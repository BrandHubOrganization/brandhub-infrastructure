# Sequence Flow — Create Workspace

> Bổ sung cho `spec.md` (FR 3.4.12). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`WorkspaceController`, `WorkspaceServiceImpl.createWorkspace`).

## Actors

- **User** — thành viên Agency, người tạo Workspace.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`workspaces`, `workspace_members`, `agency_members`, `users`).

---

## Flow A — Tạo Workspace, không kèm `assignMembers`

1. User → FE: mở form tạo Workspace trong phạm vi 1 Agency, điền `name`, `agencyId` + các field mở rộng (industry, companySize, website, ...).
2. FE → BE: `POST /api/v1/workspaces` `{name, agencyId, industry?, companySize?, website?, phone?, location?, description?, brandColor?, logoIcon?, tagline?, foundedYear?, facebookUrl?, linkedinUrl?, instagramUrl?}`.
3. BE (`WorkspaceServiceImpl.createWorkspace`):
   a. Check `currentUser` là `AgencyMember` của `agencyId` — không phải → `403 NOT_AGENCY_OWNER`.
   b. `anotherManagerChosen` = false (không có `assignMembers`).
   c. `INSERT workspaces` (settings mặc định `{}`, `createdBy = currentUser.id`).
   d. `INSERT workspace_members` (userId=currentUser.id, role=MANAGER, isActive=true) — trong cùng transaction.
4. BE → DB: 2 lệnh INSERT (bước c, d), 1 SELECT `agencyMemberRepository.findByAgencyIdAndUserId` (bước a).
5. BE → FE: `200 { data: WorkspaceResponse }`.
6. FE: chuyển hướng vào Workspace vừa tạo.

## Flow B — Tạo Workspace kèm `assignMembers`, có chuyển giao MANAGER

1. User → FE: điền form, chọn thêm `assignMembers: [{userId, role}]`, trong đó có 1 người KHÁC (không phải `currentUser`) với `role = MANAGER`.
2. FE → BE: `POST /api/v1/workspaces` (kèm `assignMembers`).
3. BE (`createWorkspace`):
   a. Check quyền Agency member — như Flow A bước a.
   b. `anotherManagerChosen = true` (có entry `role=MANAGER` với `userId != currentUser.id`).
   c. `INSERT workspaces`.
   d. `INSERT workspace_members` cho người tạo với `role = CREATOR` (không phải MANAGER, vì đã chuyển giao).
   e. Gọi `assignMembersInternal(workspaceId, agencyId, currentUser.id, assignMembers)`:
      - Với mỗi entry: check `AgencyMember` tồn tại (`agencyMemberRepository.findByAgencyIdAndUserId`) — không có → `403 NOT_AGENCY_MEMBER`.
      - Check đã có `WorkspaceMember` active cho `userId` này chưa — có rồi → bỏ qua (idempotent, không lỗi).
      - Nếu `role = MANAGER`: đếm `countByWorkspaceIdAndRoleAndIsActiveTrue(workspaceId, MANAGER)` — nếu > 0 → `409 MANAGER_ALREADY_ASSIGNED` (nhưng ở bước này chưa có MANAGER nào khác vì người tạo đã xuống CREATOR, nên pass).
      - `INSERT workspace_members` cho entry đó.
4. BE → FE: `200 { data: WorkspaceResponse }`.
5. FE: chuyển hướng vào Workspace vừa tạo, MANAGER là người được chỉ định.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Create | `name` trống (validation `@Valid`) | 400 | `VALIDATION_ERROR` |
| Create | `agencyId` thiếu (validation `@Valid`) | 400 | `VALIDATION_ERROR` |
| Create | `currentUser` không phải `AgencyMember` của `agencyId` | 403 | `NOT_AGENCY_OWNER` |
| Create (assignMembers) | Entry có `userId` không phải `AgencyMember` của agency | 403 | `NOT_AGENCY_MEMBER` |
| Create (assignMembers) | Entry `role=MANAGER` nhưng workspace đã có MANAGER active | 409 | `MANAGER_ALREADY_ASSIGNED` |
| Create (assignMembers) | Entry `userId` không tồn tại trong `users` | (throw) | `USER_NOT_FOUND` |

## Ghi chú khác biệt so với spec.md gốc

- `spec.md` mục 6 chỉ liệt kê case "nhiều hơn 1 người role MANAGER trong `assignMembers`" → `409 MANAGER_ALREADY_ASSIGNED`; code thật còn 2 nhánh lỗi khác chưa được spec.md nhắc tới: `403 NOT_AGENCY_MEMBER` (entry không thuộc agency) và lỗi `USER_NOT_FOUND` khi `userId` không tồn tại — nên bổ sung vào spec.md mục 6 nếu cần đầy đủ.

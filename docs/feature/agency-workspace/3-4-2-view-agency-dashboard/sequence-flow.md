# Sequence Flow — View Agency Dashboard

> Bổ sung cho `spec.md` (FR 3.4.2). FR này ở trạng thái **Draft — chưa implement**: không có endpoint dashboard riêng trong `AgencyController`/`AgencyServiceImpl` hiện tại (đã xác nhận qua `Grep` toàn bộ route trong `AgencyController.java` — chỉ có `listMyAgencies`, `createAgency`, `getAgency`, `updateAgency`, `uploadLogo`, `removeAgency`, `restoreAgency`, `listMembers`, `inviteMember`, `listInvitations`, `cancelInvitation`, `removeMember`, `acceptInvitation`, `listMyPendingInvitations`, `declineInvitation` — không có route `/dashboard` nào).
>
> Cập nhật: 2026-09-23.

## Kết luận

**Chưa có sequence thật để mô tả.** Không có route `GET /api/v1/agencies/{agencyId}/dashboard`, không có method service nào tính `workspaceCount`/`memberCount`/`clientCount`/`recentActivity`. Không fabricate luồng implement giả — phần dưới chỉ là **luồng dự kiến (DRAFT)** dựa trên đề xuất API Contract trong spec.md mục 5, dùng để tham khảo khi thiết kế kỹ thuật thật, **không phải luồng đã chạy được**.

## Actors (dự kiến)

- **Owner**
- **FE**
- **BE**
- **DB** — `agencies`, `agency_members`, (Workspace/ClientProfile — repository tổng hợp theo agencyId **chưa tồn tại**, cần bổ sung).

## Flow dự kiến (DRAFT — chưa code)

1. Owner → FE: mở `/agencies/:agencyId/dashboard`.
2. FE → BE: `GET /api/v1/agencies/{agencyId}/dashboard` *(route này chưa tồn tại trong code thật)*.
3. BE (dự kiến):
   a. Check `agency.ownerId == currentUser.id` — sai → `403 FORBIDDEN`.
   b. Agency không tồn tại/đã soft-delete → `404 AGENCY_NOT_FOUND`.
   c. Đếm `memberCount` qua `AgencyMemberRepository.findByAgencyId` (repository này đã có sẵn, dùng được ngay).
   d. Đếm `workspaceCount`, `clientCount` — **cần bổ sung repository method mới** theo agencyId (chưa có).
   e. `recentActivity` — chưa xác định nguồn dữ liệu (audit log?), cần thiết kế thêm.
4. BE → FE: `200 { workspaceCount, memberCount, clientCount, recentActivity: [...] }` *(shape dự kiến, chưa cố định)*.
5. FE: render dashboard tổng quan.

## Error paths tổng hợp (dự kiến, DRAFT)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Dashboard | Không phải Owner | 403 | `FORBIDDEN` |
| Dashboard | Agency không tồn tại/đã xóa | 404 | `AGENCY_NOT_FOUND` |

## Ghi chú khác biệt so với spec.md gốc

Không có drift — spec.md đã tự ghi rõ "Trạng thái tài liệu: Draft — BA confirmed, chưa code" và "CHƯA CODE" ngay trong tiêu đề mục API Contract. File sequence-flow.md này chỉ tái xác nhận qua Grep code thật rằng đúng là chưa có gì được implement, không thêm claim mới.

# Sequence Flow — Add Workspace Member

> Bổ sung cho `spec.md` (FR 3.4.19). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`WorkspaceController.inviteMember`/`assignMembers`, `WorkspaceServiceImpl`).

## Actors

- **MANAGER** — MANAGER của Workspace, người thêm thành viên.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`workspace_invitations`, `workspace_members`, `agency_members`, `users`).
- **Mail** — gửi email lời mời.

---

## Flow A — Invite qua email (luồng chính của FR này)

1. MANAGER → FE: trong `/workspaces/:id/members`, bấm "Thêm thành viên" → tab "Mời qua email", điền `email`, `role`, `note` (optional).
2. FE → BE: `POST /api/v1/workspaces/{workspaceId}/members/invite` `{email, role, note?}`.
3. BE: `@RequireRole({MemberRole.MANAGER})` chặn trước — không phải MANAGER của workspace này → `403 FORBIDDEN`.
4. BE (`WorkspaceServiceImpl.inviteMember`):
   a. Chuẩn hóa `email` (`trim().toLowerCase()`).
   b. Check email đã có `WorkspaceMember` active trong workspace này chưa (qua `userRepository.findByEmail` → `workspaceMemberRepository.findByWorkspaceIdAndUserIdAndIsActiveTrue`) — có rồi → `409 ALREADY_IN_WORKSPACE`.
   c. Check đã có invitation `PENDING` chưa hết hạn cho email đó ở workspace này chưa → `409 INVITATION_ALREADY_PENDING`.
   d. Nếu `role = MANAGER`: đếm `countByWorkspaceIdAndRoleAndIsActiveTrue(workspaceId, MANAGER)` — nếu > 0 → `409 MANAGER_ALREADY_ASSIGNED`.
   e. `INSERT workspace_invitations` (status=PENDING, token=UUID random, expiresAt=now+7 ngày — hằng số `INVITATION_EXPIRY_DAYS=7`).
5. BE → Mail: `mailService.sendWorkspaceInvitationEmail(email, workspace.name, token, note)`.
6. BE → FE: `200 { data: null }` (endpoint trả `Void`, không trả invitation).
7. FE: hiện toast thành công.

### Nhánh phụ — Accept invitation (hoàn tất Invite)

8. Invitee bấm link email → FE → BE: `POST /api/v1/workspaces/invitations/accept` `{token}`.
9. BE (`acceptInvitation`): validate token/status/expiry/email khớp → nếu `role=MANAGER` và đã có MANAGER active → `409 MANAGER_ALREADY_ASSIGNED`; nếu email đã là `WorkspaceMember` active → `409 ALREADY_IN_WORKSPACE`; hợp lệ → `INSERT workspace_members` (role theo invitation), update invitation `status=ACCEPTED`.
10. BE → FE: `200 { data: WorkspaceMemberResponse }`.

## Flow B — Assign trực tiếp (luồng phụ, không cần accept)

1. MANAGER → FE: tab "Gán từ Agency", chọn 1+ người có sẵn trong Agency, chọn role cho từng người.
2. FE → BE: `POST /api/v1/workspaces/{workspaceId}/members/assign` `{members: [{userId, role}, ...]}`.
3. BE: `@RequireRole({MemberRole.MANAGER})` chặn — không phải MANAGER → `403 FORBIDDEN`.
4. BE (`WorkspaceServiceImpl.assignMembers` → `assignMembersInternal`):
   Với mỗi entry `{userId, role}`:
   a. Check `AgencyMember` tồn tại cho `userId` trong agency của workspace — không có → `403 NOT_AGENCY_MEMBER`.
   b. Check đã có `WorkspaceMember` active cho `userId` này chưa — có rồi → thêm `userId` vào `skippedUserIds`, bỏ qua entry này (idempotent, không lỗi), tiếp tục entry kế tiếp.
   c. Nếu `role = MANAGER`: đếm MANAGER active hiện tại — nếu > 0 → `409 MANAGER_ALREADY_ASSIGNED`.
   d. Query `User` theo `userId` — không tồn tại → `USER_NOT_FOUND`.
   e. `INSERT workspace_members` (isActive=true ngay, không cần accept) — thêm vào `added`.
5. BE → DB: N lượt INSERT (theo số entry hợp lệ, không tính entry bị skip).
6. BE → FE: `200 { data: AssignMembersResponse }` — `{ added: [WorkspaceMemberResponse, ...], skippedUserIds: [uuid, ...] }`.
7. FE: cập nhật bảng thành viên với `added`; có thể hiển thị cảnh báo cho các `userId` trong `skippedUserIds` (đã là member sẵn).

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Invite / Assign | Không phải MANAGER của Workspace | 403 | `FORBIDDEN` |
| Invite | Email đã là WorkspaceMember active | 409 | `ALREADY_IN_WORKSPACE` |
| Invite | Đã có invitation PENDING cho email | 409 | `INVITATION_ALREADY_PENDING` |
| Invite / Assign | `role=MANAGER` nhưng workspace đã có MANAGER active | 409 | `MANAGER_ALREADY_ASSIGNED` |
| Assign | `userId` không phải AgencyMember của agency | 403 | `NOT_AGENCY_MEMBER` |
| Assign | `userId` không tồn tại trong `users` | — | `USER_NOT_FOUND` |
| Invite | `email`/`role` thiếu hoặc sai định dạng | 400 | `VALIDATION_ERROR` |
| Assign | `members` rỗng | 400 | `VALIDATION_ERROR` |

## Ghi chú khác biệt so với spec.md gốc

- Không có — spec.md đã cập nhật đầy đủ Error Handling (`ALREADY_IN_WORKSPACE`, `NOT_AGENCY_MEMBER`, `USER_NOT_FOUND`) và Edge Cases (hành vi `skippedUserIds`), khớp code thật.
- Đây là FR có 2 luồng độc lập (invite/assign) — sequence-flow bao phủ luồng chính (Invite, Flow A) làm trọng tâm, Flow B (Assign) ghi đầy đủ như luồng phụ cùng mức chi tiết vì cả 2 đều đã code và đều nằm trong scope FR 3.4.19.

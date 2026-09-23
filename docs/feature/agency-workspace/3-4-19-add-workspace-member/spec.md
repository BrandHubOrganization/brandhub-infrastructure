# UC — Add Workspace Member

| | |
|---|---|
| FR Code | 3.4.19 |
| Feature | Add Workspace Member |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER (của Workspace) |
| Version | 2.2 — Cập nhật 2026-09-23 — đồng bộ theo code thật (assign response đổi shape sang AssignMembersResponse) |
| Trạng thái tài liệu | Đã code |

## 1. Objective

Cho phép MANAGER thêm thành viên vào Workspace theo 2 luồng nghiệp vụ tách biệt trong code thật:
1. **Invite** (`POST /{workspaceId}/members/invite`): mời qua email — dùng cho người CHƯA CHẮC đã là Agency member (gửi lời mời, chờ accept).
2. **Assign** (`POST /{workspaceId}/members/assign`): gán thẳng — dùng cho người ĐÃ LÀ Agency member có sẵn, thêm ngay vào Workspace không cần bước chấp nhận lời mời.

## 2. User Story

Là một MANAGER của Workspace,
tôi muốn thêm thành viên vào Workspace — hoặc bằng cách mời qua email, hoặc bằng cách gán trực tiếp người đã có trong Agency,
để họ tham gia làm việc với role phù hợp.

## 3. Acceptance Criteria

### 3.1 Luồng Invite (mời qua email)

- Chỉ MANAGER của Workspace gọi được (`@RequireRole({MemberRole.MANAGER})`).
- Input: `email` (bắt buộc, định dạng email), `role` (bắt buộc, `MANAGER|CREATOR|CLIENT`), `note` (optional).
- Nếu `role = MANAGER`: hệ thống kiểm tra Workspace đã có MANAGER active chưa — nếu đã có → 409 `MANAGER_ALREADY_ASSIGNED` (mỗi Workspace chỉ có đúng 1 MANAGER active tại một thời điểm).
- Không tạo `WorkspaceMember` ngay — tạo lời mời (invitation), người được mời cần accept qua `POST /invitations/accept` (token) để chính thức trở thành `WorkspaceMember`.
- Endpoint trả `Void` — không trả lại thông tin invitation trong response.

### 3.2 Luồng Assign (gán trực tiếp)

- Chỉ MANAGER của Workspace gọi được (`@RequireRole({MemberRole.MANAGER})`).
- Input: `members` — danh sách `{userId, role}` (`role` thuộc `MANAGER|CREATOR|CLIENT`), tối thiểu 1 phần tử.
- Người dùng trong `members` phải đã tồn tại (không cần accept lời mời) — tạo `WorkspaceMember` ngay lập tức, `isActive = true`.
- Nếu có entry role = MANAGER mà Workspace đã có MANAGER active → 409 `MANAGER_ALREADY_ASSIGNED`.
- Entry mà `userId` đã là active `WorkspaceMember` của workspace này được bỏ qua (skip, idempotent, không lỗi) — **không còn im lặng bỏ qua**: `userId` bị skip được liệt kê rõ trong `skippedUserIds` của response.
- Trả về `AssignMembersResponse { added: WorkspaceMemberResponse[], skippedUserIds: UUID[] }` — `added` là các thành viên vừa được gán mới, `skippedUserIds` là các `userId` bị bỏ qua vì đã active sẵn.

## 4. UI / UX

- Nút 'Thêm thành viên' trong `/workspaces/:id/members` — nên tách rõ 2 tab/luồng: "Mời qua email" (invite) và "Gán từ Agency" (assign, chọn từ danh sách AgencyMember có sẵn).

## 5. API Contract

```
POST /api/v1/workspaces/{workspaceId}/members/invite
{ "email": "string", "role": "MANAGER|CREATOR|CLIENT", "note"?: "string" }
→ 200 { "success": true, "data": null }

POST /api/v1/workspaces/{workspaceId}/members/assign
{ "members": [{ "userId": "uuid", "role": "MANAGER|CREATOR|CLIENT" }] }
→ 200 { "success": true, "data": AssignMembersResponse }
```

`AssignMembersResponse`: `{ "added": [WorkspaceMemberResponse, ...], "skippedUserIds": ["uuid", ...] }`.

Ghi chú: còn có endpoint riêng `POST /{workspaceId}/clients` (`AddWorkspaceClientRequest { clientProfileId }`) để gán 1 Client Profile có sẵn vào Workspace, trả về `WorkspaceMemberResponse` — không thuộc phạm vi spec này nhưng liên quan (xem code thật để cập nhật spec riêng nếu cần).

## 6. Error Handling

- Không phải MANAGER của Workspace này → 403 `FORBIDDEN`.
- `role = MANAGER` khi Workspace đã có MANAGER active (cả invite lẫn assign) → 409 `MANAGER_ALREADY_ASSIGNED`.
- `email` không hợp lệ / `role` thiếu (invite) → 400 `VALIDATION_ERROR`.
- `members` rỗng (assign) → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- Assign 1 người đã có `WorkspaceMember` record ở Workspace khác (cùng Agency) với role khác → hợp lệ, role độc lập theo từng Workspace.
- Invite người đã có tài khoản trong hệ thống nhưng chưa từng vào Agency này → vẫn gửi được lời mời (invite không kiểm tra AgencyMember).
- Assign nhiều `userId`, trong đó có người đã active sẵn trong workspace → người đó xuất hiện trong `skippedUserIds`, không có entry tương ứng trong `added`, không throw lỗi (toàn bộ batch vẫn xử lý các entry còn lại).

## 8. Definition of Done

- Cả 2 luồng invite và assign hoạt động đúng theo code thật, chặn đúng trường hợp có nhiều hơn 1 MANAGER active.

## Out of Scope

- Không có.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

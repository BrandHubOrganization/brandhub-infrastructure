# UC — Invite Agency Member

| | |
|---|---|
| FR Code | 3.4.7 |
| Feature | Invite Agency Member |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép Owner mời người dùng khác vào Agency qua email + notification. Người được mời không có role gì ở cấp Agency — chỉ là thành viên thông thường.

## 2. User Story

Là một Owner,
tôi muốn mời thêm người vào Agency,
để họ có thể tham gia làm việc trong các Workspace của Agency sau này.

## 3. Acceptance Criteria

- Form nhập `email` người được mời.
- Gửi lời mời qua email + tạo notification trong app (nếu email đó đã có `User` account).
- **Người được mời sau khi accept KHÔNG có role gì trong Agency** — chỉ trở thành `AgencyMember`, chưa có quyền quản lý cụ thể (role chỉ xuất hiện khi được add vào 1 Workspace — FR 3.4.19).

## 4. UI / UX

- Trang `/agencies/:id/members`, nút 'Mời thành viên'.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/agencies/{id}/invitations
{ "email": "string" }
→ 201 { "success": true, "data": { "invitationId", "expiresAt" } }
```

## 6. Error Handling

- Email đã là Member của Agency → 409 `ALREADY_MEMBER`.
- Không phải Owner → 403 `FORBIDDEN`.

## 7. Edge Cases

- Email được mời chưa có User account trên hệ thống → vẫn gửi được lời mời qua email, khi họ đăng ký bằng đúng email đó thì tự động accept invitation.

## 8. Definition of Done

- Mời thành công, người được mời sau khi accept không có role gì (verify qua AgencyMember record không có cột role).

## Out of Scope

- Mời trực tiếp vào 1 Workspace kèm role ngay từ bước Invite Agency (2 bước tách biệt theo mô hình đã confirm).

## Tham chiếu BA

[01_Organization_Structure.md](../../../BA/01_Organization_Structure.md), [03_Agency_Workspace_Management.md](../../../BA/03_Agency_Workspace_Management.md)

# UC — Create Workspace

| | |
|---|---|
| FR Code | 3.4.12 |
| Feature | Create Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép Owner tạo Workspace mới trong Agency, bắt buộc gán ít nhất 1 Manager ngay lúc tạo.

## 2. User Story

Là một Owner,
tôi muốn tạo 1 Workspace mới,
để bắt đầu 1 không gian làm việc cho team và Client.

## 3. Acceptance Criteria

- Form nhập `name`, chọn `timezoneConfig` (mặc định theo Agency hoặc user tự chọn).
- **Bắt buộc chọn 1 người làm Manager** ngay lúc tạo — có thể là **chính Owner tự nhận** làm Manager của Workspace này, hoặc **chọn 1 Member khác** đã có trong Agency (cả 2 đều hợp lệ — [CONFIRMED 2026-09-14]).
- Tạo `Workspace` + `WorkspaceMember` (role=MANAGER) cho người được chọn trong 1 transaction.
- Sau khi tạo, hệ thống nhắc Manager chọn Media Package template (xem [04-media-package-campaign.md](../../../BA/04-media-package-campaign.md)) — nếu chưa chọn, gửi thông báo nhắc nhở (theo FR 3.5.1).

## 4. UI / UX

- Trang `/agencies/:id/workspaces/create`. Dropdown chọn Manager liệt kê Owner (mặc định) + toàn bộ AgencyMember hiện có.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/agencies/{id}/workspaces
{ "name": "string", "timezoneConfig": "string", "managerUserId": "string" }
→ 201 { "success": true, "data": { "id", "name", "agencyId" } }
```

## 6. Error Handling

- `managerUserId` không thuộc Agency này → 400 `USER_NOT_AGENCY_MEMBER`.
- `name` trống → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- Owner chọn chính mình làm Manager → vẫn tạo `WorkspaceMember` record bình thường với role=MANAGER cho Owner đó (Owner không tự động có quyền Workspace nếu không có record — xem [01-organization-structure.md](../../../BA/01-organization-structure.md)).

## 8. Definition of Done

- Tạo Workspace thành công, Manager được gán đúng theo lựa chọn, nhắc chọn Package sau khi tạo.

## Out of Scope

- Tạo Workspace từ Template có sẵn (xem FR 3.4.17 Save Workspace Template — đây là chiều ngược, tạo mới từ template là mở rộng UX, không bắt buộc trong CSV).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

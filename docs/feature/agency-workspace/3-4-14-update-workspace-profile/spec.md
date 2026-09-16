# UC — Update Workspace Profile

| | |
|---|---|
| FR Code | 3.4.14 |
| Feature | Update Workspace Profile |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER/MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép Owner/Manager cập nhật thông tin Workspace.

## 2. User Story

Là một Owner hoặc Manager,
tôi muốn cập nhật thông tin Workspace,
để giữ cấu hình luôn chính xác với thực tế vận hành.

## 3. Acceptance Criteria

- Form sửa: `name`, `timezoneConfig`.
- Cả OWNER và MANAGER (của chính Workspace đó) đều sửa được — không giới hạn chỉ Owner như Delete Workspace (FR 3.4.15).

## 4. UI / UX

- Trang `/workspaces/:id/profile/edit`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}
{ "name"?, "timezoneConfig"? }
→ 200 { "success": true, "data": { ...updated workspace... } }
```

## 6. Error Handling

- Không phải Owner/Manager của Workspace này → 403 `FORBIDDEN`.

## 7. Edge Cases

- Đổi `timezoneConfig` khi đang có Task/Livestream đã lên lịch theo timezone cũ → cần cảnh báo rõ ảnh hưởng trước khi lưu (không tự động dời lịch).

## 8. Definition of Done

- Update thành công, đúng phân quyền Owner/Manager.

## Out of Scope

- Tự động điều chỉnh lịch Task hiện có khi đổi timezone.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

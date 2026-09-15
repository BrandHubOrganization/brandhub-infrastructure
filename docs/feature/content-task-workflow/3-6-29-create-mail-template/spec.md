# UC — Create Mail Template

| | |
|---|---|
| FR Code | 3.6.29 |
| Feature | Create Mail Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | TBD (chưa gán role trong CSV) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tạo mẫu email mới, có thể áp dụng dùng lại template mẫu có sẵn.

## 2. User Story

Là một Member,
tôi muốn tạo mẫu email mới,
để chuẩn hóa nội dung gửi cho Client.

## 3. Acceptance Criteria

- Form nhập `name`, `subject`, `body` (rich text hoặc HTML).
- Có thể clone từ 1 template mẫu có sẵn (do Admin cung cấp, nếu có) rồi tùy chỉnh.

## 4. UI / UX

- Nút 'Tạo mẫu email' trong `/workspaces/:id/mail-templates`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/mail-templates
{ "name", "subject", "body" }
→ 201 { "success": true, "data": { "id" } }
```

## 6. Error Handling

- `subject`/`body` trống → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Tạo thành công.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

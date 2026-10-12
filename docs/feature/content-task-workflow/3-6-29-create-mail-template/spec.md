# UC — Create Mail Template

| | |
|---|---|
| FR Code | 3.6.29 |
| Feature | Create Mail Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | OWNER, MANAGER, CREATOR (đã chốt 2026-10-12) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Đã chốt nghiệp vụ 2026-10-12 — xem plan.md, chưa code |

## Quyết định đã chốt (2026-10-12)

> Nguồn chuẩn: [../3-6-28-32-mail-template/plan.md](../3-6-28-32-mail-template/plan.md). Mục này **ghi đè** các phần "đề xuất" và `TBD` bên dưới khi có mâu thuẫn.

- **Phạm vi**: template theo **Workspace**. **Role**: OWNER, MANAGER, CREATOR (CLIENT không). Sửa/xóa template của Workspace: người tạo hoặc OWNER/MANAGER; template hệ thống chỉ Admin sửa/xóa.
- **Trường**: `name` (≤120), `subject` (≤200), `bodyHtml` (≤100KB, TipTap, **đã sanitize allow-list** ở backend), `attachmentIds?`, `cloneFromId?`. (Tên trường là `bodyHtml`, không phải `body`.)
- **Clone**: từ template hệ thống (hoặc template khác trong Workspace); trường không gửi lên lấy từ nguồn.
- **Tệp**: upload trước qua `POST .../mail-templates/attachments` và `.../images`; 5MB/tệp, tối đa 3 tệp, tổng 10MB; allow-list `pdf/png/jpg/gif/docx/xlsx/pptx` + kiểm magic bytes.
- **Admin**: tạo mẫu hệ thống qua `POST /api/v1/admin/mail-templates` (`SYSTEM_DEFAULT`, `workspaceId = null`).

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

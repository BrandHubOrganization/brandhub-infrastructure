# UC — View Material Repository

| | |
|---|---|
| FR Code | 3.6.11 |
| Feature | View Material Repository |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Kho ảnh/video của người chụp/editor, phân loại raw vs đã retouched, cảnh báo dùng ảnh raw; kèm Brand Asset do Client cung cấp để Creator tham khảo.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn xem kho tài liệu ảnh/video của Workspace,
để tìm material phù hợp khi tạo content.

## 3. Acceptance Criteria

- List Material theo Workspace, phân loại `raw` | `retouched`.
- Ảnh `raw` hiển thị badge cảnh báo — nhắc Creator không dùng trực tiếp lên bài đăng chính thức mà chưa xử lý.
- **Brand Collection** riêng biệt: tài liệu do CLIENT cung cấp để Creator tham khảo khi sáng tạo — khác Material Repository (Material là sản phẩm do Creator/photographer tạo, Brand Collection là input từ Client).

## 4. UI / UX

- Trang `/workspaces/:id/materials`, tab riêng cho Material Repository và Brand Collection.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/materials?type=raw|retouched
→ 200 { "success": true, "data": [{ "id", "url", "type", "uploadedBy", "uploadedAt" }] }

GET /api/v1/workspaces/{id}/brand-collection
→ 200 { "success": true, "data": [{ "id", "url", "uploadedByClientId", "note" }] }
```

## 6. Error Handling

- Không có quyền truy cập Workspace → 403 `FORBIDDEN`.

## 7. Edge Cases

- File raw chưa qua retouch bị dùng trực tiếp trong 1 Task đã submit → cảnh báo hiển thị ở Task Detail, không chặn cứng submit (Manager tự quyết định reject nếu không đồng ý).

## 8. Definition of Done

- Hiển thị đúng phân loại, cảnh báo raw hoạt động.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)

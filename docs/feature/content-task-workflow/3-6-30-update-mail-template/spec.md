# UC — Update Mail Template

| | |
|---|---|
| FR Code | 3.6.30 |
| Feature | Update Mail Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | TBD (chưa gán role trong CSV) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Chỉnh sửa lại mẫu email vừa tạo hoặc mẫu có sẵn.

## 2. User Story

Là một Member,
tôi muốn sửa lại mẫu email đã tạo,
để cập nhật nội dung phù hợp hơn.

## 3. Acceptance Criteria

- Sửa `name`, `subject`, `body`.

## 4. UI / UX

- Nút Edit trong list Mail Template.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/mail-templates/{templateId}
{ "name"?, "subject"?, "body"? }
→ 200 { "success": true, "data": { ...updated template... } }
```

## 6. Error Handling

- Không có quyền → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Update thành công.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)

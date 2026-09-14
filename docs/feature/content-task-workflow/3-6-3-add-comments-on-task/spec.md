# UC — Add Comments On Task

| | |
|---|---|
| FR Code | 3.6.3 |
| Feature | Add Comments On Task |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép nhận xét, yêu cầu chỉnh sửa trên Task — dùng chung cho cả 3 role tham gia.

## 2. User Story

Là một Creator, Client, hoặc Manager,
tôi muốn bình luận trên 1 Task,
để trao đổi/yêu cầu chỉnh sửa trực tiếp trong luồng công việc.

## 3. Acceptance Criteria

- Textarea nhập comment, hỗ trợ mention (@user), có thể đính kèm ảnh/link tham khảo.
- Comment hiển thị theo timeline, kèm tên + role người comment + timestamp.

## 4. UI / UX

- Panel comment bên phải trang Task Detail, giống pattern Jira/Trello.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/tasks/{taskId}/comments
{ "content": "string", "attachments"?: ["string"] }
→ 201 { "success": true, "data": { "id", "content", "authorId", "createdAt" } }

GET /api/v1/workspaces/{id}/tasks/{taskId}/comments
→ 200 { "success": true, "data": [{...}] }
```

## 6. Error Handling

- Không có quyền truy cập Task này (không thuộc Workspace) → 403 `FORBIDDEN`.

## 7. Edge Cases

- Client comment trên Task chưa `requiresClientApproval=true` → vẫn cho phép comment (comment không giới hạn theo cờ approval, chỉ approval action mới giới hạn).

## 8. Definition of Done

- Comment tạo/hiển thị đúng thứ tự thời gian.

## Out of Scope

- Edit/xóa comment sau khi đã gửi (không có trong CSV, có thể bổ sung sau).

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)

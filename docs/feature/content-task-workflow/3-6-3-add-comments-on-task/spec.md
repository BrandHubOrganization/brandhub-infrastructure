# UC — Add Comments On Task

| | |
|---|---|
| FR Code | 3.6.3 |
| Feature | Add Comments On Task |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | BA confirmed 2026-10-14; Q13 cho Client xem/bình luận mọi Task cùng Workspace; chưa triển khai ứng dụng |

## 1. Objective

Cho phép nhận xét, yêu cầu chỉnh sửa trên Task — dùng chung cho cả 3 role tham gia.

## 2. User Story

Là một Creator, Client, hoặc Manager,
tôi muốn bình luận trên 1 Task,
để trao đổi/yêu cầu chỉnh sửa trực tiếp trong luồng công việc.

## 3. Acceptance Criteria

- Textarea nhập comment, hỗ trợ mention (@user), có thể đính kèm ảnh/link tham khảo.
- Comment hiển thị theo timeline, kèm tên + role người comment + timestamp.
- Vẫn cho tạo comment mới trên Task COMPLETED/CANCELLED nếu người dùng còn quyền Workspace/Task. Comment không mở lại Task, Campaign hoặc vòng approval.
- Ảnh cho phép JPEG/PNG/WebP, tối đa 5 ảnh mỗi comment và 5 MB mỗi ảnh; kiểm tra ở UI và API, định dạng thực chứ không chỉ tên file.
- Q13 confirmed 2026-10-14: Client active được xem và bình luận mọi Task cùng Workspace, kể cả Task
  thủ công và Task cũ, không phân biệt nội bộ/thường. Lịch sử bình luận và ảnh đã ATTACHED cũng theo quyền
  Workspace; upload DRAFT vẫn chỉ chủ upload được preview. Không mở quyền người ngoài hoặc đã rời Workspace.
- Mention chỉ tới người có quyền Task và đang hoạt động trong Workspace; không coi một URL ảnh bất kỳ là attachment đã có quyền sử dụng.
- Thông báo in-app tới người được mention, Creator phụ trách, QC và Manager của Workspace; bỏ trùng, bỏ tác giả và chỉ gửi người còn quyền Task. Client chỉ nhận khi được mention (Q11 confirmed); không gửi email hoặc thông báo mọi Client trong Workspace.

## 4. UI / UX

- Panel comment bên phải trang Task Detail, giống pattern Jira/Trello.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/tasks/{taskId}/comments
{ "content": "string", "mentions"?: ["User UUID"], "attachmentIds"?: ["owned upload ID"], "clientRequestId": "UUID" }
→ 201 { "success": true, "data": { "id", "content", "authorId", "createdAt" } }

GET /api/v1/workspaces/{id}/tasks/{taskId}/comments
→ 200 { "success": true, "data": [{...}] }
```

Contract là đề xuất kỹ thuật: attachmentIds thay arbitrary URL để kiểm tra ownership, clientRequestId chống gửi trùng; phân trang timeline chốt trong plan. Không dùng Chat Workspace để thay thế lịch sử bình luận theo Task.

## 6. Error Handling

- Không có quyền truy cập Task này (không thuộc Workspace) → 403 `FORBIDDEN`.

## 7. Edge Cases

- Client comment trên Task không yêu cầu Client duyệt → vẫn cho phép nếu còn active cùng Workspace. Cờ requiresClientApproval chỉ cấu hình duyệt kết quả, không quyết định quyền bình luận.
- Task terminal vẫn được comment; người bị gỡ khỏi Workspace không được gửi/xem tiếp dù từng tham gia thread.

## 8. Definition of Done

- Comment tạo/hiển thị đúng thứ tự thời gian.

## Out of Scope

- Edit/xóa comment sau khi đã gửi (không có trong CSV, có thể bổ sung sau).

## i18n và theme

Composer/timeline/mention/upload/errors dùng `tasks.comments.*`, `tasks.mentions.*`, `tasks.uploads.*`, `tasks.errors.*` vi/en song song; semantic light/dark, bàn phím và layout mobile. Có loading/empty/forbidden/upload progress/error/success; lỗi upload/submit giữ draft, retry không tạo comment trùng. Xem [plan](plan.md), [task](task.md), [test](test.md).

## Tham chiếu BA

[05-content-task-workflow.md](../../../ba/05-content-task-workflow.md), [roadmap](../task-detail-assignment-comments-roadmap.md).

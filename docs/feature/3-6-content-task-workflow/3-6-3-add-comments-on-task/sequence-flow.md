# Sequence Flow — Add Comments On Task

> Supplements `spec.md` (FR 3.6.3). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskCommentPanelUI`.
- **System** — `TaskCommentController` / `TaskCommentService`.

---

## Flow A — Luồng thực thi chính: Add Comments On Task

1. manager -> taskcommentpanelui: `opens comment panel on task detail page`
2. taskcommentpanelui -> taskcommentcontrolle: `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/comments`
3. taskcommentcontrolle -> taskcommentservice: `getComments(workspaceId, taskId, currentUser)`
4. taskcommentservice -> taskrepository: `existsByIdAndWorkspaceId(taskId, workspaceId)`
5. taskrepository --> taskcommentservice: `true`
6. taskcommentservice -> taskcommentrepositor: `findByTaskIdOrderByCreatedAtAsc(taskId)`
7. taskcommentrepositor --> taskcommentservice: `commentList`
8. taskcommentservice --> taskcommentcontrolle: `List<TaskCommentResponse>`
9. taskcommentcontrolle --> taskcommentpanelui: `200 OK (commentList)`
10. taskcommentpanelui --> manager: `render comments timeline (author, role, timestamp, text, attachments)`
11. manager --> taskcommentpanelui: `inputs comment text (optional @mentions), attachments & clicks "Send"`
12. taskcommentpanelui ->> taskcommentcontrolle: `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/comments (CreateTaskCommentRequest)`
13. taskcommentcontrolle ->> taskcommentservice: `addComment(workspaceId, taskId, currentUser, request)`
14. taskcommentservice ->> taskrepository: `findByIdAndWorkspaceId(taskId, workspaceId)`
15. taskrepository --> taskcommentservice: `task`
16. taskcommentservice --> taskcommentcontrolle: `throw BusinessException (403 FORBIDDEN)`
17. taskcommentcontrolle --> taskcommentpanelui: `403 Forbidden`
18. taskcommentpanelui --> manager: `show access error toast ("You do not have access to comment on this task")`
19. taskcommentservice --> taskcommentcontrolle: `throw BusinessException (400 INVALID_COMMENT_CONTENT)`
20. taskcommentcontrolle --> taskcommentpanelui: `400 Bad Request`
21. taskcommentpanelui --> manager: `show validation error ("Comment content cannot be empty")`
22. taskcommentservice ->> taskcommentrepositor: `save(taskComment with authorId, content, attachments)`
23. taskcommentrepositor --> taskcommentservice: `savedComment`
24. taskcommentservice --> taskcommentcontrolle: `TaskCommentResponse`
25. taskcommentcontrolle --> taskcommentpanelui: `201 Created (TaskCommentResponse)`
26. taskcommentpanelui --> manager: `append comment to timeline & clear input area`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

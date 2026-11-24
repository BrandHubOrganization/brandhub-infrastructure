# Sequence Flow — Identify Task Detail

> Supplements `spec.md` (FR 3.6.1). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskDetailUI`.
- **System** — `TaskController` / `TaskService`.

---

## Flow A — Luồng thực thi chính: Identify Task Detail

1. manager -> taskdetailui: `navigates to task detail page (/workspaces/:id/tasks/:taskId/detail)`
2. taskdetailui -> taskcontroller: `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}`
3. taskservice -> taskservice: `preserve or append original request context`
4. taskcontroller -> taskservice: `getTask(workspaceId, taskId)`
5. taskservice -> taskrepository: `findByIdAndWorkspaceId(taskId, workspaceId)`
6. taskrepository --> taskservice: `task`
7. taskservice --> taskcontroller: `TaskResponse`
8. taskcontroller --> taskdetailui: `200 OK (TaskResponse)`
9. taskdetailui --> manager: `render task form (fields based on task.type: Post/Livestream/Survey)`
10. manager ->> taskdetailui: `fills description, dueDate, typeSpecificFields & clicks "Save Details"`
11. taskdetailui ->> taskcontroller: `PATCH /api/v1/workspaces/{workspaceId}/tasks/{taskId}/detail (IdentifyTaskDetailRequest)`
12. taskcontroller ->> taskservice: `identifyTaskDetail(workspaceId, taskId, currentUser, request)`
13. taskservice ->> taskrepository: `findByIdAndWorkspaceId(taskId, workspaceId)`
14. taskrepository --> taskservice: `task`
15. taskservice --> taskcontroller: `throw BusinessException (403 FORBIDDEN)`
16. taskcontroller --> taskdetailui: `403 Forbidden`
17. taskdetailui --> manager: `show access denied error toast`
18. taskservice --> taskcontroller: `throw BusinessException (409 TASK_NOT_IN_BACKLOG)`
19. taskcontroller --> taskdetailui: `409 Conflict`
20. taskdetailui --> manager: `show error alert ("Task must be in BACKLOG status")`
21. taskservice --> taskcontroller: `throw BusinessException (400 BAD_REQUEST)`
22. taskcontroller --> taskdetailui: `400 Bad Request`
23. taskdetailui --> manager: `display form validation errors`
24. taskservice ->> taskrepository: `save(task with updated details and status=DETAIL_IDENTIFIED)`
25. taskrepository --> taskservice: `updatedTask`
26. taskservice --> taskcontroller: `TaskResponse (status=DETAIL_IDENTIFIED)`
27. taskcontroller --> taskdetailui: `200 OK (TaskResponse)`
28. taskdetailui --> manager: `show success toast & update status badge to DETAIL_IDENTIFIED`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

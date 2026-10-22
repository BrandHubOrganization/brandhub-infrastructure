# Sequence Flow — Kanban Board Task View

> Supplements `spec.md` (FR 3.6.7). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator / Client / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskCalendarPage (UI)`.
- **System** — `TaskController` / `TaskServiceImpl`.

---

## Flow A — Luồng thực thi chính: Kanban Board Task View

1. taskserviceimpl -> taskserviceimpl: `groupTasksIntoColumns(tasks, groupBy)`
2. creatorclientmanager -> taskcalendarpageui: `Select "Kanban Board" tab`
3. taskcalendarpageui -> taskcontroller: `Request tasks kanban board (groupBy)`
4. taskcontroller -> taskserviceimpl: `getTasksKanbanBoard(groupBy)`
5. taskserviceimpl -> taskrepository: `findTasks()`
6. taskrepository --> taskserviceimpl: `return List<Task>`
7. taskserviceimpl -> taskkanbanresponse: `mapToKanbanResponse(columns)`
8. taskkanbanresponse --> taskserviceimpl: `return kanbanData`
9. taskcalendarpageui --> creatorclientmanager: `Render Kanban columns with draggable task cards`
10. taskserviceimpl --> taskcontroller: `return kanbanData`
11. taskcontroller --> taskcalendarpageui: `return 200 OK (Kanban columns, task cards per column)`
12. creatorclientmanager -> taskcalendarpageui: `Drag card from "IN_PROGRESS" to "REVIEW"`
13. taskcalendarpageui --> creatorclientmanager: `Disable card dragging / show tooltip ("Read-only permission")`
14. taskcalendarpageui -> taskcontroller: `Request move task card (newStatus)`
15. taskcontroller -> taskserviceimpl: `updateTaskStatusByKanban(taskId, newStatus)`
16. taskserviceimpl -> taskrepository: `findTask(taskId)`
17. taskrepository --> taskserviceimpl: `return Task`
18. taskserviceimpl --> taskcontroller: `throw INVALID_STATUS_TRANSITION (409 Conflict)`
19. taskcontroller --> taskcalendarpageui: `return 409 Conflict (Illegal state transition to target status)`
20. taskcalendarpageui --> creatorclientmanager: `Revert card position & display validation warning toast`
21. taskserviceimpl -> taskserviceimpl: `task.setStatus(newStatus)`
22. taskserviceimpl -> taskrepository: `save(task)`
23. taskrepository --> taskserviceimpl: `return updatedTask`
24. taskserviceimpl --> taskcontroller: `return savedTask`
25. taskcontroller --> taskcalendarpageui: `return 200 OK (Updated task status)`
26. taskcalendarpageui --> creatorclientmanager: `Snap card to new column & trigger status update`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

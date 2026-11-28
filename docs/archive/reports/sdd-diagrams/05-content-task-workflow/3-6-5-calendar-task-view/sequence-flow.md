# Sequence Flow — Calendar Task View

> Supplements `spec.md` (FR 3.6.5). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator / Client / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskCalendarPage (UI)`.
- **System** — `TaskController` / `TaskServiceImpl`.

---

## Flow A — Luồng thực thi chính: Calendar Task View

1. creatorclientmanager -> taskcalendarpageui: `Select "Calendar View" tab (e.g., month = 2026-10)`
2. taskcalendarpageui -> taskcontroller: `Request tasks calendar view (month)`
3. taskcontroller -> taskserviceimpl: `getTasksCalendarView(month)`
4. taskserviceimpl -> taskrepository: `findTasksByMonth(startOfMonth, endOfMonth)`
5. taskrepository --> taskserviceimpl: `return List<Task>`
6. taskserviceimpl -> taskcalendarresponse: `mapToCalendarEvents(tasks)`
7. taskcalendarresponse --> taskserviceimpl: `return calendarEvents`
8. taskserviceimpl --> taskcontroller: `return calendarEvents`
9. taskcontroller --> taskcalendarpageui: `return 200 OK (Calendar events, due dates)`
10. taskcalendarpageui --> creatorclientmanager: `Render interactive calendar grid with task chips`
11. creatorclientmanager -> taskcalendarpageui: `Drag task chip from Oct 10 to Oct 15`
12. taskcalendarpageui --> creatorclientmanager: `Disable drag-and-drop / show tooltip ("Read-only permission")`
13. taskcalendarpageui -> taskcontroller: `Request reschedule task (newDueDate)`
14. taskcontroller -> taskserviceimpl: `rescheduleTask(taskId, newDueDate)`
15. taskserviceimpl -> taskrepository: `findTask(taskId)`
16. taskrepository --> taskserviceimpl: `return Optional<Task>`
17. taskserviceimpl -> taskserviceimpl: `updateDueDate(task, newDueDate)`
18. taskserviceimpl -> taskrepository: `save(task)`
19. taskrepository --> taskserviceimpl: `return updatedTask`
20. taskserviceimpl --> taskcontroller: `return TaskResponse(updatedTask)`
21. taskcontroller --> taskcalendarpageui: `return 200 OK (Updated task with new due date)`
22. taskcalendarpageui --> creatorclientmanager: `Update calendar chip position & display success toast`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

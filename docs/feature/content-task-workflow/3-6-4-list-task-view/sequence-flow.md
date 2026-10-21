# Sequence Flow — List Task View

> Supplements `spec.md` (FR 3.6.4). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator / Client / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskListPage (UI)`.
- **System** — `TaskController` / `TaskServiceImpl`.

---

## Flow A — Luồng thực thi chính: List Task View

1. creatorclientmanager -> tasklistpageui: `Select "List View" tab on Tasks board`
2. tasklistpageui -> taskcontroller: `Request tasks list view (page, size, sortBy)`
3. taskcontroller -> taskserviceimpl: `getTasksListView(pageable)`
4. taskserviceimpl -> taskrepository: `findTasks(pageable)`
5. taskrepository --> taskserviceimpl: `return Page<Task>`
6. taskserviceimpl -> tasklistresponse: `mapToSummaryList(pageTasks)`
7. tasklistresponse --> taskserviceimpl: `return taskItems`
8. taskserviceimpl --> taskcontroller: `return pagedTasks`
9. taskcontroller --> tasklistpageui: `return 200 OK (Task list items, pagination metadata)`
10. tasklistpageui --> creatorclientmanager: `Render task table with columns & Pagination controls`
11. taskserviceimpl --> taskcontroller: `return emptyPagedResult`
12. taskcontroller --> tasklistpageui: `return 200 OK (Empty task list, zero pagination)`
13. tasklistpageui --> creatorclientmanager: `Display Empty State with CTA ("Create first Campaign or Content Request")`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

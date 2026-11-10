# Sequence Flow — View Task Filter

> Supplements `spec.md` (FR 3.6.8). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator / Client / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskFilterBar / TaskViews (UI)`.
- **System** — `TaskController` / `TaskServiceImpl`.

---

## Flow A — Luồng thực thi chính: View Task Filter

1. creatorclientmanager -> taskfilterbartaskvie: `Enter search keyword & select filter criteria (type, status, assignee, dueDate)`
2. taskfilterbartaskvie -> taskcontroller: `Request search & filter tasks (criteria, sortBy)`
3. taskcontroller -> taskserviceimpl: `searchAndFilterTasks(criteria, pageable)`
4. taskserviceimpl -> taskserviceimpl: `buildSpecification(criteria)`
5. taskserviceimpl -> taskrepository: `findFilteredTasks(specification, pageable)`
6. taskrepository --> taskserviceimpl: `return Page<Task>`
7. taskserviceimpl -> taskfilterresultresp: `mapToSummaryList(filteredPage)`
8. taskfilterresultresp --> taskserviceimpl: `return filterResults`
9. taskserviceimpl --> taskcontroller: `return pagedResults`
10. taskcontroller --> taskfilterbartaskvie: `return 200 OK (Filtered tasks list, total count, pagination metadata)`
11. taskfilterbartaskvie --> creatorclientmanager: `Dynamically refresh active view (List / Calendar / Gantt / Kanban) with filtered tasks`
12. taskserviceimpl --> taskcontroller: `return emptyPagedResult`
13. taskcontroller --> taskfilterbartaskvie: `return 200 OK (Zero matching tasks, empty results)`
14. taskfilterbartaskvie --> creatorclientmanager: `Display "No matching tasks found" & show "Reset Filters" action`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

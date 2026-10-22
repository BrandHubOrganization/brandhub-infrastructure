# Sequence Flow — Grantt Timeline Task View

> Supplements `spec.md` (FR 3.6.6). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator / Client / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskListPage (UI)`.
- **System** — `TaskController` / `TaskServiceImpl`.

---

## Flow A — Luồng thực thi chính: Grantt Timeline Task View

1. creatorclientmanager -> tasklistpageui: `Select "Timeline / Gantt" tab (optional filter: campaignId)`
2. tasklistpageui -> taskcontroller: `Request tasks timeline view (campaignId)`
3. taskcontroller -> taskserviceimpl: `getTasksGanttTimeline(campaignId)`
4. taskserviceimpl -> taskrepository: `findTasksByCampaign(campaignId)`
5. taskrepository --> taskserviceimpl: `5: return List<Task>`
6. taskserviceimpl -> taskserviceimpl: `calculateTaskProgressAndDependencies(tasks)`
7. taskserviceimpl -> tasklistresponse: `mapToGanttResponse(timelineItems)`
8. tasklistresponse --> taskserviceimpl: `return ganttData`
9. taskserviceimpl --> taskcontroller: `return ganttData`
10. taskcontroller --> tasklistpageui: `return 200 OK (Timeline bars, dependencies, milestone dates)`
11. tasklistpageui --> creatorclientmanager: `Render interactive horizontal Gantt chart bars & milestones`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

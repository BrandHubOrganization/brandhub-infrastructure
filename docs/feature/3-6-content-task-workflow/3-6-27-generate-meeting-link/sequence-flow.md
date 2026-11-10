# Sequence Flow — Generate Meeting Link

> Supplements `spec.md` (FR 3.6.27). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskDetailPage (UI)`.
- **System** — `TaskController` / `TaskServiceImpl`.

---

## Flow A — Luồng thực thi chính: Generate Meeting Link

1. googlecalendarmeetap --> googlecalendarclient: `return 401 Unauthorized / 503 Service Unavailable`
2. creator -> taskdetailpageui: `Click "Generate Google Meet Link"`
3. taskserviceimpl -> taskserviceimpl: `attachMeetingLink(task, meetingUrl)`
4. taskdetailpageui -> taskcontroller: `Request generate meeting link`
5. taskcontroller -> taskserviceimpl: `generateMeetingLink(taskId)`
6. taskserviceimpl -> taskrepository: `findTask(taskId)`
7. taskrepository --> taskserviceimpl: `return Optional<Task>`
8. taskserviceimpl --> taskcontroller: `throw TASK_NOT_FOUND`
9. taskcontroller --> taskdetailpageui: `return 404 Not Found (Task not found in workspace)`
10. taskdetailpageui --> creator: `Display error message: "Task not found in workspace"`
11. taskserviceimpl -> googlecalendarclient: `createCalendarEventWithMeet(task)`
12. googlecalendarclient -> googlecalendarmeetap: `Call Google Calendar / Meet API`
13. googlecalendarmeetap --> googlecalendarclient: `return 401 / 503 error`
14. googlecalendarclient --> taskserviceimpl: `throw GoogleApiException`
15. taskcontroller --> taskdetailpageui: `return 502 Bad Gateway (Google Meet service unavailable)`
16. taskserviceimpl --> taskcontroller: `throw ServiceUnavailableException`
17. taskdetailpageui --> creator: `Display alert: "Failed to generate Google Meet link"`
18. googlecalendarmeetap --> googlecalendarclient: `return Meet event (hangoutLink)`
19. googlecalendarclient --> taskserviceimpl: `return meetingUrl`
20. taskserviceimpl -> taskrepository: `save(task)`
21. taskrepository --> taskserviceimpl: `return savedTask`
22. taskserviceimpl -> meetinglinkresponse: `mapToResponse(savedTask)`
23. meetinglinkresponse --> taskserviceimpl: `return meetingLinkResponse`
24. taskserviceimpl --> taskcontroller: `return meetingLinkResponse`
25. taskcontroller --> taskdetailpageui: `return 201 Created (Generated Google Meet link, task details)`
26. taskdetailpageui --> creator: `Display Meet Link badge with "Copy Link" & "Join Now" buttons`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

# Sequence Flow — Push Notification

> Supplements `spec.md` (FR 3.10.1). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **System/Event** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Push Notification Page`.
- **System** — `NotificationController` / `NotificationService`.

---

## Flow A — Luồng thực thi chính: Push Notification

1. systemevent -> notificationcontroll: `POST /api/v1/notifications/send (NotificationRequest)`
2. notificationcontroll -> notificationservice: `sendNotification(request)`
3. notificationservice -> userrepository: `findById(targetUserId)`
4. userrepository --> notificationservice: `Optional.empty()`
5. notificationservice --> notificationcontroll: `404 Not Found (USER_NOT_FOUND)`
6. notificationcontroll --> systemevent: `404 Not Found`
7. userrepository --> notificationservice: `Optional<User>`
8. notificationservice -> notificationreposito: `save(newNotification)`
9. notificationreposito --> notificationservice: `savedNotification`
10. notificationservice -> websocketservice: `push(targetUserId, notificationPayload)`
11. websocketservice --> notificationservice: `delivered`
12. notificationservice --> notificationcontroll: `200 OK (NotificationResponse)`
13. notificationcontroll --> systemevent: `200 OK`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

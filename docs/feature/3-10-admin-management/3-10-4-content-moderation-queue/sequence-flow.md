# Sequence Flow — Content Moderation Queue

> Supplements `spec.md` (FR 3.10.4). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Admin** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `AdminModerationPage (UI)`.
- **System** — `ModerationController` / `ModerationService`.

---

## Flow A — Luồng thực thi chính: Content Moderation Queue

1. admin -> adminmoderationpageu: `views flagged content list, selects item & action (APPROVE / REMOVE)`
2. adminmoderationpageu -> moderationcontroller: `PATCH /api/v1/admin/moderation/{contentId} (ModerationDecisionRequest)`
3. moderationcontroller -> moderationservice: `moderateContent(adminId, contentId, decision)`
4. moderationservice -> contentrepository: `findById(contentId)`
5. contentrepository --> moderationservice: `Optional.empty()`
6. moderationservice --> moderationcontroller: `404 Not Found (CONTENT_NOT_FOUND)`
7. moderationcontroller --> adminmoderationpageu: `404 Not Found`
8. adminmoderationpageu --> admin: `Show error "Content not found"`
9. contentrepository --> moderationservice: `Optional<Content>`
10. moderationservice -> contentrepository: `update(content, status=APPROVED / REMOVED)`
11. contentrepository --> moderationservice: `updatedContent`
12. moderationservice -> notificationservice: `notifyUser(content.ownerId, decision)`
13. notificationservice --> moderationservice: `ok`
14. moderationservice --> moderationcontroller: `200 OK (ModerationResponse)`
15. moderationcontroller --> adminmoderationpageu: `200 OK`
16. adminmoderationpageu --> admin: `"Moderation action applied"`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

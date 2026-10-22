# Sequence Flow — Schedule Platform Post

> Supplements `spec.md` (FR 3.8.6). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `SchedulePostModal / Calendar (UI)`.
- **System** — `PostController` / `PostServiceImpl`.

---

## Flow A — Luồng thực thi chính: Schedule Platform Post

1. creatormanager -> schedulepostmodalcal: `Select channels & set scheduledAt`
2. schedulepostmodalcal -> postcontroller: `POST /api/v1/workspaces/{workspaceId}/posts/{postId}/schedule (targetPlatforms, scheduledAt)`
3. postcontroller -> postserviceimpl: `schedulePost(workspaceId, postId, targetPlatforms, scheduledAt)`
4. postserviceimpl -> postmongorepository: `findByIdAndWorkspaceId(postId, workspaceId)`
5. postmongorepository --> postserviceimpl: `return PostDocument`
6. postserviceimpl --> postcontroller: `throw BusinessException (SCHEDULE_IN_PAST / 400)`
7. postcontroller --> schedulepostmodalcal: `return 400 Bad Request`
8. schedulepostmodalcal --> creatormanager: `return Error Response (HTTP 400/401/Timeout)`
9. postserviceimpl -> postserviceimpl: `postDoc.setStatus('SCHEDULED') postDoc.setScheduledAt(scheduledAt) postDoc.setTargetPlatforms(targetPlatforms)`
10. postserviceimpl -> postmongorepository: `save(postDoc)`
11. postmongorepository --> postserviceimpl: `return savedPostDoc`
12. postserviceimpl -> postscheduleresponse: `new PostScheduleResponse(savedPostDoc)`
13. postscheduleresponse --> postserviceimpl: `return scheduleResponse`
14. postserviceimpl --> postcontroller: `return scheduleResponse`
15. postcontroller --> schedulepostmodalcal: `return 200 OK (ApiResponse { data: scheduleResponse })`
16. schedulepostmodalcal -> creatormanager: `Display scheduled post badge on Calendar View`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

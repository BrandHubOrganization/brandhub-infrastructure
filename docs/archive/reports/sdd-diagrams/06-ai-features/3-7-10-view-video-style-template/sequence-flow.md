# Sequence Flow — View Video Style Template

> Supplements `spec.md` (FR 3.7.6). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `VideoStudioPage (UI)`.
- **System** — `AiVideoController` / `AiVideoService`.

---

## Flow A — Luồng thực thi chính: View Video Style Template

1. creatormanager -> videostudiopageui: `Open Video AI`
2. videostudiopageui -> aivideocontroller: `GET /workspaces/{id}/ai/video-styles`
3. aivideocontroller -> aivideocontroller: `Check workspace access (@RequireRole)`
4. aivideocontroller --> videostudiopageui: `403 — access denied`
5. videostudiopageui --> creatormanager: `Show access error`
6. aivideocontroller -> aivideoservice: `styles()`
7. aivideoservice -> aiservicevideoapi: `GET /api/v1/ai/video/styles`
8. aiservicevideoapi --> aivideoservice: `Style catalog / upstream error`
9. aivideoservice --> aivideocontroller: `AiServiceException`
10. aivideocontroller --> videostudiopageui: `502 / 503 — styles unavailable`
11. videostudiopageui --> creatormanager: `Show error and retry`
12. aivideoservice --> aivideocontroller: `JsonNode — video styles`
13. aivideocontroller --> videostudiopageui: `200 OK — style catalog`
14. videostudiopageui --> creatormanager: `Show video style gallery`
15. creatormanager -> videostudiopageui: `Select or clear a video style`
16. videostudiopageui --> creatormanager: `Highlight selection; set suggested aspect ratio`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

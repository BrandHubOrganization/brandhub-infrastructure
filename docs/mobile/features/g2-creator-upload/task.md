# Task — G2 Creator Upload (Mobile)

> [spec.md](./spec.md)

## Backend (business-service) — ĐÃ CODE XONG (2026-10-22), chờ team confirm policy

- [x] Thêm `createPresignedUploadUrl(key, contentType, ttlSeconds)` vào `FileStorageService` + `S3FileStorageServiceImpl` (`PutObjectPresignRequest`, cùng pattern `createPresignedDownloadUrl`).
- [x] Thêm field `taskId` (nullable) vào `MaterialDocument` + `MaterialResponse` DTO + wiring `toResponse()`.
- [x] `POST /api/v1/workspaces/{workspaceId}/materials/upload-session` — role `CREATOR`, check assignee (`task.assigneeId == currentUser`) + status không phải FINISHED/CANCELLED, whitelist content-type (`video/mp4`, `video/quicktime`), sinh S3 key `video/materials/{workspaceId}/{taskId}/{epochMillis}-{uuid}.{ext}`, trả `uploadUrl`/`s3Key`/`expiresAt` (TTL 15 phút hard-code).
- [x] `POST /api/v1/workspaces/{workspaceId}/materials/upload-session/confirm` — re-check quyền y hệt bước trên, idempotent theo `s3Key` (`findByS3Key`, trả record cũ nếu đã tồn tại), lưu `MaterialDocument` với `type=RAW`.
- [x] Policy max file size — **CHƯA CHỐT VỚI TEAM**, tạm hard-code 1GB (`MAX_UPLOAD_FILE_SIZE_BYTES`) ở `MaterialServiceImpl`, lỗi `UPLOAD_FILE_TOO_LARGE` (400) nếu vượt — **note hỏi team**: số này đúng chưa, có cần khác nhau theo plan (G7) không.
- [ ] HEAD-object verify trước khi lưu Material ở bước confirm — **chưa làm** (chấp nhận rủi ro nhỏ record "ma" như spec đã ghi, bỏ qua cho MVP).

**Error codes mới thêm vào `ErrorCode.java`:** `TASK_NOT_FOUND_FOR_UPLOAD` (404), `TASK_NOT_ASSIGNED` (403), `TASK_NOT_ACTIVE` (409), `INVALID_UPLOAD_CONTENT_TYPE` (400), `UPLOAD_FILE_TOO_LARGE` (400).

## Mobile — dependencies

- [ ] `expo install expo-camera expo-image-picker` (chưa có trong `package.json`).
- [ ] Xác nhận `expo-file-system` version hỗ trợ `createUploadTask` với progress callback.

## Mobile — screens & flow

- [ ] Task List (assigned) — lọc `assigneeId=currentUser`, status chưa `FINISHED`/`CANCELLED` (dùng API Task tạm nếu G5 chưa xong, không thiết kế lại Task list ở đây).
- [ ] Task Detail — thêm nút "Quay video" (`expo-camera`) / "Chọn từ thư viện" (`expo-image-picker`, `mediaTypes: Videos`).
- [ ] Màn Upload: hiển thị tên file + dung lượng, nút "Bắt đầu upload".
- [ ] Gọi `upload-session` lấy `uploadUrl`+`s3Key` → `FileSystem.createUploadTask` PUT với progress bar.
- [ ] PUT xong → gọi `upload-session/confirm`.
- [ ] Màn "Đã gắn vào Task" sau khi confirm thành công.

## Mobile — resilience

- [ ] Retry auto tối đa 3 lần khi lỗi network (không phải 4xx), backoff 2s/5s/10s; hết retry → nút "Thử lại" thủ công.
- [ ] Giữ file local (không xoá cache) cho tới khi confirm thành công.
- [ ] Xử lý lỗi 403 signature-expired từ PUT: gọi lại `upload-session` lấy key mới, PUT lại từ đầu.
- [ ] Lưu `s3Key`+`taskId` vào local storage khi PUT xong nhưng chưa confirm — cho phép gọi lại confirm trực tiếp (không PUT lại) nếu app bị đóng giữa chừng.
- [ ] Giới hạn Expo managed: upload chỉ chạy foreground — dừng khi app bị kill/minimize, resume khi mở lại (không background transfer thật).

## Chưa làm / out of scope G2 (xem spec mục 7)

- [ ] Không làm: AI auto-edit raw footage, auto-caption, tự tạo Task mới sau upload, S3 Multipart Upload resumable thật, background upload khi app kill/minimize.

## Rủi ro còn mở (xem spec mục 8)

- Giới hạn file size chưa chốt số cụ thể.
- Field `taskId` mới trên `MaterialDocument` cần xác nhận với backend dev trước khi code (thay đổi schema).
- Video compression: MVP không làm, chỉ giảm resolution record 720p nếu dung lượng gây vấn đề thực tế.

# Plan — G2 Creator Upload (Mobile)

> [spec.md](./spec.md) — chi tiết API/flows/error cases đầy đủ. File này là bản tóm tắt thứ tự implement + quyết định kỹ thuật chốt.

## Thứ tự implement (theo dependency)

1. **Backend trước — mobile không chạy được nếu thiếu:**
   - Thêm `createPresignedUploadUrl(key, contentType, ttlSeconds)` vào `FileStorageService` + `S3FileStorageServiceImpl` (dùng `S3Presigner.presignPutObject`, pattern giống `createPresignedDownloadUrl` đã có sẵn).
   - Thêm field `taskId` (nullable) vào `MaterialDocument` + `MaterialResponse` DTO — **xác nhận với backend dev trước khi code vì đây là thay đổi schema Mongo + DTO public** (spec mục 8 câu 4).
   - 2 endpoint mới: `POST /materials/upload-session` (xin presigned URL) + `POST /materials/upload-session/confirm` (tạo Material record).
   - Chốt policy max file size trước khi code validate (đề xuất 500MB-1GB).
2. **Mobile dependencies:**
   - `expo install expo-camera expo-image-picker` (chưa có trong `package.json`).
   - Xác nhận `expo-file-system` hỗ trợ `createUploadTask` với progress callback.
3. **Task List/Detail (phụ thuộc G5 nếu đã có, dùng API Task tạm nếu chưa):**
   - Task List lọc theo `assigneeId=currentUser`, status chưa FINISHED/CANCELLED.
   - Task Detail thêm 2 nút "Quay video" / "Chọn từ thư viện".
4. **Upload flow:**
   - Màn Upload → gọi `upload-session` lấy `uploadUrl`+`s3Key` → `FileSystem.createUploadTask` PUT với progress bar → confirm.
   - Resilience: retry 3 lần network error, giữ file local tới khi confirm xong, xử lý 403 signature-expired (gọi lại `upload-session` lấy key mới).

## Quyết định kỹ thuật đã chốt

- **1 presigned PUT duy nhất cho toàn file**, không làm S3 Multipart Upload thật (effort quá lớn so với capstone) — retry khi mất mạng là restart từ đầu, không resume byte-level.
- **Upload chỉ chạy foreground** (giới hạn Expo managed đã chốt ở `mobile-app-plan.md`) — dừng khi app bị kill/minimize, resume khi mở lại.
- **Video không đi qua nhánh `uploadMaterial`/`uploadImage` hiện có** (convert WebP, upload qua server) — nhánh đó chỉ hợp lý cho ảnh, không dùng cho video vài trăm MB.
- **Video compression: MVP không làm** — giữ nguyên file gốc từ camera/gallery. Nếu dung lượng gây vấn đề thực tế, giảm resolution record 720p trong `expo-camera` config thay vì compress sau khi quay.

## Việc backend cần xác nhận trước khi mobile code (chưa làm, xem spec mục 8)

- Giới hạn dung lượng file chưa chốt số cụ thể — cần backend validate ở `upload-session` trước khi cấp presigned URL.
- Field `taskId` mới trên `MaterialDocument` — xác nhận không ảnh hưởng Material cũ tạo từ web (field optional/nullable).
- HEAD-object verify trước khi lưu Material ở bước confirm — MVP có thể bỏ qua, đổi lại chấp nhận rủi ro nhỏ record "ma" nếu client confirm sai.

## Rủi ro còn mở

- Nếu mạng rớt ở 90% của file vài trăm MB, phải PUT lại từ đầu — hạn chế đã biết của approach "presigned PUT đơn", không phải bug.
- Nếu client mất kết nối sau khi PUT xong nhưng trước khi confirm: mobile phải giữ `s3Key`+`taskId` ở local storage để cho phép gọi lại confirm trực tiếp khi mở lại app, không PUT lại.

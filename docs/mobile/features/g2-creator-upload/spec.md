# G2 — Creator Upload (Giai đoạn 1 / MVP)

> Tham chiếu: `docs/mobile/mobile-app-plan.md` mục 2 (thiết kế đã chốt, KHÔNG mâu thuẫn với file này).
> Trạng thái: DRAFT — spec thuần, không có code.

## 1. Mục tiêu & phạm vi

Creator quay/chọn video tại hiện trường, upload trực tiếp lên S3 (presigned PUT), gắn vào 1 Task đã được giao, lưu thành 1 bản ghi Material Repository với `type = RAW`.

Chỉ làm **Phase 1 MVP** theo `mobile-app-plan.md` mục 2:
- Task list (được giao sẵn) → Task detail → quay video / chọn từ gallery → upload (progress bar, retry) → gắn vào Task → lưu Material RAW.

**KHÔNG** làm trong G2 (xem mục 7): AI edit raw footage, auto-caption, tự tạo Task mới. Đó là G8 / Phase 2 — placeholder, chưa thiết kế.

## 2. Điểm chạm hệ thống hiện có

Đã đọc trực tiếp các file sau (không đoán):

| File | Hiện trạng | Dùng được ngay? |
|---|---|---|
| `controller/UploadS3Controller.java` | `POST /api/v1/test/upload` — test-only, dùng `UUID.randomUUID()` làm fake user, gọi `fileStorageService.uploadAvatar(...)`. | KHÔNG — phải thay bằng 2 endpoint chính thức mới (mục 3), không tái dùng controller này. |
| `service/FileStorageService.java` | Có `uploadMaterial(workspaceId, bytes, contentType, filename)` (multipart, qua server), `createPresignedDownloadUrl(s3Key)` (presigned **GET**, đã có), `uploadObject`/`downloadObject`/`deleteObject`/`objectUrl` (theo key tuỳ ý). | **Presigned PUT (upload) CHƯA có** — chỉ có presigned GET (download). Phải thêm method mới vào interface + impl. |
| `service/impl/S3FileStorageServiceImpl.java` | Có `S3Presigner` đã autowired, dùng cho `presignGetObject`. Pattern key: `image/<folder>/<ownerId>/<epochMillis>.<ext>` cho ảnh qua `uploadMaterial`; `resolveBucket(key)` tách prefix `qwen-ambassador/` sang bucket AI riêng. | Cần thêm `createPresignedUploadUrl(key, contentType, ttlSeconds)` dùng `s3Presigner.presignPutObject(...)` — pattern tương tự `createPresignedDownloadUrl` đã có, chỉ đổi `PutObjectPresignRequest`. |
| `document/MaterialDocument.java` | Field thật: `id`, `workspaceId` (`workspace_id`), `name`, `originalName` (`original_name`), `type` (enum `MaterialType`), `mimeType` (`mime_type`), `fileSize` (`file_size`), `url`, `s3Key` (`s3_key`), `parentMaterialId`, `watermarkMeta`, `createdBy` (`created_by`), `createdAt`, `updatedAt`. **Không có field liên kết Task** (`taskId`) — đây là field MỚI cần thêm nếu muốn lưu liên kết Material ↔ Task trực tiếp trên document. | Thêm field `taskId` (và tuỳ chọn `source = "MOBILE_CREATOR_UPLOAD"`) vào `MaterialDocument` — NEW. |
| `controller/MaterialController.java` + `service/impl/MaterialServiceImpl.java` | `POST /api/v1/workspaces/{workspaceId}/materials` nhận `MultipartFile`, role `MANAGER`/`CREATOR`, gọi `materialService.uploadMaterial(workspaceId, user, file)` → upload qua `fileStorageService.uploadMaterial` (server trung gian, convert ảnh sang WebP) → lưu `MaterialDocument` với `type = MaterialType.RAW`. Đây là **upload qua server**, không phải presigned-PUT-từ-client. Video không nên đi qua nhánh `uploadImage` (convert WebP) — nhánh đó chỉ hợp lý cho ảnh. | Cần endpoint **confirm** riêng cho mobile (không multipart, không qua server) — xem mục 3.2. |
| `model/Task.java` (JPA, Postgres) | Entity tối giản: `id`, `workspaceId`, `type` (`TaskType`), `title`, `createdBy`, timestamps. **Không có `assigneeId`** — ghi chú ngay trong code: "Minimal Task entity... no assignee". | Task JPA KHÔNG đủ cho "Task được giao cho Creator". Phải dùng `TaskDocument` (Mongo) — có `assigneeId`. |
| `document/TaskDocument.java` (Mongo) | Field thật: `id`, `workspaceId`, `campaignId`, `type` (`TaskType`), `name`, `status` (string, mặc định `"TODO"`), `assigneeId`, `dueDate`, `publishDate`, `cancellation`, v.v. Đây là nguồn sự thật cho workflow Task V2. | Dùng `TaskDocument.id` + `assigneeId` + `status` để xác định "Task giao cho Creator này, chưa FINISHED/CANCELLED". |
| `model/enums/TaskType.java` | `POST, LIVESTREAM, SURVEY, EVENT_PLAN, PRESS_RECOMMENDATION` | Không có type riêng cho "creator upload" — không cần, Material gắn vào Task bất kỳ type nào. |
| `docs/ba/05-content-task-workflow.md` §7 (FR 3.6.11–3.6.17) | 3.6.11–3.6.14: CRUD Material Repository chuẩn. 3.6.15: Apply Watermark (role CREATOR). 3.6.16: Download Material (CREATOR/CLIENT/MANAGER). Không có rule riêng nào về raw/retouched khác với field `type` enum đã thấy trong `MaterialDocument`/`MaterialType`. | Material RAW tạo từ mobile dùng đúng `MaterialType.RAW` đã có, không cần enum mới. |
| `brandhub-mobile-app/package.json` | Có `expo-file-system` (`~56.0.7`). **Không thấy** `expo-camera` hoặc `expo-image-picker`. | Cả hai package này là NEW — cần `expo install expo-camera expo-image-picker`. |

## 3. API mới cần thêm ở business-service

Namespace đề xuất: tái dùng `MaterialController` (`/api/v1/workspaces/{workspaceId}/materials`), thêm 2 endpoint con dưới `/upload-session` để không đụng endpoint multipart hiện có.

### 3.1. `POST /api/v1/workspaces/{workspaceId}/materials/upload-session`
Xin presigned PUT URL.

- Role: `CREATOR` (dùng `@RequireRole({MemberRole.CREATOR})` — KHÔNG mở cho MANAGER/CLIENT, vì đây là thao tác quay/upload hiện trường của Creator).
- Request body:
  - `taskId` (String, bắt buộc) — id của `TaskDocument`.
  - `filename` (String, bắt buộc)
  - `contentType` (String, bắt buộc — whitelist `video/mp4`, `video/quicktime`; từ chối type khác)
  - `fileSize` (Long, bắt buộc — dùng để validate giới hạn, xem mục 8)
- Logic server phải làm trước khi cấp URL:
  1. Load `TaskDocument` theo `taskId`. Không tồn tại → 404.
  2. Check `task.workspaceId == workspaceId` (path) — lệch → 403.
  3. Check `task.assigneeId == user.id` (user hiện tại từ `AuthenticatedUser`) — khác → 403 `TASK_NOT_ASSIGNED`.
  4. Check `task.status` không phải `FINISHED`/`CANCELLED` — nếu là thì 409 `TASK_NOT_ACTIVE`.
  5. Sinh S3 key mới, pattern đề xuất theo convention đã có trong `S3FileStorageServiceImpl`: `video/materials/{workspaceId}/{taskId}/{epochMillis}-{uuid}.{ext}`.
  6. Gọi method MỚI `fileStorageService.createPresignedUploadUrl(key, contentType, ttlSeconds)` (xem mục 2, cần thêm vào `FileStorageService` + impl, dùng `s3Presigner.presignPutObject(...)`, pattern giống `createPresignedDownloadUrl` đã có).
- Response:
  - `uploadUrl` (presigned PUT URL)
  - `s3Key`
  - `expiresAt` (Instant, TTL đề xuất 15 phút — đủ cho file vài trăm MB trên mạng di động trung bình, xem mục 5/6 về hết hạn giữa chừng)

### 3.2. `POST /api/v1/workspaces/{workspaceId}/materials/upload-session/confirm`
Xác nhận đã PUT xong lên S3, tạo Material record.

- Role: `CREATOR` (giống 3.1).
- Request body:
  - `s3Key` (String, bắt buộc — key đã nhận ở 3.1)
  - `taskId` (String, bắt buộc)
  - `filename` / `originalName` (String)
  - `contentType` (String)
  - `fileSize` (Long)
- Logic server:
  1. Re-check quyền (assignee + task status) như 3.1 — không tin tưởng lại response của bước trước, vì có thể có khoảng trễ (task bị huỷ giữa lúc upload).
  2. Idempotency: check đã tồn tại `MaterialDocument` với `s3Key` này chưa (tránh confirm trùng do retry) — nếu có, trả lại record cũ, không tạo mới (xem mục 6, duplicate case).
  3. (Tuỳ chọn, KHÔNG bắt buộc ở MVP) HEAD object trên S3 để verify file thực sự tồn tại tại key đó trước khi lưu DB — tránh record "ma" nếu client confirm sai hoặc PUT thất bại âm thầm. Đánh dấu là rủi ro mở ở mục 8 nếu bỏ qua.
  4. Build `objectUrl(s3Key)` (method đã có trong `FileStorageService`) làm `url`.
  5. Lưu `MaterialDocument`: `workspaceId`, `name = filename`, `originalName`, `type = MaterialType.RAW`, `mimeType = contentType`, `fileSize`, `url`, `s3Key`, `createdBy = user.id`, **`taskId` (field mới cần thêm vào `MaterialDocument`)**.
- Response: `MaterialResponse` đã có sẵn trong `MaterialServiceImpl.toResponse(...)` — cần thêm `taskId` vào `MaterialResponse` DTO song song với field mới trên document.

### Lưu ý thiết kế
- Không tái dùng `/api/v1/test/upload` — xoá hoặc giữ lại chỉ cho mục đích test nội bộ, không public cho mobile.
- `uploadAvatar`/`uploadMaterial` (qua server, multipart) KHÔNG dùng cho video — giữ nguyên cho ảnh, vì nhánh đó convert sang WebP (không áp dụng cho video) và đi qua server (không phù hợp file vài trăm MB).

## 4. Luồng màn hình mobile

1. **Task List (assigned)** — gọi API Task hiện có, lọc theo `assigneeId = currentUser` và `status` chưa `FINISHED`/`CANCELLED`. (Việc list Task là scope G5, G2 chỉ cần đủ để chọn Task đích — có thể dùng tạm 1 API Task đơn giản nếu G5 chưa làm; không thiết kế lại toàn bộ Task list ở đây.)
2. **Task Detail** — thêm 2 nút mới: "Quay video" / "Chọn từ thư viện".
   - Quay video: `expo-camera` (NEW dependency) — mở camera trong app, ghi ra file local (`expo-file-system` cache dir).
   - Chọn từ thư viện: `expo-image-picker` (NEW dependency), `mediaTypes: Videos`.
3. **Màn Upload** (sau khi có file local URI):
   - Hiển thị tên file, dung lượng, nút "Bắt đầu upload".
   - Gọi 3.1 lấy `uploadUrl` + `s3Key`.
   - PUT file lên `uploadUrl` bằng `FileSystem.createUploadTask` (xem mục 5), progress bar theo callback.
   - PUT xong → gọi 3.2 confirm.
   - Thành công → màn "Đã gắn vào Task" (hiển thị tên Material, link quay lại Task Detail, Material giờ xuất hiện trong list Material của Task/Workspace).
4. Giới hạn Expo managed đã chốt trong `mobile-app-plan.md`: upload chỉ chạy khi app đang mở foreground — nếu user thoát app/khóa máy giữa lúc upload, tiến trình dừng, phải resume khi mở lại app (không có background transfer thật ở giai đoạn này).

## 5. Upload resilience

- Dùng `FileSystem.createUploadTask(uploadUrl, fileUri, { httpMethod: 'PUT', headers: { 'Content-Type': contentType } }, progressCallback)` của `expo-file-system` — hỗ trợ progress callback, chạy foreground.
- Đây là PUT đơn (không phải S3 Multipart Upload API thật — multipart upload S3 cần nhiều presigned URL theo part, phức tạp hơn nhiều so với effort capstone cho phép). MVP dùng 1 presigned PUT duy nhất cho toàn file.
- Retry khi mất mạng giữa chừng: **restart từ đầu**, không resume byte-level — vì presigned PUT đơn không hỗ trợ resume (khác hẳn S3 Multipart hoặc TUS protocol). Giữ file local nguyên vẹn (không xoá cache) cho tới khi confirm (3.2) thành công, để có thể bấm "Thử lại" mà không phải quay/chọn lại video.
- Retry strategy cụ thể: tối đa 3 lần tự động retry khi lỗi network (không phải lỗi 4xx), backoff đơn giản (ví dụ 2s/5s/10s); quá 3 lần → báo lỗi, cho nút "Thử lại" thủ công.
- Trade-off ghi nhận rõ: nếu video lớn (vài trăm MB) và mạng rớt ở 90%, phải PUT lại từ đầu — đây là hạn chế đã biết của approach "presigned PUT đơn + Expo managed foreground-only", không phải bug. Nâng cấp thật (resumable) cần S3 Multipart Upload (nhiều presigned URL theo part + ETag ghép) — để dành cho sau nếu pain point này xuất hiện thực tế.

## 6. Error cases

| Case | Xử lý |
|---|---|
| Mất mạng giữa upload | Giữ file local, auto-retry theo mục 5, hết retry thì cho thử lại thủ công; không mất file đã quay/chọn. |
| Presigned URL hết hạn giữa khi upload (TTL 15 phút) | PUT lên S3 trả lỗi 403 (signature expired). Client phát hiện lỗi 403 từ PUT → gọi lại 3.1 lấy URL mới với **cùng s3Key cũ hoặc key mới** (đề xuất: key mới, đơn giản hơn vì không cần lo PUT 1 phần dữ liệu cũ còn sót) → PUT lại từ đầu. |
| Duplicate upload (confirm gọi 2 lần, hoặc user bấm 2 lần) | 3.2 idempotent theo `s3Key` (mục 3.2 bước 2) — trả lại Material đã tạo, không tạo bản ghi trùng. |
| Task không giao cho Creator này | 403 `TASK_NOT_ASSIGNED` ở cả 3.1 và 3.2 (check lại, không tin request trước). |
| Task đã `FINISHED`/`CANCELLED` | 409 `TASK_NOT_ACTIVE` ở cả 3.1 và 3.2. |
| Client mất kết nối sau khi PUT xong nhưng trước khi gọi confirm (3.2) | File đã nằm trên S3 nhưng chưa có Material record. Khi mở lại app, hiển thị trạng thái "đang chờ xác nhận" (lưu `s3Key` tạm ở local state) và cho phép gọi lại 3.2 trực tiếp (không cần PUT lại) — cần client giữ `s3Key` + `taskId` ở local storage cho tới khi confirm xong. |

## 7. Việc KHÔNG làm ở G2

- Không AI auto-edit raw footage (cắt short, chọn đoạn đẹp) — đó là G8/Phase 2, phụ thuộc năng lực AI edit thật chưa tồn tại (`AiVideoService` hiện tại chỉ generate từ prompt, không edit video có sẵn).
- Không auto-caption.
- Không tự động tạo Task mới ở trạng thái `IN_REVIEW` sau khi upload — Material RAW chỉ gắn vào Task đã có, Creator hoặc Manager xử lý tiếp bằng tay theo workflow hiện tại.
- Không làm S3 Multipart Upload (resumable thật theo part) — chỉ presigned PUT đơn (mục 5).
- Không làm background upload khi app bị kill/minimize (đã chốt ở `mobile-app-plan.md` mục 1).

## 8. Rủi ro / câu hỏi mở

1. **Giới hạn dung lượng file**: chưa có policy max file size rõ ràng. Cần chốt (đề xuất: 500MB–1GB cho video raw hiện trường) và validate ở bước 3.1 (so `fileSize` request với giới hạn) trước khi cấp presigned URL — tránh cấp URL cho file quá lớn rồi thất bại giữa chừng.
2. **`createPresignedUploadUrl` là method mới** phải thêm vào interface `FileStorageService` + impl `S3FileStorageServiceImpl` (dùng `S3Presigner.presignPutObject`, pattern giống `createPresignedDownloadUrl` đã có sẵn) — xác nhận lại với backend dev trước khi implement, vì đây là thay đổi interface public.
3. **Video compression trước khi upload**: MVP KHÔNG làm (giữ nguyên file gốc từ camera/gallery) để tránh risk + effort xử lý video client-side trong Expo managed (cần `ffmpeg-kit` hoặc native module, không có sẵn). Nếu dung lượng video quá lớn gây vấn đề thực tế trong demo, xem xét giảm resolution record trong `expo-camera` config (ví dụ 720p) thay vì compress sau khi quay.
4. **Field `taskId` trên `MaterialDocument` là thay đổi schema mới** — cần xác nhận không ảnh hưởng dữ liệu Material cũ (field optional/nullable, materials tạo từ web trước đây không có `taskId`).
5. **HEAD-object verify trước khi lưu Material (3.2 bước 3)**: MVP có thể bỏ qua để đơn giản, đổi lại chấp nhận rủi ro nhỏ Material record "ma" nếu client confirm sai — cần quyết định có đáng làm thêm bước verify này không trong thời gian capstone còn lại.

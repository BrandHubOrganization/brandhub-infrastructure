# Task — G6 AI Features (Mobile)

> [spec.md](./spec.md)

## AI Hub

- [ ] 3 card: Generate Video / Generate Image / Generate Caption + khối Credit balance (`GET /ai/credits`) luôn hiện đầu màn hình.

## Generate Video

- [ ] Style picker (`GET /video-styles`) → prompt textarea (10-1000 ký tự) → ambassador picker (optional, `/ambassadors/presets`) → aspect ratio 16:9/9:16 → Generate.
- [ ] `POST /videos` → 202, hiện ngay "Đã trừ N credit — đang xử lý" (charge-upfront, không chờ job xong).
- [ ] Poll `GET /videos/{jobId}` — `refetchInterval` 4s, dừng khi status không còn `PENDING`/`PROCESSING` (`refetchInterval: (data) => isOpen(status) ? 4000 : false`).
- [ ] Result: `status=COMPLETED` → hiện `videoUrl` (stream signed URL trực tiếp, không proxy qua app); `status=FAILED` → hiện `errorCode` + thông báo credit đã hoàn (`refunded=true`).
- [ ] Invalidate `['ai','credits', workspaceId]` ngay sau `POST /videos` thành công, và lại 1 lần nữa khi job chuyển COMPLETED/FAILED.
- [ ] Không tự làm timeout logic — server sweep job treo mỗi 60s, mobile chỉ poll hoặc hỏi lại khi mở app.
- [ ] Cảnh báo dùng Wifi khi preview/download video lớn (vài chục MB).

## Generate Caption

- [ ] Form: topic textarea (10-1000 ký tự), tone/platform/length/language/goal picker, optional trend/task link.
- [ ] `POST /captions` — đồng bộ, hiện spinner ngắn, trả 3 variant ngay.
- [ ] Hiện mỗi variant kèm `signals` (emotion/trend_used/unverified_claims) + `compliance` check.
- [ ] Nút chọn variant → `POST /captions/{generationId}/choice` (không bắt buộc MVP nhưng nên gọi để history/few-shot đúng).
- [ ] Refine (`POST /captions/refine`) và Adapt platform khác (`POST /captions/adapt`) từ variant đã chọn.
- [ ] Invalidate credit balance sau generate thành công.

## Generate Image

- [ ] Style template picker (FR 3.7.4) → form input + ambassador picker + chọn material liên quan (Material Repository, liên kết G2).
- [ ] `POST /image/commercial/generate` — đồng bộ, **lấy shape request/response thật từ `brandhub-ai-service`/web trước khi code** (JsonNode tự do, không DTO Java).
- [ ] Spinner chờ response (không có job/progress API) — **cảnh báo UX nếu lâu, chưa xác nhận thời gian xử lý thật (mục 8 câu 4)**.
- [ ] **KHÔNG hiện "đã trừ N credit" cho Image** cho tới khi xác nhận với BE credit flow thật (mục 8 câu 3 — `AiGenerationController` không gọi `AiCreditService` ở tầng Java, có thể là gap).

## Result Preview / Save

- [ ] Gắn kết quả vào Task (liên kết G5) hoặc lưu Material Repository (liên kết G2).
- [ ] Export file về máy (FR 3.7.8).

## Credit History

- [ ] Video job history — `GET /videos` (tối đa 12 job gần nhất).
- [ ] Caption history — **chặn bởi mục 8 câu 5, chưa có endpoint `GET` list caption generation, cần backend thêm trước khi làm màn này đầy đủ cho caption**.

## Business rules cần enforce ở client

- [ ] Charge trước khi generate (video) — UI nói rõ "đã trừ credit" ngay bước Generating, không chờ kết quả.
- [ ] Bắt lỗi `INSUFFICIENT_AI_CREDIT` (402) riêng — thông báo "không đủ credit" + link Subscription/Billing (G7), không lỗi chung.
- [ ] Phân biệt lỗi `INVALID_REQUEST` (style/ambassador sai, không trừ credit) vs `AI_SERVICE_UNAVAILABLE` (lỗi hạ tầng, cũng không trừ credit) — khác với job fail sau khi đã charge (có refund) — copy UI khác nhau cho 2 trường hợp.
- [ ] Không giả lập % tiến trình không có thật — chỉ phản ánh đúng PENDING/PROCESSING/COMPLETED/FAILED.

## Chưa làm / out of scope G6 (xem spec mục 7)

- [ ] Không làm: edit video/raw footage có sẵn (G8), quản lý Admin-level AI style/template, Trending Topics dashboard đầy đủ, Livestream Script, Recommend Collaborator.

## Rủi ro cần chốt trước khi code (xem spec mục 8)

1. Push notification khi job video xong — server chưa có cơ chế push (FCM/APNs/Expo), cần task riêng ở backend trước khi mobile tận dụng; nếu không có, chỉ polling khi app foreground.
2. Download/preview video lớn trên mobile data — cảnh báo Wifi, dùng signed URL stream trực tiếp.
3. Credit flow Image generation chưa rõ — xác nhận với BE ai-service Python có tự trừ credit hay là gap thật.
4. Image generation không có job/status polling — nếu xử lý lâu, cần bàn đổi sang pattern async/job trước khi mobile cam kết UX đồng bộ.
5. Danh sách lịch sử Caption generation — cần thêm endpoint `GET /captions` list ở backend (tương tự `GET /videos`) nếu muốn History đầy đủ cả 2 loại.

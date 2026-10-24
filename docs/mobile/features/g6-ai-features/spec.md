# G6 — AI Features (mobile)

> Trạng thái: DRAFT — spec, không có code.
> Tham chiếu: [mobile-app-plan.md](../mobile-app-plan.md) §3 dòng G6, [docs/ba/06-ai-features.md](../../ba/06-ai-features.md), [docs/ba/use-cases/05-ai-features.md](../../ba/use-cases/05-ai-features.md).

## 1. Mục tiêu & phạm vi

Đưa 3 luồng AI generate chính của web (Caption, Image, Video) + credit balance/history lên mobile, theo đúng pattern **generate-only, async job, charge-upfront/refund-on-fail** đã có sẵn ở `AiVideoService`/`AiCaptionService`/`AiCreditService` (brandhub-business-service). Không build lại business logic — mobile chỉ là client mới gọi các endpoint đã có.

Trong phạm vi G6:
- Generate Video (Veo, prompt-based) — `AiVideoService`.
- Generate Caption (3 variant/lần, refine, adapt sang platform khác) — `AiCaptionService`.
- Generate Image (commercial image, ambassador làm input) — qua `AiGenerationController` pass-through, KHÔNG có service Java riêng kiểu `AiImageService`.
- Xem AI credit balance (agency-level + creator limit nếu có) — `AiCreditService`.
- Xem lịch sử job (video: `recent()`; caption: lịch sử generation theo `ai_caption_generations`, chưa có endpoint list riêng — xem mục 8).

Ngoài phạm vi: xem [07-publishing-social-collaborator.md](../../ba/07-publishing-social-collaborator.md) và mục 7 dưới.

## 2. FR tham chiếu

| FR | Tên | Dùng ở G6? |
|---|---|---|
| 3.7.2 | Generate Caption | Có |
| 3.7.3 | Generate Ambassador | Input phụ cho Image/Video, không phải màn hình riêng ở G6 MVP (xem mục 8) |
| 3.7.4 | View Image Style Template | Có (style picker) |
| 3.7.5 | Generate Image | Có |
| 3.7.6 | View Video Style Template | Có (`videos.styles()`) |
| 3.7.7 | Generate Video | Có |
| 3.7.8 | Export File | Có (save/share từ Result Preview) |
| 3.7.1, 3.7.10 | Trending topics/hashtag | Ngoài phạm vi G6 (có `trendFit()` dùng được cho caption context nhưng không làm màn hình riêng) |
| 3.7.9 | Crawl Schedule Config | Ngoài phạm vi — ADMIN, không áp dụng mobile Creator/Manager |
| 3.7.11, 3.7.12 | Livestream Script, Recommend Collaborator | Ngoài phạm vi G6 |

## 3. API cần dùng

### 3.1 Video (workspace-scoped, charge credit qua `AiCreditService`)
Base: `/api/v1/workspaces/{workspaceId}/ai` (`AiVideoController`)

- `GET /video-styles` → trả JSON style template list (proxy `ai.get("/api/v1/ai/video/styles")`).
- `POST /videos` → 202 Accepted. Body = `AiVideoService.Request { prompt (10-1000 ký tự), styleKey?, ambassadorId?, aspectRatio: "16:9"|"9:16" }`. Response = `Started { job, creditsUsed, creditsRemaining }`, `job.status` ban đầu `PENDING`.
- `GET /videos/{jobId}` → `Job { jobId, status, prompt, styleKey, ambassadorId, aspectRatio, videoUrl, s3Key, errorCode, refunded, createdAt, finishedAt }`. Nếu job đang `PENDING`/`PROCESSING`, server tự refresh từ AI service trước khi trả — mobile chỉ cần poll endpoint này, không cần gọi AI service trực tiếp.
- `GET /videos` → tối đa 12 job gần nhất của workspace (`recent()`), dùng cho Job History.

### 3.2 Caption (workspace-scoped, charge credit)
Base: `/api/v1/workspaces/{workspaceId}/ai` (`AiCaptionController`)

- `POST /captions` → đồng bộ (không async/job), trả ngay `Result { generationId, captions[3 variant], context, creditsUsed, creditsRemaining }`. Body = `Request { topic (10-1000), tone?, platform?, length?, language?, goal?, trend?, taskId?, trendId?, techniques? }`.
- `POST /captions/refine` → `DraftResult` (1 draft), body `RefineRequest { caption, instruction, feedback?, platform?, language?, topic? }`.
- `POST /captions/adapt` → `DraftResult` (nhiều draft, 1/platform), body `AdaptRequest { caption, platforms[], language?, topic? }`.
- `POST /captions/{generationId}/choice` → ghi lại variant Creator chọn, body `Choice { type, action: INSERT|REPLACE, finalText? }`. Không bắt buộc cho MVP nhưng nên gọi để dữ liệu history/few-shot đúng.
- `GET /trend-fit` → không charge credit, dùng optionally làm gợi ý trend khi soạn caption.

### 3.3 Image (KHÔNG qua AiCreditService ở tầng Java — khác pattern video/caption)
Base: `/api/v1/ai` (`AiGenerationController`, pass-through tới `brandhub-ai-service`, thêm `client_id`/`workspace_id` vào body)

- `POST /ambassadors/presets` (GET) và `POST /ambassadors/generate`, `POST /ambassadors/character-sheet` — tạo/làm mới Ambassador, dùng làm input cho Image/Video khi brand chưa có model thật (FR 3.7.3).
- `POST /image/commercial/generate` → proxy tới ai-service `/api/v2/ai/image/commercial/generate`. Request/response là `JsonNode` tự do (không có DTO Java riêng) — mobile cần lấy shape thật từ `brandhub-ai-service` (module `app/services/image/` — `prompt_synthesizer.py`, `style_presets.py`) hoặc từ web frontend trước khi code thật.
- **Điểm cần lưu ý quan trọng:** endpoint `/api/v1/ai/image/commercial/generate` KHÔNG đi qua `AiCreditService.ensureAvailable/charge` ở phía `AiGenerationController` — khác hẳn pattern video/caption. Nghĩa là hiện tại generate Image không tự động trừ credit ở tầng business-service (có thể trừ credit được xử lý bên `brandhub-ai-service` Python, hoặc đây là một gap/TODO của hệ thống). **Cần xác nhận với team BE trước khi mobile hiển thị "credit sẽ bị trừ" cho luồng Image** — xem mục 8 (câu hỏi mở).
- Image generation ở `AiGenerationController` là **đồng bộ** (không có job/status polling riêng kiểu video) theo code hiện tại — không có `GET /image/{jobId}/status`. Nếu ai-service xử lý lâu, mobile sẽ phải chịu timeout HTTP đồng bộ thay vì poll — cần xác nhận thời gian xử lý thật của ai-service trước khi chốt UX (progress bar giả định vs spinner chờ).

### 3.4 Credit balance
- `GET /api/v1/workspaces/{workspaceId}/ai/credits` (đặt trong `AiCaptionController` nhưng dùng chung cho mọi feature AI) → `AiCreditService.Balance { agencyId, allowance, used, creatorLimit, creatorUsed, remaining }`. `remaining` = agency remainder, capped bởi creator limit nếu Owner có đặt. Gọi lại ngay sau mỗi generate video/caption để cập nhật UI (xem mục 5).

### 3.5 Polling pattern (video — async)
- Sau `POST /videos`, mobile poll `GET /videos/{jobId}` theo `refetchInterval` (gợi ý 3-5s) **chỉ khi** `status` còn `PENDING`/`PROCESSING`; dừng polling khi `COMPLETED`/`FAILED`.
- Server có sweep job riêng (`AiVideoService.sweep()`, chạy mỗi 60s mặc định qua `@Scheduled`) tự fail + refund job quá `timeoutSeconds` (mặc định 600s) dù không ai poll — mobile không cần tự làm timeout logic, chỉ cần tiếp tục poll hoặc tắt app rồi mở lại gọi `GET /videos/{jobId}` để lấy trạng thái mới nhất.
- Push-notification-khi-job-xong: hiện **chưa có** cơ chế server push (không thấy FCM/APNs trigger trong `AiVideoService`). Đây là câu hỏi mở — xem mục 8.

## 4. Luồng màn hình

1. **AI Hub** — 3 card: Generate Video / Generate Image / Generate Caption, + khối hiển thị Credit balance (remaining/allowance) luôn hiện ở đầu màn hình.
2. **Prompt/Form screen** (theo loại):
   - Video: style picker (từ `GET /video-styles`) → prompt textarea (10-1000 ký tự) → chọn ambassador (optional, danh sách từ `/ambassadors/presets` nếu brand không có model thật) → aspect ratio 16:9/9:16 → nút Generate.
   - Caption: topic textarea, tone/platform/length/language/goal picker, optional trend/task link.
   - Image: style template picker (3.7.4) → form input + chọn ambassador + chọn material liên quan (từ Material Repository, liên kết G2) → nút Generate.
3. **Generating state**:
   - Video: hiện "Đã trừ N credit — đang xử lý" ngay sau response 202 (credit đã charge ngay khi job được tạo, KHÔNG chờ xong mới trừ) + progress indicator (không có % thật, chỉ trạng thái PENDING→PROCESSING) trong lúc poll `GET /videos/{jobId}`.
   - Caption: đồng bộ, hiện spinner ngắn (gọi 1 lần, có kết quả ngay, không polling).
   - Image: đồng bộ (theo code hiện tại), hiện spinner chờ response — cảnh báo nếu lâu vì không có job/progress API.
4. **Result Preview**:
   - Video: hiển thị `videoUrl` khi `status=COMPLETED`; nếu `status=FAILED` hiện lý do (`errorCode`) + thông báo credit đã hoàn (`refunded=true`).
   - Caption: hiện 3 variant, mỗi variant kèm `signals` (emotion/trend_used/unverified_claims), `compliance` check — cho phép chọn 1 variant (gọi `/choice`) hoặc Refine/Adapt tiếp.
   - Image: hiện ảnh generate xong.
5. **Save/attach** — gắn kết quả vào Task (liên kết G5) hoặc lưu vào Material Repository (liên kết G2), hoặc Export file về máy (FR 3.7.8).
6. **Credit History** — danh sách job (video: `GET /videos`; caption: chưa có endpoint list sẵn, xem mục 8) + hiển thị trạng thái refunded.

## 5. State & cache (TanStack Query)

- `useQuery(['ai','credits', workspaceId])` — gọi `GET /credits`; `invalidateQueries(['ai','credits', workspaceId])` ngay sau mọi `POST /videos` và `POST /captions` thành công (kể cả khi job video còn PENDING — credit đã bị trừ ngay lúc tạo job, không chờ job xong).
- `useQuery(['ai','video-job', jobId], { refetchInterval: (data) => isOpen(data.status) ? 4000 : false })` — pattern chuẩn TanStack Query polling: dừng tự động khi status không còn PENDING/PROCESSING (tức `refetchInterval` trả `false`).
- Khi job video chuyển `COMPLETED`/`FAILED`, invalidate lại `['ai','credits', workspaceId]` một lần nữa để phản ánh refund nếu có (trường hợp FAILED).
- Caption/Image là mutation đơn (`useMutation`), không cần polling; sau khi thành công thì invalidate credit balance.
- Danh sách job video (`['ai','videos', workspaceId]`) có thể để `staleTime` ngắn, refetch khi quay lại AI Hub/History screen.

## 6. Business rules đặc biệt

- **Charge trước khi generate, không phải sau khi xong**: với video, `credits.charge()` chạy ngay sau khi AI service nhận job thành công (có `jobId`), trước khi job thực sự chạy xong — UI phải nói rõ "đã trừ N credit, đang xử lý" ngay từ bước Generating, không để user hiểu lầm là chỉ trừ khi có kết quả.
- **Refund đúng 1 lần, idempotent**: `AiVideoService.fail()` dùng status guard (`where status in ('PENDING','PROCESSING')`) nên chỉ refund 1 lần dù gọi nhiều lần — mobile không cần tự chặn double-refund, nhưng không nên tự ý gọi lại generate khi job đang FAILED mà chưa kiểm tra `refunded` flag để tránh user hiểu lầm đã mất credit.
- **Sweep job server-side mỗi 60s** (`@Scheduled(fixedDelayString = "${ai.video.sweep-delay-ms:60000}")`) tự fail + refund job treo quá `timeoutSeconds` (mặc định 600s, cấu hình `ai.video.timeout-seconds`) — mobile không cần timeout logic riêng, cứ tiếp tục poll hoặc hỏi lại `GET /videos/{jobId}` sau khi mở lại app.
- **Insufficient credit** → lỗi `INSUFFICIENT_AI_CREDIT` (HTTP 402 theo `BusinessException`/`ErrorCode`) ném ra TRƯỚC khi gọi AI service (`ensureAvailable`) — mobile cần bắt lỗi này riêng, hiện thông báo rõ "không đủ credit" + link tới màn hình Subscription/Billing (G7) thay vì lỗi chung.
- **Creator limit**: nếu Owner đặt `ai_credit_creator_limits` cho user, `remaining()` bị cap theo limit riêng của Creator đó dù agency còn credit — hiển thị rõ 2 số nếu cần debug (agency remaining vs creator remaining) nhưng UI chính chỉ cần hiện số `remaining` cuối cùng.
- **Lỗi AI service 4xx (style/ambassador không hợp lệ) vs lỗi hạ tầng**: `AiVideoService.generate()` phân biệt 400/422 → `INVALID_REQUEST` (style/ambassador sai) và các lỗi khác → `AI_SERVICE_UNAVAILABLE`; cả 2 trường hợp đều KHÔNG trừ credit (fail trước khi `credits.charge()` chạy) — khác hẳn trường hợp job fail sau khi đã charge (có refund). Mobile nên phân biệt 2 loại lỗi này trong UI copy.
- **Image generation không có AiCreditService guard ở Java** (xem mục 3.3) — business rule thật của luồng Image khác cơ bản so với Video/Caption, cần xác nhận lại trước khi code.

## 7. Việc KHÔNG làm ở G6

- Không làm "edit video/raw footage có sẵn" — đó là Creator Upload Giai đoạn 2 (G8, out of scope, chưa thiết kế, phụ thuộc năng lực AI edit thật chưa tồn tại trong `brandhub-ai-service`) theo đúng mục 2 và bảng giai đoạn trong [mobile-app-plan.md](../mobile-app-plan.md).
- Không làm màn hình quản lý Admin-level AI style/template (thêm/sửa/xoá style video/image) — đó thuộc FR 3.7.9 (Crawl Schedule) và các màn hình Admin khác, không nằm trong 3.7.4/3.7.6 (chỉ View template).
- Không làm Trending Topics dashboard đầy đủ (3.7.1/3.7.10), Livestream Script (3.7.11), Recommend Collaborator (3.7.12) — các FR AI khác không liên quan trực tiếp tới generate caption/image/video + credit.
- Không tự implement progress % thật cho video/image generation — chỉ phản ánh đúng trạng thái PENDING/PROCESSING/COMPLETED/FAILED mà server trả, không giả lập % tiến trình không có thật.

## 8. Rủi ro/câu hỏi mở

1. **Push notification khi job video xong**: hiện server không có cơ chế push (FCM/APNs/Expo push token) gắn vào `AiVideoService` — cần thêm nếu muốn user không phải giữ app mở để chờ polling. Việc này đòi hỏi: (a) business-service lưu Expo push token theo user, (b) gọi Expo Push API khi job chuyển COMPLETED/FAILED trong `refresh()`/sweep. Chưa có trong code hiện tại — cần task riêng ở business-service trước khi mobile tận dụng được, nếu không mobile chỉ polling khi app foreground (khớp với quyết định "không background task" đã chốt ở `mobile-app-plan.md` §1).
2. **Download/preview video lớn trên mobile data**: video Veo có thể vài chục MB, cảnh báo người dùng dùng Wifi khi preview/download, và nên dùng signed URL stream trực tiếp (không proxy qua app) để tránh tốn băng thông app.
3. **Credit flow của Image generation chưa rõ** (mục 3.3, 6) — cần xác nhận với BE: ai-service Python có tự trừ credit riêng không, hay đây là gap thật cần vá trước khi mobile/web dựa vào. Nếu là gap, mobile không nên tự hiện "đã trừ N credit" cho Image vì sẽ sai so với thực tế backend.
4. **Image generation không có job/status polling** — nếu thời gian xử lý thật dài (gần bằng video), cần bàn với BE việc đổi `/image/commercial/generate` sang pattern async/job giống video trước khi mobile cam kết UX đồng bộ (gọi 1 lần, chờ response).
5. **Danh sách lịch sử Caption generation**: `AiCaptionService` lưu `ai_caption_generations` nhưng chưa thấy endpoint `GET` list theo workspace (chỉ có `/trend-fit`, generate/refine/adapt/choice) — cần thêm endpoint `GET /captions` (tương tự `GET /videos`) ở business-service nếu muốn màn hình Credit/Job History hiển thị đầy đủ cả 2 loại.

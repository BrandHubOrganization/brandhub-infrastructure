# Plan — G6 AI Features (Mobile)

> [spec.md](./spec.md) — chi tiết API/flows/business rules đầy đủ. File này là bản tóm tắt thứ tự implement + quyết định kỹ thuật chốt.

## Thứ tự implement (theo dependency)

1. **AI Hub** — màn gốc, đơn giản, không phụ thuộc gì (3 card + credit balance).
2. **Generate Caption trước** (đồng bộ, không cần polling, pattern đơn giản nhất) — làm mẫu cho 2 luồng còn lại.
3. **Generate Video** (async, có polling + charge-upfront) — phức tạp hơn Caption do job lifecycle.
4. **Generate Image** — **chặn bởi chưa rõ credit flow thật và shape request/response**, làm cuối cùng sau khi xác nhận với backend.
5. **Credit History** — video history làm được ngay (`GET /videos` có sẵn); caption history **chặn bởi thiếu endpoint**, để backend thêm trước.

## Quyết định kỹ thuật đã chốt

- **Charge trước khi generate (video), không phải sau khi xong** — `credits.charge()` chạy ngay khi AI service nhận job (có `jobId`), trước khi job chạy xong. UI phải nói rõ "đã trừ N credit, đang xử lý" ngay từ Generating state.
- **Polling pattern chuẩn**: `refetchInterval` dừng tự động khi status không còn PENDING/PROCESSING — không cần tự viết timeout logic, server có sweep job riêng (mỗi 60s, timeout mặc định 600s) tự fail+refund job treo.
- **Refund idempotent ở server** — mobile không cần tự chặn double-refund, nhưng không nên tự ý gọi lại generate khi job FAILED mà chưa kiểm tra `refunded` flag.
- **Phân biệt rõ 3 loại lỗi trong UI copy**: `INVALID_REQUEST`/`AI_SERVICE_UNAVAILABLE` (không trừ credit, fail trước khi charge) vs job fail sau khi đã charge (có refund) vs `INSUFFICIENT_AI_CREDIT` (402, riêng biệt, link sang G7).
- **Image generation: KHÔNG hiện "đã trừ credit"** cho tới khi backend xác nhận credit flow thật — `AiGenerationController` hiện không gọi `AiCreditService` ở tầng Java, có thể là gap hệ thống chưa vá, không phải hành vi đã xác nhận.
- **Không giả lập % tiến trình không có thật** — chỉ phản ánh đúng PENDING/PROCESSING/COMPLETED/FAILED từ server.

## Việc cần xác nhận trước khi code (chưa làm, xem spec mục 8)

- Push notification khi job video xong — server chưa có cơ chế push (FCM/APNs/Expo), cần task riêng ở backend trước khi mobile tận dụng; nếu không có, chỉ polling khi app foreground.
- Credit flow Image generation — xác nhận với BE ai-service Python có tự trừ credit hay là gap thật trước khi hiển thị bất kỳ thông tin credit nào cho luồng Image.
- Image generation không có job/status polling — nếu thời gian xử lý thật dài (gần bằng video), cần bàn đổi sang pattern async/job trước khi mobile cam kết UX đồng bộ (gọi 1 lần, chờ response).
- Endpoint `GET /captions` list (lịch sử caption generation) chưa tồn tại — cần backend thêm tương tự `GET /videos` nếu muốn Credit History đầy đủ cả 2 loại.

## Rủi ro còn mở

- Video Veo có thể vài chục MB — cảnh báo dùng Wifi khi preview/download, dùng signed URL stream trực tiếp (không proxy qua app) để tránh tốn băng thông app.
- Shape request/response thật của `POST /image/commercial/generate` chưa có DTO Java (JsonNode tự do) — phải lấy từ `brandhub-ai-service` Python hoặc web frontend trước khi code Generate Image.

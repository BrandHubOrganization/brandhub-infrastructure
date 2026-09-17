# ADR-003 — RabbitMQ cho Async Publishing

**Status:** Accepted

## Context

Khi Task (Post-type) hoàn tất Approval Sequence và tới lịch đăng, business-service cần đẩy nội dung lên Social Platform (Facebook/Instagram/TikTok/Threads) qua `publisher-service`. Cần chọn giữa gọi REST đồng bộ trực tiếp hay message queue bất đồng bộ.

## Decision

Dùng **RabbitMQ** (exchange `brandhub.publishing`, type `direct`) làm kênh giao tiếp business-service → publisher-service, publisher-service gửi callback HTTP ngược lại sau khi xử lý xong (xem `docs/architecture/rabbitmq-publisher-contract.html`).

## Consequences

**Tích cực:**
- Social API latency không ổn định (2–30s, có lúc timeout) — async queue tách rời request-issuing khỏi actual execution, business-service không bị block.
- Retry isolation: lỗi publish 1 platform (vd: Facebook rate limit) không ảnh hưởng job khác đang chờ — mỗi message retry độc lập với backoff 30s→60s→120s→DLQ.
- publisher-service scale độc lập theo tải publish (nhiều campaign lớn cùng lúc) mà không cần scale business-service.
- Exchange `direct` đảm bảo đúng 1 consumer instance xử lý 1 job — tránh double-publish.

**Tiêu cực:**
- Thêm hạ tầng vận hành (RabbitMQ cluster, DLQ monitoring) so với REST đồng bộ đơn giản.
- Eventual consistency — status Task/Post không cập nhật ngay lập tức, phải chờ callback (UX cần hiển thị trạng thái `PENDING`/`IN_PROGRESS` thay vì chờ đồng bộ).
- Cần xử lý duplicate message (idempotency) nếu RabbitMQ redeliver do consumer crash giữa chừng — publisher-service dùng Redis dedup lock (xem `docs/architecture/` ghi chú `DA-E52-15`).

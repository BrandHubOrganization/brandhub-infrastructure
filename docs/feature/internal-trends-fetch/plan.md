# Plan — internal-trends-fetch

## Giải pháp tổng quan

Endpoint đọc-nhanh (read-through cache): GET Redis → hit thì trả ngay, miss thì
fetch external source → ghi Redis (TTL) → trả. Tái dùng toàn bộ pattern sẵn có,
**không thêm dependency, không thêm config mới.**

## Luồng dữ liệu

```
GET /internal/ai/trends/fetch (X-Internal-Key)
   │ verify_internal_key (401 nếu sai)
   │ validate platform/region (422 nếu sai)
   ▼
GET redis  trends:{platform}:{region}
   ├─ hit ──────────────► trả JSON (không gọi external)
   └─ miss
        │ fetch external (CrawlerRegistry: google_trends | tiktok)
        ├─ success ─────► SET redis (ex=ttl) ──► trả envelope
        └─ fail
             │ re-check redis (có thể concurrent refresh vừa ghi)
             ├─ còn cache ► trả cache cũ (không 503)
             └─ hết      ► 503
```

## File chạm tới

| File | Thay đổi |
|---|---|
| `brandhub-ai-service/app/api/v1/endpoints/internal_trends.py` | **Tạo mới** — router + logic endpoint |
| `brandhub-ai-service/app/main.py` | Thêm 1 dòng `app.include_router(internal_trends.router, prefix="/internal/ai/trends", ...)` |
| `brandhub-ai-service/tests/unit/api/test_internal_trends_fetch.py` | **Tạo mới** — pytest |
| `brandhub-infrastructure/docs/feature/internal-trends-fetch/*` | 4 doc |

**Không sửa**: `config.py`, `clients.py`, `security.py`, `router.py` — tái dùng nguyên trạng.

## Quyết định kỹ thuật

1. **Auth**: `verify_internal_key` (`X-Internal-Key` vs `settings.internal_service_key`) —
   dùng `dependencies=[Depends(verify_internal_key)]` như các endpoint `/crawl`, `/normalize` hiện có.

2. **Redis client**: `get_redis_client()` (decode_responses=True) — phù hợp lưu/đọc JSON string.
   Không dùng `get_trend_redis_client()` (bytes mode, dành cho scheduler).

3. **Redis key + TTL**: key `trends:{platform}:{region}` (đúng spec). Giá trị = JSON envelope
   `{trends, cachedAt, ttlSeconds}`. TTL = `settings.live_cache_ttl_seconds` (đã có sẵn,
   = `crawl_interval_hours * 3600`, mặc định 21600s = 6h, nằm trong khoảng 1–6h của spec).

4. **External source mapping**: Google Trends là tín hiệu mặc định (platform-agnostic);
   TIKTOK dùng trending feed riêng:
   ```python
   _SOURCE_BY_PLATFORM = {"TIKTOK": "tiktok"}   # còn lại -> "google_trends"
   ```
   Gọi qua `CrawlerRegistry.get_crawler(source).crawl(target=region, limit=20)`.
   Mock hiện tại trả `RawPostItem` → map thành `{topic, score, relatedHashtags}`:
   - `topic`: keyword Google Trends (strip prefix) / hashtag đầu / raw_text 60 ký tự.
   - `score`: `search_volume` → `views` → `likes` → 0.
   - `relatedHashtags`: `item.hashtags` bỏ `#`.

5. **Fallback stale-not-503**: khi external fail, re-check Redis 1 lần trước khi 503 —
   phủ trường hợp concurrent refresh vừa ghi + giữ cache cũ không bị xoá.

6. **Background job (bỏ, có lý do)**: spec nói "background job refreshes every 1–6 hours".
   Không implement standalone warm job vì:
   - Không có danh sách (platform, region) nào để warm (spec không liệt kê).
   - On-demand refresh + TTL cho consumer đúng hành vi (luôn có fresh-or-cached data).
   - `ponytail:` thêm APScheduler warm job khi có danh sách region cần làm nóng + cache-miss
     latency đo được là vấn đề thật.

## Rủi ro

- Mock crawler không phân biệt region (trả cùng keyword) → v1 chấp nhận, thay bằng API thật sau.
- Fetch external trùng khi concurrent miss → chấp nhận v1 (xem Edge Cases).

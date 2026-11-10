# Spec — internal-trends-fetch

> Task gốc: **DA-1182 / DA-E23-05** — "Expose /internal/ai/trends/fetch endpoint".

## Objective

Cung cấp endpoint nội bộ `GET /internal/ai/trends/fetch` cho BrandHub backend
lấy danh sách trend theo `platform` + `region`, phục vụ từ Redis cache với
fallback external source (Google Trends / TikTok Trending). **Không tốn AI credit.**

## User Story

Là BrandHub backend, tôi gọi `GET /internal/ai/trends/fetch?platform=TIKTOK&region=VN`
để hiển thị "xu hướng đang hot" cho user. Endpoint phải trả nhanh (cache hit ~ms),
không phụ thuộc credit AI, và không 503 khi external source sập mà vẫn còn cache.

## Acceptance Criteria

- [ ] `GET /internal/ai/trends/fetch` trả `{trends: [{topic, score, relatedHashtags}], cachedAt, ttlSeconds}`.
- [ ] Thiếu hoặc sai `X-Internal-Key` → **401**.
- [ ] `platform` ∉ {FACEBOOK, INSTAGRAM, TIKTOK, THREADS, ZALO} → **422**.
- [ ] `region` không phải ISO 3166-1 alpha-2 (2 chữ in hoa) → **422**.
- [ ] Cache hit → trả từ Redis key `trends:{platform}:{region}` (không gọi external).
- [ ] Cache miss → fetch external source → SET Redis (TTL = refresh interval) → trả.
- [ ] External source down + còn cache → trả cache cũ (**không** 503).
- [ ] External source down + không có cache → **503**.
- [ ] Không gọi bất kỳ LLM nào (không tốn AI credit).

## API Contract

```
GET /internal/ai/trends/fetch?platform={platform}&region={region}
Header: X-Internal-Key: <internal_service_key>
```

**Query params:**

| Param | Type | Rule |
|---|---|---|
| `platform` | string | enum: FACEBOOK, INSTAGRAM, TIKTOK, THREADS, ZALO (case-insensitive input, chuẩn hoá uppercase) |
| `region` | string | ISO 3166-1 alpha-2, 2 chữ in hoa (vd: VN, US, SG) |

**Response 200:**

```json
{
  "trends": [
    {"topic": "trà sữa đất nung", "score": 50000.0, "relatedHashtags": ["TràSữaĐấtNung"]}
  ],
  "cachedAt": "2026-10-02T06:00:00+00:00",
  "ttlSeconds": 21600
}
```

- `score`: số dương (search_volume / views của nguồn external).
- `cachedAt`: ISO-8601 UTC, thời điểm cache được ghi.
- `ttlSeconds`: refresh interval hiện tại (mặc định `crawl_interval_hours * 3600` = 21600).

## Error Handling

| Tình huống | HTTP | Detail |
|---|---|---|
| Thiếu/sai `X-Internal-Key` | 401 | "Invalid internal service key" |
| `platform` không hợp lệ | 422 | liệt kê enum hợp lệ |
| `region` không đúng định dạng | 422 | yêu cầu ISO 3166-1 alpha-2 |
| External down, không cache | 503 | "External trends source unavailable and no cached data" |

## Edge Cases

- `platform` nhập thường (`tiktok`) → vẫn chấp nhận, chuẩn hoá uppercase.
- `region` nhập thường (`vn`) → chuẩn hoá uppercase.
- Nhiều request đồng thời cùng key khi cache miss → có thể fetch external trùng (chấp nhận v1,
  `ponytail:` thêm lock nếu throughput đòi hỏi).
- External source trả 0 item → cache lưu `trends: []` (không coi là lỗi).

## Definition of Done

- [ ] Endpoint mount tại `/internal/ai/trends`, auth `verify_internal_key`.
- [ ] Redis key đúng `trends:{platform}:{region}`, TTL = refresh interval.
- [ ] Fallback stale-not-503 hoạt động.
- [ ] 4 doc feature (spec/plan/task/test) hoàn chỉnh.
- [ ] pytest pass cho endpoint (validation + cache + fallback).
- [ ] Commit format `feat(DA-1182): ...`.

## Out of Scope

- **Không** triển khai Google Trends API / TikTok API thật — dùng mock crawler hiện có
  (`app/services/crawlers/google_trends.py`, `tiktok_scraper.py`).
- **Không** thêm standalone background warm job — on-demand refresh + TTL đủ đáp ứng
  correctness (xem plan.md quyết định).
- **Không** thêm i18n / light-dark (endpoint backend, không có UI).

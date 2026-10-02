# Test — internal-trends-fetch

## 1. Unit test (pytest — tự động)

File: `brandhub-ai-service/tests/unit/api/test_internal_trends_fetch.py`

| # | Input | Mong đợi |
|---|---|---|
| 1 | Không header `X-Internal-Key` | 401 |
| 2 | `X-Internal-Key` sai | 401 |
| 3 | `platform=YOUTUBE` (sai enum) | 422 |
| 4 | `region=VIETNAM` (sai alpha-2) | 422 |
| 5 | `platform=tiktok&region=vn` (thường) | 200, chuẩn hoá key `trends:TIKTOK:VN` |
| 6 | Cache hit (Redis có sẵn JSON) | 200, trả đúng envelope, **không** gọi crawler |
| 7 | Cache miss + external OK | 200, gọi crawler, SET Redis đúng key+TTL, `trends` map đúng |
| 8 | Cache miss + external fail + không cache | 503 |
| 9 | Cache miss + external fail + re-check có cache | 200, trả cache cũ |

## 2. Smoke (manual, khi có Redis thật)

```bash
curl -X GET "http://localhost:8082/internal/ai/trends/fetch?platform=TIKTOK&region=VN" \
     -H "X-Internal-Key: $INTERNAL_SERVICE_KEY"
```

| # | Check | Mong đợi |
|---|---|---|
| 10 | Lần 1 (cache miss) | 200, `trends` không rỗng, `cachedAt`/`ttlSeconds` hợp lệ |
| 11 | Lần 2 (cache hit) | 200, trả nhanh, `cachedAt` không đổi |
| 12 | `redis-cli GET trends:TIKTOK:VN` | có JSON envelope |

## 3. Regression

| # | Check | Mong đợi |
|---|---|---|
| 13 | Các endpoint `/api/v1/ai/trends/*` | không bị ảnh hưởng (router riêng, prefix riêng) |
| 14 | `/health` | vẫn UP |

## Ghi chú

- Mock crawler trả cùng keyword cho mọi region → không verify sự khác biệt region ở v1.
- Nếu chưa có Redis chạy, unit test phải mock `get_redis_client` (không cần Redis thật).

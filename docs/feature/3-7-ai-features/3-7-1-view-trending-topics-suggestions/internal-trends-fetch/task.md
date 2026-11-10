# Task — internal-trends-fetch

- [ ] Đối chiếu spec DA-E23-05 trong master-plan (khớp: auth, Redis key, platform enum, fallback).
- [ ] Viết spec.md / plan.md (trước khi code, theo feature-workflow).
- [ ] Tạo `app/api/v1/endpoints/internal_trends.py`:
  - [ ] `PLATFORMS` enum + regex region ISO alpha-2.
  - [ ] `_redis_key`, `_to_trend` (map RawPostItem → topic/score/relatedHashtags).
  - [ ] `_fetch_external` qua `CrawlerRegistry` (tiktok | google_trends).
  - [ ] endpoint `GET /fetch` với `verify_internal_key`, read-through cache, fallback stale-not-503.
- [ ] Mount router ở `app/main.py` prefix `/internal/ai/trends`.
- [ ] Viết `tests/unit/api/test_internal_trends_fetch.py` (validation + cache hit/miss + fallback).
- [ ] Chạy pytest → pass.
- [ ] `py_compile` các file chạm tới → pass.
- [ ] Commit ai-service: `feat(DA-1182): expose /internal/ai/trends/fetch endpoint`.
- [ ] Commit infrastructure: `docs(DA-1182): feature docs internal-trends-fetch`.

- [ ] (Defer) Standalone background warm job — khi có danh sách region cần làm nóng (xem plan.md).

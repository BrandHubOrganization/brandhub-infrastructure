# Tasks

- [x] Inspect frontend callers and backend credit validation.
- [x] Demonstrate missing request headers with a focused test.
- [x] Reuse the shared helper in all three accounted caption methods.
- [x] Run focused tests and TypeScript checks.
- [x] Complete live trend-based sample through API only: after authorized local schema/credit setup, HTTP 200 with three persisted captions and a successful same-key retry. UI excluded by the user's latest instruction.

Read-only PostgreSQL preflight confirmed wallet/grant/workspace-limit/price tables are absent; caption credits is still integer. The current baseline migration sections were copied verbatim into `.tmp/caption-credit-preflight-20261105/subscription-credit-baselines.review.sql` for review, not applied. Baselines create REVIEW_REQUIRED/PENDING accounts; no balance or plan mapping may be guessed.

The paragraph above records the initial preflight. Subsequent authorized setup is recorded under `local-credit-seed`. Live API proof and all three unedited captions: `.tmp/caption-preview-20261105/KET_QUA_TEST_CAPTION.md` and `caption-api-proof.json`. Context/data quality and latency warnings remain in that report; functional success does not imply that retrieval quality is complete.

Locale and light/dark work: not applicable; no interface or text changes.

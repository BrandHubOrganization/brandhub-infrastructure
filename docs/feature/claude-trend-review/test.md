# Verification

Cost follow-up: verify mixed-platform posts share one bounded batch, retries/fallback are disabled on review transport, generic LLM behavior remains unchanged, and cache/export provenance follows the review model. Direct Models API authentication succeeded; S3 list failed with InvalidAccessKeyId using current AI-service configuration.

- High-confidence wrong emotion is reviewed when all-post review is enabled; checked posts are not resent; batches cover more than one batch; immutable NER/topic seeds remain unchanged.
- Claude failure/invalid output preserves PhoBERT values and is retryable. Correction changes the categorical label while the original probability distribution remains intact.
- Repeated run finalization does not duplicate training rows, including crash/retry after saving correction state.
- Claude naming only changes display fields; keyword, post IDs, order, score, trend ID and NER remain identical. Source quotes and IDs are checked; mixed/insufficient/invalid results do not supply a misleading new name.
- Same model/input reuses naming cache; changed input/model requires review; failures do not poison cache.
- Persistence and Business response display the reviewed name but retain original identity/dedup behavior.
- Monthly runner selects previous calendar month by run timestamp, validates labels, excludes validation leakage, requires replay/validation inputs, compares baseline/candidate macro and per-class F1, and never promotes models itself.
- Timer is a template until installed on the confirmed VM. No claim of active scheduling without verification on that VM.

## Results — 2026-11-02

- 71 focused Python tests passed across emotion review, naming/caching, monthly data preparation,
  run/cache lifecycle, Neo4j, trend-fit context and pipeline smoke/event-loop behavior.
- 6 AiTrendController tests passed in an isolated Maven build directory. The regular shared target
  test compilation hit an unrelated stale/bad AiCaptionService.Request class; no broad test-suite
  success is claimed.
- Correctness lint and changed-file whitespace checks passed.
- Monthly CLI dry-run prepared replay/corrections/validation without training or promotion.
- User explicitly approved sending four crawler captions to Anthropic for two live calls.
  Both returned AuthenticationError / HTTP 401 via an inherited DeepSeek endpoint (identified later). Original names, labels and softmax were preserved;
  no production review state was written. Successful live quality is therefore NOT verified.
- VM identity is deferred by the user. Timer files are templates only; no monthly schedule enabled.

## Cost/auth follow-up

- 81 focused Python tests passed, including explicit endpoint, no retry/fallback transport,
  cross-platform packing and generic Claude fallback regression checks.
- Direct Models API authentication succeeded with the existing .env key.
- Two direct Haiku 5.5 calls succeeded on the four previously approved captions from
  local saved crawl 20261030_115145. Emotion: sadness -> joy/surprise. T7: vote now ->
  Bình chọn TikTok Awards SEA 2026, with validated quotes. Original softmax preserved.
- Usage: 2,131 input + 791 output tokens; estimated $0.0006086. No automatic retries.
- All live outputs/cache stayed under .tmp/claude-trend-haiku-direct-check. No production state changed.
- S3 list using current AI-service credentials: InvalidAccessKeyId. Fresh S3 test remains incomplete.
- No accuracy percentage inferred from this selected four-caption smoke test.

## S3 follow-up after credential update — 2026-11-02

- S3 access succeeded with user-updated AI-service credentials; downloaded both distinct-ETag crawler datasets read-only.
- 31 JSON objects, two distinct ETags, 210 Facebook rows. Newest upload 2026-10-13; actual post dates 2026-08-27 through 2026-09-01. No TikTok/Threads in configured prefix.
- Local V12 emotion adapter inference on 20 selected real S3 captions completed offline; no train or production model modification.
- Two Haiku requests reviewed 20 emotions and three curated naming groups. Two coherent names passed quotes/IDs, one mixed control rejected.
- Eight emotion changes; at least one questionable neutral-to-anger overcorrection. No accuracy percentage or blanket teacher-label correctness claimed.
- Identity, group membership, scores and original softmax preserved. NER/topic inference not exercised in this isolated test.
- Repeat of the same context/cache made zero additional requests. Usage 6,656 input + 3,079 output; estimated $0.0022051.
- Human-readable report: .tmp/s3-fresh-review/report.md. Full raw responses/results retained beside it. No product code changed in this validation follow-up.

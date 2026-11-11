# Plan

Cost follow-up: add an isolated standard Messages review helper (Haiku 5.5, no retries/fallback, usage logging), explicit direct endpoint in client initialization, cross-platform emotion packing, matching cache/provenance model IDs, and focused transport/batching tests. Retest the four previously authorized captions in isolation; report the S3 InvalidAccessKeyId blocker separately.

1. Extend existing LabelCheckStep with all-new-post emotion review, chunking, stricter prompt/response validation and original-distribution preservation. Reuse run-store correction persistence; make correction export retry-safe.
2. Add a small T7 naming helper using the existing Claude client; balanced source samples, strict citation/ID checks, persistent content/model cache and explicit mixed/insufficient fallback. Integrate after fusion scores/membership are assembled.
3. Add display fields to CandidateTrend; use display_name for Neo4j names, embedding chunk descriptions, trend-fit labels and Business API presentation, retaining keyword-derived IDs/dedup.
4. Add VM monthly retrain CLI, replay/validation preparation, fixed-label validation, baseline-versus-candidate metrics, per-class regression gate, versioned adapter outputs, systemd service/timer templates and runbook. Do not activate an unknown VM.
5. Use focused mocked Claude tests; validate no scoring/membership/NER mutation, invalid quotes, caching/retries and calendar-month dataset isolation. Exercise the local entry points without real API spend or production model activation.

Existing worktree edits are preserved. New configuration is additive only. The emotion/topic adapters may be retrained from reviewed rows; NER remains untouched because this flow has no reviewed BIO labels.

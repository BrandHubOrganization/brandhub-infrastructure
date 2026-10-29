# Credit price CSV import

## Objective and contract

Admin imports `credit_recommendations.csv` produced by the standalone benchmark
tool, reviews current/proposed operation prices and source metadata, then applies
the reviewed file. Source contract: `benmark tool/CREDIT_CSV.md` and
`src/Benchmark.Core/CreditRecommendations.cs`, inspected 2026-10-28.

## Acceptance criteria

- Only an active system Admin can preview/apply; check server-side.
- UTF-8 with optional BOM, RFC4180 quoting/newlines, comma delimiter and exact
  ordered header: schema_version,operation,unit_credits,source_report_id,profile_id,
  width,height,steps,generated_at. Maximum 64 KiB; one or two data records.
- schema_version=1; only AMBASSADOR_GENERATE and COMMERCIAL_IMAGE, no duplicates.
  Credit is an unsigned integer, including deliberate zero, within the existing
  Web editing range 0..9007199254740991. Values beyond that range are rejected
  explicitly, never rounded (the benchmark tool itself allows Int64 values).
- Validate report GUID-N, nonblank bounded profile, image dimensions 256..2752
  divisible by 32, optional positive Int32 steps, and ISO8601 UTC export timestamp.
  Source metadata informs review/audit, not resolution/model-specific pricing.
- Preview writes no prices. Show each current/proposed price, revision, preserved
  enabled state, report/profile/dimensions/steps/export time and record/field errors.
- Apply reparses the uploaded file and verifies its preview SHA256 and exact set
  of expected revisions. Lock operations in a deterministic order; one transaction
  updates all changed prices and audit, or rolls back everything on any conflict.
- Preserve current enabled/disabled state. New operation prices remain disabled
  until explicitly enabled through the existing controls. Unchanged prices do not
  create revisions. Other operations, wallets/limits and existing reservations stay
  untouched; accepted AI jobs retain their already-fixed price revision.
- Repeating a changed request with old revisions returns stale; no automatic retry.
- No new tables/migration/init/seeder, no shared DB apply or automatic benchmark run.

## UI and states

On `/admin/credit-prices`, Import CSV opens the file picker directly. Selection
loads an inline review panel; Apply is explicit and disabled on errors, stale
preview or while busy. Keep the selected file on recoverable errors; refreshing
the preview requires another review before Apply. No additional upload modal.

All new strings use parallel `credit.csv.*` vi/en keys. Use existing tokens and
Button/Input/Badge, responsive cards for at most two records, light/dark contrast,
keyboard focusable error summary and live pending/success states.

## API

- POST `/api/v1/admin/credit/prices/import/preview`: multipart `file`; preview DTO
  with SHA256, rows/current state and structured issues; no persistent upload.
- POST `/api/v1/admin/credit/prices/import/apply`: same `file` plus JSON part
  `request` containing SHA256 and expectedRevisions. Returns changed prices and
  unchanged operations. Revisions/current price strings avoid metadata precision loss.
- Standard ApiResponse. Invalid file 400, oversized 413, stale/hash mismatch 409,
  forbidden 403. Audit uses the existing append-only admin audit infrastructure.

## Out of scope

Changing benchmark formulas/export format, live usage/token/GPU metering, buying
credits, adding operations, auto-enabling AI or new price dimensions.

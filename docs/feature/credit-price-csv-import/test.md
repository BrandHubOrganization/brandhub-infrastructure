# Verification

- Actual benchmark CSV: BOM, quoted values, both operations, one operation, blank
  steps, zero price, escaped quote/comma/newline and Excel-safe profile accepted.
- Reject wrong/duplicate/reordered/missing header, malformed quotes/UTF8, oversized
  file, empty data, >2 rows, duplicate/unsupported operations, wrong schema,
  negative/fraction/scientific/overflow/unsafe integer, invalid GUID/profile,
  dimensions/steps/timestamp. Return record/field codes; no writes on preview.
- Forbidden/inactive/missing actor denied before parsing/writing; malformed upload
  and request parts return structured errors, never generic 500.
- Two-row apply is atomic: stale second operation or audit failure leaves first
  unchanged. Race against manual price edit uses the same advisory lock, compares
  revisions and fails without lost updates. Opposite CSV order does not deadlock.
- Preserve enabled/disabled, initialize absent price disabled, leave other operations
  and old reservations/history unchanged. Exact SHA mismatch rejected. Repeated
  changed apply is stale; refreshed no-op creates no price version.
- Browser: file picker, auto-preview, compare/provenance, invalid/stale/large file,
  double-click/async selection races, preserved file and explicit re-preview, success
  refresh, vi/en/light/dark/375px/keyboard, no CSV code or HTML execution.
- Use isolated DB/mocks only; do not apply a real benchmark price, run AI or seed
  shared data. No new executable tests in src or committed local fixtures/reports.

## Results — 2026-10-28

- 59 assertions passed in the local Java harness: actual benchmark export, malformed
  quotes/UTF8/numeric/metadata cases, active/Admin guard, SHA/revision checks,
  multipart preview/apply binding (including string revision JSON), size limits,
  missing/malformed request and pre-controller multipart 413 mapping.
- PostgreSQL 16 QA, isolated container/random loopback port: actual transactions,
  atomic two-price changes, stale second operation, audit failure rollback,
  two opposite-order imports racing (one succeeds, one stale), import racing against
  the existing manual-price API, retention of old accepted-job prices, no-op versions,
  enabled preservation, absent price disabled, provenance audit and active-user check.
  Only the private QA schema was initialized/reset; no demo/shared DB connection.
- Browser passed file-picker selection, immediate preview, source metadata, exact
  current/proposed display, real multipart transport to a memory-only QA API,
  double-click guard, table/cache refresh, no-op, invalid/oversized file, stale
  revision with explicit re-preview, late-response selection race and error focus.
  New panel checked in vi/en/light/dark and widths 375/768/1440.
- Changed Web files pass ESLint with zero warnings; production build passes.
  Backend compilation and resolved Commons CSV runtime tested. New test code,
  fixtures, screenshots and logs remain ignored under keep-local-only.
- Existing AdminCrawlConfigServiceTest regression also passed (5 tests).

## Manual test and rollout

1. Restart Business using Maven so the new Commons CSV dependency and controller
   are loaded; reload/rebuild Web. Do not run an init or migration for this feature.
2. Sign in as Admin and open `/admin/credit-prices`.
3. In the benchmark tool, choose representative eligible reports and export
   `credit_recommendations.csv`. Import that file using the new toolbar action.
4. Verify current/proposed unit credits, source report/profile/dimensions/steps,
   export time, revision and enabled state. Only two image operations are supported
   in CSV v1. Width/height/steps are provenance, not extra price dimensions.
5. Apply explicitly. Changed prices receive new append-only revisions; unchanged
   amounts do not create versions. Existing accepted AI jobs keep their old price.
6. Preview a file, edit one target price separately, then apply: expect 409 and no
   partial update. Check the file again, review the new current values, then apply.
7. The importer uses the Web price editing range 0..9007199254740991, a 64 KiB
   limit and at most two records. Oversized Int64 exports are rejected with an
   explicit error; their values are never rounded to JavaScript numbers.

## DB impact

- `ai_credit_operation_prices`: INSERT only for changed/absent imported operations;
  preserve enabled state (absent=false) and retain all old revisions.
- `audit_logs`: one audit per accepted apply, including SHA256, source report/profile,
  benchmark metadata, previous state and updated count; same transaction as prices.
- No schema, MongoDB, init, migration, seeder, wallet, subscription or limit changes.
  No real prices or shared data were changed by implementation/QA.

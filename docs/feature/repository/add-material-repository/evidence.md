# Add Material — implementation evidence, 2026-10-24

**Status: implemented locally, acceptance incomplete / NO-GO for activation.**
Ticket01 only; no implementation of View/PATCH/Trash/Download FRs. Existing readers/watermark/Post
callers changed only where needed for private upload compatibility. No live migration, deploy, commit or push.

## Baseline and authority

Business baseline `620855477dc6cd7f4b9a0da824c260ae04649e64`; Web baseline
`b4a158ef5b10241af53878981db1b17b722a4392`. Current branch `feat/tuan-sprint-9`.
Infrastructure already had unrelated subscription docs and Repository planning docs in its worktree;
those are not new implementation evidence. Historical `spec-before-planning` snapshot does not override
BR01–BR25 or current `spec/plan/task/test`.

Rules read: business CLAUDE.md/rule.md, web AGENTS.md/CLAUDE.md/rule.md/STRUCTURE,
infrastructure workflow and relevant local skills. Applied implement/TDD/code-review workflow.

## Delivered code

| Area | Implementation |
|---|---|
| Existing API | Reused upload-session/confirm and multipart ≤5 MiB; TASK default/assignee guard, LIBRARY context, no original WebP conversion |
| ACL | PG account/workspace/membership/profile resolver; no implicit OWNER file rights; ancestor checks; list resolves membership once and batches ancestors |
| Quota | PG pool→Agency→reservation lock order; effective paid catalog total; BASIC20 GiB; stable provider; atomic reserve/commit/release and ledger |
| Schema | Additive PG usage/reservation/ledger/pool SQL, Mongo optional legacy validator/session/reference/provider-key indexes, explicit DRY_RUN wrapper |
| Storage | Private provider router through existing FileStorageService, default-off flags, conditional ETag copy, bounded HEAD/range/timeout, no new Redis/service |
| Saga | Durable Mongo majority checkpoints, PG claims, unique canonical per promotion token, actual-size/MIME checks, Mongo transaction publication/pins, idempotent READY replay |
| Cleanup | Delayed staging delete+HEAD absence; physical hold clears once only after newer authoritative inventory; ambiguous copy retains quota, confirmed missing after lifetime bound cancels safely |
| Agency | Existing create transaction applies pool guard and initializes verified-empty usage for newly created Agency while Repository is enabled |
| Watermark | Private original read, trusted logo origin, bounded raster dimensions, reservation before processing, actual PNG usage, inherited ACL/purpose/task/lineage |
| Existing editor | Stable material_id in Post/Task media, atomic reference pin reconciliation including removal of final material, fresh private URL on render/publish, no signed URL persistence/log payload |
| Web | Typed session/PUT/confirm, progress/validation/retry/abort/workspace isolation, real Library upload form, vi/en parallel keys, PDF fallback |

The Library **list remains its existing mock implementation** until View ticket02. Newly confirmed
uploads can be shown in the current view; this is not a server-backed Repository listing.

## Executed checks

Windows 11 / Java21 / Maven offline / Docker Desktop29.9.2 / Node local dependencies.
PostgreSQL `postgres:17-alpine`; Mongo `mongo:8.0` replica set, disposable containers only.
Docker API compatibility property `-Dapi.version=1.44` is needed for this local Testcontainers version.
An earlier run without it skipped Docker tests; skipped runs are **not** integration evidence.

| Check | Command / evidence | Actual |
|---|---|---|
| Backend full suite | `mvn -o -q -Dapi.version=1.44 test`; local `business/target/repository-full-test.log` and Surefire XML | Exit0; 183 suites, 1205 tests, 0 failures/errors, 93 skipped (1112 executed). Run before final small pin/preflight refinements; focused regressions follow |
| Focused G1 | `MaterialRepositoryIntegrationTest,StorageQuotaPostgresTest` with Docker API property | Real PG + Mongo transaction tests pass; binary adapter is in-memory and **not G0** |
| Unit/regression | `MaterialUploadPolicyTest,MaterialContentValidatorTest,MaterialAccessPolicyTest,MaterialUploadCoordinatorTest,RepositoryPostMediaTest,MaterialServiceImplTest,PostServiceImplTest` | Focused runs pass; initial missing policy/container API tests failed before implementation |
| PG migration | SQL applied twice on disposable schema in StorageQuotaPostgresTest | Idempotent fixture run; concurrent15 GiB reservations accept one; commit replay no double count; paid-total/expiry and stale/95% pool guards pass |
| Pool accounting | StorageQuotaPostgresTest cleanup test | Hold remains until newer inventory, clears once, physical canonical usage remains |
| Mongo schema | Actual mongosh expansion applied twice per disposable fixture in final integration run | Replay pass; validator/indexes and transaction publication exercised; not a production legacy backfill |
| Post references | MaterialRepositoryIntegrationTest | Persisted Post has material_id and no signed URL; Post and Task Post remove final pin in same Mongo transaction |
| Web build | `npm.cmd run build` | Exit0, TypeScript + Vite build pass |
| Web typecheck | `npm.cmd run type-check` | Pass |
| Web full unit suite | `npm.cmd test` | 3 files / 10 tests pass; Vitest include now covers repository-required tests/unit location |
| UI | `BASE_URL=http://127.0.0.1:3000 npx.cmd playwright test tests/e2e/repository/add-material.spec.ts --workers=1 --reporter=line` | 4 pass; 375 light / 768 dark / 1440 light, keyboard focus, READY-only success, no JWT on PUT, quota error and OWNER control hidden |
| UI artifacts | `brandhub-web/test-results/repository-add-material-*/repository-form-*.png` | Form screenshots inspected; no horizontal page overflow. Existing shell/mock-list layout is outside this ticket |
| Lint | ESLint changed TS/TSX | 0 errors; 3 pre-existing set-state-in-effect warnings in useEditorForm/MediaTab |
| Infra | `./scripts/repository-migrate.ps1` | DRY_RUN, no connection/write |
| Diff | `git diff --check` | No whitespace errors |

No E2E result here proves storage durability, provider compatibility or malware safety.
Container validation is bounded structural checking (max128 ranges/2 MiB metadata/30s), not codec decoding,
PDF stream execution, antivirus or a guarantee every valid complex container is supported.

## Review and remaining gates

Standards/Spec were reviewed independently through code-review. Fixed findings: per-row ACL N+1,
safe recovery diagnostics, expiring Post URL persistence, staging/physical hold leakage,
new Agency provisioning/capacity, missing-copy recovery and stale pins on final media removal.

**Not run / not complete:**

- TC-A01–03: no disposable rclone/Drive or AWS test endpoints/config were supplied. Presign,
  conditional-copy semantics, durable acknowledgement/restart/SSD-full/403/429 remain unverified.
- G0 also needs gateway enforcement of upload size and maximum operation lifetime below24h,
  and a durable physical inventory feed ≤5 minutes old. None is deployed by this ticket.
- Actual legacy object inventory/backfill and rollout against a representative data copy remain pending.
  Expansion leaves existing agencies inventory-unverified and legacy objects non-READY until verified.
- Full per-step process-kill/timeout fault matrix, all revoked-ancestor races, real Mobile device contract,
  provider adapter integration and full watermark/private-logo production-shaped regression remain pending.
- Future mutation/purge writers must use the provided revision/reference fence. No Update/Remove
  lifecycle is implemented here; PURGE_RELEASE belongs to that later workflow.

Both provider verified flags and writesEnabled remain **false**. Do not close ticket01 as Done until the
remaining test.md gates and inventory work are resolved. See [rollout.md](rollout.md) for activation and recovery.

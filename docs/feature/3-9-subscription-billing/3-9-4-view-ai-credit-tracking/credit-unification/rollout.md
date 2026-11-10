# Rollout and manual acceptance

## Scope
All new generation fees use DA-974. Caption generate/refine/adapt share CAPTION_VARIANTS. No token/GPU metering, Payment provisioning, content-writing, editor prompt, publish or mock Studio screen changes.

### Database delta
Apply `docs/database/migrations/2026-10-21-unified-ai-credit.sql` after existing Caption/Video tables and compact Credit accounting/execution migrations. Fresh databases use `docs/database/init-postgres-v2.sql` only.

| Table | Change |
| --- | --- |
| ai_video_jobs | Nullable reservation_id FK, unique non-null reservation index, CHECK excluding simultaneous usage_id + reservation_id |
| ai_caption_generations | credits INT → BIGINT; existing values/history preserved |
| DA-974 grant/reservation/allocation/price tables | No new columns/tables; new requests use existing accounting/execution metadata |
| Legacy ledgers/limits/usages | Retained, not imported/deleted; legacy refund tail only |

The Agency seeder no longer invents random legacy usage or Owner caps. It does not grant money; explicit authorized DEV_SEED remains the dev-funding entry point. Existing seeded legacy rows remain untouched.

## Before deployment
1. Inspect open legacy jobs, current grants/prices and schema on the intended database. Freeze relevant Business/workers before DDL and do not run an old billing build afterward.
2. Apply the new SQL with `psql -X -v ON_ERROR_STOP=1 -f <migration-path>`. It is transactional with bounded lock/statement timeouts. Do not edit old teammates' migrations or replay all migration files recursively.
3. Deploy matching Business and Web together. Workspace POST `/captions`, `/captions/refine`, `/captions/adapt`, `/videos` now require `Idempotency-Key`. Web service helper supplies it; external callers need updating. API URLs/bodies/result fields remain; credit amounts are long, Video adds creditsHeld (creditsUsed=0 while held). Existing generic AI routes keep their request-hash convention and Workspace header.
4. Admin configures missing operation prices. Do not insert guessed prices or treat missing pricing as free. Agency needs a real grant or explicitly authorized test grant and a cycle anchor. Owner has no personal ceiling, not unlimited funds.

## Manual test
Use an Agency with test funds and a Workspace where the actor is Owner/Manager/Creator. Test configured prices with the existing editor adapters; standalone mock Studio pages are not newly connected.

- Caption first generation: one charge, one history row, remaining decreases by the configured price. Retry the same key/body: same generationId, no second provider call/charge. Change payload/action with that key: 409.
- Refine and Adapt: both use CAPTION_VARIANTS, one request fee even when multiple platforms return. Choice/trend-fit/status/styles/history reads remain free.
- Video: PENDING holds, not charges; COMPLETED with video_url charges once; explicit FAILED releases once. Timeout/unknown does not refund. Close browser and allow workers to finish; history/status should converge. Another member must not read the original user's Video job.
- Member ceiling 0/missing price/insufficient Agency funds: reject before dispatch. Owner bypasses only personal ceiling. Price changes affect new requests, not active reservations.
- Workspace Credit and Agency reporting agree on available/used/held. Dashboard shows explicit subscription period and a nonzero error state when setup is missing. Legacy seeded usage must not appear in current totals.

## Local read-only preflight (2026-10-21)
`brandhub-postgres/brandhub`: legacy open Video jobs=0; latest enabled Content price=3/revision2, Ambassador=10/revision1; the other five operations have no configured price. The new reservation_id column is absent: new migration has NOT been applied to this application database. No local/demo/shared DB or Atlas mutation was performed during implementation.

## Remaining live acceptance
Real JWT/Gateway/provider calls and a complete paid AI run remain for deployment testing. Browser checks used fixtures; backend checks used a dedicated PostgreSQL container and fake AI. Restart the matching Business build after migration; SQL alone does not prove HTTP/provider readiness. Unknown-outcome manual reconciliation UI and actual Payment/Subscription integration remain outside this change.

## Local APPLY receipt — 2026-10-21
After explicit user request and confirmation that Business/workers were stopped, rechecked: no listener on 8081, zero other sessions on `brandhub-postgres/brandhub.public`, zero open Video jobs. Applied only `2026-10-21-unified-ai-credit.sql` with ON_ERROR_STOP; transaction COMMIT succeeded. Earlier Credit schema effects were already present and were not replayed. This supersedes the preflight's pending-APPLY state above for this local database only.

Postcheck PASS: Caption credits is bigint; Video reservation_id is nullable uuid; FK/CHECK validated; unique partial reservation index valid. Application schema readiness query returns true. Pre/post counts unchanged: Caption/Video/reservation/allocation/legacy usage=0 each, grants=1. DEV_SEED amount=100, used=0, held=0 unchanged. No init, seed, cleanup, guessed prices, Atlas changes or service restart. Start the matching Business build before live acceptance; missing Admin operation prices still need configuration.

# Agency member credit

## DA-974 commit boundary

This feature commits Agency/member accounting, configuration/reporting and fixed operation-price AI integration. Actual token/hardware-cost metering on self-hosted Vast is deferred by the product owner. Payment demo UI, unrelated Campaign/Task UI and Task migration changes are not part of the Credit commit. Local verification sources/logs/screenshots/build products remain ignored; test.md/manual-test.md are required feature documentation, not executable test suites.

## AI integration slice — 2026-10-20

Dev seed confirmed: Demo Agency `23dc3d67-4c4b-4a0a-8b91-da5968dbbbb9`, dev Owner `user177@hotmail.com`, 100 credits under DEV_SEED, nonexpiring and separate from purchases. No subscription exists for this Owner; local seed establishes a monthly usage anchor only when absent. PLAN then PURCHASED then DEV_SEED allocation order. Additive `developmentAvailable` in balance response; omitted by older servers means zero. No public DEV_SEED grant API; only the guarded local seed script.

Owner access confirmed: allow Owner into Editor and AI Studio routes to consume AI; retain all existing server-side Task/edit/submit/publish authorization. Do not grant Client access or change other route permissions.

- Seven Business AI generation routes enforce Credit before dispatch. `X-AI-Workspace-Id` is explicit (separate from Gateway's JWT-derived X-Workspace-Id); Agency is resolved server-side. Permissions are revalidated and supplied tenant IDs overwritten. `Idempotency-Key` identifies a deliberate generation; technical retry retains it.
- Each adapter produces one image/video or one text request (including caption variants). A durable claim prevents repeat provider calls across processes/restarts. Retain responses for same-key replay, not image input payloads. Changed payload/key reuse conflicts.
- Usable synchronous output settles one unit; explicit failed/empty output settles zero. Validation/rejection HTTP 400/413/422/429 releases the hold. Network timeout, ambiguous server failure or crash stays held, without automatic redispatch/refund. UI explains pending reconciliation.
- Video job IDs bind to reservations and originating users. Only that authorized user can poll. A bounded worker also polls pending jobs after Editor closes. COMPLETED requires a video URL; FAILED releases. Missing/old jobs do not automatically refund.
- Web uses shared AI service for context/key, translates Credit errors and invalidates reports after calls. No public reserve/settle/grant, publish or content-writing changes. Parallel vi/en `credit.ai.*` text, existing theme retained.
- AI upstream generation endpoints require the internal service key; close the existing unguarded hashtag route to prevent bypassing Business accounting. Upstream must remain internal-only in deployment.
- Dev funding is explicitly authorized local seed, not fabricated payment. Confirm exact Agency first: dev Owner owns several. Missing prices stay blocked until Admin configures them.

> Database revision: [compact-schema.md](compact-schema.md) supersedes the earlier eight-table layout below. SQL/init and Business stores now use four independent Credit tables, Agency/member columns and derived usage. Public API contracts are unchanged. Do not deploy a previous eight-table build against this baseline; AI/payment hook integration remains pending.

## Status and scope

### Web reporting slice — 2026-10-20

- Extend existing `/agency/:id/credit`, not a new billing module. Resolve Agency ownership from the URL Agency's server response and current user ID; never infer Owner from the selected Workspace. Owner sees balance/default/member controls, Manager/Creator see own limit and usage only; Client is excluded. Backend authorization remains authoritative.
- Owner balance shows Plan available, purchased available, total available (sum, held already excluded) and held separately. No claim of aggregate Agency spending: that endpoint does not exist. Load member details only on selection; no per-member request fan-out. Owner can also view own tracked usage, with no personal ceiling.
- Usage uses the server subscription period, used, held and operation breakdown. Personal remaining is max(0, limit-used-held), not guaranteed shared funds. NULL Owner limit means no personal ceiling, never unlimited Agency money. Missing account/cycle is a prerequisite state, distinct from genuine zero usage and missing-schema errors. No history date filter or charts fabricated from current-period APIs.
- Reuse Admin price editor; show per-request/per-image/per-video billing units. Members may read current catalog; no price edits outside Admin. Missing, disabled and explicit free price are distinct. No buy-credit button or direct reserve/settle/grant calls; AI/Payment integration remains pending and is disclosed compactly.
- Inline configuration save and Enter submission; preserve draft on failure, require reload after 409 and show loading/empty/403/503/account-not-ready states without mock data. Invalidate inherited member-limit/usage queries after default changes and matching member usage after override changes. Cached data must be scoped by authenticated user and Agency; do not show one user's/member's result under another.
- Text keys in parallel `src/i18n/locales/{vi,en}/credit.json`: balance.*, usage.*, catalog.*, unit.*, unitName.*, sourceLabel.*, integration.*, refresh, member.search/noResults/selected, errors.account/notFound and existing forms/source/errors keys. BrandHub primitives/tokens retained; keyboard labels/focus, light/dark and 375/768/1440 widths required.

Confirmed by product owner on 2026-10-19. Implements FR 3.9.5/3.9.7 with Manager support and an Admin operation price catalog. Payment implementation is owned by the payment integration; no PayOS changes here.

## Confirmed rules

### Confirmation — 2026-10-20 (supersedes pending default/units below)

- Global fallback is 10 credits per member per period. Agency default overrides it, then member override. Owner has no personal limit. The example 3 credits/image is not an authorized price and is not seeded.
- Content/caption/hashtag costs one configured price per successful request; image/video cost per successful output. Partial success charges successful outputs only.
- After subscription expiration, purchased credit remains spendable and member usage continues resetting monthly from the last authoritative subscription anchor. Calendar arithmetic is anchored, not successive 30-day durations; old-period reservations settle against their original period.
- Only verified entitlement/payment integration may supply grants. No public balance minting route, no inference of payment from ACTIVE subscription alone. Subscription/Payment implementation remains another member's responsibility.

### Accounting scope

PostgreSQL stores Agency account anchor, period-scoped Plan/nonexpiring purchased grants, member usage by period, durable reservations and grant allocations. Agency account row serializes grants/reservations/settlements; no transaction remains open across AI network calls. Reserve includes both active holds and settled use against the personal ceiling. Price version and allocation are retained with each reservation. Repeated request key must match operation, Workspace, units and server-computed payload hash. Settlement/release is idempotent, including zero-success and old-period completion. An unknown network outcome stays reserved for reconciliation, never blindly refunded on a timer.

- Agency credit is shared; member limits are independent spending ceilings, not reserved allocations. Sum of ceilings may exceed the shared balance.
- Owner, Manager and Creator may consume credit. Client may not. Owner consumption is tracked but has no personal ceiling; the shared balance still applies.
- Owner configures the Agency default ceiling and member-specific overrides. New members inherit the Agency default, or the confirmed system fallback of 10, without manual approval. A ceiling is not a balance grant.
- Member usage resets with the subscription period; configured ceilings persist. Plan credit does not roll over; purchased credit persists and Plan credit is consumed first.
- Admin configures a non-negative integer price per supported operation. Zero is an explicit free price; missing/disabled pricing is not silently free. Each change produces an immutable version. A future reservation captures that version, independent of later changes.
- Reserve before generation; settle successful units; release unused reservations only after authoritative failure/cancellation. Technical retries are idempotent; explicit regeneration is a new operation; reuse does not charge.
- Subscription/payment activation and top-up must not be inferred from a browser return URL.

## Integration boundary and remaining input

1. Product owner confirmed focus on one Agency; Subscription is owned by another member. Do not duplicate the Owner subscription quota across Agencies. Provisioning requires their explicit Agency grant contract.
2. System default confirmed as 10. The member-limit API now returns SYSTEM_DEFAULT/10 when no override/default exists; policy API still returns null/revision zero for an unconfigured Agency policy so Owner can create one explicitly.
3. Purchased balance remains usable after subscription expiration/cancellation (confirmed).
4. Concrete operation prices are supplied by Admin, never seeded as assumed business prices. Units are confirmed (successful request/output); each adapter must still validate the actual successful output, not merely HTTP 200.

## First implementation slice

Additive PostgreSQL configuration only: Agency policy, generic member overrides, immutable operation price versions. Owner-only writes use revision checks. Owner can manage current Agency members (including members not assigned a Workspace yet), but cannot set a personal Owner limit. Members can read only their effective ceiling; consumption authorization will additionally validate the actual Workspace role. Legacy creator tables, usage totals, dashboards and AI endpoints are unchanged. Configuration defaults are resolved without granting money; join-time inheritance and period usage come later.

## API and errors

- GET/PUT `/api/v1/agencies/{agencyId}/credit/policy`: Owner only, nullable default and revision; writes require `expectedRevision`.
- GET `/api/v1/agencies/{agencyId}/credit/members/me`: Owner or current internal Agency member; own effective limit and override source. Owner has null personal limit.
- GET `/api/v1/agencies/{agencyId}/credit/members/{memberId}/limit`: Owner only; current member's effective limit and revision before editing.
- PUT `/api/v1/agencies/{agencyId}/credit/members/{memberId}/limit`: Owner only, current member, nonnegative limit, `expectedRevision`.
- GET `/api/v1/credit/prices`: authenticated users, bounded supported operation catalog only.
- PUT `/api/v1/admin/credit/prices/{operation}`: Admin only, price, enabled, expected revision. Conflicting revisions return 409; no silent overwrite.
- Explicit errors for unconfigured policy, forbidden access, missing Agency/member, unsupported operation and stale configuration. No public grant/reserve/settle endpoint in this slice.

## UI acceptance (later slice)

Use existing UI primitives/theme, keyboard accessible inputs, inline numeric validation, read-only Owner unlimited state, separate shared balance and personal ceiling. Add parallel vi/en `credit.*` keys and verify light/dark at mobile/tablet/desktop. No fabricated balance or fallback mock; no payment buttons until payment contract is ready.

## Configuration UI slice — 2026-10-19

- Owner entry `/agency/:id/credit`: default limit form, Owner unlimited notice and member selector showing one member's effective ceiling/source before changing it. Reuse current Agency member list, never issue one credit request per member. Explicit save, preserve inputs on failure, require reloading current data after stale revision before retrying.
- Admin entry `/admin/credit-prices`: supported operation selector with current price/revision/enabled flag. Missing price is unconfigured, not zero; saving creates a version. Labels call this a configuration, not an active billing system; consumption units await AI adapter confirmation.
- Scoped React Query keys include logged-in user and Agency/operation. Route access and Sidebar match existing Owner/Admin security; backend remains authoritative. No change to existing Admin panel, Subscription UI, publish, editor, or global theme.
- Text namespace `credit` in parallel vi/en JSON: title, policy, member, price, operation, source, errors and pending-integration notice. Whole-number nonnegative safe-integer validation. Zero allowed explicitly; blank never silently coerced to zero. Keyboard labels, inline errors/live status, disabled saving, light/dark tokens and mobile stacking.

## Definition of done

This slice: schema and configuration APIs compile and pass isolated checks, init/migration parity, no production data mutation. Whole feature: period provisioning, immutable request pricing, atomic reserve/settle/release, scoped reporting and UI tested end-to-end; not claimed complete by configuration alone.

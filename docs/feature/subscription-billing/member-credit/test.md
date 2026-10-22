# Member credit verification

## AI integration acceptance

Final follow-up: 19 browser fixture assertions PASS after Owner route approval (includes Owner Editor/AI Studio access, unchanged Client/publish route rules and actual Owner Editor AI panel). Also filled the real Editor prompt and clicked Generate against the fixture upstream; result displayed correctly. Credit vi/en key parity PASS (126 keys including concurrent UI additions); final app/node typecheck PASS. Last Maven isolated compile PASS and all 58 JDBC/fake-upstream assertions rerun against that build PASS. Dedicated browser, Vite 3027 and disposable PostgreSQL test container were cleaned up; local Demo Agency funding remains intact.

Results 20/10: full isolated Maven compile (627 sources) PASS; 58 assertions using actual JDBC/Spring transactions and localhost fake AI HTTP server PASS. Covers all seven adapters, canonical payload/tenant override, missing price/key, Client/revoked membership, personal/shared ceilings, sync output failures/422, ambiguous 503 held and no redispatch, concurrent same-key one-dispatch, cached results, scoped video polling, failed/successful video, frozen video price and server worker finalization without browser. No real provider calls. Temporary Java sources/build remain ignored under Business target.

Web: app/node TypeScript and production build PASS. Scoped lint has no errors; one existing set-state-in-effect warning in AIImageStudioPanel remains unchanged. 17 Playwright CLI assertions PASS using fixture routes: six Editor AI service adapters + video status, correct explicit Workspace on every POST, stable idempotency key across real Axios 401-refresh retry, distinct deliberate-generation keys, own-user-only query invalidation, translated errors and development-fund reporting. Light/dark screenshots at 375/768/1440, no page overflow/page errors. Expected fixture HTTP 401/409 are not application failures. CLI artifacts ignored under output/playwright/.playwright-cli. No src tests or committed artifacts. This is not a real paid-provider/JWT-Gateway-to-Business E2E test.

DB: fresh init and upgraded grant/reservation pg_dump schemas match. Repeated new deltas and double-running guarded seed on isolated DB PASS (still 100). Applied both additive deltas and exact authorized DEV_SEED to local brandhub-postgres/brandhub: 53 Agencies/798 members/3 price rows unchanged, reservations=0, grants 0→1. Only Demo Agency anchor initialized; 100 available, used=0/held=0 at seed time. No subscription/payment/Mongo/Atlas/legacy writes. Source is explicitly DEV_SEED, not a fabricated purchase. Init contains schema, not seed.

React guidance led to a shared query client and user-scoped invalidation; UI/UX guidance preserved existing theme/controls and supplied explicit pending/unknown-credit feedback. Existing unrelated UI changes were retained. Runtime real-service restart and provider-backed generation remain user test steps; unknown-outcome manual reconciliation UI and automatic payment provisioning are not implemented.

Upstream hashtag generation must declare verify_internal_key like the other six adapters; anonymous direct AI calls are rejected. No internal key is sent to Web.

Verify all seven operation mappings and usable/failed outputs; missing Workspace/key, foreign/Client/inactive actor, missing price/account/funds/ceiling must stop before upstream. Same key and same canonical payload replays without dispatch/charge; changed payload conflicts; concurrent dispatch CAS has one winner. Confirm price remains frozen. Explicit rejection releases; unknown HTTP/network/crash stays held. Video pending stays held, COMPLETED settles once, FAILED releases once, another user's job is denied, closing browser still allows server reconciliation. DB errors after output must not trigger regeneration or refund. Delta/init parity and repeat apply; no live paid calls. Web preserves UUID on Axios token-refresh retry, sends correct Workspace, translates Credit errors and invalidates only relevant cached reports. Check vi/en, keyboard and theme-safe feedback. Dev seed is idempotent, exact confirmed Agency only, 100 credits without fake payment; prices remain Admin-owned.

## Local migration execution — 2026-10-20

At the user's request, applied revised 19/10 configuration then 20/10 accounting to local container `brandhub-postgres`, database/schema `brandhub.public`. Both committed; postcheck PASS. Preflight found no Credit draft/new objects. Four new tables, nine parent columns, indexes and enabled immutable-price trigger verified. All four new tables remain empty; parent configuration/anchor remain NULL with revision zero. Existing row counts unchanged: Agency 53, membership 798, legacy ledger 50, legacy creator limits 50. No init/seed/backfill/Mongo/Atlas changes. Prior no-APPLY notes below describe earlier implementation/test stages.

Manual role-based scenarios and current integration limitations: [manual-test.md](manual-test.md). A missing cycle after this migration is expected CREDIT_ACCOUNT_NOT_READY, not proof that migration failed. Restart the matching Business build before live API testing; migration execution alone does not verify JWT/Gateway/provider integration.

## Web reporting acceptance

- Owner in URL Agency sees balance/default/member controls even if a persisted Workspace has another role; nonowner never calls policy/member-list/balance APIs. Client route denied. Changing user/Agency/member does not render old results in the new context.
- Plan 100 + purchased 40, held 20 -> available 140 (not 120); no Agency-spent total invented. Member limit 10, used 3, held 2 -> personal remaining 5; limit 0 -> 0; Owner NULL -> no personal ceiling. Empty usage/catalog is not an error or free pricing.
- Default change refreshes inherited member limit and reports without recreating membership or granting funds. Member update uses fetched expectedRevision and refreshes matching usage. 409 preserves input and blocks stale retry until reload; same-revision reload restores the actual returned value.
- Account-not-ready 409 displays a setup state, schema 503 identifies both applicable deltas, 403/404/network failures are not rendered as zero. Partial panel failure does not hide valid unrelated data. No automatic repeated failures/refetch while editing.
- Selected member only triggers own detail/usage queries; search filters existing list; zero eager detail requests. Admin prices distinguish missing/disabled/free and request/image/video units; Manager/Creator catalog read-only. No Billing placeholder endpoint, buy/grant/reserve/settle action or actual AI call.
- Keyboard input labels and Enter save, inline numeric errors, light/dark screenshots at 375/768/1440 and Vietnamese/English key parity; format/lint/typecheck/build. CLI browser fixtures never write real data and remain ignored outside src.

### Web reporting results — 2026-10-20

- 42 main Playwright CLI fixture assertions PASS: NULL policy, system fallback, held excluded once from availability, remaining personal ceiling, no eager member detail calls, one-click member selection, expectedRevision writes, inheritance/usage invalidation, preserving an unsaved member draft during default refresh, same-revision reload, explicit zero, member switching, 409 recovery, invalid integers never submitted, personal view with no Owner API calls, missing cycle/schema, Agency-specific ownership, missing/free/disabled prices, Admin operation units, locale and responsive checks.
- 19 additional assertions PASS: changing authenticated user without reloading does not display Owner cached funds/controls, personal view in both themes at 375/768/1440, empty/network/403/unsafe-number states, Client denial including trailing slash, nonadmin price-route denial, English personal labels and keyboard input-to-save focus. Four fixture PUT attempts in the main run (including intentional conflict), zero real API/DB writes.
- Scoped ESLint/Prettier, app and node TypeScript, production Vite build PASS. 88 vi/en Credit leaf keys have exact parity. Existing bundle-size and Library ineffective dynamic-import warnings remain unrelated. Sandbox-native dependency/spawn startup failure was resolved by approved local Vite execution, without dependency changes.
- Screenshots captured for Owner dark and Admin light at all three sizes, personal light/dark at all three sizes, and Owner desktop light. Owner desktop light/dark, Admin mobile light and personal mobile dark inspected; table labels wrap on narrow screens. UI/UX guidance led to compact contextual help and inline validation; React guidance led to scoped query keys, derived amounts/drafts and independent queries instead of eager member fan-out.
- Artifacts/scripts only under ignored output/playwright and .playwright-cli. Shared DB/migrations untouched; AI dispatch/payment hooks and browser-to-live-backend JWT/Gateway E2E remain unverified. No files were committed or pushed. Unrelated pre-existing whitespace findings in campaign-partners/page.tsx and campaign/components/CampaignDetail.tsx were preserved; Credit-scoped diff check passes.

## Compact Business/API verification — 2026-10-20

- Isolated full Maven compile PASS (623 main sources; existing GoogleOAuthService unchecked warning). Temporary POM/classes stay under ignored target to avoid IDE target/classes overwrites; no application startup claimed.
- 54 real PostgreSQL/Spring transactional accounting checks PASS again against the compact schema, covering partial/duplicate settlement, frozen prices, Plan-first allocation, member/shared limits, concurrent fund usage and request retries, verified grants, expired Plan and persistent purchased funds, anchored reset and old-period completion.
- 41 configuration checks PASS: Agency/member columns, fallback 10, inheritance, overrides, Owner exemption, inactive/removed/foreign users, stale and competing revisions, immutable prices, schema error and unchanged legacy usage/limits.
- 25 additional checks PASS using standalone Spring MVC with the real proxied services/JDBC: unchanged routes/JSON, nullable defaults, policy/member persistence in parent tables, explicit zero, validation 400, stale 409, Owner/member access rules 403, balance/derived usage and schema 503. Includes synchronized same-member/different-key reservations: one succeeds, one hits the personal ceiling, exactly one hold remains.
- The MVC harness injects an authenticated principal; it is not a JWT/Gateway/security-filter integration test. No real provider/payment calls or shared PostgreSQL/Atlas APPLY. Test scripts/classes remain ignored under Business target, never src.

## Compact SQL baseline verification — 2026-10-20

Supersedes the former eight-table schema for SQL/init. Full fresh init PASS on isolated PostgreSQL 17 (`brandhub-credit-compact-20261020`); 32 harness assertions (including grouped SQL assertions) PASS. Covers revised 19/10 then 20/10, repeat application, matching schema dumps for Agency/membership plus all four Credit tables, no Credit seed, missing-prerequisite rejection, and each of the four retired table guards against both deltas with marker data preserved and no columns added.

Also verified nullable inheritance/default revisions, explicit zero, negative limit/revision rejection, immutable price update/delete and duplicate version rejection, grant overdraw/allocation charge bounds, terminal-state null rejection, derived used/held and history surviving membership removal. The fixture price is test-only, not a product seed. No shared DB APPLY; no Business/API/concurrency certification for the pending compact-store refactor. Temporary script is ignored under Business target, not src.

## Verified implementation — 2026-10-20

- Isolated full Maven compilation PASS: 623 sources, using an ignored temporary POM with the real sourceDirectory to avoid IDE overwriting target/classes. Compile only, not application startup verification.
- 54 accounting checks PASS against real PostgreSQL 17 and Spring transactions: fallback 10, Owner bypass, zero ceiling, missing account/price, verified/idempotent grants, Plan-first allocation, partial/zero success, frozen prices, old-cycle settlement, monthly/leap boundaries, duplicate reservation concurrency and competing shared-fund reservations. Paid-plan missing/stale proof and duplicate full-period quota are rejected.
- Full fresh init PASS; five accounting table schema dumps match standalone delta applied to a baseline clone. Repeat delta PASS. This is scoped schema parity, not certification of unrelated historical init blocks.
- Earlier 19/10 configuration tests describe the historical pre-fallback behavior; 20/10 tests supersede the former unconfigured member-limit expectation with SYSTEM_DEFAULT=10.
- Temporary Java checks/build products live under ignored target only. No test source in src, no provider calls, no shared PostgreSQL/Atlas writes. HTTP security-filter E2E, AI dispatch/reconciliation and payment webhook integration remain pending.

## Accounting core additions — 2026-10-20

- Global fallback 10 only when no Agency default or override; zero is explicit. Owner remains unlimited personally.
- Anchored Jan 31 → Feb last day → Mar 31, leap years, period boundary inclusivity and future anchor rejected. No rollover; purchased grants survive subscription expiration. Holds from an old cycle settle against old usage, not the new personal limit.
- Reserve serializes on Agency account: concurrent calls cannot exceed funds/ceiling. Duplicate key/same fingerprint returns same reservation; changed operation/Workspace/units/payload rejected. Price revisions remain fixed after Admin edits.
- Settle 2/3 successful outputs charges exactly two units, releases remainder; duplicate identical settlement is a no-op, contradictory settlement fails. No public arbitrary settle/grant route. Unknown outcomes remain held; zero-success release does not infer a failed external call from timeout alone.
- New schema/init parity, constraints and repeated migration verified independently of existing legacy tables; full AI/Payment integration requires additional end-to-end checks.

## Configuration foundation

- Migration and fresh init yield identical new schema; migration repeat safe; old credit, Post, Task and Payment rows unchanged.
- Owner reads/sets own Agency default, including zero; missing configuration returns null/default revision zero, not invented balance.
- Owner sets member override; two stale concurrent edits cannot both win. Negative limit/revision rejected. Owner personal override rejected.
- Nonowner cannot change policy/member limits. Removed member and external Client cannot read internal member data. Soft-deleted Agency/disabled user denied. Owner target must be current member.
- Member reads own ceiling only; default source vs override source explicit. No new balance grants, AI calls or join record writes during reads.
- Nonadmin cannot edit prices. Unsupported operation/negative credits rejected; explicit zero allowed. First revision one; stale revision 409; every revision retained and concurrent edits serialized.
- No seeded prices and no implicit free request on missing/disabled price. Price API returns at most one latest row per known operation.
- Compile and diff whitespace checks; record actual results, do not infer API coverage from compilation.

## Later integration acceptance

## Configuration UI cases

- Owner sees null configuration as empty input, not zero; can save zero/positive whole value; negative/decimal/exponent/unsafe integer/blank rejected inline. Persist expectedRevision, not a user-editable revision field.
- One member selection fetches one effective limit; default source and override source distinct; changing selection never shows another member's cached form. Owner excluded from editable member list.
- Admin selects operation in one step, sees absent pricing state and can explicitly set enabled/disabled. Save returns version, old version remains server-side. No automatic fee on failed generation or units assumption in UI.
- Stale 409 retains input and requires explicit reload; schema 503 is actionable, no endless retry; other API failures do not render mock or zero balance. Route switching scopes data by user/Agency; no focus-driven form reset.
- Paths/sidebar correctly restricted to Owner/Admin; long names, 375/768/1440 widths, keyboard labels, dark/light and English/Vietnamese verified with fixtures. No real API writes in browser testing.

- Competing reservations cannot overspend shared funds or member ceiling; Owner bypasses only personal ceiling.
- Plan first then purchased funds; reset on authoritative subscription boundary, no Plan rollover, no purchased loss.
- Retry same idempotency key has same operation/price; changed payload rejected; explicit regeneration charged once more.
- Partial success charges exact successful units, duplicate/out-of-order completion safe; restart and late completion reconciled without free output/double charge.
- Revoked Workspace/Agency member and Client cannot generate/poll others' jobs; preview price matches locked request price.
- vi/en, light/dark, keyboard, mobile/tablet/desktop, real error states; fixture tests never mutate shared DB.

## Results

- Business offline Maven compile PASS after the new controller/service/store code. Existing GoogleOAuthService unchecked warning remains unrelated.
- 38 offline checks PASS: service-level Owner/Admin restrictions, own member reads, stale-write propagation, unsupported operation names, missing-schema error and Jakarta validation including explicit zero/negative/null fields. Mocked store; not DB/HTTP proof.
- 40 PostgreSQL checks PASS using the real JDBC store and Spring transaction proxy on PostgreSQL 17 Alpine, isolated `brandhub-credit-check-20261019`, no mounted project data. Covers missing/default/override/Owner state, external/inactive/removed users, optimistic conflicts, two concurrent policy changes and price changes (one wins/one 409), immutable historical prices and SQL nonnegative constraints. Legacy Agency usage 17 and creator limit 33 remained unchanged. Temporary fixtures are not product seed data.
- Full init ran successfully on an empty isolated database. New table schema dumps match init versus delta applied to a clone with just these new tables absent; repeat delta PASS. This is parity for the three new tables, not certification of unrelated historical duplicate init blocks.
- Local smoke sources/classes reside under ignored Business `target/credit-configuration-smoke/`, not `src` and not staged. No shared PostgreSQL/Atlas APPLY. No AI/Payment/Subscription behavior edits. HTTP security-filter/browser E2E and complete accounting remain pending.

### Configuration UI verification — 2026-10-19

- 33 main Playwright fixture checks PASS: blank/missing is not zero, Owner excluded from editable picker, no eager per-member requests, invalid input never submitted, explicit zero save, expectedRevision payloads, same-revision reload discards draft, 409 retains input/blocks stale retry/reloads current version, member override/default/switch, Admin price creation/operation switching, Owner route denial, schema 503 guidance and English labels. Four fixture PUT attempts (including intentional conflict), zero real DB writes.
- Eight additional browser checks PASS: Owner dark and Admin light at 375/768/1440, keyboard focus moves from amount to save, nonadmin rejected from Admin route. Combined with main run both pages captured light/dark across all three widths. Desktop Owner light and mobile Admin dark screenshots visually inspected.
- 11 numeric parser checks PASS (empty, negative, decimal, exponent, spaces, safe integer boundary, zero, leading zero and ordinary positive input); 44 vi/en locale keys have exact parity.
- Scoped ESLint, full app TypeScript and Vite production bundle PASS. Node config typecheck PASS. Existing bundle-size/Library ineffective dynamic import warnings remain; no unrelated fixes. Initial Vite sandbox EPERM resolved by approved local build execution, not dependency changes.
- UI/UX skill guided contextual labels/inline validation and responsive panels; React skill guided scoped server-state keys and event-driven saves. Existing theme/primitives retained. Browser artifacts/scripts are ignored under output/playwright and .playwright-cli, no src test files. No live backend/security-filter HTTP E2E or actual AI billing claimed.

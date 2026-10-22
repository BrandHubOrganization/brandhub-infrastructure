# Verification scenarios

## Existing test compatibility repair
The user explicitly authorized repair of the five existing test files that prevent `spring-boot:run` from passing its test-compile phase. Preserve Workspace coverage; replace obsolete implicit BASIC/calendar-ledger expectations with real funded Agency balances, member ceilings, held/settled reservations and replay recovery. Caption adapters delegate pricing to the unified engine; Video unknown outcomes remain held. Do not restore old production APIs, disable compilation, add new source test files, call live AI, or use the demo/Atlas databases. PostgreSQL tests require an explicitly selected isolated local test database.

### Repair results (2026-10-21)
- Updated existing `WorkspaceServiceTest`, `WorkspaceTimezoneConsistencyTest`, `AiCaptionServiceTest`, `AiCreditDatabaseTest`, and `AiVideoDatabaseTest`; no new source test files. No production code/POM/runner configuration changed by this repair. Preserved the pre-existing deletion of the obsolete `AiGenerationControllerTest`.
- Clean build with the repository POM: 639 main sources and all 145 test sources compile. No test-compilation bypass. Selected suite: 83 tests, zero failures/errors/skips (Workspace 42, timezone 18, Caption 10, Credit SQL 5, Video SQL 6, unchanged CaptionContext 2). This is not a full-suite or live-application-startup claim.
- PostgreSQL 17 container `brandhub-credit-test-repair-20261021`, loopback port 55439, database `brandhub_credit_test`, initialized from the current full `init-postgres-v2.sql`. Real SQL/transaction-proxied accounting and fake provider only; no Spring application context, seeders, Mongo/Atlas, demo database or live AI requests.
- SQL checks cover no implicit BASIC funds; actual grant funds; member ceiling/Owner exemption; frozen Admin prices; subscription-anchor period at the Vietnam month boundary; free operation versus explicit zero member limit; revoked membership; settled-result recovery after history-write failure with one provider dispatch; Video hold/settle/release and owner-scoped history; unknown/overdue/incomplete/mismatched Video results staying held; legacy refund exactly once without minting DA-974 funds.
- Reconciliation warnings for simulated lost/invalid provider outcomes are expected test fixtures. Existing GoogleOAuthService/AdminDemoSeederTest unchecked warnings, JVM Mockito agent warning and commons-logging warning remain non-fatal.
- Verified container ID, label and anonymous volume before removing only that disposable container/volume. Test fixtures are intentionally disposable; the SQL tests do not run by default without the opt-in environment. Build reports remain under ignored Business `target/`. No shared DB mutation, commit or push.

To reproduce, first initialize a **disposable local** PostgreSQL test database using the current init, then set process-local variables in PowerShell (never point these at demo/shared data):

```powershell
$env:ADMIN_TEST_DB_URL="jdbc:postgresql://127.0.0.1:55439/brandhub_credit_test"
$env:ADMIN_TEST_DB_USER="<test database user>"
$env:ADMIN_TEST_DB_PASSWORD="<test database password>"
$env:CREDIT_TEST_DB_DISPOSABLE="true"
mvn.cmd -o "-Dtest=WorkspaceServiceTest,WorkspaceTimezoneConsistencyTest,AiCaptionServiceTest,AiCreditDatabaseTest,AiVideoDatabaseTest,CaptionContextServiceTest" clean test
```

Run from Business repository. The database tests reject non-loopback URLs, database names not ending `_test`, absent credentials, and missing disposable acknowledgement before fixture writes. They append immutable global test prices and retain financial fixture rows, so discard the entire test database after the run; do not use a shared test instance or parallel runs. Normal `spring-boot:run` requires none of these test environment variables.

## Financial behavior
- Missing/disabled price, missing account, insufficient balance, explicit zero member ceiling, Client/revoked/foreign membership all stop before provider dispatch. Owner bypasses only personal ceiling.
- Caption generate/refine/adapt share CAPTION_VARIANTS and charge one request, including multiple adapted platforms. Explicit free price works.
- Retry/concurrent same key dispatch once, reuse history ID and frozen price. Cross-action or changed request key reuse conflicts. Changing brand/context after success does not regenerate or duplicate history.
- Valid sync output charges once; unusable output/authoritative rejection releases; timeout/unknown remains held. Persistence failure after upstream result recovers from stored output.
- New Video pending holds funds, COMPLETED with URL settles once, FAILED releases once; timeout/missing job remains held. Worker and browser polling cannot double settle. Unauthorized job access denied.
- Legacy Video finishing/refunding does not create DA-974 grants or charges; no new legacy charges.

## Schema/reporting/Web
- Additive delta applies twice, preserves legacy rows and enforces exclusive job accounting references. Fresh init and upgraded schema match scoped columns/indexes/constraints.
- Workspace balance uses available funds minus personal used/held, not seeded legacy quota. Dashboard reports subscription period explicitly; deprecated calendar-month field stays calendar-month scoped. Unconfigured credit does not break unrelated dashboard panels or become fake zero.
- All billable service calls carry explicit Workspace and stable retry key; status/style/history/choice/trend-fit remain free. User-scoped cache invalidation, Vietnamese/English labels and existing light/dark/mobile layout remain correct.

## Execution record
### 2026-10-21
- Full isolated Maven compilation: PASS, 639 main sources. Existing GoogleOAuthService unchecked warning remains. Temporary POM/classes/tests reside under ignored Business target/credit-unification-check, not src. No application startup or full upstream test-suite claim.
- 17 JUnit integration scenarios PASS against real PostgreSQL 17 and transaction-proxied DA-974 services with fake AI: Caption context/price/history replay; shared Refine/Adapt price and cross-action conflicts; missing key/changed payload; disabled prices/zero ceiling/revocation/foreign actors; Owner/shared limit/explicit free price; unusable output/rejection/unknown outcome; concurrent same-key one dispatch; Video held/frozen charge/ownership; timeout held then definite failure; legacy one-time refund; unified balance/Dashboard ignoring old seeded usage; bigint history/Client rejection; history-write crash recovery; standalone MVC 400/200/202 contract; all seven generic adapters; competing requests under one personal ceiling; FK/unique/exclusive-source SQL constraints. No actual provider calls. Expected fixture timeout warning is intentional.
- Full fresh init and upgraded pre-change init + new delta PASS on separate databases in the dedicated container. New delta repeat application twice PASS. pg_dump schema-only for ai_video_jobs/ai_caption_generations is identical across fresh/upgraded databases (normalized only random dump restrict markers). No old migration edited.
- Web app/node TypeScript and production build PASS. Scoped ESLint: zero errors, two pre-existing Dashboard set-state-in-effect warnings. Existing bundle-size/Library ineffective-import warnings remain; no dependency changes. Sandbox blocked native Vite/Tailwind initially; approved local execution succeeded.
- 21 Playwright CLI fixture assertions PASS: correct period label, no deprecated calendar total shown, four deliberate actions + one real Axios 401-refresh retry, stable retry key/distinct action keys/Workspace header, originating-user cache invalidation, vi/en × light/dark × 375/768/1440 labels, unavailable not zero, no uncaught page errors. Card screenshots captured at all twelve combinations; Vietnamese dark mobile and English light desktop inspected. Period helper wraps instead of truncating. Fixture routes intercept backend/remote requests; no real API writes. Expected mocked 401 logs are not application failures.
- User-scope React guidance kept shared invalidation/request helpers; UI/UX guidance produced explicit unavailable feedback and readable period bounds without a new design system. Playwright sources/screenshots/logs stay ignored under output/playwright/.playwright-cli. No executable test files were added under src, staged or committed.
- Cleanup: verified the dedicated PostgreSQL container ID/mount, then removed only that container and its anonymous test volume. Closed the named browser fixture session and stopped the temporary Vite server. Existing demo containers/volumes and unrelated worktree changes were preserved.
- Read-only local application DB audit: zero open legacy Video jobs; Content=3/Ambassador=10 only; five other prices missing; new delta absent. No application DB/Atlas APPLY, seed, funding conversion, paid AI request, commit or push. Runtime JWT/Gateway/provider cutover remains a separate live acceptance step; see rollout.md.

### Authorized local APPLY — 2026-10-21 (after implementation verification)
User requested PostgreSQL migrations and confirmed writers stopped. Verified port 8081 no longer listening and no other database sessions. Ran unchanged `2026-10-21-unified-ai-credit.sql` on `brandhub-postgres`, database/schema `brandhub.public`, ON_ERROR_STOP enabled: COMMIT. Only this delta was missing in the Credit scope.

Postchecks PASS: `ai_caption_generations.credits=bigint`, `ai_video_jobs.reservation_id=uuid/nullable`, both new constraints validated and unique partial index valid. Business integration schema readiness=true; explicit pre/post data comparison=true. Existing sole DEV_SEED grant remains amount 100 / used 0 / held 0; Caption, Video, reservation, allocation and legacy usage counts remain zero. No init/seed/price configuration, data deletion, Atlas mutation or automatic Business startup. Real provider/JWT/Gateway acceptance remains pending.

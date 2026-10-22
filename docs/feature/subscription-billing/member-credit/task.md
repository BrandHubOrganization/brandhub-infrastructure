# Member credit checklist

## AI integration slice

- [x] Add reservation execution metadata delta/init and verify repeat/parity.
- [x] Enforce reserve/claim/replay/settle for all seven adapters and scoped video polling/reconciliation.
- [x] Require existing internal key on AI hashtag route; no direct browser/provider bypass.
- [x] Web context/idempotency, translated errors, report invalidation; vi/en and existing themes.
- [x] Isolated provider/JDBC checks; compile/typecheck/lint and record limitations.
- [x] Confirm Agency and seed authorized 100 local development credits; do not invent prices/payments.

## Web reporting slice

- [x] Extend typed service and user/Agency-scoped reporting/context hooks; invalidate inherited data after configuration changes.
- [x] Owner balance and selected-member usage/configuration; no eager member fan-out.
- [x] Manager/Creator own usage, ceiling source and read-only pricing; actual Agency ownership gate.
- [x] Explicit operation units, compact help, inline validation and fresh-value reload.
- [x] Update vi/en credit locales in parallel and verify light/dark mode.
- [x] Browser fixture checks at 375/768/1440, permission/cache/error checks, scoped lint, typecheck and build; no src test files or shared writes.

## Compact schema follow-up

- [x] Revise 19/10 and 20/10 SQL and matching init to four independent Credit tables.
- [x] Document old-draft stop guard and no automatic data deletion/conversion.
- [x] Refactor Business stores/services to Agency/member columns, Agency locking and derived period usage.
- [x] Retest Business accounting/concurrency against the compact schema before deployment (54 accounting, 41 configuration, 25 standalone MVC checks; no Gateway/JWT E2E).

Earlier checked implementation items below refer to the former schema; see [compact-schema.md](compact-schema.md).

- [x] Read BA, FR 3.9.5–7, payment spec, AI alignment, schema and current code.
- [x] Capture confirmed decisions and open multi-Agency/expiry/default questions.
- [x] Add configuration migration and matching init blocks without changing old tables.
- [x] Implement authorized/revision-checked policy, member override and versioned price APIs.
- [x] Compile and verify isolated schema/configuration behavior (38 offline + 40 PostgreSQL checks; full HTTP/UI not yet verified).
- [ ] Resolve balance ownership and lifecycle BA; finalize grant/reservation schema.
  - [x] Confirm fallback 10, billable units and continued monthly reset (2026-10-20).
  - [x] Implement calendar period calculation, default fallback and accounting schema/core.
  - [x] Server-only verified grant handoff and Owner/member usage read APIs.
  - [x] 54 isolated PostgreSQL accounting checks; accounting init/delta parity and repeat migration.
- [ ] Implement period grants, accounting, reservation/settlement/reconciliation and reporting.
- [ ] Integrate all approved AI generation routes and payment handoff contract.
- [x] Owner/member/Admin UI, parallel vi/en locales and light/dark verification (reporting/configuration scope, not live AI/payment integration).
  - [x] Owner configuration page and Admin price page with real service adapters.
  - [x] Parallel vi/en labels; keyboard, light/dark and 375/768/1440 responsive checks.
  - [x] Pending integration notice, missing migration/error recovery, no balance mock.
  - [x] Member self-service tracking/reporting UI connected to real reporting adapters (fixture verified; live billing/provider integration remains pending).
- [ ] Full concurrency, security, retry, partial completion and browser verification.

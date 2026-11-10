# Plan - FR 3.5.3

## Scope

Implement E50-04 negotiation requests/counter-offers without replacing the selected package.

## Plan

1. Add `terms_version` plus append-only negotiation-event migration and V2 init update.
2. Implement request-change, counter-offer, and history read endpoints with role/state checks.
3. In the same transaction, update current terms, increment version, and invalidate both approvals.
4. Test multi-round immutable history and approval invalidation.

## Phase 5 implementation detail

- Add new SQL migration and matching init table with UUID PK, selection FK CASCADE,
  terms_version, action/actor_role/actor_id/note/terms_snapshot/created_at, unique
  (workspace_media_package_id,terms_version), version-desc paging index. Trigger
  blocks direct mutations; parent cascade deletion remains compatible.
- Backfill BASELINE only if non-DRAFT; insert-if-no-events,
  lock selections during maintenance migration. Do not mutate selection data.
- Immutable JPA entity + insert-only EntityManager store (no public save/delete
  repository), pageable read repository. Writer must join selection JPA transaction.
  Capture baseline before replacing terms; append after count/version/reset changes.
- Add history scoped service/controller and API DTOs. Reuse Workspace permission
  service but explicitly restrict history roles. No dependency on Mongo.
- Extend negotiation DTO with required expectedTermsVersion + optional note; use
  explicit-version convenience constructors and require HTTP validation.
  Approve gets validated body; service checks version under row lock even when approved.
- DRAFT package replacement advances termsVersion and resets approvals/count, never
  reuses a previous version. No baseline created until first negotiation.
- Web typed client, modal note + fixed version captured when editing starts; approve
  always sends displayed version. 409 preserves input, prompts close/reload.
- Add feature hook/components, reuse PackageTermsDiff, parallel locales
  `src/i18n/locales/{vi,en}/mediaPackage.json`; no new global providers/styles.
- Regression Package/Campaign/Request unit tests + isolated PostgreSQL transaction,
  immutability/rerun/schema tests and browser fixture. Shared writes/migrations and
  live Gateway smoke remain operator steps. No seed accounts, no commit/push.

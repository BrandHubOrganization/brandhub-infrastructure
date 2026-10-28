# Remove Material — Implementation Plan
Input: user-supplied spec-before-planning/remove-material-repository.md, FR 3.6.14.
1. Expand Mongo tombstone/lease/retry fields and validator/index migration (no TTL).
2. Implement scoped CAS delete/restore, Trash count/page/filter, optional version,
   current ancestor ACL, durable Mongo audit outbox. No storage/quota calls on mutations.
3. Keep existing pinned Post and derivative reads functional after soft deletion.
4. Check Post key/ID, Task linkage/input references, derivative and durable pins;
   atomic irreversible claim, token fencing, retries. Route by stored provider.
5. Release quota using a PG unique material receipt + usage delta in one transaction;
   reconcile receipt/Mongo completion and report mismatches without rewriting counters.
6. Replace mocked Media data with API-backed Library and Trash views; shared controls,
   accessible confirmation/cancel focus, undo, quota-neutral restore, stale context guard.
   Locales: src/i18n/locales/vi/library.json and en/library.json, semantic theme tokens.
7. Test public mutation/worker/UI seams from spec section 13; typecheck, full suites,
   two-axis code-review against captured initial HEAD, fix findings, commit per repo.
Risk: cross-store failure; receipt/outbox replay. Purge default disabled, no live migration.

## Rollout / recovery
- Stage `docs/database/migrations/2026-10-25-material-trash.sql` after the repository
  PostgreSQL foundation. Stage `2026-10-25-material-trash.js` after the Mongo
  foundation. The JS script defaults to dry-run and requires explicit APPLY and
  WRITERS_PAUSED flags. Do not rerun an older foundation validator after this expansion.
- Verify replica-set transactions, migration indexes, no TTL on materials retention
  fields, known provider/key/size identities and complete reference inventory first.
- `REPOSITORY_PURGE_ENABLED=false` and `REPOSITORY_REFERENCE_INVENTORY_VERIFIED=false`
  are the shipped defaults. Enable only after inventory and provider validation.
  Existing persisted provider names remain SYSTEM_GDRIVE/SYSTEM_S3; unknown/legacy
  providers are blocked rather than guessed. No live data or storage migration was run.
- Provider purge currently requires GetBucketVersioning proof of an unversioned bucket.
  Enabled/suspended versioning or unsupported capability calls fail closed and retain
  quota. Versioned-object cleanup needs a separately verified provider implementation.
- Claims survive restore attempts and lease expiry. On provider/PG failures leave
  tombstones intact and let the same immutable object identity retry. Do not reset
  PURGE_IN_PROGRESS to READY manually. PG receipts prevent repeated quota subtraction.
- Monitor material_purge_pending, material_audit_delivery_pending, material_quota_ack_pending,
  material_usage_drift. Reconciliation compares Mongo used totals and PG reservations;
  it reports discrepancies and does not overwrite counters from an uncertain inventory.
- Roll back by disabling purge. Preserve already claimed/deleted objects' checkpoints,
  release receipts and audit outbox so pending accounting can finish safely.

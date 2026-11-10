# Plan

1. Record local PostgreSQL identity and existing content/job counts; create a custom-format backup.
2. Restore it into an isolated disposable local verification database. Apply the exact six Subscription/Workspace Credit baseline sections copied from current init SQL, not the whole init script.
3. Apply a transaction-scoped, Agency-locked seed: reviewed Basic account, verified empty opening wallet, 5,000 DEV_SEED credits plus GRANT operation, entry and audit. Use a stable source key; refuse incompatible state.
4. Verify schema, accounting invariants, preservation and idempotency in the verification database.
5. Prefer a stopped matching Business during schema application. Runtime discovery found a replacement Business launched from `_wt/be-trend-boards`; preserve that active worktree. Its six credit reader/writer/schema classes are byte-for-byte identical to the reviewed code, and it uses this same local DB with profile dev. With no active video or credit jobs, use the tested additive expansion with bounded DDL locks, then the Agency-locked seed. All wallets stay PENDING until the complete target seed transaction commits, preventing dispatch through partially installed credit schema. Take another consistent pg_dump snapshot immediately before application. Never stop an unrelated shell or replace the other worktree's runtime.
6. Verify the live balance on the matching running build and preserve the receipt/backup paths. Do not change pricing or fund unrelated agencies.

Rollback: before any new consumption, the verified backup permits full restoration with Business stopped and explicit review; after consumption, use compensating ledger entries rather than deleting immutable history. No automatic destructive rollback or schema contraction.

# Verification

- Backup is nonempty and `pg_restore --list` succeeds.
- Trial restore preserves the 10 existing caption generations and 1 failed video job.
- Baseline application succeeds; repeated baselines skip safely.
- Target Basic subscription is READY and active; opening wallet is VERIFIED. Other agencies stay pending review.
- Exactly one DEV_SEED grant is issued for the stable source key, with amount 5,000; wallet available/reserved match grants and ledger entry sums.
- Repeating the seed leaves wallet/grant/GRANT-operation/entry/audit counts and amounts unchanged.
- No order, payment or fabricated price is created.
- Current Business becomes healthy; authenticated target workspace credit endpoint reports 5,000 available.
- If an active replacement worktree is retained: verify matching credit classes and local datasource/profile, no active Video jobs before applying, bounded DDL timeouts and PENDING opening wallets until seed completes.

## Results — 2026-11-05

- Custom-format local backup validated and restored into an isolated verification DB. Latest pre-apply backup: `.tmp/credit-seed-20261105/brandhub-before-apply.dump`, SHA256 `7121C21CA6BB2FF56E1061EB17066DB2456567C4F24DE2F5B6FB5317A599762F`.
- Six baseline sections and the guarded seed passed on the restored copy. Repeating both baselines and seed passed without duplicate credit.
- Applied to local `brandhub-postgres/brandhub` only. Target Basic account READY, wallet VERIFIED, available 5,000 and reserved 0.
- Grant available = wallet available = sum of ledger available entries = 5,000. Exactly one seed grant and one GRANT operation. Repeated local seed did not add credit.
- Existing 10 caption generations and 1 failed video job preserved. Orders, payments and operation prices remain zero. The other 49 Agencies remain REVIEW_REQUIRED.
- Live Business worktree `_wt/be-trend-boards` had identical six credit schema/reader/writer classes and used the same local datasource/dev profile. It was retained during bounded additive application; no new runtime replaced it.
- Authenticated normal Quick Login through Gateway succeeded. Both `/billing/agencies/.../credits/summary?workspaceId=...` and `/workspaces/.../ai/credits` returned 5,000 for the target Creator workspace (see `.tmp/credit-seed-20261105/live-api-verification.json`). Tokens were kept in memory only.
- Native UI was blank and active input interrupted navigation, so UI balance rendering was not verified. No model/provider call, generated caption or payment was made by this seed.
- No operation price was invented; paid operations still require Admin pricing.

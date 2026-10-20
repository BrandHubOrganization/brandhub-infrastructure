# Local PostgreSQL migration audit — 2026-10-19

**Remediation update:** the user subsequently authorized applying the three gaps below. They were applied and verified on local PostgreSQL on 2026-10-19. The audit sections preserve the original observations; see the application receipt at the end for the current state.

## Scope and conclusion

Target confirmed by the user: local container `brandhub-postgres`, database/user `brandhub`, PostgreSQL 17.10.
**The current local schema does not contain all required migration effects.** There is no schema migration ledger, so this report verifies current effects, not the historical execution of each file.

All queries against the working database enforced `default_transaction_read_only=on` and a 20-second statement timeout. No migration, data cleanup or repair was applied to it. The reference schema was initialized separately in an ephemeral PostgreSQL 17 container from the current working-tree `init-postgres-v2.sql`.

The earlier seed regression tests also used disposable databases; they did not upgrade this working database.

## Required gaps

| Finding | Observed locally | Expected source/effect | Consequence |
| --- | --- | --- | --- |
| Missing seed-run metadata | `public.seed_runs` does not exist | `migrations/2026-10-19-postgres-demo-seed-runs.sql`: marker table with dataset/version, run ID, state, counts and manifest | The new PostgreSQL seed runner cannot use its marker on this database. Creating the marker alone will not adopt legacy demo data. |
| Working-language width drift | `users.working_language` is `varchar(10)` | Archived `2026-09-27-widen-user-working-language.sql` and current baseline require `varchar(50)` | Current schema is missing or has lost the widening effect. Entity `User.java` still declares length 10, and `application.yml` enables `ddl-auto: update`; align the entity and schema together. Historical execution cannot be inferred from the current width. |
| Partial negotiation-history upgrade | Table, uniqueness, history index and append-only triggers exist; actor/action CHECK and JSON-object snapshot CHECK are absent | Current `2026-10-13-package-negotiation-history.sql` and baseline define both CHECKs | Current rows are valid, but the database does not enforce both intended checks. Replaying this file will not add them: its table definition uses `CREATE TABLE IF NOT EXISTS`. A targeted additive ALTER migration is needed. |

The absent negotiation CHECKs are `package_negotiation_events_check` (action/actor correspondence) and `package_negotiation_events_terms_snapshot_check` (`jsonb_typeof(terms_snapshot) = 'object'`). There are three existing history rows; read-only preflight found zero invalid snapshots and zero invalid actor/action records.

## Current SQL files

`migrations/` contains eight current SQL scripts. `MATCH` below means observed effects match; it does not prove the script itself was executed.

| SQL file | Current effect | Evidence |
| --- | --- | --- |
| `2026-10-13-package-negotiation-history.sql` | PARTIAL | History/index/uniqueness/append-only trigger exist, no non-draft agreement lacks history, but two CHECKs are missing. |
| `2026-10-13-partner-directory-lifecycle.sql` | MATCH | Four lifecycle columns, legacy default `usage_history_verified=false`, enabled guard trigger and its function match. No linked partner is missing `first_used_at`. |
| `2026-10-14-content-request-completion.sql` | MATCH | Completion-job table has required columns, primary key and cascading Campaign/Workspace foreign keys. |
| `2026-10-14-content-request-completion-jobs.sql` | MATCH | Completion table and `idx_content_req_completion_jobs_created` exist. |
| `2026-10-16-remove-media-package-classification.sql` | MATCH | Neither retired package column exists; native `public.package_type` is absent. The separate generated enum `packagetype` is not the type targeted by this migration. |
| `2026-10-18-link-real-user-to-3-agencies.sql` | CURRENT DATA MATCH | Target account exists; three CLIENT links exist and all three currently selected agencies have the expected link. Do not rerun this data/role-changing operation merely to establish history. |
| `2026-10-18-reduce-seed-users-to-30.sql` | CURRENT DATA MATCH | 30 users, 4 agencies, 10 workspaces; no user currently falls outside the script's preserved-account predicate. Counts do not prove historical deletion. This is cleanup, not a routine startup migration. |
| `2026-10-19-postgres-demo-seed-runs.sql` | MISSING | Marker table absent. |

## Baseline and archived effects

The archive contains 39 SQL files. Per `migrations/README.md`, these are history incorporated into the baseline, not a pending queue to replay. Later changes supersede older ones: for example, old offering-model scripts would restore fields that current code removed.

Comparison with a freshly initialized reference database found:

- 52 local tables versus 53 reference tables. The only missing table is `seed_runs`; all 11 missing baseline columns belong to it.
- Every other baseline table/column exists. Types, nullability and defaults match except the VARCHAR width differences listed below.
- Every non-seed-run baseline index has a logically equivalent local index. The negotiation uniqueness index has a different name, with the same key and uniqueness; it is not missing.
- All 19 baseline triggers exist with matching definitions. No public constraint is awaiting validation.
- `terms_version > 0` locally is equivalent to baseline `terms_version >= 1` for the integer column. Monitoring CHECKs have equivalent permitted values despite different cast formatting. These are not reported as missing migrations.
- Retired PostgreSQL `tasks` currently has zero rows. Campaign deployment/review/version tables, workspace hashtags, mail tables, activation/plan-change tables and baseline monitoring tables are present.

### Additional VARCHAR width drift

These differences do not prove migrations were never executed. They show the database is not identical to the current baseline and should be reconciled with entity mappings before changing DDL.

| Columns | Current width | Baseline width |
| --- | --- | --- |
| `users.working_language` | 10 | 50 |
| `monitoring_health_results.outcome` | 255 | 5 |
| `monitoring_health_results.reason_code` | 255 | 80 |
| `monitoring_health_results.runtime_state`, `runtime_health` | 255 | 30 |
| `monitoring_health_targets.kind` | 255 | 20 |
| `monitoring_health_targets.environment`, `monitoring_servers.environment` | 255 | 50 |
| `monitoring_health_targets.service_name`, `check_scope` | 255 | 100 |
| `monitoring_health_targets.probe_type` | 255 | 30 |
| `agencies.logo_url`, `banner_url`; `workspaces.banner_url`; `transactions.failed_reason`; `users.password_hash`, `avatar_url`, `linkedin_url`, `facebook_url`, `instagram_url`, `tiktok_url`, `website`, `banner_url` | 255 | Unbounded VARCHAR |

## Verification limits and next steps

1. Prepare the missing marker migration for the working database. Legacy users already exist, so the demo seeder will still refuse automatic adoption; do not reset the database or marker to force a run.
2. Correct the working-language entity declaration and apply a reviewed widening delta.
3. Add the two negotiation CHECKs through a reviewed incremental migration after validating existing rows. Merely re-running the CREATE-IF-NOT-EXISTS script cannot repair this drift.
4. Keep cleanup and account-linking scripts out of any automatic migration glob. Do not run `init-postgres-v2.sql` or the entire archive against this existing database to try to repair individual gaps.

No local MongoDB container is running. Mongo `.js` migrations and Atlas state were not validated by this PostgreSQL audit; the historical Atlas receipts in documentation are not a current live check.

Local schema snapshots used for comparison are in the ignored business-service `target/` directory: `postgres-migration-catalog.json` and `postgres-migration-reference.json`. They contain schema metadata, not row dumps. The temporary reference container is removed after the audit.

## Authorized application receipt — 2026-10-19

- Target rechecked: `brandhub-postgres`, database/user `brandhub`, PostgreSQL 17.10.
- Full custom-format backup: `D:\capstone\brandhub\.local-backups\postgres-schema-gaps-20261019-apply\brandhub-before.dump` (227,865 bytes). `pg_restore --list` succeeded. Container and copied-file SHA-256 match: `6d5e0ce6255128836d087eb3143e4145251ed80cb733d11aa9ef8feadc73bc59`.
- Applied existing `2026-10-19-postgres-demo-seed-runs.sql` and new `2026-10-19-repair-profile-negotiation-schema.sql` together using `psql --single-transaction -v ON_ERROR_STOP=1`, public search path, 5-second lock timeout and 60-second statement timeout. Transaction succeeded.
- Postconditions: `users.working_language` has length 50; `seed_runs` exists, is empty and has validated primary/unique/CHECK constraints; both negotiation CHECKs exist and are validated. No invalid history rows were found.
- Row counts of all 52 pre-existing public tables match the preflight. User and negotiation-history content fingerprints are identical. No cleanup, data backfill or adoption of the old demo dataset was performed.
- Reapplied both additive SQL scripts once to verify rerun behavior: schema checks, all row counts and both content fingerprints remained unchanged.
- `User.java` now declares working-language length 50. `mvn -DskipTests compile` succeeded at 16:29 +07:00 on 2026-10-19. Run/rebuild the application from this updated source; old binaries still contain the old declaration.
- Before/after evidence, rerun evidence, query SQL and archive inventory are stored beside the backup as `before.json`, `after.json`, `after-rerun.json`, `schema-postconditions.sql` and `archive-list.txt`.
- Other VARCHAR differences described by the original audit were outside these three repairs. MongoDB state remains unverified. No schema migration ledger was introduced; `seed_runs` records demo runs, not schema migration history.

Recovery: the DDL transaction would roll back automatically on failure; it committed successfully. Keep the backup. Inspect or restore the archive into a separately created empty database first if recovery becomes necessary; restoring the working database would replace data and is not part of this application.

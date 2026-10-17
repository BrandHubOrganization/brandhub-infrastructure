# Remove legacy Media Package classifications — 2026-10-16

For a clean database, run ONLY the updated `docs/database/init-postgres-v2.sql` baseline. Do not replay migration history after init.

For an existing older database only, deploy current Business/Web and run `migrations/2026-10-16-remove-media-package-classification.sql` together with Business stopped. The already-migrated local database does not need another run.

Scope: drop only media_packages.package_type, media_packages.offering_model and unused native enum package_type. Keep all rows, IDs, FKs, budgets, durations, quantities, agreed terms and Campaign/history snapshots. No Mongo migration.

The migration is transactional, rerunnable and uses RESTRICT, not CASCADE. Unexpected external dependencies or lock contention abort it. Inspect your own database before running; the local verification is not evidence about shared environments.

The retired `2026-10-06-media-package-offering-model.sql` is archived in `migrations/old_migration/` by develop; never recursively execute that directory on the new baseline. The old `2026-10-07-refresh-admin-media-templates.sql` seed and duplicate `scripts/init-postgres-v2.sql` were deleted by develop. Do not restore them from a stash. Fresh installations use the canonical init and updated Java seeder.

Legacy JSON snapshot keys remain read-only historical data. The legacy RETAINER/non-TOTAL Campaign guard remains intentionally; removing catalogue columns does not authorize rewriting monthly agreements.

After apply: verify columns and enum absent, unchanged package/Workspace agreement/Campaign counts and unchanged non-classification content; restart the newly built Business Service, not an old jar. Old service versions cannot run against the new schema.

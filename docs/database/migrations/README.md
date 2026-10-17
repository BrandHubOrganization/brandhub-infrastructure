# Migration entry points

- Fresh PostgreSQL database: run `../init-postgres-v2.sql` only, then the current seeder if needed. Do not replay historical SQL afterward.
- Fresh Mongo database: `../init-mongo.js` only. Never init existing Atlas data.
- Existing databases: inspect current schema and apply only missing, applicable deltas. SQL and Mongo scripts are different entry points; no recursive all-files runner.
- `old_migration/` is archived history already incorporated into the team's baseline. Do not include it in migration globs or recursively execute it. In particular, the old offering-model SQL reintroduces a retired column.
- `2026-10-16-remove-media-package-classification.sql` is only for old PostgreSQL databases that still contain package_type/offering_model; new init does not introduce those fields.
- Mongo metadata checker is read-only and compares schema effects, not proof of historical execution. Run metadata migrations in DRY_RUN first; shared environments need explicit APPLY.

See [Media Package baseline](../media-package-classification-removal.md) for rollout and compatibility boundaries.

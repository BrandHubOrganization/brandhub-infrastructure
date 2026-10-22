# Local application receipt — 2026-10-20

User explicitly authorized applying the migration after isolated verification.

- Target verified: local Docker container `brandhub-postgres`, database/user `brandhub`, PostgreSQL 17.10.
- Prerequisites already applied: `20261020_agency_subscription_expand_v1`, `20261020_payos_to_seepay_v1`.
- Applied `docs/database/migrations/2026-10-20-four-plan-catalog.sql` in one transaction; COMMIT succeeded.
- Registry entry: `20261020_four_plan_catalog_v1`, applied at `2026-10-20 08:38:55.944182+00`.
- Catalog now contains PERSONAL/USER, BASIC/AGENCY, PLUS/AGENCY and ENTERPRISE/AGENCY, all version 1. Only the missing Personal row was inserted; three existing versions were preserved.
- Personal, Plus and Enterprise remain unsellable with unknown prices. Basic remains free and sellable.
- All three Agency scope foreign-key constraints are validated.
- Before/after normalized catalog values and subscription/order/period content fingerprints are identical, excluding newly added scope columns and the newly inserted Personal row. Four existing subscriptions remain unchanged; order/period counts remain zero.
- No UI/API deployment or sale activation was performed as part of this database application.

## Backup and evidence

Full custom-format database backup and before/after fingerprints:
`D:\capstone\brandhub\.local-backups\four-plan-catalog-20261020-153846\`.

Backup: `brandhub-before.dump`; `pg_restore --list` succeeded and container/copied-file SHA-256 matched:
`a7fe5cba960c50b3ddaf630d04d0be5d95d69581d013e586d239cf708c24fcf7`.

Evidence files: `backup.sha256`, `snapshot.sql`, `before.json`, `after.json`.

The migration transaction has committed. Recovery, if needed, should first restore the backup into a separate database for inspection; replacing the running database requires a separate recovery decision.

# Verification

Status: PASS, 20/10/2026. Executed `docs/database/migrations/tests/verify-four-plan-catalog.ps1` against an isolated PostgreSQL 17 Docker container. All checks below passed; the container was removed. No BrandHub runtime database was accessed.

Subsequent authorized local application: migration committed successfully to `brandhub-postgres/brandhub` on 20/10/2026. Four plans and validated scope FKs were verified; existing catalog and billing fingerprints were preserved. See [application receipt](application-receipt.md) for backup and execution evidence.

- Applying after base schema yields exactly four version-1 codes, three AGENCY and one USER.
- Existing plan IDs, prices, quotas and sale flags stay unchanged, including configured paid rows.
- Personal has NULL price, is_sellable=false, zero agency workspace/client allowances and the proposed personal feature quotas.
- Applying twice leaves the catalog and migration registry unchanged on replay.
- Assigning Personal to an Agency subscription, order or period fails with a foreign-key violation; Agency plans are accepted.
- Plan mutation remains forbidden by the existing immutable trigger; sale flag updates remain supported.
- Missing prerequisite fails without inserting migration metadata or plan rows.
- Injected failure after DDL and seeding rolls back new scope columns, Personal row and migration marker; existing plan versions remain unchanged.
- The full base and follow-up migrations run on schema-only export DDL with no copied production data.

# Verification

- Custom-format backup can be read by pg_restore --list.
- PostgreSQL reports users.working_language as varchar(50), seed_runs as present with its primary/unique/check constraints, both history CHECKs as validated, and seed_runs empty.
- Existing public table counts and MD5 content fingerprints for users/history match before/after. Fingerprints are comparisons, not backup integrity guarantees.
- Reapplying the additive DDL preserves data and schema effects.
- Maven compilation passes after the entity annotation change.

No application or dataset seeding is part of this operation.

## Results — 2026-10-19

All verification cases passed on local PostgreSQL 17.10. The archive is readable and its SHA-256 matches the container copy. All 52 existing table counts and both content fingerprints stayed unchanged. The marker table is empty; its constraints and both negotiation CHECKs are validated. Both SQL files were successfully reapplied with identical postconditions. Java compilation passed. Full receipt and backup/evidence paths are recorded in `docs/database/migration-audit-local-2026-10-19.md`.

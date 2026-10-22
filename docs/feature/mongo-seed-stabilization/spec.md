# Mongo seeder schema compatibility

## Objective

Keep shared Business seeders compatible with the current Mongo Task/Request
schema. Fresh seeds must not fabricate workflow history or silently overwrite
existing Tasks.

## Acceptance criteria

- New sample Tasks are unassigned TODO drafts with initialized workflow metadata.
- Existing Workspace Tasks are preserved, including default-named drafts.
- Content Request samples are omitted unless a real Client and deployed Campaign
  workflow can provide valid evidence; do not invent approval/source history.
- MongoDataSeeder validates required collections, validators and unique indexes
  before inserting data, and propagates missing-schema failures.
- Shared init/migrations remain the source of schema. Seeders do not apply DDL.
- No UI/i18n/theme change. Publishing and PostgreSQL behavior remain unchanged.

## Out of scope

Machine-specific repair scripts, fixed-ID resets/deletions, local funding and
Playground experiments are not distributed or committed. Keep them in ignored
.local/ storage, not in shared migration entry points.

# Plan - FR 3.5.1

## Scope

Implement E50-01 on the existing V2 PostgreSQL model: read templates and create Agency-scoped custom packages.

## Plan

1. Verify `media_packages.agency_id`, check constraint, and indexes in a new migration plus `init-postgres-v2.sql`.
2. Add package repository/service with global-template filtering, optional template provenance, availability filtering, and Agency Owner validation.
3. Add template-list, Agency package, and availability endpoints with role and input validation.
4. Add integration tests for template visibility, Agency scoping, and invalid Agency.
5. Add an Agency-scoped Owner management page for persisted custom packages and global-template reference.
6. Add a separate workspace-scoped Client catalogue containing only available packages from the same Agency.
7. Register distinct Agency/Workspace route-access rules and sidebar items, and add key-parallel
   `src/i18n/locales/{vi,en}/mediaPackage.json` locale files.
8. Verify responsive layouts, light/dark theme tokens, lint, TypeScript, and production build.

## Dependencies

Agency must exist (DA-E16-05).

## E50-02 selection subplan

1. Client selects an available Agency package for the Workspace; global templates are never directly selectable.
2. First selection creates `workspace_media_packages` and snapshots source terms into `final_terms` at version 1.
3. Before the first negotiation event, replacement updates the same workspace-package record, snapshots the replacement terms, and clears approvals; after negotiation starts it returns a conflict.
4. First selection returns `201`; a permitted replacement returns `200`.
5. Keep the reminder delay/cadence configurable until the business value for `X` days is confirmed.
6. Show an immediate dashboard prompt while no package is selected; this is separate from the scheduled reminder.

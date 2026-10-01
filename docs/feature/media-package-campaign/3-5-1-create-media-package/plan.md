# Plan - FR 3.5.1

## Scope

Implement E50-01 on the existing V2 PostgreSQL model: read templates and create Agency-scoped custom packages.

## Plan

1. Verify `media_packages.agency_id`, check constraint, and indexes in a new migration plus `init-postgres-v2.sql`.
2. Add package repository/service with template filter and Agency ownership validation.
3. Add the template-list and custom-package endpoints with role and input validation.
4. Add integration tests for template visibility, Agency scoping, and invalid Agency.

## Dependencies

Agency must exist (DA-E16-05).

## E50-02 selection subplan

1. Client selects a global template or an Agency-custom package for the Workspace.
2. First selection creates `workspace_media_packages` and snapshots source terms into `final_terms` at version 1.
3. Before the first negotiation event, replacement updates the same workspace-package record, snapshots the replacement terms, and clears approvals; after negotiation starts it returns a conflict.
4. First selection returns `201`; a permitted replacement returns `200`.
5. Keep the reminder delay/cadence configurable until the business value for `X` days is confirmed.

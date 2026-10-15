# Plan - FR 3.5.5

## Scope

Implement E50-06 creation of a draft campaign from an approved workspace package.

Updated 2026-10-08: phase 1 confirms total quantities and two new Task types.
Implement against [phase-1 data/API contract](../phase-1-design/plan.md).

## Plan

Stage 2 implementation: keep the legacy route as an adapter, add workspace-scoped
create/detail/PATCH, serialize writes with the existing agreement row lock and add
database uniqueness. PATCH carries a complete editable plan plus expectedVersion;
empty optional fields clear content. Work-item list may be empty in DRAFT, but each
supplied item is complete. Deliverable quantities are frozen from the approved
snapshot, not editable Campaign allocations. Legacy RETAINER without explicit TOTAL
is read-only pending BA conversion; do not alter its approved snapshot. PostgreSQL
and Mongo runtime migrations are not automatically executed on developer data.
Web uses a dedicated campaign feature inside the approved-package panel, replacing
the prototype allocator; paired `src/i18n/locales/{vi,en}/campaign.json` keys.

1. Audit duplicate campaigns per agreement and per Workspace. Keep the existing
   UNIQUE Workspace agreement relation. Add a unique campaign agreement FK,
   `work_items JSONB NOT NULL DEFAULT '[]'` and `content_version INT NOT NULL DEFAULT 1`
   migration plus equivalent V2 init schema update. Do not delete duplicate history.
2. Validate each item has stable ID, task type, name, and due date.
3. Validate approved package, workspace access, and campaign payload.
4. Create/read/update `DRAFT` plans with a version guard; enforce one Campaign per
   Workspace, including concurrent requests and COMPLETED campaigns. Do not permit
   agreement reassignment to bypass the limit. Keep the existing draft API compatible.
5. Replace cross-Campaign allocation behavior with total quantities for one Campaign;
   no monthly allowance. Preserve legacy columns/snapshots pending explicit conversion.
   Owner Workspace duplication is a separate delivery task.
6. Add Campaign list/detail/editor in Web, paired vi/en keys and light/dark/responsive
   states; show the existing Campaign instead of a create action once it exists.


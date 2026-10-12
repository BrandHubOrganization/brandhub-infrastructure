# DA-1255 — Implementation plan

1. Add nullable `source_workspace_id` and `duplication_request_id` to workspaces,
   with unique `(agency_id, duplication_request_id)` for non-null requests. Update
   migration and PostgreSQL init file together; no FK cascade to source.
2. Expose a dedicated owner-only duplicate API. Validate the source, selected active
   member IDs, eligible Agency membership for internal users, linked ClientProfile
   for Clients, and at most one Manager. Persist the new Workspace and memberships
   in one PostgreSQL transaction. Return the existing destination on request retry.
3. Add a Workspace-list duplicate dialog for an Agency Owner. Load source members,
   allow individual selection, timezone switch and name entry; show a confirmation
   summary before submission. Resources are explicitly unavailable.
4. Verify service happy/error/retry cases, migration and UI type-check/lint/build.

No MongoDB access or changes are required for this feature.

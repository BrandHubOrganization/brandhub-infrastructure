# Plan

1. Add nullable offering_model and offering_details JSONB to media_packages, preserving legacy rows.
2. Add Campaign package_terms_snapshot, package_terms_version, allocation_period and allocations JSONB.
   Write a new repeatable migration and equivalent init-postgres-v2.sql definitions.
3. Typed records validate structured offerings. Extend existing DTOs compatibly; snapshot the new
   fields and reset both approvals on negotiation. No changes to specialist task services.
4. Implement draft Campaign create/read/list with workspace authorization and workspace-package
   row lock around allocation totals. Never copy data from mutable catalogue during draft creation.
5. Reusable FE offering form/summary for create, catalogue and negotiation; draft creation UI beside
   approved selection. Add paired keys in src/i18n/locales/vi/mediaPackage.json and en/mediaPackage.json.
6. Use existing feature-test accounts. Provide an explicit local-only refresh of existing
   Admin templates; isolated account/Agency/Workspace seeding was withdrawn by the user.
7. Backend unit/regression tests; frontend type-check/build and targeted checks; SQL verification.

Risks: legacy API constructors, stale approvals, cross-workspace access, concurrent over-allocation,
and existing dirty changes. Keep new fields optional for old clients; fail closed for draft allocation.

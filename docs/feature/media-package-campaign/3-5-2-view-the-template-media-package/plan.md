# Plan - FR 3.5.2

## Scope

Implement E50-03 read model for the package currently selected by a workspace.

## Plan

1. Read `workspace_media_packages` joined to `media_packages` and expose approved/current terms.
2. Add workspace-membership authorisation for Agency members and invited Client.
3. Define `404 PACKAGE_NOT_SELECTED` response for a workspace with no selection.
4. Test type-specific fields, no selection, and cross-workspace access.

## Dependencies

Requires E50-02 to create the selection. KPI structure for full delegation remains future work.

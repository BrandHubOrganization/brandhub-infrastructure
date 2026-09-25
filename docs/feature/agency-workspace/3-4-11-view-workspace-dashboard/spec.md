# 3.4.11 View Workspace Dashboard

| | |
|---|---|
| FR Code | 3.4.11 |
| Feature | View Workspace Dashboard |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER / CREATOR / CLIENT |
| Version | 2.3 — 2026-09-25 — implemented; rewritten to match real `WorkspaceServiceImpl.getDashboard` |
| Document status | Implemented |

## Function Trigger

Begins when a Workspace member opens the Dashboard of a Workspace (`/workspaces/:id/dashboard`).

## Function Description

- **Actors / Roles:** Workspace members with role MANAGER, CREATOR, or CLIENT.
- **Purpose:** Gives members an overview of the Workspace's members, campaigns, package negotiation status, and the parent Agency's AI credit usage.
- **Interface:** Workspace dashboard screen at `/workspaces/:id/dashboard`, showing summary cards.
- **Data Processing:** The system resolves the Workspace, confirms the caller is an active member, then aggregates: active member count and role breakdown (`WorkspaceMemberRepository.findByWorkspaceIdAndIsActiveTrue`, grouped by role); campaign count and status breakdown (via `WorkspaceMediaPackageRepository.findByWorkspaceId` → `MediaCampaignRepository.findByWorkspaceMediaPackageId`, grouped by `CampaignStatus`); the current package negotiation status (`WorkspaceMediaPackage.negotiationStatus`, `null` if the Workspace has no package yet); and the parent Agency's AI credit usage for the current calendar month (`AiCreditLedgerRepository.findByAgencyIdAndMonth`).
- **Known scope note:** No Task or Material entity exists in this codebase, so this dashboard does not (and cannot) show a Task summary — an earlier draft of this spec described one; that was aspirational, not grounded in code. AI credit usage is Agency-wide, not per-Workspace (`AiCreditLedger` has no `workspaceId` column) — the screen labels it explicitly as Agency-scoped rather than implying it is this Workspace's own usage.

## Screen Layout

Figure — Workspace Dashboard Screen:
- Header carrying the Workspace name (via `PageWrapper` title/description).
- Four stat cards in a row: Active members, Total campaigns, Package status (or "No package" if none), Agency AI credits used this month (labeled with the month).
- Two breakdown cards below: Members by role, Campaigns by status — each an empty list if the Workspace has no members/campaigns yet.
- A newly created Workspace with no package/campaign shows member counts as normal, campaign count as 0, package status as "No package".

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity.
- **Input optional:** None.
- **System data:** Active `WorkspaceMember` rows for the Workspace; the Workspace's `WorkspaceMediaPackage` (if any) and its `MediaCampaign` rows; the parent Agency's `AiCreditLedger` row for the current month.
- **Output:** The full Workspace profile (same shape as `GET /workspaces/{id}`), active member count and role breakdown, campaign count and status breakdown, package negotiation status (nullable), the Agency id, the current month string, and the Agency's AI credits used this month.

### Business Rules

- **BR-29:** Multi-tenancy — only members holding an active membership row in the Workspace (MANAGER, CREATOR, or CLIENT) may view its dashboard, enforced via both `@RequireRole` on the controller and `assertMember` in the service (same dual-layer pattern as `getWorkspace`, FR 3.4.13). There is no Workspace-level OWNER — OWNER exists only at Agency level.
- **BR-03:** The dashboard is read-only and changes no data.
- **BR-04:** An empty Workspace (no package, no campaigns) renders member counts normally and campaign/package fields as empty/zero/null rather than failing.

### Validation

- Caller must be an active member of the Workspace; otherwise 403 `WORKSPACE_ACCESS_DENIED` (from `assertMember`) or 403 `FORBIDDEN` (from `@RequireRole` if the caller has no membership row at all — see FR 3.4.13 for the exact two-layer distinction).
- Workspace must exist; otherwise 404 `WORKSPACE_NOT_FOUND`.
- A Workspace with no package/campaigns must render without error (empty maps, `packageNegotiationStatus: null`, `totalCampaigns: 0`).

## Functionalities

### Normal Flow

1. Member opens the Dashboard of a Workspace.
2. FE calls `GET /api/v1/workspaces/{workspaceId}/dashboard`.
3. System resolves the Workspace (`findWorkspaceOrThrow`) and confirms active membership (`assertMember`, BR-29).
4. System aggregates active member count/role breakdown, campaign count/status breakdown, package negotiation status, and the Agency's current-month AI credit usage.
5. Screen renders the stat cards and breakdown lists; an empty Workspace shows zeros/empty lists without error.

### Abnormal Cases

- 3.a1: The Workspace does not exist → 404 `WORKSPACE_NOT_FOUND`, toast MSG38. 3.a2: The member returns to the Workspace list (3.4.10).
- 3.b1: Caller is not an active member of the Workspace (BR-29) → 403 `WORKSPACE_ACCESS_DENIED` or `FORBIDDEN`, toast MSG40. 3.b2: The member returns to the Workspace list (3.4.10).
- 4.a1: Workspace has no package yet → `packageNegotiationStatus` is `null`, `totalCampaigns` is 0 (BR-04). 4.a2: The member continues viewing the dashboard normally; the package/campaign cards show empty states.

## Post-Conditions

- No data is changed; the Workspace's member, campaign, package, and Agency AI credit summary is displayed.

## Out of Scope

- Time-series charts of activity over time (possible later extension).
- Per-Workspace AI credit tracking (the underlying `AiCreditLedger` schema is Agency-scoped only; would need a schema change to break down by Workspace).
- Task/Material summary (no such entity exists in this codebase).

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

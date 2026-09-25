# Task — View Workspace Dashboard (FR 3.4.11)

> Implementation checklist per [plan.md](plan.md). Status: **Done — implemented and shipped.**

## Backend — `brandhub-business-service`

- [x] `WorkspaceDashboardResponse` record (workspace, totalActiveMembers, membersByRole, totalCampaigns, campaignsByStatus, packageNegotiationStatus, agencyId, aiCreditMonth, agencyAiCreditsUsedThisMonth)
- [x] `WorkspaceServiceImpl.getDashboard(workspaceId, currentUser)` — `findWorkspaceOrThrow` → `assertMember` → aggregate members/campaigns/package/AI credits → assemble response
- [x] `WorkspaceController.getDashboard` — `GET /api/v1/workspaces/{workspaceId}/dashboard`, `@RequireRole({MANAGER, CREATOR, CLIENT})`
- [x] 403 `WORKSPACE_ACCESS_DENIED` (from `assertMember`), 403 `FORBIDDEN` (from `@RequireRole`), 404 `WORKSPACE_NOT_FOUND` (from `findWorkspaceOrThrow`)
- [x] Empty Workspace (no package/campaigns) renders without error — `packageNegotiationStatus: null`, `totalCampaigns: 0`, empty breakdown maps

## Frontend — `brandhub-web-dashboard`

- [x] `workspaceService.getDashboard(workspaceId)` — `GET /api/v1/workspaces/{workspaceId}/dashboard`
- [x] `WorkspaceDashboard` type in `src/types/workspace.ts`
- [x] `WorkspaceDashboardPage` (`src/pages/workspace/dashboard.tsx`) — `PageWrapper` header, 4 stat cards (active members, total campaigns, package status, Agency AI credits this month), 2 breakdown lists (members by role, campaigns by status)
- [x] Empty-state handling in `BreakdownList` (renders nothing when the map is empty) and package card ("No package" fallback)
- [x] Error toast on load failure (`extractErrorMessage`)

## Verify

- [x] Happy path — active member sees full dashboard data
- [x] Empty Workspace — no package/campaign → zeros/null, no error
- [x] 403 for non-member
- [x] 404 for non-existent Workspace

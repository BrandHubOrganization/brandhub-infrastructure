# Plan — View Workspace Dashboard (FR 3.4.11)

> Linked: [spec.md](spec.md) — Document status: **Implemented**. This plan describes the real, shipped implementation.

## 1. Technical Scope

| Item | Content |
|---|---|
| Repo | `brandhub-business-service` (backend), `brandhub-web-dashboard` (frontend) |
| Backend files | `WorkspaceServiceImpl.getDashboard()`, `WorkspaceController.getDashboard()`, `WorkspaceDashboardResponse` (new record) |
| Reused files | `WorkspaceMemberRepository`, `WorkspaceMediaPackageRepository`, `MediaCampaignRepository`, `AiCreditLedgerRepository`, `findWorkspaceOrThrow`, `assertMember`, `toResponse` |
| Frontend files | `src/pages/workspace/dashboard.tsx`, `src/services/workspaceService.ts` (`getDashboard`), `src/types/workspace.ts` (`WorkspaceDashboard`) |

## 2. API Contract (final)

```
GET /api/v1/workspaces/{workspaceId}/dashboard
Authorization: Bearer <access-token>
Roles: MANAGER, CREATOR, CLIENT (@RequireRole, active membership required)

→ 200 ApiResponse<WorkspaceDashboardResponse>
{
  "success": true,
  "data": {
    "workspace": { ...WorkspaceResponse... },
    "totalActiveMembers": number,
    "membersByRole": { "MANAGER": number, "CREATOR": number, "CLIENT": number },
    "totalCampaigns": number,
    "campaignsByStatus": { "<CampaignStatus>": number, ... },
    "packageNegotiationStatus": string | null,
    "agencyId": uuid,
    "aiCreditMonth": "YYYY-MM",
    "agencyAiCreditsUsedThisMonth": number
  }
}
```

Matches `WorkspaceDashboardResponse` record exactly (`com.brandhub.business.dto.response.WorkspaceDashboardResponse`). No request body; `workspaceId` is a path variable, consistent with other Workspace endpoints.

## 3. Data Model

No new entity or migration. The dashboard aggregates existing tables read-only:

- `WorkspaceMember` — active rows for the Workspace (`findByWorkspaceIdAndIsActiveTrue`), grouped by `role` for `totalActiveMembers` / `membersByRole`.
- `WorkspaceMediaPackage` — the Workspace's package, if any (`findByWorkspaceId`); source of `packageNegotiationStatus` (`null` when absent).
- `MediaCampaign` — rows under the Workspace's package (`findByWorkspaceMediaPackageId`), grouped by `status` for `totalCampaigns` / `campaignsByStatus`. Empty list when there is no package.
- `AiCreditLedger` — the parent Agency's row for the current calendar month (`findByAgencyIdAndMonth(agencyId, YearMonth.now().toString())`); Agency-scoped, not per-Workspace (no `workspaceId` column exists on this table).

## 4. Processing Flow

1. `findWorkspaceOrThrow(workspaceId)` → 404 `WORKSPACE_NOT_FOUND` if missing.
2. `assertMember(workspaceId, currentUser.getId())` → 403 `WORKSPACE_ACCESS_DENIED` if the caller has no active membership row (BR-29). The `@RequireRole` annotation on the controller adds a second layer, rejecting with 403 `FORBIDDEN` if the caller has no membership row at all (same dual-layer pattern as `getWorkspace`, FR 3.4.13).
3. Load active members, compute `membersByRole` via `Collectors.groupingBy(role, counting())`.
4. Load the Workspace's `WorkspaceMediaPackage` (nullable); load its campaigns if present, else empty list. Compute `campaignsByStatus`.
5. Compute `currentMonth` (`YearMonth.now().toString()`) and look up the Agency's `AiCreditLedger` for that month; default `creditsUsed` to 0 if no ledger row exists yet.
6. Assemble and return `WorkspaceDashboardResponse`, embedding the full `WorkspaceResponse` (via `toResponse`) for the Workspace's own profile fields.

## 5. Dependencies

| Direction | Description |
|---|---|
| Blocked by | None — all referenced repositories and entities already exist. |
| Blocks | None. |

## 6. Technical Notes

- No Task/Material entity exists in this codebase; an earlier draft of this spec assumed one — removed, not implemented (see spec.md "Known scope note").
- AI credit usage is Agency-wide (`AiCreditLedger` has no `workspaceId` column); the response and UI label it explicitly as Agency-scoped rather than implying it belongs to this Workspace alone.
- The dashboard is fully read-only (BR-03); no writes occur in `getDashboard`.
- An empty Workspace (no package, no campaigns) is handled without error: `packageNegotiationStatus` is `null`, `totalCampaigns` is `0`, breakdown maps are empty (BR-04).

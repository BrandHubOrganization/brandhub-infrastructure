# Sequence Flow — View Workspace Dashboard

> FR 3.4.11 — **Implemented.** Companion to `spec.md`; lists each step as actor → action → system, in enough detail to draw the sequence diagram directly.
>
> Updated: 2026-09-25.

## Actors

- **Client** — a Workspace member (MANAGER, CREATOR, or CLIENT), via the FE dashboard page.
- **WorkspaceController** — `GET /api/v1/workspaces/{workspaceId}/dashboard`, `@RequireRole({MANAGER, CREATOR, CLIENT})`.
- **WorkspaceServiceImpl** — `getDashboard(workspaceId, currentUser)`.
- **WorkspaceMemberRepository** — active membership rows.
- **WorkspaceMediaPackageRepository** — the Workspace's media package, if any.
- **MediaCampaignRepository** — campaigns under that package.
- **AiCreditLedgerRepository** — the parent Agency's AI credit ledger for the current month.

---

## Normal Flow

1. Client → WorkspaceController: `GET /api/v1/workspaces/{workspaceId}/dashboard`.
2. WorkspaceController: `@RequireRole({MANAGER, CREATOR, CLIENT})` — rejects with 403 `FORBIDDEN` if the caller has no membership row with a qualifying role.
3. WorkspaceController → WorkspaceServiceImpl: `getDashboard(workspaceId, currentUser)`.
4. WorkspaceServiceImpl: `findWorkspaceOrThrow(workspaceId)` — 404 `WORKSPACE_NOT_FOUND` if the Workspace does not exist.
5. WorkspaceServiceImpl: `assertMember(workspaceId, currentUser.getId())` — 403 `WORKSPACE_ACCESS_DENIED` if the caller has no *active* membership row (BR-29).
6. WorkspaceServiceImpl → WorkspaceMemberRepository: `findByWorkspaceIdAndIsActiveTrue(workspaceId)` → active members; grouped by role into `membersByRole`.
7. WorkspaceServiceImpl → WorkspaceMediaPackageRepository: `findByWorkspaceId(workspaceId)` → the Workspace's package, or empty.
8. WorkspaceServiceImpl → MediaCampaignRepository: `findByWorkspaceMediaPackageId(packageId)` if a package exists, else an empty list; grouped by `CampaignStatus` into `campaignsByStatus`.
9. WorkspaceServiceImpl → AiCreditLedgerRepository: `findByAgencyIdAndMonth(workspace.getAgencyId(), currentMonth)` → the Agency's ledger row for the current month, or `0` if absent.
10. WorkspaceServiceImpl: assembles `WorkspaceDashboardResponse` (embedding `toResponse(workspace)`, active member count/breakdown, campaign count/breakdown, `packageNegotiationStatus`, `agencyId`, `aiCreditMonth`, `agencyAiCreditsUsedThisMonth`).
11. WorkspaceServiceImpl → WorkspaceController → Client: 200 with the dashboard payload.
12. Client: renders the stat cards and breakdown lists; an empty Workspace shows zeros/empty lists without error (BR-04).

---

## Error Paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| 2 | Caller has no membership row with a qualifying role | 403 | `FORBIDDEN` |
| 4 | `workspaceId` does not exist | 404 | `WORKSPACE_NOT_FOUND` |
| 5 | Caller has a membership row but it is not active (or none at all reaching this check) | 403 | `WORKSPACE_ACCESS_DENIED` |

## Notes

- Steps 6–9 run as four independent reads against existing repositories — no new query or migration was needed.
- `packageNegotiationStatus` is `null` when the Workspace has no `WorkspaceMediaPackage` yet; `totalCampaigns` is `0` and `campaignsByStatus` is empty in that case (BR-04).
- `agencyAiCreditsUsedThisMonth` reflects Agency-wide usage, not this Workspace alone — `AiCreditLedger` has no `workspaceId` column.
- The dashboard performs no writes (BR-03).

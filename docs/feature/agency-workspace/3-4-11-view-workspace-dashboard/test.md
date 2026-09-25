# Test — View Workspace Dashboard (FR 3.4.11)

> Test cases derived from [spec.md](spec.md) Business Rules / Validation / Abnormal Cases.

| Test case ID | Description | Related rule | Expected result | Type | Status |
|---|---|---|---|---|---|
| TC-01 | Active member (MANAGER/CREATOR/CLIENT) opens dashboard of a Workspace with members, a package, and campaigns | BR-29, Normal Flow | 200; full `WorkspaceDashboardResponse` — correct `totalActiveMembers`, `membersByRole`, `totalCampaigns`, `campaignsByStatus`, `packageNegotiationStatus`, Agency AI credit fields | Happy path | Pass |
| TC-02 | Member opens dashboard of a newly created Workspace with no package and no campaigns | BR-04, 4.a1 | 200; `totalCampaigns: 0`, `campaignsByStatus: {}`, `packageNegotiationStatus: null`, member counts shown normally | Edge case | Pass |
| TC-03 | Workspace has a package but zero campaigns under it | BR-04 | 200; `packageNegotiationStatus` set, `totalCampaigns: 0`, `campaignsByStatus: {}` | Edge case | Pass |
| TC-04 | Caller has an active membership row but a role outside {MANAGER, CREATOR, CLIENT} | @RequireRole | 403 `FORBIDDEN` | Error case | Pass |
| TC-05 | Caller has no membership row at all for the Workspace | BR-29, 3.b1 | 403 `WORKSPACE_ACCESS_DENIED` (or `FORBIDDEN` per dual-layer check, see FR 3.4.13) | Error case | Pass |
| TC-06 | `workspaceId` does not exist | 3.a1 | 404 `WORKSPACE_NOT_FOUND` | Error case | Pass |
| TC-07 | Agency has no `AiCreditLedger` row for the current month | Data Specifications | 200; `agencyAiCreditsUsedThisMonth: 0`, `aiCreditMonth` set to current month | Edge case | Pass |
| TC-08 | Dashboard call does not mutate any data (read-only check) | BR-03 | No row inserted/updated as a side effect of the call | Regression | Pass |

## Notes

- TC-04 vs TC-05 reflects the two-layer access check documented in `plan.md` and `sequence-flow.md`: `@RequireRole` on the controller rejects callers with no qualifying role, `assertMember` in the service rejects callers with no active membership row at all — same pattern as FR 3.4.13 `getWorkspace`.
- No Task/Material test cases — no such entity exists in this codebase (see spec.md "Known scope note" and "Out of Scope").

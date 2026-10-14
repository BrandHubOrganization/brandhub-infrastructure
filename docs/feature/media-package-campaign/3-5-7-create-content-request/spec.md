# FR 3.5.7 - Create Content Request

| Field | Value |
|---|---|
| Status | Ready after V2 Mongo migration |
| Roles | Client |
| Delivery task | DA-E50-10 |

## Outcome

A Client creates an out-of-campaign request in a workspace. It starts as `PENDING` and does not create a task until an Agency Manager accepts it.

## Acceptance criteria

- `POST /api/v1/workspaces/{workspaceId}/content-requests` accepts `title`, `description`, Client-selected `type` (`POST|LIVESTREAM|SURVEY`), and `dueDate`; it returns a `PENDING` request.
- Only a Client belonging to the workspace may create it.
- Confirmed 2026-10-13: creation requires a successfully deployed Campaign in this Workspace; approval alone, a queued/failed/partial deployment, or no Campaign is insufficient. Enforce this on the server as well as in the UI.
- Confirmed 2026-10-14: Campaign must be `IN_PROGRESS` with deployment `SUCCEEDED`. Manager marking COMPLETED automatically cancels PENDING Requests with audit history; IN_PROGRESS continues. Calendar expiry alone does not complete Campaign.
- Create/update dueDate is within max(today in Workspace timezone, Campaign startDate) and Campaign endDate, inclusive. See ../request-completion-validation/spec.md.
- Confirmed later 2026-10-14: generated Task maps type/due date and belongs to the current deployed Campaign; campaignWorkItemId remains null, sourceType=CONTENT_REQUEST/sourceRefId retain provenance. No change to approved plan or package quantities. See ../campaign-closure/spec.md.

## UI and scope

Use Workspace-scoped requests, real API data, and the existing page layout. New text uses parallel `src/i18n/locales/{vi,en}/requests.json` keys under `requests.v2.*` (status, fields, campaignGate and error/action text). Use semantic theme tokens in light/dark mode; loading, empty, validation, forbidden and retry states must be usable on mobile. Do not repurpose unrelated Client-profile screens or the content editor.

## Persistence rule

Init and the new migration now describe V2 fields `workspaceId`, `requestedBy`, `title`, `description`, `type`, `dueDate`, `status`, `generatedTaskId`, `version`, `createdAt`, and `updatedAt`, with review/audit metadata as defined in the shared plan. Read-only Atlas inventory on 2026-10-13 found zero records and legacy indexes; migration has NOT been applied. Allowed statuses are `PENDING`, `IN_PROGRESS`, `ACCEPTED`, `DENIED`, `CANCELLED`. Do not rerun Mongo initialisation or guess mappings for legacy approval/task states.

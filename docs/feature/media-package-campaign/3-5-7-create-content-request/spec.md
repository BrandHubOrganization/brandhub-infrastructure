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
- The generated task maps the selected type/due date and has `campaignId: null`.

## Persistence rule

The shared Atlas collection is legacy-shaped and must be normalised by a new idempotent migration to V2 fields `workspaceId`, `requestedBy`, `title`, `description`, `type`, `dueDate`, `status`, `generatedTaskId`, `createdAt`, and `updatedAt`; allowed statuses are `PENDING`, `IN_PROGRESS`, `ACCEPTED`, `DENIED`, `CANCELLED`. Do not rerun Mongo initialisation.

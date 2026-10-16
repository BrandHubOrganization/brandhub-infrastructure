# FR 3.5.4 - Approve Media Package

| Field | Value |
|---|---|
| Status | Ready for technical review |
| Roles | Client; Owner/Manager |
| Delivery task | DA-E50-05 |

## Outcome

A workspace package becomes `APPROVED` only when Agency and Client approve the same negotiated terms version.

## Acceptance criteria

- `POST /api/v1/workspaces/{workspaceId}/media-package/approve` records caller-side approval and returns both approval timestamps and status.
- One approval is not sufficient to mark a package approved.
- Only an approved package may be used to create a campaign.
- A terms change invalidates approvals for the prior terms version.

## Terms-version rule

Every terms change creates a new version. Both prior approvals are invalid; Agency and Client must each approve the current version before status becomes `APPROVED`.

Confirmed phase 5: request body `{expectedTermsVersion: integer >=1}` is mandatory.
Compare under the selection row lock; stale version returns 409 without mutation,
including retries after final approval. Same-version repeat by the same side preserves
its original approval timestamp. No reopen/withdraw API is introduced.

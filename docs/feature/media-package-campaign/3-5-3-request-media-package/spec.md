# FR 3.5.3 - Request Media Package Changes

| Field | Value |
|---|---|
| Status | Ready for technical review |
| Roles | Client; Owner/Manager |
| Delivery task | DA-E50-04 |

## Outcome

Client and Agency negotiate the selected workspace package through a durable, ordered history of requested terms and counter-offers.

## Acceptance criteria

- Client submits `requestedTerms` and optional note through `request-change`.
- Owner/Manager submits a counter-offer or response.
- Status moves between `CLIENT_REQUESTED_CHANGE` and `AGENCY_COUNTERED` until both parties approve.
- The package itself cannot be replaced after negotiation begins; only its workspace terms may change.
- The API exposes a negotiation history for the UI thread.

## Persistence design

`workspace_media_packages` holds current `final_terms` and `terms_version`. E50-04 adds append-only `package_negotiation_events` with the workspace package ID, terms version, actor, action (`REQUEST_CHANGE` or `COUNTER_OFFER`), terms snapshot, optional note, and timestamp. Every terms-changing event increments the version and invalidates both approvals atomically.

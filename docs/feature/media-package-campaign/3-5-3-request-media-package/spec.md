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

## Phase 5 — confirmed 2026-10-13

- Negotiation and approval require `expectedTermsVersion` >=1. Under the selection
  row lock a stale version returns 409 MEDIA_PACKAGE_VERSION_CONFLICT; no terms,
  approvals, history, notification or proposal count changes. Missing version is 400.
  User explicitly approved this breaking contract; Web and other API clients must update.
- History contains immutable snapshots and actor role/ID, optional note <=2000.
  Actor role uses effective Workspace membership; Agency ownership is a fallback
  only when no direct membership exists (Owner assigned Manager acts as Manager).
  A Client proposal increments clientProposalCount; Manager/Owner does not consume it.
  No-change/invalid/forbidden/approved-package mutations do not append history.
- Legacy already-negotiated/approved selections get exactly one BASELINE at the
  current version, unknown actor, recording time = migration time. DRAFT selections
  wait until first negotiation, including those switched before negotiation. Do not infer lost
  events from previous_terms. For a fresh DRAFT, first successful negotiation records
  its prior snapshot as BASELINE then the new proposal, in the same transaction.
- History is append-only while its Workspace exists (no event edit/delete API;
  direct SQL update/delete blocked). Preserve existing parent Workspace hard-delete
  cascade behavior, rather than introducing retention that blocks other modules.
- GET `/api/v1/workspaces/{workspaceId}/media-package/history` is paginated, newest
  first, Owner/Manager/Client scoped; Creator/outsider cannot read. No selection
  returns 404. Read never creates a baseline.
- Switching an unnegotiated package must increment (not reset) termsVersion;
  otherwise an old page could approve a different package using the same version.
- UI adds a collapsible history beside current terms; historical snapshots are
  read-only, never the approval target. Reuse current old/new diff component against
  current terms, show baseline warning. Preserve current fonts/theme/layout.
- i18n: parallel `mediaPackage.history.*` keys (title, empty, baseline, error,
  reload, previous, next, version, actor, note, compare, recordedAt, actions, roles).
  Loading/empty/error/retry, keyboard and light/dark/mobile states are required.

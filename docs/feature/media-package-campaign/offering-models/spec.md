# Media package offering models

> Checkpoint of the implemented Package/demo slice. The Campaign allocation rules
> below describe the earlier prototype. The user's 2026-10-08 decision supersedes
> multiple Campaigns per agreement: one approved WorkspaceMediaPackage leads to one
> Campaign, with periods/phases inside it. See [next delivery](../campaign-delivery-plan.md).
> Package catalogue, snapshot, proposal and approval rules remain applicable per agreement.

## Objective and actors

Extend FR 3.5.1–3.5.5 with structured package deliverables and draft Campaign allocation.
Owner manages the Agency catalogue; an active Workspace Manager may create an Agency package
with workspaceId scope. Client selects an available Agency package and negotiates with Agency.
This specification records the user's approved October 2026 scope; no Report changes are required.

## Acceptance criteria

- Preserve legacy type, durationWeeks, budgetAmount and scopeDescription. Existing packages remain readable.
- offeringModel is CAMPAIGN, RETAINER or DELIVERABLE_BUNDLE; legacy records may have no model.
- Deliverables have stable UUID id, serviceType, name, quantity, unit, description and
  acceptanceCriteria. Positive integer quantities; IDs unique in a package. `maxChanges`
  ("Số lần thay đổi tối đa") belongs to the whole package, not each deliverable.
- Services: SOCIAL_POST, EVENT_PLANNING, LIVESTREAM_PREPARATION, PRESS_RECOMMENDATION,
  WORKSHOP_SUPPORT. These are NOT Task types.
- Snapshot all structured terms at selection. Negotiation changes the snapshot, not the catalogue;
  every changed version invalidates BOTH approvals. Explicit approval remains required from both sides.
- Client may propose budget, duration, scope and deliverable content/quantity, but cannot change
  offering model, service type, unit or maxChanges. Validate this on the server, not only the UI.
  Persist the prior terms for a two-column current/proposed comparison with changed fields
  highlighted; match deliverables by stable ID so reordering alone does not create false changes.
  Notify the opposite side's active Workspace
  participants via the in-app inbox; the UI refreshes notifications on focus and at intervals.
- maxChanges limits Client-submitted package negotiation proposals only. The counter starts at
  zero when the package is selected, increments once per valid Client proposal, and resets only
  if a different package is selected before negotiation starts. Manager/Owner counteroffers do
  not consume this allowance. termsVersion still increments for every changed proposal from
  either side so both approvals remain tied to the latest terms. Once the limit is reached,
  Client may still approve or chat. Existing negotiations default to zero because their earlier
  proposal history cannot be reconstructed reliably from termsVersion.
- Agency may create a new package from either an Admin template or an existing package in the
  same Agency. Package catalogue cards expose a detail view before choosing or copying.
- Only Owner/Manager may create a DRAFT Campaign from an APPROVED workspace package.
- CAMPAIGN suggests all deliverables; bundle allows selected quantities. Aggregate allocations
  cannot exceed the agreed quantities, including concurrently created drafts.
- RETAINER quantities are monthly. Manager explicitly chooses a YYYY-MM period; no automatic
  creation and no rollover. Allocations consume only the selected month's allowance.
  No contract start/end month is inferred from durationWeeks. A separate clarification about
  restricting allowed months is pending; the initial flow accepts an explicitly selected YYYY-MM.
- Campaign preserves agreed terms and termsVersion plus deliverable allocations. Catalogue changes
  cannot change existing Campaign scope. No tasks are generated in this slice.
- Legacy snapshots without structured terms cannot use the new allocation flow. Do not infer
  a model from BY_DURATION/BY_BUDGET or mutate previously approved agreements.

## UI and API

Extend existing package create/read/negotiate DTOs additively. Add offeringModel and offeringDetails.
Draft Campaign creation accepts workspaceMediaPackageId, name, period (retainer only), allocations.
Read/list Campaign endpoints must enforce workspace membership, not trust client-supplied IDs.
UI uses shared controls, semantic theme tokens and matching vi/en `mediaPackage.offering.*` keys.
Show loading, empty, validation and API error states; retain existing navigation/package gate.

## Boundaries

Workshop supports creating a Google Meet link and survey; detailed implementation belongs to E51.
Event means delivery of an event plan only. No EVENT task, logistics, staffing or agenda module.
Keep E50-08/09 (partner directory and collaboration tracking) in the master plan, not this slice.
No Campaign approval/deployment, billing, publishing, Mongo initialization or specialist service forms.
The local Admin-template refresh updates existing template rows in place at the user's request;
it does not create accounts or change existing workspace negotiation snapshots.

## Definition of done

Migration and fresh init agree; backend and UI expose the same fields; unit tests cover invalid
input, scope isolation, snapshot immutability, approval reset and allocation limits. Regression
checks run for existing package flows. Report remaining unverified checks explicitly.

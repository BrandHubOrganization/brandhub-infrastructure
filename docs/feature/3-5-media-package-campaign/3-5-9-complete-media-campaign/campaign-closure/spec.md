# Campaign closure and supplemental Request Tasks

Confirmed by user 2026-10-14; supersedes completion-with-unfinished-reason and campaignId=null for newly accepted Content Requests. Task team must be informed of CANCELLED terminal status before merging.

## Acceptance

- Accepting a Content Request creates exactly one BACKLOG Task linked to the Workspace's current deployed IN_PROGRESS Campaign. Retain sourceType=CONTENT_REQUEST/sourceRefId; campaignWorkItemId remains null. Do not change deliverablePlan, workItems, snapshot or package quantities.
- Campaign shows these separately as supplemental Request Tasks, distinct from planned work.
- Manager completion requires every Campaign Task to be COMPLETED or CANCELLED. No textual reason bypass. Check planned Task deployment completeness separately from supplemental count.
- IN_PROGRESS Requests block completion and are linked in the preview for Manager to accept/deny through existing Request flow. Do not auto-deny or auto-cancel these. PENDING Requests remain automatic cancellation at successful completion with count warned beforehand, using existing durable queue.
- Only Workspace Manager may bulk cancel selected unfinished Campaign Tasks, including QC/Client review. No preselected Tasks or reason. One selected reason applies to the batch: CLIENT_NO_LONGER_NEEDS, MUTUAL_AGREEMENT, DUPLICATE_OR_REPLACED, NO_LONGER_SUITABLE, OTHER (requires note). Preserve approval/content records and record cancelledAt/by, reason code/note, prior status on each Task. Completed Tasks cannot be cancelled, cancelled Tasks are terminal; retries cannot overwrite audit.
- Re-read server state before cancellation/completion; reject stale status/updatedAt, wrong scope, oversized/duplicate selection. Batch writes atomic in Mongo; cancellation is a separate explicit operation from final SQL completion.
- Existing unlinked Request Tasks are NOT silently reassigned. Preview blocks completion and flags reconciliation; migration preflight reports them. No live data writes in implementation.

## API / UI

### UI refinement confirmed 2026-10-14

Completion preview always lists unfinished Task names/statuses and explains why completion is blocked. Cancellation is optional, collapsed by default behind an explicit Manager option. Only opening it reveals Task checkboxes, shared reason and confirmation. Closing it clears selection/reason/note/confirmation; reopening cannot reuse a hidden destructive intent. Opening alone never changes data. All existing server gates remain unchanged. Add parallel vi/en `campaign.closure.cancelOption/cancelHelp`; semantic theme tokens and keyboard-accessible expanded state.

GET campaigns/{id}/completion-check -> unfinished Tasks, IN_PROGRESS Request summaries, PENDING count, readiness, legacy unlinked Task count. POST campaigns/{id}/tasks/cancel -> expectedVersion, selections(taskId,status,updatedAt), reasonCode, note; return updated closure preview. Existing /complete now hard-gated. Extend Task response with nullable workItemId, sourceType/sourceRefId, updatedAt/cancellation.

Use existing Dialog, checkbox inputs, Select, Textarea, Button; keyboard labels, inline validation, destructive confirmation and loading/error/retry. Parallel vi/en campaign.closure.* and CANCELLED label; semantic light/dark tokens, mobile scroll. No auth/global UI changes. Keep content editing/read history implementation unchanged; cancellation does not delete or restore anything.

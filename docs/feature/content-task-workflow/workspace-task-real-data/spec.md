# Workspace Task views — real Campaign data (2026-10-15)

## Objective / actors

DA-979 / FR 3.6.4–3.6.8: keep the existing Task views, replacing their implicit mock fallback with actual Workspace Tasks. Owner/Manager/Creator/Client must be active members. Existing BA lets Client view all Tasks, including manual Tasks. References: `../3-6-4-list-task-view/spec.md`, `../3-6-8-view-task-filter/spec.md`, `../../../BA/05-content-task-workflow.md`, Media Campaign delivery and Content Request acceptance code.

## Acceptance criteria

- Fetch `/api/v1/workspaces/{id}/tasks`. Read the same Mongo `tasks` used by Campaign deployment and Content Request acceptance, retaining IDs, campaign/source links. No duplicate/synthetic Tasks, init/migration, seed or backfill.
- Include Campaign, supplemental Content Request and manual Tasks scoped to this Workspace. Undeployed planned work items are not Tasks. Support all five existing Task types and all nine statuses including CANCELLED.
- Server-side status/type/search filters combine with AND before pagination; search name/description as literal text. Optional campaignId filter remains Workspace-scoped. Keep existing page/sort defaults and whitelist sort keys; stable ID tie-break.
- Empty API results stay empty. Errors/401/403/invalid envelopes never silently switch to mock; show a retryable error, never another Workspace's stale rows. Only names/avatars and Task metadata are exposed, no User entity or credentials.
- User confirmed read-only integration this release: no fake Kanban status updates, Calendar moves or Gantt date changes. Only actual deadline instants are visualised; no generated dates, durations, venues or priorities. Missing deadline/priority is displayed as missing. List/board/calendar/timeline share current filters/page, with pagination reachable from every view.
- Task click shows a read-only detail summary of actual list metadata, including Campaign and source Request links. Do not send non-Post Tasks or Clients into the Post editor.

## UI states

Preserve the current layout and semantic theme tokens. New labels/messages are parallel `tasks.*` keys in `src/i18n/locales/{vi,en}/tasks.json`. Loading, empty, error/retry and unavailable fields are distinct; keyboard-operable buttons/dialog, visible labels, light/dark supported. Date-only visualisations refer to deadline, not posting time or planned duration.

## Out of scope

Approval/assignment/start/drag-and-drop mutations, specialised Task editors, Task phase-1 stash, Campaign/package terms, new account/data, database schema changes, auto commit/push, full completion of all Task-view FRs.

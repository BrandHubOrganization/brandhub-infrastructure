# Campaign timeline

## Objective / stories
Manager edits the Campaign plan on one page, schedules Task/subtask ranges, assigns members and creates subtasks quickly. Campaign rows show task name, status and assignee; there is no personal-role column. Personal involvement remains available as a filter. Client views and submits Campaign feedback in a fixed rail; Task comments remain in Task detail.

## Acceptance criteria
- Existing permissions, workflow transitions, deployment/closure and package quantities remain authoritative. Task detail opens in a dialog as explicitly requested by the user, overriding the general no-long-modal preference for this Task interaction only.
- No checkbox decoration. Truncated names open existing Task details. Preserve existing subtask controls/status permissions.
- Planned start is independent of actual firstStartedAt. New Tasks/subtasks default to today in workspace timezone and due=start+2 calendar days. Supervisor defaults to creator; no new approval privileges.
- Move/resize ranges by calendar days, including outside Campaign/parent dates. Require start before end only; do not move Campaign dates/milestones or publishing schedules. Auto-save atomically on release; date inputs are a keyboard/non-drag alternative.
- Inline assignee picker highlights selected user. Compact subtask creator accepts name/assignee/calendar icon; Enter submits and focuses a fresh name field, preserving assignee, resetting dates to the default.
- Search Task/subtask; filters: my involvement (assignee OR supervisor), assignee, supervisor, status, type, deliverable, schedule/overdue. Match subtask retains parent context. No Custom filters, Labels or Sprints.
- Resize columns using pointer or keyboard; store presentation widths by user/workspace, not server data. Weekend tint and today line. Internal scrolling and skeleton loading.
- Campaign metadata auto-save serialized with optimistic version. Errors preserve unsaved text, display retry and block deployment until resolved. Conflicts refetch and require review; never blindly replay stale full plans.

## API / DB
Add optional plannedStartDate Instant to Mongo tasks and embedded subtasks; reuse dueDate. Add batched campaign timeline read and revision-checked schedule endpoint. Existing assignee API remains in use. New fields are additive; no legacy start-date backfill. Update init and seeder along with migration. No APPLY on shared/production DB in this task.

## UI states / i18n / themes
Use campaign.timeline.* keys in parallel vi/en campaign.json. Loading skeleton, empty filtered list, storage error/retry, saving/saved/error and read-only states. Existing semantic/BrandHub tokens for both themes. Accessible pointer/keyboard alternatives, reduced motion, responsive internal calendar overflow.

## Errors / out of scope / Done
No mock fallback or unauthorized controls. Handle revision/version conflicts without losing edits. No publish, review sequence, new Task-milestone relation or unrelated working-tree changes. Done after Web CI, targeted backend and timeline behavior checks, migration/init/seeder parity verified.

## Approved layout refinement — 2026-11-07
- Compact Campaign title/save header; metadata, editable dates and strategy move to right rail above deployment conditions and Client feedback. Timeline fills remaining viewport with internal scrolling. Persistent vertical separators distinguish adjustable pinned columns and calendar.
- Add milestone directly on the Campaign bar: hover previews a translucent diamond and date, click focuses an inline name input; Enter saves, Escape or clicking outside cancels a new draft. Existing markers open inline edit; no separate add popup or toolbar add button. Only editable DRAFT Campaign roles may mutate; preserve version checks, max 100 milestones and failed drafts.
- Keep keyboard equivalents (focus rail, arrows choose day, Enter opens name) and native date alternative. Unscheduled Task rows show a state label rather than repeated Set schedule buttons; preview/create a date range from their calendar lane. Old rows remain unchanged until explicit action.
- Fit-to-view spans the visible calendar; day/week/month remain available. VI/EN keys remain parallel; semantic colors in light/dark; reduced motion; desktop independent scroll and mobile natural flow. No API/DB changes for this refinement.

## Timeline simplification — approved 2026-11-07
- Default daily scale; minimum legible column/zoom sizes, no month/year header or weekend shading. Campaign dates replace timeline title in the toolbar; remove Campaign information card while retaining compact strategy editing on the right. Persistent start/end references and an always-visible horizontal scroll control.
- Rename Campaign root row to Milestone and reduce row height. Existing task/subtask/approval behavior stays authoritative.
- A click on an unscheduled task lane immediately saves start at the pointed day and end three calendar days later, without a date popup. Explicit dragging may still set a different duration; creating a new Task/subtask retains its established defaults unless this click action is used.
- Compact subtask form: name and controls adjacent, no expanding gap caused by shared Input wrappers. Full Vietnamese assignee heading; status cannot wrap when resized.

## Approved date/column correction sketch — 2026-11-07
- Missing Campaign end date must still show at least a continuous 14-day planning window, including observed dates; never persist an invented end date.
- One horizontal control only, aligned to calendar with previous/next-day arrows. Hide the duplicate native horizontal bar while preserving vertical scrolling and horizontal trackpad/Shift-wheel input.
- Compact defaults: assignee avatar column ~56px, status ~100px; minimum status width derives from real status label content rather than header. Header ellipsis/tooltip allowed; badge and avatar must not wrap or clip. Wider widths restore complete headings.


## Milestone drag — 2026-11-07
Manager can drag an existing milestone diamond to change its date, snapping to calendar days within existing Campaign bounds. Drop auto-saves using the existing content version. Click still opens edit; Escape/pointer cancellation discards the drag. Failed saves retain the proposed date for explicit retry. Client remains read-only. Keyboard Left/Right moves one day. Semantic theme colors preserved; vi/en move hint keys added in parallel.


## Inclusive deadline display — 2026-11-07
Task bars include the deadline calendar day (07→10 covers four cells through end of 10). Remove floating date labels and native date tooltip on Task drag and milestone drag; retain accessible date descriptions. UI correction only: existing stored deadline timestamps and APIs unchanged.


## Compact timeline controls — 2026-11-07
Milestone creation uses the clicked timeline day and only shows name/confirm/cancel (no date picker). Existing milestone editor retains its date control. Toolbar has Today plus styled day/week/month menu; default week. Remove fit button and fit menu option. Shared Radix dropdown theme and keyboard behavior, parallel existing vi/en labels reused.


### Scale selection highlight
Scale menu selected item uses background/text highlight only, no radio dot. Accessible radio selected state retained.


## Compact multiple filters — 2026-11-07
Remove applied filter chip row under toolbar. Support multiple assignees/supervisors; avatar buttons toggle independent assignee selections. OR within people/status/type selection, AND between filter categories; preserve parent/subtask filter behavior. Selected avatars/checkbox rows and filter count indicate active filters. Clear stays inline/in popover. No API/DB changes.


## Remove duplicate bottom information — 2026-11-07
Remove duplicate bottom Campaign start/end controls, duration/milestone legend and daily-scroll caption. Keep functional horizontal scrollbar aligned with calendar. Top date fields/ruler remain unchanged; no API/DB change.


## Toolbar order — 2026-11-07
Place Campaign dates/Today/scale toolbar above search/people/filter toolbar. Keep filter toolbar directly above timeline ruler. Preserve responsive wrapping and functionality.


## View controls in filter row — 2026-11-07
Date row contains only Campaign start/end. Today and scale menu move to the right side of the filter row immediately above ruler; preserve wrapping on narrow screens.


## Personal-work dropdown styling — 2026-11-07
Replace native personal-work filter dropdown with themed radio menu, selected background/text highlight only (no dot). Preserve all/related/assignee/supervisor options and logic, vi/en labels and keyboard support.


## Filter checkbox layout — 2026-11-07
Filter checkbox labels stay adjacent to checkbox, using available panel width. Long names wrap naturally without pushing text to far edge. Fix assignee, supervisor, status and type choices locally, shared Input unchanged.


## Deliverable choices and filter audit — 2026-11-07
Deliverable filter supports multiple checkbox selections (OR within deliverables, AND with other categories). No selection means all. Sidebar category labels wrap within column, no overflow. All selectors in timeline filter popover are inline choices: people/status/type/deliverable checkboxes, schedule mutually exclusive radio list; toolbar mine/zoom remain themed menus. Existing closure/version workflows untouched.


## Compact popup width — 2026-11-07
Reduce filter popover width to440px desktop; allocate164px category column so Vietnamese field labels remain one line. Constrain popover to viewport width. Truncate only extreme long category labels with full title; option names keep usable right-pane space.


## Optional strategy and selected-package navigation — 2026-11-07
Deployment strategy is optional. Readiness has four required conditions: package prepared/current, valid Campaign dates, exact package-generated Tasks, all Tasks with deadlines. Strategy editor remains available, never blocks deploy. A chosen Workspace package opens navigation for Manager/Client regardless negotiation approval/preparation status; no package retains package/chat gate, existing role access rules remain. Desktop/mobile consistent. No fake approval or DB backfill.


## Compact Campaign layout — 2026-11-08
Timeline uses full page width. Strategy auto-save disclosure sits top right. Deployment action sits right of Campaign dates; conditions appear on hover/focus and an explicit accessible toggle for touch/disabled action. Preserve deployment confirmation, permissions, status, retry and closure. Feedback is a bottom-right round trigger with unread Client FEEDBACK count, excluding own events; opens a non-modal panel with existing comment permissions. Read watermark is browser-local per user/workspace/campaign, no server read-state claim or DB changes. Refresh feedback every30s while tab active. Preserve draft text, errors, VI/EN, dark/light, responsive and keyboard/Escape.


## Feedback conversation — 2026-11-08
Client and active Workspace Manager may send Campaign feedback; other roles remain read-only. Manager messages store AGENCY actorSide and notify existing opposite recipients; Client messages keep CLIENT. Preserve workspace scope, version check and no Campaign state mutation. Enter sends once, Shift+Enter inserts newline, IME Enter does not send; pending/blank prevented. Add a labeled link to /workspaces/:id/chat with no package/channel context.


## Rich strategy — 2026-11-08
Strategy editor reuses chat formatting toolbar and Tiptap. Provide a short localized empty placeholder suggesting objective, audience, channels and main activities. Enter creates normal paragraphs/list items, never sends. Preserve auto-save on leaving editor region or closing overlay; toolbar/link focus stays in editor region. Legacy plain text loads literally; new formatted content is HTML in existing strategyDetail string, max10000 stored characters, optional empty string. Safe Tiptap parsing/URL allowlist; never raw untrusted HTML rendering. Existing Campaign detail/form must not expose markup. Preserve version errors/draft and disabled roles. No schema migration.


## Vietnamese and loading feedback — 2026-11-08
Translate ordinary English domain words in Campaign/Package VI labels, leaving user data, identifiers and technical file formats untouched. Campaign page initial package read uses skeleton, existing Campaign/timeline initial skeleton remains. Package workspace skeleton matches detail-left/catalog-right layout; catalog wait uses compact card placeholders. Creating/moving/resizing a duration shows an immediate localized skeleton in the target lane through mutation and refetch. Only active row shows saving geometry; no persisted optimistic result or status change. Cancel shows no pending, error restores old/unscheduled lane, duplicate submission blocked.


## Completion checklist at the action — 2026-11-08
Manager checks campaign completion in an anchored popover at the completion button; no navigation or replacement work area. Hover/focus previews, click pins, touch/keyboard remain supported. The checklist uses the existing completion-check contract (deployment, unfinished tasks, reviewing requests, unlinked legacy tasks). Pending unaccepted requests retain the auto-cancellation warning. Optional task cancellation and final completion require separate explicit confirmations; server permissions/version checks remain authoritative. No API/schema changes.

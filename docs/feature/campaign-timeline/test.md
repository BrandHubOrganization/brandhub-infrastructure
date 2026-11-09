# Verification scenarios

- Manager/Creator/Client read capabilities are server-controlled; no cross-workspace access; Client cannot mutate Task or subtask.
- Defaults: new planned start is local today; end is two calendar days later; supervisor creator. Old records remain null until explicitly scheduled; firstStartedAt unchanged.
- Drag body preserves duration; edges require end>start. Cross Campaign/parent bounds succeeds. Campaign dates, milestones, Post schedules and statuses unchanged. Keyboard/date-picker alternatives work.
- Simultaneous schedule/subtask writes: one revision wins, stale mutation conflicts; retry fetches current data. No lost embedded subtasks.
- Inline assignment validates workspace/role and preserves other fields. Selected picker item highlighted, not duplicate label.
- Enter adds one subtask (composition guarded), preserves assignee, resets name/dates and refocuses; duplicate submit blocked. Failed create retains text. Calendar is icon-triggered.
- Personal filters correctly distinguish assignee, supervisor and both; task/subtask search retains parent context; resetting filters restores rows.
- Column widths respect min/max, persist per user/workspace and support keyboard; labels truncate with full accessible name. Weekends/today align to workspace day.
- Campaign auto-save serializes versions; failure retains dirty field and disables deploy. Client feedback has its own error/empty/loading state and unsent text survives Task changes. Task dialog reuses real controls/comments/subtasks.
- i18n vi/en key parity; light/dark contrast; keyboard and reduced motion; responsive 375/768/1440 internal overflow; no row-by-row API waterfall.
- Additive migration preserves all existing validators/indexes/data, supports DRY_RUN/APPLY and rerun. New init and seeder emit matching planned date types; no shared DB writes.

## Verification results — 2026-11-07

- Web TypeScript check and production build: PASS. Campaign ESLint: no errors. Full-repository lint remains blocked by an unrelated Dashboard `no-useless-assignment` error observed during this run.
- Browser QA with intercepted local API fixtures: PASS for inline assignment, continuous Enter creation/refocus, parent-preserving filters, column keyboard resize, drag outside Campaign bounds, edge resize, Task dialog, Client feedback, VI/EN, dark mode and responsive widths 375/768/1440. No uncaught JavaScript errors or unhandled API routes. Failed Campaign save retains text and blocks deployment until retry succeeds. This is not a live-service end-to-end test.
- Existing targeted Business tests and compile: PASS (workflow, dates, store, fields, subtasks, plan validator and sample seeder). Additional local-only harness: PASS for stale revision, role/status guards, date ordering, no status/Post mutation, timezone defaults and legacy subtask preservation.
- Isolated Mongo 7: fresh init PASS; migration DRY_RUN no writes, repeated APPLY idempotent, existing validators/indexes/documents preserved, invalid date types rejected, invalid existing documents blocked.
- Large fixture: 500 Tasks / 5,000 subtasks; filtering/flattening checked, rows are virtualized. This does not establish server-scale load capacity.
- Atlas `brandhub`: migration `2026-11-07-campaign-timeline.js` applied on 2026-11-07 after explicit user authorization and clean DRY_RUN (`invalid=0`). Verified both optional fields accept date/null; Task count remained 156; indexes and validation level/action unchanged. No record backfill or other collection writes. Deploy/restart the matching Business and Web builds before testing.
- New QA scripts, screenshots and harness classes are local-only, outside tracked source tests.

## Layout refinement cases
- At desktop widths, timeline bottom follows viewport; right info never inserts a full-width block above it. Pinned column separators and date axis align after resize/scroll/zoom.
- Preview milestone date matches pointer under all zooms and horizontal scroll. Click focuses name; Enter saves exactly once; IME Enter does not submit; empty name stays local; Escape/outside click cancels without API.
- Version conflict/save failure retains draft and disables deployment; retry is explicit. Busy/in-progress/read-only roles cannot create/edit. Limit 100 is enforced without losing local text. Existing marker rename/date/delete preserve unrelated timeline fields and data.
- Unscheduled lane previews explicit dates, click starts editing/range selection; no implicit backfill from rendering.
- Light/dark, VI/EN, 375/768/desktop and keyboard input; no production calls or database mutation.

## Layout refinement verification — 2026-11-07

- Browser QA on actual React components with all API requests intercepted: PASS. No unhandled routes or uncaught JavaScript errors; deliberate 503/409 responses were exercised.
- Milestone hover/click exact-day mapping, inline Enter, Escape/outside cancel, empty/IME Enter, keyboard add, rename, date control and two-click deletion: exercised. Save error retains input and blocks deployment. Concurrent append is preserved on explicit retry; remotely renamed marker cannot be overwritten silently.
- No Campaign end date: dashed milestone track stays usable without inventing Campaign dates. 100-marker creation limit and read-only Client behavior verified.
- Timeline geometry at 1600x1000: bottom=984px, no document vertical overflow, metadata rail on right. Day/week/fit and horizontal-scroll pointer mapping verified. Mobile allows panning calendar past non-sticky information columns; no document horizontal overflow.
- Continuous subtask Enter/refocus, filter parent preservation, assignee picker, Task dialog, explicit scheduling of unscheduled Task, Task move/edge resize remain operational. Legacy planned dates are not backfilled by rendering.
- VI/EN and light/dark screenshots captured in local QA output. Widths 375/1440/1600 exercised.
- Changed-file ESLint: PASS. Global `npm run ci` stops on unrelated no-useless-assignment errors in Agency `members.tsx:152` and Dashboard `smartPriorityAlgorithm.ts:108`; those concurrent/unrelated changes were not modified. Standalone type-check and production build verified separately.
- No Business code, shared DB, Atlas or production changes for this layout refinement. QA scripts and artifacts remain local-only.

- Additional dense-marker check: nearby milestone labels no longer intercept the neighboring diamond; two label tiers and focus/hover reveal keep the row compact. Explicit date edit verified. Month labels are clipped to their own month segment to avoid overlap at month boundaries.

## Simplification cases
- Saved widths below the new minima clamp on load; drag/keyboard cannot shrink below minima, status remains single line, assignee heading stays full. All scales respect minimum day width.
- Default daily ruler has no month title/weekend highlights; start/end references remain visible while scrolling and timeline endpoint guides reflect actual dates. Custom scroll thumb persists, syncs with native scroll and keyboard.
- Click blank task lane issues exactly one schedule request with selected start and end=start+3 calendar days, no popup; errors use existing mutation feedback, no automatic retry or backfill. Dragging still sets explicit range.
- Name input and assignee/date/add controls stay adjacent in creator; Enter/refocus still works. Strategy/date editing remains version-checked with unsaved/error retention; Client readonly.

## Simplification verification — 2026-11-07
- Browser test with intercepted API: PASS for persisted column minimums (name 200/status 120/assignee 140), full Vietnamese heading, default daily scale and minimum 32px/day across zoom modes; no month title/weekend shading or information card.
- Persistent horizontal scrollbar tested by keyboard Home/End and pointer drag; viewport stays synchronized. Campaign start/end controls and references remain fixed while scrolling; Campaign bounds no longer receive decorative date padding.
- Exactly one click schedule call stores the clicked Workspace day (verified 2026-11-09 local) and deadline three calendar days later, without opening a date popup. No rendering backfill; Client cannot schedule.
- Compact subtask name-to-assignee gap measured <=12px; Enter creation/refocus and inline milestone creation on the 56px row passed. No uncaught JS errors or unhandled API calls.
- VI/EN, light/dark and 375px/1440px/1600px layouts captured. New tests/artifacts remain local-only. No API/schema/shared data changes.

- Simplification checks: standalone TypeScript and changed-file ESLint passed. Full CI lint reports three unrelated errors: Agency Members `inviteSentence` no-useless-assignment, Dashboard `sPriority` no-useless-assignment and WorkspacePermissionsPanel no-empty-pattern; these sources were left untouched.

- Final standalone production build after simplification: PASS (`tsc -b && vite build`). Shared bundle-size warning remains informational.

## Date/column correction cases
- Campaign start set, end missing, all Task dates empty, one milestone at start: at least 14 daily labels/grid cells, no large single-day stretch or white tail. No end-date write.
- Exactly one horizontal bar is shown. Native x bar hidden; native y scroll still works. Custom thumb/arrows/keys and Shift-wheel remain synchronized.
- Compact status/assignee resize to content minima. Header truncates but tooltip stays full; all translated badges fit on one line, avatars remain whole. Widen header restores full heading; saved widths clamp on load and locale change.


## Date/column correction verification — 2026-11-07
- Direct read-only check on running local QA Workspace at 1600x1000: open-ended Campaign with one milestone renders daily labels 05/11 through 18/11. No Campaign dates or Task data changed.
- Exactly one horizontal control; next arrow changes scroll position, Home/End synchronize the viewport. Native horizontal bar hidden; calendar fills the available width.
- Keyboard resize verified status minimum 88px and assignee minimum 52px for current data; status cells stay 36px high, badges single-line, avatars whole. Headers truncate independently and retain full title.
- Temporary browser viewport override reset after testing. Changed-file ESLint and VI/EN key parity PASS; git diff --check PASS.
- Full npm run build currently stops at unrelated src/pages/workspace/components/MembersTable.tsx:70 (unused currentRole, TS6133). This concurrent source was not changed. Earlier successful build entries above refer to the earlier workspace state.
- No API/schema/DB/production writes and no new dependency/test source files for this correction.
- Standalone Vite production bundling PASS after this correction; this does not replace the blocked TypeScript check.


## Milestone drag — 2026-11-07
Drag one diamond by two day widths: one save request, same name/new date; no editor opens after drop. Small click opens existing editor without save. Escape/cancel/no-op produces no save. Check start/end bounds, busy/Client disabled, keyboard arrows, failed-save retry and stale version. Check VI/EN and light/dark. Use isolated mocked UI, no live Campaign writes.

Milestone drag verification: isolated browser QA passed 2-day pointer drag (exactly one save), click-to-edit without save, Escape editor cancellation, keyboard one-day change, failed save retains target date and explicit retry, disabled readonly drag (no save), English labels and dark theme. No live API/DB writes. Drag Escape/pointercancel and stale-version paths implemented; not independently exercised by native browser drag. Focused ESLint PASS. TypeScript reports only pre-existing MembersTable.tsx:70 unused currentRole. QA harness stays keep-local-only.


## Inclusive deadline display — 2026-11-07
07→10 at48px/day has width192px and label4days; resizing end by48px saves11 and renders240px. Moving keeps inclusive duration. Unscheduled drag through10 saves10, not11. No .ct-drag-label or native date title during Task drag; milestone drag has no floating date while click/creation remains usable. No DB writes/backfill.

Browser QA PASS: 07→10 renders192px/4days at48px/day; resize end one day saves11 and renders240px/5days; unscheduled drag from07 through10 commits07/10 (not11). No native title on Task range, no floating drag-label element. Milestone drag date label removed; accessible dates retained. Focused ESLint and diff check PASS. No real Campaign data changed.
- Type-check remains blocked solely by unrelated MembersTable.tsx:70 unused currentRole (TS6133); no Campaign diagnostics.


## Compact timeline controls — 2026-11-07
Default scale is week. Menu offers only day/week/month, current choice highlighted; keyboard selection/Escape works. No Fit button/option. New milestone form has no date input; existing milestone edit retains date. Verify light/dark and vi/en on isolated UI; no live Campaign writes.

Compact controls browser QA PASS using isolated CampaignTimelineGrid: default week checked; menu contains exactly day/week/month with themed active state; keyboard Home/Enter selects day. New milestone form shows name/confirm/cancel only and Escape cancels. Light/dark menu checked. Existing date-editor branch preserved. Focused ESLint PASS; no API/DB writes.


### Scale selection highlight
Check scale RadioItem hides its direct indicator span, uses normal left padding, retains checked highlight and Radix keyboard/radio behavior; focused lint and diff check.


## Compact multiple filters — 2026-11-07
Select two assignee avatars: both highlighted and tasks for either match. Deselect one leaves the other. Combine status: only matching status for either selected person. Include unassigned with a selected person. Multiple supervisors OR. Clear resets arrays and results. No lower chip row or toolbar height increase on selection. Check keyboard/light/dark and focused lint/type checks; QA files local only.

Multiple filters QA: pure filter regression PASS for two assignees OR, status AND, unassigned, multiple supervisors, reset and matched subtask/parent context. Isolated browser PASS: both avatars remain pressed/highlighted; deselecting first keeps second; clear resets both; no applied chips or extra toolbar row. Focused ESLint PASS. No API/DB writes.


## Remove duplicate bottom information — 2026-11-07
Bottom shows only horizontal scroll control with arrows; no duplicate start/end text or duration/milestone legend/caption. Top date toolbar and timeline ruler still present. Verify no dead helper lint errors and production bundling.

Bottom cleanup: focused ESLint, diff check and standalone Vite bundling PASS. Removed duplicate markup and unused helper/CSS; scroll control and top date fields preserved. No DB/API changes. Full type-check remains separately blocked by previously recorded unrelated MembersTable unused variable.


## Toolbar order — 2026-11-07
DOM order: Campaign dates and zoom, then search/filter, then ruler/grid. No duplicated controls; keyboard follows visual order; existing shell handles top corners.

Toolbar order source assertion, focused ESLint and diff check PASS. Only existing rows reordered; no data changes.


## View controls in filter row — 2026-11-07
Campaign dates render first; next row has search/people/filter left and Today/scale right. Keyboard order follows visual order; no duplicate controls. Existing flex wrapping handles smaller widths.

View-control move: focused ESLint, source order assertion and diff check PASS. Existing controls reused via trailing slot; no data changes.


## Personal-work dropdown styling — 2026-11-07
Menu displays four translated options, selected item highlighted without dot; selection updates only mine while preserving other filters. Shared Radix keyboard/Escape behavior and semantic theme tokens retained.

Personal-work styling: focused ESLint and diff check PASS. Existing filter value/update contract preserved; shared themed radio menu reused, indicator hidden locally.


## Filter checkbox layout — 2026-11-07
Checkbox wrapper width16px, label gap8px, text beside it; assignee/supervisor/status/type names do not squeeze at right edge. Clicking text toggles checkbox; narrow panel wraps long names, no horizontal overflow. Shared Input untouched.

Filter-layout browser QA PASS: checkbox16px/gap8px measured for assignee and supervisor; status labels adjacent, click text selects checkbox. Scoped classes also applied to type checkboxes. Focused ESLint and diff check PASS; shared Input source unchanged; no API/DB writes.


## Deliverable choices and filter audit — 2026-11-07
Select two deliverables -> tasks from either, combined status still AND; clear -> all. Deliverable names adjacent to16px checkbox. Sidebar long VI label fits/wraps, no overlap with right pane. Schedule choices exclusive radio buttons, dates still editable. No native select/options remain in TimelineFilterBar. Check QA at desktop/narrow width and dark theme. Local QA only.

Deliverable filter verification: filter regression PASS for multi-deliverable OR and status AND/default all; isolated browser PASS for two simultaneous checks, schedule radio exclusivity, desktop/390px layouts and light/dark. Sidebar long label wraps without spill; checkbox16px/wrapper sizing retained, brand accent applied. Source audit confirms no native Select/option in TimelineFilterBar. Existing toolbar personal/scale menus are themed Radix controls; legacy closure/review selectors are outside this filter popup change. No API/DB writes.
- Final focused ESLint, diff check and Vite bundling PASS. Fixed active-filter counter typing for array deliverables. Full TypeScript check reports only unrelated MembersTable.tsx:70 unused currentRole (TS6133); no Campaign diagnostics.


## Compact popup width — 2026-11-07
Desktop popup440px with164px left column; label Hạng mục bàn giao fits one line. Viewport max width retained; category text cannot spill into content pane. Filtering unchanged.

Compact width: focused ESLint and diff check PASS; only layout classes changed. Popup capped by viewport; category text nowrap/truncate with full title. No data changes.


## Optional strategy and selected-package navigation — 2026-11-07
Blank/null strategy with otherwise valid package/task/date plan passes validation. Missing dates/deadline/task allocation still blocked. Web 4/4 enables deployment for authorized manager when clean; optional strategy empty does not affect count. Selected package with negotiation DRAFT shows Campaign link; no package still gated; existing route permissions unchanged. Check real local selected-package QA Workspace read-only, do not click deploy.

Optional strategy/navigation verification: Business Maven offline compile PASS. Isolated Java mock harness PASS for null/empty/blank strategy accepted and missing deadline/dates/task-set rejected. Live read-only browser on selected-package QA Workspace: selected package still negotiation DRAFT, sidebar shows Campaign and authorized Workspace links; Campaign prerequisites4/4, Deploy button enabled, strategy still empty. Did not click Deploy or edit data. Desktop/mobile source gates both use package presence and retain role permissions. Focused Web lint has zero errors (pre-existing Sidebar effect warning); diff check PASS. No schema/DB/production changes, no tracked test file added.
- Full Web TypeScript check remains blocked only by unrelated MembersTable.tsx:70 unused currentRole; no new diagnostics from changed files.

## Pre-commit verification — 2026-11-07
Full Web npm run ci PASS: lint completed with zero errors (existing advisory warnings), TypeScript passed and production build passed. Unused bindings/dead initial assignments in changed Agency/Dashboard/Workspace pages were cleaned before committing. Source tests and local QA artifacts were excluded from commits; shared feature verification documentation remains part of this specification.


## Compact Campaign layout — 2026-11-08
Verify full-width timeline, dates and deployment on same toolbar, strategy at top right. Hover/focus deployment reveals4conditions; unavailable action still allows condition inspection; touch toggle, Escape and deployment confirmation work. Preserve closure and retry/errors. Feedback FAB opens panel, Client feedback unread excludes own/Agency/APPROVE, badge clears only after successful data viewed, persists by user/workspace/campaign and no draft loss on close. Failed fetch does not mark read. Polling stops in background; no DB writes. Test desktop/mobile light/dark VI/EN and npm run ci.


Compact layout verification — 2026-11-08: full npm run ci PASS (lint zero errors, existing advisory warnings; type-check and production build passed). Final changed-file lint/type-check and production bundling PASS after refinements. Browser QA on actual CampaignWorkspace with mocked service contracts PASS: full-width timeline, strategy blur/close auto-save, deployment hover/details/confirmation cancellation, incomplete disabled action with accessible condition toggle, Client deployment hidden, feedback count excludes own/Agency/APPROVE, read watermark survives reload and fetch failure does not clear unread, Client draft survives close. VI/EN, light/dark,1440px/390px no document horizontal overflow; mobile feedback panel stays in viewport. FAB raised above horizontal scroll controls. No real API, DB or production writes; QA artifacts remain ignored keep-local-only. Read markers are browser-local, not cross-device server read state.


## Feedback conversation — 2026-11-08
Manager feedback stored as AGENCY, requireManager invoked, version/status unchanged; rejected Manager/Owner access cannot save; stale version rejected. Client remains allowed. Enter one POST, Shift+Enter newline, composition no submit, blank/pending blocked, failure preserves text. Chat anchor has /workspaces/ws/chat no query context. Manager and Client see composer, other roles do not. No DB migration.

Verification: Business19tests PASS (MediaCampaignServiceImplTest15 and CampaignWorkspaceAccessTest4). Manager actor side, trimmed comment, authorization, unchanged state and stale version tested. Browser QA on actual Workspace with mocked services PASS: Manager/Client Enter exactly one request, Shift+Enter newline, IME/blank do not send, Creator read-only, correct Workspace chat link. Final fixture uses unique IDs; no JS/React errors. No DB/production writes. Restart Business for updated Manager permission. QA artifacts remain ignored local-only.

Web full npm run ci PASS: lint zero errors (existing warnings), TypeScript and production build passed. VI/EN key parity and diff check PASS.


## Rich strategy — 2026-11-08
Legacy multiline/plain angle brackets remain literal. Bold/list/link survive save/reopen and readonly display; invalid URL rejected; no scripts execute. Formatting controls/link popup do not prematurely save; leaving region and Escape/overlay close save once. Enter continues lists, no send. Blank optional saved empty, max10000 HTML enforced with clear error. Stale version/save error keeps draft/retry; read-only cannot edit. VI/EN light/dark and small viewport.

Rich strategy verification: full Web npm run ci PASS (zero lint errors, existing warnings; types and production build passed). Final focused lint/type-check and bundle PASS. Browser mocked QA PASS legacy multiline/literal angle brackets; no script/image/javascript-link rendering, invalid URL rejected; bold/numbered nested lists/link persisted after save/reopen; formatting did not save prematurely; closing saves once, failed save retains draft and does not auto-retry, explicit retry succeeds; optional blank saves empty, oversize10000 HTML blocked and retained, reducing input saves, stale version keeps draft and explicit retry succeeds; readonly disabled; VI/EN light/dark390px layout fits. No real API/DB/production writes; test artifacts ignored local-only. Shared Popover forwards forceMount to Portal to retain strategy draft; strategy is currently the sole forceMount consumer.


## Vietnamese and loading feedback — 2026-11-08
No English Campaign/Task/Client/Manager/Workspace/milestone/timeline in VI static labels, names/interpolation remain literal. Delayed new range click renders pending at selected dates before response; stays until refetch finishes; success shows saved duration, failure removes placeholder. Move/resize pending matches proposed interval, original restored on error; cancel no mutation. Unrelated rows do not show skeleton. Keyboard no duplicate while pending; readonly cannot mutate. Campaign initial skeleton, Package workspace and sidebar skeleton visible with delayed data; background refetch retains current content. VI/EN light/dark reduced-motion.

Loading verification: full Web npm run ci PASS (zero errors, existing warnings; types and build passed). VI/EN key parity and ordinary-domain-label scan PASS for Campaign/Package; interpolation tokens preserved. Browser QA with manually delayed promise PASS: initial Campaign/Package/sidebar skeletons; new duration placeholder immediately at correct start/width; retained after request acceptance through refetch; only target row; success clears to duration; failed move restores saved dates; Escape drag cancellation makes no request; keyboard save and EN/dark loading verified. No real API/DB/production writes. QA fixtures/screenshots ignored local-only.


## Completion action — 2026-11-08
Browser QA uses actual CampaignClosureSection with mocked service methods in ignored keep-local-only: hover/skeleton/dismiss, click pin, blocked completion, task selection, OTHER note required, cancellation confirmation, refresh callback, final completion confirmation/exactly one call, unchanged URL. Error/retry, close, Escape, mobile viewport and EN labels checked. No real API, DB or production writes. Existing backend permissions and CAS/version contracts unchanged.

Completion verification result: final npm run ci PASS (lint 0 errors, existing 106 advisory warnings; TypeScript and production build passed). Changed-file lint PASS without warnings. Browser QA additionally verified ArrowDown focus, completion API failure with recheck, no false success/no automatic mutation retry, and explicit manual retry. QA fixtures/screenshots/logs are Git-ignored local-only. No DB changes.

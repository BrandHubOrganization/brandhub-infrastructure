# Implementation tasks

- [x] Confirm approved sketch and inspect existing permissions/API/schema.
- [x] Add planned date fields, scoped bulk read and atomic schedule update.
- [x] Default new tasks/subtasks and supervisor; preserve old records.
- [x] Update Mongo init, additive migration and Business seeder.
- [x] Implement timeline, ranges, resizeable columns, weekends/today.
- [x] Implement search/filters, personal relationship and hierarchy preservation.
- [x] Implement compact continuous subtask creation and member picker.
- [x] Implement same-page Campaign auto-save, prerequisites, Client feedback and Task dialog.
- [x] Update vi/en campaign.json keys in parallel.
- [x] Check light/dark mode and keyboard/mobile behavior.
- [x] Run Web CI, backend checks and local migration verification; report limitations.

## Layout refinement
- [x] Move metadata/date/strategy into right rail, maximize timeline height.
- [x] Implement inline milestone preview/create/edit, cancellation, retry and permissions.
- [x] Align scale/grid, fit-to-view, pinned separators and unscheduled state.
- [x] Update vi/en; verify light/dark, keyboard, responsive and conflict/error behavior.

## Simplification
- [x] Daily scale, readable minimums, remove weekend/month header; compact Milestone row.
- [x] Move Campaign dates to toolbar, remove information card; persistent horizontal scrolling and endpoints.
- [x] Direct +3 day scheduling and compact subtask input layout.
- [x] Verify vi/en, light/dark, drag/resize/keyboard/scroll synchronization and readonly roles.

## Date/column correction
- [x] Repair open-ended planning range and verify date continuity.
- [x] Compact content-based column limits; clipped heading only, full tooltip.
- [x] Single clear scroll control, previous/next arrows and horizontal wheel.
- [x] Direct user-page verification of dates, scrollbar and compact columns; focused lint. Full build attempted; unrelated Workspace type-check blocker recorded in test.md.


## Milestone drag — 2026-11-07
- [x] Implement milestone drag/drop, cancel, keyboard and version-safe retry.
- [x] Add parallel vi/en hint and verify theme/permissions.
- [x] Verify local mocked drag saves, editor cancellation, keyboard, retry and readonly behavior; run compile/lint (compile blocker below).


## Inclusive deadline display — 2026-11-07
- [x] Fix inclusive deadline rendering and unscheduled selection.
- [x] Remove floating drag dates; preserve accessible labels.
- [x] Verify width/date mapping with local-only browser harness; focused lint PASS, type-check result recorded in test.md.


## Compact timeline controls — 2026-11-07
- [x] Simplify milestone add editor and timeline toolbar.
- [x] Verify themed menu, keyboard and default week; run focused checks.


### Scale selection highlight
- [x] Remove scale radio dot locally, retain selected highlight and semantics.


## Compact multiple filters — 2026-11-07
- [x] Remove applied chip row and enable multiple people filter selections.
- [x] Verify independent avatar toggles, combined filters, reset and hierarchy preservation.


## Remove duplicate bottom information — 2026-11-07
- [x] Remove repeated bottom labels and preserve functional scrollbar.
- [x] Run focused lint, diff and production bundling checks.


## Toolbar order — 2026-11-07
- [x] Reorder date and filter toolbars; verify scoped lint/diff.


## View controls in filter row — 2026-11-07
- [x] Move Today/scale controls to filter row and verify lint/structure.


## Personal-work dropdown styling — 2026-11-07
- [x] Replace personal-work dropdown and run focused lint/diff.


## Filter checkbox layout — 2026-11-07
- [x] Fix checkbox wrapper/text sizing across filter groups.
- [x] Verify rendered geometry and selection on isolated browser, lint/diff.


## Deliverable choices and filter audit — 2026-11-07
- [x] Convert deliverables to multi-checkbox and fix sidebar label overflow.
- [x] Audit all timeline filter selectors and replace remaining native schedule dropdown.
- [x] Verify multi-deliverable logic, checkbox/radio selection, theme/responsive layout and focused checks.


## Compact popup width — 2026-11-07
- [x] Compact filter popup and make category labels one line; focused lint/diff.


## Optional strategy and selected-package navigation — 2026-11-07
- [x] Make strategy optional in frontend/backend deployment readiness.
- [x] Open desktop/mobile navigation on package selection.
- [x] Verify empty strategy accepts otherwise ready plan, missing deadlines still rejected; verify selected DRAFT package sidebar and no real deploy/DB writes.

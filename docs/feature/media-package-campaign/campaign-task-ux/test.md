> Checkpoint 2026-10-17: restored specification and historical verification for retained Media Package/Campaign UI. Task UI changes described as rolled back remain out of this UX scope. API/classification changes after this checkpoint are governed by the Media Package package-simplification spec; historical fixture test results are not a new verification run.

# Validation scenarios

1. Campaign without approved package: clear explanation and working workspace package link, no create/deploy controls.
2. Existing draft: guidance leads to review; approved campaign guidance leads to deployment; in-progress/completed guidance leads to tasks. No change to approval permissions.
3. Type several characters rapidly: one search request after settling, page resets to zero. Enter applies immediately. Older responses never replace newer results.
4. Search with no matches: reset remains available and restores unfiltered tasks. Empty workspace explains that campaign deployment or accepted content requests create work.
5. Keyboard: focus title and press Enter to open task; close restores focus. Sort buttons work with keyboard. Read-only badges have no dropdown arrow and table has no inert selection controls.
6. Change task view, reload and navigate back: view remains correct; selected task query parameter is preserved. Existing unsaved edit guards still run.
7. Switch vi/en: new labels translate and locale keys remain parallel.
8. Light/dark screenshots, widths 375/768/1440: filters wrap, controls remain usable, tables scroll within their container.
9. Run typecheck, build, scoped lint and existing unit tests. Use browser fixtures when live authenticated backend is unavailable; report that limitation explicitly.

## Results
- Subsequent scope rollback: Task source and translations now match pre-session HEAD, and the added separate WorkspaceTaskView.tsx has been removed. The Task verification results below describe the earlier implementation and do not apply to the restored Task UI. Media sources/locales/tests were checked by hashes and left unchanged during rollback.
- Browser verification passed using Playwright CLI and local API fixtures. Verified debounce (one request for rapid typing), immediate Enter, page reset, filtered-empty reset, stale response protection, error retry, initial empty guidance, keyboard open/close/focus restoration, sorting direction, view URL/reload, stage guidance, prerequisite link and role-aware navigation.
- Responsive checks passed at 375, 768 and 1440px for task list and campaign. No document-level horizontal overflow; the table scrolls within its container. Also captured board screenshots. Light/dark and Vietnamese/English UI verified.
- Existing unit tests: `npm run test -- --configLoader runner` — 2 files / 3 tests passed.
- Changed-source ESLint: 0 errors; 2 existing warnings in useTasks' unchanged load effect and cleanup. `git diff --check` passed.
- TypeScript: full typecheck remains blocked by 12 existing errors outside this change. An in-memory compiler-host comparison against HEAD produced baselineErrors=12, currentErrors=12, introducedErrors=[]. No worktree/stash mutation was needed.
- Production asset build: `node node_modules/vite/bin/vite.js build --configLoader runner` passed. This does not mean the normal typecheck + build pipeline passes; the existing TypeScript failures still need repair before release.
- Unsaved-edit and business permission guards were preserved and reviewed. Browser checks used fixture APIs and did not approve, deploy, save or modify real campaigns/tasks. Live backend integration and production deployment were not verified.
- Artifacts: `brandhub-web/output/playwright/campaign-task-{setup,verify,final-check}.js` and screenshots `tasks-list-{375,768,1440}-light.png`, `campaign-{375,768,1440}-light.png`, `tasks-desktop-dark.png`, `campaign-desktop-dark.png`.

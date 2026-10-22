# Technical plan

1. Extend existing `TaskStartAction` with explicit row/detail presentation; reuse
   its existing await-start → navigate flow rather than duplicating it in rows.
   Add synchronous in-flight guard and use the successful Task response identity.
2. `TaskRowActions` uses that action for assigned TODO tasks. Non-writing branches
   use existing translated readonly/review labels; assigned IN_PROGRESS keeps
   Write post and direct Editor navigation.
3. Update `src/i18n/locales/{vi,en}/tasks.json` with writePost and revised startHint.
4. Verify in Playwright with isolated browser response fixtures. Intercept all
   mutating requests; simulate Start success/failure without changing real data.

Affected Web files: `src/pages/tasks/components/TaskStartAction.tsx`,
`src/pages/tasks/components/TaskRowActions.tsx`, and the two locale files.
No hook/API/DB contract changes. Preserve unrelated dirty Credit work.

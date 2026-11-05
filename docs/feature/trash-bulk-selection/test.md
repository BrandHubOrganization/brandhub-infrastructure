# Verification scenarios
- Select one then multiple files/folders: shared action count tracks selection; no row-level destructive actions.
- Select all visible eligible rows, mixed state, keyboard checkbox toggle and clear selection.
- Restore selected only; failures stay selected and display retry information; current versions used after refresh.
- Selected permanent delete: cancel sends no request; confirm sends only permitted selected targets.
- Empty trash with filters/page: confirmation states global scope; folder-only trash can be emptied; referenced folders kept; nested successful parent tree not retried as missing child.
- Actor/workspace changes stop later batch requests and stale toast updates.
- Mutation locks tabs, filters, pagination and selection; async removal releases storage later.
- Both vi/en keys parallel; light/dark semantic colors and mobile wrapping; labels accessible by keyboard.
- Backend folder ownership and reference validation remain intact; frontend npm run ci succeeds.

## Verified 2026-11-05
- MaterialPermanentDeleteServiceTest, MaterialFolderPurgeTest and MaterialRepositoryHttpTest: 26 tests passed, including nested folder de-duplication, blocked folders and snapshot cutoff rejection.
- Playwright trash-selection.spec.ts: desktop light 1440px, mobile dark 375px, independent parent/child restore and disabled protected rows, English tablet dark 768px. Four scenarios passed using intercepted API fixtures; no real workspace data deleted.
- Vitest materialTrash.test.ts: four policy/translation parity tests passed.
- npm run ci: lint/type-check/production build passed; repository still reports 82 lint warnings and existing large chunk warning. Targeted changed-file lint passed.
- Visual review: checkbox list, shared action toolbar, global clear button; Vietnamese mobile source tabs wrap correctly; both themes readable without horizontal page overflow.

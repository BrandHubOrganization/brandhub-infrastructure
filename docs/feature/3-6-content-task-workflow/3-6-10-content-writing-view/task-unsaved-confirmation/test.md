# Acceptance tests

Dirty/failed draft + close/switch/reload/view change/internal navigation opens application dialog, never a JavaScript confirm. Keep editing/Escape/outside keeps draft and attempted action is not executed. Discard clears session and executes only original action once. In-flight writes block leaving and never permit discard. No dirty fields means no confirmation. URL Back cancellation restores prior Task selection. Stale effect/unmount cannot resume an obsolete action. Keyboard focus starts on Keep editing and returns appropriately; both languages/themes are readable. Browser refresh/tab-close native protection is intentionally retained. Browser tests use mocked API only; no live data writes.

## Verification 2026-10-17

- Isolated Playwright browser, mocked API: failed-save description draft -> close -> custom Dialog; initial focus Keep editing; Escape retains draft; Keep editing retains draft; Discard closes Task and clears task URL parameter. No native dialogs recorded. The mocked save intentionally aborts and causes an expected network error.
- Four TaskEditSession Vitest tests passed (discard notification, normal saves, pending protection, clearing failed queue on discard).
- Changed-file ESLint: zero errors; existing Provider hook-export Fast Refresh warnings remain (2).
- TypeScript: no Task errors; whole-Web check blocked by existing errors in Content Writing, Editor, Workspace Dashboard and AppRoutes. No fixes made to those modules.
- git diff --check passed. No backend/database changes or live writes. Theme variants and exhaustive navigation scenarios remain manual acceptance.

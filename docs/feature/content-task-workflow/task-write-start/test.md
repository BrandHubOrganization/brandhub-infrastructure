# Test checklist

1. Assigned TODO POST, row: one Write post click sends one Start request with the
   current revision; before response no Editor navigation. Success opens the
   correct Workspace/Task Editor. Pending button is disabled.
2. Start failure (403, incomplete brief, revision conflict, storage failure):
   inline alert, no navigation; retry can succeed, no unhandled rejection.
3. Repeated click while pending: one Start request only.
4. Task Detail Write post uses the same successful start-and-open flow.
5. Assigned IN_PROGRESS: Write post opens Editor with zero Start calls.
6. Unassigned/other assignee: no write/start action; readonly open remains.
   IN_REVIEW opens approvals, terminal tasks are not restarted.
7. Non-POST Start work remains available and does not navigate to Post Editor.
8. Keyboard Enter triggers once. Check 375/768/1440, vi/en labels, light/dark,
   and inline alert focus. All test mutation responses are browser fixtures.
9. TypeScript, changed-file ESLint, locale key parity and git diff whitespace.

## Results

- PASS: real React components + browser-only API fixtures verify one Start call,
  revision 42, disabled pending button, duplicate-click prevention, and navigation
  only after the held response is released.
- PASS: 403, validation, revision conflict and storage error stay on the list with
  focused inline alert. Manual retry after conflict succeeds.
- PASS: additional `VALIDATION_ERROR` fixture uses the actual Backend error code
  and missing-description details; one attempted Start, no navigation.
- PASS: already-started opens directly without Start; unassigned/other assignee
  has no write/start action; review opens approvals; terminal tasks never start.
- PASS: detail starts and opens Editor; non-POST starts without Editor navigation.
- PASS: row action visible after table scrolling at 375/768/1440, English label,
  keyboard Enter, and light/dark screenshots. Existing table horizontal scrolling
  is unchanged; this is not a table layout redesign.
- PASS: npm type-check, changed-file ESLint, Prettier, locale key check, diff check.
- All Start responses were intercepted fixtures. Zero unexpected mutating calls;
  no real Task assignment/start, database migration, Post save or paid AI call.
  Browser checks/scripts/screenshots are ignored under output/playwright; no
  test source under src. No commit or push.
- Full live mutation flow remains for manual testing on a valid assigned Task.

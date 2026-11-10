# Verification

Use mocked HTTP/STOMP and a separate browser session; no real messages or DB writes.

- Default desktop width is 480px when space permits and wider than the old 320px.
- Dragging left grows the thread; right shrinks it. Extremes clamp without overflow
  and leave the main conversation usable. Changing container width re-clamps.
- Left/Right keyboard adjusts size; Home/End reach limits; Enter/double-click reset.
  Separator has an accessible name, orientation, numeric bounds and current value.
  Header menu chooses compact/standard/expanded without dragging or keyboard input.
- Escape or pointercancel during dragging restores the starting width; lost capture
  and panel unmount do not leave global selection/cursor/listener side effects.
- Typed thread draft survives resizing; separator focus survives keyboard changes. Close/reopen retains preferred
  width; switching to another panel does not apply thread sizing to it.
- At 375/768 widths the existing Sheet fits the viewport and no separator is present.
- Check vi/en, light/dark, keyboard focus and widths 1280/1440/1920. Also measure a
  chat host narrowed by a simulated app sidebar, not just a full-viewport fixture.
- Run Web lint/type checking/build. Do not add executable tests under src.

## Results — 27 October 2026

- 39 browser assertions pass using mocked HTTP/STOMP in an isolated Playwright CLI
  session. Real pointer movement/capture and keyboard inputs verify both resizing
  directions, bounds, reset, Escape, pointercancel and lost capture. The exact editor
  DOM element and typed draft survive resizing. Presets, close/reopen preference,
  automatic clamping and restoring the desired width all pass.
- Twelve desktop combinations pass: vi/en, light/dark, 1280/1440/1920. A simulated
  280px app sidebar reduces the real chat host; at 1280px viewport the thread clamps
  to 398px and the main conversation still has at least 320px, with no overflow.
  Separate 375/768 checks verify the existing Sheet fits and no desktop handle/menu
  appears. Non-thread panels remain 320px wide.
- No unexpected console/JavaScript errors, native dialogs, messages or schedules.
  Screenshots in both themes were reviewed. Browser QA uses no real account/session,
  and no backend/database or paid service was called.
- Targeted ESLint, production build (including TypeScript) and parallel locale keys
  pass. Existing chunk/import warnings remain unrelated. Executable QA/logs are
  ignored under keep-local-only; no executable test files were added under src.

No backend/init/seeder/migration change is required. Runtime preference lasts while
ChatWorkspace is mounted, not across a reload. Browser QA and its Vite server are
closed after verification; reviewed test screenshots are removed.

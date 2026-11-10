# Resizable chat thread

## Scope

Confirmed 2026-10-27: make the thread panel wider and allow resizing. Change Web
layout only; keep chat APIs, permissions, drafts, message ordering and database
unchanged. Other workspace panels retain their existing width.

## Acceptance criteria

- Desktop thread starts at 480px instead of 320px, clamped to the actual space
  remaining after chat navigation. Normally preserve at least 320px for the main
  conversation; if the host is unusually narrow, split its available space safely.
- Drag the left separator to resize. Keep the preferred width while the chat
  workspace remains mounted, including closing/reopening the thread. Re-clamp when
  its container changes size; never create horizontal overflow.
- Focusable separator supports Left/Right, Home/End and Enter to reset. Double-click
  also resets. Escape cancels an active drag; capture cancellation cleans up safely.
  A compact header width menu offers Compact/Standard/Expanded presets as a
  single-pointer alternative to dragging; it is available only in the desktop split.
- Resizing must not remount the thread editor or lose unsent text. Mobile/tablet
  keep the existing responsive Sheet; no drag handle in the modal layout.
- No visible keyboard instruction paragraph. Use sr-only instructions and matching
  vi/en chat.thread.resize, resizeHint, width, widthMenu, compact, standard and expanded
  keys. Existing semantic tokens
  supply light/dark colors, focus rings and a visible hover/drag grip.

No database migration, seed or backend change is required.

# Implementation plan

1. Add useChatThreadWidth to measure the existing chat section and navigation with
   ResizeObserver. Keep the desired width in ChatWorkspace so panel close/reopen
   retains it; derive clamped limits from real container space, not viewport alone.
2. Add a chat-only resizable aside with pointer capture, bounded drag updates,
   keyboard resizing, focusable separator semantics and cancellation cleanup.
   Reuse the current thread content without keys tied to its width. Do not add a
   dependency or persist a layout preference as server/business data.
   Supply a header width-menu slot to ChatThreadPanel for existing dropdown/button
   primitives and three presets, providing a pointer alternative to dragging.
3. Use the wrapper only for a desktop thread. Keep the other asides and narrow
   viewport Sheet behavior. Measure the navigation separately because it is hidden
   below the existing desktop breakpoint.
4. Update src/i18n/locales/vi/chat.json and en/chat.json together. Verify light/dark,
   keyboard/focus, pointer bounds and responsive layouts using a local browser
   fixture. Keep executable QA under ignored keep-local-only, outside src.

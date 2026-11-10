# Editor AI Content popup

Replace the editor's permanent AI sidebar with an `AI Content` button beside the autosave badge, giving the post editor more width.

## Acceptance criteria

- Hovering with a mouse opens a compact, chat-like floating assistant; clicking or pressing Enter/Space also opens it.
- The assistant contains the existing Text, Image and Video forms, generation feedback and apply actions.
- Moving from the button into the assistant or editing a field does not dismiss it. Close button, Escape and clicking outside dismiss it.
- Closing and reopening preserves the current form state and does not cancel active generation. Existing caption dialogs and result insertion still work.
- The editor and resizable Live Preview use the available width without an empty AI column. Read-only tasks cannot invoke AI tools.
- Live Preview stays to the right of the editor from 1024 CSS pixels upward, including 1024/1100px laptop layouts; below that, it stacks for mobile/tablet.
- Live Preview always offers Facebook, Instagram, TikTok and Threads using the existing platform mockups. Switching a preview does not change the platforms selected for publishing; buttons remain visible within the narrow preview column.
- Popup width/height stay within the viewport on desktop, tablet and mobile.
- New labels use parallel `editor.studio.aiContent.{button,description,greeting,close}` keys in Vietnamese and English. The autosave badge uses `editor.studio.autosaveLabel` in both locales.
- Editor translation updates during development refresh visible labels without requiring a page reload or discarding the current draft.
- Use existing BrandHub typography, semantic colors and controls in light and dark themes.

## Scope

Keep the existing AI API contracts, generation results and credit handling. This is an editor layout and interaction change, not a new conversational backend or a replacement of the AI forms.

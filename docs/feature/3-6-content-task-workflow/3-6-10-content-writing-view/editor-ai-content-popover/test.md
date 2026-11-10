# Verification

Use the actual Creator Quick Login and the existing running local app. Keep all browser scripts, screenshots and reports outside `src`.

| Case | Expected |
| --- | --- |
| Initial editor | AI Content button beside autosave, no AI sidebar; editor usable |
| Mouse hover | Popup opens without moving focus away from the editor |
| Move into popup | Popup remains usable for form entry |
| Close and reopen | Entered prompt persists; active generation is not unmounted |
| Enter/Space and Escape | Opens by keyboard; Escape closes and restores trigger focus |
| Click outside | Closes without blocking editor input |
| Text / Image / Video tabs | Existing forms render and switch correctly |
| Existing caption dialog | Opens from popup and closes independently; applying a result updates the editor |
| Generation | Existing endpoint request/payload unchanged; loading, errors and apply actions still work |
| Read-only task | AI trigger is disabled |
| 375 / 768 / 1440px | Popup fits viewport with internal scrolling; no added horizontal page overflow |
| Light / Dark | Theme tokens preserve readable surfaces, labels and controls |
| Vietnamese / English | New labels translate without showing raw keys |
| Laptop 1024 / 1100px | Live Preview remains beside the editor on the right |
| Preview platforms with Facebook-only publishing target | Facebook, Instagram, TikTok and Threads are all visible and selectable; selecting a preview does not alter publishing targets |
| Translation update in open editor | Visible text updates without reload or lost draft |
| Static checks | No new TypeScript or lint errors in changed files; distinguish baseline errors |

For UI-only result/dismissal checks, stub the generation response in the isolated browser rather than spending additional real AI credits.

## Results — 2026-10-21

- Before implementation, the browser check failed because there was no AI Content button.
- After implementation, all 14 browser checks passed: hover preserves editor focus, keyboard/reopen preserves prompt, Escape returns focus, outside dismissal, 375/768/1440px popup bounds, Live Preview resizing, image form, video polling while closed, quick text generation and application, nested three-option caption dialog and insertion, dark mode and English labels. No page JavaScript errors.
- Generation responses were stubbed in the isolated browser. This UI check did not spend additional AI credits or call video/image providers.
- ESLint passed for both changed TypeScript files. `git diff --check` passed.
- TypeScript reported the same 11 pre-existing errors before and after: three unused schedule bindings in `useEditorForm.ts`, unused `draggedEvent` and `ChevronDown` in Task components, and six missing `Link` references in `TaskWorkflowContent.tsx`. No new errors in the changed files.
- Read-only protection is retained via the trigger's `disabled` prop and hidden popup; a linked read-only task was not exercised in the browser.
- Evidence: `.tmp/editor-ai-content-20261021/after.json`, light/dark/English screenshots and screenshots at all three widths. Local verification files remain outside `src` and no commits were created.

## Label/layout follow-up

- Reproduced: preview stacked below the editor at 1024/1100px while remaining on the right at 1280/1713px. A harmless whitespace-only locale update refreshed labels by reloading the page and discarded the unsaved draft.
- Fixed: consistent `lg` breakpoint from 1024px; editor locale updates now update existing i18next bundles and notify the visible UI without a reload.
- `check-labels-layout.cjs after` passed at 1024/1100/1280/1713px, with correct button/autosave labels, live label updates and a preserved draft. The temporary whitespace change was restored in `finally`.
- All previous 14 popup checks passed again under `layout-fixed.json`; no page JavaScript errors. ESLint, Prettier and diff whitespace checks passed.
- TypeScript after the follow-up still reports only the same 11 baseline errors listed above, with none in the changed i18n/layout code.

## Preview platform follow-up

- Compared `StudioPreviewPanel.tsx` with Git HEAD: all four platform mockups already existed, but the buttons were filtered through publishing targets, whose initial value was Facebook only.
- Before: the browser check found only Facebook. After: Facebook, Instagram, TikTok and Threads all render and switch active preview; publishing selection is preserved.
- Buttons fit inside the preview at 1100px and 1440px. Existing mockups are reused. No page JavaScript errors; ESLint and diff whitespace checks passed.
- Evidence: `.tmp/editor-ai-content-20261021/{before,after}-preview-platforms.json` and the corresponding screenshots. No real posting or AI provider calls were made.

## Publish verification — 2026-10-23

- Synced the current Web feature branch with the latest `develop`, preserving the caption dialog, workspace video flow, crawl navigation and new credit error handling while resolving merge conflicts.
- Restored local popup/preview changes after the merge. Updated existing browser test entry points to open AI Content and updated the caption fixture to return the actual trend-fit response shape.
- `npm run build` passed, including TypeScript checking. The 11 errors recorded on October 21 are no longer present after pulling upstream fixes; an unused dashboard type import produced during the merge was removed.
- Playwright: 5/5 targeted tests passed, covering blocked adapted content, generated-caption insertion, stale adapted versions after regeneration, refinement platform preservation and rendering all three AI tools.
- AI service: 13/13 hashtag extraction/fusion tests passed after updating from `develop`. Existing datetime/pytest-asyncio deprecation warnings remain.
- Tests used mocked APIs; the temporary browser test server stopped afterward. No application containers or backend processes were started.

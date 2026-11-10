# Verification
- VI/EN: translated labels, no fixed hashtag/template numbers; keys remain parallel.
- Search/type filtering/sort/advanced filters preserve query behavior; reset clears filters.
- Folder-only result shows folders and no false empty repository message.
- Loading shows skeletons; errors retain retry; empty search offers reset.
- Upload/delete/restore/promote/download retain existing permissions and handlers.
- Keyboard: tab focus visible, menu/disclosure open with keyboard; no hover-only actions.
- Light/dark and 390px/1440px: semantic colors, legible labels, no page overflow.
- Run targeted ESLint, npm run ci; if baseline lint blocks, run production build separately.

Results: Targeted ESLint, type-check and production build PASS. Headless Chrome with actual components and mocked service responses: desktop/mobile overflow, VI/EN, keyboard filter disclosure, media filter, secondary menu, empty results PASS. Light/dark/390px screenshots reviewed. Full CI blocked by pre-existing react-hooks/purity error in SurveyFormBuilder.tsx:58. Live authenticated backend flows were not exercised.

Upload refinement: picker works with keyboard; metadata defaults unchanged; client profile visible whenever required; limits available on demand; progress/error/cancel intact.

Upload refinement verification: targeted ESLint and TypeScript/production build PASS. Browser upload flow not exercised in this refinement.

Actual Chrome: picker text width >150px, no vertical wrapping, compact default form; options disclosure, selection with long name, invalid-file validation, close/reopen, mobile overflow, dark contrast. Do not upload to live service for verification.

Actual authenticated Chrome verification (upload fix): reproduced narrow text caused by shared Input wrapper; replaced with native input. Iteration 2 caught long-name overflow from fieldset min-inline-size; added min-w-0 and rechecked at 390px. Final form 142px at 1440px, 182px at 390px; text stays inside picker, no duplicate launcher. Verified file selection enables submit, invalid txt fails locally, keyboard disclosure/file focus, required client profile blocks submit, close/reopen resets form. Visually reviewed actual mobile light and desktop dark screenshots. Restored light theme. No file was sent to the live upload service. Targeted ESLint and final production build PASS.

Chrome at desktop and 390px: search/types/sort/filter remain usable, no overflow; storage warning remains visible; folder creation reachable; scroll to final storage disclosure.
Density build and targeted lint PASS. Actual Chrome bottom storage disclosure reachable. Right-side gap traced to leftover DevTools viewport emulation; cleared with emulate({}), verified innerWidth/root width 1536 and screenshot fills window. Always reset emulation after responsive checks.

Click launcher opens native file chooser and no modal. Cancel chooser causes no upload. Unsupported/empty file shows inline error. Valid file calls existing pipeline with safe defaults. Profile ambiguity never silently selects another client.

Direct upload verification: Chrome observed launcher dispatching native file-input click (default chooser prevented once to avoid blocking automation), no upload modal. Injected unsupported txt file produced inline validation without upload. Reload restored clean state. Targeted ESLint and final production build PASS. Valid live upload was not exercised.

Drive opens near upload; no footer group. Usage reflects API, expansion reveals storage upgrade without making purchases. Mobile no overflow. Existing quota notice stays visible.

Storage/Drive separation: actual Chrome import form opens from secondary action; storage summary opens upgrade controls, footer group absent. Desktop screenshot reviewed. At 390px first check found card clipping by 2px, reduced mobile card width and verified right edge 344px, no overflow. Emulation cleared. Targeted lint and final production build PASS. No Drive imports or purchases executed.

Drive opens one URL input and Import action; no selectors or notice. Empty link disables submit. Status/errors remain conditional.

Link-only Drive: actual Chrome shows 1 URL input, 0 selects, Import button disabled when empty; desktop form row 36px, screenshot reviewed. At 390px visible input 333px, no overflow. Emulation reset. Targeted lint and production build PASS. No import executed.
Compact Drive row: removed outer card, max width 448px and right aligned on desktop, one 36px row with adjacent Import button. Chrome verified 448x36 desktop and 358x36 at 390px, no overflow; emulation reset. Targeted lint/type-check PASS.

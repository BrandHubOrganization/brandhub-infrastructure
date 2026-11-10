Verify no MATERIAL grants can be created through cross-workspace endpoint; batch validation completes before writes; source/client ownership required; future child files inherit folder access; existing legacy reads preserved. Validate folder-only checkbox UI, source workspace reset, loading/error/empty states, and successful update in B.

Fallback tests: allow owner/source collection, reject source with folders/empty inventory, deny other owners/origins, include future files, revoke denies access. UI fallback only at root with no folders and nonempty files.

Whole-workspace fallback verified 2026-11-05:
- Red before fix: collection authorization test failed; share-all request rejected INVALID_REQUEST.
- Green: ClientVaultServiceTest 11, MaterialAccessPolicyTest 3, MaterialFolderAndSortTest 2: 16 tests pass.
- Component eslint and Prettier pass; npm run build passes (existing large bundle warning).
- Business restarted by user; health HTTP200.
- Chrome UI source FPT Shop x AIM Academy shows explicit unchecked "Tất cả 4 tệp của tôi". Checkbox enables "Chia sẻ tất cả tệp".
- Real UI submission into Vietjet workspace returns200 with exactly one WORKSPACE grant. Both source/target list4 identical file IDs; image preview through receiving workspace returns200. Grant retained as resulting shared collection; no objects/material copies created.
- Temporary browser observer removed. Existing folder sharing remains default; backend disallows fallback when active source folders exist or source inventory is empty.

UI: source/recipient distinguishable, no full-height blank panel, CTA disabled until explicit selection, keyboard focus, mobile width, both themes, no data mutation during visual QA.

Reuse dialog visual QA 2026-11-05:
- Compact existing Dialog component replaces full-height sheet. Desktop measured 520x371.5 CSS pixels with source/FPT and receiving/P&G names explicit.
- Primary action disabled before selection; checkbox selection enables action. No share mutation performed during visual QA.
- Chrome mobile390x844, dark theme + English: dialog358.4x415, no horizontal overflow; CTA fully on screen and enabled, focus remains in dialog. Screenshot visually reviewed.
- Source selection, full-row labels, keyboard focus and Escape close checked; original language/theme/viewport restored.
- Changed component ESLint/Prettier pass; production build passes with existing bundle-size warning.

Source picker: searchable list stays within dialog, no native dropdown overlay, whole workspace row selects source, Change workspace returns to list, selecting new source clears old content consent; no grants written during visual verification.

Searchable source picker verified 2026-11-05: Chrome headless isolated fixture using real component and mocked API. Search and no-results pass; workspace row selects source; explicit file selection enables CTA; switching source clears consent and leaves empty-source CTA disabled. Mobile390x844 dark screenshot reviewed: dialog x16..374, no horizontal overflow, no page errors. Desktop screenshot reviewed. UTF-8 and viewport set on fixture; no real grants changed. Component lint/Prettier and production build pass.

Right sidebar revision: real component Chrome fixture passes search, no results, source selection, selection reset, and mobile390px no overflow/no page errors. Desktop screenshot reviewed with sidebar docked right. Scrollable body and bottom action bar retained.

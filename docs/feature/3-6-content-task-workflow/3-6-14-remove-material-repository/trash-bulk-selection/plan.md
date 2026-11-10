# Implementation plan
1. Extend existing MaterialPermanentDeleteServiceTest to cover folder-only trash, nested folders and reference failures; run red.
2. Add folder cleanup to MaterialPermanentDeleteService through existing MaterialFolderService transactional purge, retaining file response fields and adding folder counts.
3. Add MaterialTrashList.tsx and useTrashSelection.ts for selection, guarded batch operations, confirmation and partial results. Render instead of folder/card sections only in MediaTab trash mode; share busy state with navigation/filter/pagination. Reuse button/dialog/theme tokens.
4. Update src/i18n/locales/vi/library.json and en/library.json and purgeTrash response typing/hook notification. Update empty-trash confirmation wording.
5. Verify Java purge/HTTP tests, npm run ci; browser fixture verifies selection scope, partial failures, confirmation cancellation, filtered clear, dark/light and mobile. Keep test fixtures outside src and local artifacts uncommitted.

# Plan
1. Update library/index.tsx to use the minimal PageWrapper header, responsive tabs, real media count only.
2. Reorganize MediaTab.tsx with primary upload, navigation, search, loading and empty states; collapse CustomerDrivePanel behind a labelled disclosure.
3. Simplify MaterialToolbar.tsx with type shortcuts and disclosed advanced filters; preserve every filter.
4. Simplify MaterialRepositoryCard.tsx and MaterialFolderSection.tsx secondary actions with shared Radix menus; preserve capabilities and confirmations.
5. Update src/i18n/locales/{vi,en}/library.json in parallel.
6. Verify targeted lint, type-check/build and browser scenarios if accessible.

Refine MaterialUploadForm.tsx and MaterialUploadFields.tsx; add repositoryUpload options/formats keys to both locales.

Pass upload actions into MaterialUploadFields so picker and buttons share a flex row; native sr-only input; shorten labels; verify actual authenticated Chrome page, then mobile/dark and file-selection without uploading.

Update MaterialToolbar grid ordering; use Input iconPrefix; move storage detail into disclosure. Reorder folder/empty sections in MediaTab and condition file heading in MaterialFolderSection.

Replace MediaUploadButton modal with native input/useMaterialUpload, local validation and inline status. Reuse client profile query and existing upload hook. Existing MaterialUploadForm remains for other callers.

Add StorageUsageSummary using existing usage cache key; native disclosure for StorageAddonPanel. CustomerDrivePanel becomes import form only, mounted near actions. Update VI/EN short labels.

Simplify CustomerDrivePanel, short library.simple.import label in VI/EN.

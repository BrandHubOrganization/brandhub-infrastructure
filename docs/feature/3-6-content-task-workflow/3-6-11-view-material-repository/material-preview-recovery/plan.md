# Plan
Change MaterialPreview to classify MIME/status before rendering, and request one initial preview for supported READY files with canPreview or previewUnavailableReason. Keep bounded expiry refresh and manual retry. Update src/i18n/locales/vi/library.json and en/library.json. Add Playwright regressions under tests/e2e/repository using existing fixture routes.

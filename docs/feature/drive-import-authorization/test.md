# Cases
Missing token: 400 before Mongo/Google calls. Outsider: existing denial. Valid token: root/list called without grant and job completes for empty source. 401/403/404 map distinctly; unrelated shared API mapping unchanged. Browser requestAccessToken fires synchronously from user submit, cancellation makes no import call; token not persisted/logged. Config failure and missing scope actionable. Actual Google consent requires user account interaction; do not fake consent.

Results (2026-11-04):
- Red: missingTokenFailsBeforeCreatingJob failed because old backend accepted missing token.
- Green: 3 import service tests + 9 shared/import Google API tests + 1 retired-controller test PASS.
- 6 browser token authorization unit tests PASS, including immediate popup initiation, declined/missing scope, cancellation, blocked popup and missing SDK.
- Targeted ESLint and final frontend production build PASS. Full npm run ci stops at pre-existing SurveyFormBuilder.tsx:58 react-hooks/purity error (1 error, 195 warnings).
- Restarted local business service using original classpath and service .env. Config endpoint HTTP 200; live missing-token request HTTP 400 DRIVE_IMPORT_AUTH_REQUIRED before job creation.
- Actual Chrome: user granted Google read-only consent. Job 3997e206-6291-4a80-bd10-3580f5d4a6f4 COMPLETED: totalFiles=2, importedFiles=2, importedFolders=1, skippedFiles=0, totalBytesImported=124879, errorMessage=null.
- Opened imported FPT Shop x AIM Academy folder; pose_ref.png and img_ref.jpg visible, tab total=2, no UI errors.
- No persistent agency Drive grant was re-enabled. Runtime classpath/log retained under workspace .audit/drive-import-runtime for local process.

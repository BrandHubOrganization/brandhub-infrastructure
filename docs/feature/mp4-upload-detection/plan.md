1. Reproduce the captured client failure using vd_ref.mp4 and the production validator.
2. Add regression coverage for ISO MP4 brands, malformed containers and QuickTime-only files.
3. Permit the detector alias only for MP4-compatible ftyp brands; retain envelope checks.
4. Map INVALID_UPLOAD_CONTENT_TYPE to localized non-retryable format feedback in MediaUploadButton, updating vi/library.json and en/library.json.
5. Run focused backend tests, frontend build/lint and retry the real client upload in Chrome after restarting business.

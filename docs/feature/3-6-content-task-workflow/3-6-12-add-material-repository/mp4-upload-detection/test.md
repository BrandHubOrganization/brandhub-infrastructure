Baseline: captured client vd_ref.mp4 (1707661 bytes) PUT 204, confirmation 400 INVALID_UPLOAD_CONTENT_TYPE. Local Java probe detects video/quicktime and rejects at MIME equality before structural checks.
Regression: ISO MP4 brand accepted; malformed moov/mdat rejected; QuickTime-only brand rejected when declared MP4; declared MOV remains supported. Live: original client upload must confirm READY and preview decrypted video. UI: invalid content uses parallel VI/EN keys and no retry button, semantic theme colors.

Verified 2026-11-04:
- Red: MaterialContentValidatorTest rejects ISO MP4 at MIME equality (1 error / 6 tests before fix).
- Green: MaterialContentValidatorTest 8 tests; crypto 3, encrypted storage 1, encrypted media 6, upload coordinator 1, client vault 1: 20 passing total.
- Frontend changed component eslint passes; npm run build passes (existing bundle size warning).
- Chrome actual client upload vd_ref.mp4: session 200, encrypted PUT 204, confirmation 201 READY. Material 58ca5d9e-2479-4fe4-bb75-30b48d23181d retained as intended uploaded file.
- Browser video playback succeeds: 720x1280, 11.585011 seconds, no media error.
- Backend-served preview HTTP200 video/mp4, 1707661 bytes, SHA256 e2817fa4a90166e9ac006199d7dd226879d238dda9579b172c92953f0b30f2e3 matches original.
- Temporary localhost fixture server stopped, temporary MP4 copy/probe removed.

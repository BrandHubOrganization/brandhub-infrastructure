# Tasks
- [x] Write failing tests for standalone builder and API conversion.
- [x] Make builder portable and preserve review/cinematic continuity.
- [x] Implement authenticated LTX submission and reuse existing status/media transport; mock-test authentication and submission.
- [x] Add Claude director/backend selection and transport tests.
- [x] Forward optional character image through Business and web.
- [x] Update Vietnamese/English labels and reuse existing theme tokens.
- [x] Package ZIP and verify no keys, logs, generated jobs or model weights are included.
- [x] Run focused regression checks and document remaining live-GPU checks.
- [ ] Browser verification of upload/remove/preview in light and dark themes.
- [ ] VM runtime schema compilation, one real render per mode, and public URL/key configuration.

## Revision 2026-11-18 (VACE)
- [x] VACE worker + start script + setup/ngrok on 10200; worker tests (3).
- [x] Schema, director prompt and examples in VACE format.
- [x] Director validation, size from aspect ratio, character as extra image; tests.
- [ ] Live: start_api.py compile on VM, one real 20 s render from the web.
- [ ] Web: VACE form on product-video page, vi/en keys, light/dark check, `npm run ci` + `tsc -b`.

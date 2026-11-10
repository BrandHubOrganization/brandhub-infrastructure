# Tasks

- [x] Implement dedicated provider config, normalization, segmentation, errors.
- [x] Add internal route and generated caption moderation.
- [x] Add business workspace route and structured result mapping.
- [x] Add UI checks and stale-response handling.
- [x] Update vi.json + en.json (editor namespace files).
- [x] Verify light/dark mode, keyboard and responsive rendering.
- [x] Run focused provider/API/Java tests and frontend checks.
- [ ] Verify a successful live response after replacing the current invalid/expired V3 key. Endpoint permission is granted; current probe returns HTTP 401.

- [x] Add 3-second moderation coordinator and subscription hook.
- [x] Wire main editor text and gate Publish Now.
- [x] Update vi/en locales and verify themes.
- [x] Test timer reset, cancellation, reuse, failed checks and moderation-before-publish request ordering.

- [x] Add safe structured failure diagnostics and specific issue codes.
- [x] Add vi/en recovery messages with existing theme/layout.
- [x] Verify failure classification, sensitive-data redaction and dedicated-key isolation.

- [x] Correct entity-only filter mapping and PII aliases/container support.
- [x] Name unsupported categories and translate vi/en recovery text.
- [x] Verify entity/partial-language regression, malformed filters, IWF and editor gate.

## Generic partial response diagnosis
- [x] Instrument generic incomplete response branches and verify redaction with a mocked response.

## Class entry contract correction
- [x] Correct class-entry field-pair parsing and verify severity/error regressions.
- [ ] Verify fresh editor request after service reload.

## Live schema diagnosis
- [ ] Capture safe live class-field schema, reproduce it in regression tests and verify corrected live behavior.

## Observed V3 class/value schema
- [x] Fix observed class/value schema and run regression.
- [ ] Verify fresh editor result after class/value correction.

## Partial coverage policy (ReLoop reference)
- [x] Add partial coverage warning policy and error/blocked regression tests.
- [x] Add vi/en partial-coverage message through existing themed components.
- [x] Verify backend, editor tests and TypeScript.

## User requested unsupported-as-safe policy
Implement unsupported-category policy, score propagation and detection rendering/logging; verify focused normalization.

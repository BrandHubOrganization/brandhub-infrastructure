# Verification

- Clean English and Vietnamese fixture => PASSED only when supported classification exists.
- Harmful class severity 3 => BLOCKED; severity 1/2 => WARNING; promotion/phone number alone => PASSED.
- Profanity/PII filters => WARNING; unknown, empty, unsupported, partial, invalid score or provider failure => NOT_CHECKED unless a verified blocking issue is already found.
- Long captions, emoji and segment boundaries: every character covered; segment <=1,024 UTF-16 units, overlap retained; no silent truncation.
- Missing key makes no HTTP call. Wrong key, 429, timeout, invalid JSON => NOT_CHECKED; no credential/caption in logs/errors.
- Internal route rejects absent/bad X-Internal-Key. Workspace endpoint enforces existing access checks.
- Generation/refine/adapt results carry moderation without using Deploy LLM key or altering generation billing.
- Manual check: pending, success, unavailable; editing clears verdict; older response ignored. Blocked generated caption cannot Apply; edited caption cannot use prior verdict.
- Change vi/en: all labels translated; light/dark contrast, narrow screen wrapping and keyboard activation.
- Live probe only on user-approved endpoint with benign synthetic text, output redacted. Never claim live success from mocks.

## Results (2026-10-28)
- Python: 57 passed across moderation, caption generation and provider fallback tests; provider calls mocked, live moderation key disabled.
- Java: AiCaptionServiceTest 10 passed; CaptionModerationTest 4 passed.
- Playwright: 6 focused tests passed; 5 moderation tests rerun after correct theme setup, passed. Dark/light moderation screenshots visually inspected at mobile width.
- Frontend TypeScript/build and focused ESLint passed (final lint/typecheck rerun recorded in chat). Existing build chunk-size warning remains.
- Approved live V3 request to https://api.thehive.ai/api/v3/hive/text-moderation returned 401, message Invalid or expired token. Successful live moderation remains blocked by credential validity. No credential values saved in artifacts.

## Typing and immediate publish tests
- No request at 2,999ms; exactly one at 3,000ms. Typing at 2s resets the delay.
- Clicking Publish Now at 2s sends moderation immediately, not publish; only after a successful result may publish be called.
- Clicking during an active check joins it; clicking repeatedly does not duplicate publish.
- BLOCKED, NOT_CHECKED, malformed response or HTTP failure makes zero publish requests and preserves text.
- Editing while a check is active aborts/ignores old result; it must never authorize the edited text.
- Valid exact-text result is reused; changing caption, hashtags, or workspace invalidates it.
- Empty text never checks. Unmount clears timer and aborts outstanding request.

### Typing/publish verification results
- 8 Vitest unit tests passed: exact debounce/reset, in-flight deduplication, snapshot reuse/invalidation, empty/oversized text, abort/stale responses and disposal.
- 11 Playwright tests passed with mocked moderation/publish: debounce; early/in-flight/cached request order; blocked/unchecked/HTTP-error/malformed response; edit-during-publish-check race; mobile light/dark.
- npm run build passed; focused ESLint passed; git diff --check passed. Light/dark screenshots visually inspected. Existing bundle size warning remains.
- No new live Hive request or real publish performed during these checks.

## Failure diagnostics regression
- Mock 401/403/429/500, timeout, connection failure, malformed JSON and missing key; assert NOT_CHECKED with the corresponding fixed issue code.
- Assert logs contain reason and status when available, but exclude key, caption, upstream response and exception text.
- Existing dedicated-key, segment aggregation and provider parsing tests continue passing. Locale keys must remain parallel; existing shared UI/theme layout unchanged.

Failure diagnostics results: 30 provider/service tests passed (2 endpoint/generation tests excluded because the earlier full run stalled during endpoint imports). Eight added regression cases cover specific reason codes and sensitive-data redaction. Vietnamese/English moderation issue key sets match (28 each). No live provider verification or credential changes performed. UI component styles/layout unchanged; visual verification not rerun for text-only changes.
Editor moderation coordinator: 8 Vitest tests passed (debounce/reset, reuse, deduplication, stale requests and failure handling).

## Entity and language coverage regression
- Benign fully classified text with athlete/celebrity/politician/religious_figure/likeness match => PASSED, no custom warning.
- Vietnamese-shaped partial classification (hate=0, violence=-1) with athlete => NOT_CHECKED, unsupported_violence only. Fixed diagnostics log category names but no input text. This is a synthesized provider fixture, not a captured live response.
- PII types in all supported containers warn; profanity/custom still warn and IWF still blocks. Malformed filter arrays cannot pass.
- Parallel vi/en unsupported-category keys; no unsupported group becomes PASSED. Existing Publish Now gate and coordinator regressions pass.

Entity/coverage results: 48 provider tests passed, 2 endpoint/generation tests excluded as previously documented. Editor coordinator: 8 passed. vi/en keys match; git diff --check passed. Regression fixtures are synthetic; no authenticated live request or real publish performed. Existing UI components/theme tokens are reused.
Frontend TypeScript project build (tsc -b): passed.

## Generic partial response diagnosis
Assert missing classes, unsupported language, invalid filter containers and unrecognized classes produce distinct safe diagnostics; captions and credentials never appear.

Generic incomplete diagnostics: 5 specific redaction tests and 53 provider/service tests passed; 2 endpoint/generation tests excluded. Live diagnosis awaits a fresh editor request after reload; existing 20:15/20:16 access logs alone cannot distinguish partial-response causes.

## Class entry contract correction
Mock actual HTTP payload with class/score: 0=>PASSED, 1/2=>WARNING, 3=>BLOCKED, -1=>NOT_CHECKED. Conflicting/mixed aliases cannot pass. Keep previous alias/parser/filter/transport tests. Live payload shape is not yet captured; verify original symptom in editor separately.

Class-entry correction verification: regression initially reproduced no_supported_harmful_class on class/score payload. After correction, 63 provider/service tests passed, 2 endpoint/generation tests excluded as previously documented. Default fixtures now use class/score, with explicit alias compatibility/conflict tests. No live credential transmission; user reported not yet rechecking editor. Original live symptom verification remains pending.

## Live schema diagnosis
Live schema logging must not contain caption, secret, arbitrary keys or values. Actual schema regression and live editor verification are required before claiming compatibility.

## Observed V3 class/value schema
Observed class/value shape: 0 clean, 1/2 warning, 3 block, -1 unchecked. Red regression reproduced original no_supported_harmful_class with this shape. Other alias and error regressions must pass.

Observed live shape at 20:28:58: class:str,value:int, other_fields=0. Corrected parser: 67 provider/service tests passed (2 endpoint/generation tests excluded). Live-shaped regression went red before fix and green afterward. Temporary schema logging removed. Fresh live editor verification pending.

Runtime verification remains pending: runner log last records WatchFiles Reloading at 20:29:32, without a subsequent startup or request during verification. User must retry after startup; do not claim live completion from 67 passing offline tests.

## Partial coverage policy (ReLoop reference)
Mixed supported0/unsupported-1 => WARNING with named coverage issues; mixed supported3/unsupported-1 => BLOCKED. All unsupported => NOT_CHECKED. Unsupported+malformed/timeout segment remains NOT_CHECKED. No mock safe fallback. vi/en keys match, WARNING publishes through existing gate, BLOCKED/NOT_CHECKED do not.

Partial-coverage policy verification: 72 provider/service tests and 8 editor coordinator tests passed; 2 endpoint/generation tests excluded as previously documented. TypeScript and focused ESLint passed. Locale key parity and diff checks passed. Browser partial-warning publish test pending. ReLoop mock-safe fallback and confidence thresholds were deliberately excluded.
Browser test was stopped after remaining at dev-server startup without reaching the test; no browser pass claimed. Real publishing was not performed.

## User requested unsupported-as-safe policy
Unsupported-only valid classification => PASSED. Actual harmful score1/3 => WARNING/BLOCKED with score. HTTP/malformed fails remain NOT_CHECKED. Rule matches without numerical severity have null score.

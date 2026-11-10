# Caption text moderation

## Objective and user story
Creators check generated or manually written captions before using them. Use the existing server-side DEPLOY_ACCESS_KEY for a dedicated text classification API, independently of DEPLOY_API_KEY used for generation.

## Acceptance criteria
- Generated editor captions include moderation; Creator can recheck edited captions and check the Content Writing draft explicitly.
- Results are PASSED, WARNING, BLOCKED, or NOT_CHECKED. Level 3 harmful content blocks using the generated caption; level 1/2 and profanity/PII request review. Commercial promotions and phone numbers alone do not block marketing captions.
- Changing text invalidates the visible verdict. A delayed response cannot label newer text as checked.
- Missing configuration, provider errors, unsupported languages, empty/malformed responses never produce PASSED.
- Key stays in AI-service environment, never browser, logs, tracked files, or business-service responses. Dedicated moderation uses its configured Secret Key; it does not automatically fall back to the generation credential.
- At most 8,000 characters; split into overlapping <=1,024 UTF-16-unit segments without splitting surrogate pairs; check all segments.
- Text moderation is advisory and not legal compliance or a replacement for publish-time authorization. No automatic admin sanctions.

## API contract and errors
Internal POST /api/v1/ai/content/moderate takes {text}; X-Internal-Key required. Workspace POST /api/v1/workspaces/{workspaceId}/ai/captions/moderate checks existing membership/AI access. Result {status,issues:[{code,message,excerpt}]} uses fixed application messages, not provider error text.
Provider contract: Hive documented V3 Text Moderation API, Authorization Bearer; DEPLOY_ACCESS_KEY contains the Secret Key, not the Access Key ID. The user explicitly authorized credential transmission to this exact Hive V3 endpoint on 2026-10-28. Follow the Playground contract: JSON input with exactly one text object per call, output classes with class/score (and explicitly validated class_name/value compatibility), and string_matches.

## UI states and i18n
editor.moderation: title, check, checking, PASSED, WARNING, BLOCKED, NOT_CHECKED, stale, tooLong, issue labels. Add all keys together to vi/editor.json and en/editor.json. Existing theme tokens and light/dark semantic surfaces; keyboard-accessible button and live status. Show no verdict while checking. Preserve editor text on failure.

## Definition of done and exclusions
Mocked provider/auth/error tests, frontend typecheck/build and focused UI verification. No key rotation, server-side publishing enforcement, media moderation, translation or LLM-based moderation fallback. Report successful live verification separately; current key validity can block it.

## Editor typing and Publish Now gate (2026-10-28)
- The main post editor checks caption plus hashtags once after 3 seconds without a text change. Empty text sends no request. Further typing resets the full delay.
- Publish Now cancels the remaining debounce and checks immediately, or joins the identical in-flight request. Only PASSED/WARNING for the exact current text can proceed to saving/publish API; BLOCKED, NOT_CHECKED or transport failure prevents publishing with a translated explanation.
- Reuse a valid verdict only until text/workspace changes. Ignore and cancel obsolete responses. Repeated Publish Now clicks cannot dispatch duplicate checks or publishes. No network call per keystroke.
- Show waiting/checking/verdict inline beneath the main rich text editor; preserve content on failure. Existing task/editor access remains unchanged. This gate covers the Publish Now UI entry point, not a new server-wide publishing policy.
- New parallel vi/en keys: editor.moderation.waiting, publishBlocked, publishUnavailable, changed. Light/dark semantic tokens and narrow layout must remain usable.

## Moderation failure diagnostics
Provider failures remain NOT_CHECKED. Return fixed issue codes for missing configuration, authentication failure (401), permission denial (403), rate limiting (429), timeout, connection failure and invalid response. Log only reason, exception class and HTTP status, never credentials, URLs, response bodies or caption text. Translate recovery messages in vi/en using existing UI/theme components. Do not fall back to the generation key or bypass checks.

## Entity matches and unsupported categories correction
Recognized entity-only filters (athlete, celebrity, politician, religious_figure, likeness) are informational, not violations. Preserve profanity, PII, custom and IWF handling. Read string_matches plus documented text_filters/pii_entities arrays conservatively. Harmful categories with -1 identify each unsupported category using fixed translated codes. Partial coverage with valid checked categories is WARNING; all-unsupported or malformed results remain NOT_CHECKED. Retrying does not add language support. Do not loosen Publish Now gate. Secret Key is required for Bearer authentication; Access Key ID is not usable as a bearer credential. Credential values for generation and moderation may be the same when authorized by the provider.

## Generic partial response diagnosis
Record fixed parser diagnostic reasons when a successful provider HTTP response cannot produce a complete verdict. Never infer unsupported language solely from generic partial results.

## Class entry contract correction
Accept consistent class/score and class_name/value class entries. Reject partial/mixed/conflicting aliases; retain unknown-category and unsupported-language handling. No language override, credential change or policy relaxation.

## Live schema diagnosis
Diagnose live class-entry schema using only allowlisted field names and type names; never serialize values or arbitrary field names.

## Observed V3 class/value schema
Live V3 at 20:28:58 returned class:str,value:int. Accept class/value as the primary response contract, class/score and class_name/value compatibility. Reject mismatched name/score aliases, nonnumeric severity and unknown-only classifications.

## Partial coverage policy (ReLoop reference)
User requested reference to ReLoop Hive.js. Adopt partial coverage as WARNING, not PASSED, only when at least one harmful category was validly checked and the response is otherwise valid. Retain unsupported_<category> issues. WARNING may proceed through existing editor gate. All unsupported, unsupported language, malformed payloads and transport/auth failures remain NOT_CHECKED and prevent publishing. Verified harmful severity 3/IWF remain BLOCKED. Do not copy ReLoop keyword/mock-safe fallback or confidence thresholds.

## User requested unsupported-as-safe policy
User policy: explicit unsupported categories (-1) do not create issues or prevent PASSED. API/transport/malformed failures remain unchecked. Actual detections expose severity score when provided and matching excerpt when available. Server logs may contain detected excerpt and score as explicitly requested, never credentials or full caption. Semantic classifiers without spans must not invent offending words.

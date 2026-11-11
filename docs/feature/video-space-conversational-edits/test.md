# Acceptance tests

1. Ambiguous request returns1–3 nonblank bounded questions and zero actions; no timeline mutation.
2. Questions+actions, blank/oversized questions and unexpected response fields rejected at model/BE/browser boundaries.
3. Explicit edit goes through old-compatible response and applies immediately as one native Undo batch.
4. Clarification answer includes original intent and preceding Q/A; input is bounded; new-request resets history. Project change or in-flight manual edit prevents stale application.
5. Native text and audio layers remain separately editable; preview reads changed timeline; one Undo restores original.
6. Apply success/save failure explicitly reports unsaved edit, not false unchanged failure.
7. VI/EN, dark/light and keyboard flow; existing render/download action remains separate and usable.
8. No API keys in browser, no provider network calls in fixtures, no commit/push.

Executed evidence and limits: RESULT.md. AI53/Business12/native15 tests passed; Web CI passed; five browser cases passed. Live clarification200,4.562s, no actions and unchanged snapshot. Worker-only effects remain MP4 output, not native editable layers.

Structured UX: reject1/4 options, empty/duplicate labels, unknown fields, nonboolean recommendations and multiple recommendations; accept legacy strings. First option/recommendation must not be preselected. Next blocked until answered, Back retains state, custom answer overrides choice only when explicitly selected. No network edit until final submit. Original intent plus all question/answer pairs reach the next plan. Test two-question VI/light and EN/dark flows and old free-text questions.

Structured cards verified: AI54/Business13/native16 tests, root Web CI,6 browser cases passed. Live API200 returned Vietnamese choices+descriptions and no actions/snapshot change. Screenshot inspected. Full evidence in RESULT.md.

Transcript acceptance: every send/response remains in user/assistant order; old questions are readable, only current ones accept answers. Closing/reopening preserves transcript; new request clears it. Follow-up request carries recent context without replaying prior actions; keep full latest request, bound total to4000 chars, never truncate clarification answers silently. Transcript never leaks raw element IDs or crosses a project switch. Collapsed advanced rendering remains available. EditAtlas proof must be read-only and must not transmit user footage or private prompts.

Transcript phase:19 unit/context tests, root CI, final native typecheck/build and6 final E2E cases passed. Closing/reopening and follow-up context verified. EditAtlas tested read-only, review saved. No durable user preference model or reference-video style analysis claimed. See RESULT.md and EDITATLAS_REVIEW.md.

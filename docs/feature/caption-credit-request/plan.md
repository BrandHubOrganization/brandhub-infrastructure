# Implementation plan

1. Reproduce the missing credit headers in the actual caption service with a mocked API boundary.
2. Route only generate/refine/adapt in `brandhub-web/src/services/aiCaptionService.ts` through the existing `postAiWithCredit` helper. These operations are free under the current code but still require accounting metadata.
3. Verify request keys, workspace scope, unchanged payload/envelope and balance invalidation with local tests in `tests/unit`.
4. Following the user's API-only instruction, authenticate with the normal configured development login, submit one current real event with a saved idempotency key, verify the persisted three-caption result and same-key retry, and deliver the raw response plus a readable report. Do not operate the UI.

No database migration, new dependency or locale change. Existing authorization and pricing stay enforced by the backend.

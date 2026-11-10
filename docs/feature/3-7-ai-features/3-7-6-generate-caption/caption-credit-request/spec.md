# Caption requests and credit accounting

## Objective
Restore the existing caption dialog so the user can preview one real trend-based generation with Humanizer, Chroma and optional Neo4j context.

## Acceptance criteria
- Generate, refine and adapt send the workspace and a unique idempotency key required by the current credit accounting API, including free operations.
- Reuse the shared credit request helper, including balance refresh on success/failure.
- Preserve payloads, response envelopes, selection/history calls and all existing UI.
- No schema, provider, permission or pricing change; no publishing.

## UI states
Existing loading, error and result states remain. No new text, locale keys or theme styles are introduced.

## Definition of done
Focused request-contract tests pass and one user-requested live sample is verified through the real API. On 2026-11-05 the user explicitly requested API-only execution without UI interaction. Report context limitations accurately.

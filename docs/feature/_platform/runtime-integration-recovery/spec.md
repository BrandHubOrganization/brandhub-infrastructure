# Runtime integration recovery — 2026-10-14

## Objective and scope

Restore existing Mail, Content Writing and Content Request integrations after synchronising branches. This is a bugfix, not new BA. References: `../content-task-workflow/3-6-10-content-writting-view/spec.md`, `../content-task-workflow/3-6-32-send-email-via-template/spec.md`, `../authentication/3-2-2-sign-in-with-email/spec.md`, and `../../BA/05-content-task-workflow.md`.

## Acceptance criteria

1. Mail's existing PostgreSQL migration supplies all five missing tables. Fresh init contains the same definitions. Preserve existing application data; do not initialise Mongo or send test email.
2. Editor WebSocket passes through Gateway with existing downstream JWT and Task membership checks intact. Reconnect uses the latest authenticated session, not a captured expired token. Preserve the existing Yjs pending-update queue.
3. HTTP 401 uses the existing rotating-cookie refresh flow, at most one retry per request, including concurrent requests. Invalid refresh responses reject; never resolve a protected request with undefined data.
4. Content Request data endpoints reject unsuccessful/malformed envelopes. Valid empty lists remain valid. Do not mask failures with mock/empty data.
5. Emoji search/categories work without cross-origin public API access. Dataset is versioned and locally served with its licence. Failed loads have a working retry; no CORS proxy or security bypass.
6. Do not recreate a successful Campaign deployment. Only the explicit deployment-not-found business code is an expected absent deployment; unrelated 404s remain errors.

## UI states

Existing visual design remains. Emoji loading/error/empty/success states use semantic theme tokens, keyboard-accessible controls and parallel `editor.emojiPicker.*` keys in `src/i18n/locales/{vi,en}/editor.json`. Initial content loading failures must be visible/retryable, without discarding edits on transient reconnect failures.

## Out of scope

No BA changes, Task phase-1 stash restoration, seed accounts, shared Mongo changes, new Campaign deployments, commits/pushes or changes to specialised content workflows.

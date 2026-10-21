# Ambassador portrait UI

Replace the editor Character Sheet flow with describe → review → select ambassador. Remove sheet controls and references. Generate portraits with 25 steps, width 832 and height 1248. Keep the authenticated gateway route, which forwards to the worker /api/v1/generate_ambassador. Preserve retry/edit/error handling. No backend API removal.

## Acceptance criteria
- Selecting the reviewed portrait uses it directly as ambassador reference.
- No character-sheet request or UI in this editor flow.
- Vietnamese and English labels stay parallel; no new hardcoded UI strings.
- Existing semantic theme tokens support light/dark mode.

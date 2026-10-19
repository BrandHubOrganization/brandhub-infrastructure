# Checks
- Proxy forwards topic/platform/count and replaces caller client_id with authenticated context.
- Empty caption prevents request. Explicit generation sends current caption/platform.
- Results are API data; clicking adds to Post, never collection; duplicate selection is prevented.
- Failed request shows retryable error; empty response shows empty state.
- Existing collection and AI text flows work.
- Vietnamese/light and English/dark variants render with semantic tokens, keyboard focus and mobile wrapping.

## Verification
- Passed: AiGenerationControllerTest (2 tests), authenticated tenant forwarding including alias override.
- Passed: Playwright targeted studio suite (4 tests), including vi/light and en/dark API states, keyboard selection, context changes, no collection persistence and existing collection/text flows.
- Passed: ESLint on changed UI/service files and Prettier.
- Full frontend type-check remains blocked by existing errors in useTaskContentSync, MediaDropzone, workspace/dashboard and AppRoutes. No errors reported in new suggestions code.
- Live external AI/trend data not exercised by these mocked contract tests. Restart Business Service to load the new endpoint. No database migration.

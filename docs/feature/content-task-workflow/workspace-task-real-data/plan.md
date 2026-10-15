# Technical plan

1. Add typed Task list query/reader behind the existing TaskService/controller. Preserve old service signature for existing integrations; controller invokes a query-object overload. MongoTemplate filters/counts/pages TaskDocument with workspace criteria always applied. Validate types/status/search length/campaign ID, quote regex, stable sorting. Bulk-resolve only names/avatars via UserRepository (one lookup per page); extend list DTO with source metadata and description, not specialised editor content.
2. Web taskService uses the full versioned endpoint and typed envelope/page guards, forwards real filters, and never imports mockTaskService. useTasks handles errors, stale request cancellation and page reset. Remove local mutation-only hooks; preserve data on transient refresh only when scope matches, never display stale rows on error/scope change.
3. Expand Task type/status constants and filters. Display unknown priority as missing. Retain layout; add read-only actual Task summary dialog and current-page pagination on all views. Add `tasks.json` in vi/en and register in i18n/index.ts.
4. Keep Calendar layout but remove generated date/allDay/duration/venue/category assumptions; show deadlines only and disable editing/selecting. Kanban groups every actual status with no local drag mutations. Gantt retains rows/day-grid, uses true dueDate markers and date navigation, no fake bar spans or drag state.
5. Unit tests: reader query/access/DTO mapping, service error/empty/filter contracts, date/board mapping. Focused Maven/Vitest + type/build/lint and Playwright CLI isolated browser with mocked transport and actual UI. Do not read real tokens or mutate shared Atlas. No migration necessary: existing Campaign/Request stores already persist required fields.

## Local handoff

- Restart Business Service to load the new reader/controller query contract, then reload Web. Gateway is unchanged.
- No PostgreSQL or Mongo migration, seed, init or backfill is required for this integration.
- The endpoint retains Spring Page serialization (`number` is the current page). Web normalizes `number` to its local `page` field; both shapes have regression coverage.
- Test using existing accounts and a Workspace whose Campaign deployment has succeeded. Planned work items alone do not appear until deployment creates their generic Tasks. Accepted Content Requests use the same list, retain campaignId/sourceRefId, and do not change the approved plan.
- List, Kanban, Calendar and timeline use the current server-filtered page; navigate pagination to see more. Missing deadlines stay visible in List/Kanban, with an explanation in date views.
- This release is read-only, as confirmed by the user. Persisted status/date dragging, assignment and specialised content editors remain separate work. No claim that all FR 3.6.4-3.6.8 are complete.
- Existing mockTaskService source is retained for unrelated consumers/tests, but real Task list transport does not import or fall back to it. No changes to other members' specialised modules, stashes, data, or automatic commit/push.

> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Five-State Inline Task Editing, Role-Scoped Subtasks & Sectioned Specialized Editors (`task-subtask-and-inline-workflow`)

## 1. System Components & Touched Repositories

Consolidates the technical architecture for `subtask-role-workspaces`, `task-creator-assignment`, `task-five-state-inline-edit`, `task-structure-simplification`, `task-unsaved-confirmation`, `task-write-start`, `workspace-task-real-data` as specified in [spec.md](./spec.md):

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/workspaces/**`, `/api/v1/task-catalog/**`, WebSocket `/ws/**`) |
| **Backend / Worker Services** | `TaskController.java`, `TaskWorkflowController.java`, `TaskApprovalController.java`, `CampaignSubtaskController.java`, `TaskSectionController.java`, `TaskCatalogController.java`, `TaskContentWebSocketController.java` |
| **Persistence, Cache & Brokers** | PostgreSQL `tasks`, `task_content_operations`, `task_content_snapshots`; MongoDB `tasks`, `task_sections`, `task_section_versions`, `task_section_events` |
| **Web Frontend (`brandhub-web`)** | `pages/tasks/{index,detail}.tsx`, `pages/tasks/components/views/*`, `pages/tasks/{event,kol,newsletter,press,survey,workshop}-editor/index.tsx`, `components/task-sections/SectionReturnDialog.tsx` |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/content/{TaskListScreen,TaskKanbanScreen,TaskDetailScreen}.tsx`, `src/screens/content-writing/ContentWritingEditorScreen.tsx`, `src/services/{taskService,taskSectionService}.ts` |
| **i18n & Theme Assets** | `tasks.{workflow,inline,subtasks,sections,unsavedConfirm}.*` in `src/i18n/locales/{vi,en}/tasks.json`; Mobile `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` & `src/theme/tokens.ts` |

## 2. Core Technical Design & Data Model Invariants

- **Agency social posts:** Follow the [shared Image and Reel workflow plan](./agency-social-post-workflow.md#implementation-plan) for task creation, destination permissions, step routing and media handoff. The existing task types and section routes continue to resolve saved work.

- **Catalog-Driven Section Schemas (`TaskCatalogController`):** `GET /api/v1/task-catalog/{taskType}` defines the exact section blueprint for each specialized task type so Web and Mobile validate identical section keys.
- **Granular Section Return & Reopen (`SectionReturnDialog` & `SectionService`):** Returning (`CLIENT_RETURN`) or reopening (`REOPEN` by `Owner`/`Manager` prior to live publication) a single section reopens only that section (`RETURNED`) for `Creator` revision while keeping approved sibling sections locked, reverting the parent Task to `IN_PROGRESS`, and cancelling scheduled social/email dispatch.
- **Automatic Parent Settlement & Anti-Bypass Guards ([FR 3.6.9 Plan](../../../srs/05-content-task-workflow/3-6-9-approval-sequence-creator-manager-client/plan.md)):** `SectionService.approve()` invokes `TaskApprovalService.settleSections()` on both internal and client approvals so parent Tasks transition automatically to `IN_REVIEW (CLIENT)` and `FINISHED` without redundant manual submit steps, while `TaskServiceImpl.updateStatus()` blocks direct Kanban/Bulk jumps to `IN_REVIEW` or `FINISHED`.

## 3. End-to-End Data & Control Flow

1. **Ingress & Identity Propagation:** Requests pass through `brandhub-api-gateway` (`InboundSecurityWebFilter` -> `JwtAuthFilterGatewayFilterFactory` -> `RateLimitGatewayFilterFactory`), stripping external header spoofing and injecting verified `X-User-Id`, `X-Request-Id`, and role claims.
2. **Authorization & Invariant Validation:** Downstream controllers and services re-verify canonical role permissions (`Owner, Manager, Creator, Client`) and Agency/Workspace tenant membership against authoritative database state before mutating data or dispatching async jobs.
3. **Atomic Persistence & Event Fan-Out:** State transitions commit atomically across PostgreSQL `tasks`, `task_content_operations`, `task_content_snapshots`; MongoDB `tasks`, `task_sections`, `task_section_versions`, `task_section_events` using optimistic (`@Version` / `expectedRevision`) or pessimistic locks, emitting outbox/WebSocket/`pg_notify` events after commit.
4. **Client State Reconciliation:** `brandhub-web` and `brandhub-mobile-app` consume typed `ApiResponse<T>` envelopes, update user/tenant-scoped `TanStack Query` caches, and render localized UI states in Light and Dark themes.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Database / Storage / Config Baseline:** Apply additive migrations in `database/init/init-postgres-v2.sql` and `database/migrations/postgres/*.sql` (plus MongoDB/Neo4j/Redis indexes) with repeat-run idempotency.
2. **Phase 2 — Domain Services & Security Guards:** Implement core service logic, cryptographic/concurrency helpers, and internal service-to-service contracts.
3. **Phase 3 — Public REST / WebSocket / Worker Endpoints:** Wire controllers, consumers, and exception handlers returning standardized `ErrorCode` payloads.
4. **Phase 4 — Web & Mobile UI Surfaces:** Deliver responsive components, accessibility/keyboard navigation, and state transitions without mock data fallbacks.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Theme Audit:** Synchronize translation namespaces and verify semantic color tokens across Light and Dark modes.
6. **Phase 6 — Multi-Layer Verification:** Execute unit, integration, contract, and browser/mobile E2E suites documented in [test.md](./test.md).

For the KOL spreadsheet, reuse the field controls from the workspace form and bind them to the existing section draft. Show a single inline editor at a time and keep the mobile review drawer open while selecting the corresponding workspace step. Add parallel labels to the Web `editor.json` locale files and use the existing theme tokens.

Task export accepts explicit `format=pdf|docx|xlsx`. Omitted format retains the previous default for existing callers. Share the Web dropdown, persist local section drafts when exporting from a workspace, and keep the backend's visibility policy. Use A4 documents with clear typography and pagination, and Excel sheets with readable widths, printed headers, and typed metrics. Update the existing Postman request and Web `editor.json` translations.

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new or updated label in `tasks.{workflow,inline,subtasks,sections,unsavedConfirm}.*` in `src/i18n/locales/{vi,en}/tasks.json` is committed simultaneously in `vi` and `en` bundles on `brandhub-web` and mirrored in `brandhub-mobile-app/src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (verified by `mobileI18nParity.test.ts` and `i18nCoverage.test.ts`).
- **Light & Dark Theme Architecture:** Web components rely exclusively on semantic CSS custom properties (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` utility classes; Mobile components consume `useAppPreferences().palette` (`src/theme/tokens.ts`) verified by `tokens.test.ts`.
- **Structured Telemetry & Rollback Safety:** Every boundary logs `X-Request-Id`, latency, and classified `ErrorCode` while redacting tokens/PII. Additive schema migrations preserve backward-compatible rollback without dropping historical audit or ledger data.

## 6. Engineering Risks & Mitigations

- **Accidental Draft Loss on Tab Switch:** Dirty-state tracker compares normalized editor AST against last saved snapshot before prompting confirmation.

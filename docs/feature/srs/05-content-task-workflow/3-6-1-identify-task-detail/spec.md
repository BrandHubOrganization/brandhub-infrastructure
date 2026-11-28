> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.1 — Identify Task Detail

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.1` |
| **Use Case ID** | `UC-053` |
| **Feature** | Identify Task Detail |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-33` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Đặc tả chi tiết thông tin công việc từ Backlog (Identify Task Detail — /workspaces/:id/tasks/:taskId). Khi các công việc được đẩy tự động từ Media Campaign (3.5.8) hoặc Content Request (3.5.11) vào Backlog thì mới chỉ có tiêu đề và khung thời gian sơ bộ; tại bước này, Manager bổ sung đầy đủ Loại công việc (Post Task / Survey Task), Nền tảng đăng tải, Hạn hoàn thành (Due Date), Ngày giờ lên lịch đăng, Mức độ ưu tiên (Priority), Yêu cầu đầu ra chi tiết (Brief) và tài liệu tham khảo (BR-33).

**Consolidated Implementation Scope:** Provides inline autosave and right-hand slide-over detail management across supported task types (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `WORKSHOP`, `KOL`, `PRESS_RECOMMENDATION`, `NEWSLETTER`). Enforces `BR-33` (locks `Manager` brief/deadline edits once `firstStartedAt != null`), validates deadlines in canonical Workspace timezone within Campaign `[startDate, endDate]`, supports multi-section role workspaces (`TaskSectionController`) and `.xlsx`/PDF export (`TaskExportController`).

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **Identify Task Detail** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-33` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/workflow · PATCH /detail · PATCH /field · PATCH /partners · GET /sections · PATCH /sections/{sectionKey} · GET /subtasks · GET /export`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-33`):** `TaskWorkflowService, TaskWorkflowPolicy, TaskWorkflowFields, TaskWorkflowDates, SectionService, SectionExportService` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `tasks` (`TaskDocument`: `status`, `workflowRevision`, `firstStartedAt`, `dueDate`, `plannedPublishAt`, `typeMetadata`), `task_sections`, `task_section_versions`; PostgreSQL `media_campaigns`, `workspaces` return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 VALIDATION_ERROR` / `INVALID_DUE_DATE`, `403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`, `404 TASK_NOT_FOUND`, `409 TASK_REVISION_CONFLICT` / `TASK_LOCKED_AFTER_START` (`BR-33`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`tasks.detail.* / tasks.workflow.* / taskSections.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/tasks/index.tsx`, `src/pages/tasks/detail.tsx`, `src/pages/tasks/components/{TaskDetailPanel,TaskInlineDetails,TaskReferenceFields,TaskPartnerContactSection,JiraSubtaskUI}.tsx`, `src/components/task-sections/{SectionFrame,SectionFieldsBlock,TaskExportButton}.tsx`, `src/pages/tasks/{event-editor,workshop-editor,kol-editor,press-editor,newsletter-editor}/index.tsx`) and Mobile (`src/screens/content/TaskDetailScreen.tsx`, `src/services/taskService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/tasks/index.tsx`, `src/pages/tasks/detail.tsx`, `src/pages/tasks/components/{TaskDetailPanel,TaskInlineDetails,TaskReferenceFields,TaskPartnerContactSection,JiraSubtaskUI}.tsx`, `src/components/task-sections/{SectionFrame,SectionFieldsBlock,TaskExportButton}.tsx`, `src/pages/tasks/{event-editor,workshop-editor,kol-editor,press-editor,newsletter-editor}/index.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content/TaskDetailScreen.tsx`, `src/services/taskService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/workflow · PATCH /detail · PATCH /field · PATCH /partners · GET /sections · PATCH /sections/{sectionKey} · GET /subtasks · GET /export`
- **Controllers (`brandhub-business-service`):** `TaskWorkflowController.read() / detail() / field() / partners(), TaskController.getTask(), TaskSectionController.list() / patch(), CampaignSubtaskController.list(), TaskExportController.export()`
- **Services:** `TaskWorkflowService, TaskWorkflowPolicy, TaskWorkflowFields, TaskWorkflowDates, SectionService, SectionExportService`
- **Repositories / Stores:** TaskWorkflowStore, TaskMongoRepository, SectionStore (MongoDB `tasks`, `task_sections`), MediaCampaignRepository

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 VALIDATION_ERROR` / `INVALID_DUE_DATE`, `403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`, `404 TASK_NOT_FOUND`, `409 TASK_REVISION_CONFLICT` / `TASK_LOCKED_AFTER_START` (`BR-33`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

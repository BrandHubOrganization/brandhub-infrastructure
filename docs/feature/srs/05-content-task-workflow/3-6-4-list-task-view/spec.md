> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.4 — List Task View

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.4` |
| **Use Case ID** | `UC-056` |
| **Feature** | List Task View |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-33` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Xem và thao tác danh sách công việc dạng bảng chi tiết (List Task View — /workspaces/:id/tasks?view=list). Hiển thị đầy đủ các cột Mã Task, Tiêu đề, Trạng thái, Người thực hiện, Nền tảng, Mức độ ưu tiên, Hạn chót; hỗ trợ sắp xếp theo cột và kéo thả thay đổi thứ tự ưu tiên trong Backlog (BR-33).

**Consolidated Implementation Scope:** Renders the real MongoDB `tasks` collection (`Campaign` deliverables, accepted `CONTENT_REQUEST` tasks, and standalone manual tasks) in a sortable, paginated tabular view with deterministic `(sortField, _id)` tie-breaking, inline status/priority/assignee badges, URL-synced `?task=<id>` right-panel inspection, and zero synthetic mock fallbacks (`BR-33`).

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **List Task View** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-33` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `GET /api/v1/workspaces/{workspaceId}/tasks · POST /api/v1/workspaces/{workspaceId}/tasks/standalone · DELETE /api/v1/workspaces/{workspaceId}/tasks/{taskId}`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-33, BR-34`):** `TaskServiceImpl, WorkspaceTaskReader, TaskLifecycle` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default):
   - **Bulk Status Anti-Bypass (`TaskBulkActionBar`):** Bulk status mutation (`PATCH /tasks/{taskId}/status`) prohibits jumping directly to `IN_REVIEW` or `FINISHED` (`409 TASK_WORKFLOW_REQUIRED`) and restricts `CANCELLED` strictly to `Owner` and `Manager` ([BA Governance](../../../../ba/13-task-status-and-approval-governance.md)).
   - **Real-Time Row Sync:** Completing section/task approvals inside `TaskDetailPanel` (Side Peek / Center Modal) triggers `onUpdated` immediately so outer table status badges transition from `IN_PROGRESS` / `IN_REVIEW` to `FINISHED` without manual refresh.
3. **Persistence & Envelope Contract:** Operations on MongoDB `tasks` (`workspaceId`, `campaignId`, `sourceType`, `sourceRefId`, `type`, `status`, `priority`, `assigneeId`, `dueDate`, `createdAt`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 VALIDATION_ERROR`, `403 WORKSPACE_ACCESS_DENIED`, `404 WORKSPACE_NOT_FOUND` (`BR-33`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`tasks.list.* / tasks.status.* / tasks.types.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/tasks/index.tsx`, `src/pages/tasks/components/views/ListView.tsx`, `src/pages/tasks/components/{TaskPagination,QuickCreateTaskDialog,TaskBulkActionBar}.tsx`, `src/pages/tasks/hooks/useTasks.ts`) and Mobile (`src/screens/content/TaskListScreen.tsx`, `src/services/taskService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/tasks/index.tsx`, `src/pages/tasks/components/views/ListView.tsx`, `src/pages/tasks/components/{TaskPagination,QuickCreateTaskDialog,TaskBulkActionBar}.tsx`, `src/pages/tasks/hooks/useTasks.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content/TaskListScreen.tsx`, `src/services/taskService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `GET /api/v1/workspaces/{workspaceId}/tasks · POST /api/v1/workspaces/{workspaceId}/tasks/standalone · DELETE /api/v1/workspaces/{workspaceId}/tasks/{taskId}`
- **Controllers (`brandhub-business-service`):** `TaskController.getTasks() / createTask() / createStandaloneTask() / deleteTask()`
- **Services:** `TaskServiceImpl, WorkspaceTaskReader, TaskLifecycle`
- **Repositories / Stores:** TaskMongoRepository (MongoDB `tasks`), WorkspaceAccessService

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 VALIDATION_ERROR`, `403 WORKSPACE_ACCESS_DENIED`, `404 WORKSPACE_NOT_FOUND` (`BR-33`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

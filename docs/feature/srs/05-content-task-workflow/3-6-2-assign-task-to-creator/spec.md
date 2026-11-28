> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.2 — Assign Task to Creator

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.2` |
| **Use Case ID** | `UC-054` |
| **Feature** | Assign Task to Creator |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Business Rules** | `BR-33` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Phân công công việc cho người thực hiện và người kiểm tra (Assign Task to Creator — /workspaces/:id/tasks/:taskId). Manager gán Task cho một Creator phụ trách sản xuất nội dung chính và (tùy chọn) gán thêm người phụ trách kiểm tra chất lượng nội bộ trong cùng Workspace, đồng thời gửi thông báo thời gian thực cho người nhận việc (BR-33).

**Consolidated Implementation Scope:** Enforces two-step ownership (`BR-33`): `Owner`/`Manager` assigns an active Workspace `Creator` (assisted by skill/workload ranking from `/assignee-suggestions`) while `firstStartedAt == null` and emits durable `TASK_ASSIGNED` notifications via `task_notification_outbox`; the assigned `Creator` explicitly clicks `/start` (requiring `CampaignStatus.IN_PROGRESS` for Campaign tasks) to transition `TODO -> IN_PROGRESS`, stamping `firstStartedAt` and locking subsequent Manager brief/reassignment edits.

## 2. User Story

As an authorized actor (`Owner, Manager`), I want to execute **Assign Task to Creator** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-33` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/assign · POST /start · PATCH /assignee · GET /member-options · GET /supervisor-options · GET /api/v1/workspaces/{workspaceId}/assignee-suggestions`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-33`):** `TaskWorkflowService, TaskWorkflowMembers, TaskWorkflowPolicy, TaskAssignmentOutbox, TaskNotificationWorker, AssigneeScoring` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `tasks` (`assigneeId`, `supervisorId`, `status`, `firstStartedAt`, `firstStartedBy`, `workflowRevision`), `task_notification_outbox`; PostgreSQL `workspace_members`, `user_notifications` return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 TASK_BRIEF_INCOMPLETE`, `403 FORBIDDEN`, `404 TASK_NOT_FOUND` / `MEMBER_NOT_FOUND`, `409 TASK_ALREADY_STARTED` / `TASK_REVISION_CONFLICT` / `CAMPAIGN_NOT_IN_PROGRESS` (`BR-33`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`tasks.assign.* / tasks.start.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/tasks/components/{TaskAssigneePicker,TaskInlineAssignment,TaskDetailPanel}.tsx`, `src/pages/tasks/hooks/useTaskWorkflow.ts`, `src/pages/tasks/services/taskWorkflowService.ts`) and Mobile (`src/screens/content/TaskDetailScreen.tsx`, `src/services/taskService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/tasks/components/{TaskAssigneePicker,TaskInlineAssignment,TaskDetailPanel}.tsx`, `src/pages/tasks/hooks/useTaskWorkflow.ts`, `src/pages/tasks/services/taskWorkflowService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content/TaskDetailScreen.tsx`, `src/services/taskService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/assign · POST /start · PATCH /assignee · GET /member-options · GET /supervisor-options · GET /api/v1/workspaces/{workspaceId}/assignee-suggestions`
- **Controllers (`brandhub-business-service`):** `TaskWorkflowController.assign() / start() / options() / supervisorOptions(), TaskController.updateAssignee(), ProfileMatchingController.assigneeSuggestions()`
- **Services:** `TaskWorkflowService, TaskWorkflowMembers, TaskWorkflowPolicy, TaskAssignmentOutbox, TaskNotificationWorker, AssigneeScoring`
- **Repositories / Stores:** TaskWorkflowStore, TaskMongoRepository (`tasks`, `task_notification_outbox`), WorkspaceMemberRepository, UserNotificationRepository

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 TASK_BRIEF_INCOMPLETE`, `403 FORBIDDEN`, `404 TASK_NOT_FOUND` / `MEMBER_NOT_FOUND`, `409 TASK_ALREADY_STARTED` / `TASK_REVISION_CONFLICT` / `CAMPAIGN_NOT_IN_PROGRESS` (`BR-33`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

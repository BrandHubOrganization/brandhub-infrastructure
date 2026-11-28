> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.3 — Add Comments on Task

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.3` |
| **Use Case ID** | `UC-055` |
| **Feature** | Add Comments on Task |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-20` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Thêm bình luận, nhận xét và yêu cầu chỉnh sửa trực tiếp trên từng Task (Add Comments on Task — /workspaces/:id/tasks/:taskId). Hỗ trợ phản hồi theo chuỗi (threaded comments), đính kèm hình ảnh/tệp minh họa và gắn thẻ (@mention) thành viên trong Workspace để trao đổi tập trung ngay trên đầu việc (BR-20).

**Consolidated Implementation Scope:** Provides chronological/cursor-paginated discussion threads strictly separated from formal approval notes (`task_approvals`), supporting rich text, inline `@mentions` validated against active Workspace members (`/comment-members`), private authenticated image attachments (`/comment-uploads` validated by `TaskCommentImageValidator`), and durable `TASK_COMMENTED` / mention inbox notifications (`BR-20`).

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **Add Comments on Task** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-20` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/comments · POST /comments · GET /comment-members · POST /comment-uploads · GET /comment-uploads/{uploadId}/content`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-20`):** `TaskCommentService, TaskCommentAccess, TaskCommentUploads, TaskCommentImageValidator, TaskCommentOutbox, TaskNotificationWorker` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `task_comments`, `task_comment_uploads`, `task_notification_outbox`; PostgreSQL `workspace_members`, `user_notifications`; AWS S3 (`task-comments/`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 VALIDATION_ERROR` / `INVALID_FILE_TYPE` / `FILE_TOO_LARGE`, `403 WORKSPACE_ACCESS_DENIED`, `404 TASK_NOT_FOUND` (`BR-20`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`tasks.comments.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/tasks/components/TaskDetailPanel.tsx`, `src/pages/tasks/hooks/{useTaskCommentComposer,useTaskCommentMembers,useTaskCommentRichEditor}.ts`, `src/pages/tasks/utils/{TaskCommentMentionNode,taskCommentMention,taskCommentRichText}.ts`, `src/pages/tasks/services/taskCommentService.ts`) and Mobile (`src/screens/content/TaskDetailScreen.tsx`, `src/services/taskService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/tasks/components/TaskDetailPanel.tsx`, `src/pages/tasks/hooks/{useTaskCommentComposer,useTaskCommentMembers,useTaskCommentRichEditor}.ts`, `src/pages/tasks/utils/{TaskCommentMentionNode,taskCommentMention,taskCommentRichText}.ts`, `src/pages/tasks/services/taskCommentService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content/TaskDetailScreen.tsx`, `src/services/taskService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/comments · POST /comments · GET /comment-members · POST /comment-uploads · GET /comment-uploads/{uploadId}/content`
- **Controllers (`brandhub-business-service`):** `TaskCommentController.list() / create() / members() / upload() / content()`
- **Services:** `TaskCommentService, TaskCommentAccess, TaskCommentUploads, TaskCommentImageValidator, TaskCommentOutbox, TaskNotificationWorker`
- **Repositories / Stores:** TaskCommentStore (MongoDB `task_comments`, `task_comment_uploads`, `task_notification_outbox`), WorkspaceMemberRepository

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 VALIDATION_ERROR` / `INVALID_FILE_TYPE` / `FILE_TOO_LARGE`, `403 WORKSPACE_ACCESS_DENIED`, `404 TASK_NOT_FOUND` (`BR-20`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

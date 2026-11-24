> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.6 — Gantt Timeline Task View

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.6` |
| **Use Case ID** | `UC-058` |
| **Feature** | Gantt Timeline Task View |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-20, BR-33` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Xem tiến độ công việc dạng biểu đồ thác nước theo trục thời gian (Gantt Timeline Task View — /workspaces/:id/tasks?view=gantt). Hiển thị thanh thời gian bắt đầu – kết thúc của từng Task trong chiến dịch, tiến độ phần trăm hoàn thành và sự phụ thuộc giữa các giai đoạn sản xuất nội dung.

**Consolidated Implementation Scope:** Visualizes horizontal Gantt timeline bars across Campaign `[startDate, endDate]` and Workspace deadlines, highlighting overlapping workloads, unscheduled deliverables, and overdue bottlenecks while allowing authorized `Owner`/`Manager` actors to adjust schedules (`PATCH /tasks/{taskId}/schedule`) and row ordering (`PUT /timeline/reorder-tasks`).

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **Gantt Timeline Task View** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-20, BR-33` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/timeline · PATCH /api/v1/workspaces/{workspaceId}/tasks/{taskId}/schedule · PUT /timeline/reorder-tasks · GET /api/v1/workspaces/{workspaceId}/tasks`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-20, BR-33`):** `CampaignTimelineService, TaskServiceImpl` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `tasks` (`startDate`, `dueDate`, `timelineOrder`, `campaignId`, `status`); PostgreSQL `media_campaigns` (`start_date`, `end_date`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 INVALID_SCHEDULE_RANGE`, `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND` / `TASK_NOT_FOUND`, `409 TASK_LOCKED`).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`tasks.timeline.* / campaign.timeline.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/tasks/index.tsx` (`TimelineView`), `src/pages/campaign/{index,page}.tsx`, `src/services/taskService.ts`) and Mobile (`src/screens/more/CampaignDetailScreen.tsx`, `src/screens/content/TaskListScreen.tsx`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/tasks/index.tsx` (`TimelineView`), `src/pages/campaign/{index,page}.tsx`, `src/services/taskService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/CampaignDetailScreen.tsx`, `src/screens/content/TaskListScreen.tsx`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/timeline · PATCH /api/v1/workspaces/{workspaceId}/tasks/{taskId}/schedule · PUT /timeline/reorder-tasks · GET /api/v1/workspaces/{workspaceId}/tasks`
- **Controllers (`brandhub-business-service`):** `CampaignTimelineController.read() / schedule() / createOutOfScopeTask() / reorderTasks(), TaskController.getTasks()`
- **Services:** `CampaignTimelineService, TaskServiceImpl`
- **Repositories / Stores:** TaskMongoRepository (MongoDB `tasks`), MediaCampaignRepository (PostgreSQL `media_campaigns`)

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 INVALID_SCHEDULE_RANGE`, `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND` / `TASK_NOT_FOUND`, `409 TASK_LOCKED`.
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

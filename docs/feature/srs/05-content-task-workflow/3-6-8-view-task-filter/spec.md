> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.8 — View Task Filter

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.8` |
| **Use Case ID** | `UC-060` |
| **Feature** | View Task Filter |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-20, BR-33` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Tìm kiếm, lọc đa tiêu chí và sắp xếp dữ liệu công việc xuyên suốt cả 4 chế độ xem List, Calendar, Gantt và Kanban (View Task Filter — /workspaces/:id/tasks). Tham khảo cơ chế lọc chi tiết của Jira: hỗ trợ tìm theo từ khóa tiêu đề/mô tả và lọc kết hợp theo Trạng thái, Người phụ trách (Assignee), Chiến dịch (Campaign), Nền tảng, Mức độ ưu tiên, Nhãn (Tag) và Khoảng thời gian.

**Consolidated Implementation Scope:** Executes server-side `AND`-combined MongoDB filtering (`status`, `type`, literal escaped `search` on title/description, `campaignId`, `assignee`, `due` overdue/upcoming presets, `from`/`to` instants, and whitelisted `sort` keys) synchronized into URL query parameters (powering direct drill-down links from Role-Based Dashboards) and persisted across List, Kanban, Calendar, and Timeline switches.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **View Task Filter** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-20, BR-33` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `GET /api/v1/workspaces/{workspaceId}/tasks?status=&type=&search=&campaignId=&from=&to=&assignee=&due=&sort=&direction=&page=&size=`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-20, BR-33`):** `TaskServiceImpl, WorkspaceTaskReader (`TaskListQuery`)` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `tasks` (compound indexes on `workspaceId + status + type + assigneeId + dueDate + createdAt`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 VALIDATION_ERROR` (invalid ISO date / page bounds), `403 WORKSPACE_ACCESS_DENIED`).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`tasks.filters.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/tasks/components/{TaskFilterBar,TaskCategoryBar,TaskMultiSelectFilter}.tsx`, `src/pages/tasks/hooks/{useTaskFilters,useFilterCategoriesStorage}.ts`, `src/pages/tasks/utils/taskFilterUtils.ts`) and Mobile (`src/screens/content/{TaskListScreen,TaskKanbanScreen}.tsx`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/tasks/components/{TaskFilterBar,TaskCategoryBar,TaskMultiSelectFilter}.tsx`, `src/pages/tasks/hooks/{useTaskFilters,useFilterCategoriesStorage}.ts`, `src/pages/tasks/utils/taskFilterUtils.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content/{TaskListScreen,TaskKanbanScreen}.tsx`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `GET /api/v1/workspaces/{workspaceId}/tasks?status=&type=&search=&campaignId=&from=&to=&assignee=&due=&sort=&direction=&page=&size=`
- **Controllers (`brandhub-business-service`):** `TaskController.getTasks()`
- **Services:** `TaskServiceImpl, WorkspaceTaskReader (`TaskListQuery`)`
- **Repositories / Stores:** TaskMongoRepository (MongoDB `tasks`)

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 VALIDATION_ERROR` (invalid ISO date / page bounds), `403 WORKSPACE_ACCESS_DENIED`.
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

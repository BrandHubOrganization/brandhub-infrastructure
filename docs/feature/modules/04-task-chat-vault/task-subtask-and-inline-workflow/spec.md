> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Five-State Inline Task Editing, Role-Scoped Subtasks & Sectioned Specialized Editors

| Field | Value |
| :--- | :--- |
| **Module Slug** | `task-subtask-and-inline-workflow` |
| **Category** | `04-task-chat-vault` — Task Workflow, Realtime Workspace Chat & Encrypted S3 Vault |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Consolidated Feature Scopes** | `subtask-role-workspaces`, `task-creator-assignment`, `task-five-state-inline-edit`, `task-structure-simplification`, `task-unsaved-confirmation`, `task-write-start`, `workspace-task-real-data` |
| **Aligned SRS Domains** | [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md) (`3.6.1–3.6.10`, `3.6.34–3.6.35`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Consolidate BrandHub's end-to-end Task authoring and execution UX: simplified 5-state Task workflow (`TODO`, `IN_PROGRESS`, `INTERNAL_REVIEW`, `CLIENT_REVIEW`, `APPROVED` / `PUBLISHED`), inline field editing (`TaskWorkflowController`), `Creator` assignment & auto-start on 'Write Post' (`task-write-start`), role-scoped **Subtasks** (`CampaignSubtaskController`) & **Multi-Section Specialized Task Editors** (`TaskSectionController` for Event, KOL, Newsletter, Press, Survey, Workshop), unsaved-change navigation guards, and 100% real Campaign/Task data binding.

## 2. User Stories

- As a `Manager` or `Owner`, I want inline editing of Task assignee, priority, deadline, and structured sections (`TaskSectionController`) with independent per-section review/return cycles so complex deliverables (KOL briefs, Events, Newsletters, Press releases) don't require rejecting an entire Task over one paragraph.
- As a `Creator`, I want clicking 'Write Post' on an assigned `TODO` Task to automatically start the Task (`IN_PROGRESS`) and protect my unsaved rich-text edits against accidental navigation loss.

## 3. Consolidated Acceptance Criteria

1. **Five-State Workflow & Inline Field Editing (`task-five-state-inline-edit`, `task-structure-simplification`, `task-creator-assignment`):** `TaskWorkflowController` (`GET /workflow`, `PATCH /detail`, `PATCH /field`, `POST /assign`, `POST /start`, `GET /member-options`) enables authorized `Owner`/`Manager` inline updates to assignee (`Creator`/`Manager`), priority, and dates with immediate validation and optimistic UI updates.
2. **Auto-Start on Write & Unsaved-Change Protection (`task-write-start`, `task-unsaved-confirmation`):** Opening the Content Editor and initiating 'Write Post' as the assigned `Creator` transitions `TODO -> IN_PROGRESS` via `POST /tasks/{taskId}/start`. Dirty editor state triggers both React Router blocker confirmation and browser `beforeunload` warning.
3. **Role-Scoped Subtasks & Specialized Section Editors (`subtask-role-workspaces`):** `CampaignSubtaskController` (`/tasks/{taskId}/subtasks`) manages ordered checklist subtasks, while `TaskSectionController` (`/tasks/{taskId}/sections/{sectionKey}` + `/submit`, `/approve`, `/return`, `/reopen`, `/versions`, `/restore/{versionNo}`) powers specialized editors (`event-editor`, `kol-editor`, `newsletter-editor`, `press-editor`, `survey-editor`, `workshop-editor`) backed by MongoDB `task_sections`, `task_section_versions`, and `task_section_events`.
4. **100% Real Workspace & Campaign Task Views (`workspace-task-real-data`):** Table (`TaskTable.tsx`), Kanban (`TaskBoardView.tsx`), Calendar (`TaskCalendarTimeline.tsx`), and Gantt (`TaskGanttView.tsx`) query live `GET /api/v1/workspaces/{workspaceId}/tasks` with zero hardcoded demo arrays.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`tasks.{workflow,inline,subtasks,sections,unsavedConfirm}.*` in `src/i18n/locales/{vi,en}/tasks.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

7. **Editable KOL spreadsheet (Web):** Users can open an editable field directly in the spreadsheet, including empty values and structured shortlist rows. Both views reflect edits immediately through the same section draft. Section permissions apply to both views, and existing save and review actions handle the shared draft. The new spreadsheet hint and controls are available in Vietnamese and English and use semantic theme tokens in light and dark modes.

8. **Task file exports (Web):** The workspaces for Post, Short Video, Survey, Event, Press, KOL, Workshop, and Newsletter offer separate PDF, Word, and Excel downloads with format icons. The same options are available from task overview surfaces that show exportable work. Exports follow the existing section visibility, draft labeling, and authorization rules. Controls use parallel Vietnamese and English labels and semantic light/dark styling.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/tasks/{index,detail}.tsx`, `pages/tasks/components/views/*`, `pages/tasks/{event,kol,newsletter,press,survey,workshop}-editor/index.tsx`, `components/task-sections/SectionReturnDialog.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/content/{TaskListScreen,TaskKanbanScreen,TaskDetailScreen}.tsx`, `src/screens/content-writing/ContentWritingEditorScreen.tsx`, `src/services/{taskService,taskSectionService}.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/workspaces/{workspaceId}/tasks & GET /{taskId}` | Bearer (`Owner, Manager, Creator, Client`) | `TaskController` -> live task list & detail across Table, Kanban, Calendar, Gantt |
| `PATCH /api/v1/workspaces/{workspaceId}/tasks/{taskId}/field & POST /assign & POST /start` | Bearer (`Owner, Manager, Creator`) | `TaskWorkflowController` -> inline field mutation, Creator assignment & write-start transition |
| `GET/POST/PATCH/PUT /api/v1/workspaces/{workspaceId}/tasks/{taskId}/subtasks/**` | Bearer (`Owner, Manager, Creator`) | `CampaignSubtaskController` -> role-aware subtask CRUD, status toggle & reorder |
| `GET/PATCH/POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/sections/{sectionKey}/**` | Bearer (`Owner, Manager, Creator, Client`) | `TaskSectionController` & `WorkspaceSectionController` -> sectioned authoring, granular return/approve & version restore |

## 6. Error Handling, Security & Edge Cases

- **Client Visibility Boundary:** `Client` sees tasks and sections at `CLIENT_REVIEW` / `APPROVED` stages (`GET /sections/client-pending`) and never sees raw unsubmitted internal drafts (`TODO` / `IN_PROGRESS`).
- **Concurrent Yjs / Snapshot Edit:** `task_content_operations` and `task_content_snapshots` preserve version history (`FR 3.6.35`) alongside section version snapshots.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md) (`3.6.1–3.6.10`, `3.6.34–3.6.35`)
- **BA & Architecture References:** [BA 05 Content & Task Workflow](../../../../ba/05-content-task-workflow.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).

> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.27 — Generate Meeting Link

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.27` |
| **Use Case ID** | `UC-079` |
| **Feature** | Generate Meeting Link |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-40` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Tự động khởi tạo đường dẫn phòng họp trực tuyến (Google Meet / Jitsi Meeting Link) ngay trong Workspace hoặc trên Task (Generate Meeting Link — /workspaces/:id/meetings). Giúp đội ngũ Agency và Client mở nhanh cuộc họp trao đổi kịch bản, duyệt ấn phẩm và tự động gửi thông báo kèm link họp cho các thành viên tham gia (BR-40).

**Consolidated Implementation Scope:** Generates or attaches an online conference room URL (Google Meet / custom HTTPS conference link with optional `forceNew=true` regeneration, `BR-40`) directly onto `WORKSHOP`, `EVENT_PLAN`, or collaborative review Tasks for `Owner, Manager, Creator`, persisting `MeetingLinkResponse` on `TaskDocument` so Workspace participants can join with one click.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator`), I want to execute **Generate Meeting Link** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-40` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/meeting-link`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-40`):** `Meeting link provisioning service + Google Calendar/Meet conference integration (`SaveMeetingLinkRequest`, `MeetingLinkResponse`)` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `tasks` (`meetingUrl`, `meetingCreatedAt`, `meetingCreatedBy` inside task metadata) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 INVALID_MEETING_URL`, `403 FORBIDDEN`, `404 TASK_NOT_FOUND` (`BR-40`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`tasks.meetingLink.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/tasks/workshop-editor/index.tsx`, `src/pages/tasks/event-editor/index.tsx`, `src/pages/tasks/components/TaskDetailPanel.tsx`) and Mobile (`src/screens/content/TaskDetailScreen.tsx`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/tasks/workshop-editor/index.tsx`, `src/pages/tasks/event-editor/index.tsx`, `src/pages/tasks/components/TaskDetailPanel.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content/TaskDetailScreen.tsx`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/meeting-link`
- **Controllers (`brandhub-business-service`):** `Meeting-link endpoint in `com.brandhub.business.controller.task` (`POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/meeting-link`)`
- **Services:** `Meeting link provisioning service + Google Calendar/Meet conference integration (`SaveMeetingLinkRequest`, `MeetingLinkResponse`)`
- **Repositories / Stores:** TaskMongoRepository (MongoDB `tasks`)

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 INVALID_MEETING_URL`, `403 FORBIDDEN`, `404 TASK_NOT_FOUND` (`BR-40`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

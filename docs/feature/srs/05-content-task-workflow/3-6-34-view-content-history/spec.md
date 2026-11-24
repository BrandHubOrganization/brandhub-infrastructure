> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.34 — View Content History

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.34` |
| **Use Case ID** | `UC-086` |
| **Feature** | View Content History |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-35` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Xem lịch sử các phiên bản nội dung và tài nguyên AI đã khởi tạo trước đó của Task/Workspace (View Content History — /workspaces/:id/tasks/:taskId/history). Cho phép người dùng tra cứu, xem lại và tái sử dụng các đoạn caption, hình ảnh, video đã được tạo trước đó mà hoàn toàn không bị trừ lại AI Credit (BR-35, BR-35).

**Consolidated Implementation Scope:** Lets `Owner, Manager, Creator` inspect timestamped content snapshots, line-by-line diffs (`lineDiff.ts`), section versions, and previously generated AI captions/images/videos, and restore any historical version into the active editor without re-deducting AI Credits (`BR-35`).

## 2. User Story

As an authorized actor (`Owner, Manager, Creator`), I want to execute **View Content History** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-35` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/content/versions · GET /versions/{snapshotId} · POST /versions/{snapshotId}/restore · GET /sections/{sectionKey}/versions · POST /sections/{sectionKey}/restore/{versionNo}`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-35`):** `TaskContentService, SectionService, AiCaptionService (generation history)` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on PostgreSQL `task_content_snapshots`, `task_content_operations`; MongoDB `task_section_versions`, `video_auto_edits`, `materials` return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`403 FORBIDDEN`, `404 SNAPSHOT_NOT_FOUND` / `TASK_NOT_FOUND`, `409 TASK_REVIEW_CONTENT_LOCKED` (`BR-35`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`editor.history.* / taskSections.versions.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/task-editor/index.tsx`, `src/components/task-sections/{SectionVersionDrawer,lineDiff.ts}`, `src/pages/ai-studio/video.tsx`) and Mobile (`src/screens/content-writing/VersionHistory.tsx`, `src/screens/more/AiVideoHistoryScreen.tsx`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/task-editor/index.tsx`, `src/components/task-sections/{SectionVersionDrawer,lineDiff.ts}`, `src/pages/ai-studio/video.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content-writing/VersionHistory.tsx`, `src/screens/more/AiVideoHistoryScreen.tsx`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/content/versions · GET /versions/{snapshotId} · POST /versions/{snapshotId}/restore · GET /sections/{sectionKey}/versions · POST /sections/{sectionKey}/restore/{versionNo}`
- **Controllers (`brandhub-business-service`):** `TaskController.listVersions() / getVersion() / restoreVersion(), TaskSectionController.versions() / version() / restore()`
- **Services:** `TaskContentService, SectionService, AiCaptionService (generation history)`
- **Repositories / Stores:** TaskContentSnapshotRepository, TaskContentOperationRepository (PostgreSQL), SectionStore (MongoDB `task_section_versions`)

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `403 FORBIDDEN`, `404 SNAPSHOT_NOT_FOUND` / `TASK_NOT_FOUND`, `409 TASK_REVIEW_CONTENT_LOCKED` (`BR-35`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

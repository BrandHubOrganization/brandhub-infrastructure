> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.17 — Disconnect Google Drive Storage

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.17` |
| **Use Case ID** | `UC-069` |
| **Feature** | Disconnect Google Drive Storage |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-37` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Ngắt kết nối tài khoản Google Drive khỏi Workspace (Disconnect Google Drive Storage — /workspaces/:id/library/drive). Hệ thống thu hồi OAuth token đã lưu và dừng đồng bộ tự động, nhưng vẫn bảo toàn nguyên vẹn toàn bộ các tư liệu đã được đồng bộ vào Material Repository trước thời điểm ngắt kết nối (BR-37, BR-37).

**Consolidated Implementation Scope:** Folds in `client-drive-disconnect`: acquires `DriveOperationLease`, cancels/guards active Drive import jobs, revokes and wipes encrypted Google OAuth credentials (`CustomerDriveDisconnectService`, `BR-37`), and keeps all previously imported S3 materials, thumbnails, and Task/Post links 100% accessible inside the Workspace without deleting any files on the user Google Drive.

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **Disconnect Google Drive Storage** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-37` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `DELETE /api/v1/workspaces/{workspace}/storage/drive`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-37`):** `CustomerDriveDisconnectService, DriveOperationLease, DriveFolderImportService` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on PostgreSQL `workspaces` (clears encrypted Drive credentials); MongoDB `materials` (imported S3 assets retained intact) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`403 FORBIDDEN`, `404 WORKSPACE_NOT_FOUND`, `409 DRIVE_IMPORT_IN_PROGRESS` (`BR-37`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`library.drive.disconnect.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/library/components/CustomerDrivePanel.tsx`, `src/services/materialService.ts`) and Mobile (`src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/library/components/CustomerDrivePanel.tsx`, `src/services/materialService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `DELETE /api/v1/workspaces/{workspace}/storage/drive`
- **Controllers (`brandhub-business-service`):** `CustomerDriveController.disconnect()`
- **Services:** `CustomerDriveDisconnectService, DriveOperationLease, DriveFolderImportService`
- **Repositories / Stores:** WorkspaceRepository, CustomerDriveImportStore, MaterialMongoRepository

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `403 FORBIDDEN`, `404 WORKSPACE_NOT_FOUND`, `409 DRIVE_IMPORT_IN_PROGRESS` (`BR-37`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

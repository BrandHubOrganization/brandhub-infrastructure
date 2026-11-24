> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.16 — Sync Material from Google Drive

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.16` |
| **Use Case ID** | `UC-068` |
| **Feature** | Sync Material from Google Drive |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-36, BR-37` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Đồng bộ và nhập các tệp hình ảnh/video từ thư mục Google Drive đã kết nối vào Material Repository của Workspace (Sync Material from Google Drive — /workspaces/:id/library/drive). Hệ thống kiểm tra phiên kết nối Google Drive hợp lệ, đối chiếu mã định danh tệp để tránh nhập trùng lặp và tự động gắn phân loại tư liệu tương ứng trong kho (BR-36, BR-37).

**Consolidated Implementation Scope:** Folds in `client-drive-workspace-sync`, `client-drive-overflow`, and `s3-folder-vault-security`: executes asynchronous, cancellable one-time Google Drive folder-tree import jobs (`DriveFolderImportService`) that recursively recreate nested sub-folders in `material_folders`, validate supported media MIME/magic bytes, pre-encrypt files with `RepositoryEnvelopeCrypto` into `SYSTEM_S3`, enforce remaining S3 storage quota (`413 STORAGE_QUOTA_EXCEEDED` graceful overflow handling without partial corruption), and track real-time job progress (`importedCount`, `skippedCount`, `failedCount`, `BR-36`, `BR-37`).

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **Sync Material from Google Drive** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-36, BR-37` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `POST /api/v1/workspaces/{workspaceId}/materials/drive-import · GET /api/v1/workspaces/{workspaceId}/materials/drive-import/{jobId} · POST /api/v1/workspaces/{workspaceId}/materials/drive-import/{jobId}/cancel`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-36, BR-37`):** `DriveFolderImportService, CustomerDriveSyncService, CustomerDriveImportStore, RepositoryEnvelopeCrypto, StorageQuotaService` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `materials`, `material_folders`, `drive_import_jobs`; AWS S3 (`SYSTEM_S3`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 INVALID_DRIVE_FOLDER`, `403 FORBIDDEN`, `409 DRIVE_IMPORT_ALREADY_RUNNING`, `413 STORAGE_QUOTA_EXCEEDED` (`BR-36`, `BR-37`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`library.drive.import.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/library/components/CustomerDrivePanel.tsx`, `src/components/common/BackgroundTaskDock.tsx`, `src/services/materialService.ts`) and Mobile (`src/screens/more/MediaLibraryScreen.tsx`, `src/services/mediaSyncService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/library/components/CustomerDrivePanel.tsx`, `src/components/common/BackgroundTaskDock.tsx`, `src/services/materialService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/MediaLibraryScreen.tsx`, `src/services/mediaSyncService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `POST /api/v1/workspaces/{workspaceId}/materials/drive-import · GET /api/v1/workspaces/{workspaceId}/materials/drive-import/{jobId} · POST /api/v1/workspaces/{workspaceId}/materials/drive-import/{jobId}/cancel`
- **Controllers (`brandhub-business-service`):** `DriveFolderImportController.start() / status() / cancel()`
- **Services:** `DriveFolderImportService, CustomerDriveSyncService, CustomerDriveImportStore, RepositoryEnvelopeCrypto, StorageQuotaService`
- **Repositories / Stores:** CustomerDriveImportStore, MaterialMongoRepository (`materials`, `material_folders`), StorageQuotaService

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 INVALID_DRIVE_FOLDER`, `403 FORBIDDEN`, `409 DRIVE_IMPORT_ALREADY_RUNNING`, `413 STORAGE_QUOTA_EXCEEDED` (`BR-36`, `BR-37`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

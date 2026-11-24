> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.12 — Add Material Repository

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.12` |
| **Use Case ID** | `UC-064` |
| **Feature** | Add Material Repository |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-36` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Tải lên tư liệu hình ảnh, video hoặc tài liệu thương hiệu mới vào kho của Workspace (Add Material Repository — /workspaces/:id/library). Người dùng chọn tệp từ máy tính, gắn phân loại bắt buộc (RAW, Retouched hoặc Brand Reference Asset), nhập tiêu đề, thẻ phân loại (tags) và ghi chú sử dụng. Hệ thống kiểm tra định dạng/dung lượng tệp hợp lệ và lưu trữ an toàn trên kho đối tượng S3 (BR-36).

**Consolidated Implementation Scope:** Folds in `add-material-repository`, `pre-s3-encryption`, `mp4-upload-detection`, `s3-folder-vault-security`, and `client-folder-sharing`: validates magic-byte signatures (including ISO-BMFF `ftyp` box inspection for `.mp4`/`.mov` video detection), enforces the 5 GB free S3 quota + monthly storage add-on limits (`StorageQuotaService`), encrypts payloads with per-object AES-256-GCM DEKs wrapped before S3 storage (`RepositoryEnvelopeCrypto`), creates nested folders, detects SHA-256 content / same-folder filename collisions (`Skip` / `Keep Both` / `Overwrite as v2..vN`), auto-tags `Client` uploads as `BRAND_REFERENCE` scoped to `clientProfileId`, and supports sharing `Client` Personal Vault folders across Workspaces without duplicating S3 bytes.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **Add Material Repository** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-36` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `POST /api/v1/workspaces/{workspaceId}/materials · POST /upload-session · POST /upload-session/multipart · POST /upload-session/{sessionId}/parts · POST /upload-session/confirm · DELETE /upload-session/{sessionId} · POST /folders · PUT /api/v1/repository-media · POST /api/v1/client-vault/folders · POST /api/v1/workspaces/{workspaceId}/client-vault/shares`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-36`):** `MaterialUploadCoordinator, MaterialUploadPolicy, MaterialContentValidator, RepositoryEnvelopeCrypto, StorageQuotaService, MaterialFolderService, MaterialVersionService, ClientVaultService` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `materials` (`sha256`, `folderId`, `versionNumber`, `encryptionMetadata`, `visibility`, `clientProfileId`), `material_folders`, `material_versions`, `client_vault_shares`; AWS S3 (`SYSTEM_S3`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 INVALID_FILE_TYPE` / `FILENAME_INVALID`, `403 FORBIDDEN`, `409 DUPLICATE_MATERIAL_DETECTED`, `413 FILE_TOO_LARGE` / `STORAGE_QUOTA_EXCEEDED` (`BR-36`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`library.upload.* / library.folders.* / library.duplicate.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/library/components/{MediaUploadButton,MaterialUploadForm,MaterialUploadFields,MaterialAudienceFields,MaterialFolderPicker,DuplicateResolutionModal}.tsx`, `src/services/materialService.ts`) and Mobile (`src/screens/content/{UploadScreen,TaskUploadScreen,CameraRecordScreen}.tsx`, `src/screens/more/MediaLibraryScreen.tsx`, `src/services/uploadService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/library/components/{MediaUploadButton,MaterialUploadForm,MaterialUploadFields,MaterialAudienceFields,MaterialFolderPicker,DuplicateResolutionModal}.tsx`, `src/services/materialService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content/{UploadScreen,TaskUploadScreen,CameraRecordScreen}.tsx`, `src/screens/more/MediaLibraryScreen.tsx`, `src/services/uploadService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `POST /api/v1/workspaces/{workspaceId}/materials · POST /upload-session · POST /upload-session/multipart · POST /upload-session/{sessionId}/parts · POST /upload-session/confirm · DELETE /upload-session/{sessionId} · POST /folders · PUT /api/v1/repository-media · POST /api/v1/client-vault/folders · POST /api/v1/workspaces/{workspaceId}/client-vault/shares`
- **Controllers (`brandhub-business-service`):** `MaterialController.uploadMaterial() / createUploadSession() / createMultipartUploadSession() / nextUploadParts() / confirmUploadSession() / cancelUploadSession(), MaterialFolderController.create(), RepositoryEncryptedMediaController.upload(), ClientVaultController.folder() / share()`
- **Services:** `MaterialUploadCoordinator, MaterialUploadPolicy, MaterialContentValidator, RepositoryEnvelopeCrypto, StorageQuotaService, MaterialFolderService, MaterialVersionService, ClientVaultService`
- **Repositories / Stores:** MaterialMongoRepository, MaterialSessionStore, StorageQuotaService

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 INVALID_FILE_TYPE` / `FILENAME_INVALID`, `403 FORBIDDEN`, `409 DUPLICATE_MATERIAL_DETECTED`, `413 FILE_TOO_LARGE` / `STORAGE_QUOTA_EXCEEDED` (`BR-36`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

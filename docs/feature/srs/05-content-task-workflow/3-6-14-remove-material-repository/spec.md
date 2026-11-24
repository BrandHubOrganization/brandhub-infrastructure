> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.14 — Remove Material Repository

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.14` |
| **Use Case ID** | `UC-066` |
| **Feature** | Remove Material Repository |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-36` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Xóa mềm tư liệu khỏi kho lưu trữ của Workspace (Remove Material Repository — /workspaces/:id/library/:materialId). Thực hiện xóa mềm (Soft Delete) để ẩn tư liệu khỏi danh sách chọn mới nhưng không làm mất liên kết hình ảnh/video trong các bài viết hoặc lịch sử công việc đã sử dụng tư liệu đó trước đây (BR-36).

**Consolidated Implementation Scope:** Folds in `remove-material-repository`, `manual-trash-purge`, and `trash-bulk-selection`: checks active Task/Post/Chat references (`MaterialReferenceChecker`), soft-deletes files and recursive folder trees into Trash (`deletedAt = now()`, 30-day retention before `MaterialTrashPurgeWorker` auto-purge), supports recursive restoration, and provides manual single-item & bulk-selected permanent purge (`POST /trash/purge`) that deletes encrypted S3 objects + versions and immediately reclaims S3 storage quota (`MaterialPurgeAccounting`, `BR-36`).

## 2. User Story

As an authorized actor (`Owner, Manager, Creator`), I want to execute **Remove Material Repository** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-36` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `DELETE /api/v1/workspaces/{workspaceId}/materials/{materialId} · POST /{materialId}/restore · POST /{materialId}/purge · POST /trash/purge · DELETE /folders/{folderId} · POST /folders/{folderId}/restore · POST /folders/{folderId}/purge`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-36`):** `MaterialTrashService, MaterialPermanentDeleteService, MaterialTrashPurgeWorker, MaterialReferenceChecker, MaterialPurgeAccounting` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `materials` (`deletedAt`, `deletedBy`, `purgeAfter`), `material_folders`, `material_versions`; AWS S3 (`SYSTEM_S3`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 MATERIAL_NOT_IN_TRASH`, `403 FORBIDDEN`, `404 MATERIAL_NOT_FOUND`, `409 MATERIAL_REFERENCED_BY_ACTIVE_POST_OR_TASK` (`BR-36`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`library.trash.* / library.delete.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/library/components/{MaterialTrashList,ConfirmSoftDeleteModal,ConfirmPermanentDeleteModal,MaterialDetailActions}.tsx`, `src/services/materialService.ts`) and Mobile (`src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/library/components/{MaterialTrashList,ConfirmSoftDeleteModal,ConfirmPermanentDeleteModal,MaterialDetailActions}.tsx`, `src/services/materialService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `DELETE /api/v1/workspaces/{workspaceId}/materials/{materialId} · POST /{materialId}/restore · POST /{materialId}/purge · POST /trash/purge · DELETE /folders/{folderId} · POST /folders/{folderId}/restore · POST /folders/{folderId}/purge`
- **Controllers (`brandhub-business-service`):** `MaterialController.deleteMaterial() / restoreMaterial() / purgeMaterial() / purgeTrash(), MaterialFolderController.delete() / restore() / purge()`
- **Services:** `MaterialTrashService, MaterialPermanentDeleteService, MaterialTrashPurgeWorker, MaterialReferenceChecker, MaterialPurgeAccounting`
- **Repositories / Stores:** MaterialTrashStore, MaterialMongoRepository (MongoDB `materials`, `material_folders`, `material_versions`), S3FileStorageServiceImpl

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 MATERIAL_NOT_IN_TRASH`, `403 FORBIDDEN`, `404 MATERIAL_NOT_FOUND`, `409 MATERIAL_REFERENCED_BY_ACTIVE_POST_OR_TASK` (`BR-36`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

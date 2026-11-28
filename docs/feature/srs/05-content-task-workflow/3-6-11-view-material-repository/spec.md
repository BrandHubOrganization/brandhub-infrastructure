> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.11 — View Material Repository

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.11` |
| **Use Case ID** | `UC-063` |
| **Feature** | View Material Repository |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-36` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Xem kho lưu trữ tư liệu sáng tạo của Workspace (View Material Repository — /workspaces/:id/library). Phân loại rõ ràng các nhóm tư liệu: (1) Ảnh/Video gốc chưa qua chỉnh sửa (RAW) kèm nhãn cảnh báo không được đăng trực tiếp (BR-36), (2) Ấn phẩm đã hậu kỳ hoàn chỉnh (Retouched/Final), và (3) Tài liệu nhận diện thương hiệu tham khảo do Client tải lên (Brand Assets for Reference). Hỗ trợ tìm kiếm và lọc theo phân loại, định dạng, người tải lên.

**Consolidated Implementation Scope:** Folds in `view-material-repository`, `s3-folder-vault-security`, `material-preview-recovery`, and `library-simple-ux`: renders a two-zone hierarchical browser (`--- folder` above `--- file`) with Vietnamese-collation sorting (`newest`, `oldest`, `name_asc`, `name_desc`), `mediaKind` (`IMAGE`, `VIDEO`, `FILE`), `type` (`RAW`, `RETOUCHED`, `WATERMARKED` with non-blocking `"Ảnh chưa chỉnh sửa"` warning badge on `RAW` photos, `BR-36`), `purpose` (`MATERIAL` vs `BRAND_REFERENCE`), strict per-`clientProfileId` audience isolation (`INTERNAL` vs `CLIENT`), `Client` Personal Vault shared folders, zero-N+1 short-lived encrypted capability preview URLs (`/api/v1/repository-media` with automatic expired-URL recovery), and 5 GB S3 quota meter (`/storage-usage`) — with `SystemRole.ADMIN` blocked from viewing tenant media.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **View Material Repository** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-36` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `GET /api/v1/workspaces/{workspaceId}/materials/browser · GET /api/v1/workspaces/{workspaceId}/materials · GET /{materialId} · POST /{materialId}/preview · GET /storage-usage · GET /api/v1/repository-media · GET /api/v1/client-vault/browser · GET /api/v1/workspaces/{workspaceId}/client-vault/browser`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-36`):** `MaterialReadService, MaterialFolderService, MaterialPageQuery, MaterialAccessPolicy, RepositoryEnvelopeCrypto, RepositoryPlaintextCache, ClientVaultService, MaterialStorageUsageService` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `materials` (`MaterialDocument`), `material_folders` (`MaterialFolderDocument`), `client_vault_shares`; AWS S3 (`SYSTEM_S3` AES-256-GCM envelope-encrypted objects) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 VALIDATION_ERROR`, `403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`, `404 MATERIAL_NOT_FOUND` (`BR-20`, `BR-36`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`library.* / materials.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/library/index.tsx`, `src/pages/library/components/{MediaTab,MaterialFolderSection,MaterialRepositoryCard,MaterialBadges,MediaDetailPanel,MaterialPreview,MaterialToolbar,MaterialTrashList}.tsx`, `src/services/materialService.ts`) and Mobile (`src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`, `src/utils/{repositoryLoader,repositoryFilters}.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/library/index.tsx`, `src/pages/library/components/{MediaTab,MaterialFolderSection,MaterialRepositoryCard,MaterialBadges,MediaDetailPanel,MaterialPreview,MaterialToolbar,MaterialTrashList}.tsx`, `src/services/materialService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`, `src/utils/{repositoryLoader,repositoryFilters}.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `GET /api/v1/workspaces/{workspaceId}/materials/browser · GET /api/v1/workspaces/{workspaceId}/materials · GET /{materialId} · POST /{materialId}/preview · GET /storage-usage · GET /api/v1/repository-media · GET /api/v1/client-vault/browser · GET /api/v1/workspaces/{workspaceId}/client-vault/browser`
- **Controllers (`brandhub-business-service`):** `MaterialFolderController.browse(), MaterialController.listMaterials() / getMaterial() / preview() / storageUsage() / listBrandAssets(), RepositoryEncryptedMediaController.read(), ClientVaultController.personal() / shared()`
- **Services:** `MaterialReadService, MaterialFolderService, MaterialPageQuery, MaterialAccessPolicy, RepositoryEnvelopeCrypto, RepositoryPlaintextCache, ClientVaultService, MaterialStorageUsageService`
- **Repositories / Stores:** MaterialMongoRepository (MongoDB `materials`, `material_folders`, `material_versions`, `client_vault_shares`)

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 VALIDATION_ERROR`, `403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`, `404 MATERIAL_NOT_FOUND` (`BR-20`, `BR-36`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

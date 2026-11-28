> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Encrypted S3 Material Repository, Storage Add-Ons, Client Folder Vault & Google Drive Sync

| Field | Value |
| :--- | :--- |
| **Module Slug** | `s3-folder-vault-security` |
| **Category** | `04-task-chat-vault` — Task Workflow, Realtime Workspace Chat & Encrypted S3 Vault |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Consolidated Feature Scopes** | `agency-storage-onboarding`, `pre-s3-encryption`, `s3-folder-vault-security`, `client-folder-sharing`, `client-drive-disconnect`, `client-drive-overflow`, `client-drive-workspace-sync`, `drive-import-authorization`, `library-simple-ux`, `manual-trash-purge`, `material-preview-recovery`, `mp4-upload-detection`, `trash-bulk-selection` |
| **Aligned SRS Domains** | [3.6 Content & Workflow — Material Repository](../../../srs/05-content-task-workflow/README.md) (`3.6.11–3.6.18`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Unify BrandHub's enterprise media storage architecture: **Pre-S3 Envelope Encryption** (`RepositoryEnvelopeCrypto` + `RepositoryEncryptedMediaController`), hierarchical **Folder & Trash Vault** (`MaterialController`, `MaterialFolderController`, `MaterialVersionController`), **Agency Storage Quota & SePay Storage Add-Ons** (`StorageAddonController`), **Client Private Vault & Selective Workspace Folder Sharing** (`ClientVaultController`), and **Customer Google Drive Integration** with paid S3 overflow & folder import (`CustomerDriveController`, `DriveFolderImportController`).

## 2. User Stories

- As an `Owner` or `Manager`, I want all Workspace media assets stored in an encrypted S3 folder hierarchy with strict quota reservations (`agency_storage_usage`), bulk trash purge, MP4 `ftyp` magic-byte detection, and purchasable S3 storage add-ons.
- As a `Client`, I want my own private **Client Vault** (`client_vault_*`) to organize brand assets and selectively share folders into specific Agency Workspaces (`POST /client-vault/shares`), or connect Google Drive with automatic paid S3 overflow.

## 3. Consolidated Acceptance Criteria

1. **Pre-S3 Envelope Encryption (`pre-s3-encryption`, `s3-folder-vault-security`):** `RepositoryEnvelopeCrypto` encrypts repository objects with per-object AES-256-GCM data keys wrapped by KMS/master envelope keys before S3 persistence (`RepositoryEncryptedMediaController` `/api/v1/repository-media`), enforcing strict tenant access checks before streaming decrypted previews/downloads (`material-preview-recovery`).
2. **Hierarchical Folders, MP4 Magic-Byte Detection & Trash Governance (`library-simple-ux`, `mp4-upload-detection`, `trash-bulk-selection`, `manual-trash-purge`):** `MaterialFolderController` (`/materials/browser`, `/folders/{id}/move|restore|purge`) and `MaterialController` (`/materials/trash/purge`, multipart upload sessions) validate MP4 (`isom`/`mp42`/`mp41`) & QuickTime `.mov` boxes accurately, support multi-select trash restore/permanent purge, and release `agency_storage_usage` atomically via `material_quota_releases` + `material_audit_receipts`.
3. **Agency Storage Onboarding & SePay Add-Ons (`agency-storage-onboarding`):** `StorageAddonController` (`/api/v1/storage/addons`, `/checkout`, `/orders/{orderId}`) and `agency_storage_reservations` enforce byte-exact storage quotas across `system_storage_pools`, allowing `Owner` to purchase recurring/top-up S3 capacity via SePay.
4. **Client Private Vault & Folder Sharing (`client-folder-sharing`):** `ClientVaultController` (`/api/v1/client-vault/browser`, `/folders`, `/api/v1/workspaces/{workspaceId}/client-vault/shares`) gives `Client` accounts an isolated vault (`client_vault_storage_usage`) and revocable read/use folder shares into designated Workspaces.
5. **Customer Google Drive Sync, Import & Paid S3 Overflow (`client-drive-overflow`, `client-drive-workspace-sync`, `client-drive-disconnect`, `drive-import-authorization`):** `CustomerDriveController` (`/workspaces/{workspace}/storage/drive`) and `DriveFolderImportController` (`/materials/drive-import`) manage OAuth Drive binding, asynchronous folder imports, seamless fallback to paid Agency S3 when Drive quota overflows, and destructive-confirmed Drive disconnect.
6. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`library.{folders,vault,encryption,trash,storageAddons,drive,clientVault}.*` in `src/i18n/locales/{vi,en}/library.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
7. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/library/*` (`CustomerDrivePanel.tsx`, `ConfirmSoftDeleteModal.tsx`, `ConfirmPermanentDeleteModal.tsx`, `LibraryResourceDropdown.tsx`)
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`, `src/utils/repositoryFilters.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET/POST/PATCH/DELETE /api/v1/workspaces/{workspaceId}/materials/** & /folders/**` | Bearer (`Owner, Manager, Creator, Client`) | `MaterialController`, `MaterialFolderController`, `MaterialVersionController` -> folders, multipart upload, preview, versions & bulk trash purge |
| `PUT/GET /api/v1/repository-media` | Signed Internal / Authorized Stream | `RepositoryEncryptedMediaController` + `RepositoryEnvelopeCrypto` -> envelope-encrypted S3 I/O |
| `GET /api/v1/storage/addons & POST /checkout` | Bearer (`Owner`) | `StorageAddonController` -> S3 storage add-on plans & SePay VietQR checkout |
| `GET/POST/PATCH/DELETE /api/v1/client-vault/** & /workspaces/{id}/client-vault/shares/**` | Bearer (`Client`; Workspace members read shared) | `ClientVaultController` -> Client Vault folders & selective Workspace sharing |
| `GET/POST/DELETE /api/v1/workspaces/{workspace}/storage/drive/** & /materials/drive-import/**` | Bearer (`Owner, Manager, Client`) | `CustomerDriveController` & `DriveFolderImportController` -> Google Drive sync, overflow & import jobs |

## 6. Error Handling, Security & Edge Cases

- **Upload Session Aborted / Expired:** `DELETE /upload-session/{sessionId}` and background reaper abort incomplete S3 multipart uploads and release `agency_storage_reservations` so failed uploads never leak quota.
- **Client Revokes Shared Vault Folder:** Immediate revocation on `DELETE /client-vault/shares/{shareId}` blocks new Workspace downloads while preserving already-published external social posts.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.6 Content & Workflow — Material Repository](../../../srs/05-content-task-workflow/README.md) (`3.6.11–3.6.18`)
- **BA & Architecture References:** [BA 05 Content & Task Workflow](../../../../ba/05-content-task-workflow.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).

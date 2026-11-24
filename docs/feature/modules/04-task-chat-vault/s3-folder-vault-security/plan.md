> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Encrypted S3 Material Repository, Storage Add-Ons, Client Folder Vault & Google Drive Sync (`s3-folder-vault-security`)

## 1. System Components & Touched Repositories

Consolidates the technical architecture for `agency-storage-onboarding`, `pre-s3-encryption`, `s3-folder-vault-security`, `client-folder-sharing`, `client-drive-disconnect`, `client-drive-overflow`, `client-drive-workspace-sync`, `drive-import-authorization`, `library-simple-ux`, `manual-trash-purge`, `material-preview-recovery`, `mp4-upload-detection`, `trash-bulk-selection` as specified in [spec.md](./spec.md):

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/workspaces/*/materials/**`, `/api/v1/client-vault/**`, `/api/v1/storage/addons/**`) |
| **Backend / Worker Services** | `MaterialController.java`, `MaterialFolderController.java`, `MaterialVersionController.java`, `RepositoryEncryptedMediaController.java`, `RepositoryEnvelopeCrypto.java`, `ClientVaultController.java`, `StorageAddonController.java`, `CustomerDriveController.java`, `DriveFolderImportController.java` |
| **Persistence, Cache & Brokers** | PostgreSQL `agency_storage_usage`, `agency_storage_reservations`, `storage_usage_entries`, `material_quota_releases`, `material_audit_receipts`, `storage_addon_plans`, `storage_addon_subscriptions`, `client_vault_storage_usage`, `client_vault_quota_releases`, `agency_drive_connections`, `workspace_drive_folders`, `repository_drive_objects`; MongoDB `materials`; AWS S3 encrypted vault |
| **Web Frontend (`brandhub-web`)** | `pages/library/*` (`CustomerDrivePanel.tsx`, `ConfirmSoftDeleteModal.tsx`, `ConfirmPermanentDeleteModal.tsx`, `LibraryResourceDropdown.tsx`) |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`, `src/utils/repositoryFilters.ts` |
| **i18n & Theme Assets** | `library.{folders,vault,encryption,trash,storageAddons,drive,clientVault}.*` in `src/i18n/locales/{vi,en}/library.json`; Mobile `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` & `src/theme/tokens.ts` |

## 2. Core Technical Design & Data Model Invariants

- **Envelope Encryption (`RepositoryEnvelopeCrypto`):** Generates unique 256-bit DEKs per asset with authenticated AAD bound to `(workspaceId / ownerId, objectId)`, preventing cross-object ciphertext substitution.
- **Reservation-Before-Transfer Quota Ledger:** Multipart sessions reserve exact byte size in `agency_storage_reservations` prior to S3 upload and commit/release idempotently.

## 3. End-to-End Data & Control Flow

1. **Ingress & Identity Propagation:** Requests pass through `brandhub-api-gateway` (`InboundSecurityWebFilter` -> `JwtAuthFilterGatewayFilterFactory` -> `RateLimitGatewayFilterFactory`), stripping external header spoofing and injecting verified `X-User-Id`, `X-Request-Id`, and role claims.
2. **Authorization & Invariant Validation:** Downstream controllers and services re-verify canonical role permissions (`Owner, Manager, Creator, Client`) and Agency/Workspace tenant membership against authoritative database state before mutating data or dispatching async jobs.
3. **Atomic Persistence & Event Fan-Out:** State transitions commit atomically across PostgreSQL `agency_storage_usage`, `agency_storage_reservations`, `storage_usage_entries`, `material_quota_releases`, `material_audit_receipts`, `storage_addon_plans`, `storage_addon_subscriptions`, `client_vault_storage_usage`, `client_vault_quota_releases`, `agency_drive_connections`, `workspace_drive_folders`, `repository_drive_objects`; MongoDB `materials`; AWS S3 encrypted vault using optimistic (`@Version` / `expectedRevision`) or pessimistic locks, emitting outbox/WebSocket/`pg_notify` events after commit.
4. **Client State Reconciliation:** `brandhub-web` and `brandhub-mobile-app` consume typed `ApiResponse<T>` envelopes, update user/tenant-scoped `TanStack Query` caches, and render localized UI states in Light and Dark themes.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Database / Storage / Config Baseline:** Apply additive migrations in `database/init/init-postgres-v2.sql` and `database/migrations/postgres/*.sql` (plus MongoDB/Neo4j/Redis indexes) with repeat-run idempotency.
2. **Phase 2 — Domain Services & Security Guards:** Implement core service logic, cryptographic/concurrency helpers, and internal service-to-service contracts.
3. **Phase 3 — Public REST / WebSocket / Worker Endpoints:** Wire controllers, consumers, and exception handlers returning standardized `ErrorCode` payloads.
4. **Phase 4 — Web & Mobile UI Surfaces:** Deliver responsive components, accessibility/keyboard navigation, and state transitions without mock data fallbacks.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Theme Audit:** Synchronize translation namespaces and verify semantic color tokens across Light and Dark modes.
6. **Phase 6 — Multi-Layer Verification:** Execute unit, integration, contract, and browser/mobile E2E suites documented in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new or updated label in `library.{folders,vault,encryption,trash,storageAddons,drive,clientVault}.*` in `src/i18n/locales/{vi,en}/library.json` is committed simultaneously in `vi` and `en` bundles on `brandhub-web` and mirrored in `brandhub-mobile-app/src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (verified by `mobileI18nParity.test.ts` and `i18nCoverage.test.ts`).
- **Light & Dark Theme Architecture:** Web components rely exclusively on semantic CSS custom properties (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` utility classes; Mobile components consume `useAppPreferences().palette` (`src/theme/tokens.ts`) verified by `tokens.test.ts`.
- **Structured Telemetry & Rollback Safety:** Every boundary logs `X-Request-Id`, latency, and classified `ErrorCode` while redacting tokens/PII. Additive schema migrations preserve backward-compatible rollback without dropping historical audit or ledger data.

## 6. Engineering Risks & Mitigations

- **Range-Request Video Seek Over Encrypted Media:** Streaming endpoints support chunk-aligned decryption and graceful client disconnect handling without buffering entire multi-hundred-MB MP4s in heap.

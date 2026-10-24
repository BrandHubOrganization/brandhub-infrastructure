# FR 3.6.11 — View Material Repository Specification

## Planning contract đã đồng bộ với BR01–BR25

Nguồn chuẩn: [Repository BR](../../../../../tuan-research/REPOSITORY_SPEC.md).
Reuse nền Add, không tạo storage/ACL/accounting thứ hai. Các chốt này ưu tiên hơn ví dụ nháp:

- Provider enum SYSTEM_GDRIVE/SYSTEM_S3/USER_GDRIVE; status upload 5 giá trị của Add;
  deleted_at và purge_state riêng. Không cấp URL cho deleted/purge-in-progress.
- Legacy URL chỉ phục vụ inventory/migration; không fallback public URL cho preview.
- CLIENT lọc query clientProfileId bằng giao với profile active; profile ngoài scope cho
  kết quả rỗng, không leak tồn tại. Single ID sai scope404; membership403.
- GET list trả mảng + MetaBody page/size/total; search prefix normalized escaped, sort
  created_at/_id; CLIENT và count dùng cùng predicate trước pagination.
- Trash predicate/capability restore chỉ được enable sau Remove; không tự expose mọi
  deleted material có quyền đọc nhưng không có quyền quản lý.
- OWNER usage ở GET /api/v1/agencies/{agencyId}/storage-usage, kiểm ownership, chỉ aggregate/
  breakdown workspace; không mở quyền Library hoặc trả file metadata. Workspace usage API
  không được lộ aggregate Agency cho CLIENT.
- previewUrl TTL≤300s trong list/detail, không HEAD mỗi item/N request preview grid;
  503 provider signing không được chuyển sang public URL. Credential refresh có thể I/O.
- Gateway subscription filter phải cho read/preview qua khi paid hết hạn/vượt quota.

- **Feature ID:** FR 3.6.11
- **Feature Name:** View Material Repository (`view-material-repository`)
- **Date:** 2026-10-24
- **Status:** Specification Ready (`spec.md` — Stage ① of `spec → plan → task → test`)
- **Scope:** `brandhub-api-gateway`, `brandhub-business-service`, `brandhub-infrastructure`, `brandhub-web` (with `brandhub-ui-design` as design reference)
- **Authoritative Business Rules:** `BR01`–`BR25` from `tuan-research/REPOSITORY_SPEC.md`

---

## 1. Problem Statement

Currently, when Agency staff (`MANAGER`, `CREATOR`) or external customers (`CLIENT`) open the Content Library (`MediaTab`) in BrandHub Web, the UI reads hardcoded sample items from `mockContentLibraryService` instead of the real backend repository. Meanwhile, the existing backend `MaterialController` and `MaterialServiceImpl` only support an unpaginated list query (`findByWorkspaceIdOrderByCreatedAtDesc`) with in-memory Java substring filtering, lack object-level audience isolation (`INTERNAL` vs `CLIENT` per `client_profile_id`), do not distinguish media format (`IMAGE`, `VIDEO`, `FILE`) from processing status (`RAW`, `RETOUCHED`, `WATERMARKED`) or usage purpose (`MATERIAL` vs `BRAND_REFERENCE`), do not warn users before using unedited `RAW` photos, and expose raw public URLs instead of short-lived private presigned preview URLs routed by storage provider (`SYSTEM_GDRIVE` / `SYSTEM_S3`).

As a result:
1. Users cannot browse, search, filter, or inspect real workspace materials with accurate pagination and metadata.
2. Multiple `CLIENT` profiles within the same workspace are not isolated at the material query level, risking cross-client data exposure if real data is connected directly.
3. Creators and Managers cannot distinguish unedited `RAW` photos from `RETOUCHED` deliverables, nor filter Client-supplied `BRAND_REFERENCE` documents from regular production materials.
4. Opening a grid of private media assets without inline presigned URLs would either fail to load thumbnails or trigger an $N+1$ storm of per-item preview requests.

---

## 2. Solution

Deliver **FR 3.6.11 — View Material Repository** by upgrading the existing `Material` read path in `brandhub-business-service` and replacing the mock media data source in `brandhub-web`'s `ContentLibraryPage` / `MediaTab` / `MediaDetailPanel` with the real paginated Material API:

1. **Workspace & Role-Scoped Access (`BR01`–`BR07`):**
   - Enforce workspace membership via PostgreSQL (`RequireRoleAspect` + service-level object ACL).
   - `MANAGER` and `CREATOR` view all active materials in their active workspace.
   - `CLIENT` views only materials in the workspace where `visibility = CLIENT` and `client_profile_id` matches the authenticated client's profile in that workspace.
   - `OWNER` without operational workspace membership (`MANAGER` or `CREATOR`) has no access to repository contents or `/library`.
2. **Classification, RAW Warning & Brand Reference (`BR08`–`BR09`, `BR12`):**
   - Separate `mediaKind` (`IMAGE`, `VIDEO`, `FILE`), processing `type` (`RAW`, `RETOUCHED`, `WATERMARKED`), and `purpose` (`MATERIAL`, `BRAND_REFERENCE`).
   - Display visible processing badges (`RAW`, `RETOUCHED`, `WATERMARKED`) and purpose badges (`Tài liệu tham khảo của Client` for `BRAND_REFERENCE`).
   - Render a non-blocking warning banner/badge (`"Ảnh chưa chỉnh sửa"`) on `RAW` images in both the grid card and detail panel (and before selecting a `RAW` image for content use).
3. **Scoped Search, Filtering & Stable Pagination:**
   - Replace unbounded Mongo queries and in-memory filtering with scoped MongoDB queries supporting `page` ($\ge 0$), `size` ($1\text{–}100$, default $20$), prefix/normalized `search` ($\le 100$ chars), `mediaKind`, `type`, `purpose`, `clientProfileId` (for `MANAGER`/`CREATOR`), `deleted` (active vs trash view), and `sort` (`newest` / `oldest` with stable tie-breaker `created_at` + `_id`).
   - Keep `ApiResponse<List<MaterialResponse>>` where `data` remains a JSON array (`List<MaterialResponse>`) and `meta` carries `MetaBody(page, size, total)` for backward compatibility.
4. **Zero-N+1 Inline Preview URLs & Refresh (`BR13`–`BR14`, `BR20`–`BR21`, `BR23`):**
   - For every item in list/detail where `status = READY`, `deleted_at = null`, and the MIME type is previewable (`image/jpeg`, `image/png`, `image/webp`, `video/mp4`, `video/quicktime`, `application/pdf`), sign an inline `previewUrl` (`Content-Disposition: inline`, TTL $300\text{s}$ / $5\text{ minutes}$) directly during list/detail response mapping via `StorageClientRouter` (`SYSTEM_GDRIVE` or `SYSTEM_S3`) without per-item `HEAD` calls or $N$ extra HTTP requests from the browser.
   - Provide `POST /api/v1/workspaces/{workspaceId}/materials/{materialId}/preview` solely to refresh an expired `previewUrl` when a user keeps the detail viewer open longer than 5 minutes.
   - Preserve full read/preview access even when the Agency is over storage quota or its paid subscription has expired (`BR20`, `BR21`).

---

## 3. Authoritative Business Rules Applied (`BR01`–`BR25`)

| Rule ID | Business Rule Summary | Application to FR 3.6.11 (View Material Repository) |
|---|---|---|
| **BR01** | Single-workspace scope | Every query requires `workspace_id` from the URL path; no cross-workspace listing or lookup. |
| **BR02** | `OWNER` permissions | `OWNER` cannot call list/detail/preview unless holding an active `MANAGER` or `CREATOR` membership in the workspace. Agency storage metrics use a separate Billing endpoint that never exposes material metadata or URLs. |
| **BR03** | `MANAGER` permissions | Views and previews all materials (both `INTERNAL` and `CLIENT`, plus workspace trash) in managed workspaces; receives full mutation capability flags (`canRename`, `canChangeAudience`, `canDelete`, `canRestore`). |
| **BR04** | `CREATOR` permissions | Views and previews all active materials in the workspace (`INTERNAL` and `CLIENT`); receives `canRename`/`canDelete`/`canRestore` equal to `true` only on materials where `created_by == actorUserId`. |
| **BR05** | `CLIENT` permissions | Views and previews only materials in the workspace where `visibility = CLIENT` and `client_profile_id` belongs to the authenticated client in that workspace; `canRename`/`canDelete`/`canRestore` is `true` only when `created_by == actorUserId`. |
| **BR06** | Sharing scope | Canonical field is `visibility` (`INTERNAL` \| `CLIENT`) paired with `client_profile_id`. `CLIENT` never sees `INTERNAL` materials or materials assigned to another `client_profile_id`. |
| **BR07** | Audience change authority | `capabilities.canChangeAudience` is `true` only for active `MANAGER` (and `SystemRole.ADMIN`). |
| **BR08** | Processing classification & `RAW` warning | Card and detail views show `RAW`, `RETOUCHED`, and `WATERMARKED` badges. When `mediaKind = IMAGE` and `type = RAW`, UI displays the `"Ảnh chưa chỉnh sửa"` warning badge/banner without blocking preview or download. |
| **BR09** | Brand reference purpose | `purpose = MATERIAL \| BRAND_REFERENCE` is independent of `mediaKind` and `type`. UI provides a filter for `purpose` and displays `"Tài liệu tham khảo của Client"` on `BRAND_REFERENCE` items. Does not replace `/materials/brand-assets` (logo list for watermark). |
| **BR10** | Lineage & immutability | Detail view displays lineage metadata (`parentMaterialId`, `watermarkMeta`) when present so users can see if an asset is a retouched or watermarked derivative. |
| **BR11** | Task linkage | Detail view and response DTO preserve `taskId` when a material was uploaded from a Task flow. |
| **BR12** | Allowed file types | MVP supports `IMAGE` (`jpeg`, `png`, `webp`), `VIDEO` (`mp4`, `quicktime`), and `FILE` (`pdf`). Legacy or browser-unsupported codecs (e.g., certain `video/quicktime` streams or legacy Office files) show a clear `previewUnsupported` fallback state in the detail view. |
| **BR13** | Preview eligibility | Only materials with `status = READY`, `deleted_at = null`, and valid read permission receive a `previewUrl`. Non-READY states (`UPLOADING`, `VALIDATING`, `REJECTED`, `FAILED`) show status badges instead of broken images. |
| **BR14** | Access revocation & TTL | Permission is verified on every list/detail/preview-refresh request. `previewUrl` TTL is at most **300 seconds (5 minutes)**. API responses with signed URLs include `Cache-Control: no-store`. |
| **BR15** | Soft delete & Trash view | Default list hides soft-deleted items (`deleted = false`). Switching to Trash view (`deleted = true`) lists soft-deleted items within the actor's allowed scope along with `deletedAt` and `purgeAfter` (30-day retention), without issuing `previewUrl`. |
| **BR17–22** | Quota & Subscription expiry | Over-quota or expired subscription states (`BR20`, `BR21`) never block `GET /materials`, `GET /materials/{id}`, or `POST /materials/{id}/preview`. `GET /storage-usage` reports workspace/agency storage usage (`usedBytes`, `reservedBytes`, `quotaBytes`). |
| **BR23–25** | Multi-tier storage routing | Each material stores its `storage_provider` (`SYSTEM_GDRIVE`, `SYSTEM_S3`, or future `USER_GDRIVE`). `StorageClientRouter` signs the `previewUrl` against the material's own `storage_provider` without migrating files across providers. |

---

## 4. Current Codebase vs. Required Changes (Gap Analysis)

### 4.1 Backend (`brandhub-business-service`) & Database (`brandhub-infrastructure`)

| Component | Current State (Implemented) | Required Additions / Modifications for FR 3.6.11 |
|---|---|---|
| **MongoDB Collection (`MaterialDocument`)** | Maps `materials` collection with `id`, `workspace_id`, `name`, `original_name`, `type` (`RAW`, `RETOUCHED`, `WATERMARKED`), `mime_type`, `file_size`, `url`, `s3_key`, `parent_material_id`, `task_id`, `watermark_meta`, `created_by`, `created_at`, `updated_at`. | Extend `MaterialDocument` (snake_case fields) with: `media_kind` (`IMAGE`, `VIDEO`, `FILE`), `purpose` (`MATERIAL`, `BRAND_REFERENCE`, default `MATERIAL`), `visibility` (`INTERNAL`, `CLIENT`, default `INTERNAL`), `client_profile_id` (nullable String), `storage_provider` (`SYSTEM_GDRIVE`, `SYSTEM_S3`, `USER_GDRIVE`), `status` (`UPLOADING`, `VALIDATING`, `READY`, `REJECTED`, `FAILED`), `normalized_name`, `deleted_at`, `deleted_by`, `purge_after`, `updated_by`, `version`. |
| **MongoDB Indexes & Migration** | Basic repository methods `findByWorkspaceIdOrderByCreatedAtDesc` and `findByWorkspaceIdAndTypeOrderByCreatedAtDesc`. | Add compound indexes `{workspace_id: 1, deleted_at: 1, status: 1, created_at: -1, _id: -1}` and `{workspace_id: 1, visibility: 1, client_profile_id: 1, deleted_at: 1, status: 1, created_at: -1, _id: -1}`. Provide idempotent `DRY_RUN`-default migration to backfill `purpose = MATERIAL`, `visibility = INTERNAL`, `media_kind` from `mime_type`, `status = READY` (for verified existing objects), `normalized_name`, and `version = 0`. |
| **Repository & Querying (`MaterialMongoRepository`)** | Returns unbounded `List<MaterialDocument>`; `MaterialServiceImpl.listMaterials` filters `search` in Java RAM using `.stream().filter(...)`. | Replace RAM filtering with `MongoTemplate` / scoped criteria queries applying `workspace_id`, role/client ACL (`visibility = CLIENT` + `client_profile_id` for `CLIENT`), `deleted_at` (`null` vs non-null), `media_kind`, `type`, `purpose`, escaped prefix match on `normalized_name`, stable sort (`created_at` + `_id`), and `Pageable` (`page`, `size`) + scoped `count`. |
| **Controller (`MaterialController`)** | Has `GET /api/v1/workspaces/{workspaceId}/materials` (params: `type`, `search` only; `meta = null`), `GET /{materialId}`, and `GET /brand-assets`. | Expand `GET /` query params (`page`, `size`, `search`, `mediaKind`, `type`, `purpose`, `clientProfileId`, `deleted`, `sort`) and return `ApiResponse.ok(items, meta, requestId)` with `Cache-Control: no-store`. Pass `@AuthenticationPrincipal AuthenticatedUser` into `listMaterials` and `getMaterial`. Add optional `POST /{materialId}/preview` for TTL refresh and `GET /storage-usage` for workspace quota banner. |
| **Preview URL Signing (`FileStorageService` / `StorageClientRouter`)** | `S3FileStorageServiceImpl.createPresignedDownloadUrl` signs a GET URL using global TTL (`3600s`) without `ResponseContentDisposition` or provider routing. | Add `createPresignedPreviewUrl(storageProvider, s3Key, mimeType, ttlSeconds = 300)` setting `ResponseContentDisposition = inline` and `ResponseContentType = mimeType`. Sign inline for `READY` non-deleted items during list/detail construction without per-item `HEAD` network calls. |
| **Authorization (`RequireRoleAspect` & Service ACL)** | `RequireRoleAspect` checks `MANAGER`, `CREATOR`, `CLIENT` membership against path `workspaceId` in PostgreSQL (`OWNER` excluded on `MaterialController`). | Reuse `RequireRoleAspect` at controller boundary; add service-layer object ACL resolver that resolves the caller's active `MemberRole` and `clientProfileIds` in `workspaceId` from PostgreSQL to enforce `BR03`–`BR07` on list, count, detail, and preview refresh. |

### 4.2 Frontend (`brandhub-web`)

| Component | Current State (Implemented) | Required Additions / Modifications for FR 3.6.11 |
|---|---|---|
| **Route Access (`src/routes/access.ts`)** | `"/library": ["MANAGER", "CREATOR", "CLIENT"]` (`OWNER` excluded, `ADMIN` bypasses). | Keep unchanged — already matches `BR02`–`BR05`. |
| **API Service (`src/services/materialService.ts`)** | Has `list(workspaceId, type?, search?)` returning `MaterialItem[]` and `get(workspaceId, materialId)`. Unused by `MediaTab.tsx`. | Keep `list(...)` returning `MaterialItem[]` for backward compatibility; add `listRepository(workspaceId, params)` returning `{ items: MaterialItem[]; meta: MetaBody }`, `refreshPreviewUrl(workspaceId, materialId)`, and `getStorageUsage(workspaceId)`. |
| **Library Page (`src/pages/library/index.tsx`)** | Shows hardcoded KPI counters (`16+`, `6 Nhóm`, `8 Mẫu`) and renders `<MediaTab />`. | Bind Media KPI count / tab badge to the real `meta.total` from the scoped Material query (or hide hardcoded `16+` mock number) while keeping Hashtag/Template tabs intact. |
| **Media Grid (`src/pages/library/components/MediaTab.tsx`)** | Calls `mockContentLibraryService.getMedia(...)`, filters by mock `aspectRatio` (`1:1`, `9:16`, `16:9`, `4:5`), copies raw S3 URL to clipboard, and lacks `FILE`/`PDF`, `RAW`/`RETOUCHED`/`WATERMARKED`, `purpose`, and `clientProfileId` filters. | Replace `mockContentLibraryService` with TanStack Query + `materialService.listRepository`. Replace mock orientation filter with real filters: `mediaKind` (`ALL`, `IMAGE`, `VIDEO`, `FILE`), `type` (`ALL`, `RAW`, `RETOUCHED`, `WATERMARKED`), `purpose` (`ALL`, `MATERIAL`, `BRAND_REFERENCE`), `clientProfileId` (visible to `MANAGER`/`CREATOR`), `deleted` (Active vs Trash toggle), and `sort` (`newest`, `oldest`) + `page`/`size` pagination. Render `RAW` warning badge, `BRAND_REFERENCE` badge, and status placeholders (`UPLOADING`, `VALIDATING`, `REJECTED`, `FAILED`). Remove raw S3 URL copy button. |
| **Detail Panel (`src/pages/library/components/MediaDetailPanel.tsx`)** | Renders slide-over panel from mock `MediaItem`, displays `"S3 Direct URL"` input with copy button, and shows Delete / Watermark buttons unconditionally. | Upgrade to use real `MaterialItem` / `getMaterial` detail response: preview `IMAGE`, `VIDEO` (with seek/range), and `PDF` (sandboxed viewer) using `previewUrl` (auto-refreshing via `POST /{id}/preview` if expired); show `previewUnsupported` fallback for unsupported codecs; display `RAW` warning alert, `purpose`, `visibility` + client profile name, uploader, timestamps, lineage (`parentMaterialId`); remove `"S3 Direct URL"` input (`BR14`); gate action buttons (`Download`, `Rename`, `Audience`, `Watermark`, `Delete`, `Restore`) strictly by server-returned `capabilities`. |

---

## 5. User Stories

1. **As a Workspace Manager**, I want to view a paginated grid of all materials (`IMAGE`, `VIDEO`, `FILE`) in my workspace with their processing status (`RAW`, `RETOUCHED`, `WATERMARKED`), audience (`INTERNAL`, `CLIENT`), and usage purpose (`MATERIAL`, `BRAND_REFERENCE`), so that I can oversee all creative assets and Client references in one place.
2. **As a Workspace Creator**, I want to browse and filter all materials in my workspace by media kind, processing type (`RAW`, `RETOUCHED`, `WATERMARKED`), and purpose (`MATERIAL`, `BRAND_REFERENCE`), so that I can quickly find raw assets to retouch or Client brand references to follow.
3. **As a Workspace Client**, I want to view only the materials that I uploaded or that the Agency explicitly shared with my Client Profile in this workspace (`visibility = CLIENT` and matching `client_profile_id`), so that my brand assets and deliverables remain isolated from other Clients in the same workspace.
4. **As an Agency Owner without operational workspace membership**, I want the system to block me from viewing workspace repository files while still letting me see aggregate storage usage in Billing/Subscription, so that workspace confidentiality rules (`BR02`) are respected.
5. **As a Manager or Creator**, I want to see a clear `"Ảnh chưa chỉnh sửa"` (`RAW`) warning badge on unedited photos in both the grid card and the detail view (and before attaching a `RAW` photo to content), so that I do not accidentally publish unedited raw imagery.
6. **As a Creator or Manager**, I want materials uploaded with `purpose = BRAND_REFERENCE` to display a `"Tài liệu tham khảo của Client"` badge and be filterable in the toolbar, so that I can separate Client guidelines/references from production deliverables.
7. **As a Manager, Creator, or Client**, I want thumbnails and previews for `READY` images, videos, and PDFs to load immediately from inline short-lived signed URLs returned with the list response, so that browsing a page of 20 items does not trigger 20 extra HTTP requests (`N+1`).
8. **As a Manager, Creator, or Client**, I want to open a detail panel for any material to inspect its full preview (image, video player with range seek, or PDF preview), file size, MIME type, upload date, creator, audience scope, processing type, purpose, and lineage (`parentMaterialId`), so that I can verify the asset before downloading or using it.
9. **As a user keeping the detail view open for more than 5 minutes**, I want the UI to refresh the material's `previewUrl` when it expires (or when the media element reports an expired signature), so that I can continue previewing without reloading the entire page.
10. **As a user inspecting a file whose format or codec cannot be rendered inline by the browser** (such as certain `video/quicktime` `.mov` codecs or legacy non-previewable files), I want to see a clear `"Không hỗ trợ xem trước trực tiếp"` fallback state with full file metadata and a Download action (if permitted), so that I understand the file is intact and can still download it.
11. **As a user viewing materials that are still `UPLOADING`, `VALIDATING`, `REJECTED`, or `FAILED`**, I want the card and detail view to display the exact processing state and reason instead of a broken image icon, so that I know whether to wait or re-upload.
12. **As a Manager, Creator, or Client**, I want to switch to the Trash view (`deleted = true`) to see soft-deleted materials within my permitted scope along with their scheduled purge date (`purgeAfter`), so that I can identify accidentally deleted files that need restoration.
13. **As a Manager, Creator, or Client in an Agency whose storage quota is full or whose paid subscription has expired**, I want to continue viewing, searching, filtering, and previewing all existing `READY` materials without restriction, so that quota locks only prevent new data creation (`BR20`, `BR21`).
14. **As a user belonging to multiple workspaces**, I want switching workspaces while a material list or detail request is in flight to cancel or ignore the stale response from the previous workspace, so that materials from Workspace A never flash inside Workspace B.
15. **As a Vietnamese or English user using Light or Dark mode on desktop, tablet, or mobile via keyboard or mouse**, I want all repository labels, badges, filters, warnings, empty states, and errors to switch languages without hardcoded text, maintain WCAG 2.1 AA contrast in both themes, and support full keyboard navigation (`Tab`, `Enter`, `Escape`).

---

## 6. Implementation Decisions

### 6.1 Architectural & Module Decisions

1. **Reuse Existing `materials` Collection & `MaterialController` Base Path:**
   - Keep collection `materials` in MongoDB and base path `/api/v1/workspaces/{workspaceId}/materials`. Do not create a separate `material_repository` or `brand_collections` collection (`BR09`, ADR-002 reconciliation).
   - Keep PostgreSQL as the single source of truth for workspace membership, roles, `client_profiles`, and Agency subscription/quota state. Never denormalize `agency_id` into MongoDB documents; resolve `agencyId` via `workspaceId` in PostgreSQL when needed.
   - Do **not** introduce Redis caching for material lists, object ACLs, or presigned URLs (`REPOSITORY_SPEC.md` §11).
2. **Server-Side Actor Scope Resolution (Zero Trust on Client Params):**
   - For every request to `GET /materials`, `GET /materials/{id}`, and `POST /materials/{id}/preview`, the service resolves the caller's active `WorkspaceMember` records in `workspaceId` from PostgreSQL:
     - If `SystemRole == ADMIN`: allowed to read workspace materials (still scoped to `workspaceId` path parameter).
     - If active `MANAGER` or `CREATOR` in `workspaceId`: allowed to read all materials in `workspaceId`; may optionally filter by `clientProfileId`.
     - If active `CLIENT` in `workspaceId` (resolved via `client_profiles.user_id -> workspace_members.client_profile_id` where `role = CLIENT` and `is_active = true`): mandatory query filter `visibility == 'CLIENT'` AND `client_profile_id IN (callerActiveClientProfileIdsInWorkspace)`. Any `clientProfileId` query parameter not belonging to the caller is rejected or intersected with the caller's own active profile IDs in that workspace (`404` on single-item mismatch, empty/scoped on list).
     - If the user is only the Agency `OWNER` without an active `MANAGER`/`CREATOR` membership row in `workspaceId`: `RequireRoleAspect` rejects access with `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN` (`BR02`).
3. **Inline Presigning Without $N+1$ or Per-Item `HEAD`:**
   - Presigning a `GET` URL with AWS S3 SDK (`S3Presigner`) is a local cryptographic operation using the configured credentials and endpoint of the material's `storage_provider` (`SYSTEM_GDRIVE` or `SYSTEM_S3`).
   - During `listMaterials` and `getMaterial`, for each document where `status == READY` and `deletedAt == null` and `isPreviewableMimeType(mimeType)`:
     - If `s3Key` is present, `StorageClientRouter` generates a presigned GET URL with `ResponseContentDisposition = "inline"`, `ResponseContentType = doc.getMimeType()`, and `signatureDuration = Duration.ofSeconds(300)` ($5\text{ minutes}$).
     - Legacy compatibility: legacy URLs are migration inputs only. If a document has no verified private key/provider, do not return its public URL; return metadata without preview and reconcile before publication. Newly uploaded/migrated materials always sign from verified key/provider.
   - Do **not** execute `HEAD Object` for each item in `GET /materials` list. `HEAD` verification belongs to upload confirm and download link issuance (`FR 3.6.16`).
4. **Action Capabilities Driven by Server (`capabilities` Object):**
   - To prevent the UI from guessing mutation permissions or drifting from `BR03`–`BR08`, each `MaterialResponse` includes a `capabilities` object computed for the current caller:
     - `canPreview`: `status == READY && deletedAt == null && isPreviewableMimeType(mimeType)`
     - `canDownload`: `status == READY && deletedAt == null` (all roles that can read the material can download it per `BR03`–`BR05`, `BR13`)
     - `canRename`: `deletedAt == null` and (`role == MANAGER` or (`role in [CREATOR, CLIENT]` and `createdBy == callerUserId`))
     - `canUpdateType`: `deletedAt == null && status == READY && type in [RAW, RETOUCHED]` and (`role == MANAGER` or (`role in [CREATOR, CLIENT]` and `createdBy == callerUserId`)) (`BR08`)
     - `canChangeAudience`: `deletedAt == null && role == MANAGER` (`BR07`)
     - `canWatermark`: `deletedAt == null && status == READY && mediaKind == IMAGE && role in [MANAGER, CREATOR]`
     - `canDelete`: `deletedAt == null` and (`role == MANAGER` or (`role in [CREATOR, CLIENT]` and `createdBy == callerUserId`))
     - `canRestore`: `deletedAt != null` and (`role == MANAGER` or (`role in [CREATOR, CLIENT]` and `createdBy == callerUserId`))

---

## 7. Data Model & Database Specification

### 7.1 MongoDB Collection: `materials` (`MaterialDocument`)

| Logical Field | Physical Mongo Field | Type | Required / Default | Description & Constraints |
|---|---|---|---|---|
| `id` | `_id` | `String` | Required | Existing String ID / ObjectId hex string. |
| `workspaceId` | `workspace_id` | `String` | Required | UUID string of the owning Workspace (`BR01`). Mandatory in every query. |
| `name` | `name` | `String` | Required (`1..255` chars) | Display filename (sanitized Unicode, no `/`, `\`, control chars, or CRLF). |
| `normalizedName` | `normalized_name` | `String` | Required | Lowercased, trimmed, Unicode NFC-normalized `name` for indexed prefix search. |
| `originalName` | `original_name` | `String` | Required (`1..255` chars) | Original filename captured at upload time. |
| `mediaKind` | `media_kind` | `Enum String` | Required | `IMAGE` \| `VIDEO` \| `FILE`. Derived from verified `mime_type`. |
| `type` | `type` | `Enum String` | Required (`RAW`) | Processing state: `RAW` \| `RETOUCHED` \| `WATERMARKED` (`BR08`). |
| `purpose` | `purpose` | `Enum String` | Required (`MATERIAL`) | Usage purpose: `MATERIAL` \| `BRAND_REFERENCE` (`BR09`). |
| `visibility` | `visibility` | `Enum String` | Required (`INTERNAL`) | Audience scope: `INTERNAL` \| `CLIENT` (`BR06`, `BR07`). |
| `clientProfileId` | `client_profile_id` | `String` (UUID) | Nullable | Required when `visibility = CLIENT`; `null` when `visibility = INTERNAL`. |
| `mimeType` | `mime_type` | `String` | Required | Verified MIME type (`image/jpeg`, `image/png`, `image/webp`, `video/mp4`, `video/quicktime`, `application/pdf`). |
| `fileSize` | `file_size` | `Long` | Required (`> 0`) | Size in bytes of the stored object. |
| `s3Key` | `s3_key` | `String` | Required (post-migration) | Private canonical storage key (`repository/{workspaceId}/{materialId}/original`). Never returned to browser DTOs. |
| `storageProvider` | `storage_provider` | `Enum String` | Required (`SYSTEM_GDRIVE`) | `SYSTEM_GDRIVE` \| `SYSTEM_S3` \| `USER_GDRIVE` (`BR23`, `BR25`). |
| `url` | `url` | `String` | Legacy Nullable | Legacy field only; new writers set `null` and never persist presigned URLs. |
| `status` | `status` | `Enum String` | Required (`READY` for legacy) | `UPLOADING` \| `VALIDATING` \| `READY` \| `REJECTED` \| `FAILED` (`BR13`). |
| `parentMaterialId` | `parent_material_id` | `String` | Nullable | ID of the source material in the same workspace when retouched or watermarked (`BR04`, `BR10`). |
| `taskId` | `task_id` | `String` | Nullable | Linked Task ID when uploaded via Task flow (`BR11`). |
| `watermarkMeta` | `watermark_meta` | `Object` | Nullable | Existing `WatermarkMetadata` embedded object when `type = WATERMARKED`. |
| `createdBy` | `created_by` | `String` | Required | User UUID string of the uploader (`BR04`, `BR05`). |
| `updatedBy` | `updated_by` | `String` | Nullable | User UUID string of the last metadata modifier. |
| `createdAt` | `created_at` | `Instant` (Date) | Required | Creation UTC timestamp. |
| `updatedAt` | `updated_at` | `Instant` (Date) | Required | Last modification UTC timestamp. |
| `deletedAt` | `deleted_at` | `Instant` (Date) | Nullable (`null`) | Soft-delete UTC timestamp (`null` when active; non-null when in Trash per `BR15`). |
| `deletedBy` | `deleted_by` | `String` | Nullable (`null`) | User UUID string who soft-deleted the material. |
| `purgeAfter` | `purge_after` | `Instant` (Date) | Nullable (`null`) | `deleted_at + 30 days` (`BR15`). |
| `version` | `version` | `Long` | Required (`0`) | Optimistic concurrency version counter. |

### 7.2 Required MongoDB Indexes

1. **Workspace Active/Trash Listing & Sorting Index:**
   ```javascript
   { workspace_id: 1, deleted_at: 1, status: 1, created_at: -1, _id: -1 }
   ```
2. **Client-Scoped Listing & Filtering Index:**
   ```javascript
   { workspace_id: 1, visibility: 1, client_profile_id: 1, deleted_at: 1, status: 1, created_at: -1, _id: -1 }
   ```
3. **Scoped Prefix Search Index:**
   ```javascript
   { workspace_id: 1, deleted_at: 1, normalized_name: 1, created_at: -1, _id: -1 }
   ```
4. **Canonical Key Uniqueness Index (Partial):**
   ```javascript
   // Partial filter: { s3_key: { $type: "string" } }
   { s3_key: 1 } // unique: true
   ```

---

## 8. API Contract

Base path: `/api/v1/workspaces/{workspaceId}/materials`  
Authentication: `Authorization: Bearer <accessToken>` (validated by Gateway `JwtAuthFilter` and Business `RequireRoleAspect`).  
Response headers for all endpoints returning signed URLs: `Cache-Control: no-store`.

### 8.1 List & Search Materials — `GET /api/v1/workspaces/{workspaceId}/materials`

- **Allowed Roles:** `MANAGER`, `CREATOR`, `CLIENT` (active member of `workspaceId`), `SystemRole.ADMIN`. (`OWNER` without operational membership is rejected with `403`).
- **Query Parameters:**

| Parameter | Type | Default | Constraints & Behavior |
|---|---|---|---|
| `page` | `int` | `0` | $\ge 0$. Zero-based page index. Invalid ($< 0$) returns `400 VALIDATION_ERROR`. |
| `size` | `int` | `20` | $1\text{–}100$. Page size. Invalid ($< 1$ or $> 100$) returns `400 VALIDATION_ERROR`. |
| `search` | `String` | `null` | Optional, trimmed, max $100$ characters. Escaped regex prefix/token match against `normalized_name` (and `original_name` fallback). $> 100$ chars returns `400 VALIDATION_ERROR`. |
| `mediaKind` | `Enum` | `null` (All) | Optional: `IMAGE`, `VIDEO`, `FILE`. |
| `type` | `Enum` | `null` (All) | Optional: `RAW`, `RETOUCHED`, `WATERMARKED`. |
| `purpose` | `Enum` | `null` (All) | Optional: `MATERIAL`, `BRAND_REFERENCE`. |
| `clientProfileId` | `UUID` | `null` | Optional filter for `MANAGER`/`CREATOR` to filter materials shared with a specific Client Profile in `workspaceId`. For `CLIENT` callers, server always enforces the caller's own active `client_profile_id` in `workspaceId` (if a `CLIENT` passes another profile's ID, return `403 CLIENT_ACCESS_DENIED`). |
| `deleted` | `boolean` | `false` | `false`: active materials (`deleted_at == null`). `true`: Trash view (`deleted_at != null`; for `CREATOR`/`CLIENT`, restricted to items within their read scope that they are permitted to see/restore). |
| `sort` | `String` | `"newest"` | `"newest"` (`created_at DESC, _id DESC`) or `"oldest"` (`created_at ASC, _id ASC`). Any other value returns `400 VALIDATION_ERROR`. |

- **Success Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "671a0f8b2c4e1a3b5d7f9012",
      "workspaceId": "550e8400-e29b-41d4-a716-446655440000",
      "name": "hero-banner-summer.jpg",
      "originalName": "DSC_0912.jpg",
      "mediaKind": "IMAGE",
      "type": "RAW",
      "purpose": "MATERIAL",
      "visibility": "CLIENT",
      "clientProfileId": "770e8400-e29b-41d4-a716-446655440111",
      "clientDisplayName": "Nike Vietnam",
      "mimeType": "image/jpeg",
      "fileSize": 4194304,
      "status": "READY",
      "rawWarning": true,
      "previewUrl": "https://storage.example/repository/...?X-Amz-Expires=300&...",
      "previewExpiresAt": "2026-10-24T10:35:00Z",
      "parentMaterialId": null,
      "taskId": null,
      "watermarkMeta": null,
      "createdBy": "880e8400-e29b-41d4-a716-446655440222",
      "createdByName": "Nguyễn Minh Tuấn",
      "createdAt": "2026-10-24T10:00:00Z",
      "updatedAt": "2026-10-24T10:00:00Z",
      "deletedAt": null,
      "purgeAfter": null,
      "version": 0,
      "capabilities": {
        "canPreview": true,
        "canDownload": true,
        "canRename": true,
        "canUpdateType": true,
        "canChangeAudience": true,
        "canWatermark": true,
        "canDelete": true,
        "canRestore": false
      }
    }
  ],
  "error": null,
  "meta": {
    "page": 0,
    "size": 20,
    "total": 1
  },
  "requestId": "c39e1416-4b02-4091-81a0-50a6f673f212",
  "version": "v1",
  "timestamp": "2026-10-24T10:30:00Z"
}
```
> **Note on `url` compatibility:** During the transition window for existing callers (`WatermarkStudioModal`, `MediaDropzone`), `url` in `MaterialResponse` may mirror `previewUrl` for `READY` items, but `s3Key` and storage credentials are **never** serialized in the response DTO. When `deletedAt != null` or `status != READY` or `canPreview == false`, `previewUrl` and `previewExpiresAt` are `null`.

### 8.2 Get Material Detail — `GET /api/v1/workspaces/{workspaceId}/materials/{materialId}`

- **Allowed Roles:** `MANAGER`, `CREATOR`, `CLIENT` (within object ACL), `SystemRole.ADMIN`.
- **Behavior:**
  - Looks up material by `{ _id: materialId, workspace_id: workspaceId }`.
  - If not found, or if the caller is a `CLIENT` and the material is `INTERNAL` or belongs to a different `client_profile_id`, throws `404 MATERIAL_NOT_FOUND` (never leaks whether the ID exists under another client/workspace).
  - Returns the full `MaterialResponse` (including `previewUrl` with 300s TTL if `status == READY && deletedAt == null && canPreview`, `rawWarning = (mediaKind == IMAGE && type == RAW)`, lineage info `parentMaterialId`, and computed `capabilities`).

### 8.3 Refresh Expired Preview URL — `POST /api/v1/workspaces/{workspaceId}/materials/{materialId}/preview`

- **Allowed Roles:** `MANAGER`, `CREATOR`, `CLIENT` (within object ACL), `SystemRole.ADMIN`.
- **Purpose:** Used **only** when a user keeps the detail view or video/PDF preview open past `previewExpiresAt` (5 minutes). Strictly forbidden from being called in a loop for grid thumbnails.
- **Preconditions:** Material exists in `workspaceId`, caller has read permission, `deletedAt == null`, `status == READY`, and `mediaKind`/`mimeType` supports inline preview.
- **Success Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "materialId": "671a0f8b2c4e1a3b5d7f9012",
    "previewUrl": "https://storage.example/repository/...?X-Amz-Expires=300&...",
    "previewExpiresAt": "2026-10-24T10:40:00Z",
    "mimeType": "video/mp4"
  },
  "error": null,
  "meta": null,
  "requestId": "9f8d7c6b-5a4e-3d2c-1b0a-0987654321fe",
  "version": "v1",
  "timestamp": "2026-10-24T10:35:00Z"
}
```

### 8.4 Storage usage read contracts

GET /api/v1/agencies/{agencyId}/storage-usage checks Agency owner_id (or existing system
ADMIN support policy), not workspace membership. Return decimal-string usedBytes,
reservedBytes,quotaBytes, per-workspace usage breakdown and observedAt/reconciliationPending.
No file names, IDs, keys, URLs or Client-specific lists. OWNER-only still cannot enter Library.
Workspace endpoint GET /api/v1/workspaces/{workspaceId}/materials/storage-usage is ops-only
MANAGER/CREATOR and returns workspace usage only; do not expose Agency aggregate to CLIENT
or implicitly to non-owner operators. Plan.md V4 is the canonical DTO definition.
Quota is catalog total; BASIC/expired21474836480; trash included, restore no increase.

---

## 9. Error Handling Contract

All errors use `BusinessException` mapped by `GlobalExceptionHandler` into `ApiResponse` with centralized `ErrorCode` values:

| Scenario | HTTP Status | ErrorCode | User-Facing / Client Behavior |
|---|---|---|---|
| Missing or expired JWT | `401 Unauthorized` | `UNAUTHORIZED` / `TOKEN_EXPIRED` | Axios interceptor refreshes token once via `/api/v1/auth/refresh`; redirects to `/login` on failure. |
| User is not an active member of `workspaceId`, or is an `OWNER` without `MANAGER`/`CREATOR` membership (`BR02`) | `403 Forbidden` | `WORKSPACE_ACCESS_DENIED` / `FORBIDDEN` | UI renders Forbidden state (`repository.access.forbidden`) and prevents rendering workspace data. |
| `CLIENT` filters by a profile outside caller scope | `200 OK` | — | Empty scoped data/total; do not reveal profile existence. Calling Agency/workspace ops-only usage is403. |
| Invalid `page` ($<0$), `size` ($<1$ or $>100$), `search` ($>100$ chars), or invalid enum filter (`mediaKind`, `type`, `purpose`, `sort`) | `400 Bad Request` | `VALIDATION_ERROR` / `INVALID_REQUEST` | Inline/toast validation error; no database query executed. |
| `materialId` does not exist, belongs to another `workspaceId`, or is invisible to the calling `CLIENT` (`INTERNAL` or another Client's profile) | `404 Not Found` | `MATERIAL_NOT_FOUND` | Detail panel closes or shows `"Không tìm thấy tài liệu"` without leaking whether the ID exists elsewhere. |
| Calling `POST /{id}/preview` on a material with `status` in `UPLOADING` or `VALIDATING` | `409 Conflict` | `MATERIAL_NOT_READY` | Detail panel shows processing state (`repository.upload.validating`). |
| Calling `POST /{id}/preview` on a material with `status` in `REJECTED`, `FAILED`, or unsupported preview format | `409 Conflict` | `MATERIAL_UNAVAILABLE` / `MATERIAL_PREVIEW_UNSUPPORTED` | Detail panel renders `previewUnsupported` / `uploadRejected` fallback card. |
| Storage provider (`SYSTEM_GDRIVE` / `SYSTEM_S3`) signer or metadata store temporarily unavailable | `503 Service Unavailable` | `MATERIAL_STORAGE_UNAVAILABLE` | UI renders retryable error banner + toast ($\ge 5\text{s}$), preserving current filter state. |
| Gateway rate limit exceeded | `429 Too Many Requests` | `RATE_LIMIT_EXCEEDED` | UI stops automatic retries and informs user to wait before retrying. |

---

## 10. UI/UX, UI States, i18n, Theme & Accessibility

### 10.1 Layout & Component Architecture (`brandhub-web`)

Reuse the existing `ContentLibraryPage` (`src/pages/library/index.tsx`), `MediaTab` (`src/pages/library/components/MediaTab.tsx`), and `MediaDetailPanel` (`src/pages/library/components/MediaDetailPanel.tsx`), refactoring according to `STRUCTURE.md` (Orchestrator $< 150$ lines, sub-components under `src/pages/library/components/`, custom hook `useMaterialRepository.ts` under `src/pages/library/hooks/`):

1. **Toolbar & Filters (`MediaToolbar`):**
   - **Search Input:** `<Input>` with `Search` icon (`lucide-react`), debounced ($300\text{ ms}$), max $100$ chars, clear button when non-empty.
   - **Media Kind Filter (`mediaKind`):** Segmented pill control using `<Button>` / semantic classes: `Tất cả` (`ALL`), `Ảnh` (`IMAGE`, `ImageIcon`), `Video` (`VIDEO`, `Film`), `Tài liệu` (`FILE`, `FileText`).
   - **Processing Type Filter (`type`):** Filter pills/select: `Tất cả trạng thái`, `RAW` (with `AlertTriangle` indicator), `RETOUCHED` (`Sparkles`/`CheckCircle2`), `WATERMARKED` (`Stamp`).
   - **Purpose Filter (`purpose`):** Toggle/pills: `Tất cả mục đích`, `Tư liệu sản xuất` (`MATERIAL`), `Tài liệu tham khảo của Client` (`BRAND_REFERENCE`, `Bookmark`/`Briefcase`).
   - **Client Profile Filter (`clientProfileId`):** Rendered **only** for `MANAGER` and `CREATOR` when the workspace has active Client Profiles (`Tất cả Client` + list of workspace clients). Hidden for `CLIENT` (since `CLIENT` is automatically scoped to their own profile).
   - **Sort & View Mode:** Sort select (`Mới nhất` / `Cũ nhất`) and Active vs. Trash toggle (`Kho hoạt động` / `Thùng rác`).
   - **Quota Summary Chip (for `MANAGER` / `CREATOR`):** Compact storage usage indicator (`usedBytes / quotaBytes`) with a subtle warning badge if `isQuotaExceeded = true`, clearly stating that viewing and downloading remain available (`BR20`, `BR21`).
2. **Material Card (`MaterialGridCard`):**
   - Aspect-square card (`rounded-xl border border-border bg-card shadow-xs hover:border-brand-orange/50`).
   - **Thumbnail / Preview Area:**
     - `IMAGE` (`READY`): `<img src={item.previewUrl} loading="lazy" alt={item.name} />` with fallback icon if load fails.
     - `VIDEO` (`READY`): `<video src={item.previewUrl} preload="metadata" muted playsInline />` or poster frame with centered `Play` icon badge.
     - `FILE` (`PDF` / document): Clean document preview surface with `FileText` icon, MIME badge (`PDF`), and file size.
     - Non-`READY` states (`UPLOADING`, `VALIDATING`, `REJECTED`, `FAILED`): Distinct status placeholder with `Loader2` (spinning for `UPLOADING`/`VALIDATING`) or `AlertCircle` (`REJECTED`/`FAILED`).
   - **Badges:**
     - **Top-Left:** Processing `type` badge (`RAW`, `RETOUCHED`, `WATERMARKED`). If `item.rawWarning === true` (`mediaKind === 'IMAGE' && type === 'RAW'`), render a high-contrast warning badge with `AlertTriangle` icon: `"RAW • Ảnh chưa chỉnh sửa"`.
     - **Top-Right:** Media kind badge (`IMAGE`, `VIDEO`, `PDF`) + Purpose badge (`Tài liệu tham khảo` when `purpose === 'BRAND_REFERENCE'`).
     - **Bottom Metadata Bar:** Truncated `name`, `formatFileSize(fileSize)`, audience badge (`INTERNAL` or `CLIENT: {clientDisplayName}`), and soft-delete countdown badge when viewing Trash (`purgeAfter`).
3. **Material Detail View (`MediaDetailPanel`):**
   - Accessible slide-over panel (`role="dialog"`, `aria-modal="true"`, `aria-labelledby`, closes on `Escape` and returns focus to the triggering card).
   - **Interactive Preview Stage:**
     - `IMAGE`: Zoomable/contain `<img>` rendered from `previewUrl`.
     - `VIDEO`: Native `<video controls preload="metadata" src={previewUrl}>` supporting HTTP Range seek. If browser fires media error on unsupported `.mov` codec, transition cleanly to the `previewUnsupported` fallback box.
     - `FILE` (`application/pdf`): Sandboxed `<iframe src={previewUrl} sandbox="allow-same-origin allow-scripts" title={item.name} />` or embedded PDF viewer with fallback link to trigger Download (`FR 3.6.16`).
     - Automatic TTL Refresh: If the panel stays open and `Date.now() >= Date.parse(previewExpiresAt) - 15000` (or on media load 403 due to expiry), call `POST /materials/{id}/preview` once to refresh `previewUrl` seamlessly.
   - **RAW Image Warning Banner (`BR08`):**
     - When `item.rawWarning === true`, display a prominent warning callout (`border-amber-500/40 bg-amber-500/10 text-amber-700 dark:text-amber-300`) with `AlertTriangle`: *"Ảnh chưa chỉnh sửa (RAW) — Chỉ dùng để chỉnh sửa hoặc tham khảo. Khuyến nghị tải lên bản RETOUCHED trước khi đưa vào bài đăng."*
   - **Metadata Section:**
     - Display `name`, `originalName`, `type` (`RAW`/`RETOUCHED`/`WATERMARKED`), `purpose` (`MATERIAL`/`BRAND_REFERENCE`), `visibility` (`INTERNAL`/`CLIENT` + `clientDisplayName`), `mimeType`, `fileSize`, `createdByName`, `createdAt`, `updatedAt`, `taskId` (if linked), `parentMaterialId` (lineage badge if derived), and `deletedAt`/`purgeAfter` (if in Trash).
     - **Security Rule (`BR14`):** Remove the legacy `"S3 Direct URL"` input and copy-URL button so short-lived signed URLs are not copied or shared as permanent links.
   - **Capability-Gated Action Footer (Dependency Integration Points):**
     - Render action buttons strictly based on `item.capabilities` (`canDownload`, `canRename`, `canUpdateType`, `canChangeAudience`, `canWatermark`, `canDelete`, `canRestore`). Execution of those mutations belongs to `FR 3.6.13`, `FR 3.6.14`, `FR 3.6.15`, and `FR 3.6.16`.
4. **Pagination Control:**
   - Reuse shared `<Pagination>` (`src/components/common/Pagination.tsx`) driven by `meta.page`, `meta.size`, and `meta.total`, displaying total item count and page navigation (`Trước` / `Sau` + page numbers).

### 10.2 Exhaustive UI States

| UI State | Trigger Condition | Visual Representation |
|---|---|---|
| **1. Initial Loading** | First fetch for workspace / filter change | 8 `<Skeleton>` cards (`aspect-square rounded-xl`) in the responsive grid; toolbar inputs remain interactive. |
| **2. Empty Workspace Repository** | `meta.total === 0` with default filters (`deleted = false`, no search/filter active) | Centered empty state card with `FolderOpen` icon, `t("repository.empty")`, description, and Upload CTA (if actor has upload permission). |
| **3. Empty Search / Filter Result** | `meta.total === 0` with active search keyword or filter (`mediaKind`, `type`, `purpose`, `clientProfileId`) | Centered state with `Search` icon, `t("repository.emptySearch")`, and a `"Xóa bộ lọc"` (`Reset filters`) `<Button variant="outline">`. |
| **4. Empty Trash** | `meta.total === 0` when `deleted = true` | Centered state with `Trash2` icon and `t("repository.emptyTrash")`. |
| **5. Ready Item (Standard)** | `status === 'READY'` and previewable | Thumbnail/preview rendered via `previewUrl`, processing badge, purpose badge, and metadata. |
| **6. Ready Item with `RAW` Warning** | `status === 'READY' && mediaKind === 'IMAGE' && type === 'RAW'` | Amber `RAW` warning badge on card + warning alert banner inside `MediaDetailPanel` (and confirmation warning if selected for content). |
| **7. Uploading / Validating Item** | `status === 'UPLOADING'` or `'VALIDATING'` | Muted surface card with `<Spinner>` / `Loader2`, status label (`t("repository.uploading")` / `t("repository.validating")`), preview disabled (`409` if clicked). |
| **8. Rejected / Failed Item** | `status === 'REJECTED'` or `'FAILED'` | Destructive-tinted border/badge (`AlertCircle`), `t("repository.uploadRejected")` / `t("repository.uploadFailed")`, no preview URL issued. |
| **9. Unsupported Preview Fallback** | `status === 'READY'` but browser cannot render codec (e.g., unsupported QuickTime `.mov`) or legacy Office file | Clean fallback panel in `MediaDetailPanel` with `FileWarning` / `Film` icon, `t("repository.previewUnsupported")`, full file metadata, and Download button. |
| **10. Soft-Deleted (Trash) Item** | `deleted === true` (`deletedAt != null`) | Muted card with `"Đã xóa"` badge and scheduled purge date (`purgeAfter`), preview/download disabled, showing `Restore` action if `capabilities.canRestore === true`. |
| **11. Quota Exceeded / Expired Plan Read-Only Banner** | `storageUsage.isQuotaExceeded === true` | Non-blocking info/warning banner in toolbar stating quota is full (new uploads/watermarks paused), while confirming all existing files remain viewable and downloadable (`BR20`, `BR21`). |
| **12. Load Error / Storage Unavailable** | API returns `5xx` / `503` / network failure | Error banner with `AlertTriangle`, `t("repository.loadError")`, and `<Button variant="orange">` (`t("repository.retry")`), plus `toast.error` ($\ge 5\text{s}$). |
| **13. Forbidden (`403`)** | Actor lacks workspace access or is `OWNER` without operational role | Full-width permission state (`ShieldAlert` icon, `t("repository.forbidden")`) with navigation back to Workspace overview. |

### 10.3 Internationalization (i18n — Parallel `vi` & `en` Keys)

All user-facing text must use `react-i18next` (`t()`). Reuse existing `library.media.*` and `materials.watermark.*` keys where identical, and add the following keys simultaneously in `src/i18n/locales/vi/library.json` and `src/i18n/locales/en/library.json` under `library.repository` (or top-level `repository` namespace registered in `src/i18n/index.ts`):

| Key (`repository.*`) | Vietnamese (`vi`) | English (`en`) |
|---|---|---|
| `repository.title` | `Kho Tư Liệu (Material Repository)` | `Material Repository` |
| `repository.empty` | `Kho tư liệu chưa có tệp nào` | `No materials in this repository yet` |
| `repository.emptyDescription` | `Tải lên ảnh, video hoặc tài liệu tham khảo để bắt đầu cộng tác trong workspace.` | `Upload images, videos, or reference documents to start collaborating in this workspace.` |
| `repository.emptySearch` | `Không tìm thấy tư liệu phù hợp với bộ lọc` | `No materials match your current filters` |
| `repository.emptyTrash` | `Thùng rác đang trống` | `Trash is empty` |
| `repository.resetFilters` | `Xóa bộ lọc` | `Reset filters` |
| `repository.loadError` | `Không thể tải danh sách tư liệu. Vui lòng thử lại.` | `Failed to load materials. Please try again.` |
| `repository.retry` | `Thử lại` | `Retry` |
| `repository.searchPlaceholder` | `Tìm kiếm tư liệu theo tên tệp...` | `Search materials by filename...` |
| `repository.filterAll` | `Tất cả` | `All` |
| `repository.filterImage` | `Ảnh` | `Images` |
| `repository.filterVideo` | `Video` | `Videos` |
| `repository.filterFile` | `Tài liệu (PDF)` | `Documents (PDF)` |
| `repository.processingTypeLabel` | `Phân loại xử lý` | `Processing Status` |
| `repository.typeAll` | `Mọi trạng thái xử lý` | `All processing types` |
| `repository.typeRaw` | `Ảnh gốc (RAW)` | `Raw (Unedited)` |
| `repository.typeRetouched` | `Đã chỉnh sửa (Retouched)` | `Retouched` |
| `repository.typeWatermarked` | `Đã đóng dấu (Watermarked)` | `Watermarked` |
| `repository.rawWarningBadge` | `Ảnh chưa chỉnh sửa` | `Unedited RAW image` |
| `repository.rawWarning` | `Ảnh chưa chỉnh sửa (RAW) — Cần kiểm tra hoặc chỉnh sửa trước khi sử dụng làm nội dung đăng tải.` | `Unedited RAW image — Please review or retouch before using in published content.` |
| `repository.purposeLabel` | `Mục đích sử dụng` | `Purpose` |
| `repository.purposeAll` | `Mọi mục đích` | `All purposes` |
| `repository.purposeMaterial` | `Tư liệu sản xuất` | `Production Material` |
| `repository.purposeBrandReference` | `Tài liệu tham khảo của Client` | `Client Brand Reference` |
| `repository.audienceLabel` | `Phạm vi chia sẻ` | `Audience Scope` |
| `repository.audienceInternal` | `Nội bộ Workspace` | `Workspace Internal` |
| `repository.audienceClient` | `Chia sẻ cho Client` | `Shared with Client` |
| `repository.clientLabel` | `Khách hàng (Client)` | `Client Profile` |
| `repository.clientAll` | `Tất cả Client` | `All Clients` |
| `repository.viewActive` | `Kho hoạt động` | `Active Repository` |
| `repository.viewTrash` | `Thùng rác (30 ngày)` | `Trash (30 days)` |
| `repository.uploading` | `Đang tải lên...` | `Uploading...` |
| `repository.validating` | `Đang kiểm tra tệp...` | `Validating file...` |
| `repository.uploadRejected` | `Tệp bị từ chối kiểm duyệt` | `File rejected by validation` |
| `repository.uploadFailed` | `Tải lên thất bại` | `Upload failed` |
| `repository.preview` | `Xem trước` | `Preview` |
| `repository.previewUnsupported` | `Trình duyệt không hỗ trợ xem trước trực tiếp định dạng này. Bạn vẫn có thể tải tệp gốc về máy.` | `Inline preview is not supported for this file format in the browser. You can still download the original file.` |
| `repository.previewFailed` | `Không thể tải bản xem trước` | `Failed to load preview` |
| `repository.previewRefreshing` | `Đang làm mới liên kết xem trước...` | `Refreshing preview link...` |
| `repository.lineageLabel` | `Được tạo từ tư liệu gốc` | `Derived from parent material` |
| `repository.createdByLabel` | `Người tải lên` | `Uploaded by` |
| `repository.purgeAfterLabel` | `Xóa vĩnh viễn sau` | `Purge scheduled after` |
| `repository.quotaReadOnlyNotice` | `Dung lượng lưu trữ đã chạm hạn mức. Tạo tệp mới tạm khóa nhưng bạn vẫn xem và tải xuống toàn bộ tư liệu bình thường.` | `Storage quota reached. Creating new files is paused, but viewing and downloading existing materials remain fully available.` |
| `repository.forbidden` | `Bạn không có quyền truy cập kho tư liệu của workspace này.` | `You do not have permission to access this workspace's material repository.` |
| `repository.unavailable` | `Tư liệu hiện không khả dụng hoặc đã bị xóa.` | `This material is currently unavailable or has been removed.` |
| `repository.switchWorkspaceCancelled` | `Đã chuyển workspace, hủy thao tác trên workspace cũ.` | `Workspace switched; previous workspace request was cancelled.` |

### 10.4 Light/Dark Theme, Responsive & Accessibility Requirements

1. **Theme Compliance (`rule.md` §1):**
   - Use semantic CSS variables/Tailwind classes (`bg-background`, `bg-card`, `bg-muted`, `text-foreground`, `text-muted-foreground`, `border-border`, `bg-brand-orange`, `text-brand-orange`, `bg-brand-orange-soft`).
   - Do **not** hardcode raw hex values (`#fafafa`, `#09090b`, `#f05a28`) or unpaired `bg-white` / `bg-zinc-900` on cards, filter bars, or the detail panel.
   - Verify badge contrast in both `:root` (Light) and `.dark` (Dark) modes so `RAW` warning badges, `BRAND_REFERENCE` badges, and `INTERNAL`/`CLIENT` badges meet WCAG 2.1 AA ($\ge 4.5:1$ text contrast).
2. **Responsive Breakpoints (`rule.md` §3):**
   - **Mobile (`375px`):** 2-column grid (`grid-cols-2 gap-3`), stacked toolbar controls, full-width slide-over detail drawer (`w-full`).
   - **Tablet (`768px`, `md:`):** 3-column grid (`sm:grid-cols-3 gap-4`), 2-row compact filter bar, `max-w-md` detail drawer.
   - **Desktop (`1440px`, `lg:`/`xl:`):** 4-column grid (`lg:grid-cols-4 gap-4`), inline horizontal toolbar, `max-w-lg` detail drawer.
3. **Accessibility (`rule.md` §10):**
   - All icons use `lucide-react` with `size-*` classes; zero emoji characters in UI chrome.
   - Every material card is keyboard-focusable (`tabIndex={0}` or semantic `<button>`), activates detail view on `Enter`/`Space`, and displays a visible focus ring (`focus-visible:ring-2 focus-visible:ring-brand-orange`).
   - Icon-only buttons (close detail panel, clear search, refresh preview) include translated `aria-label`.
   - Closing `MediaDetailPanel` via `Escape` or Close button restores focus to the card that opened it.

---

## 11. Testing Decisions & Test Scenarios

### 11.1 What Makes a Good Test & Testing Seams

Following `to-spec` and `brandhub-business-service/rule.md` + `brandhub-web/rule.md`:
- **Test external behavior at the highest practical seam**, not internal private helper methods.
- **Primary Backend Seam:** Controller/Service integration and unit tests on `MaterialController` + `MaterialService` verifying HTTP status codes, `ApiResponse<List<MaterialResponse>>` + `MetaBody(page, size, total)`, MongoDB scoped criteria construction, PostgreSQL membership/profile resolution, `StorageClientRouter` inline presigning calls, and `capabilities` calculation.
- **Primary Frontend Seam:** Playwright E2E tests (`tests/e2e/library/view-material-repository.spec.ts` using Page Object Model outside `src/`) + Vitest component/hook tests verifying real API wiring (mocking HTTP routes via `page.route()`), role-based filter visibility, `RAW` warning rendering, `BRAND_REFERENCE` filtering, workspace switch cancellation, i18n (`vi`/`en` parity), and Light/Dark mode rendering.
- **Prior Art in Codebase:**
  - `brandhub-business-service/src/test/java/com/brandhub/business/service/MaterialServiceImplTest.java`
  - `brandhub-business-service/src/test/java/com/brandhub/business/security/aspect/RequireRoleAspectTest.java`
  - `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceAccessServiceTest.java`
  - `brandhub-business-service/src/test/java/com/brandhub/business/controller/HashtagApiTest.java`

### 11.2 Acceptance Criteria & Test Scenarios Matrix

| ID | Scenario | Input / Actor | Expected Outcome |
|---|---|---|---|
| **AC-V01** | `MANAGER` & `CREATOR` list workspace materials | Active `MANAGER` or `CREATOR` calls `GET /workspaces/{wsId}/materials?page=0&size=20` | Returns `200 OK`, `data` as JSON array of active materials (`INTERNAL` + `CLIENT`) in `wsId`, `meta = { page: 0, size: 20, total: N }`, `Cache-Control: no-store`. |
| **AC-V02** | `CLIENT` isolation by `client_profile_id` (`BR05`, `BR06`) | Workspace has Client A (`profileA`), Client B (`profileB`), and `INTERNAL` files. Client A calls `GET /materials` and `GET /materials/{id}`. | Client A receives **only** items where `visibility = CLIENT` and `clientProfileId = profileA`. `meta.total` counts only Client A's visible items. Requesting an `INTERNAL` item or Client B's item by ID returns `404 MATERIAL_NOT_FOUND` and never invokes presigner. |
| **AC-V03** | `OWNER` without operational role is blocked (`BR02`) | Agency `OWNER` (not a `MANAGER` or `CREATOR` in `wsId`) calls `GET /workspaces/{wsId}/materials` or navigates to `/library`. | Backend returns `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`; Web route guard blocks `/library`. |
| **AC-V04** | Multi-workspace user access (`RequireRoleAspect`) | User is `CREATOR` in Workspace 1 (JWT initial claim) and `MANAGER` in Workspace 2. Calls `GET /workspaces/{ws2Id}/materials`. | Succeeds (`200 OK`) with Workspace 2's materials and `MANAGER` capabilities (`canChangeAudience = true`). |
| **AC-V05** | `RAW` image warning (`BR08`) | Material has `mediaKind = IMAGE` and `type = RAW`. | Response has `rawWarning = true`. Grid card displays `"Ảnh chưa chỉnh sửa"` badge; Detail panel renders amber warning banner; `canDownload` and `canPreview` remain `true`. |
| **AC-V06** | `RETOUCHED` & `WATERMARKED` badges (`BR08`) | Materials with `type = RETOUCHED` or `WATERMARKED`, or `mediaKind = VIDEO` with `type = RAW`. | Correct `type` badge is displayed; `rawWarning` is `false` for `RETOUCHED`, `WATERMARKED`, and non-image files; `WATERMARKED` detail shows `parentMaterialId` and `watermarkMeta`. |
| **AC-V07** | `BRAND_REFERENCE` purpose filter & label (`BR09`) | User filters by `purpose = BRAND_REFERENCE`. | Returns only materials with `purpose = BRAND_REFERENCE` within the caller's ACL. Card and detail view show `"Tài liệu tham khảo của Client"`. `GET /materials/brand-assets` continues returning workspace/client logos unchanged. |
| **AC-V08** | Search, filter & stable pagination | Filter by `mediaKind = VIDEO`, `type = RAW`, `search = "summer"`, `sort = oldest`, `page = 1`, `size = 10`. | Query executes in MongoDB (no unbounded `findAll` in RAM), matches normalized prefix, sorts deterministically by `created_at ASC, _id ASC`, and returns accurate `MetaBody`. |
| **AC-V09** | Inline `previewUrl` without $N+1$ (`BR13`, `BR14`) | Grid loads 20 `READY` materials (`IMAGE`, `VIDEO`, `PDF`) across `SYSTEM_GDRIVE` and `SYSTEM_S3`. | Exactly **1** HTTP request (`GET /materials`) is made by the browser. All 20 items include a valid inline `previewUrl` (`TTL <= 300s`) signed for their respective `storageProvider`; zero per-item `HEAD` or `/preview` requests occur on grid load. |
| **AC-V10** | Non-`READY` and Trash items do not leak `previewUrl` (`BR13`, `BR15`) | Materials in `UPLOADING`, `VALIDATING`, `REJECTED`, `FAILED`, or soft-deleted (`deleted = true`). | `previewUrl` and `previewExpiresAt` are `null`. UI renders corresponding status placeholder or Trash card with `purgeAfter`. |
| **AC-V11** | Preview URL refresh on expiry | Detail panel open $> 5\text{ minutes}$; triggers `POST /materials/{id}/preview`. | Re-verifies workspace/object ACL and `status == READY`; returns new `previewUrl` (`TTL = 300s`). If permission was revoked or material was soft-deleted while panel was open, returns `403`/`404` and clears preview. |
| **AC-V12** | Quota exceeded / subscription expired read continuity (`BR20`, `BR21`) | Agency `usedBytes > 20 GiB` after subscription expires. User browses `MediaTab` and opens detail preview for files on `SYSTEM_S3` and `SYSTEM_GDRIVE`. | All list, detail, and preview refresh calls succeed (`200 OK`). Toolbar displays non-blocking `quotaReadOnlyNotice`. |
| **AC-V13** | Workspace switch race cancellation | User switches from Workspace A to Workspace B while Workspace A's `GET /materials` or `GET /materials/{id}` is still pending. | `AbortController` / TanStack Query key (`['materials', workspaceId, ...]`) cancels/ignores Workspace A's response and closes any open detail panel from Workspace A. |
| **AC-V14** | i18n (`vi`/`en`), Light/Dark, Responsive & A11y | Switch language `vi ↔ en`, toggle Light/Dark theme, resize `375px` / `768px` / `1440px`, navigate by keyboard (`Tab`, `Enter`, `Escape`). | Key parity check passes between `vi` and `en`; zero hardcoded strings or emojis; semantic theme tokens render with WCAG AA contrast; `Escape` closes detail panel and restores focus. |

---

## 12. Out of Scope

The following items belong to separate FR specifications or future phases and are **not** specified for implementation inside FR 3.6.11:
1. **Add / Upload Material & Client Brand Reference (`FR 3.6.12`)**: Multipart upload, `POST /upload-session`, `POST /upload-session/confirm`, magic-bytes/container validation, staging-to-canonical `CopyObject`, and PostgreSQL quota reservation ledger writes.
2. **Update Material Metadata & Audience (`FR 3.6.13`)**: `PATCH /api/v1/workspaces/{workspaceId}/materials/{materialId}` implementation for renaming, toggling `RAW ↔ RETOUCHED`, and Manager changing `visibility` / `client_profile_id`. (FR 3.6.11 only computes and displays the read-side metadata and `capabilities` flags).
3. **Remove / Soft Delete, Restore & Retention Purge (`FR 3.6.14`)**: `DELETE /{id}`, `POST /{id}/restore`, and the 30-day scheduled purge worker checking Post/Task/Derivative references. (FR 3.6.11 only supports viewing the `deleted = true` Trash list and `capabilities.canDelete`/`canRestore`).
4. **Apply Watermark (`FR 3.6.15`)**: Watermark Studio compositing logic (`POST /{id}/watermark`), already implemented and only invoked when `capabilities.canWatermark === true`.
5. **Download Material (`FR 3.6.16`)**: `POST /{id}/download` attachment link issuance (`TTL 120s`), `HEAD` verification on download, and `DOWNLOAD_LINK_ISSUED` audit logging.
6. **Should Have / Future Items (`R10`–`R16`)**: Folder hierarchy (`material_folders`), server-generated video posters/thumbnails worker, fuzzy/substring full-text search cluster, multi-select bulk ZIP download, and `USER_GDRIVE` OAuth2 adapter (`R14`).

---

## 13. Definition of Done (DoD)

1. `spec.md` (this document) is reviewed and followed sequentially by `plan.md → task.md → test.md` under `brandhub-infrastructure/docs/feature/repository/view-material-repository/` before writing production code.
2. MongoDB migration script and index definitions for `materials` (`media_kind`, `purpose`, `visibility`, `client_profile_id`, `storage_provider`, `status`, `normalized_name`, `deleted_at`, `purge_after`, `version`) pass offline/dry-run verification without data loss.
3. `GET /api/v1/workspaces/{workspaceId}/materials`, `GET /{materialId}`, `POST /{materialId}/preview`, and `GET /storage-usage` compile, enforce PostgreSQL role + Client Profile ACL (`BR01`–`BR07`), return `ApiResponse<List<MaterialResponse>>` with `MetaBody(page, size, total)`, and sign inline `previewUrl` (`TTL 300s`, `Cache-Control: no-store`) via `StorageClientRouter`.
4. `MediaTab.tsx` and `MediaDetailPanel.tsx` in `brandhub-web` are fully disconnected from `mockContentLibraryService` for media items and wired to `materialService` via TanStack Query with workspace-scoped query keys.
5. `RAW` warning badge/banner (`BR08`) and `BRAND_REFERENCE` badge/filter (`BR09`) work end-to-end.
6. Parallel `vi`/`en` translation keys exist with zero missing keys; UI passes Light/Dark mode, responsive (`375px`, `768px`, `1440px`), and keyboard accessibility checks.
7. Unit, integration, and E2E tests covering `AC-V01` through `AC-V14` pass (`mvn test` and `npx tsc -b` / Playwright).

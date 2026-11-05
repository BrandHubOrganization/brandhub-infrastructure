# Repository S3 5GB, Nested Folders, Drive Folder Import, Duplicate/File Versioning, Client Personal Vault & Zero-Dev-Access Security Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the Material Repository around a default 5 GB Free S3 storage model (with monthly S3 add-ons), nested folders with tiered `--- folder` / `--- file` display and time/name sorting, one-time Google Drive folder import to S3, SHA-256 content & filename duplicate detection with 3 choices (`SKIP`, `KEEP_BOTH`, `OVERWRITE` with `v1, v2...` File Versioning), an independent Client Personal Vault (`CLIENT_VAULT`) for zero-copy cross-workspace reuse, and strict security blocking outsiders and Dev/System Admins from viewing user images in code and on AWS S3.

**Architecture:** We remove `USER_GDRIVE` direct storage and background sync in favor of `SYSTEM_S3` (`BASIC_BYTES = 5_368_709_120L` + monthly `storage_addon_subscriptions`) and a one-time `DriveFolderImportService`. In MongoDB, we introduce `MaterialFolderDocument` (`material_folders`), `MaterialVersionDocument` (`material_versions`), and `ClientVaultShareDocument` (`client_vault_shares`), while extending `MaterialDocument` with `folderId`, `ancestorFolderIds`, `sortKey`, `contentHash`, `currentVersionNumber`, `scopeType`, and `ownerUserId`. Access control in `MaterialAccessPolicy` strips all `SystemRole.ADMIN`/`adminSupport` privileges, and `StorageClientRouter` + `brandhub-infrastructure` enforce `SSE-KMS` and explicit S3/KMS `Deny` policies for human Dev/Admin roles.

**Tech Stack:** Java 21 / Spring Boot 3.3 (`brandhub-business-service`), MongoDB (`MongoTemplate`), PostgreSQL 17 (`JdbcTemplate`), AWS SDK v2 S3 & KMS, React 19 / TypeScript / Vite / TanStack Query (`brandhub-web`), JUnit 5 + Mockito + Vitest.

**Spec:** `D:\capstone\brandhub\docs\superpowers\specs\2026-11-04-repository-s3-folder-vault-security-design.md`

## Global Constraints

- `StorageQuotaService.BASIC_BYTES` must be exactly `5_368_709_120L` (5 GiB free S3 storage per Agency and per Client account).
- All new uploads and Google Drive folder imports store exclusively on `SYSTEM_S3` (`provider = "SYSTEM_S3"`). Background polling in `CustomerDriveSyncService` must be disabled.
- `SystemRole.ADMIN` and `adminSupport` must NEVER grant read, list, detail, preview, download, or restore access to workspace or client vault materials in `MaterialAccessPolicy`.
- Repository browsing (`GET /api/v1/workspaces/{workspaceId}/materials/browser` and UI) must separate items into two distinct top-to-bottom sections: `folders` (`--- folder`) on top and `files` (`--- file`) below, both sorted by `sort` (`newest` default, `oldest`, `name_asc`, `name_desc`).
- Duplicate detection checks both `normalizedName` (in target `folderId`) and `contentHash` (`SHA-256` across the workspace/vault); when `conflictResolution == "ASK"`, upload session creation returns `409 MATERIAL_DUPLICATE_CONFLICT` so the user can choose `SKIP`, `KEEP_BOTH` (auto-renamed `name (1).ext` with an independent S3 object), or `OVERWRITE` (pushes current version to `material_versions` and increments `currentVersionNumber`).
- `CLIENT` user uploads are stored in the Client's Personal Vault (`scopeType = "CLIENT_VAULT"`, `ownerUserId = actor.id`) and shared into a Workspace's *"Kho của Client"* tab strictly when an explicit `ClientVaultShareDocument` record exists for that `workspaceId`.

## Review Focus

1. **System Admin (`SystemRole.ADMIN`) attempting to view/preview/download workspace files**: Must be rejected with `403 WORKSPACE_ACCESS_DENIED` unless that user is an active operational member of the workspace; `X-Support-Ticket` headers must not bypass membership.
2. **Moving a folder into itself or one of its descendants**: `MaterialFolderService.moveFolder(workspaceId, folderId, targetParentFolderId)` must reject cycles (`targetParentFolderId.equals(folderId)` or target's `ancestorIds` contains `folderId`) with `400 VALIDATION_ERROR` and enforce max depth `<= 16`.
3. **Vietnamese alphabetical sort (`name_asc` / `name_desc`)**: `MaterialSortKey.of("Đồ án Áo dài")` and `"An Bình"` must produce deterministic collation keys where `A < Á < Đ` rather than sorting `Đ` after `Z` by raw Unicode code point.
4. **Deleting a single old file version vs purging the entire material**: Deleting version `v1` in `MaterialVersionService.deleteVersion` must delete only `v1`'s S3 object and release `v1.fileSize` bytes from S3 quota without affecting the current active version `v2` on `MaterialDocument`.
5. **Cross-workspace isolation of Client Personal Vault**: If a Client has 10 files in `CLIENT_VAULT`, shares 2 with Workspace A, and joins Workspace B, querying Workspace B's `CLIENT_VAULT` tab must return `0` files until the Client explicitly shares specific files/folders with Workspace B.

---

### Task 1: Zero-Dev-Access Security in `MaterialAccessPolicy`, `StorageClientRouter` (`SSE-KMS`) & AWS S3/KMS Terraform (`4. repository-s3-prod`)

**Files:**
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialAccessPolicy.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialReadService.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialTrashService.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/controller/MaterialController.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/config/RepositoryStorageProperties.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/StorageClientRouter.java`
- Create: `brandhub-infrastructure/prod/terraform/4. repository-s3-prod/providers.tf`
- Create: `brandhub-infrastructure/prod/terraform/4. repository-s3-prod/variables.tf`
- Create: `brandhub-infrastructure/prod/terraform/4. repository-s3-prod/kms.tf`
- Create: `brandhub-infrastructure/prod/terraform/4. repository-s3-prod/s3.tf`
- Create: `brandhub-infrastructure/prod/terraform/4. repository-s3-prod/iam-service-policy.tf`
- Create: `brandhub-infrastructure/prod/terraform/4. repository-s3-prod/outputs.tf`
- Create: `brandhub-infrastructure/prod/terraform/4. repository-s3-prod/terraform.tfvars`
- Modify: `brandhub-business-service/src/test/java/com/brandhub/business/service/MaterialAccessPolicyTest.java`

**Interfaces:**
- Produces:
  - `MaterialAccessPolicy.Scope(UUID workspaceId, UUID agencyId, UUID actorId, MemberRole role, Set<String> profiles)` (with `adminSupport` permanently `false` / removed from authorization grant)
  - `RepositoryStorageProperties.Provider.getKmsKeyId()` (`String`)
  - Terraform stack in `brandhub-infrastructure/prod/terraform/4. repository-s3-prod/` provisioning `aws_kms_key.repository_media`, `aws_s3_bucket.repository`, `aws_s3_bucket_public_access_block.repository`, `aws_s3_bucket_server_side_encryption_configuration.repository` (`aws:kms`), and `aws_s3_bucket_policy.repository` with explicit `Deny` on `s3:GetObject` and `kms:Decrypt` for all human Dev/Admin principals except `brandhub-ec2-ecr-pull`

- [x] **Step 1: Write failing test in `MaterialAccessPolicyTest.java` verifying `SystemRole.ADMIN` is denied access to workspace materials**

```java
@Test
void systemAdminAndDevWithoutWorkspaceMembershipAreStrictlyDenied() {
    UUID workspace = UUID.randomUUID();
    UUID adminId = UUID.randomUUID();
    var workspaces = mock(com.brandhub.business.repository.WorkspaceRepository.class);
    var members = mock(com.brandhub.business.repository.WorkspaceMemberRepository.class);
    var profiles = mock(com.brandhub.business.repository.ClientProfileRepository.class);
    var users = mock(com.brandhub.business.repository.UserRepository.class);
    var roles = mock(com.brandhub.business.repository.UserSystemRoleRepository.class);
    when(users.findById(adminId)).thenReturn(java.util.Optional.of(
            com.brandhub.business.model.User.builder().id(adminId).isActive(true).build()));
    when(workspaces.findById(workspace)).thenReturn(java.util.Optional.of(
            com.brandhub.business.model.Workspace.builder()
                    .id(workspace).agencyId(UUID.randomUUID())
                    .status(com.brandhub.business.model.enums.EntityStatus.ACTIVE).build()));
    when(roles.findByUserId(adminId)).thenReturn(java.util.Optional.of(
            com.brandhub.business.model.UserSystemRole.builder()
                    .userId(adminId).systemRole(com.brandhub.business.model.enums.SystemRole.ADMIN).build()));
    when(members.findByWorkspaceIdAndIsActiveTrue(workspace)).thenReturn(java.util.List.of());

    var policy = new MaterialAccessPolicy(workspaces, members, profiles, users, roles,
            mock(com.brandhub.business.repository.TaskMongoRepository.class),
            mock(com.brandhub.business.repository.MaterialMongoRepository.class));
    var adminActor = new com.brandhub.business.security.AuthenticatedUser(adminId, "ADMIN", workspace, java.util.List.of());

    assertThatThrownBy(() -> policy.resolve(workspace, adminActor))
            .isInstanceOf(BusinessException.class)
            .hasFieldOrPropertyWithValue("code", "WORKSPACE_ACCESS_DENIED");
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=MaterialAccessPolicyTest`
Expected: FAIL because `MaterialAccessPolicy.resolve` currently returns a `Scope` with `adminSupport = true` when `systemRole == SystemRole.ADMIN`.

- [x] **Step 3: Remove `SystemRole.ADMIN` bypass in `MaterialAccessPolicy.java`, `MaterialReadService.java`, and configure optional `kmsKeyId` in `RepositoryStorageProperties.java` & `StorageClientRouter.java` + create Terraform stack `brandhub-infrastructure/prod/terraform/4. repository-s3-prod/`**

1. In `MaterialAccessPolicy.java`: delete lines 51–53 (`if (systemRoles.findByUserId(actor.getId()).map(value -> value.getSystemRole() == SystemRole.ADMIN)...`) so `SystemRole.ADMIN` never grants workspace repository access.
2. In `RepositoryStorageProperties.java`: add `private String kmsKeyId;` to `Provider`.
3. In `StorageClientRouter.java`: when `config.getKmsKeyId()` is non-blank, attach `.serverSideEncryption(ServerSideEncryption.AWS_KMS).ssekmsKeyId(config.getKmsKeyId())` on `PutObjectRequest` and `CopyObjectRequest`.
4. Create Terraform configuration in `brandhub-infrastructure/prod/terraform/4. repository-s3-prod/` (`providers.tf`, `variables.tf`, `kms.tf`, `s3.tf`, `iam-service-policy.tf`, `outputs.tf`, `terraform.tfvars`) matching the existing numbered Terraform structure (`1. IAM-role`, `2. frontend-prod`, `3. backend-prod`), enforcing `BlockPublicAccess`, `SSE-KMS` with `aws_kms_key.repository_media`, and explicit `Deny` on `s3:GetObject` / `kms:Decrypt` for human Dev/Admin principals.

- [x] **Step 4: Run test to verify it passes**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=MaterialAccessPolicyTest`
Expected: PASS

- [x] **Step 5: Commit**

```bash
git add brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialAccessPolicy.java brandhub-business-service/src/main/java/com/brandhub/business/config/RepositoryStorageProperties.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/StorageClientRouter.java "brandhub-infrastructure/prod/terraform/4. repository-s3-prod/" brandhub-business-service/src/test/java/com/brandhub/business/service/MaterialAccessPolicyTest.java
git commit -m "feat(security): remove admin/dev repository access and add AWS S3/KMS Terraform stack"
```

---

### Task 2: S3 5GB Free Default Quota, Disable Background Drive Sync & Monthly S3 Storage Add-ons

**Files:**
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/StorageQuotaService.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialStorageUsageService.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/CustomerDriveSyncService.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/response/StorageAddonPlanResponse.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/StorageAddonCheckoutRequest.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/StorageAddonService.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/controller/StorageAddonController.java`
- Create: `brandhub-business-service/src/test/java/com/brandhub/business/service/StorageQuotaFiveGigabyteAndAddonTest.java`

**Interfaces:**
- Produces:
  - `StorageQuotaService.BASIC_BYTES = 5_368_709_120L` (5 GiB)
  - `StorageQuotaService.effectiveQuota(UUID agencyId)` -> `baseQuota (5 GiB or paid plan) + activeAddonBytes(agencyId)`
  - `StorageQuotaService.effectiveClientVaultQuota(UUID userId)` -> `BASIC_BYTES + activeClientAddonBytes(userId)`
  - `StorageAddonService.listAddonPlans() -> List<StorageAddonPlanResponse>` (`S3_ADDON_25GB` @ `49000` VND, `S3_ADDON_100GB` @ `149000` VND, `S3_ADDON_500GB` @ `499000` VND)
  - `GET /api/v1/storage/addons` and `POST /api/v1/storage/addons/checkout`

- [x] **Step 1: Write failing test `StorageQuotaFiveGigabyteAndAddonTest.java`**

```java
package com.brandhub.business.service;

import com.brandhub.business.service.material.StorageAddonService;
import com.brandhub.business.service.material.StorageQuotaService;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.PlatformTransactionManager;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class StorageQuotaFiveGigabyteAndAddonTest {

    @Test
    void basicFreeS3QuotaIsFiveGigabytes() {
        assertThat(StorageQuotaService.BASIC_BYTES).isEqualTo(5_368_709_120L);
    }

    @Test
    void effectiveQuotaAddsActiveMonthlyStorageAddonsToBaseQuota() {
        var jdbc = mock(JdbcTemplate.class);
        var tx = mock(PlatformTransactionManager.class);
        var service = new StorageQuotaService(jdbc, tx);
        UUID agencyId = UUID.randomUUID();

        when(jdbc.query(anyString(), any(org.springframework.jdbc.core.RowMapper.class), any()))
                .thenReturn(List.of());
        when(jdbc.queryForObject(anyString(), org.mockito.ArgumentMatchers.eq(Long.class), any()))
                .thenReturn(26_843_545_600L); // +25 GiB active monthly add-on

        long quota = service.effectiveQuota(agencyId);
        assertThat(quota).isEqualTo(5_368_709_120L + 26_843_545_600L);
    }

    @Test
    void defaultAddonCatalogProvides25Gb100GbAnd500GbMonthlyPlans() {
        var jdbc = mock(JdbcTemplate.class);
        when(jdbc.query(anyString(), any(org.springframework.jdbc.core.RowMapper.class)))
                .thenThrow(new org.springframework.dao.InvalidResultSetAccessException("no table", null));
        var addonService = new StorageAddonService(jdbc);
        var plans = addonService.listAddonPlans();
        assertThat(plans).extracting("code")
                .containsExactly("S3_ADDON_25GB", "S3_ADDON_100GB", "S3_ADDON_500GB");
        assertThat(plans).extracting("priceMonthlyVnd")
                .containsExactly("49000", "149000", "499000");
    }
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=StorageQuotaFiveGigabyteAndAddonTest`
Expected: FAIL because `BASIC_BYTES` is `2_147_483_648L` and `StorageAddonService` does not exist.

- [x] **Step 3: Implement 5GB Free S3 default in `StorageQuotaService`, disable `CustomerDriveSyncService.sync()`, and implement `StorageAddonService` + `StorageAddonController`**

1. In `StorageQuotaService.java`:
   - Set `public static final long BASIC_BYTES = 5_368_709_120L;`
   - In `sample(Request request)`: return `null` so all new reservations route to `"SYSTEM_S3"`.
   - In `effectiveQuota(UUID agency)`: sum `baseQuota` (`paid.isEmpty() ? BASIC_BYTES : paid.getFirst()`) plus active monthly add-on bytes (`SELECT COALESCE(sum(extra_bytes), 0) FROM storage_addon_subscriptions WHERE agency_id=? AND status='ACTIVE' AND current_period_end > now()`, falling back to `0L` if table is not yet migrated).
   - Add `effectiveClientVaultQuota(UUID userId)` returning `BASIC_BYTES + activeClientAddonBytes(userId)`.
2. In `MaterialStorageUsageService.java`: always return `storageMode = "SYSTEM_S3"` using `quota.effectiveQuota(scope.agencyId())`.
3. In `CustomerDriveSyncService.java`: make `sync()` a no-op (`return;`) so background Drive polling is permanently disabled.
4. Create `StorageAddonService.java` and `StorageAddonController.java` (`/api/v1/storage/addons` and `/api/v1/storage/addons/checkout`).

- [x] **Step 4: Run test to verify it passes**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=StorageQuotaFiveGigabyteAndAddonTest`
Expected: PASS

- [x] **Step 5: Commit**

```bash
git add brandhub-business-service/src/main/java/com/brandhub/business/service/material/StorageQuotaService.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialStorageUsageService.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/CustomerDriveSyncService.java brandhub-business-service/src/main/java/com/brandhub/business/dto/response/StorageAddonPlanResponse.java brandhub-business-service/src/main/java/com/brandhub/business/dto/request/StorageAddonCheckoutRequest.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/StorageAddonService.java brandhub-business-service/src/main/java/com/brandhub/business/controller/StorageAddonController.java brandhub-business-service/src/test/java/com/brandhub/business/service/StorageQuotaFiveGigabyteAndAddonTest.java
git commit -m "feat(storage): set 5GB free S3 default, disable background drive sync, add monthly S3 add-ons"
```

---

### Task 3: Nested Folders (`MaterialFolderDocument`), Tiered Browser (`--- folder` / `--- file`) & Sort (`newest`, `oldest`, `name_asc`, `name_desc`)

**Files:**
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/document/MaterialFolderDocument.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialSortKey.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialFolderService.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/CreateMaterialFolderRequest.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/UpdateMaterialFolderRequest.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/MoveMaterialItemRequest.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/response/MaterialFolderResponse.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/response/MaterialBrowserResponse.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/document/MaterialDocument.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/MaterialListRequest.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/dto/response/MaterialResponse.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialResponseFactory.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialRepositoryQuery.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialPageQuery.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/controller/MaterialController.java`
- Create: `brandhub-business-service/src/test/java/com/brandhub/business/service/MaterialFolderAndSortTest.java`

**Interfaces:**
- Produces:
  - `MaterialSortKey.of(String name) -> String` (Vietnamese collation sort key where `a < á < ă < â < b < d < đ < e < ê`)
  - `MaterialListRequest` accepting `sort` in `{"newest", "oldest", "name_asc", "name_desc"}` and optional `String folderId`
  - `MaterialFolderService.browse(UUID workspaceId, AuthenticatedUser actor, String folderId, MaterialListRequest filter) -> MaterialBrowserResponse`
  - `MaterialFolderService.createFolder`, `renameFolder`, `moveFolder`, `deleteFolder`, `restoreFolder`, `moveMaterial`
  - Endpoints on `MaterialController`:
    - `GET /api/v1/workspaces/{workspaceId}/materials/browser`
    - `POST /api/v1/workspaces/{workspaceId}/materials/folders`
    - `PATCH /api/v1/workspaces/{workspaceId}/materials/folders/{folderId}`
    - `POST /api/v1/workspaces/{workspaceId}/materials/folders/{folderId}/move`
    - `DELETE /api/v1/workspaces/{workspaceId}/materials/folders/{folderId}`
    - `POST /api/v1/workspaces/{workspaceId}/materials/folders/{folderId}/restore`
    - `POST /api/v1/workspaces/{workspaceId}/materials/{materialId}/move`

- [x] **Step 1: Write failing test `MaterialFolderAndSortTest.java` covering Vietnamese sort keys, `MaterialListRequest` sort options, and cycle detection on folder move**

```java
package com.brandhub.business.service;

import com.brandhub.business.document.MaterialFolderDocument;
import com.brandhub.business.dto.request.MaterialListRequest;
import com.brandhub.business.exception.BusinessException;
import com.brandhub.business.service.material.MaterialAccessPolicy;
import com.brandhub.business.service.material.MaterialFolderService;
import com.brandhub.business.service.material.MaterialSortKey;
import org.junit.jupiter.api.Test;
import org.springframework.data.mongodb.core.MongoTemplate;

import java.util.List;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class MaterialFolderAndSortTest {

    @Test
    void materialListRequestAcceptsTimeAndNameSortModesAndDefaultsToNewest() {
        var defaultReq = new MaterialListRequest(null, null, null, null, null, null, null, null, null, null, null, null);
        assertThat(defaultReq.sort()).isEqualTo("newest");
        for (String sort : List.of("newest", "oldest", "name_asc", "name_desc")) {
            var req = new MaterialListRequest(0, 20, null, null, null, null, null, null, false, false, sort, null);
            assertThatCode(req::validate).doesNotThrowAnyException();
        }
    }

    @Test
    void vietnameseSortKeyOrdersDStrokeBeforeE() {
        String keyA = MaterialSortKey.of("An Bình");
        String keyD = MaterialSortKey.of("Đồ án Áo dài");
        String keyE = MaterialSortKey.of("Em đẹp");
        assertThat(keyA).isLessThan(keyD);
        assertThat(keyD).isLessThan(keyE);
    }

    @Test
    void movingFolderIntoItsOwnDescendantIsRejected() {
        var mongo = mock(MongoTemplate.class);
        var access = mock(MaterialAccessPolicy.class);
        var queries = mock(com.brandhub.business.service.material.MaterialRepositoryQuery.class);
        var responses = mock(com.brandhub.business.service.material.MaterialResponseEnricher.class);
        var service = new MaterialFolderService(mongo, access, queries, responses);

        UUID workspaceId = UUID.randomUUID();
        var scope = new MaterialAccessPolicy.Scope(workspaceId, UUID.randomUUID(), UUID.randomUUID(),
                com.brandhub.business.model.enums.MemberRole.MANAGER, Set.of());
        when(access.resolve(workspaceId, null)).thenReturn(scope);

        var parent = MaterialFolderDocument.builder().id("folder-root").workspaceId(workspaceId.toString())
                .scopeType("WORKSPACE").name("Root").ancestorIds(List.of()).build();
        var child = MaterialFolderDocument.builder().id("folder-child").workspaceId(workspaceId.toString())
                .scopeType("WORKSPACE").name("Child").parentFolderId("folder-root").ancestorIds(List.of("folder-root")).build();

        when(mongo.findById("folder-root", MaterialFolderDocument.class)).thenReturn(parent);
        when(mongo.findById("folder-child", MaterialFolderDocument.class)).thenReturn(child);

        assertThatThrownBy(() -> service.moveFolder(workspaceId, null, "folder-root", "folder-child"))
                .isInstanceOf(BusinessException.class);
    }
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=MaterialFolderAndSortTest`
Expected: FAIL because `MaterialFolderDocument`, `MaterialSortKey`, and `MaterialFolderService` do not exist yet.

- [x] **Step 3: Implement `MaterialFolderDocument`, `MaterialSortKey`, `MaterialFolderService`, update `MaterialDocument`, `MaterialListRequest`, `MaterialRepositoryQuery`, `MaterialPageQuery`, and `MaterialController`**

1. Add `folderId`, `ancestorFolderIds`, `sortKey`, `scopeType`, `ownerUserId`, `contentHash`, `currentVersionNumber` to `MaterialDocument.java` and `MaterialResponse.java`.
2. Update `MaterialListRequest.java` with secondary constructor keeping backward compatibility for existing 11-arg callers and adding `String folderId`, while expanding `sort` validation to `Set.of("newest", "oldest", "name_asc", "name_desc")`.
3. Update `MaterialPageQuery.java` and `MaterialRepositoryQuery.java`:
   - Support sorting by `created_at` (`newest` = `-1`, `oldest` = `1`) or `normalized_name` (`name_asc` = `1`, `name_desc` = `-1`).
   - When `filter.folderId()` is `"ROOT"`, match `folder_id == null`; when `filter.folderId()` is a folder ID, match `folder_id == filter.folderId()`; when `null` (legacy list endpoint), return all matching items in workspace.
4. Implement `MaterialFolderService.java` providing tiered `browse(...)` (returns `currentFolder`, `breadcrumbs`, sorted `folders`, and paged sorted `files`) plus `createFolder`, `renameFolder`, `moveFolder` (with cycle & max-depth 16 check), `deleteFolder` (cascading soft delete to descendant folders & materials), `restoreFolder`, and `moveMaterial`.
5. Wire endpoints into `MaterialController.java`.

- [x] **Step 4: Run test to verify it passes**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=MaterialFolderAndSortTest`
Expected: PASS

- [x] **Step 5: Commit**

```bash
git add brandhub-business-service/src/main/java/com/brandhub/business/document/MaterialFolderDocument.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialSortKey.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialFolderService.java brandhub-business-service/src/main/java/com/brandhub/business/dto/request/CreateMaterialFolderRequest.java brandhub-business-service/src/main/java/com/brandhub/business/dto/request/UpdateMaterialFolderRequest.java brandhub-business-service/src/main/java/com/brandhub/business/dto/request/MoveMaterialItemRequest.java brandhub-business-service/src/main/java/com/brandhub/business/dto/response/MaterialFolderResponse.java brandhub-business-service/src/main/java/com/brandhub/business/dto/response/MaterialBrowserResponse.java brandhub-business-service/src/main/java/com/brandhub/business/document/MaterialDocument.java brandhub-business-service/src/main/java/com/brandhub/business/dto/request/MaterialListRequest.java brandhub-business-service/src/main/java/com/brandhub/business/dto/response/MaterialResponse.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialResponseFactory.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialRepositoryQuery.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialPageQuery.java brandhub-business-service/src/main/java/com/brandhub/business/controller/MaterialController.java brandhub-business-service/src/test/java/com/brandhub/business/service/MaterialFolderAndSortTest.java
git commit -m "feat(repository): add nested folders, tiered folder/file browser, and time/name sorting"
```

---

### Task 4: Duplicate Content (`SHA-256`) & Filename Resolution (`SKIP`, `KEEP_BOTH`, `OVERWRITE`) + File Versioning (`MaterialVersionDocument` `v1, v2...`)

**Files:**
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/document/MaterialVersionDocument.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/response/MaterialVersionResponse.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/response/MaterialDuplicateConflictResponse.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialVersionService.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/exception/ErrorCode.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/CreateUploadSessionRequest.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialUploadPolicy.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialSessionStore.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialUploadCoordinator.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/controller/MaterialController.java`
- Create: `brandhub-business-service/src/test/java/com/brandhub/business/service/MaterialDuplicateAndVersioningTest.java`

**Interfaces:**
- Produces:
  - `MaterialVersionService.checkDuplicate(String workspaceId, String ownerUserId, String folderId, String normalizedName, String contentHash) -> Optional<MaterialDocument>`
  - `MaterialVersionService.nextKeepBothFilename(String workspaceId, String ownerUserId, String folderId, String filename) -> String` (e.g. `"banner (1).png"`)
  - `MaterialVersionService.overwriteWithNewVersion(MaterialDocument existing, MaterialDocument incoming, String reservationId) -> MaterialDocument` (saves `existing` snapshot into `material_versions` as `v1`, updates `existing` to `v2` with new `s3Key`/`fileSize`/`contentHash`)
  - `MaterialVersionService.listVersions(UUID workspaceId, AuthenticatedUser actor, String materialId) -> List<MaterialVersionResponse>`
  - `MaterialVersionService.restoreVersion(UUID workspaceId, AuthenticatedUser actor, String materialId, String versionId) -> MaterialResponse`
  - `MaterialVersionService.deleteVersion(UUID workspaceId, AuthenticatedUser actor, String materialId, String versionId)` (deletes S3 object of old version & calls `MaterialPurgeAccounting.release`)
  - Endpoints on `MaterialController`:
    - `GET /api/v1/workspaces/{workspaceId}/materials/{materialId}/versions`
    - `POST /api/v1/workspaces/{workspaceId}/materials/{materialId}/versions/{versionId}/restore`
    - `POST /api/v1/workspaces/{workspaceId}/materials/{materialId}/versions/{versionId}/download`
    - `DELETE /api/v1/workspaces/{workspaceId}/materials/{materialId}/versions/{versionId}`

- [x] **Step 1: Write failing test `MaterialDuplicateAndVersioningTest.java`**

```java
package com.brandhub.business.service;

import com.brandhub.business.document.MaterialDocument;
import com.brandhub.business.document.MaterialVersionDocument;
import com.brandhub.business.service.FileStorageService;
import com.brandhub.business.service.material.MaterialAccessPolicy;
import com.brandhub.business.service.material.MaterialPurgeAccounting;
import com.brandhub.business.service.material.MaterialVersionService;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;

import java.time.Instant;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class MaterialDuplicateAndVersioningTest {

    @Test
    void keepBothGeneratesSequentialNumberedFilenameInSameFolder() {
        var mongo = mock(MongoTemplate.class);
        var service = new MaterialVersionService(mongo, mock(MaterialAccessPolicy.class),
                mock(FileStorageService.class), mock(MaterialPurgeAccounting.class));

        when(mongo.exists(any(Query.class), eq(MaterialDocument.class)))
                .thenReturn(true)   // banner.png exists
                .thenReturn(true)   // banner (1).png exists
                .thenReturn(false); // banner (2).png is free

        String resolved = service.nextKeepBothFilename("ws-1", null, "folder-1", "banner.png");
        assertThat(resolved).isEqualTo("banner (2).png");
    }

    @Test
    void overwriteArchivesPreviousStateAsVersionAndIncrementsCurrentVersionNumber() {
        var mongo = mock(MongoTemplate.class);
        var service = new MaterialVersionService(mongo, mock(MaterialAccessPolicy.class),
                mock(FileStorageService.class), mock(MaterialPurgeAccounting.class));

        var existing = MaterialDocument.builder()
                .id("mat-1").workspaceId("ws-1").name("hero.png").originalName("hero.png")
                .s3Key("repository/ws-1/mat-1/tok1/original").storageProvider("SYSTEM_S3")
                .fileSize(1024L).mimeType("image/png").contentHash("hash-v1")
                .currentVersionNumber(1).version(0L).createdBy("user-1").createdAt(Instant.now()).build();

        var incoming = MaterialDocument.builder()
                .id("mat-new").workspaceId("ws-1").name("hero.png")
                .s3Key("repository/ws-1/mat-new/tok2/original").storageProvider("SYSTEM_S3")
                .fileSize(2048L).mimeType("image/png").contentHash("hash-v2")
                .sessionId("res-2").createdBy("user-2").build();

        when(mongo.save(any(MaterialDocument.class))).thenAnswer(inv -> inv.getArgument(0));

        MaterialDocument updated = service.overwriteWithNewVersion(existing, incoming, "res-2");

        var versionCaptor = ArgumentCaptor.forClass(MaterialVersionDocument.class);
        verify(mongo).save(versionCaptor.capture(), eq("material_versions"));
        assertThat(versionCaptor.getValue().getMaterialId()).isEqualTo("mat-1");
        assertThat(versionCaptor.getValue().getVersionNumber()).isEqualTo(1);
        assertThat(versionCaptor.getValue().getS3Key()).isEqualTo("repository/ws-1/mat-1/tok1/original");
        assertThat(versionCaptor.getValue().getFileSize()).isEqualTo(1024L);

        assertThat(updated.getId()).isEqualTo("mat-1");
        assertThat(updated.getCurrentVersionNumber()).isEqualTo(2);
        assertThat(updated.getS3Key()).isEqualTo("repository/ws-1/mat-new/tok2/original");
        assertThat(updated.getFileSize()).isEqualTo(2048L);
    }
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=MaterialDuplicateAndVersioningTest`
Expected: FAIL because `MaterialVersionDocument` and `MaterialVersionService` do not exist yet.

- [x] **Step 3: Implement `MaterialVersionDocument`, `MaterialVersionService`, update `CreateUploadSessionRequest`, `MaterialUploadCoordinator`, and `MaterialController`**

1. Add `MATERIAL_DUPLICATE_CONFLICT(HttpStatus.CONFLICT, "MATERIAL_DUPLICATE_CONFLICT", "File bị trùng tên hoặc trùng nội dung ảnh trong kho")` to `ErrorCode.java`.
2. Add `folderId`, `contentHash`, `conflictResolution` (`ASK` | `SKIP` | `KEEP_BOTH` | `OVERWRITE`), and `overwriteMaterialId` to `CreateUploadSessionRequest.java` and `MaterialUploadPolicy.Upload`.
3. In `MaterialUploadCoordinator.create`:
   - Only when `request.getConflictResolution()` is `"ASK"` (explicitly requested by UI duplicate check or when `contentHash` is provided with `"ASK"`): check `MaterialVersionService.checkDuplicate(...)`; if a duplicate exists, throw `BusinessException(ErrorCode.MATERIAL_DUPLICATE_CONFLICT)` with conflict details.
   - If `"KEEP_BOTH"`, compute `nextKeepBothFilename(...)` so the new material gets `ten-file (1).ext`.
   - In `MaterialUploadCoordinator.finish`: if `"OVERWRITE"` was chosen, call `MaterialVersionService.overwriteWithNewVersion(...)` so the previous file becomes `v1` in `material_versions` and the existing `MaterialDocument` advances to `v2`.
4. Add version history endpoints (`GET /versions`, `POST /versions/{versionId}/restore`, `POST /versions/{versionId}/download`, `DELETE /versions/{versionId}`) to `MaterialController.java`.

- [x] **Step 4: Run test to verify it passes**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=MaterialDuplicateAndVersioningTest`
Expected: PASS

- [x] **Step 5: Commit**

```bash
git add brandhub-business-service/src/main/java/com/brandhub/business/document/MaterialVersionDocument.java brandhub-business-service/src/main/java/com/brandhub/business/dto/response/MaterialVersionResponse.java brandhub-business-service/src/main/java/com/brandhub/business/dto/response/MaterialDuplicateConflictResponse.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialVersionService.java brandhub-business-service/src/main/java/com/brandhub/business/exception/ErrorCode.java brandhub-business-service/src/main/java/com/brandhub/business/dto/request/CreateUploadSessionRequest.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialUploadPolicy.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialSessionStore.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialUploadCoordinator.java brandhub-business-service/src/main/java/com/brandhub/business/controller/MaterialController.java brandhub-business-service/src/test/java/com/brandhub/business/service/MaterialDuplicateAndVersioningTest.java
git commit -m "feat(repository): add SHA-256/filename duplicate resolution and file versioning (v1, v2...)"
```

---

### Task 5: One-Time Google Drive Folder Import into S3 Repository (`DriveFolderImportService`)

**Files:**
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/DriveFolderImportRequest.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/response/DriveFolderImportJobResponse.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/DriveFolderImportService.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/controller/MaterialController.java`
- Create: `brandhub-business-service/src/test/java/com/brandhub/business/service/DriveFolderImportServiceTest.java`

**Interfaces:**
- Produces:
  - `DriveFolderImportService.importFolder(UUID workspaceId, AuthenticatedUser actor, DriveFolderImportRequest request) -> DriveFolderImportJobResponse`
  - `DriveFolderImportService.getJobStatus(UUID workspaceId, AuthenticatedUser actor, String jobId) -> DriveFolderImportJobResponse`
  - Endpoints on `MaterialController`:
    - `POST /api/v1/workspaces/{workspaceId}/materials/drive-import`
    - `GET /api/v1/workspaces/{workspaceId}/materials/drive-import/{jobId}`

- [x] **Step 1: Write failing test `DriveFolderImportServiceTest.java`**

```java
package com.brandhub.business.service;

import com.brandhub.business.document.MaterialDocument;
import com.brandhub.business.document.MaterialFolderDocument;
import com.brandhub.business.dto.request.DriveFolderImportRequest;
import com.brandhub.business.model.enums.MemberRole;
import com.brandhub.business.service.material.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.data.mongodb.core.MongoTemplate;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class DriveFolderImportServiceTest {

    @Test
    void importFolderRecreatesNestedFolderTreeAndUploadsFilesToSystemS3() throws Exception {
        var mongo = mock(MongoTemplate.class);
        var access = mock(MaterialAccessPolicy.class);
        var api = mock(CustomerDriveApi.class);
        var quota = mock(StorageQuotaService.class);
        var storage = mock(FileStorageService.class);
        var folders = mock(MaterialFolderService.class);
        var versions = mock(MaterialVersionService.class);

        UUID workspaceId = UUID.randomUUID();
        UUID agencyId = UUID.randomUUID();
        UUID actorId = UUID.randomUUID();
        var scope = new MaterialAccessPolicy.Scope(workspaceId, agencyId, actorId, MemberRole.OWNER, Set.of());
        when(access.resolve(eq(workspaceId), any())).thenReturn(scope);

        var mapper = new ObjectMapper();
        when(api.get(eq("ya29.token"), contains("files/drive-root"))).thenReturn(
                mapper.readTree("{\"id\":\"drive-root\",\"name\":\"Brand Campaign\",\"mimeType\":\"application/vnd.google-apps.folder\",\"trashed\":false}"));
        when(api.get(eq("ya29.token"), contains("'drive-root'"))).thenReturn(
                mapper.readTree("{\"files\":[" +
                        "{\"id\":\"drive-sub\",\"name\":\"Subfolder A\",\"mimeType\":\"application/vnd.google-apps.folder\",\"trashed\":false}," +
                        "{\"id\":\"drive-file-1\",\"name\":\"poster.png\",\"mimeType\":\"image/png\",\"size\":100,\"trashed\":false}" +
                        "]}"));
        when(api.get(eq("ya29.token"), contains("'drive-sub'"))).thenReturn(
                mapper.readTree("{\"files\":[]}"));
        when(api.range(eq("ya29.token"), eq("drive-file-1"), eq(0L), eq(99L))).thenReturn(new byte[100]);

        when(folders.createImportedFolder(eq(scope), anyString(), any(), anyString()))
                .thenReturn(MaterialFolderDocument.builder().id("local-root").name("Brand Campaign").build())
                .thenReturn(MaterialFolderDocument.builder().id("local-sub").name("Subfolder A").parentFolderId("local-root").build());

        UUID resId = UUID.randomUUID();
        when(quota.reserve(any())).thenReturn(new StorageQuotaService.Reservation(
                resId, agencyId, workspaceId, actorId, "fp", "SYSTEM_S3", 100L, 0L, "RESERVED", "CREATED", Instant.now().plusSeconds(600)));

        var service = new DriveFolderImportService(mongo, access, api, quota, storage, folders, versions);
        var req = new DriveFolderImportRequest("drive-root", "ya29.token", null, "KEEP_BOTH");
        var job = service.importFolder(workspaceId, null, req);

        assertThat(job.status()).isEqualTo("COMPLETED");
        assertThat(job.importedFolders()).isEqualTo(2);
        assertThat(job.importedFiles()).isEqualTo(1);
        verify(storage).putMaterial(eq("SYSTEM_S3"), startsWith("repository/" + workspaceId + "/"), any(byte[].class), eq("image/png"));
        verify(quota).commit(resId, 100L);
        verify(mongo).save(any(MaterialDocument.class), eq("materials"));
    }
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=DriveFolderImportServiceTest`
Expected: FAIL because `DriveFolderImportService` does not exist yet.

- [x] **Step 3: Implement `DriveFolderImportService`, DTOs, `MaterialFolderService.createImportedFolder`, and controller endpoints**

1. Create `DriveFolderImportRequest` (`driveFolderId`, `googleAccessToken`, `targetFolderId`, `conflictResolution`) and `DriveFolderImportJobResponse` (`jobId`, `status`, `importedFolders`, `importedFiles`, `skippedFiles`, `totalBytesImported`, `errorMessage`).
2. Implement `DriveFolderImportService.java`:
   - Traverse the selected Google Drive folder using BFS via `CustomerDriveApi.get(token, ...)` (using the user's one-time Google OAuth token or connected agency token if token is omitted).
   - For each Drive folder, call `folders.createImportedFolder(...)` to create the corresponding `MaterialFolderDocument` in MongoDB preserving the parent-child hierarchy.
   - For each supported file (`image/jpeg`, `image/png`, `image/webp`, `video/mp4`, `video/quicktime`, `application/pdf`), reserve S3 quota via `StorageQuotaService.reserve(...)` (`SYSTEM_S3`), download bytes via `api.range(...)`, compute `SHA-256`, upload to `SYSTEM_S3` via `FileStorageService.putMaterial("SYSTEM_S3", s3Key, bytes, mime)`, commit quota, and save `MaterialDocument` in the mapped `folderId`.
3. Expose `POST /drive-import` and `GET /drive-import/{jobId}` on `MaterialController.java`.

- [x] **Step 4: Run test to verify it passes**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=DriveFolderImportServiceTest`
Expected: PASS

- [x] **Step 5: Commit**

```bash
git add brandhub-business-service/src/main/java/com/brandhub/business/dto/request/DriveFolderImportRequest.java brandhub-business-service/src/main/java/com/brandhub/business/dto/response/DriveFolderImportJobResponse.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/DriveFolderImportService.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialFolderService.java brandhub-business-service/src/main/java/com/brandhub/business/controller/MaterialController.java brandhub-business-service/src/test/java/com/brandhub/business/service/DriveFolderImportServiceTest.java
git commit -m "feat(repository): add one-time Google Drive folder tree import to S3"
```

---

### Task 6: Client Personal Vault (`CLIENT_VAULT`) & Opt-In Cross-Workspace Sharing (`ClientVaultShareDocument`)

**Files:**
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/document/ClientVaultShareDocument.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/ShareClientVaultItemsRequest.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/ClientVaultService.java`
- Create: `brandhub-business-service/src/main/java/com/brandhub/business/controller/ClientVaultController.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialFolderService.java`
- Modify: `brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialUploadCoordinator.java`
- Create: `brandhub-business-service/src/test/java/com/brandhub/business/service/ClientVaultServiceTest.java`

**Interfaces:**
- Produces:
  - `ClientVaultService.browsePersonalVault(AuthenticatedUser clientActor, String folderId, String sort, String search, int page, int size) -> MaterialBrowserResponse`
  - `ClientVaultService.shareToWorkspace(UUID workspaceId, AuthenticatedUser clientActor, ShareClientVaultItemsRequest request) -> List<ClientVaultShareDocument>`
  - `ClientVaultService.unshareFromWorkspace(UUID workspaceId, AuthenticatedUser clientActor, String shareId)`
  - `ClientVaultService.browseWorkspaceClientTab(UUID workspaceId, AuthenticatedUser actor, String folderId, MaterialListRequest filter) -> MaterialBrowserResponse` (returns ONLY folders and files explicitly shared with `workspaceId` via `client_vault_shares`)
  - Endpoints on `ClientVaultController`:
    - `GET /api/v1/client-vault/browser`
    - `GET /api/v1/client-vault/storage-usage`
    - `POST /api/v1/client-vault/folders`
    - `POST /api/v1/workspaces/{workspaceId}/client-vault/shares`
    - `DELETE /api/v1/workspaces/{workspaceId}/client-vault/shares/{shareId}`
    - `GET /api/v1/workspaces/{workspaceId}/client-vault/browser`

- [x] **Step 1: Write failing test `ClientVaultServiceTest.java` verifying strict opt-in cross-workspace isolation and zero-duplicate S3 sharing**

```java
package com.brandhub.business.service;

import com.brandhub.business.document.ClientVaultShareDocument;
import com.brandhub.business.document.MaterialDocument;
import com.brandhub.business.dto.request.MaterialListRequest;
import com.brandhub.business.dto.request.ShareClientVaultItemsRequest;
import com.brandhub.business.model.enums.MemberRole;
import com.brandhub.business.security.AuthenticatedUser;
import com.brandhub.business.service.material.ClientVaultService;
import com.brandhub.business.service.material.MaterialAccessPolicy;
import com.brandhub.business.service.material.MaterialResponseEnricher;
import com.brandhub.business.service.material.StorageQuotaService;
import org.junit.jupiter.api.Test;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;

import java.util.List;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class ClientVaultServiceTest {

    @Test
    void workspaceOnlySeesClientFilesExplicitlySharedToThatWorkspace() {
        var mongo = mock(MongoTemplate.class);
        var access = mock(MaterialAccessPolicy.class);
        var enricher = mock(MaterialResponseEnricher.class);
        var quota = mock(StorageQuotaService.class);

        UUID clientUserId = UUID.randomUUID();
        UUID workspace1 = UUID.randomUUID();
        UUID workspace2 = UUID.randomUUID();
        var actor = new AuthenticatedUser(clientUserId, "USER", workspace2, List.of());

        when(access.resolve(workspace2, actor)).thenReturn(
                new MaterialAccessPolicy.Scope(workspace2, UUID.randomUUID(), clientUserId, MemberRole.CLIENT, Set.of("prof-2")));

        // Workspace 2 has NO shares yet -> returns empty even though Client owns files from Workspace 1
        when(mongo.find(any(Query.class), eq(ClientVaultShareDocument.class))).thenReturn(List.of());

        var service = new ClientVaultService(mongo, access, enricher, quota);
        var filter = new MaterialListRequest(0, 20, null, null, null, null, null, null, false, false, "newest", null);
        var emptyResult = service.browseWorkspaceClientTab(workspace2, actor, null, filter);
        assertThat(emptyResult.folders()).isEmpty();
        assertThat(emptyResult.files().items()).isEmpty();

        // Now Client shares "mat-logo-1" (originally uploaded in Workspace 1) into Workspace 2
        var logoDoc = MaterialDocument.builder()
                .id("mat-logo-1").ownerUserId(clientUserId.toString()).scopeType("CLIENT_VAULT")
                .name("brand-logo.png").s3Key("repository/" + workspace1 + "/mat-logo-1/tok/original")
                .fileSize(50_000L).status("READY").build();
        when(mongo.findById("mat-logo-1", MaterialDocument.class)).thenReturn(logoDoc);

        var shares = service.shareToWorkspace(workspace2, actor,
                new ShareClientVaultItemsRequest(List.of(), List.of("mat-logo-1")));
        assertThat(shares).hasSize(1);
        assertThat(shares.getFirst().getWorkspaceId()).isEqualTo(workspace2.toString());
        assertThat(shares.getFirst().getResourceId()).isEqualTo("mat-logo-1");
    }
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=ClientVaultServiceTest`
Expected: FAIL because `ClientVaultShareDocument` and `ClientVaultService` do not exist yet.

- [x] **Step 3: Implement `ClientVaultShareDocument`, `ClientVaultService`, `ClientVaultController`, and auto-share on Client upload in `MaterialUploadCoordinator`**

1. Create `ClientVaultShareDocument.java` (`collection = "client_vault_shares"`).
2. In `MaterialUploadCoordinator.finish`: when `scope.role() == MemberRole.CLIENT` or `"CLIENT".equals(upload.visibility())`, set `scopeType = "CLIENT_VAULT"` and `ownerUserId = scope.actorId().toString()` on `MaterialDocument`, and automatically upsert a `ClientVaultShareDocument` for `scope.workspaceId().toString()` so the uploaded file is immediately in the Client's Personal Vault AND visible in the current Workspace's *"Kho của Client"* tab.
3. Implement `ClientVaultService.java`:
   - `browsePersonalVault`: returns all folders and files owned by `actor.getId()` (`ownerUserId == actor.getId()` or legacy `createdBy == actor.getId() && visibility == 'CLIENT'`), tiered into `folders` (`--- folder`) and `files` (`--- file`).
   - `shareToWorkspace`: verifies `actor` owns the requested `folderIds` / `materialIds` and is a member of `workspaceId`, then upserts `ClientVaultShareDocument` records without duplicating S3 objects.
   - `browseWorkspaceClientTab`: queries `client_vault_shares` for `workspaceId` and returns only the shared folders (and their children) and shared files, sorted by `newest` / `oldest` / `name_asc` / `name_desc`.
4. Wire `ClientVaultController.java` and support `tab = "CLIENT_VAULT"` in `MaterialFolderService.browse`.

- [x] **Step 4: Run test to verify it passes**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=ClientVaultServiceTest`
Expected: PASS

- [x] **Step 5: Commit**

```bash
git add brandhub-business-service/src/main/java/com/brandhub/business/document/ClientVaultShareDocument.java brandhub-business-service/src/main/java/com/brandhub/business/dto/request/ShareClientVaultItemsRequest.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/ClientVaultService.java brandhub-business-service/src/main/java/com/brandhub/business/controller/ClientVaultController.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialFolderService.java brandhub-business-service/src/main/java/com/brandhub/business/service/material/MaterialUploadCoordinator.java brandhub-business-service/src/test/java/com/brandhub/business/service/ClientVaultServiceTest.java
git commit -m "feat(client-vault): add personal client vault and opt-in cross-workspace sharing"
```

---

### Task 7: Frontend (`brandhub-web`) — Tiered `--- folder` / `--- file` Display, Time/Name Sort, Folder Actions, Drive Import, Duplicate/Version Modal & Client Vault Tab

**Files:**
- Modify: `brandhub-web/src/types/material.ts`
- Modify: `brandhub-web/src/services/materialService.ts`
- Modify: `brandhub-web/src/pages/library/components/MaterialToolbar.tsx`
- Modify: `brandhub-web/src/pages/library/components/CustomerDrivePanel.tsx`
- Create: `brandhub-web/src/pages/library/components/MaterialFolderSection.tsx`
- Create: `brandhub-web/src/pages/library/components/DuplicateResolutionModal.tsx`
- Create: `brandhub-web/src/pages/library/components/MaterialVersionHistoryPanel.tsx`
- Create: `brandhub-web/src/pages/library/components/ShareFromClientVaultModal.tsx`
- Modify: `brandhub-web/src/pages/library/components/MaterialDetailFacts.tsx`
- Modify: `brandhub-web/src/pages/library/hooks/useMaterialRepository.ts`
- Modify: `brandhub-web/src/pages/library/hooks/useMaterialUpload.ts`
- Modify: `brandhub-web/src/i18n/locales/vi/materials.json`
- Modify: `brandhub-web/src/i18n/locales/en/materials.json`

**Interfaces:**
- Produces:
  - `MaterialSortOption = "newest" | "oldest" | "name_asc" | "name_desc"` in `brandhub-web/src/types/material.ts`
  - `MaterialToolbar` with 4 sort options (`newest`, `oldest`, `name_asc`, `name_desc`), `"+ Tạo thư mục"` button, `"Import Folder từ Google Drive"` button, and `"Mua thêm dung lượng S3"` button
  - `MaterialFolderSection` rendering the tiered layout:
    - Top section: `--- Thư mục (Folder)` with nested folder navigation, breadcrumbs, rename, move, and delete
    - Bottom section: `--- Tệp tin (File)`
  - `DuplicateResolutionModal` presenting 3 actions on duplicate name or SHA-256 content: `Bỏ qua (SKIP)`, `Giữ cả hai (KEEP_BOTH)`, `Ghi đè tạo phiên bản mới (OVERWRITE)`
  - `MaterialVersionHistoryPanel` inside Material Detail showing `v1, v2...` history with Download, Restore, and Delete Version buttons
  - `ShareFromClientVaultModal` & *"Kho của Client"* tab for `CLIENT` users to reuse files from previous workspaces without re-uploading

- [x] **Step 1: Update `brandhub-web/src/types/material.ts` and `brandhub-web/src/services/materialService.ts`**

Add types and API methods for:
- `MaterialSort = "newest" | "oldest" | "name_asc" | "name_desc"`
- `MaterialFolderItem`, `MaterialBrowserResponse`, `MaterialVersionItem`, `StorageAddonPlan`
- `materialService.browse(...)`, `createFolder(...)`, `renameFolder(...)`, `moveFolder(...)`, `deleteFolder(...)`, `moveMaterial(...)`, `importDriveFolder(...)`, `listVersions(...)`, `restoreVersion(...)`, `deleteVersion(...)`, `browseClientVault(...)`, `shareClientVaultToWorkspace(...)`, `listStorageAddons(...)`.

- [x] **Step 2: Implement `MaterialToolbar.tsx`, `MaterialFolderSection.tsx`, `DuplicateResolutionModal.tsx`, `MaterialVersionHistoryPanel.tsx`, and `ShareFromClientVaultModal.tsx`**

1. In `MaterialToolbar.tsx`:
   - Add `<option value="name_asc">` (`Tên: A → Z`) and `<option value="name_desc">` (`Tên: Z → A`) alongside `newest` (default) and `oldest`.
   - Display S3 5GB storage usage bar (`Đã dùng X / 5 GB S3`) + `"Mua thêm S3"` modal trigger.
2. In `CustomerDrivePanel.tsx`: replace legacy Customer Drive sync card with S3 5GB Storage & One-Time Google Drive Folder Import action bar.
3. In `MaterialFolderSection.tsx` and the Library page: render breadcrumbs and the explicit two-tier layout (`--- Thư mục` above, `--- Tệp tin` below).
4. In `useMaterialUpload.ts` & `DuplicateResolutionModal.tsx`: compute SHA-256 via `crypto.subtle.digest("SHA-256", buffer)`, catch `409 MATERIAL_DUPLICATE_CONFLICT`, and prompt user with `SKIP` / `KEEP_BOTH` / `OVERWRITE`.
5. In `MaterialDetailFacts.tsx` & `MaterialVersionHistoryPanel.tsx`: render current version badge (`v1`, `v2`...) and version history list with restore/download/delete actions.

- [x] **Step 3: Run frontend typecheck and build verification**

Run: `npm --prefix brandhub-web run build`
Expected: `built in ...` with 0 TypeScript or bundle errors.

- [x] **Step 4: Run full backend test suite**

Run: `mvn test -f brandhub-business-service/pom.xml -Dtest=MaterialAccessPolicyTest,StorageQuotaFiveGigabyteAndAddonTest,MaterialFolderAndSortTest,MaterialDuplicateAndVersioningTest,DriveFolderImportServiceTest,ClientVaultServiceTest`
Expected: All tests PASS.

- [x] **Step 5: Commit**

```bash
git add brandhub-web/src/types/material.ts brandhub-web/src/services/materialService.ts brandhub-web/src/pages/library/ brandhub-web/src/i18n/locales/
git commit -m "feat(web): add tiered folder/file browser, name sort, duplicate/version UI, Drive folder import, and Client Vault tab"
```


## Correction plan — remove leftover Drive connection
1. Add failing live Selenium dashboard check and backend regression proving retired handlers never invoke connection cleanup.
2. Remove dashboard card, connection hook/client, OAuth callback UI and route. Retire old controller methods with explicit 410.
3. Run backend regression, web type-check/build/lint and live headed Selenium dashboard/API checks. Preserve one-time import and legacy read support.

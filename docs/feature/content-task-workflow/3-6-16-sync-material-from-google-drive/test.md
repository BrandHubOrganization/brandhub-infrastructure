# Test Specification — FR 3.6.16: Sync Material from Google Drive

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.16` |
| **Function Name** | Sync Material from Google Drive |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `CustomerDriveSyncService.sync()` (84 LOC) |
| **Unit Test File** | `brandhub-media-service/src/test/java/com/brandhub/media/service/CustomerDriveSyncServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Incrementally scan connected workspace Google Drive folders, validate MIME magic bytes and size limits, and import new materials |
| **Preconditions** | Can connect with server; Agency has an active Google Drive connection with SYNC_SCOPE |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Agency has connected=true, disconnecting=false, and SYNC_SCOPE in agency_drive_connections | `folder` = `mapped workspace Drive folder`, `fileNode` = `new image/jpeg & image/png (<=20MB)` | 200 OK - Verified image/jpeg, image/png, image/webp files imported via CustomerDriveImportStore.save | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Agency has connected=true, disconnecting=false, and SYNC_SCOPE in agency_drive_connections | `folder` = `mapped workspace Drive folder`, `fileNode` = `new video/mp4 & video/quicktime (<=200MB)` | 200 OK - Verified video/mp4 and video/quicktime files (<=200MB) imported into workspace | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Agency has connected=true, disconnecting=false, and SYNC_SCOPE in agency_drive_connections | `folder` = `folder with nested subfolders`, `fileNode` = `new image/jpeg & image/png (<=20MB)` | 200 OK - Verified application/pdf files (<=25MB) imported into workspace | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Agency has connected=true, disconnecting=false, and SYNC_SCOPE in agency_drive_connections | `folder` = `folder with nested subfolders`, `fileNode` = `new video/mp4 & video/quicktime (<=200MB)` | 200 OK - Nested subfolders recursively queued and scanned up to 1000 pages | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Mapped workspace Drive folder has brandhub_workspace appProperty matching workspaceId | `folder` = `mapped workspace Drive folder`, `fileNode` = `new application/pdf (<=25MB)` | 200 OK - Files with brandhub_key appProperty or already in imports.known() skipped without duplicate | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Mapped workspace Drive folder has brandhub_workspace appProperty matching workspaceId | `folder` = `folder with nested subfolders`, `fileNode` = `new application/pdf (<=25MB)` | 200 OK - Binary magic bytes verified via MaterialContentValidator.validateObject range reads | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Agency has connected=true, disconnecting=false, and SYNC_SCOPE in agency_drive_connections | `folder` = `mapped workspace Drive folder`, `fileNode` = `new image/jpeg & image/png (<=20MB)` | 200 OK - File version, parent, and trashed=false re-verified under DriveOperationLease before save | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Agency has connected=true, disconnecting=false, and SYNC_SCOPE in agency_drive_connections | `folder` = `mapped workspace Drive folder`, `fileNode` = `new video/mp4 & video/quicktime (<=200MB)` | 200 OK - RepositoryInventoryService.requireVerified(agencyId) checked before folder scan | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Folder contains subfolders, already-imported files, and 12-byte minimum boundary file | `folder` = `folder with 12B..20MB boundary files`, `fileNode` = `already known file or brandhub_key file` | 200 OK - File at exact minimum 12 bytes and maximum 20MB image limit accepted | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Folder contains subfolders, already-imported files, and 12-byte minimum boundary file | `folder` = `folder with 12B..20MB boundary files`, `fileNode` = `already known file or brandhub_key file` | 200 OK - Trashed files or folders belonging to other workspace roots are skipped | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Agency has connected=true, disconnecting=false, and SYNC_SCOPE in agency_drive_connections | `folder` = `mapped workspace Drive folder`, `fileNode` = `new application/pdf (<=25MB)` | 200 OK - When syncEnabled=false or writesEnabled=false, sync() exits cleanly as no-op | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Connection lacks SYNC_SCOPE, folder is trashed/unmapped, or file fails magic-byte validation | `folder` = `folder without SYNC_SCOPE`, `fileNode` = `new image/jpeg & image/png (<=20MB)` | Reconnect warning logged - Folder skipped when granted_scope lacks SYNC_SCOPE | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Connection lacks SYNC_SCOPE, folder is trashed/unmapped, or file fails magic-byte validation | `folder` = `trashed or wrong-parent Drive folder`, `fileNode` = `new image/jpeg & image/png (<=20MB)` | Folder skipped - Root folder is trashed or brandhub_workspace appProperty mismatches | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Storage feature flags are disabled or Drive API is temporarily unavailable | `folder` = `mapped workspace Drive folder`, `fileNode` = `new image/jpeg & image/png (<=20MB)` | Runtime warning logged - DB or Drive API failure caught and logged without crashing scheduler | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Agency has connected=true, disconnecting=false, and SYNC_SCOPE in agency_drive_connections | `folder` = `folder without SYNC_SCOPE`, `fileNode` = `unsupported MIME or >200MB file` | File skipped - Unsupported MIME type or file size outside [12B, limit] | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; CustomerDriveProperties.enabled, syncEnabled, and RepositoryStorageProperties.writesEnabled are true; Agency has connected=true, disconnecting=false, and SYNC_SCOPE in agency_drive_connections | `folder` = `trashed or wrong-parent Drive folder`, `fileNode` = `corrupted magic bytes (validator fails)` | Import pending logged - BusinessException from MaterialContentValidator caught and logged | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.16`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

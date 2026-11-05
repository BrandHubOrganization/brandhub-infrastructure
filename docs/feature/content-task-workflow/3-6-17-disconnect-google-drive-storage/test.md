# Test Specification — FR 3.6.17: Disconnect Google Drive Storage

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.17` |
| **Function Name** | Disconnect Google Drive Storage |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `CustomerDriveDisconnectService.disconnect()` (56 LOC) |
| **Unit Test File** | `brandhub-media-service/src/test/java/com/brandhub/media/service/CustomerDriveDisconnectServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Fence Google Drive connection, purge USER_GDRIVE materials and remote Drive folders, release storage quota, and delete credentials |
| **Preconditions** | Can connect with server; Agency has an active Google Drive connection |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has an active connection in agency_drive_connections | `agency` = `connected agency UUID with materials`, `actor` = `Manager` | 200 OK - fence() sets connected=false, disconnecting=true, increments generation, deletes states | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has an active connection in agency_drive_connections | `agency` = `connected agency UUID with materials`, `actor` = `Owner` | 200 OK - fenceLateUploads() marks RESERVED USER_GDRIVE uploads as PURGE_IN_PROGRESS in Mongo | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has an active connection in agency_drive_connections | `agency` = `connected agency with in-flight uploads`, `actor` = `Manager` | 200 OK - Active USER_GDRIVE materials transitioned PURGE_IN_PROGRESS -> PURGED in Mongo | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has an active connection in agency_drive_connections | `agency` = `connected agency with in-flight uploads`, `actor` = `Owner` | 200 OK - In-flight USER_GDRIVE material_upload_sessions marked FAILED | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Workspaces have USER_GDRIVE materials in Mongo and reservations in agency_storage_reservations | `agency` = `connected agency UUID with materials`, `actor` = `Manager disconnecting external-folder files` | 200 OK - Remote Drive objects, workspace folders, and root folder deleted via CustomerDriveApi | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Workspaces have USER_GDRIVE materials in Mongo and reservations in agency_storage_reservations | `agency` = `connected agency with in-flight uploads`, `actor` = `Manager disconnecting external-folder files` | 200 OK - External files only deleted if still within mapped workspace Drive folder | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has an active connection in agency_drive_connections | `agency` = `connected agency UUID with materials`, `actor` = `Manager` | 200 OK - finish() releases committed/reserved bytes in agency_storage_usage | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has an active connection in agency_drive_connections | `agency` = `connected agency UUID with materials`, `actor` = `Owner` | 200 OK - repository_drive_objects, workspace_drive_folders, and agency_drive_connections deleted | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has 0 USER_GDRIVE materials or connection row was already removed | `agency` = `agency with 0 Drive materials`, `actor` = `repeat disconnect call` | 200 OK - Disconnecting agency with 0 Drive materials completes and clears token cache | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has 0 USER_GDRIVE materials or connection row was already removed | `agency` = `agency with 0 Drive materials`, `actor` = `repeat disconnect call` | 200 OK - If agency_drive_connections is already empty after fence, disconnect returns cleanly | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has an active connection in agency_drive_connections | `agency` = `connected agency UUID with materials`, `actor` = `Manager disconnecting external-folder files` | 200 OK - UPLOAD_OBJECT_NOT_FOUND on external folder check is ignored safely during cleanup | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Refresh token exchange fails (blank access_token) or Drive storage is unavailable | `agency` = `agency with revoked Google refresh token`, `actor` = `Manager` | MATERIAL_STORAGE_UNAVAILABLE - 503 Google token refresh returned blank access_token | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Refresh token exchange fails (blank access_token) or Drive storage is unavailable | `agency` = `already disconnected agency UUID`, `actor` = `Manager` | CUSTOMER_DRIVE_DISABLED - 503 Customer Google Drive feature is disabled | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is Creator or Client without Manager permission | `agency` = `connected agency UUID with materials`, `actor` = `Manager` | FORBIDDEN - 403 Caller is not Manager or Owner of the workspace | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has an active connection in agency_drive_connections | `agency` = `agency with revoked Google refresh token`, `actor` = `unauthorized Creator/Client` | WORKSPACE_NOT_FOUND - 404 Workspace does not exist | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager); Agency has an active connection in agency_drive_connections | `agency` = `already disconnected agency UUID`, `actor` = `Drive API token failure` | DRIVE_OPERATION_IN_PROGRESS - 409 Another Drive operation lease is active for agency | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.17`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

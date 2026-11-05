# Test Specification — FR 3.6.15: Connect Google Drive Storage

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.15` |
| **Function Name** | Connect Google Drive Storage |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `CustomerDriveConnectionService.complete()` (52 LOC) |
| **Unit Test File** | `brandhub-media-service/src/test/java/com/brandhub/media/service/CustomerDriveConnectionServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Verify PKCE OAuth 2.0 state, exchange code for Google Drive refresh token, seal with AES-256-GCM, and provision agency/workspace folders |
| **Preconditions** | Can connect with server; Caller is Manager or Owner of workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager) | `workspace` = `valid workspace UUID (first connect)`, `completion` = `Completion(code, validState)` | 200 OK - complete() returns Status(enabled=true, connected=true, accountEmail, rootFolderId) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager) | `workspace` = `valid workspace UUID (first connect)`, `completion` = `authorize(workspace, actor) PKCE URL` | 200 OK - authorize() generates Google OAuth2 URL with S256 PKCE challenge and 10m state row | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager) | `workspace` = `workspace in agency reconnecting same account`, `completion` = `Completion(code, validState)` | 200 OK - Refresh token sealed with DriveSecretBox.seal('grant:' + connectionId) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager) | `workspace` = `workspace in agency reconnecting same account`, `completion` = `authorize(workspace, actor) PKCE URL` | 200 OK - Root Drive folder 'brandhub-<agencyName>' and workspace subfolder created | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Valid PKCE state_hash exists in repository_drive_states within 10-minute TTL | `workspace` = `valid workspace UUID (first connect)`, `completion` = `status(workspace, actor) check` | 200 OK - One-time state row deleted from repository_drive_states on consumption | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Valid PKCE state_hash exists in repository_drive_states within 10-minute TTL | `workspace` = `workspace in agency reconnecting same account`, `completion` = `status(workspace, actor) check` | 200 OK - Reconnecting same Google account_id updates refresh_token_ciphertext and granted_scope | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager) | `workspace` = `valid workspace UUID (first connect)`, `completion` = `Completion(code, validState)` | 200 OK - In-memory access token cache cleared after connection update | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager) | `workspace` = `valid workspace UUID (first connect)`, `completion` = `authorize(workspace, actor) PKCE URL` | 200 OK - status() returns connected=false when agency has no connection row yet | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Agency is reconnecting the same Google account (existing connection_id and root_folder_id) | `workspace` = `workspace at 10m state TTL boundary`, `completion` = `reconnect same Google permissionId` | 200 OK - Completion at exact 10-minute state expiration boundary succeeds | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Agency is reconnecting the same Google account (existing connection_id and root_folder_id) | `workspace` = `workspace at 10m state TTL boundary`, `completion` = `reconnect same Google permissionId` | 200 OK - Both SYNC_SCOPE and drive.file SCOPE validated according to isSyncEnabled() | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager) | `workspace` = `valid workspace UUID (first connect)`, `completion` = `status(workspace, actor) check` | 200 OK - status() returns Status(false, false, null, null) when Drive feature is disabled | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; OAuth state is expired/missing, Google token lacks required scope/refresh_token, or account differs | `workspace` = `workspace with expired state`, `completion` = `Completion(code, validState)` | OAUTH_CODE_INVALID - 400 PKCE state hash not found, expired, or generation changed | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; OAuth state is expired/missing, Google token lacks required scope/refresh_token, or account differs | `workspace` = `other-agency workspace UUID`, `completion` = `Completion(code, validState)` | OAUTH_CODE_INVALID - 400 Google token response missing refresh_token, scope, or permissionId | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is Creator or Client without Manager permission | `workspace` = `valid workspace UUID (first connect)`, `completion` = `Completion(code, validState)` | FORBIDDEN - 403 Caller is not Manager or Owner of the workspace | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager) | `workspace` = `workspace with expired state`, `completion` = `different Google account (conflict)` | UPLOAD_REQUEST_CONFLICT - 409 Agency already connected to a different Google account | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; CustomerDriveProperties.isEnabled() is true and schema is ready; Caller is Manager or Owner of the workspace (CustomerDriveAccess.requireManager) | `workspace` = `other-agency workspace UUID`, `completion` = `missing refresh_token or scope` | CUSTOMER_DRIVE_DISABLED - 503 Customer Google Drive integration is disabled | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.15`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

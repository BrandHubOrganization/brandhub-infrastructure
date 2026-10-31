# Test Specification — FR 3.6.22: Add Hashtag Collection

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.22` |
| **Function Name** | Add Hashtag Collection |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `HashtagServiceImpl.add()` (34 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/HashtagServiceImplTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Create a new hashtag collection or add normalized hashtags with category classification to the workspace library |
| **Preconditions** | Can connect with server; Caller is Manager, Creator, or Client in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 20** (`Passed`: 20, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID20`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `brand` | 201 Created - {id, tag} | Hashtag added | **Passed** |
| `UTCID02` | `N` | Can connect with server; Workspace exists and is active; User is CLIENT | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `event-specific`, `isRequired` = `true` | 201 Created - isRequired=true | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Workspace exists and is active; User is CREATOR | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `trending` | 201 Created - isRequired=false | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `campaign` | 201 Created - purpose=campaign | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Workspace exists and is active; User is CLIENT | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `brand` | 201 Created - isRequired=false by default | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `brandhub`, `purpose` = `brand` | 201 Created - tag normalized with leading # | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active; Same tag exists in another workspace | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `brand` | 201 Created - allowed per workspace | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active; Same tag exists but removed | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `brand` | 201 Created - tag re-added | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `1 char after #`, `purpose` = `brand` | 201 Created - shortest tag | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `max length tag`, `purpose` = `brand` | 201 Created - longest tag | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `max length + 1 chars`, `purpose` = `brand` | 400 VALIDATION_ERROR (tag too long) | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `empty`, `purpose` = `brand` | 400 VALIDATION_ERROR (tag required) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active; Tag already exists in workspace | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `brand` | 409 HASHTAG_ALREADY_EXISTS | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active; Same tag exists with different case | `workspaceId` = `valid`, `tag` = `#BrandHub`, `purpose` = `brand` | 409 HASHTAG_ALREADY_EXISTS | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `null`, `purpose` = `brand` | 400 VALIDATION_ERROR (tag required) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `null` | 400 VALIDATION_ERROR (purpose required) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `unknown` | 400 VALIDATION_ERROR (invalid purpose) | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace exists and is active | `workspaceId` = `valid`, `tag` = `has space`, `purpose` = `brand` | 400 VALIDATION_ERROR (invalid characters) | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Workspace exists and is active; User is MANAGER without permission | `workspaceId` = `valid`, `tag` = `#brandhub`, `purpose` = `brand` | 403 FORBIDDEN | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace does not exist | `workspaceId` = `non-existent`, `tag` = `#brandhub`, `purpose` = `brand` | 404 WORKSPACE_NOT_FOUND | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.22`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

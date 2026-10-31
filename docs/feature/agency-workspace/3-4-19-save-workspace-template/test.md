# Test Specification — FR 3.4.19: Save Workspace Template

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.19` |
| **Function Name** | Save Workspace Template |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `WorkspaceTemplateServiceImpl.saveTemplate()` (13 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceTemplateServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Save a workspace's configuration snapshot (industry, brand info, timezone, defaultPlatforms, reportFrequency) as an agency template |
| **Preconditions** | Can connect with server; Caller is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 20** (`Passed`: 20, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID20`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller owns an agency | `name` = `Retail Starter`, `config` = `timezone, platforms, reportFrequency`, `sourceWorkspaceId` = `valid workspace id` | WorkspaceTemplateResponse(id,agencyId,name,sourceWorkspaceId,configSnapshot,createdBy) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller owns an agency | `name` = `Retail Starter`, `config` = `timezone, platforms, reportFrequency` | WorkspaceTemplateResponse(sourceWorkspaceId=null) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller owns an agency | `name` = `Retail Starter`, `config` = `timezone only` | WorkspaceTemplateResponse(configSnapshot JSON with timezone) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller owns an agency | `name` = `Retail Starter`, `config` = `platforms + reportFrequency=WEEKLY` | WorkspaceTemplateResponse(configSnapshot JSON) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller owns an agency | `name` = `Retail Starter`, `config` = `reportFrequency=MONTHLY` | WorkspaceTemplateResponse(configSnapshot JSON) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller owns an agency; Caller owns 2 agencies | `name` = `Retail Starter`, `config` = `timezone, platforms, reportFrequency` | WorkspaceTemplateResponse(agencyId = owned agency) | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller owns an agency | `name` = `Retail Starter`, `config` = `timezone, platforms, reportFrequency`, `agencyId` = `forged id in payload ignored` | WorkspaceTemplateResponse(agencyId from session) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller owns an agency | `name` = `Retail Starter`, `config` = `timezone, platforms, reportFrequency` | WorkspaceTemplateResponse(createdBy = caller id) | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Caller owns an agency; Source workspace later deleted | `name` = `Retail Starter`, `config` = `timezone, platforms, reportFrequency`, `sourceWorkspaceId` = `soft-deleted workspace` | Template remains available (BR-06) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller owns an agency | `name` = `1 char`, `config` = `timezone, platforms, reportFrequency` | WorkspaceTemplateResponse(name length 1) | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller owns an agency | `name` = `max length name`, `config` = `timezone, platforms, reportFrequency` | WorkspaceTemplateResponse(name at max length) | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Caller owns an agency | `name` = `Retail Starter`, `config` = `empty object` | WorkspaceTemplateResponse(configSnapshot={}) | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; Caller owns an agency; Agency already has templates | `name` = `duplicate name`, `config` = `timezone, platforms, reportFrequency` | WorkspaceTemplateResponse (name not unique-checked) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller owns no agency | `name` = `Retail Starter`, `config` = `timezone, platforms, reportFrequency` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is only agency member (not owner) | `name` = `Retail Starter`, `config` = `timezone, platforms, reportFrequency` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller owns an agency | `name` = `null`, `config` = `timezone, platforms, reportFrequency` | VALIDATION_ERROR: name must not be blank (MSG02) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Caller owns an agency | `name` = `empty`, `config` = `timezone, platforms, reportFrequency` | VALIDATION_ERROR: name must not be blank (MSG02) | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Caller owns an agency | `name` = `blank spaces only`, `config` = `timezone, platforms, reportFrequency` | VALIDATION_ERROR: name must not be blank (MSG02) | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Caller owns an agency | `name` = `Retail Starter`, `config` = `null` | VALIDATION_ERROR: configSnapshot must not be blank (MSG02) | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Caller owns an agency | `name` = `Retail Starter`, `config` = `unserializable object` | IllegalStateException: failed to serialize config | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.19`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

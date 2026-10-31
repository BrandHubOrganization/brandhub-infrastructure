# Test Specification — FR 3.7.19: Recommend Collaborator

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.19` |
| **Function Name** | Recommend Collaborator |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `CollaboratorServiceImpl.listByAgency()` (5 LOC) |
| **Unit Test File** | `Pending (Unimplemented in current release)` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Rank and recommend third-party collaborators matching campaign objective, industry, and budget (currently unimplemented) |
| **Preconditions** | Can connect with server; Caller is Owner, Manager, or Client in workspace |
| **Overall Status** | **Untested (Pending Implementation)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 0, `Failed`: 0, `Untested`: 18) — `Normal (N)`: 7, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `fashion`, `targetAudience` = `women 18-30`, `budgetRange` = `50-100M VND` | 200 - recommendations[{name,type,tier,reason}] sorted by tier | — | **Untested** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `F&B`, `targetAudience` = `women 18-30`, `budgetRange` = `50-100M VND` | 200 - recommendations for F&B | — | **Untested** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `fashion`, `targetAudience` = `women 18-30`, `budgetRange` = `500M+ VND` | 200 - high-tier partners included (press, TV) | — | **Untested** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `fashion`, `targetAudience` = `null`, `budgetRange` = `50-100M VND` | 200 - recommendations based on industry and budget | — | **Untested** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR or MANAGER of workspace; Collaborator exists in agency directory | `collaboratorId` = `existing in directory`, `campaignId` = `valid campaign` | 200 - CampaignCollaborator linked, cooperationStatus=contacted | — | **Untested** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR or MANAGER of workspace | `campaignId` = `valid campaign`, `newCollaborator` = `name,type,contactInfo` | 200 - new ThirdPartyCollaborator created and linked, status=contacted | — | **Untested** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `fashion`, `targetAudience` = `women 18-30`, `budgetRange` = `50-100M VND` | 200 - suggestions only, no auto contact or contract | — | **Untested** |
| `UTCID08` | `B` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `fashion`, `targetAudience` = `women 18-30`, `budgetRange` = `very low` | 200 - lowest-tier recommendations with warning, not empty | — | **Untested** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `fashion`, `targetAudience` = `women 18-30`, `budgetRange` = `0 VND` | 200 - lowest-tier recommendations with warning | — | **Untested** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `1 char`, `targetAudience` = `women 18-30`, `budgetRange` = `50-100M VND` | 200 - generic recommendations | — | **Untested** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR or MANAGER of workspace; Collaborator already linked to campaign | `collaboratorId` = `already linked`, `campaignId` = `valid campaign` | 200 - existing link returned, no duplicate | — | **Untested** |
| `UTCID12` | `A` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `empty`, `targetAudience` = `women 18-30`, `budgetRange` = `50-100M VND` | 400 Validation error (industry required) | — | **Untested** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `null`, `targetAudience` = `women 18-30`, `budgetRange` = `50-100M VND` | 400 Validation error (industry required) | — | **Untested** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR or MANAGER of workspace | `industry` = `fashion`, `targetAudience` = `women 18-30`, `budgetRange` = `invalid text` | 400 Validation error (invalid budgetRange) | — | **Untested** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR or MANAGER of workspace | `collaboratorId` = `non-existent id`, `campaignId` = `valid campaign` | 404 Collaborator not found | — | **Untested** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR or MANAGER of workspace | `collaboratorId` = `existing in directory`, `campaignId` = `non-existent id` | 404 Campaign not found | — | **Untested** |
| `UTCID17` | `A` | User is not CREATOR or MANAGER of workspace | `industry` = `fashion`, `targetAudience` = `women 18-30`, `budgetRange` = `50-100M VND` | 403 FORBIDDEN | — | **Untested** |
| `UTCID18` | `A` | Can connect with server; User is CREATOR or MANAGER of workspace; LLM provider fails | `industry` = `fashion`, `targetAudience` = `women 18-30`, `budgetRange` = `50-100M VND` | 502 AI_SERVICE_UNAVAILABLE | — | **Untested** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.19`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

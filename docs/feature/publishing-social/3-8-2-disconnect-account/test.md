# Test Specification — FR 3.8.2: Disconnect Account

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.2` |
| **Function Name** | Disconnect Account |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Target Class & Method** | `SocialAccountServiceImpl.disconnectAccount()` (32 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/SocialAccountServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Disconnect a social account from the workspace, revoke stored OAuth tokens, cancel pending scheduled posts, and keep published history |
| **Preconditions** | Can connect with server; Social account is connected to workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CLIENT owner of account | `accountId` = `valid active account` | 200 - data=null, account deactivated | Social account disconnected | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CLIENT owner of account; Platform supports revoke | `accountId` = `valid active account` | 200 - platform token revoked then record deactivated | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is CLIENT owner of account; Platform has no revoke API | `accountId` = `valid active account` | 200 - record deactivated without revoke call | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CLIENT owner of account; Account has 2 PENDING posts | `accountId` = `valid active account` | 200 - both posts set to FAIL, reason account disconnected | 2 pending posts failed | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CLIENT owner of account; Account has no pending posts | `accountId` = `valid active account` | 200 - no post modified | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CLIENT owner of account; Account has DONE posts | `accountId` = `valid active account` | 200 - DONE posts remain unchanged | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CLIENT owner of account | `accountId` = `valid active account` | 200 - token wiped from record | Stored token cleared | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is CLIENT owner of account; Account later reconnected | `accountId` = `valid active account` | 200 - record can be reactivated by 3.8.1 | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CLIENT owner of account; Account has exactly 1 PENDING post | `accountId` = `valid active account` | 200 - single post set to FAIL | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CLIENT owner of account; Account has 1000 PENDING posts | `accountId` = `valid active account` | 200 - all 1000 posts set to FAIL | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is CLIENT owner of account; Post IN_PROGRESS on account | `accountId` = `valid active account` | 200 - in-flight post set to FAIL with clear reason | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is CLIENT owner of account | `accountId` = `null` | SOCIAL_ACCOUNT_NOT_FOUND: Social account not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is CLIENT owner of account | `accountId` = `non-existent id` | SOCIAL_ACCOUNT_NOT_FOUND: Social account not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is CLIENT owner of account | `accountId` = `malformed id` | SOCIAL_ACCOUNT_NOT_FOUND: Social account not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CLIENT but not owner | `accountId` = `account of other client` | FORBIDDEN: access denied | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MEMBER | `accountId` = `valid active account` | FORBIDDEN: access denied | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is CLIENT owner of account; Account already disconnected | `accountId` = `already disconnected account` | SOCIAL_ACCOUNT_NOT_FOUND: Social account not found | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is CLIENT owner of account; Platform revoke API fails | `accountId` = `valid active account` | PLATFORM_API_ERROR: platform revoke failed | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.2`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

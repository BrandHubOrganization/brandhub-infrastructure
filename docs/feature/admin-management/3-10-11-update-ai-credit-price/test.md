# Test Specification — FR 3.10.11: Update AI Credit Price

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.11` |
| **Function Name** | Update AI Credit Price |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `CreditConfigurationService.updatePrice()` (12 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/CreditConfigurationServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Allow Admin to update unitCredits and enabled state for a billable CreditOperation with optimistic revision concurrency check |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Caller has ROLE_ADMIN authority | `operation` = `CAPTION_GENERATION`, `request` = `Price(unitCredits=5, enabled=true, expectedRevision=0)` | 200 OK - CreditConfigurationResponse.Price updated with unitCredits=5 and revision incremented | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Caller has ROLE_ADMIN authority | `operation` = `CAPTION_GENERATION`, `request` = `Price(unitCredits=20, enabled=true, expectedRevision=1)` | 200 OK - IMAGE_GENERATION price updated to 20 credits and persisted in store | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Caller has ROLE_ADMIN authority | `operation` = `IMAGE_GENERATION`, `request` = `Price(unitCredits=5, enabled=true, expectedRevision=0)` | 200 OK - VIDEO_GENERATION price updated to 50 credits with enabled=false toggle | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Caller has ROLE_ADMIN authority | `operation` = `IMAGE_GENERATION`, `request` = `Price(unitCredits=20, enabled=true, expectedRevision=1)` | 200 OK - Subsequent AI generation requests use the updated unitCredits immediately | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Target operation is a valid billable CreditOperation (e.g. CAPTION_GENERATION, IMAGE_GENERATION, VIDEO_GENERATION) | `operation` = `CAPTION_GENERATION`, `request` = `Price(unitCredits=50, enabled=false, expectedRevision=2)` | 200 OK - Existing reserved AI credit holds keep their locked price from reservation time | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Target operation is a valid billable CreditOperation (e.g. CAPTION_GENERATION, IMAGE_GENERATION, VIDEO_GENERATION) | `operation` = `IMAGE_GENERATION`, `request` = `Price(unitCredits=50, enabled=false, expectedRevision=2)` | 200 OK - store.savePrice records actorId, new revision, and updatedAt timestamp | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Caller has ROLE_ADMIN authority | `operation` = `CAPTION_GENERATION`, `request` = `Price(unitCredits=5, enabled=true, expectedRevision=0)` | 200 OK - updatePolicy and updateMember allow Owner to update agency/member limits | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Caller has ROLE_ADMIN authority | `operation` = `CAPTION_GENERATION`, `request` = `Price(unitCredits=20, enabled=true, expectedRevision=1)` | 200 OK - Role check verifies ROLE_ADMIN authority on AuthenticatedUser | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; expectedRevision matches current operation revision in credit_operation_prices | `operation` = `VIDEO_GENERATION`, `request` = `Price(unitCredits=0, enabled=true, expectedRevision=0)` | 200 OK - Boundary unitCredits=0 (zero-cost operation) accepted with expectedRevision=0 | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; expectedRevision matches current operation revision in credit_operation_prices | `operation` = `VIDEO_GENERATION`, `request` = `Price(unitCredits=0, enabled=true, expectedRevision=0)` | 200 OK - Toggling enabled flag without changing unitCredits increments revision cleanly | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Caller has ROLE_ADMIN authority | `operation` = `CAPTION_GENERATION`, `request` = `Price(unitCredits=50, enabled=false, expectedRevision=2)` | 200 OK - High unitCredits boundary (e.g. 10000 credits) persisted accurately | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Operation name is unknown, non-billable, or expectedRevision is stale | `operation` = `UNKNOWN_OP or non-billable op`, `request` = `Price(unitCredits=5, enabled=true, expectedRevision=0)` | CREDIT_OPERATION_INVALID - 400 Operation name is unknown or not billable | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Operation name is unknown, non-billable, or expectedRevision is stale | `operation` = `CAPTION_GENERATION (stale revision)`, `request` = `Price(unitCredits=5, enabled=true, expectedRevision=0)` | CREDIT_CONFIGURATION_STALE - 409 expectedRevision does not match current price revision | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller does not have ROLE_ADMIN authority | `operation` = `CAPTION_GENERATION`, `request` = `Price(unitCredits=5, enabled=true, expectedRevision=0)` | FORBIDDEN - 403 Caller does not have ROLE_ADMIN authority | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Caller has ROLE_ADMIN authority | `operation` = `UNKNOWN_OP or non-billable op`, `request` = `stale expectedRevision=99` | CREDIT_OWNER_LIMIT_INVALID - 400 Cannot set member credit limit on the Owner | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; CreditConfigurationStore schema is ready and actor is an active user; Caller has ROLE_ADMIN authority | `operation` = `CAPTION_GENERATION (stale revision)`, `request` = `negative unitCredits or null expectedRevision` | VALIDATION_ERROR - 400 unitCredits must be >= 0 and expectedRevision is required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.11`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

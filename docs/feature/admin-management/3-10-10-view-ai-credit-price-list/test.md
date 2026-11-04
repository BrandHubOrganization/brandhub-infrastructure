# Test Specification — FR 3.10.10: View AI Credit Price List

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.10` |
| **Function Name** | View AI Credit Price List |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `CreditConfigurationService.prices()` (15 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/CreditConfigurationServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Return the system-wide billable AI credit pricing catalog across all CreditOperation types with unitCredits, enabled, and revision |
| **Preconditions** | Can connect with server; Credit configuration schema is ready |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); credit_operation_prices table contains billable and non-billable CreditOperation rows | `operationScope` = `CreditConfigurationService.prices()`, `actor` = `Admin user` | 200 OK - prices() returns List<CreditConfigurationResponse.Price> for all billable operations | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); credit_operation_prices table contains billable and non-billable CreditOperation rows | `operationScope` = `CreditConfigurationService.prices()`, `actor` = `Owner` | 200 OK - Non-billable operations filtered out via price.operation().isBillable() | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); credit_operation_prices table contains billable and non-billable CreditOperation rows | `operationScope` = `policy(agencyId, ownerActor)`, `actor` = `Admin user` | 200 OK - Each Price includes operation, unitCredits, enabled, revision, updatedAt, updatedBy | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); credit_operation_prices table contains billable and non-billable CreditOperation rows | `operationScope` = `policy(agencyId, ownerActor)`, `actor` = `Owner` | 200 OK - policy(agencyId, owner) returns Agency credit policy settings | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); Caller is authenticated (or Admin viewing price table) | `operationScope` = `CreditConfigurationService.prices()`, `actor` = `Agency Member (Creator/Manager)` | 200 OK - ownLimit(agencyId, owner) returns MemberLimit with mode='OWNER_UNLIMITED' | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); Caller is authenticated (or Admin viewing price table) | `operationScope` = `policy(agencyId, ownerActor)`, `actor` = `Agency Member (Creator/Manager)` | 200 OK - ownLimit(agencyId, member) returns member's configured credit limit and revision | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); credit_operation_prices table contains billable and non-billable CreditOperation rows | `operationScope` = `CreditConfigurationService.prices()`, `actor` = `Admin user` | 200 OK - memberLimit(agencyId, owner, memberId) returns target member's credit limit | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); credit_operation_prices table contains billable and non-billable CreditOperation rows | `operationScope` = `CreditConfigurationService.prices()`, `actor` = `Owner` | 200 OK - Prices match real-time unit costs used by AiCreditGenerationService | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); Only 1 billable CreditOperation is enabled in catalog | `operationScope` = `ownLimit(agencyId, memberActor)`, `actor` = `Owner querying ownLimit (OWNER_UNLIMITED)` | 200 OK - memberLimit(agencyId, owner, ownerId) returns mode='OWNER_UNLIMITED', revision=0 | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); Only 1 billable CreditOperation is enabled in catalog | `operationScope` = `ownLimit(agencyId, memberActor)`, `actor` = `Owner querying ownLimit (OWNER_UNLIMITED)` | 200 OK - Catalog with 0 billable rows returns empty list [] cleanly | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); credit_operation_prices table contains billable and non-billable CreditOperation rows | `operationScope` = `CreditConfigurationService.prices()`, `actor` = `Agency Member (Creator/Manager)` | 200 OK - Price with unitCredits=0 (free billable operation) returned accurately | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); CreditConfigurationStore schema is not yet initialized | `operationScope` = `schema not ready state`, `actor` = `Admin user` | CREDIT_SCHEMA_NOT_READY - 503 Credit configuration database schema is not ready | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); CreditConfigurationStore schema is not yet initialized | `operationScope` = `non-Owner querying policy`, `actor` = `Admin user` | FORBIDDEN - 403 Caller is not the Owner of the agency when viewing policy/memberLimit | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller queries agency policy/member limit without Owner/member permission | `operationScope` = `CreditConfigurationService.prices()`, `actor` = `Admin user` | FORBIDDEN - 403 Inactive user account rejected by requireActiveUser | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); credit_operation_prices table contains billable and non-billable CreditOperation rows | `operationScope` = `schema not ready state`, `actor` = `inactive user account` | NOT_AGENCY_MEMBER - 403 User is not an active member of the agency | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; CreditConfigurationStore schema is ready (store.requireSchema()); credit_operation_prices table contains billable and non-billable CreditOperation rows | `operationScope` = `non-Owner querying policy`, `actor` = `non-member of agency` | AGENCY_NOT_FOUND - 404 Agency not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.10`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

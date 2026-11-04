# Test Specification — FR 3.9.5: Buy Credit

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.9.5` |
| **Function Name** | Buy Credit |
| **Functional Domain** | Billing |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `BillingServiceImpl.buyCredit()` (5 LOC) |
| **Unit Test File** | `Pending (Unimplemented in current release)` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Create a standalone SePay payment order for top-up AI credits (currently unimplemented; throws UnsupportedOperationException) |
| **Preconditions** | Can connect with server; Caller is Owner of agency |
| **Overall Status** | **Untested (Pending Implementation)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 0, `Failed`: 0, `Untested`: 16) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is authenticated Owner of an active agency; BuyCreditRequest payload is submitted to POST /api/v1/billing/credits/buy | `currentUser` = `authenticated Owner`, `request` = `BuyCreditRequest(agencyId, amount=100)` | 200 OK - TransactionResponse(status=PENDING, paymentUrl) for 100 credits | — | **Untested** |
| `UTCID02` | `N` | Can connect with server; Caller is authenticated Owner of an active agency; BuyCreditRequest payload is submitted to POST /api/v1/billing/credits/buy | `currentUser` = `authenticated Owner`, `request` = `BuyCreditRequest(agencyId, amount=500)` | 200 OK - TransactionResponse(status=PENDING, paymentUrl) for 500 credits | — | **Untested** |
| `UTCID03` | `N` | Can connect with server; Caller is authenticated Owner of an active agency; BuyCreditRequest payload is submitted to POST /api/v1/billing/credits/buy | `currentUser` = `Owner on PLUS plan`, `request` = `BuyCreditRequest(agencyId, amount=100)` | 200 OK - SePay VietQR checkout order created for standalone credit pack | — | **Untested** |
| `UTCID04` | `N` | Can connect with server; Caller is authenticated Owner of an active agency; BuyCreditRequest payload is submitted to POST /api/v1/billing/credits/buy | `currentUser` = `Owner on PLUS plan`, `request` = `BuyCreditRequest(agencyId, amount=500)` | 200 OK - Webhook confirmation grants TOPUP credits to agency wallet | — | **Untested** |
| `UTCID05` | `N` | Can connect with server; Caller is authenticated Owner of an active agency; BillingServiceImpl.buyCredit is invoked by BillingController | `currentUser` = `authenticated Owner`, `request` = `BuyCreditRequest(agencyId, amount=1000)` | 200 OK - TransactionResponse(status=PENDING) for 1000 credits | — | **Untested** |
| `UTCID06` | `N` | Can connect with server; Caller is authenticated Owner of an active agency; BillingServiceImpl.buyCredit is invoked by BillingController | `currentUser` = `Owner on PLUS plan`, `request` = `BuyCreditRequest(agencyId, amount=1000)` | 200 OK - Idempotent webhook processing for credit purchase | — | **Untested** |
| `UTCID07` | `N` | Can connect with server; Caller is authenticated Owner of an active agency; BuyCreditRequest payload is submitted to POST /api/v1/billing/credits/buy | `currentUser` = `authenticated Owner`, `request` = `BuyCreditRequest(agencyId, amount=100)` | 200 OK - Credit top-up recorded in invoice history | — | **Untested** |
| `UTCID08` | `N` | Can connect with server; Caller is authenticated Owner of an active agency; BuyCreditRequest payload is submitted to POST /api/v1/billing/credits/buy | `currentUser` = `authenticated Owner`, `request` = `BuyCreditRequest(agencyId, amount=500)` | 200 OK - Updated balance immediately visible in CreditBalanceService | — | **Untested** |
| `UTCID09` | `B` | Can connect with server; Caller is authenticated Owner of an active agency; Boundary credit amount (1 credit or max pack) is requested | `currentUser` = `Owner at boundary amount`, `request` = `BuyCreditRequest(agencyId, amount=1)` | 200 OK - Minimum boundary amount=1 credit accepted | — | **Untested** |
| `UTCID10` | `B` | Can connect with server; Caller is authenticated Owner of an active agency; Boundary credit amount (1 credit or max pack) is requested | `currentUser` = `Owner at boundary amount`, `request` = `BuyCreditRequest(agencyId, amount=1)` | 200 OK - Maximum pack boundary amount accepted | — | **Untested** |
| `UTCID11` | `B` | Can connect with server; Caller is authenticated Owner of an active agency; BuyCreditRequest payload is submitted to POST /api/v1/billing/credits/buy | `currentUser` = `authenticated Owner`, `request` = `BuyCreditRequest(agencyId, amount=1000)` | 200 OK - Top-up grant created with non-expiring or period-bound policy | — | **Untested** |
| `UTCID12` | `A` | Can connect with server; Caller is authenticated Owner of an active agency; Invalid or negative credit amount is submitted | `currentUser` = `Owner with invalid amount`, `request` = `BuyCreditRequest(agencyId, amount=100)` | VALIDATION_ERROR - 400 Credit amount must be positive | — | **Untested** |
| `UTCID13` | `A` | Can connect with server; Caller is authenticated Owner of an active agency; Invalid or negative credit amount is submitted | `currentUser` = `non-Owner Creator/Client`, `request` = `BuyCreditRequest(agencyId, amount=100)` | VALIDATION_ERROR - 400 agencyId and amount are required | — | **Untested** |
| `UTCID14` | `A` | Can connect with server; Caller is not Owner or is unauthenticated | `currentUser` = `authenticated Owner`, `request` = `BuyCreditRequest(agencyId, amount=100)` | FORBIDDEN - 403 Only Owner can purchase AI credits | — | **Untested** |
| `UTCID15` | `A` | Can connect with server; Caller is authenticated Owner of an active agency; BuyCreditRequest payload is submitted to POST /api/v1/billing/credits/buy | `currentUser` = `Owner with invalid amount`, `request` = `BuyCreditRequest(agencyId, amount=0 or -10)` | AGENCY_NOT_FOUND - 404 Target agency not found | — | **Untested** |
| `UTCID16` | `A` | Can connect with server; Caller is authenticated Owner of an active agency; BuyCreditRequest payload is submitted to POST /api/v1/billing/credits/buy | `currentUser` = `non-Owner Creator/Client`, `request` = `BuyCreditRequest(agencyId=null, amount=null)` | UnsupportedOperationException - BillingServiceImpl.buyCredit is not implemented yet | — | **Untested** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.9.5`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

# Test Specification — FR 3.9.3: View Invoice History

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.9.3` |
| **Function Name** | View Invoice History |
| **Functional Domain** | Billing |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `InvoiceHistoryService.list()` (43 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/InvoiceHistoryServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | List agency billing orders with cursor pagination, status/kind/date filters, invoice detail, and verified receipt text download |
| **Preconditions** | Can connect with server; Caller is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has billing orders in billing_orders (FULFILLED, PENDING_PAYMENT, EXPIRED, REVIEW_REQUIRED) | `agencyId` = `own agency UUID with orders`, `queryParams` = `list(limit=20, status=null, kind=null)` | 200 OK - InvoiceHistoryResponse(items, nextCursor) returned in descending createdAt order | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has billing orders in billing_orders (FULFILLED, PENDING_PAYMENT, EXPIRED, REVIEW_REQUIRED) | `agencyId` = `own agency UUID with orders`, `queryParams` = `list(status='FULFILLED', kind='SUBSCRIPTION', from, to)` | 200 OK - Filtered list by status=FULFILLED, kind=SUBSCRIPTION, and [from, to] date range | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has billing orders in billing_orders (FULFILLED, PENDING_PAYMENT, EXPIRED, REVIEW_REQUIRED) | `agencyId` = `own agency UUID (detail & receipt)`, `queryParams` = `list(limit=20, status=null, kind=null)` | 200 OK - receiptAvailable=true only when status=FULFILLED and verifiedPaymentCount==1 | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has billing orders in billing_orders (FULFILLED, PENDING_PAYMENT, EXPIRED, REVIEW_REQUIRED) | `agencyId` = `own agency UUID (detail & receipt)`, `queryParams` = `list(status='FULFILLED', kind='SUBSCRIPTION', from, to)` | 200 OK - detail() returns Detail(order, snapshot, payments, reasons) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); FULFILLED orders have a single VERIFIED payment and invoice snapshot | `agencyId` = `own agency UUID with orders`, `queryParams` = `detail(orderId) & receipt(orderId)` | 200 OK - receipt() renders UTF-8 BrandHub Payment Receipt byte[] with order & buyer info | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); FULFILLED orders have a single VERIFIED payment and invoice snapshot | `agencyId` = `own agency UUID (detail & receipt)`, `queryParams` = `detail(orderId) & receipt(orderId)` | 200 OK - Next page cursor encoded as URL-safe Base64 of createdAt\|orderId | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has billing orders in billing_orders (FULFILLED, PENDING_PAYMENT, EXPIRED, REVIEW_REQUIRED) | `agencyId` = `own agency UUID with orders`, `queryParams` = `list(limit=20, status=null, kind=null)` | 200 OK - PENDING_PAYMENT or REVIEW_REQUIRED orders have receiptAvailable=false | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has billing orders in billing_orders (FULFILLED, PENDING_PAYMENT, EXPIRED, REVIEW_REQUIRED) | `agencyId` = `own agency UUID with orders`, `queryParams` = `list(status='FULFILLED', kind='SUBSCRIPTION', from, to)` | 200 OK - Default limit=20 applied when limit parameter is null | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has 0 billing orders or pagination cursor is used | `agencyId` = `own agency UUID with 0 orders`, `queryParams` = `cursor pagination (limit=1 boundary)` | 200 OK - Agency with 0 orders returns items=[], nextCursor=null | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has 0 billing orders or pagination cursor is used | `agencyId` = `own agency UUID with 0 orders`, `queryParams` = `cursor pagination (limit=1 boundary)` | 200 OK - Boundary limit=1 and limit=100 with same-day from==to accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has billing orders in billing_orders (FULFILLED, PENDING_PAYMENT, EXPIRED, REVIEW_REQUIRED) | `agencyId` = `own agency UUID with orders`, `queryParams` = `detail(orderId) & receipt(orderId)` | 200 OK - Receipt masks buyer taxId/email when buyer snapshot fields are null | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Filter parameters (limit, status, kind, from > to, cursor) are invalid or receipt is unavailable | `agencyId` = `other agency UUID (not owner)`, `queryParams` = `list(limit=20, status=null, kind=null)` | BILLING_ORDER_NOT_FOUND - 404 Caller is not Owner or orderId not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Filter parameters (limit, status, kind, from > to, cursor) are invalid or receipt is unavailable | `agencyId` = `agency UUID with invalid filter`, `queryParams` = `list(limit=20, status=null, kind=null)` | INVALID_REQUEST - 400 limit outside [1..100], unknown status/kind, or from > to | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is null or is not the Owner of the agency | `agencyId` = `own agency UUID with orders`, `queryParams` = `list(limit=20, status=null, kind=null)` | UNAUTHORIZED - 401 Actor is null | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has billing orders in billing_orders (FULFILLED, PENDING_PAYMENT, EXPIRED, REVIEW_REQUIRED) | `agencyId` = `other agency UUID (not owner)`, `queryParams` = `limit=0 or limit=101 or from > to` | INVALID_REQUEST - 400 Malformed Base64 pagination cursor | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is authenticated Owner of the agency (store.isOwner(agencyId, actor)); Agency has billing orders in billing_orders (FULFILLED, PENDING_PAYMENT, EXPIRED, REVIEW_REQUIRED) | `agencyId` = `agency UUID with invalid filter`, `queryParams` = `invalid cursor or receipt on PENDING_PAYMENT` | BILLING_RECEIPT_UNAVAILABLE - 409 Receipt is unavailable for unfulfilled or unverified order | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.9.3`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

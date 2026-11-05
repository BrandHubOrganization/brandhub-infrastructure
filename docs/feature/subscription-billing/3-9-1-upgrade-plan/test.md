# Test Specification — FR 3.9.1: Upgrade Plan

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.9.1` |
| **Function Name** | Upgrade Plan |
| **Functional Domain** | Billing |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `AgencyBillingService.createPlusOrder()` (58 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyBillingServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Create an idempotent PENDING_PAYMENT SePay VietQR order to upgrade a FREE agency to PLUS or renew an active PLUS subscription |
| **Preconditions** | Can connect with server; Caller is Owner of agency with READY subscription |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Caller is Owner of the agency and agency_subscriptions.migration_state is READY | `action` = `UPGRADE (FREE -> PLUS)`, `idempotencyKey` = `valid UUID key-001` | 200 OK - AgencyBillingOrderResponse(planCode='PLUS', status='PENDING_PAYMENT', currency='VND') | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Caller is Owner of the agency and agency_subscriptions.migration_state is READY | `action` = `UPGRADE (FREE -> PLUS)`, `idempotencyKey` = `valid key-002 (after expired order)` | 200 OK - RENEWAL order created for active PLUS agency when no future period exists | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Caller is Owner of the agency and agency_subscriptions.migration_state is READY | `action` = `RENEWAL (active PLUS -> next period)`, `idempotencyKey` = `valid UUID key-001` | 200 OK - VietQR URL generated with SePay qrBaseUrl, merchantAccount, bankCode, amount, and BH code | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Caller is Owner of the agency and agency_subscriptions.migration_state is READY | `action` = `RENEWAL (active PLUS -> next period)`, `idempotencyKey` = `valid key-002 (after expired order)` | 200 OK - Order and PaymentAttempt saved with expiresAt = now + orderTtlMinutes | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Agency is on FREE plan (for UPGRADE) or active PLUS plan without future period (for RENEWAL) | `action` = `UPGRADE (FREE -> PLUS)`, `idempotencyKey` = `status(agencyId, user) read` | 200 OK - Idempotent replay with same Idempotency-Key and action returns existing order | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Agency is on FREE plan (for UPGRADE) or active PLUS plan without future period (for RENEWAL) | `action` = `RENEWAL (active PLUS -> next period)`, `idempotencyKey` = `status(agencyId, user) read` | 200 OK - Stale PENDING_PAYMENT order (expires_at <= now) auto-expired before creating new order | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Caller is Owner of the agency and agency_subscriptions.migration_state is READY | `action` = `UPGRADE (FREE -> PLUS)`, `idempotencyKey` = `valid UUID key-001` | 200 OK - status(agencyId, user) returns AgencyBillingStatusResponse with currentPeriod and pendingOrder | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Caller is Owner of the agency and agency_subscriptions.migration_state is READY | `action` = `UPGRADE (FREE -> PLUS)`, `idempotencyKey` = `valid key-002 (after expired order)` | 200 OK - Action parsed case-insensitively ('upgrade' -> 'UPGRADE', 'renewal' -> 'RENEWAL') | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Expired PENDING_PAYMENT order exists or matching Idempotency-Key replay is sent | `action` = `idempotent replay (same Idempotency-Key)`, `idempotencyKey` = `120-char max boundary key` | 200 OK - Idempotency-Key at exact 120-character maximum boundary accepted | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Expired PENDING_PAYMENT order exists or matching Idempotency-Key replay is sent | `action` = `idempotent replay (same Idempotency-Key)`, `idempotencyKey` = `120-char max boundary key` | 200 OK - status() auto-expires overdue pending order and transitions expired period to FREE | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Caller is Owner of the agency and agency_subscriptions.migration_state is READY | `action` = `UPGRADE (FREE -> PLUS)`, `idempotencyKey` = `status(agencyId, user) read` | 200 OK - Order code generated in canonical 'BH' + 18-hex-uppercase format | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Agency already has a live PENDING_PAYMENT order, wrong plan for action, or suspended subscription | `action` = `invalid action ('INVALID_ACTION' / blank)`, `idempotencyKey` = `valid UUID key-001` | INVALID_REQUEST - 400 Action must be UPGRADE or RENEWAL | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Agency already has a live PENDING_PAYMENT order, wrong plan for action, or suspended subscription | `action` = `UPGRADE when already on PLUS`, `idempotencyKey` = `valid UUID key-001` | BILLING_ORDER_CONFLICT - 409 Agency already on PLUS for UPGRADE, or active PENDING_PAYMENT order exists | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is not the Owner or SePay is unconfigured | `action` = `UPGRADE (FREE -> PLUS)`, `idempotencyKey` = `valid UUID key-001` | BILLING_FORBIDDEN - 403 Caller is not the Owner of the agency | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Caller is Owner of the agency and agency_subscriptions.migration_state is READY | `action` = `invalid action ('INVALID_ACTION' / blank)`, `idempotencyKey` = `reused key with different action` | BILLING_ORDER_CONFLICT - 409 Idempotency-Key reused with different action payload | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; SePayProperties is configured and active PLUS plan exists in billing_plan_versions; Caller is Owner of the agency and agency_subscriptions.migration_state is READY | `action` = `UPGRADE when already on PLUS`, `idempotencyKey` = `blank or >120-char key` | INVALID_REQUEST - 400 Idempotency-Key header is blank or exceeds 120 characters | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.9.1`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

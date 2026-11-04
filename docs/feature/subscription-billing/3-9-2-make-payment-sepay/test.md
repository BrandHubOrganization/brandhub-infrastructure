# Test Specification — FR 3.9.2: Make Payment (SePay)

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.9.2` |
| **Function Name** | Make Payment (SePay) |
| **Functional Domain** | Billing |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `AgencyBillingService.acceptWebhook()` (92 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyBillingServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Authenticate SePay Apikey webhook, verify transfer amount and BH order code, fulfill PLUS subscription period, and grant AI credits |
| **Preconditions** | Can connect with server; Valid SePay webhook API key |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header matches 'Apikey ' + webhookApiKey (constant-time MessageDigest.isEqual) | `authorization` = `Apikey ' + validWebhookApiKey`, `event` = `valid IN transfer matching BH code & amount` | 200 OK - Returns Map.of('success', true) and fulfills PENDING_PAYMENT order to FULFILLED | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header matches 'Apikey ' + webhookApiKey (constant-time MessageDigest.isEqual) | `authorization` = `Apikey ' + validWebhookApiKey`, `event` = `valid RENEWAL IN transfer matching BH code` | 200 OK - UPGRADE activates PLUS subscription period [now, now + 1 month) and sets status=ACTIVE | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header matches 'Apikey ' + webhookApiKey (constant-time MessageDigest.isEqual) | `authorization` = `apikey ' + validWebhookApiKey (case-insensitive prefix)`, `event` = `valid IN transfer matching BH code & amount` | 200 OK - RENEWAL creates FUTURE period starting at current period ends_at | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header matches 'Apikey ' + webhookApiKey (constant-time MessageDigest.isEqual) | `authorization` = `apikey ' + validWebhookApiKey (case-insensitive prefix)`, `event` = `valid RENEWAL IN transfer matching BH code` | 200 OK - BillingPeriodBenefits.grant issues PERIOD AI credits and unlocks agency storage | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; SePayProperties.webhookApiKey is configured; Matching PENDING_PAYMENT order and OPEN attempt exist for BH order code before expiresAt | `authorization` = `Apikey ' + validWebhookApiKey`, `event` = `duplicate SePayWebhookEvent.id()` | 200 OK - Verified payment row inserted in billing_payments with raw payload SHA-256 | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; SePayProperties.webhookApiKey is configured; Matching PENDING_PAYMENT order and OPEN attempt exist for BH order code before expiresAt | `authorization` = `apikey ' + validWebhookApiKey (case-insensitive prefix)`, `event` = `duplicate SePayWebhookEvent.id()` | 200 OK - Duplicate webhook event.id() ignored idempotently without double credit grant | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header matches 'Apikey ' + webhookApiKey (constant-time MessageDigest.isEqual) | `authorization` = `Apikey ' + validWebhookApiKey`, `event` = `valid IN transfer matching BH code & amount` | 200 OK - Unmatched BH order code recorded in billing_unmatched_webhooks with REVIEW_REQUIRED | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header matches 'Apikey ' + webhookApiKey (constant-time MessageDigest.isEqual) | `authorization` = `Apikey ' + validWebhookApiKey`, `event` = `valid RENEWAL IN transfer matching BH code` | 200 OK - Amount mismatch or transferType != 'IN' marks order REVIEW_REQUIRED without fulfillment | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; SePayProperties.webhookApiKey is configured; Duplicate webhook event.id() arrives or unmatched/mismatched transfer arrives for review | `authorization` = `Apikey ' + validKey (duplicate event)`, `event` = `unmatched BH code or transferType='OUT'` | 200 OK - BH order code extracted from event.content() when event.code() is null | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; SePayProperties.webhookApiKey is configured; Duplicate webhook event.id() arrives or unmatched/mismatched transfer arrives for review | `authorization` = `Apikey ' + validKey (duplicate event)`, `event` = `unmatched BH code or transferType='OUT'` | 200 OK - Transfer arriving after order expiresAt marks order REVIEW_REQUIRED ('EXPIRED_ORDER') | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header matches 'Apikey ' + webhookApiKey (constant-time MessageDigest.isEqual) | `authorization` = `Apikey ' + validWebhookApiKey`, `event` = `duplicate SePayWebhookEvent.id()` | 200 OK - Non-ISO transactionDate falls back cleanly to Instant.now(clock) | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header is missing or has wrong API key | `authorization` = `missing or wrong Apikey header`, `event` = `valid IN transfer matching BH code & amount` | UNAUTHORIZED - 401 Missing or invalid SePay Apikey Authorization header | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header is missing or has wrong API key | `authorization` = `blank webhookApiKey config`, `event` = `valid IN transfer matching BH code & amount` | BILLING_NOT_CONFIGURED - 503 SePay webhookApiKey is not configured | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Webhook payload is null or event.id() is blank | `authorization` = `Apikey ' + validWebhookApiKey`, `event` = `valid IN transfer matching BH code & amount` | UNAUTHORIZED - 401 Authorization header does not start with 'Apikey ' | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header matches 'Apikey ' + webhookApiKey (constant-time MessageDigest.isEqual) | `authorization` = `missing or wrong Apikey header`, `event` = `amount mismatch or expired order` | INVALID_REQUEST - 400 Webhook event body is null | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; SePayProperties.webhookApiKey is configured; Authorization header matches 'Apikey ' + webhookApiKey (constant-time MessageDigest.isEqual) | `authorization` = `blank webhookApiKey config`, `event` = `null event or blank event.id()` | INVALID_REQUEST - 400 Webhook event.id() is null or blank | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.9.2`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

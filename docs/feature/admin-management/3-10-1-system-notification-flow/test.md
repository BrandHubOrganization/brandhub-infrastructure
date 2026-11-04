# Test Specification — FR 3.10.1: Push Notification

> Note: This specification maps to official **FR 3.10.1 — Push Notification** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-10-1-push-notification/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.1` |
| **Function Name** | Push Notification |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `AdminNotificationService.create()` (36 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminNotificationServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Allow Admin to create and broadcast or schedule a system notification targeted by audience role or subscription tier |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 6, `Boundary (B)`: 3, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role | `title` = `Maintenance`, `content` = `Down at 22:00`, `targetAudience` = `all` | 201 Created - NotificationResponse(id, recipientCount=all active users) | Notification dispatched to all users | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role | `title` = `New feature`, `content` = `Try AI`, `targetAudience` = `plan=PRO` | 201 Created - NotificationResponse(id, recipientCount=PRO users) | Notification dispatched to PRO users | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role | `title` = `Role notice`, `content` = `Hello`, `targetAudience` = `role=AGENCY_OWNER` | 201 Created - NotificationResponse(id, recipientCount=owner count) | Notification dispatched to role | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role | `title` = `Scheduled`, `content` = `Later`, `targetAudience` = `all`, `scheduledAt` = `future datetime` | 201 Created - NotificationResponse(id, recipientCount=n), status=SCHEDULED | Notification scheduled | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role | `title` = `No match`, `content` = `Hi`, `targetAudience` = `plan=ENTERPRISE` | 201 Created - NotificationResponse(id, recipientCount=0), still created | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role | `title` = `Role no match`, `content` = `Hi`, `targetAudience` = `role=NO_USERS` | 201 Created - NotificationResponse(id, recipientCount=0), still created | — | **Passed** |
| `UTCID07` | `B` | Can connect with server; Caller has ADMIN system role | `title` = `T`, `content` = `C`, `targetAudience` = `all` | 201 Created - NotificationResponse(id, recipientCount=n), min length title and content | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; Caller has ADMIN system role | `title` = `title at max length`, `content` = `C`, `targetAudience` = `all` | 201 Created - NotificationResponse(id, recipientCount=n) | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role | `title` = `Scheduled`, `content` = `Later`, `targetAudience` = `all`, `scheduledAt` = `now + 1 minute` | 201 Created - NotificationResponse(id, recipientCount=n), status=SCHEDULED | — | **Passed** |
| `UTCID10` | `A` | Can connect with server; Caller does not have ADMIN system role | `title` = `Hello`, `content` = `Hi`, `targetAudience` = `all` | BusinessException(FORBIDDEN) - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Request has no valid JWT | `title` = `Hello`, `content` = `Hi`, `targetAudience` = `all` | BusinessException(UNAUTHORIZED) | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role | `title` = `null`, `content` = `Hi`, `targetAudience` = `all` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role | `title` = `Hello`, `content` = `empty`, `targetAudience` = `all` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller has ADMIN system role | `title` = `Hello`, `content` = `Hi`, `targetAudience` = `null` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role | `title` = `Hello`, `content` = `Hi`, `targetAudience` = `unknown audience type` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role | `title` = `Hello`, `content` = `Hi`, `targetAudience` = `all`, `scheduledAt` = `past datetime` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.1`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

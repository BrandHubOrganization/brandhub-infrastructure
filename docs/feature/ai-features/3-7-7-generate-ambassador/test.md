# Test Specification — FR 3.7.7: Generate Ambassador

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.7` |
| **Function Name** | Generate Ambassador |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `AiGenerationController.generateAmbassador()` (52 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/controller/AiGenerationControllerTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Generate and save a consistent virtual brand ambassador profile and reference portrait with atomic AI credit deduction |
| **Preconditions** | Can connect with server; Workspace has sufficient AI credits |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 6, `Boundary (B)`: 3, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Creator has enough AI credit | `description` = `young Vietnamese woman, casual style`, `style` = `realistic`, `client_id` = `client-1` | 200 - AmbassadorImageResponse(image url, s3 key) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Creator has enough AI credit | `description` = `middle-aged man, formal suit`, `client_id` = `client-1` | 200 - AmbassadorImageResponse, default style | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Creator has enough AI credit | `description` = `anime style girl`, `style` = `anime`, `client_id` = `client-1` | 200 - image stored with image_type=ambassador | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Creator has enough AI credit | `description` = `valid description`, `client_id` = `client-2` | 200 - image stored under client-2 prefix | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Creator has enough AI credit; Creator already generated an ambassador | `description` = `valid description`, `client_id` = `client-1` | 200 - new ambassador each call (new generation) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Creator has enough AI credit; Ambassador presets available | `description` = `valid description`, `client_id` = `client-1` | 200 - generate works with presets available | — | **Passed** |
| `UTCID07` | `B` | Can connect with server; Creator has enough AI credit | `description` = `1 char`, `client_id` = `client-1` | 200 - image generated for minimal description | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; Creator has enough AI credit | `description` = `max length description`, `client_id` = `client-1` | 200 - image generated at max description length | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Creator has enough AI credit | `description` = `valid description`, `client_id` = `1 char` | 200 - image generated, min client_id | — | **Passed** |
| `UTCID10` | `A` | Can connect with server; Creator has enough AI credit | `description` = `empty`, `client_id` = `client-1` | 422 Validation error (description required) | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Creator has enough AI credit | `description` = `null`, `client_id` = `client-1` | 422 Validation error (description required) | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Creator has enough AI credit | `description` = `over max length`, `client_id` = `client-1` | 422 Validation error (description too long) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Creator has enough AI credit; FLUX worker returns error | `description` = `valid description`, `client_id` = `client-1` | AmbassadorWorkerError - worker status_code, detail | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Creator has no AI credit | `description` = `valid description`, `client_id` = `client-1` | 402 INSUFFICIENT_AI_CREDIT | — | **Passed** |
| `UTCID15` | `A` | AI service is down | `description` = `valid description`, `client_id` = `client-1` | 503 AI service is unavailable | — | **Passed** |
| `UTCID16` | `A` | Request has invalid internal API key | `description` = `valid description`, `client_id` = `client-1` | 403 Forbidden (invalid internal key) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.7`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

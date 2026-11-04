# Test Specification — FR 3.8.15: Publish Threads Post

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.15` |
| **Function Name** | Publish Threads Post |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `ThreadsPublishServiceImpl.publish()` (48 LOC) |
| **Unit Test File** | `brandhub-publisher-service/src/test/java/com/brandhub/publisher/service/impl/ThreadsPublishServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Publish an approved text (<= 500 chars), image, or video post to Threads via Threads Publishing API and record permalink |
| **Preconditions** | Can connect with server; Approved post and connected Threads account |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 22** (`Passed`: 22, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 5, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID22`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult SUCCESS, platformPostId=post id (TEXT) | Successfully published to Threads | **Passed** |
| `UTCID02` | `N` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `1 jpg url`, `targetId` = `threads user 1` | PublishResult SUCCESS - IMAGE container published | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `null`, `mediaUrls` = `1 jpg url`, `targetId` = `threads user 1` | PublishResult SUCCESS - image without text | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid; Container FINISHED on 1st poll | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult SUCCESS - threads_publish called once | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid; Container FINISHED on 4th poll | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult SUCCESS - polled every 3s | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `500 chars`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult SUCCESS - text sent unchanged | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `null`, `targetId` = `threads user 1` | PublishResult SUCCESS - treated as text post | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | Rate limiter throttles to 1 call per 2s | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `501 chars with spaces`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult SUCCESS - truncated at last space + '...' | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `600 chars no spaces`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult SUCCESS - truncated to 497 chars + '...' | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `2 jpg urls`, `targetId` = `threads user 1` | PublishResult FAILED, errorCode=400, 'maximum 1 image' | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid; Container FINISHED on 10th poll | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult SUCCESS on last poll | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid; Container not FINISHED in 10 polls | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult FAILED, errorCode=TIMEOUT | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `501 chars, first space at index 10`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult FAILED, errorCode=caption_too_short_after_truncation | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `null`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult FAILED, errorCode=400, 'requires either text or an image' | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `empty`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult FAILED, errorCode=400, 'requires either text or an image' | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `null` | PublishResult FAILED, errorCode=400, 'requires a valid targetId (Threads User ID)' | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `blank spaces` | PublishResult FAILED, errorCode=400, 'requires a valid targetId (Threads User ID)' | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid; Threads returns HTTP 401 | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult FAILED, errorCode=400, 'Invalid Threads Request/Token' | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid; Threads returns HTTP 429 | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult FAILED, errorCode=429, 'Rate Limit Exceeded' | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid; Container status ERROR | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult FAILED, errorCode=500, 'Container processing failed' | — | **Passed** |
| `UTCID22` | `A` | Can connect with server; Job message delivered by RabbitMQ; Threads token valid; Token cannot be decrypted | `platform` = `THREADS`, `content` = `short text`, `mediaUrls` = `empty`, `targetId` = `threads user 1` | PublishResult FAILED, errorCode=SYSTEM_ERROR | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.15`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

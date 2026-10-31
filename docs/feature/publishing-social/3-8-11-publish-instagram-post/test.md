# Test Specification — FR 3.8.11: Publish Instagram Post

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.11` |
| **Function Name** | Publish Instagram Post |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `InstagramPublishServiceImpl.publish()` (56 LOC) |
| **Unit Test File** | `brandhub-publisher-service/src/test/java/com/brandhub/publisher/service/impl/InstagramPublishServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Publish an approved single image or carousel post to an Instagram Business account via Instagram Graph API container flow |
| **Preconditions** | Can connect with server; Approved post and connected Instagram Business account |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 20** (`Passed`: 20, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID20`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult SUCCESS, platformPostId=post id | Successfully published to Instagram | **Passed** |
| `UTCID02` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `3 jpg urls`, `targetId` = `ig user 1` | PublishResult SUCCESS - carousel parent container published | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `null`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult SUCCESS - container without caption | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container FINISHED on 1st poll | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult SUCCESS - media_publish called once | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container FINISHED on 5th poll | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult SUCCESS - polled every 3s until FINISHED | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `2200 chars`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult SUCCESS - caption sent unchanged | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `2 jpg urls`, `targetId` = `ig user 1` | PublishResult SUCCESS - 2-item carousel created | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult SUCCESS - rate limiter throttles to 1 call per 2s | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `2201 chars`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult SUCCESS - caption truncated to 2197 chars + '...' | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container FINISHED on 10th poll | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult SUCCESS - last allowed poll attempt | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container never FINISHED in 10 polls | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult FAILED, errorCode=TIMEOUT, 'did not become FINISHED within 30 seconds' | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `empty`, `targetId` = `ig user 1` | PublishResult FAILED, errorCode=VALIDATION_ERROR, 'requires at least one image' | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `null`, `targetId` = `ig user 1` | PublishResult FAILED, errorCode=VALIDATION_ERROR, 'requires at least one image' | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `null` | PublishResult FAILED, errorCode=400, 'requires a valid targetId (IG User ID)' | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `blank spaces` | PublishResult FAILED, errorCode=400, 'requires a valid targetId (IG User ID)' | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Instagram returns HTTP 401 | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult FAILED, errorCode=400, 'Invalid Instagram Request/Token' | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Instagram returns HTTP 429 | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult FAILED, errorCode=429, 'Rate Limit Exceeded' | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container status ERROR | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult FAILED, errorCode=500, 'Container processing failed with status ERROR' | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container creation returns no id | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult FAILED, errorCode=500, 'No ID returned' | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Token cannot be decrypted | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1` | PublishResult FAILED, errorCode=SYSTEM_ERROR | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.11`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

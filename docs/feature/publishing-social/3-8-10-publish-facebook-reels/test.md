# Test Specification — FR 3.8.10: Publish Facebook Reels

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.10` |
| **Function Name** | Publish Facebook Reels |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `FacebookPublishServiceImpl.publish()` (52 LOC) |
| **Unit Test File** | `brandhub-publisher-service/src/test/java/com/brandhub/publisher/service/impl/FacebookPublishServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Publish an approved 9:16 vertical short video (3-90s) to Facebook Reels via Meta two-phase Reels Publishing API |
| **Preconditions** | Can connect with server; Approved Reels video and connected Facebook Page |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | PublishResult SUCCESS - reel published via /video_reels | Successfully published to Facebook | **Passed** |
| `UTCID02` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `null`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | PublishResult SUCCESS - reel published via /video_reels without caption | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `null`, `postType` = `reel` | PublishResult SUCCESS - reel published via /video_reels on default target | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | Status tracking updated: PENDING -> IN_PROGRESS -> DONE | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | PublishResult carries platformPostId | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Task COMPLETED with targetPlatform=Facebook | `platform` = `FACEBOOK`, `postType` = `reel` | Job is queued to RabbitMQ publish queue | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | Duplicate job message with same postId discarded (Redis lock) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | Rate limiter keeps calls 2s apart | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `empty`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | PublishResult SUCCESS - reel published via /video_reels with empty caption | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `mp4 url 90s long`, `targetId` = `page 123`, `postType` = `reel` | PublishResult SUCCESS - reel at max length accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `blank spaces`, `postType` = `reel` | PublishResult SUCCESS - reel published via /video_reels - blank targetId falls back to default | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `empty`, `targetId` = `page 123`, `postType` = `reel` | PublishResult FAILED - media required for reel | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Facebook returns HTTP 401 | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | PublishResult FAILED, reason TOKEN_EXPIRED, Client must reconnect | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Facebook returns HTTP 400 | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `jpg url instead of video`, `targetId` = `page 123`, `postType` = `reel` | PublishResult FAILED with specific platform reason | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Facebook returns HTTP 429 | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | PublishResult FAILED, errorCode=429 | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Facebook returns HTTP 500 | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | PublishResult FAILED, errorCode=500 | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Account disconnected while job queued | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | Post set to FAIL, reason account disconnected, nothing published | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Token cannot be decrypted | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123`, `postType` = `reel` | PublishResult FAILED, errorCode=SYSTEM_ERROR | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.10`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

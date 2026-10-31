# Test Specification — FR 3.8.12: Publish Instagram Reels

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.12` |
| **Function Name** | Publish Instagram Reels |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `InstagramPublishServiceImpl.publish()` (54 LOC) |
| **Unit Test File** | `brandhub-publisher-service/src/test/java/com/brandhub/publisher/service/impl/InstagramPublishServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Publish an approved vertical video with cover frame and caption to Instagram Reels via Instagram Graph API |
| **Preconditions** | Can connect with server; Approved Reels video and connected Instagram Business account |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult SUCCESS via /media (media_type=REELS) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `null`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult SUCCESS without caption | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container FINISHED on 3rd poll | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult SUCCESS after polling | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | Status tracking updated PENDING -> IN_PROGRESS -> DONE | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult carries platformPostId | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Task COMPLETED with targetPlatform=Instagram | `platform` = `INSTAGRAM`, `postType` = `REELS` | Job queued to RabbitMQ publish queue | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | Duplicate message with same postId discarded (Redis lock) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | Rate limiter keeps calls 2s apart | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `2200 chars`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult SUCCESS - caption at limit | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `2201 chars`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | Caption truncated to 2197 chars + '...' | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container FINISHED on 10th poll | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult SUCCESS on last poll | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container not FINISHED in 10 polls | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult FAILED, errorCode=TIMEOUT | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `empty`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult FAILED - REELS media required | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult FAILED - unsupported media format | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `null`, `postType` = `REELS` | PublishResult FAILED, errorCode=400, requires targetId | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Instagram returns HTTP 401 | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult FAILED, reason TOKEN_EXPIRED, Client must reconnect | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Instagram returns HTTP 429 | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult FAILED, errorCode=429 | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container status ERROR | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | PublishResult FAILED, errorCode=500 | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Account disconnected while job queued | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `ig user 1`, `postType` = `REELS` | Post set to FAIL, reason account disconnected | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.12`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

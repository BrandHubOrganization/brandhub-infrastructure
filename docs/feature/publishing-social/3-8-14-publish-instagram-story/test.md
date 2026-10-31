# Test Specification — FR 3.8.13: Publish Instagram Story

> Note: This specification maps to official **FR 3.8.13 — Publish Instagram Story** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-8-13-publish-instagram-story/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.13` |
| **Function Name** | Publish Instagram Story |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `InstagramPublishServiceImpl.publish()` (48 LOC) |
| **Unit Test File** | `brandhub-publisher-service/src/test/java/com/brandhub/publisher/service/impl/InstagramPublishServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Publish an approved 9:16 image or video story to an Instagram Business Story via Instagram Graph API |
| **Preconditions** | Can connect with server; Approved story and connected Instagram Business account |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult SUCCESS via /media (media_type=STORIES) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `null`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult SUCCESS without caption | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container FINISHED on 3rd poll | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult SUCCESS after polling | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | Status tracking updated PENDING -> IN_PROGRESS -> DONE | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult carries platformPostId | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Task COMPLETED with targetPlatform=Instagram | `platform` = `INSTAGRAM`, `postType` = `STORIES` | Job queued to RabbitMQ publish queue | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | Duplicate message with same postId discarded (Redis lock) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | Rate limiter keeps calls 2s apart | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `2200 chars`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult SUCCESS - caption at limit | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `2201 chars`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | Caption truncated to 2197 chars + '...' | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container FINISHED on 10th poll | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult SUCCESS on last poll | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container not FINISHED in 10 polls | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult FAILED, errorCode=TIMEOUT | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `empty`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult FAILED - STORIES media required | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 pdf url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult FAILED - unsupported media format | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `null`, `postType` = `STORIES` | PublishResult FAILED, errorCode=400, requires targetId | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Instagram returns HTTP 401 | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult FAILED, reason TOKEN_EXPIRED, Client must reconnect | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Instagram returns HTTP 429 | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult FAILED, errorCode=429 | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Container status ERROR | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | PublishResult FAILED, errorCode=500 | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Job message delivered by RabbitMQ; Instagram token valid; Account disconnected while job queued | `platform` = `INSTAGRAM`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `ig user 1`, `postType` = `STORIES` | Post set to FAIL, reason account disconnected | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.13`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

# Test Specification — FR 3.8.8: Publish Facebook Post

> Note: This specification maps to official **FR 3.8.8 — Publish Facebook Post** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-8-8-publish-facebook-post/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.8` |
| **Function Name** | Publish Facebook Post |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `FacebookPublishServiceImpl.publish()` (58 LOC) |
| **Unit Test File** | `brandhub-publisher-service/src/test/java/com/brandhub/publisher/service/impl/FacebookPublishServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Publish an approved text, photo, or video feed post to a connected Facebook Page via Meta Graph API and record permalink |
| **Preconditions** | Can connect with server; Approved post and connected Facebook Page |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `page 123` | PublishResult SUCCESS, platformPostId=post_id (POST /123/feed) | Successfully published to Facebook | **Passed** |
| `UTCID02` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `null` | PublishResult SUCCESS - endpoint /me/feed | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 jpg url`, `targetId` = `page 123` | PublishResult SUCCESS - POST /123/photos with url+message | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `targetId` = `page 123` | PublishResult SUCCESS - POST /123/videos with file_url+description | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `1 avi url`, `targetId` = `page 123` | PublishResult SUCCESS - detected as video | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `null`, `mediaUrls` = `1 jpg url`, `targetId` = `page 123` | PublishResult SUCCESS - photo without message | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Response has post_id | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `page 123` | PublishResult SUCCESS - platformPostId=post_id preferred over id | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `mp4 url with ?token=1`, `targetId` = `page 123` | PublishResult SUCCESS - query string ignored when detecting video | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `empty`, `mediaUrls` = `empty`, `targetId` = `page 123` | PublishResult SUCCESS - message not added (empty content) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `blank spaces` | PublishResult SUCCESS - blank targetId falls back to /me | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid | `platform` = `FACEBOOK`, `content` = `caption`, `mediaUrls` = `2 urls`, `targetId` = `page 123` | PublishResult SUCCESS - only first media url used | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Rate limiter 0.5 req/s | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `page 123` | PublishResult SUCCESS - call throttled ~2s after previous call | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Facebook returns HTTP 401 | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `page 123` | PublishResult FAILED, errorCode=401, 'Invalid Facebook Token' (TOKEN_EXPIRED) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Facebook returns HTTP 400 | `platform` = `FACEBOOK`, `content` = `over-limit content`, `mediaUrls` = `empty`, `targetId` = `page 123` | PublishResult FAILED, errorCode=401, 'Invalid Facebook Token: <platform detail>' | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Facebook returns HTTP 429 | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `page 123` | PublishResult FAILED, errorCode=429, 'Rate Limit Exceeded' | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Facebook returns HTTP 500 | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `page 123` | PublishResult FAILED, errorCode=500, 'Facebook API HTTP Error' | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Response body has error object | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `page 123` | PublishResult FAILED, errorCode=500, 'Facebook API Error: <message>' | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Token cannot be decrypted | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `page 123`, `accessToken` = `corrupted ciphertext` | PublishResult FAILED, errorCode=SYSTEM_ERROR | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Job message delivered by RabbitMQ; Facebook token valid; Response has no id and no error | `platform` = `FACEBOOK`, `content` = `text only`, `mediaUrls` = `empty`, `targetId` = `page 123` | PublishResult FAILED, errorCode=UNKNOWN_ERROR | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.8`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

# Test Specification — FR 3.8.14: Publish TikTok Video

> Note: This specification maps to official **FR 3.8.14 — Publish TikTok Video** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-8-14-publish-tiktok-video/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.14` |
| **Function Name** | Publish TikTok Video |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `TikTokPublishServiceImpl.publish()` (56 LOC) |
| **Unit Test File** | `brandhub-publisher-service/src/test/java/com/brandhub/publisher/service/impl/TikTokPublishServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Publish an approved vertical video with privacy and interaction settings to TikTok via TikTok Content Posting API v2 |
| **Preconditions** | Can connect with server; Approved video and connected TikTok account |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 20** (`Passed`: 20, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID20`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | PublishResult SUCCESS, platformPostId=publish_id (direct post) | Successfully initialized Direct Post | **Passed** |
| `UTCID02` | `N` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `45` | PublishResult SUCCESS - direct post PULL_FROM_URL, PUBLIC_TO_EVERYONE | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `120` | Delegated to creatorUploadService.uploadAndPublish | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `null` | Delegated to creatorUploadService (duration defaults to Creator Upload) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `null`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | PublishResult SUCCESS - title null | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `4000 chars`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | PublishResult SUCCESS - caption sent unchanged | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | Bearer access token sent in Authorization header | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `tiktok`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | supports() returns true (case-insensitive) | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `60` | Direct post used at exactly 60s | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `61` | Delegated to creatorUploadService at 61s | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `0` | PublishResult SUCCESS - direct post used (0 <= 60) | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `4001 chars`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | Caption truncated to 4000 chars, direct post SUCCESS | Truncated caption to 4000 characters | **Passed** |
| `UTCID13` | `A` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid; TikTok returns HTTP 401 | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | PublishResult status=401, 'Invalid TikTok Token' (TOKEN_EXPIRED) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid; TikTok returns HTTP 400 | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | PublishResult status=401, 'Invalid TikTok Token' | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid; TikTok returns HTTP 429 | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | PublishResult status=429, 'Rate Limit Exceeded' | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid; TikTok returns HTTP 500 | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | PublishResult status=500, 'TikTok API HTTP Error' | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid; Response has error object | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | PublishResult status=500, 'TikTok API Error' | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid; Response has no publish_id | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `1 mp4 url`, `videoDuration` = `30` | PublishResult status=FAILED, 'Unknown error during direct post' | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `empty`, `videoDuration` = `30` | PublishResult status=SYSTEM_ERROR (no media url available) | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Job message delivered by RabbitMQ; TikTok token valid | `platform` = `TIKTOK`, `content` = `caption`, `mediaUrls` = `null`, `videoDuration` = `30` | PublishResult status=SYSTEM_ERROR (null media list) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.14`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

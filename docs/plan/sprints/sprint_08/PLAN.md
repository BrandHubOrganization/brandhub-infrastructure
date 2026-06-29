# Sprint 8 — Publisher Service

**Timeline:** Weeks 15–16 (Aug 26–Sep 8, 2026)
**Jira:** DA Sprint 8
**Phase:** Phase 4 — Social Integration & AI Pipeline
**Goal:** Build the complete publisher-service — RabbitMQ consumer, all 5 platform publish adapters, retry logic, and HTTP callback to business-service.

> **AI Parallel:** AI Iteration 2 runs concurrently this sprint (final week).

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E21 | Publisher Service Core | Phước |
| E22 | Publish Callback & Error Handling | Phước, Trung |

**Deliverables by end of Sprint 8:**
- `brandhub-publisher-service` running and consuming from RabbitMQ
- All 5 platform adapters: Facebook, Instagram, TikTok, Threads, Zalo OA
- Retry logic: 3 attempts with exponential backoff (1m, 5m, 15m)
- HTTP callback to business-service on publish success/failure
- business-service handler updates post status on callback

---

## EPIC E21 — Publisher Service Core

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E21-01 | Initialize brandhub-publisher-service project (Spring Boot 3, RabbitMQ consumer setup) | Phước (Publisher) | 🔴 Critical |
| DA-E21-02 | Implement RabbitMQ consumer: receive PublishJobMessage (postId, platform, content, mediaUrls, scheduledAt) | Phước (Publisher) | 🔴 Critical |
| DA-E21-03 | Implement Facebook publish adapter (Graph API v19: /me/feed + /me/photos) | Phước (Publisher) | 🔴 Critical |
| DA-E21-04 | Implement Instagram publish adapter (Content Publishing API: create container → publish) | Phước (Publisher) | 🔴 Critical |
| DA-E21-05 | Implement TikTok publish adapter (Content Posting API v2) | Phước (Publisher) | 🔴 Critical |
| DA-E21-06 | Implement Threads publish adapter (Threads API: create container → publish, max 500 chars) | Phước (Publisher) | 🔴 Critical |
| DA-E21-07 | Implement Zalo OA publish adapter (Article API + Photo API) | Phước (Publisher) | 🔴 Critical |

**PublishJobMessage format:**
```json
{
  "postId": "string",
  "workspaceId": "string",
  "platform": "FACEBOOK|INSTAGRAM|TIKTOK|THREADS|ZALO_OA",
  "contentText": "string",
  "mediaUrls": ["s3://..."],
  "scheduledAt": "2026-08-26T10:00:00Z",
  "encryptedToken": "base64-aes256-gcm-encrypted",
  "tokenIv": "base64-iv"
}
```

**Platform adapter specifics:**

| Platform | API | Post types | Notes |
|---|---|---|---|
| Facebook | Graph API v19 | Text, Photo, Reel/Video | `/me/feed` for text+link, `/me/photos` for image |
| Instagram | Content Publishing API | Photo, Carousel, Reel | 2-step: create container → `POST /{ig-user-id}/media_publish` |
| TikTok | Content Posting API v2 | Video only | Direct Post ≤60s, Creator Upload >60s |
| Threads | Threads API | Text, Photo | 2-step like Instagram, max 500 chars |
| Zalo OA | Zalo OA API | Article, Photo | Article API for text+image posts |

**Notes:**
- DA-E21-02: publisher-service decrypts the token using AES-256-GCM with the same key as business-service. Token key must be shared via environment variable.
- Instagram carousel: each image needs its own container first, then a carousel container.
- TikTok video: must be MP4, H.264, 1080p. For >60s use Creator Upload API which requires file upload before publishing.

---

## EPIC E22 — Publish Callback & Error Handling

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E22-01 | Implement HTTP callback to business-service after publish completes (POST /internal/posts/{id}/publish-result) | Phước (Publisher) | 🔴 Critical |
| DA-E22-02 | Implement retry logic: on failure → retry up to 3 times with exponential backoff (1m, 5m, 15m) | Phước (Publisher) | 🔴 Critical |
| DA-E22-03 | Implement business-service handler for publish callback (update post status, create notification) | Trung (Leader) | 🔴 Critical |

**Retry strategy (DA-E22-02):**
```
Attempt 1: immediate
Attempt 2: +1 minute delay
Attempt 3: +5 minutes delay
Attempt 4: +15 minutes delay (final)
After 4 failures: send to Dead Letter Queue (DLQ), callback with status=FAILED
```

**Callback payload (DA-E22-01):**
```json
{
  "postId": "string",
  "platform": "FACEBOOK",
  "status": "PUBLISHED|FAILED",
  "externalPostId": "string (if published)",
  "errorMessage": "string (if failed)",
  "publishedAt": "2026-08-26T10:01:23Z"
}
```

**business-service handler (DA-E22-03):**
- On PUBLISHED: update `posts.publishStatus[platform] = PUBLISHED`, set `publishedAt`
- On FAILED: update `posts.publishStatus[platform] = FAILED`, create notification for Account Manager

**Notes:**
- Callback endpoint `/internal/posts/{id}/publish-result` must be secured — only accept from publisher-service IP or with `X-Internal-Key` header.
- RabbitMQ DLQ: configure `x-dead-letter-exchange` on the publish queue. Admin views DLQ via RabbitMQ management UI (port 15672).

---

## Sprint 8 Checklist

- [ ] publisher-service starts, connects to RabbitMQ
- [ ] PublishJobMessage consumed from queue successfully
- [ ] Facebook text post published to test Fanpage
- [ ] Instagram photo post published (2-step container flow)
- [ ] TikTok video post published to test account
- [ ] Threads text post published
- [ ] Zalo OA article post published
- [ ] Failed publish retried 3 times with correct delays
- [ ] After all retries fail: message sent to DLQ
- [ ] HTTP callback fires to business-service on success
- [ ] HTTP callback fires to business-service on failure
- [ ] business-service updates post status on callback
- [ ] Account Manager receives notification on publish failure

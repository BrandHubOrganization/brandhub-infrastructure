# Sprint 11 — Approval Workflow & Full Publishing

**Timeline:** Weeks 21–22 (Oct 7–20, 2026)
**Jira:** DA Sprint 11
**Phase:** Phase 5 — Content Workflow & Publishing
**Goal:** Implement the multi-step approval workflow (Creator → Account Manager → Brand Client) and the full publishing pipeline (APPROVED post → RabbitMQ → publisher-service → social platform).

> **AI Parallel:** AI Iteration 4 runs concurrently this sprint.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E31 | Approval Workflow | Trung |
| E32 | Publishing System | Trung, Phước |
| E33 | Publish Error Handling | Phước, Trung |

**Deliverables by end of Sprint 11:**
- Full approval chain working: CONTENT_CREATOR submits → ACCOUNT_MANAGER reviews → BRAND_CLIENT approves → SCHEDULED
- Approved post enqueued to RabbitMQ for publishing
- All 5 platform adapters tested with real sandbox accounts
- Retry + DLQ + failure notification working end-to-end

---

## EPIC E31 — Approval Workflow

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E31-01 | Implement POST /api/v1/posts/{id}/submit (CONTENT_CREATOR submits → PENDING_REVIEW) | Trung (Leader) | 🔴 Critical |
| DA-E31-02 | Implement POST /api/v1/posts/{id}/account-review (ACCOUNT_MANAGER approves or rejects + note) | Trung (Leader) | 🔴 Critical |
| DA-E31-03 | Implement POST /api/v1/posts/{id}/client-approve (BRAND_CLIENT approves → SCHEDULED) | Trung (Leader) | 🔴 Critical |
| DA-E31-04 | Implement POST /api/v1/posts/{id}/client-reject (BRAND_CLIENT rejects + feedback) | Trung (Leader) | 🔴 Critical |

**Full status machine:**
```
DRAFT → (submit) → PENDING_REVIEW
PENDING_REVIEW → (account-review: approve) → SENT_TO_CLIENT
PENDING_REVIEW → (account-review: reject) → DRAFT (with rejectionNote)
SENT_TO_CLIENT → (client-approve) → SCHEDULED
SENT_TO_CLIENT → (client-reject) → DRAFT (with clientFeedback)
SCHEDULED → (scheduled time reached) → PUBLISHING
PUBLISHING → (publisher callback: success) → PUBLISHED
PUBLISHING → (publisher callback: failure x3) → FAILED
```

**Notes:**
- On SCHEDULED: trigger enqueue to RabbitMQ for the scheduled time.
- If scheduledAt is in the past (immediate publish): enqueue immediately.
- Notifications on each transition: notify the next actor in the chain.

---

## EPIC E32 — Publishing System

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E32-01 | Implement Smart Ingestion (package post + encrypted token + platform configs into a RabbitMQ message) | Trung (Leader) | 🔴 Critical |
| DA-E32-02 | Implement RabbitMQ consumer in publisher-service (FIFO, exactly-once, acknowledgement) | Phước (Publisher) | 🔴 Critical |
| DA-E32-03 | Implement Facebook adapter (Graph API: IMAGE post and REEL/VIDEO) | Phước (Publisher) | 🔴 Critical |
| DA-E32-04 | Implement Instagram adapter (2-step: create container → publish) | Phước (Publisher) | 🔴 Critical |
| DA-E32-05 | Implement TikTok adapter (Direct Post for video ≤60s, Creator Upload for video >60s) | Phước (Publisher) | 🔴 Critical |
| DA-E32-06 | Implement Threads adapter (2-step: create container → publish, max 500 chars) | Phước (Publisher) | 🔴 Critical |
| DA-E32-07 | Implement Zalo OA adapter | Phước (Publisher) | 🔴 Critical |
| DA-E32-08 | Implement HTTP callback → business-service after publish completes (update post status: PUBLISHED/FAILED) | Phước (Publisher) | 🔴 Critical |

**Smart Ingestion (DA-E32-01):**
- Triggered when post transitions to SCHEDULED
- For each targetPlatform: fetch encrypted social token from `social_accounts`
- Build PublishJobMessage per platform (one message per platform)
- Set RabbitMQ message `scheduledDeliveryTime` if scheduledAt is future
- Use delayed message plugin (`rabbitmq_delayed_message_exchange`) for scheduled delivery

**Exactly-once (DA-E32-02):**
- Use RabbitMQ manual acknowledgement (`basicAck` only after successful publish or DLQ)
- Store `processingPostIds` in Redis to prevent duplicate processing if consumer crashes mid-flight

---

## EPIC E33 — Publish Error Handling

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E33-01 | Implement retry logic (up to 3 attempts, exponential backoff: 30s, 60s, 120s) | Phước (Publisher) | 🔴 Critical |
| DA-E33-02 | Implement Dead Letter Queue handler (Admin can view and manually retry or discard failed posts) | Trung (Leader) | 🔴 Critical |
| DA-E33-03 | Implement failure notification (send alert to Account Manager when a post fails after all retries) | Trung (Leader) | 🔴 Critical |

**DLQ handler (DA-E33-02):**
- Admin API: `GET /api/v1/admin/dlq` — list failed messages
- Admin API: `POST /api/v1/admin/dlq/{messageId}/retry` — re-enqueue
- Admin API: `DELETE /api/v1/admin/dlq/{messageId}` — discard

**Notes:**
- E32 adapters in this sprint are the PRODUCTION-QUALITY implementations (replacing the Sprint 8 scaffolding).
- E32-03 to E32-07: test each adapter against a real sandbox developer account before marking done.

---

## Sprint 11 Checklist

- [ ] CONTENT_CREATOR submits post → status = PENDING_REVIEW, ACCOUNT_MANAGER notified
- [ ] ACCOUNT_MANAGER approves → status = SENT_TO_CLIENT, BRAND_CLIENT notified
- [ ] ACCOUNT_MANAGER rejects → status = DRAFT, rejection note saved
- [ ] BRAND_CLIENT approves → status = SCHEDULED, post enqueued
- [ ] BRAND_CLIENT rejects → status = DRAFT, client feedback saved
- [ ] Scheduled post: enqueued with delayed delivery time
- [ ] Immediate post: enqueued and published within 30 seconds
- [ ] Facebook IMAGE post published to sandbox Fanpage
- [ ] Instagram PHOTO post published (2-step container)
- [ ] TikTok video published (Direct Post ≤60s)
- [ ] Threads text post published
- [ ] Zalo OA article published
- [ ] Failed publish: retried 3x with 30s/60s/120s delays
- [ ] After all retries: message in DLQ, Account Manager notified
- [ ] Admin can view DLQ, retry, or discard messages

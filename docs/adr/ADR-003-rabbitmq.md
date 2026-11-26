# ADR-003 — RabbitMQ Direct & Tiered TTL-Retry Topology for Social Publishing

> Navigation: [← Knowledge Base Hub](../index.md) · [← ADR Index](./README.md) · [RabbitMQ Contract](/view?file=architecture/rabbitmq-publisher-contract.html) · [Service Boundaries](../architecture/service-boundaries.md) · [Sequence Diagrams](../architecture/sequence-diagrams.md)

- **Status:** Accepted
- **Owners:** Core Backend & Social Integration Leads
- **Related Docs:** [Social Platforms API Specs](/view?file=architecture/social-platforms-api-specs.html) · [BA Publishing & Social](../ba/07-publishing-social.md)

---

## 1. Context & Problem Statement

Once a `Task` passes BrandHub's 3-tier approval sequence (`Creator -> Manager -> Client`, `FR 3.6.9`) and reaches either immediate publish (`FR 3.8.6`) or its scheduled timestamp (`FR 3.8.5`), the platform publishes content to **strictly 4 supported social platforms**:
- **Facebook** (`FR 3.8.8` Page Post, `FR 3.8.9` Story, `FR 3.8.10` Reels — Meta Graph API `v19.0`)
- **Instagram** (`FR 3.8.11` Post/Carousel, `FR 3.8.12` Reels, `FR 3.8.13` Story — two-step Container Creation + Status Polling + Publish API)
- **TikTok** (`FR 3.8.14` Video — Content Posting API v2 chunked upload & async transcode polling)
- **Threads** (`FR 3.8.15` Post — Threads Publishing container API)

External platform APIs exhibit wide latency variance (`2`–`60+` seconds while Instagram/TikTok transcode video containers), strict per-app/per-account rate limits, and transient `5xx` outages. Blocking `brandhub-business-service` Tomcat threads on synchronous HTTP calls would exhaust connection pools during scheduled campaign bursts (e.g., `09:00` or `20:00` prime-time slots).

---

## 2. Evaluated Options

| Option | Pros | Cons / Why Rejected or Selected |
| :--- | :--- | :--- |
| **Option A: Synchronous REST (`business-service` → `publisher-service`)** | Immediate HTTP status return | Blocks servlet threads up to 60s+ per video post; loses in-flight jobs if `publisher-service` restarts; no native backoff isolation |
| **Option B: MongoDB Polling Queue (`posts.status = SCHEDULED`)** | Zero extra broker container | High polling read load; awkward multi-platform fan-out when one post targets 3 channels with independent retry schedules |
| **Option C: Apache Kafka** | High-throughput log replay | Heavy JVM/KRaft memory footprint (`> 1 GiB` RAM) disproportionate for `core` EC2 (`m7i-flex.large`, `8 GiB` total); lacks native per-message TTL delay queues |
| **Option D: RabbitMQ 3.12 Direct + Dead-Letter TTL Retry Topology** *(Selected)* | Lightweight (`512m` RAM cap in prod), manual `ACK`/`NACK`, zero-code broker-enforced TTL delay queues (`1m`/`5m`/`15m`) + DLQ | Requires idempotency locks (`Redis`) in the consumer to prevent duplicate posts on redelivery |

---

## 3. Decision Architecture

Decouple `brandhub-business-service` (`:8081`) and `brandhub-publisher-service` (`:8083`) via **RabbitMQ 3.12** (`rabbitmq:3.12-management-alpine`), paired with **Redis** per-(post, platform) idempotency locks and authenticated internal status callbacks:

```text
brandhub-business-service (Scheduler / PostController.publish)
  │  Fan-out: 1 PublishJobMessage per target platform (AES-256 encrypted OAuth token + S3 media URLs)
  ▼
DirectExchange: publisher.job.exchange  ──(publisher.job.routing-key)──►  Queue: publisher.job.queue (durable, manual ACK)
                                                                                 │
                                                                                 ▼
                                                            brandhub-publisher-service (PublishJobConsumer)
                                                              ├─ 1. Acquire Redis lock: processingPostIds:{postId}:{platform} (TTL 30m)
                                                              ├─ 2. Decrypt token in memory (CryptoUtils AES-256-GCM / AES)
                                                              ├─ 3. Dispatch to SocialPublishAdapter (Facebook | Instagram | TikTok | Threads)
                                                              ├─ 4a. Success ──► basicAck + report DONE (platformPostId, permalink) to Business
                                                              ├─ 4b. Retryable error (attempt 1..3) ──► DirectExchange: publisher.retry.exchange
                                                              │        ├── publish.jobs.retry.1m  (TTL 60,000ms)  ─┐
                                                              │        ├── publish.jobs.retry.5m  (TTL 300,000ms) ─┼─► dead-letters back to publisher.job.exchange
                                                              │        └── publish.jobs.retry.15m (TTL 900,000ms) ─┘
                                                              └─ 4c. Non-retryable / Max retries exhausted ──► publisher.job.dlx ──► publisher.job.dlq + report FAIL
```

*(Note: RabbitMQ is also reused on `core` EC2 by `brandhub-crawl` → `brandhub-ai-service` `CrawlBatchConsumer` for asynchronous social trend batch ingestion.)*

---

## 4. Real Codebase & Infrastructure Grounding

- **Broker Configuration (`RabbitMQConfig.java` in `brandhub-publisher-service`)**:
  - Declares durable `publisher.job.queue` wired with `x-dead-letter-exchange = publisher.job.dlx` and `x-dead-letter-routing-key = publisher.job.dlq.routing-key` → durable `publisher.job.dlq`.
  - Declares `publisher.retry.exchange` bound to three durable TTL delay queues (`publish.jobs.retry.1m`, `publish.jobs.retry.5m`, `publish.jobs.retry.15m`) whose expired messages automatically route back to `publisher.job.exchange` with incremented `x-retry-count` headers.
  - Maps producer DTO type `com.brandhub.business.dto.message.PublishJobMessage` cleanly to consumer `com.brandhub.publisher.core.dto.PublishJobMessage` via `Jackson2JsonMessageConverter` + `DefaultClassMapper`.
- **Idempotent Consumer & 4 Social Adapters (`PublishJobConsumer.java`)**:
  - Uses `acknowledge-mode: manual` (`spring.rabbitmq.listener.simple.retry.enabled: false`) so retry cadence is controlled deterministically by `ErrorClassifier` and the TTL delay queues.
  - Acquires a per-(post, platform) Redis lock `processingPostIds:{postId}:{platform}` (`Duration.ofMinutes(30)`) so multi-platform fan-out jobs for the same post execute concurrently while duplicate redeliveries for the same platform are suppressed.
  - Routes execution to `FacebookPublishAdapter`, `InstagramPublishAdapter`, `TikTokPublishAdapter`, or `ThreadsPublishAdapter` (`SocialPlatform` enum).
- **Proactive OAuth Token Refresh (`TokenRefreshScheduler` & `SocialOAuthController`)**:
  - `brandhub-publisher-service` runs a daily `02:00` cron (`TOKEN_REFRESH_CRON="0 0 2 * * ?"`, `threshold-days: 7`) querying `GET /api/v1/internal/social-accounts/expiring` on `business-service`, refreshing expiring Meta/TikTok/Threads tokens, and syncing encrypted tokens back via `POST /api/v1/internal/social-accounts/sync` (`X-Internal-Key`).

---

## 5. Trade-offs & Operational Impact

### Positive Outcomes
- **Zero HTTP Thread Starvation**: `business-service` enqueues `PublishJobMessage` in `< 5 ms` regardless of Instagram/TikTok video container processing times.
- **Per-Platform Fault Isolation**: If TikTok's API returns `503` while Facebook succeeds for the same multi-channel campaign post, only the TikTok job enters `publish.jobs.retry.1m` -> `5m` -> `15m` without re-publishing to Facebook.
- **Stateless Database Boundary**: `publisher-service` requires zero credentials to PostgreSQL or business MongoDB collections (owning only `publish_logs`).

### Accepted Costs & Mitigations
- **Eventual UI Status (`PENDING` / `IN_PROGRESS` → `PUBLISHED` / `FAILED`)**: Users observe asynchronous status transitions (`FR 3.8.7 Track Post Status`) and receive real-time in-app notifications (`user_notifications` STOMP push) when publishing completes or exhausts retries.
- **DLQ Monitoring**: Poison or permanently rejected payloads accumulate in `publisher.job.dlq` and are surfaced through `Admin` System Health Monitoring (`FR 3.10.3`).

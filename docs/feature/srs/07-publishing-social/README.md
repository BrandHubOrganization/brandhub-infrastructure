# 3.8 Publishing & Social (15 FRs)

> **Navigation:** [← Feature Master Index](../../README.md) · [← SRS 141 FRs Index](../README.md) · [BA Domain Spec](../../../ba/07-publishing-social.md) · [Extension Modules](../../modules/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Canonical business specification, technical implementation plan, sequential task checklist, and verification suite for **3.8 Publishing & Social** (`3.8.1 – 3.8.15`, **15 Atomic CRUD Functional Requirements** across `UC-107` to `UC-121`).

## Architectural Overview

- **Supported Social Platforms (Strictly 4):** **Facebook**, **Instagram**, **TikTok**, and **Threads** (Meta Graph API `v19.0`, TikTok Content Posting API v2 with OAuth 2.0 PKCE, and Threads Graph API `v1.0`).
- **Services:** `brandhub-business-service` (`PostController`, `SocialAccountController`, `PostTemplateController`, `InternalPostController`) + `brandhub-publisher-service` (`SocialOAuthController`, `PublishJobConsumer`, `FacebookPublishServiceImpl`, `InstagramPublishServiceImpl`, `TikTokPublishServiceImpl`, `ThreadsPublishServiceImpl`, `TokenRefreshScheduler`).
- **Messaging, Locking & Persistence:** RabbitMQ exchange `publisher.job.exchange` -> queue `publisher.job.queue` (`brandhub.publishing` domain), tiered TTL retry queues (`publish.jobs.retry.1m`, `publish.jobs.retry.5m`, `publish.jobs.retry.15m` via `publisher.retry.exchange`) + DLQ (`publisher.job.dlx` -> `publisher.job.dlq`), Redis per-platform idempotency lock `processingPostIds:{postId}:{platform}` (`30m` TTL), and MongoDB `social_accounts` (`SocialAccountDocument` with AES-256-GCM `CryptoUtils` token encryption) & `posts` (`PostDocument`).
- **Related Platform Module:** [`social-publisher-resilience`](../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md).

## Functional Requirements Matrix

| FR ID | UC ID | Function Name | Canonical Roles | Feature Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- | :--- |
| `3.8.1` | `UC-107` | **Connect Social Account** | `Owner, Manager, Client` | [Spec](./3-8-1-connect-social-account/spec.md) · [Plan](./3-8-1-connect-social-account/plan.md) · [Task](./3-8-1-connect-social-account/task.md) · [Test](./3-8-1-connect-social-account/test.md) |
| `3.8.2` | `UC-108` | **Disconnect Account** | `Owner, Manager, Client` | [Spec](./3-8-2-disconnect-account/spec.md) · [Plan](./3-8-2-disconnect-account/plan.md) · [Task](./3-8-2-disconnect-account/task.md) · [Test](./3-8-2-disconnect-account/test.md) |
| `3.8.3` | `UC-109` | **View Dashboard Post** | `Owner, Manager, Creator, Client` | [Spec](./3-8-3-view-dashboard-post/spec.md) · [Plan](./3-8-3-view-dashboard-post/plan.md) · [Task](./3-8-3-view-dashboard-post/task.md) · [Test](./3-8-3-view-dashboard-post/test.md) |
| `3.8.4` | `UC-110` | **View Posted Detail** | `Owner, Manager, Creator, Client` | [Spec](./3-8-4-view-posted-detail/spec.md) · [Plan](./3-8-4-view-posted-detail/plan.md) · [Task](./3-8-4-view-posted-detail/task.md) · [Test](./3-8-4-view-posted-detail/test.md) |
| `3.8.5` | `UC-111` | **Preview Post** | `Owner, Manager, Creator, Client` | [Spec](./3-8-5-preview-post/spec.md) · [Plan](./3-8-5-preview-post/plan.md) · [Task](./3-8-5-preview-post/task.md) · [Test](./3-8-5-preview-post/test.md) |
| `3.8.6` | `UC-112` | **Schedule Platform Post** | `Owner, Manager, Creator` | [Spec](./3-8-6-schedule-platform-post/spec.md) · [Plan](./3-8-6-schedule-platform-post/plan.md) · [Task](./3-8-6-schedule-platform-post/task.md) · [Test](./3-8-6-schedule-platform-post/test.md) |
| `3.8.7` | `UC-113` | **Track Post Status** | `Owner, Manager, Creator, Client` | [Spec](./3-8-7-track-post-status/spec.md) · [Plan](./3-8-7-track-post-status/plan.md) · [Task](./3-8-7-track-post-status/task.md) · [Test](./3-8-7-track-post-status/test.md) |
| `3.8.8` | `UC-114` | **Publish Facebook Post** | `Owner, Manager, Creator` | [Spec](./3-8-8-publish-facebook-post/spec.md) · [Plan](./3-8-8-publish-facebook-post/plan.md) · [Task](./3-8-8-publish-facebook-post/task.md) · [Test](./3-8-8-publish-facebook-post/test.md) |
| `3.8.9` | `UC-115` | **Publish Facebook Story** | `Owner, Manager, Creator` | [Spec](./3-8-9-publish-facebook-story/spec.md) · [Plan](./3-8-9-publish-facebook-story/plan.md) · [Task](./3-8-9-publish-facebook-story/task.md) · [Test](./3-8-9-publish-facebook-story/test.md) |
| `3.8.10` | `UC-116` | **Publish Facebook Reels** | `Owner, Manager, Creator` | [Spec](./3-8-10-publish-facebook-reels/spec.md) · [Plan](./3-8-10-publish-facebook-reels/plan.md) · [Task](./3-8-10-publish-facebook-reels/task.md) · [Test](./3-8-10-publish-facebook-reels/test.md) |
| `3.8.11` | `UC-117` | **Publish Instagram Post** | `Owner, Manager, Creator` | [Spec](./3-8-11-publish-instagram-post/spec.md) · [Plan](./3-8-11-publish-instagram-post/plan.md) · [Task](./3-8-11-publish-instagram-post/task.md) · [Test](./3-8-11-publish-instagram-post/test.md) |
| `3.8.12` | `UC-118` | **Publish Instagram Reels** | `Owner, Manager, Creator` | [Spec](./3-8-12-publish-instagram-reels/spec.md) · [Plan](./3-8-12-publish-instagram-reels/plan.md) · [Task](./3-8-12-publish-instagram-reels/task.md) · [Test](./3-8-12-publish-instagram-reels/test.md) |
| `3.8.13` | `UC-119` | **Publish Instagram Story** | `Owner, Manager, Creator` | [Spec](./3-8-13-publish-instagram-story/spec.md) · [Plan](./3-8-13-publish-instagram-story/plan.md) · [Task](./3-8-13-publish-instagram-story/task.md) · [Test](./3-8-13-publish-instagram-story/test.md) |
| `3.8.14` | `UC-120` | **Publish TikTok Video** | `Owner, Manager, Creator` | [Spec](./3-8-14-publish-tiktok-video/spec.md) · [Plan](./3-8-14-publish-tiktok-video/plan.md) · [Task](./3-8-14-publish-tiktok-video/task.md) · [Test](./3-8-14-publish-tiktok-video/test.md) |
| `3.8.15` | `UC-121` | **Publish Threads Post** | `Owner, Manager, Creator` | [Spec](./3-8-15-publish-threads-post/spec.md) · [Plan](./3-8-15-publish-threads-post/plan.md) · [Task](./3-8-15-publish-threads-post/task.md) · [Test](./3-8-15-publish-threads-post/test.md) |

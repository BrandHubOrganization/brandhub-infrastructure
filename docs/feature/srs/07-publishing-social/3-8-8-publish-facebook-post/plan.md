> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.8.8: Publish Facebook Post (`UC-114`)

## 1. Architectural Scope & Touched Repositories

Implements **FR 3.8.8 — Publish Facebook Post** ([spec.md](./spec.md)) for canonical roles `Owner, Manager, Creator` across the BrandHub social publishing architecture:

| Layer / Repository | Concrete Classes, Queues & Files |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `InboundSecurityWebFilter.java`, `JwtAuthFilterGatewayFilterFactory.java`, OAuth callback & `/api/v1/social/**` / `/api/v1/workspaces/**` routing |
| **Business Service (`brandhub-business-service`)** | `PostController.java`, `SocialAccountController.java`, `TaskPostController.java`, `InternalPostController.java`, `PostService.java`, `PostPublishService.java`, `SocialAccountService.java`, `RabbitMQConfig.java` |
| **Publisher Service (`brandhub-publisher-service`)** | `SocialOAuthController.java`, `PublishJobConsumer.java`, `RabbitMQConfig.java`, `CryptoUtils.java`, `FacebookPublishServiceImpl.java`, `InstagramPublishServiceImpl.java`, `TikTokPublishServiceImpl.java`, `TikTokCreatorUploadService.java`, `ThreadsPublishServiceImpl.java`, `TokenRefreshScheduler.java` |
| **Data, Cache & Broker Layer** | MongoDB `social_accounts` (`SocialAccountDocument`), MongoDB `posts` (`PostDocument`), Redis lock `processingPostIds:{postId}:{platform}` (`TTL = 30m`), RabbitMQ `publisher.job.exchange` -> `publisher.job.queue` + `publish.jobs.retry.1m/5m/15m` + `publisher.job.dlq`, PostgreSQL `user_notifications` |
| **Web Application (`brandhub-web`)** | `pages/editor/index.tsx`, `FacebookMockup.tsx`, `EditorHeaderActions.tsx` |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/more/PostDashboardScreen.tsx`, `src/screens/content/PostDetailScreen.tsx` |
| **i18n Locale Bundles** | Web: `editor.publish.facebookFeed.*`, `posts.platform.facebook` in `vi.json` & `en.json`; Mobile: `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (`tr()`) |

## 2. Persistence, Token Cryptography & Messaging Topology

1. **MongoDB Document Schemas:**
   - `social_accounts` (`SocialAccountDocument`): Indexed by `{workspaceId, platform, platformAccountId}`; stores AES-256-GCM encrypted token ciphertext (`CryptoUtils`), `tokenExpiresAt`, `status` (`CONNECTED`, `TOKEN_EXPIRED`, `DISCONNECTED`), and display profile snapshot.
   - `posts` (`PostDocument`): Indexed by `{workspaceId, status, scheduledAt}` and `{workspaceId, taskId}`; stores caption, hashtags, media references, `scheduledAt`, aggregate status, and per-platform `PlatformDeliveryTarget` subdocuments (`placement`, `status`, `externalPostId`, `permalinkUrl`, `retryCount`, `lastError`).
2. **RabbitMQ Resilient Delivery (`brandhub.publishing`):**
   - Primary exchange `publisher.job.exchange` routes `PublishJobMessage` to durable queue `publisher.job.queue` (`DefaultClassMapper` maps `com.brandhub.business.dto.message.PublishJobMessage` cleanly to `com.brandhub.publisher.core.dto.PublishJobMessage`).
   - Transient upstream `429/5xx` errors publish with incremented `x-retry-count` to `publisher.retry.exchange` -> `publish.jobs.retry.1m` (`60,000 ms`), `publish.jobs.retry.5m` (`300,000 ms`), `publish.jobs.retry.15m` (`900,000 ms`), dead-lettering back to `publisher.job.exchange`, and finally `publisher.job.dlx` -> `publisher.job.dlq` on permanent failure or retry exhaustion.

## 3. End-to-End Execution Flow

1. **Actor Trigger:** Authenticated user (`Owner, Manager, Creator`) invokes `Publish Facebook Post` on Web or Mobile.
2. **Authorization & Validation:** `brandhub-business-service` (or `SocialOAuthController` delegating to `/api/v1/internal/social-accounts/authorize-connect`) verifies `Owner, Manager, Creator` membership in `workspaceId` and validates platform/media/schedule rules (`BR-20, BR-57, BR-59`).
3. **Synchronous Query or Async Broker Fan-Out:** Read/preview/OAuth actions complete synchronously with `ApiResponse<T>`; publish/schedule actions persist `PostDocument` state, dispatch per-platform `PublishJobMessage` to RabbitMQ, acquire Redis `processingPostIds:{postId}:{platform}`, invoke Meta/TikTok/Threads HTTPS APIs, and callback `InternalPostController` (`X-Internal-Service-Key`).
4. **Client State Update:** `TanStack Query` refreshes post/account views and PostgreSQL `LISTEN/NOTIFY` delivers realtime `user_notifications` upon completion or failure.

## 4. Sequential Build Order

1. **Step 1 — Contracts & MongoDB Indexes:** Verify `SocialAccountDocument` / `PostDocument` indexes, DTO validation annotations, and `PublishJobMessage` Jackson type mappings.
2. **Step 2 — Publisher Adapter / OAuth Service:** Implement & unit-test provider HTTP interactions (`RestClient` / `WebClient`), PKCE/state validation, `CryptoUtils` AES-256-GCM encryption, and `ErrorClassifier` retry vs permanent failure rules.
3. **Step 3 — Business Service Controllers & Callbacks:** Wire `PostController`, `SocialAccountController`, and `InternalPostController` with `@RequireRole` and `X-Internal-Service-Key` guards.
4. **Step 4 — Web & Mobile UI:** Build/wire `pages/editor/index.tsx`, `FacebookMockup.tsx`, `EditorHeaderActions.tsx` and `src/screens/more/PostDashboardScreen.tsx`, `src/screens/content/PostDetailScreen.tsx` with loading/empty/error states and platform-accurate mockups.
5. **Step 5 — i18n (`vi.json` + `en.json`) & Light/Dark Theme:** Synchronize `editor.publish.facebookFeed.*`, `posts.platform.facebook` in `vi.json` & `en.json` and verify Light/Dark semantic tokens across `375px / 768px / 1440px`.
6. **Step 6 — Verification:** Execute JUnit 5 MockMvc/WireMock tests, RabbitMQ/Redis consumer tests, Jest mobile tests, and Playwright E2E checks ([test.md](./test.md)).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & API Envelope Contract

- **Standardized `ApiResponse<T>` Contract:** All JSON endpoints return `{ "success": boolean, "data": T, "error": { "code", "message" } | null, "requestId": string }` with deterministic HTTP status mapping (`200/201/204` success; `400` validation; `401` unauthenticated; `402` insufficient credit; `403` role/tenant forbidden; `404` scoped not found; `409` version/idempotency conflict; `429` rate limit; `503` upstream unavailable).
- **Key-Parallel i18n Synchronization:** All UI strings are added simultaneously in `vi.json` and `en.json` on `brandhub-web` and mirrored via `tr()` (`src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json`) on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
- **Semantic Light & Dark Mode Styling:** Web components use CSS custom properties and Tailwind `dark:` variants; Mobile screens use `useAppPreferences().palette` (`src/theme/tokens.ts`), maintaining WCAG AA contrast across Light and Dark modes.

## 6. Engineering Risks & Mitigations

- **Duplicate Social Posts on Broker Redelivery:** Mitigated by per-`(postId, platform)` Redis `SETNX` lock (`processingPostIds:{postId}:{platform}`) and idempotent status checks before calling external APIs.
- **Client Media Stream Aborts (`Broken pipe` / `AsyncRequestNotUsableException`):** Handled gracefully as client disconnect debug events without polluting `500` alerting (see `social-publisher-resilience`).
- **OAuth Token Expiry Before Scheduled Time:** Mitigated by `TokenRefreshScheduler` refreshing tokens expiring within `7` days and surfacing proactive reconnect banners.

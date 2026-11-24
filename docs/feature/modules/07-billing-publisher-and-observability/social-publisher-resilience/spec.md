> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# RabbitMQ Publisher Message Type Compatibility & Graceful Media Stream Disconnect Handling

| Field | Value |
| :--- | :--- |
| **Module Slug** | `social-publisher-resilience` |
| **Category** | `07-billing-publisher-and-observability` — Billing Verification, Publisher Resilience & System Health Observability |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Consolidated Feature Scopes** | `publisher-message-type-compatibility`, `media-disconnect-handling` |
| **Aligned SRS Domains** | [3.8 Publishing & Social](../../../srs/07-publishing-social/README.md) (`3.8.4`, `3.8.7–3.8.15`) · [FR 3.7.12 — Export File](../../../srs/06-ai-features/3-7-12-export-file/spec.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Harden cross-service messaging and media streaming resilience across `brandhub-business-service` and `brandhub-publisher-service`: ensuring zero-downtime **Jackson `__TypeId__` RabbitMQ deserialization compatibility** (`publisher-message-type-compatibility`) between producer and consumer DTO packages, and handling **abrupt browser/mobile media stream disconnects** (`media-disconnect-handling`) cleanly without false `500` alerts or converter exceptions.

## 2. User Stories

- As an `Owner`, `Manager`, or `Creator` publishing posts, I want RabbitMQ `PublishJobMessage` payloads emitted by `business-service` to deserialize reliably in `publisher-service` across rolling deployments without poison-message loops.
- As any user scrubbing or closing HTML5/native video previews, I want aborted HTTP range streams (`Broken pipe` / `ClientAbortException` / `AsyncRequestNotUsableException`) handled quietly without corrupting server error metrics.

## 3. Consolidated Acceptance Criteria

1. **Cross-Service RabbitMQ `__TypeId__` Mapping (`publisher-message-type-compatibility`):** `com.brandhub.publisher.common.config.RabbitMQConfig.jsonMessageConverter()` configures `DefaultClassMapper` + `Jackson2JsonMessageConverter` mapping producer header `com.brandhub.business.dto.message.PublishJobMessage` (and legacy/fallback empty type headers) directly to `com.brandhub.publisher.core.dto.PublishJobMessage`, ignoring unknown forward-compatible fields (`FAIL_ON_UNKNOWN_PROPERTIES = false`).
2. **Dual Token Field Compatibility in `PublishJobConsumer`:** Normalizes `accessToken` <-> `encryptedToken` fields on arrival and rejects malformed payloads lacking `postId`/`jobId` via `basicNack(requeue=false)` + `AmqpRejectAndDontRequeueException` so poison messages route cleanly to `publisher.job.dlq` instead of spinning CPU.
3. **Graceful Media Streaming Client Disconnect (`media-disconnect-handling`):** Global exception handling in `brandhub-business-service` detects client-initiated socket closes (`AsyncRequestNotUsableException`, `ClientAbortException`, `EOFException` / `Broken pipe` on `/repository-media`, `/videos/{jobId}/content`, `/attachments/{id}/content`), suppresses JSON `ApiResponse` write attempts onto already-committed `video/mp4` / `octet-stream` responses, and logs at `DEBUG` instead of `ERROR`.
4. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (Backend/protocol resilience module; existing localized media error banners (`common.errors.mediaLoadFailed`) in `vi.json` & `en.json` preserved) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
5. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/editor/*`, `pages/library/*`, `pages/video-space/*` HTML5 `<video>` players
- **Mobile Surfaces (`brandhub-mobile-app`):** `expo-video` players across `PostDetailScreen.tsx`, `AiVideoHistoryScreen.tsx`, `MediaLibraryScreen.tsx`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `AMQP publisher.job.exchange -> publisher.job.queue` | RabbitMQ Internal Broker | `PublishJobConsumer` + `RabbitMQConfig.jsonMessageConverter()` (`DefaultClassMapper`) |
| `GET /api/v1/repository-media & /workspaces/*/ai/videos/{jobId}/content` | Authorized Media Stream | `RepositoryEncryptedMediaController`, `AiVideoController`, `GlobalExceptionHandler` -> quiet client-abort handling |

## 6. Error Handling, Security & Edge Cases

- **Rolling Deploy New Field Added on `business-service` First:** Consumer ignores unknown JSON property safely and continues publishing.
- **Safari / iOS Range Probe Immediate Abort:** Byte-range `0-1` probe followed by socket close returns cleanly with `0` `HttpMessageNotWritableException` stack traces.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.8 Publishing & Social](../../../srs/07-publishing-social/README.md) (`3.8.4`, `3.8.7–3.8.15`) · [FR 3.7.12 — Export File](../../../srs/06-ai-features/3-7-12-export-file/spec.md)
- **BA & Architecture References:** [BA 07 Publishing & Social](../../../../ba/07-publishing-social.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).

> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · **Task** · [Test](./test.md)

# Task Checklist — FR 3.8.5: Preview Post (`UC-111`)

> Sequential implementation checklist mapped from [spec.md](./spec.md) and [plan.md](./plan.md) for canonical roles `Owner, Manager, Creator, Client`.

## 1. Contracts, Security & Persistence (Plan §1–§2)

- [x] **T01 — Validate DTOs & Platform Enum:** Enforce strict 4-platform enum (`FACEBOOK`, `INSTAGRAM`, `TIKTOK`, `THREADS`) and request constraints for `Preview Post` in `brandhub-business-service` and `brandhub-publisher-service`.
- [x] **T02 — Enforce Role & Internal Key Guards:** Configure `@RequireRole` (`Owner, Manager, Creator, Client`) on workspace endpoints and constant-time `X-Internal-Service-Key` verification on `/api/v1/internal/**` sync/status callbacks.
- [x] **T03 — Verify MongoDB & Redis State Models:** Confirm `social_accounts` / `posts` document fields, AES-256-GCM `CryptoUtils` token encryption, and `processingPostIds:{postId}:{platform}` lock TTL (`30m`).

## 2. Publisher & Business Service Logic (Plan §2–§3)

- [x] **T04 — Implement Core Business Service Workflow:** Implement `PostService` / `PostPublishService` / `SocialAccountService` validation, timezone normalization (`Asia/Ho_Chi_Minh` default), and atomic state transitions (`BR-20, BR-56`).
- [x] **T05 — Implement Publisher Provider / Queue Integration:** Wire `SocialOAuthController` / `PublishJobConsumer` / platform `SocialPublishAdapter` (`Meta v19.0`, `TikTok v2 PKCE`, `Threads v1.0`) with `DefaultClassMapper` message compatibility.
- [x] **T06 — Wire Tiered Retry, DLQ & Notifications:** Classify provider errors (`ErrorClassifier`) across `1m / 5m / 15m` TTL retry queues vs permanent `publisher.job.dlq` failure and emit `user_notifications` events.

## 3. Frontend Web & Mobile Surfaces (Plan §4)

- [x] **T07 — Integrate Web UI (`brandhub-web`):** Wire typed API client and `TanStack Query` hooks into `pages/editor/components/PlatformMockups.tsx`, `PlatformPreviewModal.tsx`, `StudioPreviewPanel.tsx`, `mockups/{FacebookMockup,InstagramMockup,TikTokMockup,ThreadsMockup,PhoneFrame,ExpandableCaption}.tsx`, `pages/content-writing/components/SocialPreview.tsx` with complete Loading, Empty, Success, and Error states.
- [x] **T08 — Integrate Mobile UI (`brandhub-mobile-app`):** Wire `src/screens/content-writing/SocialPreview.tsx` (`SocialPreview.test.tsx` verified) with role-gated navigation (`AppNavigator`, `withAccess.tsx`) and mobile OAuth/preview parity.

## 4. Internationalization (i18n) & Light/Dark Mode (Plan §5)

- [x] **T09 — Synchronize `vi.json` + `en.json` Keys:** Add key-parallel translations (`editor.preview.platforms.*`, `editor.preview.safeZoneWarning`, `editor.preview.seeMore` in `src/i18n/locales/{vi,en}/editor.json`) in `brandhub-web` and mobile `en.json` + `vi/common.json` (`tr()`) with zero hardcoded UI strings.
- [x] **T10 — Verify Light & Dark Theme Contrast:** Validate platform badges, status pills, mockup frames, and dialogs in both Light and Dark modes using semantic CSS variables and `useAppPreferences().palette`.

## 5. Observability, Accessibility & Operational Readiness

- [x] **T10a — Trace Correlation & Log Redaction:** Verify `X-Request-Id` propagates across Gateway, Business, and downstream services while redacting JWTs, OAuth tokens, webhook secrets, and API keys from logs.
- [x] **T10b — Keyboard Navigation & Responsive Layout:** Verify `Tab` focus order, `Enter`/`Escape` dialog handling, focus restoration on drawer/modal close, and zero horizontal overflow at `375px`, `768px`, and `1440px`.
- [x] **T10c — Scoped Query Cache Hygiene:** Scope all `TanStack Query` cache keys by authenticated `userId` and active `agencyId` / `workspaceId` so switching tenants never flashes stale data.
- [x] **T10d — Schema & Seed Idempotency:** Confirm database migrations and seeders run idempotently (`ON CONFLICT DO NOTHING` / `IF NOT EXISTS`) without mutating unrelated historical records.
- [x] **T10e — Duplicate-Submit & Race-Condition Guard:** Confirm UI mutation buttons disable while in-flight and backend enforces optimistic version / idempotency locks (`409` on conflict).
- [x] **T10f — ErrorCode-to-i18n Mapping:** Confirm every domain `ErrorCode` maps to a localized user-facing toast/banner in both `vi` and `en` without exposing raw stack traces.
- [x] **T10g — API Gateway Route & Rate-Limit Alignment:** Confirm route matching, timeout budget, and rate-limit replenish thresholds in `brandhub-api-gateway`.
- [x] **T10h — Documentation & SRS Traceability Sync:** Confirm 1-to-1 alignment between `spec.md`, `plan.md`, `task.md`, `test.md`, and the canonical BA baseline.

## 5. Verification & Regression Suite (Plan §6)

- [x] **T11 — Execute Backend & Publisher Unit/Integration Tests:** Pass JUnit 5 controller/service/consumer tests (`mvn test`) covering happy paths, OAuth/token errors, retry/DLQ routing, and cross-tenant isolation ([test.md](./test.md)).
- [x] **T12 — Execute Web & Mobile Quality Gates:** Pass `tsc --noEmit`, ESLint, Jest (`SocialAccountsScreen.test.tsx` / `PostDetailScreen.test.tsx` / `SocialPreview.test.tsx`), and responsive UI checks.

## 7. Lifecycle Artefact Traceability (`feature-workflow.md`)

| Workflow Stage | Artefact | Responsibility Verified |
| :--- | :--- | :--- |
| **Stage 1 — Business Specification** | [spec.md](./spec.md) | Canonical roles, acceptance criteria, API contract, i18n (`vi`/`en`) & Light/Dark rules |
| **Stage 2 — Technical Plan** | [plan.md](./plan.md) | Touched repositories/classes, schema invariants, data flow, build order & risks |
| **Stage 3 — Implementation Checklist** | `task.md` (this file) | Sequential backend, frontend, mobile, i18n, theme, and observability tasks |
| **Stage 4 — Verification Matrix** | [test.md](./test.md) | 16-case Normal/Boundary/Abnormal/Security/i18n/Theme suite & CLI commands |

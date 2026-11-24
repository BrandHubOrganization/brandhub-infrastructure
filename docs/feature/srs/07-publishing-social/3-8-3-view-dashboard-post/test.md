> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Verification & Test Suite — FR 3.8.3: View Dashboard Post (`UC-109`)

> Verification matrix covering Normal, Boundary, Abnormal/Provider Failure, Security, i18n (`vi`/`en`), and Light/Dark theme compliance for **FR 3.8.3 — View Dashboard Post** (`Owner, Manager, Creator, Client`).

## 1. Automated Verification Summary

| Suite / Repository | Test Scope | Status |
| :--- | :--- | :---: |
| **`brandhub-business-service` (JUnit 5 + MockMvc)** | `PostController`, `SocialAccountController`, `@RequireRole` (`Owner, Manager, Creator, Client`), `X-Internal-Service-Key` guard | **Passed** |
| **`brandhub-publisher-service` (JUnit 5 + WireMock)** | `SocialOAuthController`, `PublishJobConsumer`, Redis `processingPostIds` lock, `1m/5m/15m` retry & DLQ, Graph/TikTok/Threads adapters | **Passed** |
| **`brandhub-web` (TypeScript + Playwright)** | `pages/calendar/index.tsx` (`ContentCalendar.tsx`, `CalendarFilterBar.tsx`, `PlatformFilter.tsx`, `StatusFilter.tsx`), `pages/workspace/components/SocialQuickSnapshot.tsx` states, `vi.json`/`en.json` parity, Light/Dark contrast | **Passed** |
| **`brandhub-mobile-app` (Jest + RNTL)** | `src/screens/more/PostDashboardScreen.tsx`, `src/screens/calendar/CalendarScreen.tsx`, `src/services/postDashboardService.ts`, `i18nCoverage.test.ts`, `tokens.test.ts` | **Passed** |

## 2. Test Case Matrix (16 Cases)

| ID | Type | Test Case | Input / Setup | Expected Outcome | Result |
| :--- | :---: | :--- | :--- | :--- | :---: |
| `TC-3.8.3-N01` | Normal | Primary authorized workflow | Authenticated `Owner` executes `View Dashboard Post` in owned Workspace | Returns `200/201/302` per contract; MongoDB `social_accounts` / `posts` updated accurately | Pass |
| `TC-3.8.3-N02` | Normal | Co-authorized role parity | Secondary role(s) in `Owner, Manager, Creator, Client` execute workflow in same Workspace | Permitted per `10-roles-permissions-matrix.md`; audit & `requestId` recorded | Pass |
| `TC-3.8.3-N03` | Normal | Four-platform compatibility | Exercise supported target platform(s) (`FACEBOOK`, `INSTAGRAM`, `TIKTOK`, `THREADS`) | Platform-specific rules, mockups, and endpoints execute cleanly without regression | Pass |
| `TC-3.8.3-N04` | Normal | Token & secret hygiene | Inspect HTTP responses and structured logs during execution | Zero plaintext OAuth access/refresh tokens or `X-Internal-Service-Key` values exposed | Pass |
| `TC-3.8.3-N05` | Normal | UI cache & realtime update | Complete action on Web/Mobile UI | `TanStack Query` invalidates stale cache and renders updated status immediately | Pass |
| `TC-3.8.3-B01` | Boundary | Platform character & hashtag limits | Exact boundary caption (`Threads = 500`, `IG/TikTok = 2200`) and hashtag caps | Accepted at exact upper limit; `limit + 1` triggers deterministic validation warning/error | Pass |
| `TC-3.8.3-B02` | Boundary | Media count & aspect ratio bounds | `1` item (Story/Reels/TikTok), `2–10` items (FB/IG Carousel), `2–20` items (Threads) | Valid combinations pass; out-of-range counts or invalid aspect ratios rejected (`400`) | Pass |
| `TC-3.8.3-B03` | Boundary | Timezone midnight rollover | Workspace timezone `Asia/Ho_Chi_Minh` (`UTC+07:00`) at `23:55` vs `00:05` | Calendar date buckets and `scheduledAt` timestamps align identically on Web and Mobile | Pass |
| `TC-3.8.3-B04` | Boundary | Concurrent / duplicate job redelivery | Deliver identical `PublishJobMessage` twice while Redis lock `processingPostIds:{postId}:{platform}` active | Second delivery skipped/nacked safely; external social feed receives at most `1` post | Pass |
| `TC-3.8.3-A01` | Abnormal | Unauthenticated `Guest` request | Call workspace/social endpoint without valid Bearer JWT (or invalid ticket) | Rejected `401 UNAUTHORIZED` | Pass |
| `TC-3.8.3-A02` | Abnormal | Disallowed canonical role | Authenticated user outside `Owner, Manager, Creator, Client` invokes mutation | Rejected `403 FORBIDDEN` (`MSG07`); zero state mutation | Pass |
| `TC-3.8.3-A03` | Abnormal | Cross-workspace ID tampering | Authenticated user passes `workspaceId` / `postId` / `accountId` from another tenant | Rejected `403 FORBIDDEN` or `404 NOT_FOUND`; zero cross-tenant leakage | Pass |
| `TC-3.8.3-A04` | Abnormal | De-scoped platform rejection | Request specifies `zalo`, `linkedin`, or `youtube` | Rejected `400 BAD_REQUEST` (`MSG02`) enforcing strict 4-platform SRS scope | Pass |
| `TC-3.8.3-A05` | Abnormal | Upstream provider `429/5xx` vs `401` | Simulate Meta/TikTok/Threads `503` vs `190 OAuthException` | `503` routes to `publish.jobs.retry.1m/5m/15m`; `190` marks `TOKEN_EXPIRED` + routes to DLQ without retry storm | Pass |
| `TC-3.8.3-UI01` | i18n | `VI` <-> `EN` locale switching | Toggle language on `pages/calendar/index.tsx` (`ContentCalendar.tsx`, `CalendarFilterBar.tsx`, `PlatformFilter.tsx`, `StatusFilter.tsx`), `pages/workspace/components/SocialQuickSnapshot.tsx` and Mobile | All labels (`calendar.dashboard.*`, `calendar.filters.*`, `posts.status.*` in `src/i18n/locales/{vi,en}/calendar.json`) translate cleanly with zero raw keys or clipped buttons | Pass |
| `TC-3.8.3-UI02` | Theme | `Light` <-> `Dark` mode & viewports | Verify `375px`, `768px`, `1440px` in Light and Dark themes | Semantic tokens & `useAppPreferences().palette` preserve WCAG AA contrast and clean layout | Pass |

## 3. Fixture Isolation & Reproducible Verification Commands

- **Safe Isolated Execution:** Unit and integration tests run against isolated PostgreSQL/MongoDB containers and `WireMock` / `httpx` upstream mocks — zero live social feed mutations, zero real bank transfers, and zero shared-database side effects.

```powershell
# Backend & service unit/integration suites
mvn test

# AI service pytest suite (where applicable)
pytest -q

# Web frontend typecheck & lint
npx tsc --noEmit
npx eslint src

# Mobile Jest parity & i18n/theme token suite
npx jest --runInBand
```

## 4. Sign-Off Checklist

- [x] Production-verified engineering specification; verified against `PostController`, `SocialAccountController`, `SocialOAuthController`, and `PublishJobConsumer`.
- [x] Canonical roles strictly limited to `Owner, Manager, Creator, Client` and platforms strictly limited to Facebook, Instagram, TikTok, and Threads.
- [x] Key-parallel `vi.json` + `en.json` and Light/Dark theme verified across Web and Mobile.

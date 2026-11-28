> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# API Gateway JWT Verification, Header Sanitization & Rate Limiting

| Field | Value |
| :--- | :--- |
| **Module Slug** | `gateway-jwt-and-rate-limiting` |
| **Category** | `01-identity-gateway` — Identity, API Gateway & Edge Security |
| **Canonical Actors / Roles** | `Guest, Owner, Manager, Creator, Client, Admin` |
| **Consolidated Feature Scopes** | `gateway-ci-jwt`, `InboundSecurityWebFilter`, `JwtAuthFilterGatewayFilterFactory`, `RateLimitGatewayFilterFactory` |
| **Aligned SRS Domains** | [3.2 Authentication & Authorization](../../../srs/01-authentication/README.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Provide unified edge security across `brandhub-api-gateway` (Spring Cloud Gateway WebFlux): stripping spoofed internal identity headers (`InboundSecurityWebFilter`), validating HMAC-SHA256 / RSA Bearer JWTs (`JwtAuthFilterGatewayFilterFactory`), enforcing Redis token-bucket rate limits (`RateLimitGatewayFilterFactory`), injecting correlation IDs (`RequestIdWebFilter`), and ensuring deterministic CI/production secret configuration.

## 2. User Stories

- As any platform actor (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), I want every API call routed through `brandhub-api-gateway` to enforce consistent JWT authentication, anti-spoofing header hygiene, and abuse rate limiting so downstream microservices remain protected.

## 3. Consolidated Acceptance Criteria

1. **Inbound Header Sanitization (`InboundSecurityWebFilter`):** Strips caller-supplied `X-User-Id`, `X-User-Role`, `X-User-Email`, `X-Workspace-Id`, and `X-Internal-Service-Key` headers at the edge before JWT evaluation so external clients can never impersonate internal actors (`X-AI-Workspace-Id` is validated separately against DB membership in `business-service`).
2. **Stateless JWT Verification (`JwtAuthFilterGatewayFilterFactory`):** Validates signature, `exp`, `iat`, and token type (`access` vs `refresh`) on protected routes while whitelisting public endpoints (`/api/v1/auth/login`, `/register`, `/public/**`, `/api/v1/billing/webhooks/sepay`, `/api/monitoring/heartbeat`).
3. **Redis Distributed Rate Limiting (`RateLimitGatewayFilterFactory`):** Enforces per-IP and per-authenticated-user token-bucket limits on auth/OTP, AI Studio, and public share endpoints, returning `429 TOO_MANY_REQUESTS` with `Retry-After` headers when exceeded.
4. **Request Correlation & CI Deterministic Boot (`gateway-ci-jwt`, `RequestIdWebFilter`, `LoggingGlobalFilter`):** Propagates or mints `X-Request-Id` across all upstream routes (`business`, `publisher`, `ai`) and validates `JWT_SECRET` minimum entropy (`>= 256-bit`) in CI and production profiles.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`common.errors.{unauthorized,rateLimited,networkError}` in `src/i18n/locales/{vi,en}/common.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `src/services/api.ts` (`401` refresh interceptor & `429` toast handler)
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/services/api.ts` (`expo-secure-store` token refresh queue & `429` error mapping)
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `InboundSecurityWebFilter (Global Order HIGHEST)` | All Edge Traffic | `brandhub-api-gateway` -> strips forged `X-User-*` / `X-Internal-*` headers |
| `JwtAuthFilterGatewayFilterFactory` | Bearer JWT Routes | `brandhub-api-gateway` -> validates JWT & injects verified `X-User-Id` / `X-User-Role` |
| `RateLimitGatewayFilterFactory` | IP / User Bucket | `brandhub-api-gateway` + Redis -> enforces burst/replenish rate limits (`429` on overflow) |
| `RequestIdWebFilter + LoggingGlobalFilter` | All Routes | `brandhub-api-gateway` -> binds `X-Request-Id` & structured latency/status logs |

## 6. Error Handling, Security & Edge Cases

- **Redis Temporarily Unreachable:** Rate limiter fails open/bounded with circuit warning on non-auth read routes while keeping strict login/OTP brute-force protection.
- **Refresh Token Replayed as Access Token:** Rejected `401 UNAUTHORIZED` by claim-type check at the Gateway.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.2 Authentication & Authorization](../../../srs/01-authentication/README.md)
- **BA & Architecture References:** [BA 02 Authentication & Profile](../../../../ba/02-authentication-profile.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).

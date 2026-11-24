# 01-identity-gateway — Identity, API Gateway & Edge Security (2 Modules)

> **Navigation:** [← Feature Master Index](../../README.md) · [← Modules Master Index](../README.md) · [SRS 3.2 Auth](../../srs/01-authentication/README.md) · [SRS 3.3 Profile](../../srs/02-profile/README.md) · [BA Baseline](../../../ba/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Cross-cutting edge security, stateless RS256 JWT verification, inbound identity header sanitization, Redis token-bucket rate limiting, and universal user avatar/banner S3 delivery shared across all client surfaces.

---

## 1. Production Codebase & Persistence Mapping

- **Primary Services:** `brandhub-api-gateway` (`JwtAuthFilterGatewayFilterFactory`, `RateLimitGatewayFilterFactory`, `InternalHeaderSanitizerFilter`), `brandhub-business-service` (`AuthController`, `UserController`, `S3FileStorageServiceImpl`, `ImageValidator`), `brandhub-web`, and `brandhub-mobile-app`.
- **Storage & Runtime State:**
  - **PostgreSQL 17:** `users` (`avatar_url`, `banner_preset`, `banner_url`), `user_system_roles`, `user_refresh_tokens`.
  - **Redis 7.2:** `jwt:blacklist:{jti}` (revoked access-token JTIs), `ratelimit:{route}:{subject}` (Lua sliding/token-bucket counters).
  - **AWS S3 (`brandhub-media-134875421878`):** Publicly cached CDN/S3 object keys under `avatars/{userId}/*` and curated banner presets.
- **Related Canonical SRS Domains:** [01-authentication (`3.2.1`–`3.2.9`)](../../srs/01-authentication/README.md) · [02-profile (`3.3.1`–`3.3.4`)](../../srs/02-profile/README.md) · [RS256 JWT Flow](../../../api/rs256-jwt-flow.md) · [ADR-004 Spring Cloud Gateway](../../../adr/adr-004-spring-cloud-gateway.md).

---

## 2. Consolidated Modules (`2`)

| Module Slug | Scope & Engineering Title | Core Codebase Touchpoints | Lifecycle Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- |
| `gateway-jwt-and-rate-limiting` | **API Gateway JWT Verification, Header Sanitization & Rate Limiting** | `JwtAuthFilterGatewayFilterFactory`, `RateLimitGatewayFilterFactory`, `X-User-Id` / `X-User-Roles` header stripping & injection, `/ws/chat` WebSocket upgrade auth | [Spec](./gateway-jwt-and-rate-limiting/spec.md) · [Plan](./gateway-jwt-and-rate-limiting/plan.md) · [Task](./gateway-jwt-and-rate-limiting/task.md) · [Test](./gateway-jwt-and-rate-limiting/test.md) |
| `user-avatar-and-banner-presets` | **Unified People Avatars, Banner Presets & S3 Image Upload Pipeline** | `UserController`, `ImageValidator` magic-byte check, deterministic initials/gradient fallback, `ProfileBannerPicker` & S3 presigned/multipart upload | [Spec](./user-avatar-and-banner-presets/spec.md) · [Plan](./user-avatar-and-banner-presets/plan.md) · [Task](./user-avatar-and-banner-presets/task.md) · [Test](./user-avatar-and-banner-presets/test.md) |

---

## 3. Verification & Security Invariants

1. External callers can never spoof `X-User-Id`, `X-User-Email`, or `X-User-Roles`; `brandhub-api-gateway` strips inbound `X-User-*` headers before RS256 verification (`public.pem`).
2. `brandhub-business-service` exclusively holds `private.pem` for signing JWTs (`ADR-004`), while downstream services trust verified gateway headers inside the private Docker/VPC network.
3. Avatar and banner uploads enforce strict MIME + magic-byte validation (`JPEG`, `PNG`, `WEBP`) and size caps prior to S3 persistence.

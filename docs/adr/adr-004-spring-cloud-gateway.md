# ADR-004 — Spring Cloud Gateway Perimeter, RS256 Auth & Zero-Trust Re-Verification

> Navigation: [← Knowledge Base Hub](../index.md) · [← ADR Index](./README.md) · [RS256 JWT Flow](../api/rs256-jwt-flow.md) · [Redis Rate Limiting](../api/redis-rate-limiting-filter.md) · [Architecture Diagram](/view?file=architecture/architecture.html)

- **Status:** Accepted
- **Owners:** Platform Security & Core Backend Leads
- **Related Docs:** [API Response Format](../api/api-response-format.md) · [Roles & Permissions Matrix](../ba/10-roles-permissions-matrix.md) · [Wake-on-Request Runbook](../operations/wake-on-request.md)

---

## 1. Context & Problem Statement

`brandhub-web` (`https://brandhub.id.vn`) and `brandhub-mobile-app` interact with REST endpoints, multipart S3/Repository streams, public guest links (surveys, package shares, mail unsubscribe), third-party webhooks (SePay VietQR, Meta/TikTok/Threads OAuth callbacks), and dual STOMP WebSockets (`/ws/chat`, `/ws/tasks`).

Exposing `brandhub-business-service` (`:8081`), `brandhub-ai-service` (`:8082`), and `brandhub-publisher-service` (`:8083`) directly to the public internet would duplicate CORS, rate-limiting, request-correlation, and token-revocation logic across Java and Python stacks while widening the attack surface of internal `X-Internal-Key` routes. At the same time, pushing BrandHub's complex 2-tier authorization rules (`agencies.owner_id` + per-workspace `Manager`/`Creator`/`Client` membership) into an edge gateway would turn the gateway into a stateful monolith coupled to PostgreSQL.

---

## 2. Evaluated Options

| Option | Pros | Cons / Why Rejected or Selected |
| :--- | :--- | :--- |
| **Option A: Nginx Reverse Proxy Only** (All JWT, rate-limit & header logic inside each microservice) | Minimal memory overhead on `gateway` EC2 | Cannot run shared reactive Redis Lua rate limiters + `jwt:blacklist:{jti}` checks + unified `ApiResponse<T>` JSON error serialization without OpenResty/Lua custom plugins |
| **Option B: Kong / Envoy API Gateway** | High throughput C/Go proxy | Introduces a separate declarative plugin stack outside the team's Java 21 / Spring Boot 3 skillset and requires custom plugins for BrandHub's capability-IP rate limiters |
| **Option C: Spring Cloud Gateway (WebFlux / Netty) Behind Nginx TLS** *(Selected)* | Non-blocking Netty event loop fits inside `640m` RAM on `t3.small`; shares Java 21 + `ApiResponse<T>` error contracts; clean custom `WebFilter` & `GatewayFilterFactory` pipeline | Static route table in `application.yml` (acceptable for a fixed 4-service backend) |

---

## 3. Decision Architecture (Defense-in-Depth Perimeter)

Deploy **Spring Cloud Gateway** (`brandhub-api-gateway` on `:8080` behind Nginx `:80`/`:443` on `brandhub-api-gateway` EC2 `172.31.27.199`) as the sole public API ingress, paired with **asymmetric RS256 JWT verification** and **downstream Zero-Trust re-verification**:

```text
Internet Client ──HTTPS──► Nginx (:443, TLS 1.2/1.3, /edit-video/ -> 172.31.20.80:8095 + @wake_edit_video)
                             │
                             ▼
                   brandhub-api-gateway (:8080, Netty WebFlux)
                     ├─ 1. RequestIdWebFilter (HIGHEST_PRECEDENCE): validates or generates X-Request-Id
                     ├─ 2. InboundSecurityWebFilter (HIGHEST_PRECEDENCE + 1):
                     │      • Rejects path smuggling (; , .. , \, %2e%2e, %3b, %00) -> 400 INVALID_REQUEST_PATH
                     │      • Blocks external access to /api/v1/internal/**, /api/v1/test/** -> 403 FORBIDDEN
                     │      • Strips spoofed inbound X-User-Id, X-User-Role, X-Workspace-Id, X-Internal-Key
                     │      • Attaches nosniff, X-Frame-Options: DENY, Referrer-Policy, Permissions-Policy
                     ├─ 3. Route Predicates & JwtAuthFilterGatewayFilterFactory:
                     │      • Verifies RS256 signature using ONLY JWT_PUBLIC_KEY (cannot mint tokens)
                     │      • Rejects 2FA challenge tokens ("type" claim) & refresh tokens (missing "role")
                     │      • Checks reactive Redis key jwt:blacklist:{jti}
                     │      • Injects verified X-User-Id, X-User-Role, X-Workspace-Id trace headers
                     ├─ 4. RateLimitGatewayFilterFactory:
                     │      • Atomic Lua INCR + EXPIRE on ratelimit:gateway:{userId|ip}:{minute}
                     └─ 5. Forwards to VPC-private business-service (:8081) or publisher OAuth (:8083)
                             │
                             ▼
                   brandhub-business-service (:8081)
                     └─ JwtAuthenticationFilter independently re-verifies Authorization: Bearer <jwt>
                        and resolves live 2-tier RBAC (Admin / Owner / Manager / Creator / Client) from PostgreSQL
```

---

## 4. Real Codebase & Route Grounding

- **Gateway Route Classes (`brandhub-api-gateway/src/main/resources/application.yml`)**:
  - **Authenticated API routes (`/api/v1/**`, `/api/monitoring/enrollments`, `/api/monitoring/servers`)**: Protected by `JwtAuthFilter` + per-user `RateLimit` (`100` req/min default; stricter quotas for AI text/image/video and publishing).
  - **Public `Guest` & Webhook routes**: `/api/v1/auth/**` (login, register, refresh, Google OAuth), `/api/v1/public/{mail,surveys,billing/plans,media-packages}/**` (IP-scoped `RateLimit`), `POST /api/v1/billing/webhooks/sepay` (verified by SePay API key/signature inside `BillingController`), and `GET /api/v1/social/{facebook,instagram,tiktok,threads}/{authorize,callback}` (routed to `publisher-service:8083` with single-use 60s connect tickets + `bh_oauth_state` cookie).
  - **STOMP WebSocket Upgrades (`/ws/chat/**`, `/ws/tasks/**`)**: Proxied over `ws://` to `business-service:8081`, where `WsJwtHandshakeInterceptor` and `ChatInboundChannelInterceptor` authenticate the handshake/CONNECT frame (`16 KB` frame cap).
  - **Unexposed Internal Services**: `brandhub-ai-service` (`:8082`) has **zero** routes in `brandhub-api-gateway`; it is reachable solely over the private VPC (`brandhub-ai-sg`) with `X-Internal-Key`.
- **Unified Envelope on Gateway Errors (`GlobalErrorWebExceptionHandler` + `GatewayErrorResponseWriter`)**: Serializes `401`, `403`, `404`, `429`, and `503` responses in the exact same `ApiResponse<T>` JSON envelope (`success`, `data`, `error`, `requestId`, `version: "v1"`, `timestamp`) as downstream services, never echoing raw internal Java exception messages on `500`.

---

## 5. Trade-offs & Operational Impact

### Positive Outcomes
- **Compromise Containment (RS256 Public/Private Split)**: Because `brandhub-api-gateway` possesses only `JWT_PUBLIC_KEY`, a compromise of the internet-facing `gateway` EC2 cannot forge user tokens, decrypt social OAuth tokens, or read private S3 repository files.
- **Zero-Trust Defense in Depth**: Stripping `X-User-*` and `X-Internal-Key` at `InboundSecurityWebFilter` **plus** re-verifying the RS256 Bearer token inside `business-service` prevents privilege escalation even if a misconfigured route ever omits `JwtAuthFilter`.
- **Database-Free Edge Scaling**: Gateway requires only reactive Redis (`172.31.24.149:6379`) and runs comfortably within `640m` container memory on a `t3.small` instance.

### Accepted Costs & Mitigations
- **Double RSA Signature Verification**: Both `api-gateway` and `business-service` verify the RSA-2048 SHA-256 signature on authenticated requests (~`0.1 ms` CPU overhead per request — negligible compared to network/DB I/O).
- **Burstable `t3.small` CPU Credits Under Sustained High RPS**: Monitored via CloudWatch `CPUCreditBalance` and benchmarked with the 60-minute `soak` profile in `prod/loadtest/brandhub-api.k6.js`.

# API & Gateway Contracts (`docs/api/`)

> Navigation: [← Knowledge Base Hub](../index.md) · [← System Architecture](../architecture/README.md) · [Database Design →](../database/README.md) · [Business Analysis →](../ba/README.md)

Authoritative HTTP/REST, WebSocket/STOMP, RS256 authentication, Redis rate-limiting, and OpenAPI 3.1 specifications across `brandhub-api-gateway` (`:8080`), `brandhub-business-service` (`:8081`), `brandhub-ai-service` (`:8082`), and `brandhub-publisher-service` (`:8083`).

---

## 1. Contract Catalog

| Document | Service(s) | Scope & Code-Verified Highlights |
| :--- | :--- | :--- |
| [Business & Publisher Endpoint Reference](./business-service-endpoints.md) | `business-service` (`:8081`), `publisher-service` (`:8083`), `api-gateway` (`:8080`) | **Complete production REST & STOMP endpoint catalog** extracted from all `120+` Spring controllers across the **9 SRS Functional Domains (`141` FRs)**, STOMP WebSockets (`/ws/tasks`, `/ws/chat`), S3 encrypted media streaming, and 4-platform social OAuth |
| [Standard API Response Format (`ApiResponse<T>`)](./api-response-format.md) | All HTTP services | Mandatory JSON response envelope (`success`, `data`, `error`, `meta`, `requestId`, `version: "v1"`, `timestamp`), HTTP status mapping (`204` prohibited), and `97`-code `SCREAMING_SNAKE_CASE` error catalog |
| [RS256 JWT Authentication Flow](./rs256-jwt-flow.md) | `api-gateway` ↔ `business-service` | RSA-2048 private-key signing (`business-service`), public-key perimeter verification (`api-gateway`), `InboundSecurityWebFilter` header sanitization, `15m` access + `30d` HttpOnly refresh rotation, and Redis `jwt:blacklist:{jti}` revocation |
| [Redis Rate Limiting Filter](./redis-rate-limiting-filter.md) | `api-gateway` (`RateLimitGatewayFilterFactory`) | Reactive Lua `INCR` + `EXPIRE` sliding-minute limiter (`ratelimit:gateway:{userId|ip}:{minute}`), per-role `100` req/min default, route-tier limits (Auth, AI Text/Image/Video, Publish), and IP-scoped `Guest` / capability limiters |
| [OpenAPI 3.1 Spec — `business-service`](./openapi-spec-business-service.md) | `business-service` (`SpringDoc 2.6`) | Swagger UI (`http://localhost:8081/swagger-ui.html`), `/v3/api-docs.yaml`, reusable DTO components, gateway correlation headers, and validation checklist |
| [OpenAPI 3.1 Spec — `ai-service`](./openapi-spec-ai-service.md) | `ai-service` (`FastAPI`) | Complete internal OpenAPI contract (`http://localhost:8082/docs` in dev) covering all **15 v1 routers + v2 commercial image + internal routers (`68` routes)** protected by `X-Internal-Key` |

---

## 2. Gateway Perimeter Routing Summary (`application.yml`)

| Traffic Class | Gateway Route Predicate(s) | Auth & Filter Chain | Downstream Target |
| :--- | :--- | :--- | :--- |
| **Authenticated Domain API** | `/api/v1/**` *(excluding public/webhook paths below)* | `RequestIdWebFilter` → `InboundSecurityWebFilter` → `JwtAuthFilter` → `RateLimit` (`userId`) | `business-service:8081` |
| **Public Auth & Google OAuth** | `/api/v1/auth/**`, `/login/oauth2/code/google` | Public (`Guest`), auth rate limit | `business-service:8081` |
| **Public Guest Links** | `/api/v1/public/{mail,surveys,billing/plans,media-packages,images}/**` | Public (`Guest`), IP-scoped `RateLimit` (`publicIp` / `publicPackageIp`) | `business-service:8081` |
| **Encrypted Repository Media** | `/api/v1/repository-media`, `/api/v1/repository-drive/media` | Short-lived `AES-256-GCM` capability token + `capabilityIp` `RateLimit` | `business-service:8081` |
| **SePay (VietQR) Webhook** | `POST /api/v1/billing/webhooks/sepay` | Provider API key / signature check in `BillingController` | `business-service:8081` |
| **4-Platform Social OAuth** | `GET /api/v1/social/{facebook,instagram,tiktok,threads}/{authorize,callback}` | Single-use `60s` connect ticket + `bh_oauth_state` cookie + IP `RateLimit` | `publisher-service:8083` |
| **STOMP WebSockets** | `/ws/tasks/**`, `/ws/chat/**` | `WsJwtHandshakeInterceptor` / STOMP `CONNECT` JWT verification (`16 KB` frame cap) | `ws://business-service:8081` |
| **System Monitoring** | `/api/monitoring/{heartbeat,collectors/heartbeat,health-results,register,install.sh,agent.py}` (machine) & `/api/monitoring/{enrollments,servers,health-targets}` (`Admin` JWT) | Machine token or `JwtAuthFilter` + `Admin` check | `business-service:8081` |

---

## 3. Related Inter-Service Specifications

- [`business-service` ↔ `ai-service` Internal REST Contract](../architecture/business-ai-rest-contract.md)
- [`business-service` ↔ `publisher-service` RabbitMQ Contract](/view?file=architecture/rabbitmq-publisher-contract.html)
- [Redis Key Patterns (`DA-E06-06`)](../database/redis-cache/redis-key-patterns.md)

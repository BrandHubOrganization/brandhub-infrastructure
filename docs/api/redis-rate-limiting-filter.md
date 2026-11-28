# DA-E11-03 — Redis Rate Limiting Filter

> Navigation: [← Knowledge Base Hub](../index.md) · [← API Contracts Index](./README.md) · [Redis Key Patterns](../database/redis-cache/redis-key-patterns.md) · [API Response Format](./api-response-format.md) · [RS256 JWT Flow](./rs256-jwt-flow.md)

**Service:** `brandhub-api-gateway`  
**Owner:** Trung (Leader)  
**Priority:** Critical  
**Status:** Implemented in gateway layer  
**Blocked by:** DA-E11-02, [DA-E06-06](../database/redis-cache/redis-key-patterns.md)  
**Blocks:** DA-E11-04

---

## 1. Purpose

`brandhub-api-gateway` enforces a per-account sliding-minute rate limit for requests issued by signed-in system roles (`Owner`, `Manager`, `Creator`, `Client`, `Admin`) before forwarding traffic to `business-service`, and applies IP/email-scoped limits on public `Guest` authentication routes.

The default guardrail for signed-in traffic is:

```text
100 requests / minute / userId (Owner, Manager, Creator, Client, Admin)
```

Stricter route-specific limits (`AUTH_RATE_LIMIT_PER_MINUTE`, `AI_TEXT_RATE_LIMIT_PER_MINUTE`, `AI_IMAGE_RATE_LIMIT_PER_MINUTE`, `AI_VIDEO_RATE_LIMIT_PER_MINUTE`, `PUBLISH_RATE_LIMIT_PER_MINUTE`) are configured via environment variables in `docker/compose/shared/apps.yaml`.

---

## 2. Runtime Placement

The rate-limiting filter runs inside `brandhub-api-gateway` immediately after `JwtAuthFilter`:

```text
Client (Web / Mobile)
  -> api-gateway (:8080)
  -> JwtAuthFilter (RS256 verify + Redis blacklist check)
  -> RateLimit filter (Redis counter check)
  -> business-service (:8081)
```

- On protected routes (`Owner`, `Manager`, `Creator`, `Client`, `Admin`), the filter keys off `X-User-Id` extracted from the verified RS256 JWT. If `X-User-Id` is absent, the filter rejects with `401 JWT_MISSING` rather than creating a blank Redis key.
- On public `Guest` routes (`/api/v1/auth/login`, `/api/v1/auth/register`, etc.), rate limiting keys off client IP / normalized email.

---

## 3. Redis Key Contract (Aligned with `DA-E06-06`)

See [DA-E06-06 — Redis Key Patterns](../database/redis-cache/redis-key-patterns.md) for the cross-service Redis contract:

| Field | Value |
| :--- | :--- |
| **Canonical Key Template** | `ratelimit:gateway:{userId}:{minute}` (logical family `ratelimit:{scope}:{userId}:{minute}`) |
| **Example Key** | `ratelimit:gateway:9f3a6f7b-2d4a-49a8-93cc-2b8e7a8c0d11:29741760` |
| **Value Type** | Integer string |
| **Value Content** | Request count for one user inside one epoch-minute window (`epoch_seconds / 60`) |
| **TTL** | `60` seconds |
| **Writer / Reader** | `api-gateway` |

---

## 4. Atomic Redis Operation

`api-gateway` executes `INCR` and first-hit `EXPIRE` atomically (via reactive Redis / Lua script) so a counter can never persist without a TTL:

```lua
local current = redis.call('INCR', KEYS[1])
if current == 1 then
    redis.call('EXPIRE', KEYS[1], ARGV[1])
end
return current
```

---

## 5. Gateway Configuration

```yaml
gateway:
  rate-limit:
    requests-per-minute: ${RATE_LIMIT_PER_MINUTE:100}
    ttl-seconds: ${RATE_LIMIT_TTL_SECONDS:60}
    fail-open: ${RATE_LIMIT_FAIL_OPEN:true}
    auth-per-minute: ${AUTH_RATE_LIMIT_PER_MINUTE:10}
    ai-text-per-minute: ${AI_TEXT_RATE_LIMIT_PER_MINUTE:25}
    ai-image-per-minute: ${AI_IMAGE_RATE_LIMIT_PER_MINUTE:8}
    ai-video-per-minute: ${AI_VIDEO_RATE_LIMIT_PER_MINUTE:3}
    publish-per-minute: ${PUBLISH_RATE_LIMIT_PER_MINUTE:15}
```

| Property | Default | Meaning |
| :--- | :---: | :--- |
| `gateway.rate-limit.requests-per-minute` | `100` | Default maximum requests per minute per `userId` |
| `gateway.rate-limit.ttl-seconds` | `60` | Redis window key TTL in seconds |
| `gateway.rate-limit.fail-open` | `true` | Allow requests through if Redis is temporarily unreachable |

---

## 6. Success & `429` Limit Exceeded Behavior

### Within Limit
Gateway forwards the request to `business-service` and attaches quota headers:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 42
```

### Limit Exceeded (`429 Too Many Requests`)
When the counter exceeds the configured threshold, `api-gateway` short-circuits and returns the standard `ApiResponse<T>` envelope defined in [DA-E07-04](./api-response-format.md):

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please slow down.",
    "details": {
      "limit": 100,
      "windowSeconds": 60,
      "retryAfterSeconds": 30
    }
  },
  "meta": null,
  "requestId": "c9d0e1f2-a3b4-5678-cdef-789012345678",
  "version": "v1",
  "timestamp": "2026-11-01T10:30:00Z"
}
```

---

## 7. Route-Specific Thresholds

| Route Group | Applicable Roles | Configured Limit |
| :--- | :--- | :---: |
| Auth login / register / OTP (`/api/v1/auth/**`) | `Guest` (by IP / email) | `5–10` req/min |
| General Workspace / Agency CRUD | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `100` req/min |
| AI Caption / Hashtag / RAG (`/api/v1/workspaces/*/ai/**`) | `Owner`, `Manager`, `Creator`, `Client` | `20–30` req/min |
| AI Image / Virtual Ambassador | `Owner`, `Manager`, `Creator` | `5–10` req/min |
| AI Video Generation | `Owner`, `Manager`, `Creator` | `1–3` req/min |
| Social Publishing (`/api/v1/workspaces/*/publishing/**`) | `Owner`, `Manager`, `Creator` | `10–20` req/min |

# DA-E11-03 — Redis Rate Limiting Filter

**Service:** `brandhub-api-gateway`  
**Owner:** Trung (Leader)  
**Priority:** Critical  
**Status:** Implemented in gateway layer  
**Blocked by:** DA-E11-02, DA-E06-06  
**Blocks:** DA-E11-04

---

## 1. Purpose

The API Gateway enforces a default authenticated-user rate limit before forwarding traffic to downstream services. This protects `business-service`, `ai-service`, and other backend services from request bursts without requiring each service to implement its own first-line limiter.

The default rule is:

```text
100 requests / minute / authenticated user
```

This is a default gateway guardrail. Stricter route-specific limits should be added later for login/register, AI generation, upload, and publish workflows.

---

## 2. Runtime Placement

The rate limiting filter runs in `brandhub-api-gateway` after the JWT validation filter.

```text
Client
  -> api-gateway
  -> JwtAuthFilter
  -> RateLimit filter
  -> routed downstream service
```

The filter depends on `X-User-Id`, which must be injected by DA-E11-02 after JWT validation succeeds.

If `X-User-Id` is missing, the filter returns `401 JWT_MISSING` instead of creating an invalid Redis key.

---

## 3. Redis Key Contract

| Field | Value |
|---|---|
| Key template | `ratelimit:gateway:{userId}:{minute}` |
| Example | `ratelimit:gateway:user_123:29741760` |
| Value type | Integer string |
| Value content | Request count for one user inside one minute window |
| Minute value | `epoch_seconds / 60` |
| TTL | 60 seconds |
| Writer | `api-gateway` |
| Reader | `api-gateway` |

The key includes the `gateway` namespace so the gateway limiter does not collide with future service-specific limiters.

---

## 4. Redis Operation

The gateway uses a Redis Lua script so `INCR` and conditional `EXPIRE` execute atomically:

```lua
local current = redis.call('INCR', KEYS[1])
if current == 1 then
    redis.call('EXPIRE', KEYS[1], ARGV[1])
end
return current
```

This prevents a race condition where `INCR` succeeds but `EXPIRE` is not set.

---

## 5. Configuration

```yaml
gateway:
  rate-limit:
    requests-per-minute: ${RATE_LIMIT_PER_MINUTE:100}
    ttl-seconds: ${RATE_LIMIT_TTL_SECONDS:60}
    fail-open: ${RATE_LIMIT_FAIL_OPEN:true}
```

| Property | Default | Meaning |
|---|---:|---|
| `gateway.rate-limit.requests-per-minute` | `100` | Maximum authenticated requests per user per minute |
| `gateway.rate-limit.ttl-seconds` | `60` | Redis key TTL |
| `gateway.rate-limit.fail-open` | `true` | Allow requests when Redis is unavailable |

`fail-open=true` is the default for local/dev and early MVP stability. Production may switch this to `false` if abuse protection is more important than availability during Redis incidents.

---

## 6. Success Behavior

For requests within the limit, the gateway forwards the request downstream and adds response headers:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 42
```

---

## 7. Limit Exceeded Behavior

When the counter is greater than the configured limit, the gateway returns `429 Too Many Requests` and does not forward the request.

```http
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
Retry-After: 30
Content-Type: application/json
```

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
  "timestamp": "2026-07-01T10:30:00Z"
}
```

The response follows `docs/api/DA-E07-04_API_Response_Format.md`.

---

## 8. Routes

The filter is attached to authenticated gateway routes:

```yaml
filters:
  - JwtAuthFilter
  - RateLimit
```

Public health endpoints and other unauthenticated routes should not use this per-user limiter because they do not have `X-User-Id`.

---

## 9. Test Checklist

- [x] Request 1 through 100 for the same user and minute are allowed.
- [x] Request 101 for the same user and minute returns `429 RATE_LIMIT_EXCEEDED`.
- [x] Redis key gets TTL on first increment.
- [x] Missing `X-User-Id` returns an auth error and does not create `ratelimit:gateway::...`.
- [x] Redis failure follows configured fallback policy.
- [x] Filter is placed after JWT validation in route configuration.

---

## 10. Future Extension

Add route-specific limits after the default limiter is stable:

| Route group | Suggested limit |
|---|---:|
| Auth login/register | 5-10 requests/minute/IP or email |
| AI text generation | 20-30 requests/minute/user |
| AI image generation | 5-10 requests/minute/user |
| AI video generation | 1-3 requests/minute/user |
| Publish post | 10-20 requests/minute/user |

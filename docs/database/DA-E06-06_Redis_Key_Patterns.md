# DA-E06-06 - Redis Key Patterns

**Owner:** An (AI)  
**Priority:** High  
**Status:** Source of truth for Redis key names, values, TTLs, and service ownership  
**Blocks:** DA-E11-03  
**Blocked by:** DA-E05-04

---

## 1. Purpose

This document defines the Redis key contracts used by BrandHub so services do not create overlapping keys, incompatible value formats, or mismatched TTL behavior.

Redis is a cache and coordination layer only. It must not become primary storage for users, workspaces, posts, billing data, or audit records.

---

## 2. Naming Rules

- Use lowercase namespace prefixes separated by `:`.
- Put the highest-cardinality identifier at the end of the key.
- Do not reuse a namespace for a different value shape.
- Every key in this document must have a TTL.
- Services must treat this document as the contract before adding new Redis keys.

---

## 3. Key Pattern Summary

| Family | Key template | Example key | Value type | Value content | TTL | Writes | Reads |
|---|---|---|---|---|---|---|---|
| JWT blacklist | `jwt:blacklist:{jti}` | `jwt:blacklist:01JZ9P2N8Y7Q4M5R6T0ABCDEF1` | String | `"1"`; only key existence matters | **15 minutes, equal to access token TTL** | business-service | api-gateway, business-service |
| Rate limiting | `ratelimit:{userId}:{minute}` | `ratelimit:user_123:29740320` | Integer string | Request count from Redis `INCR` | 60 seconds | api-gateway | api-gateway |
| OAuth state | `oauth:state:{state}` | `oauth:state:9dfc2c7a-6d2c-4c89-88f1-99fd16a83df4` | JSON string | OAuth flow metadata: provider, redirect URI, and optional PKCE/workspace context | 10 minutes | business-service | business-service |
| Trending cache | `trends:vn:{date}:{category}` | `trends:vn:2026-06-29:fashion` | JSON string | Serialized list of trending topics/items for the date and category | 6 hours | ai-service | ai-service |

> Business-facing services should consume trending data through the ai-service internal endpoint, not by reading the Redis key directly. The Redis key owner is ai-service.

---

## 4. JWT Blacklist

### Contract

| Field | Value |
|---|---|
| Key template | `jwt:blacklist:{jti}` |
| Example key | `jwt:blacklist:01JZ9P2N8Y7Q4M5R6T0ABCDEF1` |
| Value type | String |
| Value content | `"1"` |
| TTL | **15 minutes** |
| Writer | business-service |
| Readers | api-gateway, business-service |

### Rules

- The key is written when an access token is revoked, for example logout or access-token rotation.
- The value is always `"1"` because only key existence matters.
- **The TTL must equal the access token TTL: 15 minutes.**
- Do not keep access-token blacklist entries longer than the access token lifetime. They should expire naturally at the same time the token would have expired anyway.

### Redis Operation

```redis
SETEX jwt:blacklist:{jti} 900 "1"
```

---

## 5. Rate Limiting

### Contract

| Field | Value |
|---|---|
| Key template | `ratelimit:{userId}:{minute}` |
| Example key | `ratelimit:user_123:29740320` |
| Value type | Integer string |
| Value content | Request count for that user in that minute window |
| TTL | 60 seconds |
| Writer | api-gateway |
| Reader | api-gateway |

`{minute}` is the current epoch minute, calculated as `epoch_seconds / 60` using integer division.

### Required Pattern

Use Redis `INCR` + `EXPIRE`, setting the expiry only when the first increment creates the key. Do not use a Lua script for this task; the simpler pattern is the accepted implementation contract for DA-E11-03.

```text
count = INCR ratelimit:{userId}:{minute}
if count == 1:
  EXPIRE ratelimit:{userId}:{minute} 60
if count > limit:
  reject with 429 RATE_LIMIT_EXCEEDED
```

### Notes

- The gateway is the enforcement point.
- Downstream services should not implement their own duplicate per-user request limiter for the same route group.
- The default product limit is 100 requests per minute per authenticated user unless a route explicitly documents a stricter limit.

---

## 6. OAuth State

### Contract

| Field | Value |
|---|---|
| Key template | `oauth:state:{state}` |
| Example key | `oauth:state:9dfc2c7a-6d2c-4c89-88f1-99fd16a83df4` |
| Value type | JSON string |
| Value content | OAuth flow metadata |
| TTL | 10 minutes |
| Writer | business-service |
| Reader | business-service |

### Required JSON Shape

```json
{
  "provider": "google",
  "redirectUri": "https://app.brandhub.vn/oauth/callback",
  "workspaceId": "ws_123",
  "userId": "user_123",
  "codeVerifier": "pkce-code-verifier"
}
```

### Rules

- `provider` and `redirectUri` are required.
- `workspaceId`, `userId`, and `codeVerifier` are included when the OAuth flow needs workspace binding or PKCE.
- Delete the key after a successful callback validation to enforce one-time use.
- If the key is missing, expired, malformed, or mismatched, return `OAUTH_STATE_INVALID`.

### Redis Operation

```redis
SETEX oauth:state:{state} 600 "{json}"
DEL oauth:state:{state}
```

---

## 7. Trending / Analytics Cache

### Contract

| Field | Value |
|---|---|
| Key template | `trends:vn:{date}:{category}` |
| Example key | `trends:vn:2026-06-29:fashion` |
| Value type | JSON string |
| Value content | Serialized list of trend items |
| TTL | 6 hours |
| Writer | ai-service |
| Reader | ai-service |

### Required JSON Shape

```json
[
  {
    "keyword": "summer outfit",
    "platform": "google",
    "region": "VN",
    "score": 87,
    "fetchedAt": "2026-06-29T00:00:00Z"
  }
]
```

### Rules

- `{date}` must use UTC date format `YYYY-MM-DD`.
- `{category}` must be a lowercase category slug such as `fashion`, `food`, `beauty`, `tech`, or `lifestyle`.
- Cache misses should trigger a live crawl when possible, then repopulate Redis.
- If the live trends source fails, callers should prefer stale-but-available fallback data at the service layer instead of failing the product workflow.

### Redis Operation

```redis
SETEX trends:vn:{YYYY-MM-DD}:{category} 21600 "{json}"
```

---

## 8. Ownership Matrix

| Service | Redis role |
|---|---|
| api-gateway | Reads JWT blacklist; writes and reads rate-limit counters |
| business-service | Writes JWT blacklist; writes, reads, and deletes OAuth state |
| ai-service | Writes and reads trending cache |
| publisher-service | No ownership of the four DA-E06-06 key families |

---

## 9. Acceptance Checklist

- [x] JWT blacklist key pattern documented with template, example, value type, value content, TTL, readers, and writer
- [x] Rate-limit key pattern documented with template, example, value type, value content, TTL, reader, and writer
- [x] OAuth state key pattern documented with template, example, value type, value content, TTL, reader, and writer
- [x] Trending cache key pattern documented with template, example, value type, value content, TTL, reader, and writer
- [x] JWT blacklist TTL explicitly equals the access token TTL: 15 minutes
- [x] Rate limiting explicitly uses `INCR` + `EXPIRE` on first increment, not Lua

# DA-E06-06 - Redis Key Patterns

> Navigation: [← Knowledge Base Hub](../../index.md) · [← Database Hub](../README.md) · [Gateway Rate Limiting](../../api/redis-rate-limiting-filter.md) · [Redis & Neo4j Upsert Flow](../ai-vector/redis-neo4j-upsert-flow.md)

**Owner:** An (AI)  
**Priority:** High  
**Status:** Source of truth for Redis key names, values, TTLs, and service ownership  
**Blocks:** [DA-E11-03](../../api/redis-rate-limiting-filter.md)  
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
| JWT blacklist | `jwt:blacklist:{jti}` | `jwt:blacklist:01JZ9P2N8Y7Q4M5R6T0ABCDEF1` | String | `"1"` / `"true"`; only key existence matters | **Up to 15 minutes (remaining Access Token TTL)** | business-service | api-gateway, business-service |
| Rate limiting | `ratelimit:gateway:{userId}:{minute}` | `ratelimit:gateway:user_123:29740320` | Integer string | Request count from atomic Redis `INCR` + `EXPIRE` | 60 seconds | api-gateway | api-gateway |
| OAuth state | `oauth:state:{state}` | `oauth:state:9dfc2c7a-6d2c-4c89-88f1-99fd16a83df4` | JSON string | OAuth flow metadata: provider, redirect URI, and optional PKCE/workspace context | 10 minutes | business-service | business-service |
| Trending cache | `trends:vn:{date}:{category}` | `trends:vn:2026-06-29:fashion` | ZSET (`ZADD` score + JSON member) or JSON String snapshot | Ranked trending topics/items for the UTC date and category (see [DA-AI04-99-06](../ai-vector/redis-neo4j-upsert-flow.md)) | 6 hours | ai-service | ai-service |
| Publish idempotency lock | `processingPostIds:{postId}:{platform}` | `processingPostIds:667f1a9c2b8e4d1234567890:FACEBOOK` | String | ISO-8601 lock timestamp (`setIfAbsent`) preventing duplicate RabbitMQ fan-out execution per `(postId, platform)` | 30 minutes (`1800` seconds) | publisher-service | publisher-service |

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
| Key template | `ratelimit:gateway:{userId}:{minute}` |
| Example key | `ratelimit:gateway:user_123:29740320` |
| Value type | Integer string |
| Value content | Request count for that user in that minute window |
| TTL | 60 seconds |
| Writer | api-gateway |
| Reader | api-gateway |

`{minute}` is the current epoch minute, calculated as `epoch_seconds / 60` using integer division.

### Required Pattern

Execute Redis `INCR` + conditional `EXPIRE` atomically (via reactive Lua script in [DA-E11-03](../../api/redis-rate-limiting-filter.md)) when the first increment creates the key:

```text
count = INCR ratelimit:gateway:{userId}:{minute}
if count == 1:
  EXPIRE ratelimit:gateway:{userId}:{minute} 60
if count > limit:
  reject with 429 RATE_LIMIT_EXCEEDED
```

### Notes

- `api-gateway` is the enforcement point.
- Downstream services do not implement duplicate per-user request limiters for the same route group.
- The default limit is `100` requests per minute per signed-in user (`Owner`, `Manager`, `Creator`, `Client`, `Admin`) unless a route specifies a stricter threshold.

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
| Value type | **ZSET** (`ZADD` score = `finalScore`, member = JSON item — primary per [DA-AI04-99-06](../ai-vector/redis-neo4j-upsert-flow.md)) or **JSON String** (`SETEX` serialized list snapshot) |
| Value content | Ranked list of Vietnam trend items |
| TTL | 6 hours (`21600` seconds) |
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

## 8. Publisher Per-Platform Idempotency Lock

### Contract

| Field | Value |
|---|---|
| Key template | `processingPostIds:{postId}:{platform}` |
| Example key | `processingPostIds:667f1a9c2b8e4d1234567890:FACEBOOK` |
| Value type | String |
| Value content | `Instant.now().toString()` lock marker |
| TTL | 30 minutes (`1800` seconds, `Duration.ofMinutes(30)`) |
| Writer | `brandhub-publisher-service` (`PublishJobConsumer`) |
| Reader | `brandhub-publisher-service` (`PublishJobConsumer`) |

### Rules

- One scheduled or immediate `Post` fans out into one RabbitMQ `PublishJobMessage` per target platform (`FACEBOOK`, `INSTAGRAM`, `TIKTOK`, `THREADS`).
- `PublishJobConsumer` acquires `SET processingPostIds:{postId}:{platform} <isoTimestamp> NX EX 1800` before calling the platform's `SocialPublishAdapter`.
- Scoping the key by `{platform}` ensures sibling platform deliveries for the same `postId` execute concurrently without blocking one another, while duplicate redeliveries for the same `(postId, platform)` are skipped cleanly.
- On transient failure (where the message is routed to `publish.jobs.retry.{1m,5m,15m}`), the consumer explicitly deletes the lock key in `finally`/error handling so the delayed retry can re-acquire it.

---

## 9. Ownership Matrix

| Service | Redis role |
|---|---|
| `brandhub-api-gateway` | Reads JWT blacklist (`jwt:blacklist:*`); writes and reads sliding-window rate-limit counters (`ratelimit:gateway:*`) |
| `brandhub-business-service` | Writes JWT blacklist; writes, reads, and deletes one-time OAuth state (`oauth:state:*`) |
| `brandhub-ai-service` | Writes and reads Vietnam trending ZSET/JSON cache (`trends:vn:*`) |
| `brandhub-publisher-service` | Acquires and releases per-platform publish deduplication locks (`processingPostIds:{postId}:{platform}`) |

---

## 10. Acceptance Checklist

- [x] JWT blacklist key pattern documented with template, example, value type, value content, TTL, readers, and writer
- [x] Rate-limit key pattern documented with template, example, value type, value content, TTL, reader, and writer
- [x] OAuth state key pattern documented with template, example, value type, value content, TTL, reader, and writer
- [x] Trending cache key pattern documented with template, example, value type, value content, TTL, reader, and writer
- [x] Publisher per-platform idempotency lock `processingPostIds:{postId}:{platform}` (`30m` TTL) documented from `PublishJobConsumer`
- [x] JWT blacklist TTL matches remaining access token lifetime (up to 15 minutes)
- [x] Rate limiting uses `ratelimit:gateway:{userId}:{minute}` with atomic `INCR` + `EXPIRE` on first increment (aligned with [DA-E11-03](../../api/redis-rate-limiting-filter.md))

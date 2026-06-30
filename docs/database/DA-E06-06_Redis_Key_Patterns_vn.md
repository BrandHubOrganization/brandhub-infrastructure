# DA-E06-06 - Redis Key Patterns (VI)

**Owner:** Ân (AI)  
**Priority:** High  
**Status:** Nguồn chuẩn cho tên Redis key, value format, TTL và quyền đọc/ghi của service  
**Blocks:** DA-E11-03  
**Blocked by:** DA-E05-04

---

## 1. Mục tiêu

Tài liệu này định nghĩa contract Redis key dùng trong BrandHub để các service không tạo key trùng nhau, không ghi sai value format, và không dùng TTL lệch nhau.

Redis chỉ là cache và coordination layer. Không dùng Redis làm primary storage cho users, workspaces, posts, billing data hoặc audit records.

---

## 2. Quy tắc đặt tên

- Dùng prefix namespace chữ thường, ngăn cách bằng dấu `:`.
- Đặt identifier có cardinality cao nhất ở cuối key.
- Không tái sử dụng một namespace cho value shape khác.
- Mỗi key trong tài liệu này bắt buộc có TTL.
- Trước khi thêm Redis key mới, service phải xem tài liệu này như contract chuẩn.

---

## 3. Tổng hợp key patterns

| Family | Key template | Example key | Value type | Value content | TTL | Writes | Reads |
|---|---|---|---|---|---|---|---|
| JWT blacklist | `jwt:blacklist:{jti}` | `jwt:blacklist:01JZ9P2N8Y7Q4M5R6T0ABCDEF1` | String | `"1"`; chỉ cần key tồn tại | **15 minutes, bằng access token TTL** | business-service | api-gateway, business-service |
| Rate limiting | `ratelimit:{userId}:{minute}` | `ratelimit:user_123:29740320` | Integer string | Số request từ Redis `INCR` | 60 seconds | api-gateway | api-gateway |
| OAuth state | `oauth:state:{state}` | `oauth:state:9dfc2c7a-6d2c-4c89-88f1-99fd16a83df4` | JSON string | Metadata OAuth flow: provider, redirect URI và optional PKCE/workspace context | 10 minutes | business-service | business-service |
| Trending cache | `trends:vn:{date}:{category}` | `trends:vn:2026-06-29:fashion` | JSON string | Danh sách trending topics/items đã serialize cho date và category | 6 hours | ai-service | ai-service |

> Các business-facing services nên lấy trending data qua internal endpoint của ai-service, không đọc trực tiếp Redis key. Owner của Redis key này là ai-service.

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

- Key được ghi khi access token bị revoke, ví dụ logout hoặc access-token rotation.
- Value luôn là `"1"` vì hệ thống chỉ cần kiểm tra key có tồn tại hay không.
- **TTL bắt buộc bằng access token TTL: 15 minutes.**
- Không giữ blacklist entry lâu hơn thời gian sống của access token. Entry phải tự expire đúng lúc token gốc hết hạn.

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
| Value content | Số request của user trong minute window đó |
| TTL | 60 seconds |
| Writer | api-gateway |
| Reader | api-gateway |

`{minute}` là epoch minute hiện tại, tính bằng `epoch_seconds / 60` với integer division.

### Required Pattern

Dùng Redis `INCR` + `EXPIRE`, chỉ set expiry khi lần increment đầu tiên tạo key. Không dùng Lua script cho task này; pattern đơn giản này là implementation contract được chấp nhận cho DA-E11-03.

```text
count = INCR ratelimit:{userId}:{minute}
if count == 1:
  EXPIRE ratelimit:{userId}:{minute} 60
if count > limit:
  reject with 429 RATE_LIMIT_EXCEEDED
```

### Notes

- Gateway là enforcement point.
- Downstream services không nên tự implement thêm per-user request limiter trùng lặp cho cùng route group.
- Product limit mặc định là 100 requests/phút/authenticated user, trừ khi route có document limit chặt hơn.

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

- `provider` và `redirectUri` là required.
- `workspaceId`, `userId` và `codeVerifier` được thêm khi OAuth flow cần workspace binding hoặc PKCE.
- Xóa key sau khi callback validate thành công để đảm bảo state chỉ dùng một lần.
- Nếu key bị thiếu, expired, malformed hoặc mismatch, trả về `OAUTH_STATE_INVALID`.

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
| Value content | Danh sách trend items đã serialize |
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

- `{date}` phải dùng UTC date format `YYYY-MM-DD`.
- `{category}` phải là lowercase category slug, ví dụ `fashion`, `food`, `beauty`, `tech` hoặc `lifestyle`.
- Cache miss nên trigger live crawl nếu có thể, sau đó repopulate Redis.
- Nếu live trends source fail, service layer nên ưu tiên stale-but-available fallback data thay vì làm hỏng product workflow.

### Redis Operation

```redis
SETEX trends:vn:{YYYY-MM-DD}:{category} 21600 "{json}"
```

---

## 8. Ownership Matrix

| Service | Redis role |
|---|---|
| api-gateway | Đọc JWT blacklist; ghi và đọc rate-limit counters |
| business-service | Ghi JWT blacklist; ghi, đọc và xóa OAuth state |
| ai-service | Ghi và đọc trending cache |
| publisher-service | Không own 4 key family của DA-E06-06 |

---

## 9. Acceptance Checklist

- [x] JWT blacklist key pattern có template, example, value type, value content, TTL, readers, writer
- [x] Rate-limit key pattern có template, example, value type, value content, TTL, reader, writer
- [x] OAuth state key pattern có template, example, value type, value content, TTL, reader, writer
- [x] Trending cache key pattern có template, example, value type, value content, TTL, reader, writer
- [x] JWT blacklist TTL ghi rõ bằng access token TTL: 15 minutes
- [x] Rate limiting ghi rõ dùng `INCR` + `EXPIRE` khi first increment, không dùng Lua

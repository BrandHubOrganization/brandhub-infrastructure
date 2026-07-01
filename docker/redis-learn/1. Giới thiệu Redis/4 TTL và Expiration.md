**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/60b06bf3-50b2-487f-bdac-f95ab86ae56a](https://code4func.com/learn/redis-and-caching-strategies/60b06bf3-50b2-487f-bdac-f95ab86ae56a)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── TTL và Expiration trong Redis
├── Mục tiêu bài học
├── 1\. Tại sao cần TTL?
├── 2\. Các lệnh set TTL
│   └── EXPIRE — Set TTL tính bằng giây
├── Set key
├── Set TTL = 3600 giây (1 giờ)
├── EXPIRE key không tồn tại → thất bại
│   └── PEXPIRE — Set TTL tính bằng milliseconds
├── TTL = 500ms (nửa giây)
│   └── EXPIREAT — Set thời điểm hết hạn (Unix timestamp)
├── Hết hạn lúc 2024-12-31 23:59:59 UTC
│   ├── PEXPIREAT — Thời điểm hết hạn tính bằng milliseconds
│   └── SET với EX/PX — Set value và TTL cùng lúc
├── EX = giây
├── PX = milliseconds
├── EXAT = Unix timestamp (giây)
├── PXAT = Unix timestamp (milliseconds)
│   └── 3\. Kiểm tra TTL
│       └── TTL — Thời gian còn lại (giây)
├── Kiểm tra TTL
├── Key không có TTL (persistent)
├── Key không tồn tại
│   ├── PTTL — Thời gian còn lại (milliseconds)
│   ├── Ví dụ trong Go: Kiểm tra TTL
│   └── 4\. PERSIST — Xóa TTL
├── Xóa TTL — key sẽ tồn tại vĩnh viễn
├── SET mới KHÔNG giữ TTL
└── SET với KEEPTTL giữ nguyên TTL
    ├── 5\. Cơ chế Expiration bên trong Redis
    │   ├── Lazy Expiration (Passive)
    │   ├── Active Expiration
    │   └── Kết hợp cả hai
    ├── 6\. Best Practices cho TTL
    │   ├── Guideline TTL values theo use case
    │   ├── Pattern: Jitter để tránh Thundering Herd
    │   └── Pattern: Cache key naming convention
    └── Tóm tắt
```

---

## TTL và Expiration trong Redis

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Sử dụng thành thạo EXPIRE, EXPIREAT, PEXPIRE để set TTL
-   Dùng TTL, PTTL để kiểm tra thời gian sống còn lại
-   Hiểu cách xóa TTL bằng PERSIST
-   Nắm rõ cơ chế lazy expiration và active expiration bên trong Redis
-   Áp dụng best practices cho TTL values trong các use case thực tế

## 1\. Tại sao cần TTL?

TTL (Time-To-Live) là thời gian sống của một key trong Redis. Sau khi TTL hết, key tự động bị xóa. Đây là tính năng quan trọng nhất khi dùng Redis làm cache.

**Nếu không có TTL:**

-   Cache data cũ (stale data) → user thấy thông tin lỗi thời
-   Redis ngày càng dùng nhiều memory → cuối cùng hết RAM
-   Phải manually cleanup → phức tạp, dễ sót

**Với TTL:**

-   Data tự động hết hạn → cache luôn fresh
-   Memory tự giải phóng → không lo hết RAM
-   Đơn giản, ít code hơn

## 2\. Các lệnh set TTL

### EXPIRE — Set TTL tính bằng giây

```
# Set key
127.0.0.1:6379> SET session:abc123 "user-data"
OK

# Set TTL = 3600 giây (1 giờ)
127.0.0.1:6379> EXPIRE session:abc123 3600
(integer) 1   # 1 = thành công

# EXPIRE key không tồn tại → thất bại
127.0.0.1:6379> EXPIRE nonexistent 3600
(integer) 0   # 0 = key không tồn tại
```

### PEXPIRE — Set TTL tính bằng milliseconds

```
# TTL = 500ms (nửa giây)
127.0.0.1:6379> SET quick:data "temp"
OK
127.0.0.1:6379> PEXPIRE quick:data 500
(integer) 1
```

### EXPIREAT — Set thời điểm hết hạn (Unix timestamp)

```
# Hết hạn lúc 2024-12-31 23:59:59 UTC
127.0.0.1:6379> SET promo:newyear "50% off"
OK
127.0.0.1:6379> EXPIREAT promo:newyear 1735689599
(integer) 1
```

### PEXPIREAT — Thời điểm hết hạn tính bằng milliseconds

```
127.0.0.1:6379> PEXPIREAT promo:newyear 1735689599000
(integer) 1
```

### SET với EX/PX — Set value và TTL cùng lúc

```
# EX = giây
127.0.0.1:6379> SET cache:product:1 '{"name":"iPhone"}' EX 300
OK

# PX = milliseconds
127.0.0.1:6379> SET cache:product:2 '{"name":"Samsung"}' PX 300000
OK

# EXAT = Unix timestamp (giây)
127.0.0.1:6379> SET event:sale "active" EXAT 1735689599
OK

# PXAT = Unix timestamp (milliseconds)
127.0.0.1:6379> SET event:flash "active" PXAT 1735689599000
OK
```

> **Best practice:** Khi có thể, dùng `SET key value EX seconds` thay vì `SET` rồi `EXPIRE` riêng. Lý do: `SET ... EX` là **atomic** — nếu crash giữa SET và EXPIRE, key sẽ không có TTL (tồn tại mãi mãi).

## 3\. Kiểm tra TTL

### TTL — Thời gian còn lại (giây)

```
127.0.0.1:6379> SET cache:data "value" EX 60
OK

# Kiểm tra TTL
127.0.0.1:6379> TTL cache:data
(integer) 57   # còn 57 giây

# Key không có TTL (persistent)
127.0.0.1:6379> SET persistent:data "forever"
OK
127.0.0.1:6379> TTL persistent:data
(integer) -1   # -1 = không có TTL

# Key không tồn tại
127.0.0.1:6379> TTL nonexistent
(integer) -2   # -2 = key không tồn tại
```

### PTTL — Thời gian còn lại (milliseconds)

```
127.0.0.1:6379> PTTL cache:data
(integer) 54321   # còn 54.321 giây
```

**Ý nghĩa giá trị trả về:**

| Giá trị | Ý nghĩa |
| --- | --- |
| \> 0 | Số giây/ms còn lại trước khi hết hạn |
| \-1 | Key tồn tại nhưng không có TTL (persistent) |
| \-2 | Key không tồn tại |

### Ví dụ trong Go: Kiểm tra TTL

```
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    // Set key với TTL 5 phút
    rdb.Set(ctx, "session:test", "data", 5*time.Minute)

    // Kiểm tra TTL
    ttl, _ := rdb.TTL(ctx, "session:test").Result()
    fmt.Printf("TTL: %v\n", ttl) // ~5m0s

    // PTTL cho milliseconds precision
    pttl, _ := rdb.PTTL(ctx, "session:test").Result()
    fmt.Printf("PTTL: %v\n", pttl) // ~4m59.987s

    // TTL của key không có expiry
    rdb.Set(ctx, "persistent:key", "value", 0) // 0 = no expiry
    ttl2, _ := rdb.TTL(ctx, "persistent:key").Result()
    fmt.Printf("Persistent TTL: %v\n", ttl2) // -1ns (special value)

    // TTL của key không tồn tại
    ttl3, _ := rdb.TTL(ctx, "nonexistent").Result()
    fmt.Printf("Non-existent TTL: %v\n", ttl3) // -2ns (special value)
}
```

## 4\. PERSIST — Xóa TTL

`PERSIST` xóa TTL của key, biến nó thành persistent (tồn tại mãi mãi cho đến khi bị DEL).

```
127.0.0.1:6379> SET temp:data "value" EX 60
OK

127.0.0.1:6379> TTL temp:data
(integer) 58

# Xóa TTL — key sẽ tồn tại vĩnh viễn
127.0.0.1:6379> PERSIST temp:data
(integer) 1

127.0.0.1:6379> TTL temp:data
(integer) -1   # Không còn TTL
```

**Use case:** Khi user upgrade lên premium, session của họ không cần hết hạn:

```
package main

import (
    "context"
    "fmt"

    "github.com/redis/go-redis/v9"
)

func upgradeToPremium(ctx context.Context, rdb *redis.Client, userID string) error {
    sessionKey := fmt.Sprintf("session:%s", userID)

    // Kiểm tra session tồn tại
    exists, err := rdb.Exists(ctx, sessionKey).Result()
    if err != nil {
        return err
    }
    if exists == 0 {
        return fmt.Errorf("session not found")
    }

    // Xóa TTL — premium users có persistent session
    return rdb.Persist(ctx, sessionKey).Err()
}
```

> **Lưu ý:** `SET` mới cũng xóa TTL cũ. Nếu bạn `SET key value` (không có EX), TTL cũ sẽ bị mất. Dùng `SET key value KEEPTTL` (Redis 6.0+) để giữ TTL khi update value.

```
127.0.0.1:6379> SET mykey "old" EX 100
OK
127.0.0.1:6379> TTL mykey
(integer) 98

# SET mới KHÔNG giữ TTL
127.0.0.1:6379> SET mykey "new"
OK
127.0.0.1:6379> TTL mykey
(integer) -1   # TTL bị mất!

# SET với KEEPTTL giữ nguyên TTL
127.0.0.1:6379> SET mykey "old" EX 100
OK
127.0.0.1:6379> SET mykey "new" KEEPTTL
OK
127.0.0.1:6379> TTL mykey
(integer) 95   # TTL vẫn còn
```

## 5\. Cơ chế Expiration bên trong Redis

Redis dùng 2 cơ chế để xóa expired keys:

### Lazy Expiration (Passive)

Key chỉ bị xóa khi có client truy cập vào nó:

```
Client: GET expired_key
Redis:  1. Kiểm tra key có expired không
        2. Nếu expired → xóa key → trả về nil
        3. Nếu chưa expired → trả về value
```

**Vấn đề:** Nếu không ai access key đã expired, nó vẫn chiếm memory!

### Active Expiration

Redis chủ động quét và xóa expired keys theo chu kỳ:

```
Mỗi 100ms (10 lần/giây), Redis thực hiện:
1. Random chọn 20 keys có TTL
2. Xóa các keys đã expired
3. Nếu > 25% keys đã expired → lặp lại bước 1
4. Nếu ≤ 25% → dừng, chờ chu kỳ tiếp theo

Đảm bảo: Tối đa 25% keys expired tồn tại tại bất kỳ thời điểm nào
```

### Kết hợp cả hai

```
┌─────────────────────────────────────────────┐
│            Redis Expiration                  │
│                                              │
│  Lazy (khi access):                          │
│  ┌─────────┐    GET key    ┌──────────┐     │
│  │ Client  │ ───────────── │ Redis    │     │
│  │         │               │ Check    │     │
│  │         │  expired?     │ TTL      │     │
│  │         │ ◄──────────── │ → Delete │     │
│  └─────────┘   nil         └──────────┘     │
│                                              │
│  Active (mỗi 100ms):                        │
│  ┌──────────────────────────────────┐       │
│  │ Random sample 20 keys with TTL  │       │
│  │ Delete expired ones             │       │
│  │ If >25% expired → repeat        │       │
│  └──────────────────────────────────┘       │
│                                              │
└─────────────────────────────────────────────┘
```

## 6\. Best Practices cho TTL

### Guideline TTL values theo use case

| Use case | TTL khuyên dùng | Lý do |
| --- | --- | --- |
| API response cache | 30s - 5 phút | Data thay đổi thường xuyên |
| Database query cache | 5 - 30 phút | Giảm DB load, chấp nhận stale ngắn |
| User session | 24h - 7 ngày | Cân bằng UX và security |
| OTP/Verification code | 5 - 15 phút | Security requirement |
| Rate limit counter | 1 - 60 phút | Tùy window size |
| Static content cache | 1 - 24 giờ | Ít thay đổi |
| Feature flags | 5 - 30 phút | Cần update nhanh khi deploy |

### Pattern: Jitter để tránh Thundering Herd

Nếu nhiều cache keys có cùng TTL, chúng sẽ expire cùng lúc → tất cả requests đều miss cache → database bị overwhelm (thundering herd).

**Giải pháp:** Thêm random jitter vào TTL:

```
package main

import (
    "context"
    "math/rand"
    "time"

    "github.com/redis/go-redis/v9"
)

// cacheWithJitter lưu cache với TTL có jitter
func cacheWithJitter(ctx context.Context, rdb *redis.Client, key, value string, baseTTL time.Duration) error {
    // Thêm jitter: ±20% của baseTTL
    jitter := time.Duration(rand.Int63n(int64(baseTTL) * 40 / 100)) - baseTTL*20/100
    ttl := baseTTL + jitter

    return rdb.Set(ctx, key, value, ttl).Err()
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    // BaseTTL = 5 phút, nhưng thực tế TTL sẽ là 4-6 phút (random)
    // Các keys sẽ expire rải rác, không cùng lúc
    for i := 0; i < 100; i++ {
        cacheWithJitter(ctx, rdb, "product:"+string(rune(i)), "data", 5*time.Minute)
    }
}
```

### Pattern: Cache key naming convention

```
package main

import "fmt"

// Đặt tên key theo convention: {type}:{entity}:{id}:{field}
func cacheKey(entity, id string) string {
    return fmt.Sprintf("cache:%s:%s", entity, id)
}

func sessionKey(sessionID string) string {
    return fmt.Sprintf("session:%s", sessionID)
}

func rateLimitKey(userID string, window int64) string {
    return fmt.Sprintf("ratelimit:%s:%d", userID, window)
}

func lockKey(resource string) string {
    return fmt.Sprintf("lock:%s", resource)
}

func main() {
    // Ví dụ key names:
    fmt.Println(cacheKey("product", "123"))       // cache:product:123
    fmt.Println(sessionKey("abc-def"))             // session:abc-def
    fmt.Println(rateLimitKey("user1", 1700000000)) // ratelimit:user1:1700000000
    fmt.Println(lockKey("order:456"))              // lock:order:456
}
```

## Tóm tắt

| Lệnh | Mô tả | Ví dụ |
| --- | --- | --- |
| `EXPIRE` | Set TTL (giây) | `EXPIRE key 3600` |
| `PEXPIRE` | Set TTL (ms) | `PEXPIRE key 500` |
| `EXPIREAT` | Set expiry timestamp | `EXPIREAT key 1735689599` |
| `TTL` | Kiểm tra TTL còn lại (giây) | `TTL key` → 57 |
| `PTTL` | Kiểm tra TTL còn lại (ms) | `PTTL key` → 57321 |
| `PERSIST` | Xóa TTL | `PERSIST key` |
| `SET ... EX` | Set value + TTL atomic | `SET k v EX 60` |
| `KEEPTTL` | Giữ TTL khi SET mới | `SET k v KEEPTTL` |

**Key takeaways:**

-   Luôn dùng `SET key value EX` thay vì SET rồi EXPIRE riêng
-   Thêm jitter vào TTL để tránh thundering herd
-   Redis dùng lazy + active expiration để clean up expired keys
-   Tuân theo naming convention cho cache keys

> **Bài tiếp theo:** Chúng ta sẽ bắt đầu sử dụng Redis trong Go với thư viện go-redis — kết nối, cấu hình, và thực hiện các operations cơ bản.
**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/23c2780a-3231-48af-926a-cd43c6061bf9](https://code4func.com/learn/redis-and-caching-strategies/23c2780a-3231-48af-926a-cd43c6061bf9)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Rate Limiting: Token Bucket và Sliding Window
├── Mục tiêu bài học
├── 1\. Tại sao cần Rate Limiting?
│   └── Response khi bị rate limit
├── 2\. Fixed Window Counter
├── 3\. Sliding Window Log
├── 4\. Token Bucket
├── 5\. Gin Rate Limit Middleware
├── 6\. So sánh các thuật toán
└── Tóm tắt
```

---

## Rate Limiting: Token Bucket và Sliding Window

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Hiểu 3 thuật toán rate limiting: Fixed Window, Sliding Window, Token Bucket
-   Implement mỗi thuật toán với Redis trong Go
-   Tạo Gin middleware cho rate limiting
-   Biết cách chọn thuật toán phù hợp cho từng use case

## 1\. Tại sao cần Rate Limiting?

Rate limiting bảo vệ API khỏi:

-   **DDoS attacks**: Hàng triệu requests từ attacker
-   **Brute force**: Thử nhiều passwords liên tục
-   **API abuse**: Client gọi quá nhiều, ảnh hưởng users khác
-   **Cost control**: Giới hạn usage cho free tier

### Response khi bị rate limit

```
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 100         ← Tối đa 100 requests
X-RateLimit-Remaining: 0       ← Còn lại 0
X-RateLimit-Reset: 1700000060  ← Reset lúc Unix timestamp này
Retry-After: 30                ← Thử lại sau 30 giây

{"error": "Rate limit exceeded", "retry_after": 30}
```

## 2\. Fixed Window Counter

Thuật toán đơn giản nhất: đếm requests trong mỗi "cửa sổ" thời gian cố định.

```
Window 1 (00:00 - 00:01)    Window 2 (00:01 - 00:02)
┌────────────────────┐      ┌────────────────────┐
│ ███████████░░░░░░░ │      │ █████░░░░░░░░░░░░░ │
│ 11 requests        │      │ 5 requests         │
│ Limit: 10          │      │ Limit: 10          │
│ → Request 11 bị    │      │ → OK               │
│   REJECT!          │      │                    │
└────────────────────┘      └────────────────────┘
```

```
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

// FixedWindowLimiter rate limiter dùng fixed window
type FixedWindowLimiter struct {
    rdb       *redis.Client
    limit     int64
    window    time.Duration
}

func NewFixedWindowLimiter(rdb *redis.Client, limit int64, window time.Duration) *FixedWindowLimiter {
    return &FixedWindowLimiter{rdb: rdb, limit: limit, window: window}
}

// Allow kiểm tra request có được phép không
func (fw *FixedWindowLimiter) Allow(ctx context.Context, key string) (bool, int64, error) {
    // Key bao gồm timestamp của window hiện tại
    windowKey := fmt.Sprintf("ratelimit:fw:%s:%d", key, time.Now().Unix()/int64(fw.window.Seconds()))

    // INCR + EXPIRE atomic
    pipe := fw.rdb.Pipeline()
    incrCmd := pipe.Incr(ctx, windowKey)
    pipe.Expire(ctx, windowKey, fw.window)
    _, err := pipe.Exec(ctx)
    if err != nil {
        return false, 0, err
    }

    current := incrCmd.Val()
    remaining := fw.limit - current
    if remaining < 0 {
        remaining = 0
    }

    return current <= fw.limit, remaining, nil
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // 10 requests per minute
    limiter := NewFixedWindowLimiter(rdb, 10, time.Minute)

    for i := 0; i < 12; i++ {
        allowed, remaining, _ := limiter.Allow(ctx, "user:123")
        fmt.Printf("Request %2d: allowed=%v, remaining=%d\n", i+1, allowed, remaining)
    }
    // Request 1-10: allowed=true
    // Request 11-12: allowed=false
}
```

**Nhược điểm Fixed Window:** Boundary problem — user có thể gửi 2x limit ở ranh giới 2 windows:

```
Window 1 (00:00 - 01:00)      Window 2 (01:00 - 02:00)
             ┌──────────────────────────────────┐
             │  10 requests    10 requests       │
             │  (00:59-01:00)  (01:00-01:01)     │
             │                                    │
             │  = 20 requests trong 1 phút!       │
             │  (gấp đôi limit!)                  │
             └──────────────────────────────────┘
```

## 3\. Sliding Window Log

Giải quyết boundary problem bằng cách lưu timestamp mỗi request.

```
package main

import (
    "context"
    "fmt"
    "strconv"
    "time"

    "github.com/redis/go-redis/v9"
)

// SlidingWindowLimiter dùng Sorted Set để track timestamps
type SlidingWindowLimiter struct {
    rdb    *redis.Client
    limit  int64
    window time.Duration
}

func NewSlidingWindowLimiter(rdb *redis.Client, limit int64, window time.Duration) *SlidingWindowLimiter {
    return &SlidingWindowLimiter{rdb: rdb, limit: limit, window: window}
}

// Allow kiểm tra và ghi nhận request
func (sw *SlidingWindowLimiter) Allow(ctx context.Context, key string) (bool, int64, error) {
    now := time.Now()
    windowStart := now.Add(-sw.window)
    redisKey := "ratelimit:sw:" + key

    // Lua script để đảm bảo atomic
    script := redis.NewScript(`
        local key = KEYS[1]
        local now = tonumber(ARGV[1])
        local window_start = tonumber(ARGV[2])
        local limit = tonumber(ARGV[3])
        local ttl = tonumber(ARGV[4])

        -- Xóa entries cũ (ngoài window)
        redis.call('ZREMRANGEBYSCORE', key, '-inf', window_start)

        -- Đếm entries hiện tại
        local count = redis.call('ZCARD', key)

        if count < limit then
            -- Thêm request mới
            redis.call('ZADD', key, now, now .. ':' .. math.random(1000000))
            redis.call('EXPIRE', key, ttl)
            return {1, limit - count - 1}  -- allowed, remaining
        else
            redis.call('EXPIRE', key, ttl)
            return {0, 0}  -- denied, remaining=0
        end
    `)

    result, err := script.Run(ctx, sw.rdb, []string{redisKey},
        now.UnixMicro(),
        windowStart.UnixMicro(),
        sw.limit,
        int64(sw.window.Seconds())+1,
    ).Int64Slice()

    if err != nil {
        return false, 0, err
    }

    return result[0] == 1, result[1], nil
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // 5 requests per 10 seconds
    limiter := NewSlidingWindowLimiter(rdb, 5, 10*time.Second)

    for i := 0; i < 7; i++ {
        allowed, remaining, _ := limiter.Allow(ctx, "user:456")
        fmt.Printf("Request %d: allowed=%v, remaining=%d\n", i+1, allowed, remaining)
    }
    // Request 1-5: allowed=true
    // Request 6-7: allowed=false

    _ = strconv.Itoa(0) // suppress unused import
}
```

## 4\. Token Bucket

Thuật toán linh hoạt nhất — cho phép burst requests trong khi vẫn giới hạn tốc độ trung bình.

```
Token Bucket:
┌──────────────────┐
│ ████████░░░░░░░░ │  Bucket chứa tokens
│ 8/10 tokens      │  (max capacity: 10)
└──────────────────┘
        ▲
        │ Refill: 1 token/giây
        │
Mỗi request "lấy" 1 token.
Nếu bucket hết token → REJECT.
Tokens tự động "đổ" vào bucket theo thời gian.

Burst: User có thể gửi 10 requests ngay lập tức
       (nếu bucket đầy), sau đó 1 request/giây.
```

```
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

// TokenBucketLimiter rate limiter dùng token bucket
type TokenBucketLimiter struct {
    rdb        *redis.Client
    capacity   int64         // Số tokens tối đa
    refillRate float64       // Tokens thêm mỗi giây
}

func NewTokenBucketLimiter(rdb *redis.Client, capacity int64, refillRate float64) *TokenBucketLimiter {
    return &TokenBucketLimiter{rdb: rdb, capacity: capacity, refillRate: refillRate}
}

// Allow kiểm tra và tiêu thụ 1 token
func (tb *TokenBucketLimiter) Allow(ctx context.Context, key string) (bool, int64, error) {
    redisKey := "ratelimit:tb:" + key

    // Lua script: tính tokens dựa trên thời gian, tiêu thụ 1 token
    script := redis.NewScript(`
        local key = KEYS[1]
        local capacity = tonumber(ARGV[1])
        local refill_rate = tonumber(ARGV[2])
        local now = tonumber(ARGV[3])

        -- Đọc state hiện tại
        local data = redis.call('HMGET', key, 'tokens', 'last_refill')
        local tokens = tonumber(data[1])
        local last_refill = tonumber(data[2])

        -- Khởi tạo nếu chưa tồn tại
        if tokens == nil then
            tokens = capacity
            last_refill = now
        end

        -- Tính tokens được refill từ lần cuối
        local elapsed = now - last_refill
        local new_tokens = elapsed * refill_rate
        tokens = math.min(capacity, tokens + new_tokens)

        -- Tiêu thụ 1 token
        local allowed = 0
        if tokens >= 1 then
            tokens = tokens - 1
            allowed = 1
        end

        -- Lưu state
        redis.call('HMSET', key, 'tokens', tokens, 'last_refill', now)
        redis.call('EXPIRE', key, math.ceil(capacity / refill_rate) + 1)

        return {allowed, math.floor(tokens)}
    `)

    result, err := script.Run(ctx, tb.rdb, []string{redisKey},
        tb.capacity,
        tb.refillRate,
        float64(time.Now().UnixMicro())/1000000,
    ).Int64Slice()

    if err != nil {
        return false, 0, err
    }

    return result[0] == 1, result[1], nil
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // Capacity: 5 tokens, Refill: 1 token/giây
    limiter := NewTokenBucketLimiter(rdb, 5, 1.0)

    // Burst: 5 requests ngay lập tức
    fmt.Println("=== Burst (5 requests) ===")
    for i := 0; i < 7; i++ {
        allowed, remaining, _ := limiter.Allow(ctx, "user:789")
        fmt.Printf("  Request %d: allowed=%v, remaining=%d\n", i+1, allowed, remaining)
    }

    // Chờ 3 giây → refill 3 tokens
    fmt.Println("\n=== Wait 3 seconds ===")
    time.Sleep(3 * time.Second)

    for i := 0; i < 5; i++ {
        allowed, remaining, _ := limiter.Allow(ctx, "user:789")
        fmt.Printf("  Request %d: allowed=%v, remaining=%d\n", i+1, allowed, remaining)
    }
}
```

## 5\. Gin Rate Limit Middleware

```
package main

import (
    "context"
    "fmt"
    "net/http"
    "strconv"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/redis/go-redis/v9"
)

// RateLimitConfig cấu hình rate limiter
type RateLimitConfig struct {
    RedisClient *redis.Client
    Limit       int64         // Số requests tối đa
    Window      time.Duration // Trong khoảng thời gian
    KeyFunc     func(c *gin.Context) string // Tạo key từ request
}

// RateLimitMiddleware tạo Gin middleware
func RateLimitMiddleware(cfg RateLimitConfig) gin.HandlerFunc {
    return func(c *gin.Context) {
        ctx := c.Request.Context()
        key := cfg.KeyFunc(c)

        // Fixed Window Counter (đơn giản, hiệu quả)
        windowKey := fmt.Sprintf("rl:%s:%d", key, time.Now().Unix()/int64(cfg.Window.Seconds()))

        pipe := cfg.RedisClient.Pipeline()
        incrCmd := pipe.Incr(ctx, windowKey)
        pipe.Expire(ctx, windowKey, cfg.Window)
        pipe.Exec(ctx)

        current := incrCmd.Val()
        remaining := cfg.Limit - current
        if remaining < 0 {
            remaining = 0
        }

        // Set rate limit headers
        c.Header("X-RateLimit-Limit", strconv.FormatInt(cfg.Limit, 10))
        c.Header("X-RateLimit-Remaining", strconv.FormatInt(remaining, 10))
        c.Header("X-RateLimit-Reset", strconv.FormatInt(
            time.Now().Add(cfg.Window).Unix(), 10))

        if current > cfg.Limit {
            retryAfter := int(cfg.Window.Seconds())
            c.Header("Retry-After", strconv.Itoa(retryAfter))
            c.JSON(http.StatusTooManyRequests, gin.H{
                "error":       "Rate limit exceeded",
                "retry_after": retryAfter,
            })
            c.Abort()
            return
        }

        c.Next()
    }
}

// === Key Functions ===

// PerIP rate limit theo IP
func PerIP(c *gin.Context) string {
    return "ip:" + c.ClientIP()
}

// PerUser rate limit theo user ID (cần auth middleware trước)
func PerUser(c *gin.Context) string {
    userID, exists := c.Get("user_id")
    if !exists {
        return "anon:" + c.ClientIP()
    }
    return "user:" + userID.(string)
}

// PerEndpoint rate limit theo endpoint + IP
func PerEndpoint(c *gin.Context) string {
    return "ep:" + c.Request.Method + ":" + c.FullPath() + ":" + c.ClientIP()
}

func main() {
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    if err := rdb.Ping(context.Background()).Err(); err != nil {
        panic(err)
    }

    r := gin.Default()

    // Global rate limit: 100 requests/phút per IP
    r.Use(RateLimitMiddleware(RateLimitConfig{
        RedisClient: rdb,
        Limit:       100,
        Window:      time.Minute,
        KeyFunc:     PerIP,
    }))

    r.GET("/api/products", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{"products": []string{"iPhone", "MacBook"}})
    })

    // Strict rate limit cho login: 5 requests/phút
    r.POST("/login", RateLimitMiddleware(RateLimitConfig{
        RedisClient: rdb,
        Limit:       5,
        Window:      time.Minute,
        KeyFunc:     PerEndpoint,
    }), func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{"message": "Login"})
    })

    r.Run(":8080")
}
```

## 6\. So sánh các thuật toán

| Thuật toán | Burst | Accuracy | Memory | Complexity |
| --- | --- | --- | --- | --- |
| Fixed Window | Boundary problem | Thấp | O(1) per key | Thấp |
| Sliding Window Log | Không | Cao | O(N) per key | Trung bình |
| Sliding Window Counter | Ít | Trung bình | O(1) per key | Trung bình |
| Token Bucket | Có (controlled) | Cao | O(1) per key | Trung bình |

**Chọn thuật toán nào?**

| Use case | Thuật toán | Lý do |
| --- | --- | --- |
| API general | Fixed Window | Đơn giản, đủ tốt cho hầu hết |
| Login/OTP | Sliding Window | Cần chính xác, không cho burst |
| API with burst | Token Bucket | Cho phép burst nhưng giới hạn average |
| Billing/quota | Sliding Window Log | Cần tracking chính xác từng request |

## Tóm tắt

| Component | Mô tả |
| --- | --- |
| Fixed Window | INCR + EXPIRE, đơn giản nhất |
| Sliding Window | Sorted Set với timestamps, chính xác |
| Token Bucket | Refill tokens theo thời gian, cho phép burst |
| Gin Middleware | Set X-RateLimit headers, return 429 |
| Key strategy | Per-IP, per-user, per-endpoint |

> **Bài tiếp theo:** Boss Battle — Chúng ta sẽ xây dựng một Mini API Gateway kết hợp rate limiting + session management + caching.
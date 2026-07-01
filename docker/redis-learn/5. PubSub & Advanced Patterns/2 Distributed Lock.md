**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/c22af3a2-c747-4c4c-8e7a-9bc2e6d99e82](https://code4func.com/learn/redis-and-caching-strategies/c22af3a2-c747-4c4c-8e7a-9bc2e6d99e82)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Distributed Lock với Redis
├── Mục tiêu bài học
├── 1\. Tại sao cần Distributed Lock?
├── 2\. SET NX EX Pattern
│   └── Tại sao cần unique value?
├── 3\. Redlock Algorithm
├── 4\. Production: redsync
├── 5\. Ví dụ: Prevent Double Payment
│   └── Test double payment prevention
├── Terminal 1: Gửi payment
├── Terminal 2: Gửi cùng payment ngay lập tức
├── → 409 Conflict: "payment is already being processed"
├── Sau khi payment 1 xong, gửi lại
└── → 409 Conflict: "payment already processed"
    └── Tóm tắt
```

---

## Distributed Lock với Redis

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Hiểu tại sao cần distributed lock
-   Implement lock bằng SET NX EX pattern
-   Hiểu Redlock algorithm
-   Sử dụng thư viện redsync cho production
-   Xây dựng ví dụ hoàn chỉnh: prevent double payment processing

## 1\. Tại sao cần Distributed Lock?

Trong hệ thống phân tán (multiple servers), `sync.Mutex` của Go không hoạt động — vì nó chỉ lock trong cùng một process.

```
Server 1                      Server 2
┌─────────────────┐          ┌─────────────────┐
│ Go Process      │          │ Go Process      │
│                 │          │                 │
│ sync.Mutex?     │          │ sync.Mutex?     │
│ → Chỉ lock      │          │ → Chỉ lock      │
│   trong process  │          │   trong process  │
│   này!           │          │   này!           │
│                 │          │                 │
│ Request A:      │          │ Request B:      │
│ Process payment │          │ Process payment │
│ for order-123   │          │ for order-123   │
└────────┬────────┘          └────────┬────────┘
         │                            │
         └──── CẢ HAI đều process! ──┘
              → Double payment!
```

**Distributed Lock**: Dùng Redis (hoặc ZooKeeper, etcd) làm "trọng tài" — chỉ **một server** được phép xử lý tại một thời điểm.

```
Server 1                Redis                  Server 2
    │                     │                        │
    │── SET lock NX ────►│                        │
    │◄── OK (acquired) ──│                        │
    │                     │                        │
    │  Processing...      │◄── SET lock NX ───────│
    │                     │── nil (denied) ────────►│
    │                     │                        │
    │  Done!              │                        │  Wait/Retry
    │── DEL lock ────────►│                        │
    │                     │                        │
    │                     │◄── SET lock NX ───────│
    │                     │── OK (acquired) ───────►│
    │                     │                        │  Processing...
```

## 2\. SET NX EX Pattern

Redis `SET key value NX EX seconds` là atomic operation:

-   **NX**: Set only if key does **Not eXist**
-   **EX**: Set **expiry** in seconds (tự giải phóng nếu holder crash)

```
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/google/uuid"
    "github.com/redis/go-redis/v9"
)

// DistributedLock implement distributed lock bằng Redis
type DistributedLock struct {
    rdb    *redis.Client
    key    string
    value  string        // Unique value để đảm bảo chỉ owner mới unlock được
    ttl    time.Duration
}

// NewLock tạo lock mới
func NewLock(rdb *redis.Client, resource string, ttl time.Duration) *DistributedLock {
    return &DistributedLock{
        rdb:   rdb,
        key:   "lock:" + resource,
        value: uuid.New().String(), // Unique per lock instance
        ttl:   ttl,
    }
}

// Acquire cố gắng lấy lock
func (dl *DistributedLock) Acquire(ctx context.Context) (bool, error) {
    // SET key value NX EX ttl — atomic
    ok, err := dl.rdb.SetNX(ctx, dl.key, dl.value, dl.ttl).Result()
    return ok, err
}

// Release giải phóng lock (chỉ nếu mình là owner)
func (dl *DistributedLock) Release(ctx context.Context) (bool, error) {
    // Lua script: chỉ DEL nếu value khớp (tránh xóa lock của người khác)
    script := redis.NewScript(`
        if redis.call("GET", KEYS[1]) == ARGV[1] then
            return redis.call("DEL", KEYS[1])
        else
            return 0
        end
    `)

    result, err := script.Run(ctx, dl.rdb, []string{dl.key}, dl.value).Int64()
    return result == 1, err
}

// AcquireWithRetry thử lấy lock với retry
func (dl *DistributedLock) AcquireWithRetry(ctx context.Context, maxRetries int, retryDelay time.Duration) (bool, error) {
    for i := 0; i < maxRetries; i++ {
        acquired, err := dl.Acquire(ctx)
        if err != nil {
            return false, err
        }
        if acquired {
            return true, nil
        }

        // Chờ rồi retry
        select {
        case <-ctx.Done():
            return false, ctx.Err()
        case <-time.After(retryDelay):
        }
    }
    return false, nil
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // Tạo lock cho resource "payment:order-123"
    lock := NewLock(rdb, "payment:order-123", 30*time.Second)

    // Acquire lock
    acquired, err := lock.AcquireWithRetry(ctx, 5, 200*time.Millisecond)
    if err != nil {
        panic(err)
    }
    if !acquired {
        fmt.Println("Could not acquire lock — someone else is processing")
        return
    }

    fmt.Println("Lock acquired! Processing payment...")

    // Xử lý payment (critical section)
    time.Sleep(2 * time.Second)
    fmt.Println("Payment processed successfully")

    // Release lock
    released, _ := lock.Release(ctx)
    fmt.Printf("Lock released: %v\n", released)
}
```

### Tại sao cần unique value?

```
Không có unique value → Bug:

T=0:  Server A lấy lock (TTL 10s)
T=11: Lock hết hạn (A vẫn đang xử lý chậm)
T=12: Server B lấy lock mới
T=13: Server A xong → DEL lock
      → Xóa lock của Server B! → Server C có thể lấy lock
      → Hai server (B và C) cùng xử lý!

Có unique value → Safe:

T=0:  Server A lấy lock, value="a-uuid"
T=11: Lock hết hạn
T=12: Server B lấy lock mới, value="b-uuid"
T=13: Server A xong → Lua: GET lock == "a-uuid"? NO! → Không xóa
      → Lock của B vẫn an toàn
```

## 3\. Redlock Algorithm

SET NX EX hoạt động tốt với **một Redis server**. Nhưng nếu Redis crash, lock mất. **Redlock** giải quyết bằng cách dùng **N Redis instances** (khuyến nghị N=5).

```
Redlock Algorithm:

1. Lấy timestamp hiện tại (T1)
2. Lần lượt SET NX EX trên N Redis instances
3. Lock thành công nếu:
   - Acquired trên >= N/2 + 1 instances (majority)
   - Tổng thời gian acquire < TTL
4. Effective TTL = original TTL - (T_now - T1)
5. Nếu thất bại → unlock tất cả instances

┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ Redis 1 │ │ Redis 2 │ │ Redis 3 │ │ Redis 4 │ │ Redis 5 │
│   ✓     │ │   ✓     │ │   ✗     │ │   ✓     │ │   ✓     │
└─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
                          │
                    4/5 = majority ✓ → Lock acquired!
```

## 4\. Production: redsync

Thư viện `redsync` implement Redlock algorithm cho Go:

```
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    goredislib "github.com/redis/go-redis/v9"
    "github.com/go-redsync/redsync/v4"
    "github.com/go-redsync/redsync/v4/redis/goredis/v9"
)

func main() {
    // Kết nối Redis
    client := goredislib.NewClient(&goredislib.Options{
        Addr: "localhost:6379",
    })
    defer client.Close()

    // Tạo redsync pool
    pool := goredis.NewPool(client)
    rs := redsync.New(pool)

    // Tạo mutex cho resource
    mutex := rs.NewMutex("lock:payment:order-456",
        redsync.WithExpiry(30*time.Second),     // Lock TTL
        redsync.WithTries(5),                   // Retry 5 lần
        redsync.WithRetryDelay(200*time.Millisecond), // Delay giữa retries
    )

    // Acquire lock
    if err := mutex.Lock(); err != nil {
        log.Fatalf("Could not acquire lock: %v", err)
    }
    fmt.Println("Lock acquired!")

    // Critical section
    processPayment("order-456")

    // Release lock
    if ok, err := mutex.Unlock(); !ok || err != nil {
        log.Fatalf("Could not release lock: %v", err)
    }
    fmt.Println("Lock released!")

    _ = context.Background() // suppress unused import
}

func processPayment(orderID string) {
    fmt.Printf("Processing payment for %s...\n", orderID)
    time.Sleep(2 * time.Second) // Giả lập
    fmt.Println("Payment processed!")
}
```

## 5\. Ví dụ: Prevent Double Payment

```
package main

import (
    "context"
    "errors"
    "fmt"
    "log"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
    "github.com/redis/go-redis/v9"
)

// PaymentService xử lý thanh toán với distributed lock
type PaymentService struct {
    rdb *redis.Client
}

func NewPaymentService(rdb *redis.Client) *PaymentService {
    return &PaymentService{rdb: rdb}
}

// ProcessPayment xử lý payment với lock
func (ps *PaymentService) ProcessPayment(ctx context.Context, orderID string, amount float64) error {
    lockKey := "lock:payment:" + orderID
    lockValue := uuid.New().String()
    lockTTL := 30 * time.Second

    // 1. Acquire lock
    acquired, err := ps.rdb.SetNX(ctx, lockKey, lockValue, lockTTL).Result()
    if err != nil {
        return fmt.Errorf("lock error: %w", err)
    }
    if !acquired {
        return errors.New("payment is already being processed")
    }

    // 2. Defer release lock
    defer func() {
        script := redis.NewScript(`
            if redis.call("GET", KEYS[1]) == ARGV[1] then
                return redis.call("DEL", KEYS[1])
            end
            return 0
        `)
        script.Run(ctx, ps.rdb, []string{lockKey}, lockValue)
    }()

    // 3. Check idempotency (đã xử lý chưa?)
    processed, err := ps.rdb.Exists(ctx, "payment:done:"+orderID).Result()
    if err != nil {
        return fmt.Errorf("check idempotency: %w", err)
    }
    if processed > 0 {
        return errors.New("payment already processed")
    }

    // 4. Process payment (critical section)
    fmt.Printf("Processing payment: order=%s, amount=%.2f\n", orderID, amount)
    time.Sleep(2 * time.Second) // Giả lập call payment gateway

    // 5. Mark as processed (idempotency key, TTL 24h)
    ps.rdb.Set(ctx, "payment:done:"+orderID, "completed", 24*time.Hour)

    fmt.Printf("Payment completed: order=%s\n", orderID)
    return nil
}

func main() {
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    if err := rdb.Ping(context.Background()).Err(); err != nil {
        log.Fatal(err)
    }

    ps := NewPaymentService(rdb)

    r := gin.Default()

    r.POST("/payments", func(c *gin.Context) {
        var req struct {
            OrderID string  `json:"order_id" binding:"required"`
            Amount  float64 `json:"amount" binding:"required"`
        }
        if err := c.ShouldBindJSON(&req); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }

        err := ps.ProcessPayment(c.Request.Context(), req.OrderID, req.Amount)
        if err != nil {
            if err.Error() == "payment is already being processed" {
                c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
                return
            }
            if err.Error() == "payment already processed" {
                c.JSON(http.StatusConflict, gin.H{
                    "error":   err.Error(),
                    "message": "This payment was already completed",
                })
                return
            }
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }

        c.JSON(http.StatusOK, gin.H{
            "message":  "Payment processed successfully",
            "order_id": req.OrderID,
        })
    })

    r.Run(":8080")
}
```

### Test double payment prevention

```
# Terminal 1: Gửi payment
curl -X POST http://localhost:8080/payments \
  -H "Content-Type: application/json" \
  -d '{"order_id":"order-123","amount":100000}'

# Terminal 2: Gửi cùng payment ngay lập tức
curl -X POST http://localhost:8080/payments \
  -H "Content-Type: application/json" \
  -d '{"order_id":"order-123","amount":100000}'
# → 409 Conflict: "payment is already being processed"

# Sau khi payment 1 xong, gửi lại
curl -X POST http://localhost:8080/payments \
  -H "Content-Type: application/json" \
  -d '{"order_id":"order-123","amount":100000}'
# → 409 Conflict: "payment already processed"
```

## Tóm tắt

| Khái niệm | Mô tả |
| --- | --- |
| Distributed Lock | Lock resource trên shared storage (Redis) |
| SET NX EX | Atomic acquire: set if not exists with expiry |
| Unique value | Đảm bảo chỉ owner mới release được |
| Lua script | Atomic check-and-delete cho release |
| Redlock | Acquire trên majority (N/2+1) Redis instances |
| redsync | Production library implement Redlock |
| Idempotency | Kết hợp lock + idempotency key tránh double processing |

> **Bài tiếp theo:** Redis Streams — giải pháp cho reliable messaging, consumer groups, và event sourcing.
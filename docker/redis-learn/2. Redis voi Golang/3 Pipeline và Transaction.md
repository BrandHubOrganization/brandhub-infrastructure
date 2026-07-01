**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/25d7bec3-7202-41ba-b13d-91118bf61f38](https://code4func.com/learn/redis-and-caching-strategies/25d7bec3-7202-41ba-b13d-91118bf61f38)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Pipeline và Transaction trong Redis
├── Mục tiêu bài học
├── 1\. Vấn đề: Round-trip Latency
├── 2\. Pipeline — Batch nhiều commands
│   ├── Pipeline cơ bản trong go-redis
│   ├── Pipelined — Cách viết gọn hơn
│   └── Pipeline cho batch operations
├── 3\. Transaction — MULTI/EXEC
│   └── TxPipeline trong go-redis
├── 4\. WATCH — Optimistic Locking
│   └── Giải thích WATCH flow
├── 5\. Performance Comparison
├── 6\. Khi nào dùng gì?
└── Tóm tắt
```

---

## Pipeline và Transaction trong Redis

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Hiểu Pipeline là gì và tại sao giúp tăng performance đáng kể
-   Sử dụng Pipeline trong go-redis để batch commands
-   Hiểu Transaction (MULTI/EXEC) với TxPipeline
-   Implement optimistic locking với WATCH
-   So sánh performance giữa pipeline và individual commands

## 1\. Vấn đề: Round-trip Latency

Mỗi Redis command cần một vòng network round-trip:

```
Client              Redis Server
  │                     │
  │── SET key1 val1 ───►│
  │◄─── OK ────────────│   Round-trip 1 (~0.5ms)
  │                     │
  │── SET key2 val2 ───►│
  │◄─── OK ────────────│   Round-trip 2 (~0.5ms)
  │                     │
  │── SET key3 val3 ───►│
  │◄─── OK ────────────│   Round-trip 3 (~0.5ms)
  │                     │
  Total: ~1.5ms cho 3 commands
```

Nếu bạn cần gửi 1000 commands → 1000 round-trips → ~500ms. Với Redis command chỉ mất microseconds, phần lớn thời gian là **network latency**, không phải processing time.

## 2\. Pipeline — Batch nhiều commands

Pipeline gửi tất cả commands cùng lúc, không chờ response từng cái:

```
Client                    Redis Server
  │                           │
  │── SET key1 val1 ─────────►│
  │── SET key2 val2 ─────────►│   Gửi tất cả cùng lúc
  │── SET key3 val3 ─────────►│
  │                           │
  │◄─── OK ──────────────────│
  │◄─── OK ──────────────────│   Nhận tất cả response
  │◄─── OK ──────────────────│
  │                           │
  Total: ~0.5ms cho 3 commands (1 round-trip!)
```

### Pipeline cơ bản trong go-redis

```
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // === Pipeline gửi nhiều commands ===
    pipe := rdb.Pipeline()

    // Queue commands (chưa gửi đi)
    incr := pipe.Incr(ctx, "pipeline:counter")
    pipe.Expire(ctx, "pipeline:counter", time.Hour)
    set1 := pipe.Set(ctx, "pipeline:key1", "value1", time.Minute)
    set2 := pipe.Set(ctx, "pipeline:key2", "value2", time.Minute)
    get1 := pipe.Get(ctx, "pipeline:key1")

    // Exec — gửi tất cả và nhận response
    _, err := pipe.Exec(ctx)
    if err != nil {
        log.Fatal(err)
    }

    // Đọc kết quả
    fmt.Printf("Counter: %d\n", incr.Val())
    fmt.Printf("Set1: %s\n", set1.Val())
    fmt.Printf("Set2: %s\n", set2.Val())
    fmt.Printf("Get1: %s\n", get1.Val())

    // Cleanup
    rdb.Del(ctx, "pipeline:counter", "pipeline:key1", "pipeline:key2")
}
```

### Pipelined — Cách viết gọn hơn

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
    defer rdb.Close()

    // Pipelined — tự động Exec khi function kết thúc
    var getCmd *redis.StringCmd

    cmds, err := rdb.Pipelined(ctx, func(pipe redis.Pipeliner) error {
        pipe.Set(ctx, "pl:name", "Nguyen Van A", 5*time.Minute)
        pipe.Set(ctx, "pl:email", "a@test.com", 5*time.Minute)
        pipe.Incr(ctx, "pl:visits")
        getCmd = pipe.Get(ctx, "pl:name")
        return nil
    })

    if err != nil {
        fmt.Printf("Pipeline error: %v\n", err)
    }

    fmt.Printf("Executed %d commands\n", len(cmds))
    fmt.Printf("Name: %s\n", getCmd.Val())

    // Duyệt qua tất cả results
    for i, cmd := range cmds {
        fmt.Printf("  cmd[%d]: %s\n", i, cmd.String())
    }

    // Cleanup
    rdb.Del(ctx, "pl:name", "pl:email", "pl:visits")
}
```

### Pipeline cho batch operations

```
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

type Product struct {
    ID    string  `json:"id"`
    Name  string  `json:"name"`
    Price float64 `json:"price"`
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // Giả lập danh sách products từ database
    products := []Product{
        {ID: "p1", Name: "iPhone 15", Price: 999},
        {ID: "p2", Name: "MacBook Pro", Price: 2499},
        {ID: "p3", Name: "AirPods Pro", Price: 249},
        {ID: "p4", Name: "iPad Air", Price: 599},
        {ID: "p5", Name: "Apple Watch", Price: 399},
    }

    // Cache tất cả products bằng pipeline (1 round-trip)
    pipe := rdb.Pipeline()
    for _, p := range products {
        data, _ := json.Marshal(p)
        pipe.Set(ctx, "product:"+p.ID, data, 30*time.Minute)
    }
    _, err := pipe.Exec(ctx)
    if err != nil {
        fmt.Printf("Cache error: %v\n", err)
    }
    fmt.Printf("Cached %d products in 1 round-trip\n", len(products))

    // Đọc tất cả products bằng pipeline (1 round-trip)
    getterPipe := rdb.Pipeline()
    cmds := make([]*redis.StringCmd, len(products))
    for i, p := range products {
        cmds[i] = getterPipe.Get(ctx, "product:"+p.ID)
    }
    getterPipe.Exec(ctx)

    for _, cmd := range cmds {
        var p Product
        json.Unmarshal([]byte(cmd.Val()), &p)
        fmt.Printf("  %s: %s ($%.0f)\n", p.ID, p.Name, p.Price)
    }

    // Cleanup
    pipe2 := rdb.Pipeline()
    for _, p := range products {
        pipe2.Del(ctx, "product:"+p.ID)
    }
    pipe2.Exec(ctx)
}
```

## 3\. Transaction — MULTI/EXEC

Pipeline không đảm bảo atomicity — các commands có thể bị xen kẽ bởi commands từ clients khác. Transaction (MULTI/EXEC) đảm bảo tất cả commands chạy **atomic** — không ai xen vào giữa.

### TxPipeline trong go-redis

```
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // Setup test data
    rdb.Set(ctx, "account:A:balance", "1000", 0)
    rdb.Set(ctx, "account:B:balance", "500", 0)

    // === Transaction: Chuyển tiền từ A sang B ===
    // Tất cả commands trong TxPipeline chạy atomic
    txPipe := rdb.TxPipeline()

    txPipe.DecrBy(ctx, "account:A:balance", 200) // A - 200
    txPipe.IncrBy(ctx, "account:B:balance", 200) // B + 200
    txPipe.Set(ctx, "transfer:log:1", "A->B:200", 24*time.Hour)

    _, err := txPipe.Exec(ctx)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println("Transfer completed atomically")

    // Kiểm tra kết quả
    balA, _ := rdb.Get(ctx, "account:A:balance").Int()
    balB, _ := rdb.Get(ctx, "account:B:balance").Int()
    fmt.Printf("Account A: %d\n", balA) // 800
    fmt.Printf("Account B: %d\n", balB) // 700

    // === TxPipelined — cách viết gọn hơn ===
    _, err = rdb.TxPipelined(ctx, func(pipe redis.Pipeliner) error {
        pipe.IncrBy(ctx, "account:A:balance", 200) // Hoàn tiền
        pipe.DecrBy(ctx, "account:B:balance", 200)
        pipe.Del(ctx, "transfer:log:1")
        return nil
    })
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println("Transfer reversed")

    // Cleanup
    rdb.Del(ctx, "account:A:balance", "account:B:balance")
}
```

## 4\. WATCH — Optimistic Locking

WATCH cho phép thực hiện **check-and-set** atomic. Nếu watched keys bị thay đổi bởi client khác trước khi EXEC, transaction sẽ fail.

```
package main

import (
    "context"
    "fmt"
    "log"
    "strconv"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    rdb.Set(ctx, "product:stock:1", "10", 0)

    // === WATCH + Transaction: Giảm stock an toàn ===
    err := decrementStock(ctx, rdb, "product:stock:1", 3)
    if err != nil {
        log.Fatal(err)
    }

    stock, _ := rdb.Get(ctx, "product:stock:1").Int()
    fmt.Printf("Stock after purchase: %d\n", stock) // 7

    // Cleanup
    rdb.Del(ctx, "product:stock:1")
}

// decrementStock giảm stock atomic với optimistic locking
func decrementStock(ctx context.Context, rdb *redis.Client, key string, quantity int) error {
    // Retry loop — nếu bị conflict, thử lại
    for retries := 0; retries < 5; retries++ {
        err := rdb.Watch(ctx, func(tx *redis.Tx) error {
            // Đọc stock hiện tại (trong WATCH)
            currentStock, err := tx.Get(ctx, key).Int()
            if err != nil {
                return err
            }

            // Kiểm tra đủ stock
            if currentStock < quantity {
                return fmt.Errorf("insufficient stock: have %d, need %d", currentStock, quantity)
            }

            // Tính stock mới
            newStock := currentStock - quantity

            // Transaction — nếu key bị thay đổi từ lúc WATCH, sẽ fail
            _, err = tx.TxPipelined(ctx, func(pipe redis.Pipeliner) error {
                pipe.Set(ctx, key, strconv.Itoa(newStock), 0)
                return nil
            })
            return err
        }, key) // WATCH key "product:stock:1"

        if err == nil {
            return nil // Thành công
        }
        if err == redis.TxFailedErr {
            fmt.Printf("  Conflict detected, retry %d/5...\n", retries+1)
            continue // Retry
        }
        return err // Error thực sự
    }

    return fmt.Errorf("max retries exceeded for stock decrement")
}
```

### Giải thích WATCH flow

```
Client A                    Redis                    Client B
  │                           │                         │
  │── WATCH stock ───────────►│                         │
  │                           │                         │
  │── GET stock ─────────────►│                         │
  │◄── "10" ─────────────────│                         │
  │                           │                         │
  │                           │◄── SET stock 8 ────────│ (Client B mua 2)
  │                           │── OK ──────────────────►│
  │                           │                         │
  │── MULTI ─────────────────►│                         │
  │── SET stock 7 ───────────►│                         │
  │── EXEC ──────────────────►│                         │
  │◄── nil (FAILED!) ────────│   stock đã bị B thay đổi!
  │                           │
  │   (retry từ đầu)          │
  │── WATCH stock ───────────►│
  │── GET stock ─────────────►│
  │◄── "8" ──────────────────│
  │── MULTI ─────────────────►│
  │── SET stock 5 ───────────►│
  │── EXEC ──────────────────►│
  │◄── OK ───────────────────│   Thành công!
```

## 5\. Performance Comparison

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
    defer rdb.Close()

    n := 1000

    // === Test 1: Individual commands ===
    start := time.Now()
    for i := 0; i < n; i++ {
        rdb.Set(ctx, fmt.Sprintf("bench:ind:%d", i), "value", time.Minute)
    }
    individualDuration := time.Since(start)

    // === Test 2: Pipeline ===
    start = time.Now()
    pipe := rdb.Pipeline()
    for i := 0; i < n; i++ {
        pipe.Set(ctx, fmt.Sprintf("bench:pipe:%d", i), "value", time.Minute)
    }
    pipe.Exec(ctx)
    pipelineDuration := time.Since(start)

    // === Test 3: Transaction ===
    start = time.Now()
    rdb.TxPipelined(ctx, func(pipe redis.Pipeliner) error {
        for i := 0; i < n; i++ {
            pipe.Set(ctx, fmt.Sprintf("bench:tx:%d", i), "value", time.Minute)
        }
        return nil
    })
    txDuration := time.Since(start)

    fmt.Printf("=== %d SET commands ===\n", n)
    fmt.Printf("Individual: %v (%.0f ops/sec)\n",
        individualDuration,
        float64(n)/individualDuration.Seconds())
    fmt.Printf("Pipeline:   %v (%.0f ops/sec) — %.1fx faster\n",
        pipelineDuration,
        float64(n)/pipelineDuration.Seconds(),
        float64(individualDuration)/float64(pipelineDuration))
    fmt.Printf("Transaction: %v (%.0f ops/sec) — %.1fx faster\n",
        txDuration,
        float64(n)/txDuration.Seconds(),
        float64(individualDuration)/float64(txDuration))

    // Cleanup
    pipe2 := rdb.Pipeline()
    for i := 0; i < n; i++ {
        pipe2.Del(ctx, fmt.Sprintf("bench:ind:%d", i))
        pipe2.Del(ctx, fmt.Sprintf("bench:pipe:%d", i))
        pipe2.Del(ctx, fmt.Sprintf("bench:tx:%d", i))
    }
    pipe2.Exec(ctx)
}
```

**Kết quả điển hình (localhost):**

| Phương pháp | Thời gian | Ops/sec | So với individual |
| --- | --- | --- | --- |
| Individual | ~150ms | ~6,600 | 1x |
| Pipeline | ~5ms | ~200,000 | 30x nhanh hơn |
| Transaction | ~5ms | ~200,000 | 30x nhanh hơn |

> **Kết luận:** Pipeline nhanh hơn **20-50x** so với individual commands. Luôn dùng pipeline khi cần gửi nhiều commands không phụ thuộc nhau. Dùng transaction khi cần atomicity.

## 6\. Khi nào dùng gì?

| Tình huống | Dùng | Lý do |
| --- | --- | --- |
| Batch SET/GET không liên quan | Pipeline | Nhanh, không cần atomic |
| Chuyển tiền giữa 2 accounts | TxPipeline | Cần atomic |
| Giảm stock (concurrent) | WATCH + TxPipeline | Cần check-and-set |
| Cache warming (load nhiều data) | Pipeline | Batch insert nhanh |
| Read-modify-write | WATCH + TxPipeline | Tránh race condition |

## Tóm tắt

| Khái niệm | Mô tả |
| --- | --- |
| Pipeline | Gửi nhiều commands trong 1 round-trip, không atomic |
| TxPipeline | Transaction (MULTI/EXEC), atomic |
| WATCH | Optimistic locking — fail nếu key bị thay đổi |
| Pipelined() | Helper function, tự Exec khi kết thúc |
| TxPipelined() | Helper function cho transaction |
| Performance | Pipeline nhanh hơn 20-50x so với individual |

> **Bài tiếp theo:** Chúng ta sẽ xây dựng một hệ thống bảng xếp hạng (leaderboard) hoàn chỉnh sử dụng Sorted Set — một dự án thực hành tổng hợp kiến thức Redis với Go.
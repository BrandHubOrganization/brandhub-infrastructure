**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/6d53ac18-500b-4096-a05d-05e70d01a7cd](https://code4func.com/learn/redis-and-caching-strategies/6d53ac18-500b-4096-a05d-05e70d01a7cd)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Redis Streams
├── Mục tiêu bài học
├── 1\. Redis Streams vs Pub/Sub
├── 2\. Stream Basics
│   └── XADD — Thêm message vào stream
├── XADD stream_name ID field1 value1 field2 value2
├── ID = * → Redis tự tạo (timestamp-based)
│   └── XRANGE — Đọc messages theo range
├── Tất cả messages
├── Giới hạn số lượng
├── Từ ID cụ thể
│   └── XREAD — Đọc messages mới (blocking)
├── Đọc messages mới nhất (non-blocking)
├── 0 = từ đầu, $ = chỉ messages mới từ bây giờ
└── Blocking — chờ messages mới (timeout 5000ms)
    ├── 3\. Go Implementation
    ├── 4\. Consumer Groups
    │   └── Consumer Group trong Go
    ├── 5\. Handling Failed Messages
    ├── 6\. Use Case: Event Sourcing
    └── Tóm tắt
```

---

## Redis Streams

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Hiểu Redis Streams khác Pub/Sub như thế nào
-   Sử dụng XADD, XREAD, XRANGE để đọc/ghi streams
-   Implement Consumer Groups: XGROUP, XREADGROUP, XACK
-   Viết code Go với go-redis cho Streams
-   Biết use cases: event sourcing, message queue, activity log

## 1\. Redis Streams vs Pub/Sub

| Tính năng | Pub/Sub | Streams |
| --- | --- | --- |
| Persistence | Không | Có — messages được lưu |
| Consumer Groups | Không | Có — chia tải giữa consumers |
| Acknowledgment | Không | Có — XACK khi xử lý xong |
| Replay | Không | Có — đọc lại messages cũ |
| Delivery | At-most-once | At-least-once |
| Use case | Real-time notifications | Message queue, event sourcing |

**Redis Streams** giống **Apache Kafka** nhưng đơn giản hơn nhiều — phù hợp cho ứng dụng vừa và nhỏ.

## 2\. Stream Basics

### XADD — Thêm message vào stream

```
# XADD stream_name ID field1 value1 field2 value2
# ID = * → Redis tự tạo (timestamp-based)
127.0.0.1:6379> XADD events * action "user_login" user_id "u001" ip "127.0.0.1"
"1700000001234-0"

127.0.0.1:6379> XADD events * action "page_view" user_id "u001" page "/courses"
"1700000001235-0"

127.0.0.1:6379> XADD events * action "course_enroll" user_id "u001" course_id "c001"
"1700000001236-0"
```

### XRANGE — Đọc messages theo range

```
# Tất cả messages
127.0.0.1:6379> XRANGE events - +
1) 1) "1700000001234-0"
   2) 1) "action" 2) "user_login" 3) "user_id" 4) "u001" 5) "ip" 6) "127.0.0.1"
2) 1) "1700000001235-0"
   2) 1) "action" 2) "page_view" 3) "user_id" 4) "u001" 5) "page" 6) "/courses"
3) 1) "1700000001236-0"
   2) 1) "action" 2) "course_enroll" 3) "user_id" 4) "u001" 5) "course_id" 6) "c001"

# Giới hạn số lượng
127.0.0.1:6379> XRANGE events - + COUNT 2

# Từ ID cụ thể
127.0.0.1:6379> XRANGE events 1700000001235-0 +
```

### XREAD — Đọc messages mới (blocking)

```
# Đọc messages mới nhất (non-blocking)
127.0.0.1:6379> XREAD COUNT 10 STREAMS events 0
# 0 = từ đầu, $ = chỉ messages mới từ bây giờ

# Blocking — chờ messages mới (timeout 5000ms)
127.0.0.1:6379> XREAD BLOCK 5000 COUNT 10 STREAMS events $
```

## 3\. Go Implementation

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

    streamKey := "mystream:events"

    // === XADD — Thêm messages ===
    id1, err := rdb.XAdd(ctx, &redis.XAddArgs{
        Stream: streamKey,
        Values: map[string]interface{}{
            "action":  "user_login",
            "user_id": "u001",
            "ip":      "127.0.0.1",
        },
    }).Result()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Added message: %s\n", id1)

    rdb.XAdd(ctx, &redis.XAddArgs{
        Stream: streamKey,
        Values: map[string]interface{}{
            "action":    "course_enroll",
            "user_id":   "u001",
            "course_id": "go-basics",
        },
    })

    rdb.XAdd(ctx, &redis.XAddArgs{
        Stream: streamKey,
        Values: map[string]interface{}{
            "action":  "xp_earned",
            "user_id": "u001",
            "amount":  "50",
        },
    })

    // === XRANGE — Đọc tất cả messages ===
    messages, err := rdb.XRange(ctx, streamKey, "-", "+").Result()
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println("\n=== All Messages ===")
    for _, msg := range messages {
        fmt.Printf("ID: %s\n", msg.ID)
        for k, v := range msg.Values {
            fmt.Printf("  %s: %v\n", k, v)
        }
    }

    // === XLEN — Đếm messages ===
    length, _ := rdb.XLen(ctx, streamKey).Result()
    fmt.Printf("\nStream length: %d\n", length)

    // === XREAD — Đọc messages mới (non-blocking) ===
    results, err := rdb.XRead(ctx, &redis.XReadArgs{
        Streams: []string{streamKey, "0"}, // Stream name, start ID
        Count:   10,
    }).Result()
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println("\n=== XREAD Results ===")
    for _, stream := range results {
        fmt.Printf("Stream: %s\n", stream.Stream)
        for _, msg := range stream.Messages {
            fmt.Printf("  %s: %v\n", msg.ID, msg.Values)
        }
    }

    // === XTRIM — Giới hạn size ===
    // Giữ tối đa 1000 messages
    rdb.XTrimMaxLen(ctx, streamKey, 1000)

    // Cleanup
    rdb.Del(ctx, streamKey)
    _ = time.Now() // suppress unused
}
```

## 4\. Consumer Groups

Consumer Groups cho phép **nhiều consumers cùng đọc stream** mà mỗi message chỉ được xử lý bởi **một consumer** (load balancing).

```
Stream: ─── msg1 ── msg2 ── msg3 ── msg4 ── msg5 ── msg6 ───►

Consumer Group "workers":
  Consumer A: ──── msg1 ──── msg3 ──── msg5 ────
  Consumer B: ──── msg2 ──── msg4 ──── msg6 ────

Mỗi message chỉ được giao cho MỘT consumer.
Consumer phải XACK khi xử lý xong.
Nếu không ACK → message có thể được reassign.
```

### Consumer Group trong Go

```
package main

import (
    "context"
    "fmt"
    "log"
    "sync"
    "time"

    "github.com/redis/go-redis/v9"
)

const (
    streamKey = "jobs:stream"
    groupName = "workers"
)

// Producer thêm jobs vào stream
func producer(ctx context.Context, rdb *redis.Client, count int) {
    for i := 0; i < count; i++ {
        rdb.XAdd(ctx, &redis.XAddArgs{
            Stream: streamKey,
            Values: map[string]interface{}{
                "job_type": "send_email",
                "to":       fmt.Sprintf("user%d@test.com", i),
                "subject":  fmt.Sprintf("Welcome #%d", i),
            },
        })
    }
    fmt.Printf("[Producer] Added %d jobs\n", count)
}

// Consumer đọc và xử lý jobs
func consumer(ctx context.Context, rdb *redis.Client, consumerName string, wg *sync.WaitGroup) {
    defer wg.Done()

    for {
        // XREADGROUP — đọc messages mới cho consumer này
        results, err := rdb.XReadGroup(ctx, &redis.XReadGroupArgs{
            Group:    groupName,
            Consumer: consumerName,
            Streams:  []string{streamKey, ">"}, // ">" = chỉ messages mới
            Count:    1,
            Block:    2 * time.Second,
        }).Result()

        if err != nil {
            if err.Error() == "redis: nil" {
                // Timeout — không có message mới
                fmt.Printf("[%s] No new messages, stopping\n", consumerName)
                return
            }
            log.Printf("[%s] Error: %v", consumerName, err)
            return
        }

        for _, stream := range results {
            for _, msg := range stream.Messages {
                // Xử lý job
                fmt.Printf("[%s] Processing job %s: to=%v\n",
                    consumerName, msg.ID, msg.Values["to"])

                // Giả lập xử lý
                time.Sleep(100 * time.Millisecond)

                // ACK — xác nhận đã xử lý xong
                rdb.XAck(ctx, streamKey, groupName, msg.ID)
                fmt.Printf("[%s] ACK: %s\n", consumerName, msg.ID)
            }
        }
    }
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // Xóa stream cũ nếu có
    rdb.Del(ctx, streamKey)

    // Tạo consumer group
    // MKSTREAM tạo stream nếu chưa tồn tại
    err := rdb.XGroupCreateMkStream(ctx, streamKey, groupName, "0").Err()
    if err != nil && err.Error() != "BUSYGROUP Consumer Group name already exists" {
        log.Fatal(err)
    }

    // Producer thêm 10 jobs
    producer(ctx, rdb, 10)

    // Chạy 3 consumers
    var wg sync.WaitGroup
    for i := 1; i <= 3; i++ {
        wg.Add(1)
        go consumer(ctx, rdb, fmt.Sprintf("worker-%d", i), &wg)
    }

    wg.Wait()
    fmt.Println("\nAll jobs processed!")

    // Kiểm tra pending messages (chưa ACK)
    pending, _ := rdb.XPending(ctx, streamKey, groupName).Result()
    fmt.Printf("Pending messages: %d\n", pending.Count)

    // Cleanup
    rdb.Del(ctx, streamKey)
}
```

## 5\. Handling Failed Messages

Nếu consumer crash trước khi ACK, message nằm trong **pending list**. Cần cơ chế claim lại messages:

```
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

// ClaimStaleMessages lấy lại messages pending quá lâu
func ClaimStaleMessages(ctx context.Context, rdb *redis.Client, stream, group, consumer string, maxIdle time.Duration) {
    // Tìm messages pending > maxIdle
    pending, err := rdb.XPendingExt(ctx, &redis.XPendingExtArgs{
        Stream: stream,
        Group:  group,
        Start:  "-",
        End:    "+",
        Count:  10,
        Idle:   maxIdle,
    }).Result()

    if err != nil || len(pending) == 0 {
        return
    }

    // Claim messages
    ids := make([]string, len(pending))
    for i, p := range pending {
        ids[i] = p.ID
        fmt.Printf("Claiming stale message: %s (idle: %v, retries: %d)\n",
            p.ID, p.Idle, p.RetryCount)
    }

    // XCLAIM — chuyển ownership sang consumer hiện tại
    messages, err := rdb.XClaim(ctx, &redis.XClaimArgs{
        Stream:   stream,
        Group:    group,
        Consumer: consumer,
        MinIdle:  maxIdle,
        Messages: ids,
    }).Result()

    if err != nil {
        fmt.Printf("Claim error: %v\n", err)
        return
    }

    // Xử lý lại messages
    for _, msg := range messages {
        fmt.Printf("Re-processing claimed message: %s\n", msg.ID)
        // ... xử lý ...
        rdb.XAck(ctx, stream, group, msg.ID)
    }
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // Claim messages pending > 5 phút
    ClaimStaleMessages(ctx, rdb,
        "jobs:stream", "workers", "recovery-worker",
        5*time.Minute,
    )
}
```

## 6\. Use Case: Event Sourcing

```
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

// EventStore lưu trữ events
type EventStore struct {
    rdb *redis.Client
}

func NewEventStore(rdb *redis.Client) *EventStore {
    return &EventStore{rdb: rdb}
}

// Append thêm event vào stream
func (es *EventStore) Append(ctx context.Context, streamKey string, eventType string, data map[string]interface{}) (string, error) {
    values := map[string]interface{}{
        "event_type": eventType,
        "timestamp":  time.Now().UnixMilli(),
    }
    for k, v := range data {
        values[k] = v
    }

    return es.rdb.XAdd(ctx, &redis.XAddArgs{
        Stream: streamKey,
        Values: values,
    }).Result()
}

// GetEvents đọc tất cả events cho entity
func (es *EventStore) GetEvents(ctx context.Context, streamKey string) ([]redis.XMessage, error) {
    return es.rdb.XRange(ctx, streamKey, "-", "+").Result()
}

// GetEventsSince đọc events từ ID
func (es *EventStore) GetEventsSince(ctx context.Context, streamKey, sinceID string) ([]redis.XMessage, error) {
    return es.rdb.XRange(ctx, streamKey, sinceID, "+").Result()
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    store := NewEventStore(rdb)
    orderStream := "events:order:ord-001"

    // Ghi events cho order lifecycle
    store.Append(ctx, orderStream, "order_created", map[string]interface{}{
        "user_id": "u001",
        "amount":  "150000",
    })

    store.Append(ctx, orderStream, "payment_received", map[string]interface{}{
        "payment_method": "bank_transfer",
        "transaction_id": "TX-001",
    })

    store.Append(ctx, orderStream, "order_confirmed", map[string]interface{}{
        "confirmed_by": "system",
    })

    store.Append(ctx, orderStream, "order_shipped", map[string]interface{}{
        "tracking_number": "VN123456789",
        "carrier":         "GHN",
    })

    // Replay events
    events, _ := store.GetEvents(ctx, orderStream)
    fmt.Println("=== Order History ===")
    for _, e := range events {
        fmt.Printf("[%s] %s\n", e.ID, e.Values["event_type"])
        for k, v := range e.Values {
            if k != "event_type" && k != "timestamp" {
                fmt.Printf("  %s: %v\n", k, v)
            }
        }
    }

    // Cleanup
    rdb.Del(ctx, orderStream)
}
```

## Tóm tắt

| Command | Mô tả |
| --- | --- |
| XADD | Thêm message vào stream |
| XRANGE | Đọc messages theo range |
| XREAD | Đọc messages mới (blocking) |
| XLEN | Đếm messages |
| XTRIM | Giới hạn stream size |
| XGROUP CREATE | Tạo consumer group |
| XREADGROUP | Đọc messages cho consumer (group) |
| XACK | Xác nhận đã xử lý message |
| XPENDING | Xem messages chưa ACK |
| XCLAIM | Lấy lại messages từ consumer khác |

> **Bài tiếp theo:** Thực hành cuối cùng — Job Queue đơn giản với Redis Streams, producer/consumer pattern hoàn chỉnh.
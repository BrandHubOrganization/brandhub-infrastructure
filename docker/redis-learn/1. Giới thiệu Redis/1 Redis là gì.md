**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/26b04498-b33c-4e69-b6a9-da6800cee0c8](https://code4func.com/learn/redis-and-caching-strategies/26b04498-b33c-4e69-b6a9-da6800cee0c8)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Redis là gì? Khi nào nên dùng Redis?
├── Mục tiêu bài học
├── 1\. Redis là gì?
│   ├── Redis KHÔNG chỉ là cache
│   └── Tại sao Redis nhanh?
├── 2\. Khi nào nên dùng Redis?
│   ├── Use Case 1: Caching — Giảm tải database
│   ├── Use Case 2: Session Management
│   ├── Use Case 3: Rate Limiting
│   ├── Use Case 4: Leaderboard (Bảng xếp hạng)
│   └── Use Case 5: Pub/Sub — Real-time messaging
├── 3\. Redis vs Memcached
├── 4\. Redis Architecture
│   ├── Single-threaded Event Loop
│   └── Persistence: RDB và AOF
├── redis.conf
├── Save snapshot nếu có ít nhất 1 key thay đổi trong 900 giây
├── Save snapshot nếu có ít nhất 10 keys thay đổi trong 300 giây
├── Save snapshot nếu có ít nhất 10000 keys thay đổi trong 60 giây
├── Tên file snapshot
├── Thư mục lưu file
├── redis.conf
├── Sync policy:
├── appendfsync always   # Mỗi write → fsync (an toàn nhất, chậm nhất)
├── appendfsync no       # Để OS tự fsync (nhanh nhất, rủi ro nhất)
└── redis.conf - Production recommended
    └── 5\. Tóm tắt
```

---

## Redis là gì? Khi nào nên dùng Redis?

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Hiểu Redis là gì và tại sao nó là công cụ không thể thiếu trong backend development
-   Nắm rõ các use case phổ biến: caching, session, rate limiting, leaderboard, pub/sub
-   So sánh Redis với Memcached để biết khi nào chọn công cụ nào
-   Hiểu kiến trúc single-threaded của Redis và cơ chế persistence (RDB/AOF)

## 1\. Redis là gì?

**Redis** (Remote Dictionary Server) là một **in-memory data structure store** — một cơ sở dữ liệu lưu trữ dữ liệu hoàn toàn trên RAM. Redis được tạo bởi Salvatore Sanfilippo (antirez) vào năm 2009 và nhanh chóng trở thành công cụ phổ biến nhất cho caching và real-time data processing.

> **Tại sao gọi là "Remote Dictionary Server"?** Vì Redis hoạt động như một "từ điển" (key-value store) chạy trên một server riêng biệt (remote), cho phép nhiều application cùng truy cập.

### Redis KHÔNG chỉ là cache

Nhiều người nghĩ Redis chỉ dùng để cache, nhưng thực tế Redis hỗ trợ nhiều kiểu dữ liệu phức tạp:

-   **Strings** — key-value đơn giản
-   **Lists** — danh sách có thứ tự
-   **Sets** — tập hợp không trùng lặp
-   **Hashes** — object với nhiều fields
-   **Sorted Sets** — tập hợp có điểm số, tự động sắp xếp
-   **Streams** — log data structure cho event streaming
-   **Bitmaps, HyperLogLog, Geospatial** — các kiểu dữ liệu đặc biệt

### Tại sao Redis nhanh?

Redis đạt được tốc độ đáng kinh ngạc nhờ các yếu tố:

1.  **In-memory storage**: Dữ liệu nằm trên RAM — đọc/ghi nhanh hơn disk hàng nghìn lần
2.  **Single-threaded event loop**: Không cần lock, không context switching
3.  **Efficient data structures**: Các cấu trúc dữ liệu được tối ưu hóa cho từng use case
4.  **I/O multiplexing**: Dùng epoll/kqueue để xử lý hàng nghìn connections đồng thời

**Benchmark thực tế:**

-   **100,000+ operations/giây** trên một server thông thường
-   Latency trung bình: **< 1ms**
-   Với pipeline: có thể đạt **1,000,000+ operations/giây**

## 2\. Khi nào nên dùng Redis?

### Use Case 1: Caching — Giảm tải database

Đây là use case phổ biến nhất. Thay vì query database mỗi lần, lưu kết quả vào Redis.

```
┌──────────┐     1. GET /products        ┌──────────┐
│          │ ──────────────────────────── │          │
│  Client  │                             │  Server  │
│          │     2. Check Redis          │          │
│          │                        ┌────│──────┐   │
│          │                        │  Redis   │   │
│          │                        │  Cache   │   │
│          │                        └────│──────┘   │
│          │                             │          │
│          │     3. Cache MISS →         │          │
│          │        Query PostgreSQL ┌───│──────┐   │
│          │                        │ Postgres │   │
│          │                        └───│──────┘   │
│          │                             │          │
│          │     4. Save to Redis        │          │
│          │     5. Return response      │          │
│          │ ◄─────────────────────────  │          │
└──────────┘                             └──────────┘
```

**Trước khi dùng cache:**

```
package main

import (
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "gorm.io/gorm"
)

type Product struct {
    ID        uint      `json:"id"`
    Name      string    `json:"name"`
    Price     float64   `json:"price"`
    CreatedAt time.Time `json:"created_at"`
}

// Mỗi request đều query database — chậm khi traffic cao
func getProducts(db *gorm.DB) gin.HandlerFunc {
    return func(c *gin.Context) {
        var products []Product
        // Mỗi lần gọi API = 1 query tới PostgreSQL
        // Với 1000 requests/giây → 1000 queries/giây!
        if err := db.Find(&products).Error; err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }
        c.JSON(http.StatusOK, products)
    }
}
```

### Use Case 2: Session Management

Lưu session user trên Redis thay vì file hoặc database:

```
package main

import (
    "context"
    "encoding/json"
    "time"

    "github.com/redis/go-redis/v9"
)

type UserSession struct {
    UserID    string    `json:"user_id"`
    Email     string    `json:"email"`
    Role      string    `json:"role"`
    LoginAt   time.Time `json:"login_at"`
    ExpiresAt time.Time `json:"expires_at"`
}

func saveSession(ctx context.Context, rdb *redis.Client, sessionID string, session UserSession) error {
    data, err := json.Marshal(session)
    if err != nil {
        return err
    }
    // Session tự động hết hạn sau 24 giờ
    return rdb.Set(ctx, "session:"+sessionID, data, 24*time.Hour).Err()
}

func getSession(ctx context.Context, rdb *redis.Client, sessionID string) (*UserSession, error) {
    data, err := rdb.Get(ctx, "session:"+sessionID).Bytes()
    if err != nil {
        return nil, err // redis.Nil nếu session không tồn tại
    }
    var session UserSession
    if err := json.Unmarshal(data, &session); err != nil {
        return nil, err
    }
    return &session, nil
}
```

### Use Case 3: Rate Limiting

Giới hạn số request mỗi user/IP trong khoảng thời gian:

```
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

// Kiểm tra rate limit: tối đa maxRequests trong window
func checkRateLimit(ctx context.Context, rdb *redis.Client, key string, maxRequests int64, window time.Duration) (bool, error) {
    // INCR tăng counter, nếu key chưa tồn tại thì tạo mới = 1
    count, err := rdb.Incr(ctx, key).Result()
    if err != nil {
        return false, err
    }

    // Nếu đây là request đầu tiên, set TTL
    if count == 1 {
        rdb.Expire(ctx, key, window)
    }

    // Cho phép nếu chưa vượt giới hạn
    return count <= maxRequests, nil
}

func main() {
    // Ví dụ: user "user123" chỉ được gọi 100 lần/phút
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    key := fmt.Sprintf("rate_limit:user123:%d", time.Now().Minute())
    allowed, _ := checkRateLimit(ctx, rdb, key, 100, time.Minute)
    fmt.Printf("Request allowed: %v\n", allowed)
}
```

### Use Case 4: Leaderboard (Bảng xếp hạng)

Redis Sorted Set là công cụ hoàn hảo cho leaderboard:

```
package main

import (
    "context"
    "fmt"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    // Thêm điểm cho players
    rdb.ZAdd(ctx, "leaderboard", redis.Z{Score: 1500, Member: "player:alice"})
    rdb.ZAdd(ctx, "leaderboard", redis.Z{Score: 2300, Member: "player:bob"})
    rdb.ZAdd(ctx, "leaderboard", redis.Z{Score: 1800, Member: "player:charlie"})

    // Lấy top 3 players (điểm cao nhất)
    results, _ := rdb.ZRevRangeWithScores(ctx, "leaderboard", 0, 2).Result()
    for i, z := range results {
        fmt.Printf("#%d: %s - %.0f points\n", i+1, z.Member, z.Score)
    }
    // Output:
    // #1: player:bob - 2300 points
    // #2: player:charlie - 1800 points
    // #3: player:alice - 1500 points

    // Lấy rank của một player cụ thể (0-indexed, từ cao nhất)
    rank, _ := rdb.ZRevRank(ctx, "leaderboard", "player:charlie").Result()
    fmt.Printf("Charlie's rank: #%d\n", rank+1) // #2
}
```

### Use Case 5: Pub/Sub — Real-time messaging

Gửi thông báo real-time giữa các service:

```
package main

import (
    "context"
    "fmt"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    // Publisher — gửi notification
    err := rdb.Publish(ctx, "notifications", "Bạn có đơn hàng mới!").Err()
    if err != nil {
        panic(err)
    }

    // Subscriber — nhận notification (chạy trong goroutine khác)
    sub := rdb.Subscribe(ctx, "notifications")
    ch := sub.Channel()
    for msg := range ch {
        fmt.Printf("Received: %s from channel %s\n", msg.Payload, msg.Channel)
    }
}
```

## 3\. Redis vs Memcached

| Tiêu chí | Redis | Memcached |
| --- | --- | --- |
| Kiểu dữ liệu | Strings, Lists, Sets, Hashes, Sorted Sets, Streams | Chỉ Strings |
| Persistence | RDB snapshots + AOF log | Không có |
| Replication | Master-Slave built-in | Không có |
| Pub/Sub | Có | Không |
| Scripting | Lua scripting | Không |
| Cluster mode | Redis Cluster | Client-side sharding |
| Memory efficiency | Tốt | Tốt hơn cho string đơn giản |
| Multi-threaded | Single-threaded (I/O threads từ v6) | Multi-threaded |
| Max key size | 512 MB | 250 bytes |
| Max value size | 512 MB | 1 MB |

**Khi nào chọn Memcached?**

-   Chỉ cần cache string/blob đơn giản
-   Cần multi-threaded cho workload CPU-intensive
-   Ứng dụng chỉ cần volatile cache, không cần persistence

**Khi nào chọn Redis?** (hầu hết trường hợp)

-   Cần các kiểu dữ liệu phức tạp (Sorted Set cho leaderboard, List cho queue)
-   Cần persistence — dữ liệu không mất khi restart
-   Cần Pub/Sub cho real-time messaging
-   Cần atomic operations và transactions
-   Cần Lua scripting cho complex logic

> **Lời khuyên thực tế:** Trong 95% trường hợp, chọn Redis. Memcached chỉ có lợi khi bạn cache dữ liệu rất đơn giản và cần multi-threaded performance. Redis đã thêm I/O threads từ version 6, thu hẹp khoảng cách performance.

## 4\. Redis Architecture

### Single-threaded Event Loop

Redis xử lý tất cả commands trên **một thread duy nhất**. Nghe có vẻ chậm, nhưng thực tế lại rất nhanh vì:

```
┌─────────────────────────────────────────┐
│           Redis Event Loop              │
│                                         │
│  ┌──────┐  ┌──────┐  ┌──────┐         │
│  │Client│  │Client│  │Client│  ...     │
│  │  1   │  │  2   │  │  3   │         │
│  └──┬───┘  └──┬───┘  └──┬───┘         │
│     │         │         │               │
│     ▼         ▼         ▼               │
│  ┌─────────────────────────────┐       │
│  │   I/O Multiplexing          │       │
│  │   (epoll / kqueue)          │       │
│  └─────────────┬───────────────┘       │
│                │                        │
│                ▼                        │
│  ┌─────────────────────────────┐       │
│  │   Single Thread             │       │
│  │   Process commands          │       │
│  │   one by one                │       │
│  └─────────────────────────────┘       │
│                                         │
└─────────────────────────────────────────┘
```

**Tại sao single-threaded lại nhanh?**

1.  **Không cần mutex/lock**: Multi-threaded phải dùng lock để đồng bộ → overhead lớn
2.  **Không context switching**: CPU không phải chuyển đổi giữa các thread
3.  **In-memory operations cực nhanh**: Mỗi operation chỉ mất microseconds
4.  **I/O multiplexing**: Kernel xử lý I/O song song, Redis chỉ process data

**Bottleneck thực sự**: Network I/O và memory, không phải CPU. Từ Redis 6.0, I/O threads được thêm vào để xử lý network I/O song song, nhưng data processing vẫn single-threaded.

### Persistence: RDB và AOF

Redis lưu dữ liệu trên RAM, nhưng hỗ trợ 2 cơ chế persistence để không mất data khi restart:

**RDB (Redis Database Backup)** — Snapshot tại thời điểm

```
# redis.conf
# Save snapshot nếu có ít nhất 1 key thay đổi trong 900 giây
save 900 1
# Save snapshot nếu có ít nhất 10 keys thay đổi trong 300 giây
save 300 10
# Save snapshot nếu có ít nhất 10000 keys thay đổi trong 60 giây
save 60 10000

# Tên file snapshot
dbfilename dump.rdb
# Thư mục lưu file
dir /var/lib/redis
```

-   **Ưu điểm**: File nhỏ gọn, restore nhanh, phù hợp backup
-   **Nhược điểm**: Có thể mất dữ liệu giữa 2 lần snapshot

**AOF (Append Only File)** — Ghi log mọi write operation

```
# redis.conf
appendonly yes
appendfilename "appendonly.aof"

# Sync policy:
# appendfsync always   # Mỗi write → fsync (an toàn nhất, chậm nhất)
appendfsync everysec    # Fsync mỗi giây (cân bằng tốt)
# appendfsync no       # Để OS tự fsync (nhanh nhất, rủi ro nhất)
```

-   **Ưu điểm**: Mất tối đa 1 giây dữ liệu, durable hơn RDB
-   **Nhược điểm**: File lớn hơn, restore chậm hơn

**Best practice**: Dùng cả hai — RDB cho backup, AOF cho durability:

```
# redis.conf - Production recommended
save 900 1
save 300 10
save 60 10000

appendonly yes
appendfsync everysec
```

## 5\. Tóm tắt

| Khái niệm | Mô tả |
| --- | --- |
| Redis | In-memory data structure store, hỗ trợ nhiều kiểu dữ liệu |
| Use cases | Caching, sessions, rate limiting, leaderboards, pub/sub, queues |
| vs Memcached | Redis linh hoạt hơn (nhiều data types, persistence, pub/sub) |
| Single-threaded | Nhanh nhờ không lock, no context switch, I/O multiplexing |
| RDB | Point-in-time snapshot, file nhỏ, restore nhanh |
| AOF | Append log mọi write, mất tối đa 1s data |

> **Bài tiếp theo:** Chúng ta sẽ cài đặt Redis bằng Docker và làm quen với Redis CLI — công cụ tương tác trực tiếp với Redis server.
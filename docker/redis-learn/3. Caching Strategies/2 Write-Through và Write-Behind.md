**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/598960e1-d242-485b-a4d4-112465a6fa37](https://code4func.com/learn/redis-and-caching-strategies/598960e1-d242-485b-a4d4-112465a6fa37)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Write-Through và Write-Behind
├── Mục tiêu bài học
├── 1\. Write-Through Pattern
│   ├── Flow
│   └── Implementation
├── 2\. Write-Behind (Write-Back) Pattern
│   ├── Flow
│   └── Implementation
├── 3\. Read-Through Pattern
├── 4\. So sánh tất cả Caching Strategies
│   └── Khi nào dùng gì?
└── Tóm tắt
```

---

## Write-Through và Write-Behind

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Hiểu Write-Through pattern và cách hoạt động
-   Hiểu Write-Behind (Write-Back) pattern
-   Hiểu Read-Through pattern
-   So sánh tất cả caching strategies
-   Implement từng pattern trong Go

## 1\. Write-Through Pattern

**Write-Through** ghi dữ liệu vào cache **và** database **đồng thời**. Cache luôn chứa data mới nhất.

### Flow

```
Client Write Request
        │
        ▼
┌──────────────┐
│   Server     │
│              │
│  1. Write    │──────────►┌───────┐
│     Cache    │           │ Redis │  (cache luôn up-to-date)
│              │◄──────────│       │
│              │           └───────┘
│  2. Write    │──────────►┌──────────┐
│     DB       │           │ Postgres │
│              │◄──────────│          │
│              │           └──────────┘
│  3. Return   │
│     OK       │
└──────┬───────┘
       │
       ▼
    Client
```

### Implementation

```
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "log"
    "time"

    "github.com/redis/go-redis/v9"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

type Product struct {
    ID        string    `gorm:"primaryKey" json:"id"`
    Name      string    `json:"name"`
    Price     float64   `json:"price"`
    Stock     int       `json:"stock"`
    UpdatedAt time.Time `json:"updated_at"`
}

// WriteThroughCache ghi đồng thời vào cache và DB
type WriteThroughCache struct {
    rdb *redis.Client
    db  *gorm.DB
    ttl time.Duration
}

func NewWriteThroughCache(rdb *redis.Client, db *gorm.DB, ttl time.Duration) *WriteThroughCache {
    return &WriteThroughCache{rdb: rdb, db: db, ttl: ttl}
}

// Write ghi vào cả cache và database
func (wtc *WriteThroughCache) Write(ctx context.Context, product *Product) error {
    product.UpdatedAt = time.Now()

    // Bước 1: Ghi vào database trước (source of truth)
    if err := wtc.db.WithContext(ctx).Save(product).Error; err != nil {
        return fmt.Errorf("db write: %w", err)
    }

    // Bước 2: Ghi vào cache
    data, err := json.Marshal(product)
    if err != nil {
        return fmt.Errorf("marshal: %w", err)
    }

    cacheKey := "product:" + product.ID
    if err := wtc.rdb.Set(ctx, cacheKey, data, wtc.ttl).Err(); err != nil {
        // Cache write failed — log nhưng không return error
        // DB đã ghi thành công, cache sẽ được populate ở lần read tiếp
        log.Printf("Cache write failed for %s: %v", cacheKey, err)
    }

    return nil
}

// Read đọc từ cache trước, fallback DB
func (wtc *WriteThroughCache) Read(ctx context.Context, id string) (*Product, error) {
    cacheKey := "product:" + id

    // Đọc từ cache
    data, err := wtc.rdb.Get(ctx, cacheKey).Bytes()
    if err == nil {
        var product Product
        if json.Unmarshal(data, &product) == nil {
            return &product, nil // Cache HIT
        }
    }

    // Cache MISS — đọc từ DB
    var product Product
    if err := wtc.db.WithContext(ctx).First(&product, "id = ?", id).Error; err != nil {
        return nil, err
    }

    // Lưu vào cache
    productData, _ := json.Marshal(product)
    wtc.rdb.Set(ctx, cacheKey, productData, wtc.ttl)

    return &product, nil
}

func main() {
    // Setup
    dsn := "host=localhost user=postgres password=postgres dbname=myapp port=5432"
    db, _ := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    db.AutoMigrate(&Product{})

    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    cache := NewWriteThroughCache(rdb, db, 30*time.Minute)

    ctx := context.Background()

    // Write — tự động ghi vào cả DB và cache
    product := &Product{ID: "p1", Name: "iPhone 15", Price: 999, Stock: 50}
    cache.Write(ctx, product)

    // Read — luôn từ cache (vì Write-Through đảm bảo cache có data)
    cached, _ := cache.Read(ctx, "p1")
    fmt.Printf("Product: %+v\n", cached)
}
```

## 2\. Write-Behind (Write-Back) Pattern

**Write-Behind** ghi vào cache **ngay lập tức**, sau đó **async** ghi vào database. Ưu tiên tốc độ write.

### Flow

```
Client Write Request
        │
        ▼
┌──────────────┐
│   Server     │
│              │
│  1. Write    │──────────►┌───────┐
│     Cache    │           │ Redis │  ← Ghi ngay (nhanh)
│              │◄──────────│       │
│              │           └───────┘
│  2. Return   │
│     OK       │  ← Response ngay cho client
│              │
│  3. Async    │ ─ ─ ─ ─ ►┌──────────┐
│     Write DB │          │ Postgres │  ← Ghi sau (background)
│              │◄ ─ ─ ─ ─ │          │
└──────────────┘          └──────────┘
```

### Implementation

```
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "log"
    "sync"
    "time"

    "github.com/redis/go-redis/v9"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

type Order struct {
    ID        string    `gorm:"primaryKey" json:"id"`
    UserID    string    `json:"user_id"`
    Amount    float64   `json:"amount"`
    Status    string    `json:"status"`
    CreatedAt time.Time `json:"created_at"`
}

// WriteBuffer chứa data cần ghi vào DB
type WriteBuffer struct {
    mu      sync.Mutex
    items   []Order
    maxSize int
}

// WriteBehindCache ghi cache ngay, async ghi DB
type WriteBehindCache struct {
    rdb    *redis.Client
    db     *gorm.DB
    buffer *WriteBuffer
    ttl    time.Duration
}

func NewWriteBehindCache(rdb *redis.Client, db *gorm.DB, ttl time.Duration, flushInterval time.Duration) *WriteBehindCache {
    wbc := &WriteBehindCache{
        rdb: rdb,
        db:  db,
        ttl: ttl,
        buffer: &WriteBuffer{
            items:   make([]Order, 0),
            maxSize: 100,
        },
    }

    // Background worker: flush buffer mỗi N giây
    go wbc.flushLoop(flushInterval)

    return wbc
}

// Write ghi vào cache ngay, đưa vào buffer để async ghi DB
func (wbc *WriteBehindCache) Write(ctx context.Context, order *Order) error {
    order.CreatedAt = time.Now()

    // Bước 1: Ghi vào cache ngay (nhanh — microseconds)
    data, err := json.Marshal(order)
    if err != nil {
        return fmt.Errorf("marshal: %w", err)
    }
    cacheKey := "order:" + order.ID
    if err := wbc.rdb.Set(ctx, cacheKey, data, wbc.ttl).Err(); err != nil {
        return fmt.Errorf("cache write: %w", err)
    }

    // Bước 2: Đưa vào buffer (async ghi DB sau)
    wbc.buffer.mu.Lock()
    wbc.buffer.items = append(wbc.buffer.items, *order)
    shouldFlush := len(wbc.buffer.items) >= wbc.buffer.maxSize
    wbc.buffer.mu.Unlock()

    // Flush ngay nếu buffer đầy
    if shouldFlush {
        go wbc.flush()
    }

    return nil // Return ngay cho client — không chờ DB
}

// flush ghi buffer vào database
func (wbc *WriteBehindCache) flush() {
    wbc.buffer.mu.Lock()
    if len(wbc.buffer.items) == 0 {
        wbc.buffer.mu.Unlock()
        return
    }
    items := make([]Order, len(wbc.buffer.items))
    copy(items, wbc.buffer.items)
    wbc.buffer.items = wbc.buffer.items[:0] // Clear buffer
    wbc.buffer.mu.Unlock()

    // Batch insert vào DB
    if err := wbc.db.CreateInBatches(items, 50).Error; err != nil {
        log.Printf("Write-behind flush failed: %v", err)
        // Đưa items lại vào buffer để retry
        wbc.buffer.mu.Lock()
        wbc.buffer.items = append(items, wbc.buffer.items...)
        wbc.buffer.mu.Unlock()
    } else {
        log.Printf("Flushed %d orders to DB", len(items))
    }
}

// flushLoop chạy flush định kỳ
func (wbc *WriteBehindCache) flushLoop(interval time.Duration) {
    ticker := time.NewTicker(interval)
    defer ticker.Stop()
    for range ticker.C {
        wbc.flush()
    }
}

// Read đọc từ cache
func (wbc *WriteBehindCache) Read(ctx context.Context, id string) (*Order, error) {
    cacheKey := "order:" + id
    data, err := wbc.rdb.Get(ctx, cacheKey).Bytes()
    if err != nil {
        return nil, err
    }
    var order Order
    if err := json.Unmarshal(data, &order); err != nil {
        return nil, err
    }
    return &order, nil
}

func main() {
    dsn := "host=localhost user=postgres password=postgres dbname=myapp port=5432"
    db, _ := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    db.AutoMigrate(&Order{})

    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    // Flush mỗi 5 giây hoặc khi buffer đạt 100 items
    cache := NewWriteBehindCache(rdb, db, time.Hour, 5*time.Second)

    ctx := context.Background()

    // Ghi 10 orders — response ngay lập tức
    for i := 0; i < 10; i++ {
        order := &Order{
            ID:     fmt.Sprintf("order-%d", i),
            UserID: "user-1",
            Amount: float64(i) * 100,
            Status: "pending",
        }
        cache.Write(ctx, order)
    }

    fmt.Println("All orders written to cache (DB write pending...)")
    time.Sleep(6 * time.Second) // Chờ flush
    fmt.Println("Orders should be in DB now")
}
```

## 3\. Read-Through Pattern

**Read-Through** cache tự động load data từ DB khi cache miss. Application không cần biết về database — cache là interface duy nhất.

```
package main

import (
    "context"
    "encoding/json"
    "errors"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

// DataLoader là function load data từ source (DB, API, etc.)
type DataLoader[T any] func(ctx context.Context, key string) (T, error)

// ReadThroughCache tự động load data khi cache miss
type ReadThroughCache[T any] struct {
    rdb    *redis.Client
    loader DataLoader[T]
    ttl    time.Duration
    prefix string
}

func NewReadThroughCacheT any *ReadThroughCache[T] {
    return &ReadThroughCache[T]{
        rdb:    rdb,
        loader: loader,
        ttl:    ttl,
        prefix: prefix,
    }
}

// Get — Read-Through: tự động load và cache nếu miss
func (rtc *ReadThroughCache[T]) Get(ctx context.Context, key string) (T, error) {
    var result T
    cacheKey := rtc.prefix + ":" + key

    // Đọc từ cache
    data, err := rtc.rdb.Get(ctx, cacheKey).Bytes()
    if err == nil {
        if json.Unmarshal(data, &result) == nil {
            return result, nil // Cache HIT
        }
    }

    // Cache MISS — tự động load
    if errors.Is(err, redis.Nil) || err != nil {
        result, err = rtc.loader(ctx, key)
        if err != nil {
            return result, err
        }

        // Lưu vào cache
        cacheData, _ := json.Marshal(result)
        rtc.rdb.Set(ctx, cacheKey, cacheData, rtc.ttl)
    }

    return result, nil
}

// === Usage ===

type Article struct {
    ID    string `json:"id"`
    Title string `json:"title"`
    Body  string `json:"body"`
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    // Tạo Read-Through cache với loader function
    articleCache := NewReadThroughCacheArticle (Article, error) {
            // Đây là nơi query database
            fmt.Printf("Loading article %s from DB...\n", key)
            return Article{
                ID:    key,
                Title: "Sample Article",
                Body:  "Article content...",
            }, nil
        },
    )

    // Application chỉ cần gọi Get — không cần biết về DB
    article, _ := articleCache.Get(ctx, "art-001")
    fmt.Printf("Article: %+v\n", article) // Loads from DB

    article2, _ := articleCache.Get(ctx, "art-001")
    fmt.Printf("Article (cached): %+v\n", article2) // From cache
}
```

## 4\. So sánh tất cả Caching Strategies

| Tiêu chí | Cache-Aside | Write-Through | Write-Behind | Read-Through |
| --- | --- | --- | --- | --- |
| Ai quản lý cache? | Application | Cache layer | Cache layer | Cache layer |
| Write latency | Thấp (chỉ ghi DB) | Trung bình (ghi cả 2) | Rất thấp (chỉ ghi cache) | N/A |
| Read latency (miss) | Cao (DB query + cache) | Thấp (cache luôn có data) | Thấp | Trung bình |
| Data consistency | TTL-based | Mạnh (sync write) | Yếu (async) | TTL-based |
| Mất data risk | Không | Không | Có (nếu crash trước flush) | Không |
| Complexity | Thấp | Trung bình | Cao | Trung bình |
| Cache pollution | Thấp (lazy) | Cao (mọi write) | Cao | Thấp (lazy) |

### Khi nào dùng gì?

| Use case | Strategy | Lý do |
| --- | --- | --- |
| API response cache | Cache-Aside | Đơn giản, lazy loading |
| User profile | Write-Through | Cần consistency, read nhiều |
| Analytics/logging | Write-Behind | Write heavy, chấp nhận async |
| Config/settings | Read-Through | Tự động reload, ít thay đổi |
| E-commerce product | Cache-Aside | Cần invalidation khi update |
| Real-time counter | Write-Behind | Tốc độ write quan trọng nhất |

## Tóm tắt

| Pattern | Mô tả | Ưu điểm | Nhược điểm |
| --- | --- | --- | --- |
| Cache-Aside | App quản lý cache tường minh | Đơn giản, resilient | Cache miss penalty |
| Write-Through | Ghi cache + DB đồng thời | Consistency mạnh | Write chậm hơn |
| Write-Behind | Ghi cache ngay, DB async | Write cực nhanh | Có thể mất data |
| Read-Through | Cache tự load khi miss | Clean code, separation | Cần abstraction layer |

> **Bài tiếp theo:** Chúng ta sẽ đối mặt với bài toán khó nhất trong caching — Cache Invalidation — cùng các giải pháp cho cache stampede problem.
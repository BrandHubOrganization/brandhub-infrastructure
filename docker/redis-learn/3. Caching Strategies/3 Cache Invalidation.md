**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/e8c32f64-bb96-489b-aea8-b9645ef6aa8e](https://code4func.com/learn/redis-and-caching-strategies/e8c32f64-bb96-489b-aea8-b9645ef6aa8e)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Cache Invalidation - Bài toán khó nhất
├── Mục tiêu bài học
├── 1\. "Two Hard Things in Computer Science"
│   └── Các vấn đề phổ biến
├── 2\. TTL-based Invalidation
├── 3\. Event-Driven Invalidation
├── 4\. Cache Stampede Solutions
│   ├── Solution 1: Singleflight
│   └── Solution 2: Distributed Lock
├── 5\. Practical Invalidation Patterns
│   ├── Pattern: Versioned Cache Keys
│   └── Pattern: Tag-based Invalidation
└── Tóm tắt
```

---

## Cache Invalidation - Bài toán khó nhất

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Hiểu tại sao cache invalidation là bài toán khó nhất
-   Implement TTL-based invalidation
-   Implement event-driven invalidation
-   Giải quyết cache stampede problem bằng singleflight và distributed lock
-   Áp dụng các practical patterns cho invalidation

## 1\. "Two Hard Things in Computer Science"

> _"There are only two hard things in Computer Science: cache invalidation and naming things."_ — Phil Karlton

Cache invalidation khó vì bạn phải trả lời câu hỏi: **Khi nào data trong cache không còn đúng?** Và **làm sao xóa đúng cache key?**

### Các vấn đề phổ biến

**1\. Stale Data (Dữ liệu cũ)**

```
T=0: User A đọc product → cache: {price: 100}
T=1: Admin update product → DB: {price: 150}
T=2: User B đọc product → cache: {price: 100} ← SAI!
     (Cache chưa được invalidate)
```

**2\. Cache Stampede (Bão request)**

```
T=0: Cache hết hạn
T=0.001: 1000 requests đồng thời → tất cả cache miss
         → 1000 DB queries đồng thời → DB quá tải!

┌────────┐
│ Req 1  │──→ Cache MISS ──→ Query DB ──┐
│ Req 2  │──→ Cache MISS ──→ Query DB ──┤
│ Req 3  │──→ Cache MISS ──→ Query DB ──┤  DB bị 1000
│  ...   │──→ Cache MISS ──→ Query DB ──┤  queries!
│ Req1000│──→ Cache MISS ──→ Query DB ──┘
└────────┘
```

**3\. Inconsistency Window**

```
T=0: App ghi DB thành công
T=0.001: App bắt đầu xóa cache
T=0.002: Request khác đọc cache → nhận data CŨ (cache chưa bị xóa)
T=0.003: Cache bị xóa
```

## 2\. TTL-based Invalidation

Cách đơn giản nhất: set TTL cho cache key. Data tự hết hạn sau một khoảng thời gian.

```
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "math/rand"
    "time"

    "github.com/redis/go-redis/v9"
)

type Product struct {
    ID    string  `json:"id"`
    Name  string  `json:"name"`
    Price float64 `json:"price"`
}

// cacheWithJitter set cache với TTL + random jitter
func cacheWithJitter(ctx context.Context, rdb *redis.Client, key string, value interface{}, baseTTL time.Duration) error {
    data, err := json.Marshal(value)
    if err != nil {
        return err
    }

    // Jitter ±20% để tránh thundering herd
    jitterRange := int64(baseTTL) * 40 / 100 // 40% range
    jitter := time.Duration(rand.Int63n(jitterRange)) - time.Duration(jitterRange/2)
    ttl := baseTTL + jitter

    return rdb.Set(ctx, key, data, ttl).Err()
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    product := Product{ID: "p1", Name: "iPhone", Price: 999}

    // TTL 5 phút ± 1 phút (4-6 phút)
    cacheWithJitter(ctx, rdb, "product:p1", product, 5*time.Minute)

    ttl, _ := rdb.TTL(ctx, "product:p1").Result()
    fmt.Printf("Actual TTL: %v\n", ttl) // ~4-6 minutes

    // Cleanup
    rdb.Del(ctx, "product:p1")
}
```

**Ưu điểm:** Đơn giản, không cần logic phức tạp. **Nhược điểm:** Data có thể stale trong khoảng TTL.

## 3\. Event-Driven Invalidation

Khi data thay đổi → phát sự kiện → invalidate cache.

```
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "log"
    "time"

    "github.com/redis/go-redis/v9"
)

// CacheInvalidator lắng nghe sự kiện và xóa cache
type CacheInvalidator struct {
    rdb *redis.Client
}

func NewCacheInvalidator(rdb *redis.Client) *CacheInvalidator {
    return &CacheInvalidator{rdb: rdb}
}

// PublishInvalidation phát sự kiện invalidation
func (ci *CacheInvalidator) PublishInvalidation(ctx context.Context, entity, id string) error {
    event := map[string]string{
        "entity": entity,
        "id":     id,
        "action": "invalidate",
        "time":   time.Now().Format(time.RFC3339),
    }
    data, _ := json.Marshal(event)
    return ci.rdb.Publish(ctx, "cache:invalidation", data).Err()
}

// SubscribeInvalidation lắng nghe và xử lý sự kiện
func (ci *CacheInvalidator) SubscribeInvalidation(ctx context.Context) {
    sub := ci.rdb.Subscribe(ctx, "cache:invalidation")
    ch := sub.Channel()

    for msg := range ch {
        var event map[string]string
        if err := json.Unmarshal([]byte(msg.Payload), &event); err != nil {
            log.Printf("Invalid event: %v", err)
            continue
        }

        entity := event["entity"]
        id := event["id"]

        // Xóa cache cho entity
        cacheKey := fmt.Sprintf("cache:%s:%s", entity, id)
        ci.rdb.Del(ctx, cacheKey)
        log.Printf("Invalidated cache: %s", cacheKey)

        // Xóa cả list cache liên quan
        ci.invalidateListCache(ctx, entity)
    }
}

func (ci *CacheInvalidator) invalidateListCache(ctx context.Context, entity string) {
    // Xóa tất cả list cache cho entity này
    iter := ci.rdb.Scan(ctx, 0, fmt.Sprintf("cache:%s:list:*", entity), 100).Iterator()
    var keys []string
    for iter.Next(ctx) {
        keys = append(keys, iter.Val())
    }
    if len(keys) > 0 {
        ci.rdb.Del(ctx, keys...)
        log.Printf("Invalidated %d list caches for %s", len(keys), entity)
    }
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    invalidator := NewCacheInvalidator(rdb)

    // Subscriber chạy trong goroutine
    go invalidator.SubscribeInvalidation(ctx)

    // Giả lập: admin update product
    time.Sleep(100 * time.Millisecond) // Chờ subscriber sẵn sàng
    invalidator.PublishInvalidation(ctx, "product", "p1")

    time.Sleep(500 * time.Millisecond)
    fmt.Println("Done")
}
```

## 4\. Cache Stampede Solutions

### Solution 1: Singleflight

`singleflight` đảm bảo chỉ **một goroutine** thực hiện function, các goroutine khác chờ kết quả.

```
package main

import (
    "context"
    "encoding/json"
    "errors"
    "fmt"
    "log"
    "sync"
    "time"

    "github.com/redis/go-redis/v9"
    "golang.org/x/sync/singleflight"
)

type Article struct {
    ID    string `json:"id"`
    Title string `json:"title"`
}

type ArticleCache struct {
    rdb *redis.Client
    sf  singleflight.Group
    ttl time.Duration
}

func NewArticleCache(rdb *redis.Client, ttl time.Duration) *ArticleCache {
    return &ArticleCache{rdb: rdb, ttl: ttl}
}

// GetArticle — cache-aside với singleflight
func (ac *ArticleCache) GetArticle(ctx context.Context, id string) (*Article, error) {
    cacheKey := "article:" + id

    // 1. Check cache
    data, err := ac.rdb.Get(ctx, cacheKey).Bytes()
    if err == nil {
        var article Article
        if json.Unmarshal(data, &article) == nil {
            return &article, nil
        }
    }
    if err != nil && !errors.Is(err, redis.Nil) {
        log.Printf("Cache error: %v", err)
    }

    // 2. Cache MISS — singleflight đảm bảo chỉ 1 goroutine query DB
    result, err, shared := ac.sf.Do(cacheKey, func() (interface{}, error) {
        // Chỉ goroutine đầu tiên chạy code này
        // Các goroutine khác chờ kết quả
        fmt.Printf("  [singleflight] Loading article %s from DB\n", id)

        // Giả lập DB query (100ms)
        time.Sleep(100 * time.Millisecond)
        article := &Article{ID: id, Title: "Article " + id}

        // Lưu vào cache
        articleData, _ := json.Marshal(article)
        ac.rdb.Set(ctx, cacheKey, articleData, ac.ttl)

        return article, nil
    })

    if err != nil {
        return nil, err
    }

    fmt.Printf("  [result] shared=%v\n", shared) // true nếu dùng kết quả từ goroutine khác
    return result.(*Article), nil
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    cache := NewArticleCache(rdb, 5*time.Minute)

    // Giả lập 100 concurrent requests cho cùng một article
    var wg sync.WaitGroup
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func(i int) {
            defer wg.Done()
            article, err := cache.GetArticle(ctx, "art-001")
            if err != nil {
                log.Printf("Request %d error: %v", i, err)
                return
            }
            _ = article // use result
        }(i)
    }
    wg.Wait()

    // Output: Chỉ có 1 dòng "Loading article art-001 from DB"
    // 99 requests còn lại dùng shared result

    rdb.Del(ctx, "article:art-001")
    fmt.Println("\nDone! Only 1 DB query for 100 requests")
}
```

### Solution 2: Distributed Lock

Khi singleflight không đủ (multiple servers), dùng distributed lock:

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

type CacheWithLock struct {
    rdb *redis.Client
    ttl time.Duration
}

func NewCacheWithLock(rdb *redis.Client, ttl time.Duration) *CacheWithLock {
    return &CacheWithLock{rdb: rdb, ttl: ttl}
}

// GetOrLoadWithLock đọc cache, nếu miss thì dùng lock để load
func (cwl *CacheWithLock) GetOrLoadWithLock(ctx context.Context, key string, loader func() (interface{}, error)) ([]byte, error) {
    // 1. Check cache
    data, err := cwl.rdb.Get(ctx, key).Bytes()
    if err == nil {
        return data, nil // Cache HIT
    }
    if !errors.Is(err, redis.Nil) {
        return nil, err
    }

    // 2. Cache MISS — thử lấy lock
    lockKey := "lock:" + key
    locked, err := cwl.rdb.SetNX(ctx, lockKey, "1", 10*time.Second).Result()
    if err != nil {
        return nil, err
    }

    if locked {
        // Lấy được lock — load data
        defer cwl.rdb.Del(ctx, lockKey) // Release lock

        result, err := loader()
        if err != nil {
            return nil, err
        }

        // Lưu vào cache
        jsonData, _ := json.Marshal(result)
        cwl.rdb.Set(ctx, key, jsonData, cwl.ttl)
        return jsonData, nil
    }

    // Không lấy được lock — chờ và retry
    for i := 0; i < 50; i++ { // Chờ tối đa 5 giây
        time.Sleep(100 * time.Millisecond)
        data, err = cwl.rdb.Get(ctx, key).Bytes()
        if err == nil {
            return data, nil // Goroutine khác đã load xong
        }
    }

    return nil, fmt.Errorf("timeout waiting for cache to be populated")
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    cache := NewCacheWithLock(rdb, 5*time.Minute)

    data, err := cache.GetOrLoadWithLock(ctx, "cache:product:1", func() (interface{}, error) {
        fmt.Println("Loading from DB (only once)...")
        return map[string]interface{}{"id": "1", "name": "iPhone"}, nil
    })

    if err != nil {
        fmt.Printf("Error: %v\n", err)
        return
    }
    fmt.Printf("Data: %s\n", string(data))

    rdb.Del(ctx, "cache:product:1")
}
```

## 5\. Practical Invalidation Patterns

### Pattern: Versioned Cache Keys

```
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

// VersionedCache dùng version number trong key
type VersionedCache struct {
    rdb *redis.Client
}

func NewVersionedCache(rdb *redis.Client) *VersionedCache {
    return &VersionedCache{rdb: rdb}
}

// GetVersion lấy version hiện tại của entity
func (vc *VersionedCache) GetVersion(ctx context.Context, entity string) (int64, error) {
    ver, err := vc.rdb.Get(ctx, "version:"+entity).Int64()
    if err == redis.Nil {
        return 1, nil // Default version 1
    }
    return ver, err
}

// IncrVersion tăng version (invalidate tất cả cache cũ)
func (vc *VersionedCache) IncrVersion(ctx context.Context, entity string) (int64, error) {
    return vc.rdb.Incr(ctx, "version:"+entity).Result()
}

// CacheKey tạo key có version
func (vc *VersionedCache) CacheKey(ctx context.Context, entity, id string) (string, error) {
    ver, err := vc.GetVersion(ctx, entity)
    if err != nil {
        return "", err
    }
    return fmt.Sprintf("cache:v%d:%s:%s", ver, entity, id), nil
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    vc := NewVersionedCache(rdb)

    // Cache key version 1
    key1, _ := vc.CacheKey(ctx, "product", "123")
    rdb.Set(ctx, key1, "old data", 30*time.Minute)
    fmt.Printf("Key v1: %s\n", key1) // cache:v1:product:123

    // Product được update → tăng version
    vc.IncrVersion(ctx, "product")

    // Cache key version 2 — khác key cũ → cache miss tự nhiên
    key2, _ := vc.CacheKey(ctx, "product", "123")
    fmt.Printf("Key v2: %s\n", key2) // cache:v2:product:123

    // Key cũ v1 vẫn tồn tại nhưng không ai dùng → TTL hết thì tự xóa
    // Không cần xóa tường minh!

    // Cleanup
    rdb.Del(ctx, key1, key2, "version:product")
}
```

### Pattern: Tag-based Invalidation

```
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

// TagCache cho phép invalidate theo tags
type TagCache struct {
    rdb *redis.Client
}

func NewTagCache(rdb *redis.Client) *TagCache {
    return &TagCache{rdb: rdb}
}

// SetWithTags lưu cache và gắn tags
func (tc *TagCache) SetWithTags(ctx context.Context, key string, value string, ttl time.Duration, tags ...string) error {
    pipe := tc.rdb.Pipeline()

    // Lưu data
    pipe.Set(ctx, key, value, ttl)

    // Gắn key vào mỗi tag (dùng Set)
    for _, tag := range tags {
        tagKey := "tag:" + tag
        pipe.SAdd(ctx, tagKey, key)
        pipe.Expire(ctx, tagKey, 24*time.Hour) // Tags tự hết hạn
    }

    _, err := pipe.Exec(ctx)
    return err
}

// InvalidateByTag xóa tất cả cache keys có tag này
func (tc *TagCache) InvalidateByTag(ctx context.Context, tag string) (int64, error) {
    tagKey := "tag:" + tag

    // Lấy tất cả keys thuộc tag
    keys, err := tc.rdb.SMembers(ctx, tagKey).Result()
    if err != nil {
        return 0, err
    }

    if len(keys) == 0 {
        return 0, nil
    }

    // Xóa tất cả keys
    pipe := tc.rdb.Pipeline()
    for _, key := range keys {
        pipe.Del(ctx, key)
    }
    pipe.Del(ctx, tagKey) // Xóa luôn tag
    pipe.Exec(ctx)

    return int64(len(keys)), nil
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    tc := NewTagCache(rdb)

    // Cache với tags
    tc.SetWithTags(ctx, "cache:product:1", "iPhone data", 30*time.Minute,
        "product", "category:electronics", "featured")
    tc.SetWithTags(ctx, "cache:product:2", "MacBook data", 30*time.Minute,
        "product", "category:electronics")
    tc.SetWithTags(ctx, "cache:product:3", "T-Shirt data", 30*time.Minute,
        "product", "category:fashion")

    // Invalidate tất cả electronics
    count, _ := tc.InvalidateByTag(ctx, "category:electronics")
    fmt.Printf("Invalidated %d keys for 'electronics'\n", count)
    // → Xóa product:1 và product:2, giữ product:3

    // Kiểm tra
    exists1, _ := rdb.Exists(ctx, "cache:product:1").Result()
    exists3, _ := rdb.Exists(ctx, "cache:product:3").Result()
    fmt.Printf("Product 1 exists: %v (should be 0)\n", exists1)
    fmt.Printf("Product 3 exists: %v (should be 1)\n", exists3)

    // Cleanup
    rdb.Del(ctx, "cache:product:3", "tag:product", "tag:category:fashion", "tag:featured")
}
```

## Tóm tắt

| Vấn đề | Giải pháp | Khi nào dùng |
| --- | --- | --- |
| Stale data | TTL + event-driven invalidation | Mọi trường hợp |
| Cache stampede | Singleflight (single server) | Single server, cùng process |
| Cache stampede | Distributed lock (multi-server) | Multi-server, distributed |
| Invalidate group | Tag-based invalidation | Khi data có quan hệ (category) |
| Invalidate all | Versioned keys | Khi cần invalidate toàn bộ entity type |
| Thundering herd | TTL jitter | Khi nhiều keys cùng TTL |

> **Bài tiếp theo:** Chúng ta sẽ tổng hợp tất cả kiến thức qua một bài thực hành hoàn chỉnh — Cache API Response trong Gin với middleware approach.
**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/53d373cf-a028-4900-80fe-9563cef42e66](https://code4func.com/learn/redis-and-caching-strategies/53d373cf-a028-4900-80fe-9563cef42e66)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Cache-Aside Pattern
├── Mục tiêu bài học
├── 1\. Cache-Aside là gì?
│   └── Nguyên tắc hoạt động
├── 2\. Implementation trong Go
│   └── Cấu trúc project
├── 3\. Ưu điểm và Nhược điểm
│   ├── Ưu điểm
│   └── Nhược điểm
├── 4\. Generic Cache-Aside Wrapper
└── Tóm tắt
```

---

## Cache-Aside Pattern

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Hiểu Cache-Aside pattern (Lazy Loading) là gì và cách hoạt động
-   Implement Cache-Aside trong Go với Redis + GORM
-   Nắm rõ ưu/nhược điểm và khi nào nên dùng
-   Xử lý cache miss, cache invalidation cơ bản
-   Biết cách kết hợp Cache-Aside với TTL

## 1\. Cache-Aside là gì?

**Cache-Aside** (hay **Lazy Loading**, **Look-Aside**) là caching pattern phổ biến nhất. Application chịu trách nhiệm quản lý cache — đọc/ghi cache một cách tường minh.

### Nguyên tắc hoạt động

**Khi đọc dữ liệu (Read Flow):**

```
1. Application kiểm tra cache
2. Cache HIT → trả về data từ cache
3. Cache MISS → query database
4. Lưu kết quả vào cache
5. Trả về data cho client

┌────────┐     ┌──────────┐     ┌───────┐     ┌──────────┐
│ Client │────►│  Server  │────►│ Redis │     │ Postgres │
│        │     │          │     │ Cache │     │    DB    │
│        │     │  1. Check │────►│       │     │          │
│        │     │     cache │     │       │     │          │
│        │     │          │◄────│ MISS  │     │          │
│        │     │  2. Query │─────────────────►│          │
│        │     │     DB    │◄────────────────│  data    │
│        │     │  3. Save  │────►│ SET   │     │          │
│        │     │     cache │     │       │     │          │
│        │     │  4. Return│     │       │     │          │
│        │◄────│     data  │     │       │     │          │
└────────┘     └──────────┘     └───────┘     └──────────┘
```

**Khi ghi dữ liệu (Write Flow):**

```
1. Application ghi vào database
2. Xóa cache (invalidate)
   (KHÔNG update cache — vì data có thể đã stale)

┌────────┐     ┌──────────┐     ┌───────┐     ┌──────────┐
│ Client │────►│  Server  │     │ Redis │     │ Postgres │
│        │     │          │     │ Cache │     │    DB    │
│        │     │  1. Write │─────────────────►│          │
│        │     │     DB    │◄────────────────│   OK     │
│        │     │  2. Delete│────►│ DEL   │     │          │
│        │     │     cache │     │       │     │          │
│        │◄────│  3. OK    │     │       │     │          │
└────────┘     └──────────┘     └───────┘     └──────────┘
```

> **Tại sao xóa cache thay vì update?** Vì giữa lúc đọc DB và update cache, có thể có request khác đã đọc data cũ. Xóa cache an toàn hơn — request tiếp theo sẽ tự load data mới từ DB.

## 2\. Implementation trong Go

### Cấu trúc project

```
package main

import (
    "context"
    "encoding/json"
    "errors"
    "fmt"
    "log"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/redis/go-redis/v9"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

// === Entity ===

type Course struct {
    ID          string    `gorm:"primaryKey" json:"id"`
    Title       string    `json:"title"`
    Description string    `json:"description"`
    Price       float64   `json:"price"`
    Instructor  string    `json:"instructor"`
    IsPublished bool      `json:"is_published"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
}

// === Cache Layer ===

type CacheService struct {
    rdb *redis.Client
    ttl time.Duration
}

func NewCacheService(rdb *redis.Client, ttl time.Duration) *CacheService {
    return &CacheService{rdb: rdb, ttl: ttl}
}

// Get đọc từ cache, trả nil nếu cache miss
func (cs *CacheService) Get(ctx context.Context, key string, dest interface{}) error {
    data, err := cs.rdb.Get(ctx, key).Bytes()
    if errors.Is(err, redis.Nil) {
        return redis.Nil // Cache miss
    }
    if err != nil {
        return fmt.Errorf("cache get: %w", err)
    }
    return json.Unmarshal(data, dest)
}

// Set lưu vào cache
func (cs *CacheService) Set(ctx context.Context, key string, value interface{}) error {
    data, err := json.Marshal(value)
    if err != nil {
        return fmt.Errorf("cache marshal: %w", err)
    }
    return cs.rdb.Set(ctx, key, data, cs.ttl).Err()
}

// Delete xóa cache
func (cs *CacheService) Delete(ctx context.Context, keys ...string) error {
    return cs.rdb.Del(ctx, keys...).Err()
}

// === Repository (Database Layer) ===

type CourseRepository struct {
    db *gorm.DB
}

func NewCourseRepository(db *gorm.DB) *CourseRepository {
    return &CourseRepository{db: db}
}

func (r *CourseRepository) FindByID(ctx context.Context, id string) (*Course, error) {
    var course Course
    err := r.db.WithContext(ctx).First(&course, "id = ?", id).Error
    if err != nil {
        return nil, err
    }
    return &course, nil
}

func (r *CourseRepository) FindAll(ctx context.Context, limit, offset int) ([]Course, error) {
    var courses []Course
    err := r.db.WithContext(ctx).
        Where("is_published = ?", true).
        Limit(limit).Offset(offset).
        Order("created_at DESC").
        Find(&courses).Error
    return courses, err
}

func (r *CourseRepository) Update(ctx context.Context, course *Course) error {
    return r.db.WithContext(ctx).Save(course).Error
}

// === Use Case (Cache-Aside Logic) ===

type CourseUseCase struct {
    repo  *CourseRepository
    cache *CacheService
}

func NewCourseUseCase(repo *CourseRepository, cache *CacheService) *CourseUseCase {
    return &CourseUseCase{repo: repo, cache: cache}
}

// GetByID — Cache-Aside pattern
func (uc *CourseUseCase) GetByID(ctx context.Context, id string) (*Course, error) {
    cacheKey := fmt.Sprintf("cache:course:%s", id)

    // Bước 1: Kiểm tra cache
    var course Course
    err := uc.cache.Get(ctx, cacheKey, &course)
    if err == nil {
        // Cache HIT
        return &course, nil
    }
    if !errors.Is(err, redis.Nil) {
        // Cache error (không phải miss) — log và tiếp tục query DB
        log.Printf("Cache error for %s: %v", cacheKey, err)
    }

    // Bước 2: Cache MISS — query database
    dbCourse, err := uc.repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("find course: %w", err)
    }

    // Bước 3: Lưu vào cache (fire-and-forget, không block response)
    go func() {
        bgCtx := context.Background()
        if cacheErr := uc.cache.Set(bgCtx, cacheKey, dbCourse); cacheErr != nil {
            log.Printf("Failed to cache course %s: %v", id, cacheErr)
        }
    }()

    return dbCourse, nil
}

// GetList — Cache-Aside cho list
func (uc *CourseUseCase) GetList(ctx context.Context, page, pageSize int) ([]Course, error) {
    offset := (page - 1) * pageSize
    cacheKey := fmt.Sprintf("cache:courses:page:%d:size:%d", page, pageSize)

    // Kiểm tra cache
    var courses []Course
    err := uc.cache.Get(ctx, cacheKey, &courses)
    if err == nil {
        return courses, nil // Cache HIT
    }

    // Cache MISS — query DB
    courses, err = uc.repo.FindAll(ctx, pageSize, offset)
    if err != nil {
        return nil, err
    }

    // Lưu vào cache
    go func() {
        bgCtx := context.Background()
        uc.cache.Set(bgCtx, cacheKey, courses)
    }()

    return courses, nil
}

// Update — Ghi DB rồi invalidate cache
func (uc *CourseUseCase) Update(ctx context.Context, course *Course) error {
    // Bước 1: Ghi vào database
    if err := uc.repo.Update(ctx, course); err != nil {
        return fmt.Errorf("update course: %w", err)
    }

    // Bước 2: Invalidate cache
    cacheKey := fmt.Sprintf("cache:course:%s", course.ID)
    if err := uc.cache.Delete(ctx, cacheKey); err != nil {
        log.Printf("Failed to invalidate cache %s: %v", cacheKey, err)
        // Không return error — DB đã update thành công
        // Cache sẽ tự hết hạn theo TTL
    }

    // Cũng invalidate list cache (vì data đã thay đổi)
    // Trong thực tế, dùng pattern-based invalidation
    uc.cache.Delete(ctx, "cache:courses:page:1:size:20")

    return nil
}

// === Gin Handlers ===

func main() {
    // Setup database
    dsn := "host=localhost user=postgres password=postgres dbname=myapp port=5432"
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if err != nil {
        log.Fatal(err)
    }
    db.AutoMigrate(&Course{})

    // Setup Redis
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    if err := rdb.Ping(context.Background()).Err(); err != nil {
        log.Fatal(err)
    }

    // Setup layers
    repo := NewCourseRepository(db)
    cache := NewCacheService(rdb, 10*time.Minute)
    useCase := NewCourseUseCase(repo, cache)

    // Setup Gin
    r := gin.Default()

    r.GET("/courses/:id", func(c *gin.Context) {
        course, err := useCase.GetByID(c.Request.Context(), c.Param("id"))
        if err != nil {
            c.JSON(http.StatusNotFound, gin.H{"error": "Course not found"})
            return
        }
        c.JSON(http.StatusOK, course)
    })

    r.GET("/courses", func(c *gin.Context) {
        courses, err := useCase.GetList(c.Request.Context(), 1, 20)
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }
        c.JSON(http.StatusOK, courses)
    })

    r.Run(":8080")
}
```

## 3\. Ưu điểm và Nhược điểm

### Ưu điểm

| Ưu điểm | Giải thích |
| --- | --- |
| Đơn giản | Logic dễ hiểu: check cache → miss → query DB → set cache |
| Resilient | Nếu Redis down, application vẫn hoạt động (query DB trực tiếp) |
| Lazy loading | Chỉ cache data được request → không lãng phí memory |
| Tương thích | Hoạt động với mọi database, không cần thay đổi DB |

### Nhược điểm

| Nhược điểm | Giải pháp |
| --- | --- |
| Cache miss penalty | Request đầu tiên chậm hơn (DB query + cache write). Dùng cache warming |
| Stale data | Dùng TTL hợp lý, event-driven invalidation |
| Cache stampede | Nhiều requests cùng miss → nhiều DB queries. Dùng singleflight |
| Code duplication | Mỗi entity lặp lại logic. Dùng generic cache wrapper |

## 4\. Generic Cache-Aside Wrapper

```
package main

import (
    "context"
    "encoding/json"
    "errors"
    "fmt"
    "log"
    "time"

    "github.com/redis/go-redis/v9"
)

// CacheAside là generic wrapper cho Cache-Aside pattern
type CacheAside[T any] struct {
    rdb *redis.Client
    ttl time.Duration
}

func NewCacheAsideT any *CacheAside[T] {
    return &CacheAside[T]{rdb: rdb, ttl: ttl}
}

// GetOrLoad kiểm tra cache, nếu miss thì gọi loader function
func (ca *CacheAside[T]) GetOrLoad(ctx context.Context, key string, loader func() (T, error)) (T, error) {
    var result T

    // 1. Kiểm tra cache
    data, err := ca.rdb.Get(ctx, key).Bytes()
    if err == nil {
        if unmarshalErr := json.Unmarshal(data, &result); unmarshalErr == nil {
            return result, nil // Cache HIT
        }
    }
    if err != nil && !errors.Is(err, redis.Nil) {
        log.Printf("Cache get error for %s: %v", key, err)
    }

    // 2. Cache MISS — load từ source
    result, err = loader()
    if err != nil {
        return result, err
    }

    // 3. Lưu vào cache (non-blocking)
    go func() {
        cacheData, marshalErr := json.Marshal(result)
        if marshalErr != nil {
            log.Printf("Cache marshal error: %v", marshalErr)
            return
        }
        bgCtx := context.Background()
        if setErr := ca.rdb.Set(bgCtx, key, cacheData, ca.ttl).Err(); setErr != nil {
            log.Printf("Cache set error for %s: %v", key, setErr)
        }
    }()

    return result, nil
}

// Invalidate xóa cache
func (ca *CacheAside[T]) Invalidate(ctx context.Context, key string) error {
    return ca.rdb.Del(ctx, key).Err()
}

// === Usage ===

type User struct {
    ID    string `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    userCache := NewCacheAsideUser

    // GetOrLoad — tự động cache-aside
    user, err := userCache.GetOrLoad(ctx, "cache:user:1", func() (User, error) {
        // Đây là nơi query database
        fmt.Println("Loading from DB...")
        return User{ID: "1", Name: "Alice", Email: "alice@test.com"}, nil
    })
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("User: %+v\n", user)

    // Lần gọi thứ 2 — sẽ từ cache
    time.Sleep(100 * time.Millisecond) // Chờ goroutine cache xong
    user2, _ := userCache.GetOrLoad(ctx, "cache:user:1", func() (User, error) {
        fmt.Println("This should NOT print (cache hit)")
        return User{}, nil
    })
    fmt.Printf("User (from cache): %+v\n", user2)

    // Invalidate
    userCache.Invalidate(ctx, "cache:user:1")
}
```

## Tóm tắt

| Khái niệm | Mô tả |
| --- | --- |
| Cache-Aside | Application quản lý cache: check → miss → load → set |
| Read flow | Check cache → miss → query DB → save cache → return |
| Write flow | Write DB → delete cache (invalidate) |
| Ưu điểm | Đơn giản, resilient, lazy loading |
| Nhược điểm | Cache miss penalty, stale data, stampede |
| Generic wrapper | Dùng Go generics để tái sử dụng logic |

> **Bài tiếp theo:** Chúng ta sẽ tìm hiểu Write-Through và Write-Behind — hai pattern giúp giữ cache và database luôn đồng bộ.
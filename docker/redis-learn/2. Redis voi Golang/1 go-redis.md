**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/653d2cb5-17ad-4292-9673-a316033933c5](https://code4func.com/learn/redis-and-caching-strategies/653d2cb5-17ad-4292-9673-a316033933c5)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── go-redis: Kết nối và cấu hình
├── Mục tiêu bài học
├── 1\. Giới thiệu go-redis
│   ├── Tại sao chọn go-redis?
│   └── Cài đặt
├── Khởi tạo project
└── Cài đặt go-redis
    ├── 2\. Kết nối cơ bản
    │   ├── Connection đơn giản
    │   ├── Kết nối với URL string
    │   └── Kết nối với TLS (Redis Cloud, Production)
    ├── 3\. Connection Pool Configuration
    │   ├── Cấu hình pool chi tiết
    │   └── Production recommendation
    ├── 4\. Context Usage
    │   ├── Timeout per operation
    │   └── Context trong Gin handler
    ├── 5\. Error Handling
    │   └── Các loại error thường gặp
    ├── 6\. Health Check và Ping
    │   └── Implement health check endpoint
    ├── 7\. Singleton Pattern cho Redis Client
    └── Tóm tắt
```

---

## go-redis: Kết nối và cấu hình

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Cài đặt và sử dụng thư viện go-redis v9
-   Cấu hình connection pool tối ưu cho production
-   Hiểu cách dùng Context trong go-redis
-   Xử lý errors đúng cách
-   Implement health check và monitoring

## 1\. Giới thiệu go-redis

**go-redis** (`github.com/redis/go-redis/v9`) là thư viện Redis client phổ biến nhất cho Go. Đây là thư viện chính thức được Redis Ltd. khuyên dùng.

### Tại sao chọn go-redis?

-   **Type-safe API**: Mỗi command trả về đúng kiểu dữ liệu Go
-   **Connection pool**: Built-in connection pooling, tự quản lý
-   **Context support**: Hỗ trợ context.Context cho timeout và cancellation
-   **Pipeline & Transaction**: Hỗ trợ đầy đủ
-   **Pub/Sub, Streams**: API đầy đủ cho tất cả Redis features
-   **Cluster & Sentinel**: Hỗ trợ Redis Cluster và Sentinel

### Cài đặt

```
# Khởi tạo project
mkdir redis-go-demo && cd redis-go-demo
go mod init redis-go-demo

# Cài đặt go-redis
go get github.com/redis/go-redis/v9
```

## 2\. Kết nối cơ bản

### Connection đơn giản

```
package main

import (
    "context"
    "fmt"
    "log"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()

    // Tạo Redis client
    rdb := redis.NewClient(&redis.Options{
        Addr:     "localhost:6379", // host:port
        Password: "",               // không password
        DB:       0,                // database mặc định (0-15)
    })
    defer rdb.Close()

    // Kiểm tra kết nối
    pong, err := rdb.Ping(ctx).Result()
    if err != nil {
        log.Fatalf("Không thể kết nối Redis: %v", err)
    }
    fmt.Printf("Redis connected: %s\n", pong) // PONG

    // Thử SET/GET
    err = rdb.Set(ctx, "greeting", "Xin chào từ Go!", 0).Err()
    if err != nil {
        log.Fatalf("SET failed: %v", err)
    }

    val, err := rdb.Get(ctx, "greeting").Result()
    if err != nil {
        log.Fatalf("GET failed: %v", err)
    }
    fmt.Printf("greeting = %s\n", val) // Xin chào từ Go!
}
```

### Kết nối với URL string

```
package main

import (
    "context"
    "fmt"
    "log"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()

    // Parse URL — format: redis://:password@host:port/db
    opt, err := redis.ParseURL("redis://:mypassword@localhost:6379/0")
    if err != nil {
        log.Fatalf("Invalid Redis URL: %v", err)
    }

    rdb := redis.NewClient(opt)
    defer rdb.Close()

    pong, err := rdb.Ping(ctx).Result()
    if err != nil {
        log.Fatalf("Connection failed: %v", err)
    }
    fmt.Printf("Connected: %s\n", pong)
}
```

### Kết nối với TLS (Redis Cloud, Production)

```
package main

import (
    "context"
    "crypto/tls"
    "fmt"
    "log"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()

    rdb := redis.NewClient(&redis.Options{
        Addr:     "my-redis.cloud.com:6380",
        Password: "strong-password",
        DB:       0,
        TLSConfig: &tls.Config{
            MinVersion: tls.VersionTLS12,
        },
    })
    defer rdb.Close()

    pong, err := rdb.Ping(ctx).Result()
    if err != nil {
        log.Fatalf("TLS connection failed: %v", err)
    }
    fmt.Printf("TLS Connected: %s\n", pong)
}
```

## 3\. Connection Pool Configuration

go-redis tự quản lý connection pool. Mỗi `redis.Client` có một pool connections tới Redis server.

### Cấu hình pool chi tiết

```
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    "github.com/redis/go-redis/v9"
)

func newRedisClient() *redis.Client {
    return redis.NewClient(&redis.Options{
        // === Connection ===
        Addr:     "localhost:6379",
        Password: "",
        DB:       0,

        // === Pool Settings ===
        // Số connection tối đa trong pool
        // Mặc định: 10 * runtime.GOMAXPROCS
        PoolSize: 100,

        // Số connection tối thiểu idle (giữ sẵn để dùng ngay)
        // Mặc định: 0
        MinIdleConns: 10,

        // Số connection tối đa idle
        // Mặc định: 0 (không giới hạn)
        MaxIdleConns: 50,

        // Thời gian tối đa chờ lấy connection từ pool
        // Nếu pool hết connection, client sẽ chờ tối đa PoolTimeout
        // Mặc định: ReadTimeout + 1 giây
        PoolTimeout: 5 * time.Second,

        // Đóng connection idle sau khoảng thời gian này
        // Mặc định: 30 phút
        ConnMaxIdleTime: 10 * time.Minute,

        // Đóng connection sau khoảng thời gian (bất kể idle hay active)
        // Mặc định: 0 (không giới hạn)
        ConnMaxLifetime: 1 * time.Hour,

        // === Timeouts ===
        // Timeout khi tạo connection mới
        DialTimeout: 5 * time.Second,

        // Timeout khi đọc response
        ReadTimeout: 3 * time.Second,

        // Timeout khi ghi command
        WriteTimeout: 3 * time.Second,
    })
}

func main() {
    ctx := context.Background()
    rdb := newRedisClient()
    defer rdb.Close()

    // Kiểm tra connection
    if err := rdb.Ping(ctx).Err(); err != nil {
        log.Fatalf("Redis ping failed: %v", err)
    }

    // Xem thông tin pool
    stats := rdb.PoolStats()
    fmt.Printf("Pool Stats:\n")
    fmt.Printf("  Hits:       %d (lấy connection từ pool thành công)\n", stats.Hits)
    fmt.Printf("  Misses:     %d (phải tạo connection mới)\n", stats.Misses)
    fmt.Printf("  Timeouts:   %d (chờ connection quá lâu)\n", stats.Timeouts)
    fmt.Printf("  TotalConns: %d (tổng connections hiện tại)\n", stats.TotalConns)
    fmt.Printf("  IdleConns:  %d (connections đang idle)\n", stats.IdleConns)
    fmt.Printf("  StaleConns: %d (connections bị đóng do quá hạn)\n", stats.StaleConns)
}
```

### Production recommendation

```
package main

import (
    "os"
    "runtime"
    "time"

    "github.com/redis/go-redis/v9"
)

func newProductionRedisClient() *redis.Client {
    poolSize := runtime.GOMAXPROCS(0) * 20 // 20 connections per CPU core

    return redis.NewClient(&redis.Options{
        Addr:     os.Getenv("REDIS_ADDR"),     // redis:6379
        Password: os.Getenv("REDIS_PASSWORD"), // from env/secret
        DB:       0,

        PoolSize:        poolSize,
        MinIdleConns:    poolSize / 4,    // Giữ 25% connections sẵn sàng
        MaxIdleConns:    poolSize / 2,    // Tối đa 50% connections idle
        ConnMaxIdleTime: 5 * time.Minute, // Đóng idle connections sớm hơn
        ConnMaxLifetime: 30 * time.Minute,
        PoolTimeout:     4 * time.Second,

        DialTimeout:  3 * time.Second,
        ReadTimeout:  2 * time.Second,
        WriteTimeout: 2 * time.Second,

        // Retry khi connection bị lỗi
        MaxRetries:      3,
        MinRetryBackoff: 100 * time.Millisecond,
        MaxRetryBackoff: 500 * time.Millisecond,
    })
}
```

## 4\. Context Usage

go-redis v9 yêu cầu `context.Context` cho mọi operation. Điều này cho phép:

-   **Timeout**: Hủy operation nếu quá lâu
-   **Cancellation**: Hủy khi request kết thúc
-   **Tracing**: Truyền trace ID qua context

### Timeout per operation

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
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // Context với timeout 2 giây cho operation này
    ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()

    // Nếu Redis chậm hơn 2 giây → operation bị cancel
    val, err := rdb.Get(ctx, "some-key").Result()
    if err != nil {
        if err == context.DeadlineExceeded {
            log.Println("Redis operation timed out!")
            return
        }
        if err == redis.Nil {
            fmt.Println("Key does not exist")
            return
        }
        log.Fatalf("Redis error: %v", err)
    }
    fmt.Printf("Value: %s\n", val)
}
```

### Context trong Gin handler

```
package main

import (
    "encoding/json"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/redis/go-redis/v9"
)

type Product struct {
    ID    string  `json:"id"`
    Name  string  `json:"name"`
    Price float64 `json:"price"`
}

func getProductHandler(rdb *redis.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        // Gin context tự động cancel khi request kết thúc
        // Nếu client disconnect → context cancel → Redis operation cancel
        ctx := c.Request.Context()

        productID := c.Param("id")
        cacheKey := "cache:product:" + productID

        // Đọc từ cache
        data, err := rdb.Get(ctx, cacheKey).Bytes()
        if err == nil {
            var product Product
            if json.Unmarshal(data, &product) == nil {
                c.JSON(http.StatusOK, product)
                return
            }
        }

        // Cache miss → query DB (giả lập)
        product := Product{
            ID:    productID,
            Name:  "Sample Product",
            Price: 99.99,
        }

        // Lưu vào cache
        productJSON, _ := json.Marshal(product)
        rdb.Set(ctx, cacheKey, productJSON, 5*time.Minute)

        c.JSON(http.StatusOK, product)
    }
}

func main() {
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    r := gin.Default()
    r.GET("/products/:id", getProductHandler(rdb))
    r.Run(":8080")
}
```

## 5\. Error Handling

### Các loại error thường gặp

```
package main

import (
    "context"
    "errors"
    "fmt"
    "log"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // Error 1: redis.Nil — key không tồn tại
    val, err := rdb.Get(ctx, "nonexistent-key").Result()
    if err != nil {
        if errors.Is(err, redis.Nil) {
            fmt.Println("Key does not exist (cache miss)")
        } else {
            log.Fatalf("Unexpected error: %v", err)
        }
    } else {
        fmt.Printf("Value: %s\n", val)
    }

    // Error 2: Connection refused — Redis không chạy
    badRdb := redis.NewClient(&redis.Options{Addr: "localhost:9999"})
    _, err = badRdb.Ping(ctx).Result()
    if err != nil {
        fmt.Printf("Connection error: %v\n", err)
        // Output: Connection error: dial tcp [::1]:9999: connect: connection refused
    }

    // Error 3: Context timeout
    // (xem ví dụ ở section trước)

    // Pattern: Helper function xử lý cache miss
    product, err := getFromCache(ctx, rdb, "product:123")
    if err != nil {
        fmt.Printf("Cache error: %v\n", err)
    } else if product == "" {
        fmt.Println("Cache miss — need to query DB")
    } else {
        fmt.Printf("Cache hit: %s\n", product)
    }
}

// getFromCache trả về value hoặc "" nếu cache miss
func getFromCache(ctx context.Context, rdb *redis.Client, key string) (string, error) {
    val, err := rdb.Get(ctx, key).Result()
    if errors.Is(err, redis.Nil) {
        return "", nil // Cache miss — không phải error
    }
    if err != nil {
        return "", fmt.Errorf("redis get %s: %w", key, err) // Real error
    }
    return val, nil
}
```

## 6\. Health Check và Ping

### Implement health check endpoint

```
package main

import (
    "context"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/redis/go-redis/v9"
)

type HealthStatus struct {
    Status    string            `json:"status"`
    Services  map[string]string `json:"services"`
    Timestamp time.Time         `json:"timestamp"`
}

func healthCheckHandler(rdb *redis.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        ctx, cancel := context.WithTimeout(c.Request.Context(), 2*time.Second)
        defer cancel()

        health := HealthStatus{
            Status:    "healthy",
            Services:  make(map[string]string),
            Timestamp: time.Now(),
        }

        // Check Redis
        start := time.Now()
        _, err := rdb.Ping(ctx).Result()
        latency := time.Since(start)

        if err != nil {
            health.Status = "unhealthy"
            health.Services["redis"] = "down: " + err.Error()
            c.JSON(http.StatusServiceUnavailable, health)
            return
        }
        health.Services["redis"] = "up (" + latency.String() + ")"

        // Pool stats
        stats := rdb.PoolStats()
        if stats.Timeouts > 0 {
            health.Status = "degraded"
            health.Services["redis_pool"] = "pool timeouts detected"
        } else {
            health.Services["redis_pool"] = "healthy"
        }

        c.JSON(http.StatusOK, health)
    }
}

func main() {
    rdb := redis.NewClient(&redis.Options{
        Addr:     "localhost:6379",
        PoolSize: 50,
    })

    r := gin.Default()
    r.GET("/health", healthCheckHandler(rdb))
    r.Run(":8080")
}
```

## 7\. Singleton Pattern cho Redis Client

Trong ứng dụng thực tế, bạn chỉ nên tạo **một** Redis client duy nhất và chia sẻ cho toàn bộ application:

```
package main

import (
    "context"
    "fmt"
    "log"
    "os"
    "sync"
    "time"

    "github.com/redis/go-redis/v9"
)

// RedisConfig chứa cấu hình Redis
type RedisConfig struct {
    Addr     string
    Password string
    DB       int
}

var (
    redisClient *redis.Client
    redisOnce   sync.Once
)

// GetRedisClient trả về singleton Redis client
func GetRedisClient(cfg RedisConfig) *redis.Client {
    redisOnce.Do(func() {
        redisClient = redis.NewClient(&redis.Options{
            Addr:            cfg.Addr,
            Password:        cfg.Password,
            DB:              cfg.DB,
            PoolSize:        100,
            MinIdleConns:    10,
            ConnMaxIdleTime: 5 * time.Minute,
            DialTimeout:     3 * time.Second,
            ReadTimeout:     2 * time.Second,
            WriteTimeout:    2 * time.Second,
            MaxRetries:      3,
        })

        // Verify connection
        ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
        defer cancel()

        if err := redisClient.Ping(ctx).Err(); err != nil {
            log.Fatalf("Failed to connect to Redis: %v", err)
        }
        log.Println("Redis connected successfully")
    })
    return redisClient
}

func main() {
    cfg := RedisConfig{
        Addr:     os.Getenv("REDIS_ADDR"),
        Password: os.Getenv("REDIS_PASSWORD"),
        DB:       0,
    }
    if cfg.Addr == "" {
        cfg.Addr = "localhost:6379"
    }

    rdb := GetRedisClient(cfg)
    defer rdb.Close()

    ctx := context.Background()
    rdb.Set(ctx, "test", "singleton works!", time.Minute)
    val, _ := rdb.Get(ctx, "test").Result()
    fmt.Println(val) // singleton works!
}
```

## Tóm tắt

| Mục | Chi tiết |
| --- | --- |
| Thư viện | `github.com/redis/go-redis/v9` |
| Kết nối | `redis.NewClient(&redis.Options{})` |
| URL parse | `redis.ParseURL("redis://:pass@host:port/db")` |
| Pool size | Mặc định 10 \* GOMAXPROCS, production: 50-200 |
| Context | Mọi operation đều cần context |
| Error: key miss | `errors.Is(err, redis.Nil)` |
| Health check | `rdb.Ping(ctx)` + `rdb.PoolStats()` |
| Singleton | Dùng `sync.Once` để tạo một client duy nhất |

> **Bài tiếp theo:** Chúng ta sẽ thực hiện CRUD operations đầy đủ với go-redis — SET/GET, Hash, List, Sorted Set — cùng serialization JSON cho complex objects.
**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/49f67b87-9480-4a63-a3fd-d1427d50000b](https://code4func.com/learn/redis-and-caching-strategies/49f67b87-9480-4a63-a3fd-d1427d50000b)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Cài đặt Redis và Redis CLI
├── Mục tiêu bài học
├── 1\. Cài đặt Redis bằng Docker (Khuyên dùng)
│   └── Chạy Redis container đơn giản
├── Kéo image Redis mới nhất
├── Chạy Redis container
├── Kiểm tra container đang chạy
│   └── Chạy Redis với persistence và password
├── Chạy Redis với password và persistence
├── Kết nối với password
│   └── Docker Compose cho development
├── Khởi động
├── Kiểm tra logs
├── Dừng
├── Dừng và xóa data
│   └── 2\. Cài đặt Redis bằng Homebrew (macOS)
├── Cài đặt Redis
├── Khởi động Redis (chạy foreground)
├── Hoặc chạy như service (background)
├── Kiểm tra trạng thái
├── Dừng service
│   └── 3\. Redis CLI — Công cụ tương tác
│       └── Kết nối cơ bản
├── Kết nối tới Redis local (mặc định localhost:6379)
├── Kết nối tới Redis remote
├── Kết nối với password
├── Kết nối tới database cụ thể (Redis có 16 databases: 0-15)
│   ├── Lệnh đầu tiên: PING
│   └── CRUD cơ bản với Strings
├── SET — lưu một giá trị
├── GET — đọc giá trị
├── SET với TTL (hết hạn sau 60 giây)
├── GET key đã hết hạn
├── DEL — xóa key
├── EXISTS — kiểm tra key tồn tại
├── SET nhiều key cùng lúc
├── GET nhiều key cùng lúc
│   └── Các lệnh quản lý hữu ích
├── KEYS — tìm keys theo pattern (CẢNH BÁO: không dùng trong production!)
├── SCAN — duyệt keys an toàn (dùng trong production thay cho KEYS)
├── TYPE — kiểm tra kiểu dữ liệu
├── DBSIZE — số lượng keys trong database hiện tại
├── FLUSHDB — xóa tất cả keys trong database hiện tại
├── FLUSHALL — xóa tất cả keys trong tất cả databases
├── INFO — thông tin server
│   └── 4\. Cấu hình Redis
│       └── maxmemory — Giới hạn bộ nhớ
├── Kiểm tra cấu hình hiện tại
├── Set maxmemory 256MB
├── Hoặc dùng đơn vị dễ đọc
├── Giới hạn Redis sử dụng tối đa 256MB RAM
│   └── Eviction Policies — Chính sách xóa khi đầy bộ nhớ
├── Xem eviction policy hiện tại
├── Đổi sang allkeys-lru (khuyên dùng cho cache)
│   └── 5\. Redis Insight — GUI Tool
│       └── Cài đặt Redis Insight
├── Cách 1: Download từ trang chủ
├── https://redis.io/insight/
├── Cách 2: Chạy bằng Docker
│   ├── Tính năng nổi bật
│   └── Ví dụ sử dụng: Monitor real-time
├── Trong Redis CLI, dùng MONITOR để xem mọi command real-time
├── Mọi command từ tất cả clients sẽ hiện ra:
├── 1700000001.123456 [0 127.0.0.1:58742] "SET" "user:1" "John"
├── 1700000001.234567 [0 127.0.0.1:58742] "GET" "user:1"
│   └── 6\. Thực hành: Setup Redis cho project
├── Chạy thử
├── Output mong đợi:
├── Redis connected: PONG
├── Value: Xin chào Redis!
└── Done! Redis is working correctly.
    └── Tóm tắt
```

---

## Cài đặt Redis và Redis CLI

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Cài đặt Redis bằng Docker (cách được khuyên dùng) và Homebrew
-   Sử dụng thành thạo Redis CLI với các lệnh cơ bản
-   Cấu hình Redis: maxmemory, eviction policies
-   Biết cách dùng Redis Insight GUI tool

## 1\. Cài đặt Redis bằng Docker (Khuyên dùng)

Docker là cách nhanh nhất và sạch nhất để chạy Redis. Không cần cài đặt gì trên máy host.

### Chạy Redis container đơn giản

```
# Kéo image Redis mới nhất
docker pull redis:7-alpine

# Chạy Redis container
docker run --name my-redis -d -p 6379:6379 redis:7-alpine

# Kiểm tra container đang chạy
docker ps
```

### Chạy Redis với persistence và password

```
# Chạy Redis với password và persistence
docker run --name my-redis \
  -d \
  -p 6379:6379 \
  -v redis-data:/data \
  redis:7-alpine \
  redis-server --requirepass "mypassword" --appendonly yes

# Kết nối với password
docker exec -it my-redis redis-cli -a "mypassword"
```

### Docker Compose cho development

Tạo file `docker-compose.yml`:

```
version: '3.8'
services:
  redis:
    image: redis:7-alpine
    container_name: dev-redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  redis-data:
```

```
# Khởi động
docker-compose up -d

# Kiểm tra logs
docker-compose logs redis

# Dừng
docker-compose down

# Dừng và xóa data
docker-compose down -v
```

## 2\. Cài đặt Redis bằng Homebrew (macOS)

```
# Cài đặt Redis
brew install redis

# Khởi động Redis (chạy foreground)
redis-server

# Hoặc chạy như service (background)
brew services start redis

# Kiểm tra trạng thái
brew services info redis

# Dừng service
brew services stop redis
```

**File cấu hình mặc định:** `/usr/local/etc/redis.conf` (Intel Mac) hoặc `/opt/homebrew/etc/redis.conf` (Apple Silicon)

## 3\. Redis CLI — Công cụ tương tác

Redis CLI (`redis-cli`) là command-line interface để tương tác trực tiếp với Redis server.

### Kết nối cơ bản

```
# Kết nối tới Redis local (mặc định localhost:6379)
redis-cli

# Kết nối tới Redis remote
redis-cli -h 192.168.1.100 -p 6379

# Kết nối với password
redis-cli -a "mypassword"

# Kết nối tới database cụ thể (Redis có 16 databases: 0-15)
redis-cli -n 2
```

### Lệnh đầu tiên: PING

```
127.0.0.1:6379> PING
PONG

127.0.0.1:6379> PING "Hello Redis"
"Hello Redis"
```

Nếu nhận được `PONG`, Redis đang hoạt động bình thường!

### CRUD cơ bản với Strings

```
# SET — lưu một giá trị
127.0.0.1:6379> SET name "Nguyen Van A"
OK

# GET — đọc giá trị
127.0.0.1:6379> GET name
"Nguyen Van A"

# SET với TTL (hết hạn sau 60 giây)
127.0.0.1:6379> SET session:abc123 "user-data" EX 60
OK

# GET key đã hết hạn
127.0.0.1:6379> GET session:abc123
(nil)

# DEL — xóa key
127.0.0.1:6379> DEL name
(integer) 1

# EXISTS — kiểm tra key tồn tại
127.0.0.1:6379> EXISTS name
(integer) 0

# SET nhiều key cùng lúc
127.0.0.1:6379> MSET key1 "value1" key2 "value2" key3 "value3"
OK

# GET nhiều key cùng lúc
127.0.0.1:6379> MGET key1 key2 key3
1) "value1"
2) "value2"
3) "value3"
```

### Các lệnh quản lý hữu ích

```
# KEYS — tìm keys theo pattern (CẢNH BÁO: không dùng trong production!)
127.0.0.1:6379> KEYS *
1) "key1"
2) "key2"
3) "key3"

127.0.0.1:6379> KEYS session:*
1) "session:abc123"

# SCAN — duyệt keys an toàn (dùng trong production thay cho KEYS)
127.0.0.1:6379> SCAN 0 MATCH session:* COUNT 10
1) "0"
2) 1) "session:abc123"

# TYPE — kiểm tra kiểu dữ liệu
127.0.0.1:6379> TYPE key1
string

# DBSIZE — số lượng keys trong database hiện tại
127.0.0.1:6379> DBSIZE
(integer) 3

# FLUSHDB — xóa tất cả keys trong database hiện tại
127.0.0.1:6379> FLUSHDB
OK

# FLUSHALL — xóa tất cả keys trong tất cả databases
127.0.0.1:6379> FLUSHALL
OK

# INFO — thông tin server
127.0.0.1:6379> INFO server
127.0.0.1:6379> INFO memory
127.0.0.1:6379> INFO stats
```

> **Cảnh báo quan trọng:** Lệnh `KEYS *` quét toàn bộ keyspace và block Redis. Trong production với hàng triệu keys, lệnh này có thể làm Redis không phản hồi trong vài giây. Luôn dùng `SCAN` thay thế.

## 4\. Cấu hình Redis

### maxmemory — Giới hạn bộ nhớ

```
# Kiểm tra cấu hình hiện tại
127.0.0.1:6379> CONFIG GET maxmemory
1) "maxmemory"
2) "0"   # 0 = không giới hạn

# Set maxmemory 256MB
127.0.0.1:6379> CONFIG SET maxmemory 268435456
OK

# Hoặc dùng đơn vị dễ đọc
127.0.0.1:6379> CONFIG SET maxmemory 256mb
OK
```

Trong file `redis.conf`:

```
# Giới hạn Redis sử dụng tối đa 256MB RAM
maxmemory 256mb
```

> **Best practice:** Luôn set maxmemory trong production. Nếu không, Redis sẽ dùng hết RAM → OOM Killer của OS sẽ kill Redis process.

### Eviction Policies — Chính sách xóa khi đầy bộ nhớ

Khi Redis đạt maxmemory, cần quyết định xóa key nào. Redis hỗ trợ nhiều eviction policies:

| Policy | Mô tả |
| --- | --- |
| `noeviction` | Trả lỗi khi hết memory (mặc định) |
| `allkeys-lru` | Xóa key ít được sử dụng nhất (LRU) trong tất cả keys |
| `volatile-lru` | Xóa key LRU chỉ trong các keys có TTL |
| `allkeys-lfu` | Xóa key ít được dùng nhất (LFU — theo tần suất) |
| `volatile-lfu` | Xóa key LFU chỉ trong các keys có TTL |
| `allkeys-random` | Xóa random trong tất cả keys |
| `volatile-random` | Xóa random chỉ trong keys có TTL |
| `volatile-ttl` | Xóa key có TTL ngắn nhất |

```
# Xem eviction policy hiện tại
127.0.0.1:6379> CONFIG GET maxmemory-policy
1) "maxmemory-policy"
2) "noeviction"

# Đổi sang allkeys-lru (khuyên dùng cho cache)
127.0.0.1:6379> CONFIG SET maxmemory-policy allkeys-lru
OK
```

**Chọn policy nào?**

-   **Cache thuần túy** (mọi key đều có thể mất): `allkeys-lru` hoặc `allkeys-lfu`
-   **Cache + persistent data** (một số key quan trọng không set TTL): `volatile-lru`
-   **Session store**: `volatile-ttl` (session nào gần hết hạn → xóa trước)
-   **Không muốn mất data**: `noeviction` (nhưng phải monitor memory!)

## 5\. Redis Insight — GUI Tool

**Redis Insight** (trước đây là RedisInsight) là GUI tool miễn phí từ Redis Ltd., giúp quản lý và debug Redis trực quan.

### Cài đặt Redis Insight

```
# Cách 1: Download từ trang chủ
# https://redis.io/insight/

# Cách 2: Chạy bằng Docker
docker run --name redis-insight \
  -d \
  -p 5540:5540 \
  redis/redisinsight:latest
```

Sau khi cài đặt, mở browser tại `http://localhost:5540` và thêm Redis connection.

### Tính năng nổi bật

1.  **Browser**: Duyệt và tìm kiếm keys, xem/sửa giá trị trực quan
2.  **CLI**: Terminal tích hợp trong browser, có autocomplete
3.  **Profiler**: Xem real-time tất cả commands đang được gửi tới Redis
4.  **Slow Log**: Phát hiện commands chạy chậm
5.  **Memory Analysis**: Phân tích memory usage theo key pattern

### Ví dụ sử dụng: Monitor real-time

```
# Trong Redis CLI, dùng MONITOR để xem mọi command real-time
127.0.0.1:6379> MONITOR
OK
# Mọi command từ tất cả clients sẽ hiện ra:
# 1700000001.123456 [0 127.0.0.1:58742] "SET" "user:1" "John"
# 1700000001.234567 [0 127.0.0.1:58742] "GET" "user:1"
```

> **Cảnh báo:** Lệnh `MONITOR` ảnh hưởng performance (giảm ~50% throughput). Chỉ dùng khi debug, không dùng trong production lâu dài.

## 6\. Thực hành: Setup Redis cho project

Tạo script Go đơn giản để kiểm tra kết nối Redis:

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

    // Kết nối Redis
    rdb := redis.NewClient(&redis.Options{
        Addr:     "localhost:6379",
        Password: "",  // không password
        DB:       0,   // database mặc định
    })
    defer rdb.Close()

    // Ping để kiểm tra kết nối
    pong, err := rdb.Ping(ctx).Result()
    if err != nil {
        log.Fatalf("Không thể kết nối Redis: %v", err)
    }
    fmt.Printf("Redis connected: %s\n", pong)

    // Test SET/GET
    err = rdb.Set(ctx, "test:hello", "Xin chào Redis!", 0).Err()
    if err != nil {
        log.Fatalf("SET failed: %v", err)
    }

    val, err := rdb.Get(ctx, "test:hello").Result()
    if err != nil {
        log.Fatalf("GET failed: %v", err)
    }
    fmt.Printf("Value: %s\n", val)

    // Cleanup
    rdb.Del(ctx, "test:hello")
    fmt.Println("Done! Redis is working correctly.")
}
```

```
# Chạy thử
go mod init redis-test
go mod tidy
go run main.go

# Output mong đợi:
# Redis connected: PONG
# Value: Xin chào Redis!
# Done! Redis is working correctly.
```

## Tóm tắt

| Mục | Chi tiết |
| --- | --- |
| Cài đặt | Docker (khuyên dùng): `docker run redis:7-alpine` |
| CLI | `redis-cli`: PING, SET, GET, DEL, KEYS, SCAN |
| maxmemory | Luôn set trong production, ví dụ 256mb |
| Eviction | `allkeys-lru` cho cache, `volatile-ttl` cho sessions |
| GUI | Redis Insight — browser-based, miễn phí |
| Cảnh báo | Không dùng KEYS, MONITOR trong production |

> **Bài tiếp theo:** Chúng ta sẽ khám phá 5 kiểu dữ liệu chính của Redis — String, List, Set, Hash, Sorted Set — cùng các use case thực tế cho từng loại.
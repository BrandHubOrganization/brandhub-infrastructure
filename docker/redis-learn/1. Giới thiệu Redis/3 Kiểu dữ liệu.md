**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/a847bae4-53e6-430c-9e07-b3650ca27c85](https://code4func.com/learn/redis-and-caching-strategies/a847bae4-53e6-430c-9e07-b3650ca27c85)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Kiểu dữ liệu: String, List, Set, Hash, Sorted Set
├── Mục tiêu bài học
├── 1\. String — Kiểu dữ liệu cơ bản nhất
│   └── Các lệnh cơ bản
├── SET / GET — lưu và đọc giá trị
├── SETNX — Set if Not Exists (chỉ set nếu key chưa tồn tại)
├── SETEX — Set với expiry (giây)
├── OTP "123456" sẽ tự xóa sau 5 phút
├── MSET / MGET — Set/Get nhiều keys cùng lúc
│   └── Atomic Counter — Tăng/giảm số nguyên
├── INCR — tăng 1
├── INCRBY — tăng N
├── DECR — giảm 1
├── DECRBY — giảm N
├── INCRBYFLOAT — tăng số thực
│   ├── Use case: Cache JSON object
│   └── 2\. List — Danh sách có thứ tự
│       └── Các lệnh cơ bản
├── LPUSH — thêm vào đầu list (Left Push)
├── RPUSH — thêm vào cuối list (Right Push)
├── LRANGE — đọc phần tử từ start đến stop (0-indexed)
├── LPOP / RPOP — lấy và xóa phần tử
├── LLEN — đếm số phần tử
├── LINDEX — đọc phần tử theo index
├── LTRIM — giữ lại chỉ phần tử từ start đến stop
├── Chỉ giữ 100 notifications mới nhất
│   ├── Use case: Activity Feed (mới nhất lên đầu)
│   └── 3\. Set — Tập hợp không trùng lặp
│       └── Các lệnh cơ bản
├── SADD — thêm phần tử
├── SADD phần tử đã tồn tại → bị bỏ qua
├── SMEMBERS — liệt kê tất cả phần tử
├── SISMEMBER — kiểm tra phần tử có tồn tại
├── SCARD — đếm số phần tử
├── SREM — xóa phần tử
├── Phép toán tập hợp
├── SINTER — giao (intersection)
├── SUNION — hợp (union)
├── SDIFF — hiệu (difference): có trong go nhưng không có trong python
│   ├── Use case: Online Users Tracking
│   └── 4\. Hash — Object với nhiều fields
│       └── Các lệnh cơ bản
├── HSET — set một hoặc nhiều fields
├── HGET — đọc một field
├── HGETALL — đọc tất cả fields
├── HMGET — đọc nhiều fields cụ thể
├── HDEL — xóa field
├── HEXISTS — kiểm tra field tồn tại
├── HLEN — đếm số fields
├── HINCRBY — tăng giá trị số trong field
│   ├── Use case: User Profile Cache
│   └── 5\. Sorted Set — Tập hợp có điểm số
│       └── Các lệnh cơ bản
├── ZADD — thêm phần tử với score
├── ZRANGE — lấy phần tử theo thứ tự score tăng dần
├── ZREVRANGE — lấy theo thứ tự giảm dần (top players)
├── ZRANK — lấy rank (0-indexed, từ thấp nhất)
├── ZREVRANK — lấy rank từ cao nhất
├── ZSCORE — lấy score của member
├── ZINCRBY — tăng score
├── ZRANGEBYSCORE — lấy theo khoảng score
├── ZCARD — đếm số phần tử
├── ZREM — xóa phần tử
└── ZCOUNT — đếm phần tử trong khoảng score
    ├── Use case: Trending Articles (kết hợp score + time)
    └── 6\. Tóm tắt: Chọn đúng kiểu dữ liệu
```

---

## Kiểu dữ liệu: String, List, Set, Hash, Sorted Set

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Nắm vững 5 kiểu dữ liệu chính của Redis
-   Biết các lệnh quan trọng cho mỗi kiểu
-   Hiểu use case thực tế phù hợp cho từng kiểu dữ liệu
-   Có thể chọn đúng kiểu dữ liệu cho bài toán cụ thể

## 1\. String — Kiểu dữ liệu cơ bản nhất

String là kiểu dữ liệu đơn giản nhất và cũng linh hoạt nhất trong Redis. Một Redis String có thể chứa bất kỳ dữ liệu nào: text, số, JSON, thậm chí binary data (hình ảnh, file). Kích thước tối đa: **512 MB**.

### Các lệnh cơ bản

```
# SET / GET — lưu và đọc giá trị
127.0.0.1:6379> SET user:name "Nguyen Van A"
OK
127.0.0.1:6379> GET user:name
"Nguyen Van A"

# SETNX — Set if Not Exists (chỉ set nếu key chưa tồn tại)
127.0.0.1:6379> SETNX lock:order:123 "processing"
(integer) 1   # Thành công
127.0.0.1:6379> SETNX lock:order:123 "processing"
(integer) 0   # Thất bại — key đã tồn tại

# SETEX — Set với expiry (giây)
127.0.0.1:6379> SETEX otp:user123 300 "123456"
OK
# OTP "123456" sẽ tự xóa sau 5 phút

# MSET / MGET — Set/Get nhiều keys cùng lúc
127.0.0.1:6379> MSET user:1:name "Alice" user:1:email "alice@test.com" user:1:age "25"
OK
127.0.0.1:6379> MGET user:1:name user:1:email user:1:age
1) "Alice"
2) "alice@test.com"
3) "25"
```

### Atomic Counter — Tăng/giảm số nguyên

```
# INCR — tăng 1
127.0.0.1:6379> SET page:views 0
OK
127.0.0.1:6379> INCR page:views
(integer) 1
127.0.0.1:6379> INCR page:views
(integer) 2

# INCRBY — tăng N
127.0.0.1:6379> INCRBY page:views 10
(integer) 12

# DECR — giảm 1
127.0.0.1:6379> DECR page:views
(integer) 11

# DECRBY — giảm N
127.0.0.1:6379> DECRBY page:views 5
(integer) 6

# INCRBYFLOAT — tăng số thực
127.0.0.1:6379> SET product:price 99.99
OK
127.0.0.1:6379> INCRBYFLOAT product:price 0.01
"100"
```

> **Atomic operations:** INCR/DECR là atomic — khi nhiều clients cùng INCR một key, mỗi operation đều được thực hiện chính xác, không bao giờ bị race condition. Đây là lý do Redis phù hợp cho counters.

### Use case: Cache JSON object

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

type User struct {
    ID    string `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    // Serialize user thành JSON string
    user := User{ID: "u001", Name: "Nguyen Van A", Email: "a@test.com"}
    data, _ := json.Marshal(user)

    // Lưu vào Redis với TTL 1 giờ
    rdb.Set(ctx, "user:u001", data, time.Hour)

    // Đọc và deserialize
    val, err := rdb.Get(ctx, "user:u001").Bytes()
    if err != nil {
        log.Fatal(err)
    }

    var cached User
    json.Unmarshal(val, &cached)
    fmt.Printf("Cached user: %+v\n", cached)
}
```

## 2\. List — Danh sách có thứ tự

Redis List là một **linked list** — thêm/xóa ở đầu hoặc cuối rất nhanh (O(1)), nhưng truy cập theo index chậm (O(n)).

### Các lệnh cơ bản

```
# LPUSH — thêm vào đầu list (Left Push)
127.0.0.1:6379> LPUSH notifications "Bạn có tin nhắn mới"
(integer) 1
127.0.0.1:6379> LPUSH notifications "Đơn hàng đã được xác nhận"
(integer) 2
127.0.0.1:6379> LPUSH notifications "Chào mừng bạn đến với hệ thống"
(integer) 3

# RPUSH — thêm vào cuối list (Right Push)
127.0.0.1:6379> RPUSH queue:email "email1@test.com"
(integer) 1
127.0.0.1:6379> RPUSH queue:email "email2@test.com"
(integer) 2

# LRANGE — đọc phần tử từ start đến stop (0-indexed)
127.0.0.1:6379> LRANGE notifications 0 -1
1) "Chào mừng bạn đến với hệ thống"
2) "Đơn hàng đã được xác nhận"
3) "Bạn có tin nhắn mới"

# LPOP / RPOP — lấy và xóa phần tử
127.0.0.1:6379> LPOP notifications
"Chào mừng bạn đến với hệ thống"

127.0.0.1:6379> RPOP queue:email
"email2@test.com"

# LLEN — đếm số phần tử
127.0.0.1:6379> LLEN notifications
(integer) 2

# LINDEX — đọc phần tử theo index
127.0.0.1:6379> LINDEX notifications 0
"Đơn hàng đã được xác nhận"

# LTRIM — giữ lại chỉ phần tử từ start đến stop
127.0.0.1:6379> LTRIM notifications 0 99
OK
# Chỉ giữ 100 notifications mới nhất
```

### Use case: Activity Feed (mới nhất lên đầu)

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

    key := "feed:user:123"

    // Thêm activity mới (LPUSH = mới nhất ở đầu)
    rdb.LPush(ctx, key, "Đã hoàn thành bài học Go Basics")
    rdb.LPush(ctx, key, "Đã đạt 100 XP")
    rdb.LPush(ctx, key, "Đã mở khóa badge 'Fast Learner'")

    // Giữ tối đa 50 activities
    rdb.LTrim(ctx, key, 0, 49)

    // Lấy 10 activities mới nhất
    activities, _ := rdb.LRange(ctx, key, 0, 9).Result()
    for i, act := range activities {
        fmt.Printf("%d. %s\n", i+1, act)
    }
}
```

## 3\. Set — Tập hợp không trùng lặp

Redis Set là tập hợp các string **không có thứ tự** và **không trùng lặp**. Hỗ trợ các phép toán tập hợp: union, intersection, difference.

### Các lệnh cơ bản

```
# SADD — thêm phần tử
127.0.0.1:6379> SADD tags:course:go "backend" "golang" "api" "web"
(integer) 4

# SADD phần tử đã tồn tại → bị bỏ qua
127.0.0.1:6379> SADD tags:course:go "backend"
(integer) 0

# SMEMBERS — liệt kê tất cả phần tử
127.0.0.1:6379> SMEMBERS tags:course:go
1) "api"
2) "backend"
3) "golang"
4) "web"

# SISMEMBER — kiểm tra phần tử có tồn tại
127.0.0.1:6379> SISMEMBER tags:course:go "backend"
(integer) 1
127.0.0.1:6379> SISMEMBER tags:course:go "frontend"
(integer) 0

# SCARD — đếm số phần tử
127.0.0.1:6379> SCARD tags:course:go
(integer) 4

# SREM — xóa phần tử
127.0.0.1:6379> SREM tags:course:go "web"
(integer) 1

# Phép toán tập hợp
127.0.0.1:6379> SADD tags:course:python "backend" "python" "ai" "data"
(integer) 4

# SINTER — giao (intersection)
127.0.0.1:6379> SINTER tags:course:go tags:course:python
1) "backend"

# SUNION — hợp (union)
127.0.0.1:6379> SUNION tags:course:go tags:course:python
1) "api"
2) "backend"
3) "golang"
4) "python"
5) "ai"
6) "data"

# SDIFF — hiệu (difference): có trong go nhưng không có trong python
127.0.0.1:6379> SDIFF tags:course:go tags:course:python
1) "api"
2) "golang"
```

### Use case: Online Users Tracking

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

    key := "online:users"

    // User online
    rdb.SAdd(ctx, key, "user:1", "user:2", "user:3")

    // User offline
    rdb.SRem(ctx, key, "user:2")

    // Kiểm tra user có online không
    isOnline, _ := rdb.SIsMember(ctx, key, "user:1").Result()
    fmt.Printf("User 1 online: %v\n", isOnline) // true

    // Đếm users online
    count, _ := rdb.SCard(ctx, key).Result()
    fmt.Printf("Online users: %d\n", count) // 2
}
```

## 4\. Hash — Object với nhiều fields

Redis Hash giống như một "mini dictionary" — lưu trữ tập hợp các field-value pairs. Rất phù hợp để lưu objects (user, product, settings).

### Các lệnh cơ bản

```
# HSET — set một hoặc nhiều fields
127.0.0.1:6379> HSET user:1001 name "Nguyen Van A" email "a@test.com" age 25 role "student"
(integer) 4

# HGET — đọc một field
127.0.0.1:6379> HGET user:1001 name
"Nguyen Van A"

# HGETALL — đọc tất cả fields
127.0.0.1:6379> HGETALL user:1001
1) "name"
2) "Nguyen Van A"
3) "email"
4) "a@test.com"
5) "age"
6) "25"
7) "role"
8) "student"

# HMGET — đọc nhiều fields cụ thể
127.0.0.1:6379> HMGET user:1001 name email
1) "Nguyen Van A"
2) "a@test.com"

# HDEL — xóa field
127.0.0.1:6379> HDEL user:1001 age
(integer) 1

# HEXISTS — kiểm tra field tồn tại
127.0.0.1:6379> HEXISTS user:1001 name
(integer) 1

# HLEN — đếm số fields
127.0.0.1:6379> HLEN user:1001
(integer) 3

# HINCRBY — tăng giá trị số trong field
127.0.0.1:6379> HSET user:1001 xp 0
(integer) 1
127.0.0.1:6379> HINCRBY user:1001 xp 50
(integer) 50
127.0.0.1:6379> HINCRBY user:1001 xp 30
(integer) 80
```

### Use case: User Profile Cache

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

    key := "user:1001"

    // Lưu user profile
    rdb.HSet(ctx, key, map[string]interface{}{
        "name":  "Nguyen Van A",
        "email": "a@test.com",
        "xp":    0,
        "level": 1,
    })

    // Cập nhật XP (atomic)
    newXP, _ := rdb.HIncrBy(ctx, key, "xp", 100).Result()
    fmt.Printf("New XP: %d\n", newXP)

    // Đọc toàn bộ profile
    profile, _ := rdb.HGetAll(ctx, key).Result()
    for field, value := range profile {
        fmt.Printf("  %s: %s\n", field, value)
    }

    // Chỉ đọc fields cần thiết
    values, _ := rdb.HMGet(ctx, key, "name", "xp").Result()
    fmt.Printf("Name: %v, XP: %v\n", values[0], values[1])
}
```

**Hash vs String cho objects:**

| Tiêu chí | Hash | String (JSON) |
| --- | --- | --- |
| Cập nhật 1 field | `HSET key field val` — nhanh | GET → unmarshal → update → marshal → SET — chậm |
| Đọc 1 field | `HGET key field` | GET toàn bộ JSON → unmarshal |
| Memory | Tiết kiệm hơn với objects nhỏ | Overhead JSON format |
| TTL per field | Không hỗ trợ | Không hỗ trợ (TTL cho cả key) |

> **Quy tắc:** Nếu bạn cần update/read từng field riêng lẻ → dùng Hash. Nếu bạn luôn read/write toàn bộ object → dùng String (JSON).

## 5\. Sorted Set — Tập hợp có điểm số

Sorted Set (ZSet) giống Set nhưng mỗi phần tử có một **score** (điểm số). Redis tự động sắp xếp theo score từ thấp đến cao. Đây là kiểu dữ liệu mạnh mẽ nhất của Redis.

### Các lệnh cơ bản

```
# ZADD — thêm phần tử với score
127.0.0.1:6379> ZADD leaderboard 1500 "alice" 2300 "bob" 1800 "charlie" 2100 "diana"
(integer) 4

# ZRANGE — lấy phần tử theo thứ tự score tăng dần
127.0.0.1:6379> ZRANGE leaderboard 0 -1 WITHSCORES
1) "alice"
2) "1500"
3) "charlie"
4) "1800"
5) "diana"
6) "2100"
7) "bob"
8) "2300"

# ZREVRANGE — lấy theo thứ tự giảm dần (top players)
127.0.0.1:6379> ZREVRANGE leaderboard 0 2 WITHSCORES
1) "bob"
2) "2300"
3) "diana"
4) "2100"
5) "charlie"
6) "1800"

# ZRANK — lấy rank (0-indexed, từ thấp nhất)
127.0.0.1:6379> ZRANK leaderboard "alice"
(integer) 0

# ZREVRANK — lấy rank từ cao nhất
127.0.0.1:6379> ZREVRANK leaderboard "bob"
(integer) 0   # Bob rank #1

# ZSCORE — lấy score của member
127.0.0.1:6379> ZSCORE leaderboard "charlie"
"1800"

# ZINCRBY — tăng score
127.0.0.1:6379> ZINCRBY leaderboard 500 "alice"
"2000"

# ZRANGEBYSCORE — lấy theo khoảng score
127.0.0.1:6379> ZRANGEBYSCORE leaderboard 1800 2200 WITHSCORES
1) "charlie"
2) "1800"
3) "alice"
4) "2000"
5) "diana"
6) "2100"

# ZCARD — đếm số phần tử
127.0.0.1:6379> ZCARD leaderboard
(integer) 4

# ZREM — xóa phần tử
127.0.0.1:6379> ZREM leaderboard "alice"
(integer) 1

# ZCOUNT — đếm phần tử trong khoảng score
127.0.0.1:6379> ZCOUNT leaderboard 1800 2300
(integer) 3
```

### Use case: Trending Articles (kết hợp score + time)

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

    key := "trending:articles"

    // Thêm articles — score là số views
    rdb.ZAdd(ctx, key, redis.Z{Score: 150, Member: "article:1"})
    rdb.ZAdd(ctx, key, redis.Z{Score: 320, Member: "article:2"})
    rdb.ZAdd(ctx, key, redis.Z{Score: 89, Member: "article:3"})
    rdb.ZAdd(ctx, key, redis.Z{Score: 450, Member: "article:4"})

    // Khi user xem article → tăng view count
    rdb.ZIncrBy(ctx, key, 1, "article:3")

    // Lấy top 3 trending articles
    top3, _ := rdb.ZRevRangeWithScores(ctx, key, 0, 2).Result()
    fmt.Println("Top 3 Trending:")
    for i, z := range top3 {
        fmt.Printf("  #%d: %s — %0.f views\n", i+1, z.Member, z.Score)
    }

    // Dùng WITHSCORES + timestamp cho time-decay ranking
    // Score = views * decay_factor(time)
    now := float64(time.Now().Unix())
    rdb.ZAdd(ctx, "trending:decay", redis.Z{
        Score:  150 / (now - 86400), // views / age_in_seconds
        Member: "article:1",
    })
}
```

## 6\. Tóm tắt: Chọn đúng kiểu dữ liệu

| Bài toán | Kiểu dữ liệu | Lý do |
| --- | --- | --- |
| Cache API response | String (JSON) | Đơn giản, SET/GET là đủ |
| User profile cache | Hash | Cập nhật từng field riêng lẻ |
| Session data | String hoặc Hash | Tùy cần update từng field hay không |
| Counter (views, likes) | String (INCR) | Atomic increment |
| Activity feed | List | LPUSH + LTRIM giữ N items mới nhất |
| Online users | Set | Unique members, SCARD đếm nhanh |
| Tags | Set | Unique, hỗ trợ SINTER cho filter |
| Leaderboard | Sorted Set | Tự sắp xếp, ZRANK lấy rank O(log N) |
| Trending/priority queue | Sorted Set | Score-based ordering |
| Rate limiting | String (INCR) + EXPIRE | Atomic counter với TTL |

> **Bài tiếp theo:** Chúng ta sẽ tìm hiểu về TTL và Expiration — cách quản lý thời gian sống của dữ liệu trong Redis.
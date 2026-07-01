**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/57cf9bf0-6f22-40a5-b61b-d018cc304e5a](https://code4func.com/learn/redis-and-caching-strategies/57cf9bf0-6f22-40a5-b61b-d018cc304e5a)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── CRUD Operations với go-redis
├── Mục tiêu bài học
├── 1\. String Operations
│   └── Set/Get/Del cơ bản
├── 2\. JSON Serialization cho Complex Objects
├── 3\. Hash Operations trong Go
├── 4\. List và Set Operations
├── 5\. SCAN — Duyệt keys an toàn
├── 6\. Thực hành: User Session CRUD
└── Tóm tắt
```

---

## CRUD Operations với go-redis

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Thực hiện đầy đủ Set/Get/Del operations trong Go
-   Làm việc với tất cả kiểu dữ liệu Redis trong Go
-   Serialize/deserialize complex objects bằng JSON
-   Sử dụng SCAN để duyệt keys an toàn
-   Xây dựng một ví dụ CRUD hoàn chỉnh: User Session Management

## 1\. String Operations

### Set/Get/Del cơ bản

```
package main

import (
    "context"
    "errors"
    "fmt"
    "log"
    "time"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // === SET ===
    // Set không có TTL (tồn tại vĩnh viễn)
    err := rdb.Set(ctx, "name", "Nguyen Van A", 0).Err()
    if err != nil {
        log.Fatal(err)
    }

    // Set với TTL 5 phút
    err = rdb.Set(ctx, "session:abc", "user-data", 5*time.Minute).Err()
    if err != nil {
        log.Fatal(err)
    }

    // SetNX — Set if Not eXists
    wasSet, err := rdb.SetNX(ctx, "lock:order:123", "processing", 30*time.Second).Result()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Lock acquired: %v\n", wasSet) // true nếu lần đầu

    // SetXX — Set if eXists (chỉ update, không create)
    wasSet, err = rdb.SetXX(ctx, "name", "Tran Van B", 0).Result()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Updated: %v\n", wasSet) // true vì key "name" đã tồn tại

    // === GET ===
    // Get trả về string
    val, err := rdb.Get(ctx, "name").Result()
    if errors.Is(err, redis.Nil) {
        fmt.Println("Key not found")
    } else if err != nil {
        log.Fatal(err)
    } else {
        fmt.Printf("name = %s\n", val)
    }

    // Get trả về int
    rdb.Set(ctx, "counter", "42", 0)
    num, err := rdb.Get(ctx, "counter").Int()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("counter = %d\n", num)

    // Get trả về float
    rdb.Set(ctx, "price", "99.99", 0)
    price, err := rdb.Get(ctx, "price").Float64()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("price = %.2f\n", price)

    // Get trả về bytes
    rdb.Set(ctx, "binary", "raw data", 0)
    data, err := rdb.Get(ctx, "binary").Bytes()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("bytes: %v\n", data)

    // === DEL ===
    // Xóa một key
    deleted, err := rdb.Del(ctx, "name").Result()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Deleted %d key(s)\n", deleted)

    // Xóa nhiều keys
    deleted, err = rdb.Del(ctx, "session:abc", "counter", "price", "binary", "lock:order:123").Result()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Deleted %d key(s)\n", deleted)

    // === INCR/DECR ===
    rdb.Set(ctx, "views", "0", 0)
    newVal, _ := rdb.Incr(ctx, "views").Result()
    fmt.Printf("After INCR: %d\n", newVal) // 1

    newVal, _ = rdb.IncrBy(ctx, "views", 10).Result()
    fmt.Printf("After INCRBY 10: %d\n", newVal) // 11

    newVal, _ = rdb.Decr(ctx, "views").Result()
    fmt.Printf("After DECR: %d\n", newVal) // 10

    // MSET / MGET
    rdb.MSet(ctx, "k1", "v1", "k2", "v2", "k3", "v3")
    values, _ := rdb.MGet(ctx, "k1", "k2", "k3", "k4").Result()
    for i, v := range values {
        fmt.Printf("  k%d = %v\n", i+1, v) // k4 = <nil>
    }

    // Cleanup
    rdb.Del(ctx, "views", "k1", "k2", "k3")
}
```

## 2\. JSON Serialization cho Complex Objects

Redis lưu trữ strings, nên để lưu Go struct, bạn cần serialize thành JSON.

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

// User là entity từ database
type User struct {
    ID        string    `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    Role      string    `json:"role"`
    XP        int       `json:"xp"`
    CreatedAt time.Time `json:"created_at"`
}

// RedisCache wrapper cho Redis operations
type RedisCache struct {
    client *redis.Client
}

func NewRedisCache(addr string) *RedisCache {
    return &RedisCache{
        client: redis.NewClient(&redis.Options{Addr: addr}),
    }
}

// SetJSON lưu object dưới dạng JSON
func (rc *RedisCache) SetJSON(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
    data, err := json.Marshal(value)
    if err != nil {
        return fmt.Errorf("json marshal: %w", err)
    }
    return rc.client.Set(ctx, key, data, ttl).Err()
}

// GetJSON đọc và unmarshal JSON vào struct
func (rc *RedisCache) GetJSON(ctx context.Context, key string, dest interface{}) error {
    data, err := rc.client.Get(ctx, key).Bytes()
    if err != nil {
        return err // trả về redis.Nil nếu key không tồn tại
    }
    return json.Unmarshal(data, dest)
}

func main() {
    ctx := context.Background()
    cache := NewRedisCache("localhost:6379")

    // Lưu user vào cache
    user := User{
        ID:        "user-001",
        Name:      "Nguyen Van A",
        Email:     "a@example.com",
        Role:      "student",
        XP:        1500,
        CreatedAt: time.Now(),
    }

    err := cache.SetJSON(ctx, "user:user-001", user, 30*time.Minute)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println("User cached successfully")

    // Đọc user từ cache
    var cachedUser User
    err = cache.GetJSON(ctx, "user:user-001", &cachedUser)
    if errors.Is(err, redis.Nil) {
        fmt.Println("Cache miss")
    } else if err != nil {
        log.Fatal(err)
    } else {
        fmt.Printf("Cached: %+v\n", cachedUser)
    }

    // Lưu slice
    users := []User{
        {ID: "u1", Name: "Alice", Email: "alice@test.com"},
        {ID: "u2", Name: "Bob", Email: "bob@test.com"},
    }
    cache.SetJSON(ctx, "users:page:1", users, 5*time.Minute)

    // Đọc slice
    var cachedUsers []User
    cache.GetJSON(ctx, "users:page:1", &cachedUsers)
    fmt.Printf("Cached %d users\n", len(cachedUsers))
}
```

## 3\. Hash Operations trong Go

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

    key := "user:profile:1001"

    // === HSET — set multiple fields ===
    err := rdb.HSet(ctx, key, map[string]interface{}{
        "name":    "Nguyen Van A",
        "email":   "a@test.com",
        "xp":      0,
        "level":   1,
        "streak":  0,
        "premium": false,
    }).Err()
    if err != nil {
        log.Fatal(err)
    }

    // === HGET — đọc một field ===
    name, err := rdb.HGet(ctx, key, "name").Result()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Name: %s\n", name)

    // === HGETALL — đọc tất cả fields ===
    fields, err := rdb.HGetAll(ctx, key).Result()
    if err != nil {
        log.Fatal(err)
    }
    for k, v := range fields {
        fmt.Printf("  %s: %s\n", k, v)
    }

    // === HMGET — đọc nhiều fields ===
    values, _ := rdb.HMGet(ctx, key, "name", "email", "xp").Result()
    fmt.Printf("Name=%v, Email=%v, XP=%v\n", values[0], values[1], values[2])

    // === HINCRBY — tăng XP (atomic) ===
    newXP, _ := rdb.HIncrBy(ctx, key, "xp", 100).Result()
    fmt.Printf("New XP: %d\n", newXP)

    // === HDEL — xóa field ===
    rdb.HDel(ctx, key, "streak")

    // === HEXISTS — kiểm tra field ===
    exists, _ := rdb.HExists(ctx, key, "premium").Result()
    fmt.Printf("Has premium field: %v\n", exists)

    // === HLEN — đếm fields ===
    length, _ := rdb.HLen(ctx, key).Result()
    fmt.Printf("Number of fields: %d\n", length)

    // Scan hash vào struct
    type UserProfile struct {
        Name    string `redis:"name"`
        Email   string `redis:"email"`
        XP      int    `redis:"xp"`
        Level   int    `redis:"level"`
        Premium bool   `redis:"premium"`
    }

    var profile UserProfile
    err = rdb.HGetAll(ctx, key).Scan(&profile)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Profile struct: %+v\n", profile)

    _ = strconv.Itoa(0) // suppress unused import

    // Cleanup
    rdb.Del(ctx, key)
}
```

## 4\. List và Set Operations

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
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    // ========================
    // LIST Operations
    // ========================
    listKey := "notifications:user:1"

    // LPUSH — thêm vào đầu list
    rdb.LPush(ctx, listKey, "Welcome to the platform!")
    rdb.LPush(ctx, listKey, "Course 'Go Basics' is available")
    rdb.LPush(ctx, listKey, "You earned 100 XP!")

    // LRANGE — đọc elements (0-indexed)
    notifications, _ := rdb.LRange(ctx, listKey, 0, -1).Result()
    fmt.Println("=== Notifications ===")
    for i, n := range notifications {
        fmt.Printf("  %d: %s\n", i, n)
    }

    // LLEN — đếm
    count, _ := rdb.LLen(ctx, listKey).Result()
    fmt.Printf("Total: %d\n", count)

    // RPOP — lấy và xóa từ cuối (oldest)
    oldest, _ := rdb.RPop(ctx, listKey).Result()
    fmt.Printf("Oldest: %s\n", oldest)

    // LTRIM — giữ chỉ N phần tử mới nhất
    rdb.LTrim(ctx, listKey, 0, 49) // giữ tối đa 50

    // ========================
    // SET Operations
    // ========================
    setKey := "online:users"

    // SADD — thêm members
    rdb.SAdd(ctx, setKey, "user:1", "user:2", "user:3", "user:4")

    // SCARD — đếm
    onlineCount, _ := rdb.SCard(ctx, setKey).Result()
    fmt.Printf("\nOnline users: %d\n", onlineCount)

    // SISMEMBER — kiểm tra
    isOnline, _ := rdb.SIsMember(ctx, setKey, "user:2").Result()
    fmt.Printf("User 2 online: %v\n", isOnline)

    // SMEMBERS — lấy tất cả
    members, _ := rdb.SMembers(ctx, setKey).Result()
    fmt.Printf("All online: %v\n", members)

    // SREM — xóa (user offline)
    rdb.SRem(ctx, setKey, "user:3")

    // Set operations
    rdb.SAdd(ctx, "group:A", "user:1", "user:2", "user:3")
    rdb.SAdd(ctx, "group:B", "user:2", "user:3", "user:4")

    // SINTER — giao
    common, _ := rdb.SInter(ctx, "group:A", "group:B").Result()
    fmt.Printf("Common: %v\n", common)

    // Cleanup
    rdb.Del(ctx, listKey, setKey, "group:A", "group:B")
}
```

## 5\. SCAN — Duyệt keys an toàn

`KEYS *` block Redis server. Trong production, luôn dùng `SCAN`:

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
    defer rdb.Close()

    // Tạo test data
    for i := 0; i < 100; i++ {
        rdb.Set(ctx, fmt.Sprintf("cache:product:%d", i), "data", 0)
    }
    for i := 0; i < 50; i++ {
        rdb.Set(ctx, fmt.Sprintf("cache:user:%d", i), "data", 0)
    }

    // === SCAN — duyệt tất cả keys theo pattern ===
    var cursor uint64
    var allKeys []string

    for {
        keys, nextCursor, err := rdb.Scan(ctx, cursor, "cache:product:*", 20).Result()
        if err != nil {
            panic(err)
        }
        allKeys = append(allKeys, keys...)
        cursor = nextCursor

        if cursor == 0 {
            break // Đã scan hết
        }
    }
    fmt.Printf("Found %d product cache keys\n", len(allKeys))

    // === Cách ngắn gọn hơn: Iterator ===
    iter := rdb.Scan(ctx, 0, "cache:user:*", 20).Iterator()
    count := 0
    for iter.Next(ctx) {
        count++
        // iter.Val() là key name
    }
    if err := iter.Err(); err != nil {
        panic(err)
    }
    fmt.Printf("Found %d user cache keys\n", count)

    // === SCAN + DEL: Xóa keys theo pattern ===
    deleteByPattern(ctx, rdb, "cache:product:*")
    deleteByPattern(ctx, rdb, "cache:user:*")
    fmt.Println("Cleanup done")
}

// deleteByPattern xóa tất cả keys matching pattern
func deleteByPattern(ctx context.Context, rdb *redis.Client, pattern string) {
    iter := rdb.Scan(ctx, 0, pattern, 100).Iterator()
    var batch []string

    for iter.Next(ctx) {
        batch = append(batch, iter.Val())

        // Xóa theo batch 100 keys
        if len(batch) >= 100 {
            rdb.Del(ctx, batch...)
            batch = batch[:0]
        }
    }

    // Xóa batch còn lại
    if len(batch) > 0 {
        rdb.Del(ctx, batch...)
    }
}
```

## 6\. Thực hành: User Session CRUD

```
package main

import (
    "context"
    "encoding/json"
    "errors"
    "fmt"
    "log"
    "time"

    "github.com/google/uuid"
    "github.com/redis/go-redis/v9"
)

// Session chứa thông tin phiên đăng nhập
type Session struct {
    ID        string    `json:"id"`
    UserID    string    `json:"user_id"`
    Email     string    `json:"email"`
    Role      string    `json:"role"`
    IPAddress string    `json:"ip_address"`
    UserAgent string    `json:"user_agent"`
    CreatedAt time.Time `json:"created_at"`
}

// SessionStore quản lý sessions trên Redis
type SessionStore struct {
    rdb        *redis.Client
    defaultTTL time.Duration
}

func NewSessionStore(rdb *redis.Client, ttl time.Duration) *SessionStore {
    return &SessionStore{rdb: rdb, defaultTTL: ttl}
}

// Create tạo session mới, trả về session ID
func (s *SessionStore) Create(ctx context.Context, userID, email, role, ip, ua string) (string, error) {
    session := Session{
        ID:        uuid.New().String(),
        UserID:    userID,
        Email:     email,
        Role:      role,
        IPAddress: ip,
        UserAgent: ua,
        CreatedAt: time.Now(),
    }

    data, err := json.Marshal(session)
    if err != nil {
        return "", fmt.Errorf("marshal session: %w", err)
    }

    // Lưu session
    key := "session:" + session.ID
    if err := s.rdb.Set(ctx, key, data, s.defaultTTL).Err(); err != nil {
        return "", fmt.Errorf("set session: %w", err)
    }

    // Thêm vào danh sách sessions của user (để quản lý multi-device)
    userSessionsKey := "user_sessions:" + userID
    s.rdb.SAdd(ctx, userSessionsKey, session.ID)
    s.rdb.Expire(ctx, userSessionsKey, 7*24*time.Hour) // 7 ngày

    return session.ID, nil
}

// Get đọc session theo ID
func (s *SessionStore) Get(ctx context.Context, sessionID string) (*Session, error) {
    data, err := s.rdb.Get(ctx, "session:"+sessionID).Bytes()
    if errors.Is(err, redis.Nil) {
        return nil, nil // Session không tồn tại hoặc đã hết hạn
    }
    if err != nil {
        return nil, fmt.Errorf("get session: %w", err)
    }

    var session Session
    if err := json.Unmarshal(data, &session); err != nil {
        return nil, fmt.Errorf("unmarshal session: %w", err)
    }
    return &session, nil
}

// Refresh gia hạn session TTL
func (s *SessionStore) Refresh(ctx context.Context, sessionID string) error {
    key := "session:" + sessionID
    exists, err := s.rdb.Expire(ctx, key, s.defaultTTL).Result()
    if err != nil {
        return fmt.Errorf("refresh session: %w", err)
    }
    if !exists {
        return fmt.Errorf("session not found: %s", sessionID)
    }
    return nil
}

// Delete xóa một session (logout)
func (s *SessionStore) Delete(ctx context.Context, sessionID string) error {
    // Đọc session để lấy userID
    session, err := s.Get(ctx, sessionID)
    if err != nil {
        return err
    }
    if session == nil {
        return nil // Đã hết hạn
    }

    // Xóa session
    s.rdb.Del(ctx, "session:"+sessionID)

    // Xóa khỏi danh sách sessions của user
    s.rdb.SRem(ctx, "user_sessions:"+session.UserID, sessionID)

    return nil
}

// DeleteAllForUser xóa tất cả sessions của user (logout everywhere)
func (s *SessionStore) DeleteAllForUser(ctx context.Context, userID string) error {
    userSessionsKey := "user_sessions:" + userID

    // Lấy tất cả session IDs
    sessionIDs, err := s.rdb.SMembers(ctx, userSessionsKey).Result()
    if err != nil {
        return fmt.Errorf("get user sessions: %w", err)
    }

    // Xóa từng session
    for _, sid := range sessionIDs {
        s.rdb.Del(ctx, "session:"+sid)
    }

    // Xóa danh sách
    s.rdb.Del(ctx, userSessionsKey)

    return nil
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    store := NewSessionStore(rdb, 24*time.Hour)

    // 1. Create session
    sessionID, err := store.Create(ctx, "user-001", "a@test.com", "student", "127.0.0.1", "Chrome/120")
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Created session: %s\n", sessionID)

    // 2. Get session
    session, err := store.Get(ctx, sessionID)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Session: %+v\n", session)

    // 3. Refresh session
    err = store.Refresh(ctx, sessionID)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println("Session refreshed")

    // 4. Delete session (logout)
    err = store.Delete(ctx, sessionID)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println("Session deleted (logout)")

    // 5. Verify deleted
    session, _ = store.Get(ctx, sessionID)
    fmt.Printf("After delete: %v\n", session) // nil
}
```

## Tóm tắt

| Operation | Method | Ví dụ |
| --- | --- | --- |
| Set string | `rdb.Set(ctx, key, val, ttl)` | `rdb.Set(ctx, "k", "v", time.Minute)` |
| Get string | `rdb.Get(ctx, key).Result()` | Trả về (string, error) |
| Get int | `rdb.Get(ctx, key).Int()` | Trả về (int, error) |
| Delete | `rdb.Del(ctx, keys...)` | Xóa nhiều keys |
| Set JSON | Marshal → Set | Dùng json.Marshal |
| Get JSON | Get → Unmarshal | Dùng json.Unmarshal |
| Hash set | `rdb.HSet(ctx, key, fields)` | Map hoặc struct |
| Hash get | `rdb.HGetAll(ctx, key).Scan(&s)` | Scan vào struct |
| SCAN | `rdb.Scan().Iterator()` | Duyệt keys an toàn |

> **Bài tiếp theo:** Chúng ta sẽ học Pipeline và Transaction — cách gửi nhiều commands cùng lúc để tăng performance gấp nhiều lần.
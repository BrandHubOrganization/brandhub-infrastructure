**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/f610d0be-0c7a-4fcd-9bbc-74a029c77046](https://code4func.com/learn/redis-and-caching-strategies/f610d0be-0c7a-4fcd-9bbc-74a029c77046)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Session Management với Redis
├── Mục tiêu bài học
├── 1\. Tại sao Redis cho Sessions?
│   ├── So sánh các phương pháp lưu session
│   └── Session vs JWT
├── 2\. Session Store Implementation
├── 3\. Gin Session Middleware
│   └── Test session flow
├── Login
├── Access protected route (dùng cookie)
├── Logout
└── Thử access sau logout → 401
    ├── 4\. Session Security Best Practices
    └── Tóm tắt
```

---

## Session Management với Redis

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Hiểu tại sao Redis là lựa chọn tốt nhất cho session storage
-   Implement session store hoàn chỉnh trong Go
-   Tạo Gin middleware cho session handling
-   Xử lý session expiry và refresh
-   Xây dựng session-based authentication hoàn chỉnh

## 1\. Tại sao Redis cho Sessions?

### So sánh các phương pháp lưu session

| Phương pháp | Ưu điểm | Nhược điểm |
| --- | --- | --- |
| In-memory (biến Go) | Nhanh nhất | Mất khi restart, không scale |
| File system | Đơn giản | Chậm, khó scale |
| Database (PostgreSQL) | Persistent | Chậm, tạo load cho DB |
| **Redis** | **Nhanh, scale, TTL tự động** | **Cần thêm infrastructure** |
| Cookie-based (JWT) | Stateless | Không revoke được, size giới hạn |

**Redis là lựa chọn tốt nhất vì:**

1.  **Tốc độ**: Session access mỗi request — cần microseconds, không phải milliseconds
2.  **TTL tự động**: `EXPIRE` xóa session hết hạn tự động
3.  **Scale horizontal**: Nhiều app servers cùng đọc/ghi Redis
4.  **Atomic operations**: SETNX cho lock, INCR cho counter
5.  **Persistence tùy chọn**: AOF/RDB nếu cần

### Session vs JWT

```
Session (Redis):                    JWT (Token):
┌──────────┐                       ┌──────────┐
│ Client   │ cookie: session_id    │ Client   │ header: Bearer <token>
│          │──────────────────►    │          │──────────────────►
│          │                       │          │
│  Server  │ Redis.Get(sid)        │  Server  │ Verify(token)
│  Biết    │ → user data           │  Không   │ → claims
│  session │                       │  lưu gì  │
│          │ Revoke: Del(sid) ✓    │          │ Revoke: ✗ (phải blacklist)
└──────────┘                       └──────────┘
```

## 2\. Session Store Implementation

```
package main

import (
    "context"
    "crypto/rand"
    "encoding/hex"
    "encoding/json"
    "errors"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

// Session chứa thông tin phiên làm việc
type Session struct {
    ID        string                 `json:"id"`
    UserID    string                 `json:"user_id"`
    Email     string                 `json:"email"`
    Role      string                 `json:"role"`
    Data      map[string]interface{} `json:"data"`
    IPAddress string                 `json:"ip_address"`
    UserAgent string                 `json:"user_agent"`
    CreatedAt time.Time              `json:"created_at"`
    ExpiresAt time.Time              `json:"expires_at"`
}

// SessionStore quản lý sessions trên Redis
type SessionStore struct {
    rdb        *redis.Client
    prefix     string
    defaultTTL time.Duration
}

// NewSessionStore tạo session store mới
func NewSessionStore(rdb *redis.Client, ttl time.Duration) *SessionStore {
    return &SessionStore{
        rdb:        rdb,
        prefix:     "session",
        defaultTTL: ttl,
    }
}

// generateSessionID tạo session ID an toàn
func generateSessionID() (string, error) {
    b := make([]byte, 32) // 256 bits
    if _, err := rand.Read(b); err != nil {
        return "", fmt.Errorf("generate session ID: %w", err)
    }
    return hex.EncodeToString(b), nil
}

func (ss *SessionStore) sessionKey(id string) string {
    return ss.prefix + ":" + id
}

func (ss *SessionStore) userSessionsKey(userID string) string {
    return "user_sessions:" + userID
}

// Create tạo session mới
func (ss *SessionStore) Create(ctx context.Context, userID, email, role, ip, ua string) (*Session, error) {
    sid, err := generateSessionID()
    if err != nil {
        return nil, err
    }

    now := time.Now()
    session := &Session{
        ID:        sid,
        UserID:    userID,
        Email:     email,
        Role:      role,
        Data:      make(map[string]interface{}),
        IPAddress: ip,
        UserAgent: ua,
        CreatedAt: now,
        ExpiresAt: now.Add(ss.defaultTTL),
    }

    data, err := json.Marshal(session)
    if err != nil {
        return nil, fmt.Errorf("marshal session: %w", err)
    }

    // Pipeline: lưu session + track user sessions
    pipe := ss.rdb.Pipeline()
    pipe.Set(ctx, ss.sessionKey(sid), data, ss.defaultTTL)
    pipe.SAdd(ctx, ss.userSessionsKey(userID), sid)
    pipe.Expire(ctx, ss.userSessionsKey(userID), 30*24*time.Hour)
    _, err = pipe.Exec(ctx)
    if err != nil {
        return nil, fmt.Errorf("save session: %w", err)
    }

    return session, nil
}

// Get đọc session theo ID
func (ss *SessionStore) Get(ctx context.Context, sessionID string) (*Session, error) {
    data, err := ss.rdb.Get(ctx, ss.sessionKey(sessionID)).Bytes()
    if errors.Is(err, redis.Nil) {
        return nil, nil // Session hết hạn hoặc không tồn tại
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

// Refresh gia hạn session
func (ss *SessionStore) Refresh(ctx context.Context, sessionID string) error {
    key := ss.sessionKey(sessionID)

    // Đọc session hiện tại
    data, err := ss.rdb.Get(ctx, key).Bytes()
    if errors.Is(err, redis.Nil) {
        return fmt.Errorf("session expired")
    }
    if err != nil {
        return err
    }

    // Update ExpiresAt
    var session Session
    json.Unmarshal(data, &session)
    session.ExpiresAt = time.Now().Add(ss.defaultTTL)

    newData, _ := json.Marshal(session)
    return ss.rdb.Set(ctx, key, newData, ss.defaultTTL).Err()
}

// SetData cập nhật custom data trong session
func (ss *SessionStore) SetData(ctx context.Context, sessionID, field string, value interface{}) error {
    session, err := ss.Get(ctx, sessionID)
    if err != nil {
        return err
    }
    if session == nil {
        return fmt.Errorf("session not found")
    }

    session.Data[field] = value

    data, _ := json.Marshal(session)
    ttl, _ := ss.rdb.TTL(ctx, ss.sessionKey(sessionID)).Result()
    if ttl < 0 {
        ttl = ss.defaultTTL
    }

    return ss.rdb.Set(ctx, ss.sessionKey(sessionID), data, ttl).Err()
}

// Destroy xóa session (logout)
func (ss *SessionStore) Destroy(ctx context.Context, sessionID string) error {
    // Đọc session để lấy userID
    session, err := ss.Get(ctx, sessionID)
    if err != nil {
        return err
    }
    if session == nil {
        return nil
    }

    pipe := ss.rdb.Pipeline()
    pipe.Del(ctx, ss.sessionKey(sessionID))
    pipe.SRem(ctx, ss.userSessionsKey(session.UserID), sessionID)
    _, err = pipe.Exec(ctx)
    return err
}

// DestroyAllForUser xóa tất cả sessions (logout everywhere)
func (ss *SessionStore) DestroyAllForUser(ctx context.Context, userID string) (int, error) {
    userKey := ss.userSessionsKey(userID)
    sessionIDs, err := ss.rdb.SMembers(ctx, userKey).Result()
    if err != nil {
        return 0, err
    }

    if len(sessionIDs) == 0 {
        return 0, nil
    }

    pipe := ss.rdb.Pipeline()
    for _, sid := range sessionIDs {
        pipe.Del(ctx, ss.sessionKey(sid))
    }
    pipe.Del(ctx, userKey)
    _, err = pipe.Exec(ctx)

    return len(sessionIDs), err
}

// GetActiveSessions liệt kê sessions đang active của user
func (ss *SessionStore) GetActiveSessions(ctx context.Context, userID string) ([]*Session, error) {
    sessionIDs, err := ss.rdb.SMembers(ctx, ss.userSessionsKey(userID)).Result()
    if err != nil {
        return nil, err
    }

    var sessions []*Session
    for _, sid := range sessionIDs {
        session, err := ss.Get(ctx, sid)
        if err != nil {
            continue
        }
        if session != nil {
            sessions = append(sessions, session)
        } else {
            // Session hết hạn → cleanup
            ss.rdb.SRem(ctx, ss.userSessionsKey(userID), sid)
        }
    }

    return sessions, nil
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    store := NewSessionStore(rdb, 24*time.Hour)

    // Login → Create session
    session, _ := store.Create(ctx, "user-1", "a@test.com", "student", "127.0.0.1", "Chrome")
    fmt.Printf("Created session: %s\n", session.ID[:16]+"...")

    // Read session
    s, _ := store.Get(ctx, session.ID)
    fmt.Printf("User: %s, Role: %s\n", s.Email, s.Role)

    // Update session data
    store.SetData(ctx, session.ID, "last_page", "/courses/go-basics")
    store.SetData(ctx, session.ID, "cart_items", 3)

    // List active sessions
    sessions, _ := store.GetActiveSessions(ctx, "user-1")
    fmt.Printf("Active sessions: %d\n", len(sessions))

    // Logout
    store.Destroy(ctx, session.ID)
    fmt.Println("Logged out")
}
```

## 3\. Gin Session Middleware

```
package main

import (
    "context"
    "crypto/rand"
    "encoding/hex"
    "encoding/json"
    "errors"
    "fmt"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/redis/go-redis/v9"
)

const (
    sessionCookieName = "sid"
    sessionCtxKey     = "session"
)

// Session dùng trong middleware
type Session struct {
    ID        string                 `json:"id"`
    UserID    string                 `json:"user_id"`
    Email     string                 `json:"email"`
    Role      string                 `json:"role"`
    Data      map[string]interface{} `json:"data"`
    CreatedAt time.Time              `json:"created_at"`
}

type SessionMiddleware struct {
    rdb    *redis.Client
    ttl    time.Duration
    prefix string
}

func NewSessionMiddleware(rdb *redis.Client, ttl time.Duration) *SessionMiddleware {
    return &SessionMiddleware{rdb: rdb, ttl: ttl, prefix: "session"}
}

func (sm *SessionMiddleware) key(id string) string {
    return sm.prefix + ":" + id
}

// Middleware xác thực session từ cookie
func (sm *SessionMiddleware) Middleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        // Đọc session ID từ cookie
        sid, err := c.Cookie(sessionCookieName)
        if err != nil || sid == "" {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "No session"})
            c.Abort()
            return
        }

        // Đọc session từ Redis
        data, err := sm.rdb.Get(c.Request.Context(), sm.key(sid)).Bytes()
        if errors.Is(err, redis.Nil) {
            // Session hết hạn
            c.SetCookie(sessionCookieName, "", -1, "/", "", false, true)
            c.JSON(http.StatusUnauthorized, gin.H{"error": "Session expired"})
            c.Abort()
            return
        }
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Session error"})
            c.Abort()
            return
        }

        var session Session
        if err := json.Unmarshal(data, &session); err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid session"})
            c.Abort()
            return
        }

        // Đưa session vào context
        c.Set(sessionCtxKey, &session)

        // Refresh TTL (sliding expiration)
        sm.rdb.Expire(c.Request.Context(), sm.key(sid), sm.ttl)

        c.Next()
    }
}

// GetSession helper lấy session từ Gin context
func GetSession(c *gin.Context) *Session {
    val, exists := c.Get(sessionCtxKey)
    if !exists {
        return nil
    }
    return val.(*Session)
}

// CreateSession tạo session mới và set cookie
func (sm *SessionMiddleware) CreateSession(c *gin.Context, userID, email, role string) (*Session, error) {
    b := make([]byte, 32)
    rand.Read(b)
    sid := hex.EncodeToString(b)

    session := &Session{
        ID:        sid,
        UserID:    userID,
        Email:     email,
        Role:      role,
        Data:      make(map[string]interface{}),
        CreatedAt: time.Now(),
    }

    data, _ := json.Marshal(session)
    ctx := c.Request.Context()

    if err := sm.rdb.Set(ctx, sm.key(sid), data, sm.ttl).Err(); err != nil {
        return nil, fmt.Errorf("create session: %w", err)
    }

    // Set HttpOnly cookie
    c.SetCookie(
        sessionCookieName,
        sid,
        int(sm.ttl.Seconds()),
        "/",
        "",     // domain
        false,  // secure (true in production with HTTPS)
        true,   // httpOnly
    )

    return session, nil
}

// DestroySession xóa session và cookie
func (sm *SessionMiddleware) DestroySession(c *gin.Context) error {
    sid, err := c.Cookie(sessionCookieName)
    if err != nil {
        return nil
    }

    sm.rdb.Del(c.Request.Context(), sm.key(sid))
    c.SetCookie(sessionCookieName, "", -1, "/", "", false, true)
    return nil
}

// === Application ===

func main() {
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    if err := rdb.Ping(context.Background()).Err(); err != nil {
        panic(err)
    }

    sm := NewSessionMiddleware(rdb, 24*time.Hour)

    r := gin.Default()

    // Public routes
    r.POST("/login", func(c *gin.Context) {
        var req struct {
            Email    string `json:"email" binding:"required"`
            Password string `json:"password" binding:"required"`
        }
        if err := c.ShouldBindJSON(&req); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }

        // Giả lập authenticate (thực tế query DB)
        if req.Email != "admin@test.com" || req.Password != "password" {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
            return
        }

        session, err := sm.CreateSession(c, "user-1", req.Email, "admin")
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }

        c.JSON(http.StatusOK, gin.H{
            "message":    "Login successful",
            "session_id": session.ID[:16] + "...",
        })
    })

    // Protected routes
    protected := r.Group("/api")
    protected.Use(sm.Middleware())
    {
        protected.GET("/profile", func(c *gin.Context) {
            session := GetSession(c)
            c.JSON(http.StatusOK, gin.H{
                "user_id": session.UserID,
                "email":   session.Email,
                "role":    session.Role,
            })
        })

        protected.POST("/logout", func(c *gin.Context) {
            sm.DestroySession(c)
            c.JSON(http.StatusOK, gin.H{"message": "Logged out"})
        })
    }

    r.Run(":8080")
}
```

### Test session flow

```
# Login
curl -c cookies.txt -X POST http://localhost:8080/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"password"}'

# Access protected route (dùng cookie)
curl -b cookies.txt http://localhost:8080/api/profile

# Logout
curl -b cookies.txt -X POST http://localhost:8080/api/logout

# Thử access sau logout → 401
curl -b cookies.txt http://localhost:8080/api/profile
```

## 4\. Session Security Best Practices

| Practice | Mô tả |
| --- | --- |
| HttpOnly cookie | JavaScript không đọc được session cookie |
| Secure flag | Cookie chỉ gửi qua HTTPS (production) |
| SameSite=Strict | Chống CSRF attacks |
| Regenerate ID | Tạo session ID mới sau login thành công |
| TTL sliding | Gia hạn TTL mỗi request |
| IP binding | Validate IP khi dùng session |
| Max sessions | Giới hạn số sessions per user |

## Tóm tắt

| Component | Mô tả |
| --- | --- |
| Session Store | Redis SET/GET/DEL với JSON serialization |
| Session ID | 256-bit random hex string |
| TTL | Sliding expiration — refresh mỗi request |
| Cookie | HttpOnly, Secure (production), SameSite=Strict |
| Multi-device | SET lưu danh sách session IDs per user |
| Logout all | Xóa tất cả sessions của user |

> **Bài tiếp theo:** Chúng ta sẽ xây dựng Rate Limiter — bảo vệ API khỏi abuse bằng Token Bucket và Sliding Window algorithms.
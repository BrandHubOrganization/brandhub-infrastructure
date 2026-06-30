**Title:** CODE4FUNC - Micro Learning Platform

**Source:** [https://code4func.com/learn/redis-and-caching-strategies/1f61a2cf-87c6-46d5-b185-fad904327705](https://code4func.com/learn/redis-and-caching-strategies/1f61a2cf-87c6-46d5-b185-fad904327705)

---

# Page Structure Map
```text
CODE4FUNC - Micro Learning Platform
├── Pub/Sub: Real-time Messaging
├── Mục tiêu bài học
├── 1\. Pub/Sub Model
│   └── Pub/Sub trong Redis CLI
├── Terminal 1: Subscribe
├── Terminal 2: Publish
├── Terminal 1 nhận:
│   └── Pattern Subscribe
├── Subscribe tất cả channels bắt đầu bằng "user:"
├── Publish tới channel cụ thể
└── Subscriber nhận cả 2 messages vì match pattern "user:*"
    ├── 2\. Go Implementation
    │   ├── Publisher và Subscriber cơ bản
    │   └── Pattern Subscribe với go-redis
    ├── 3\. Use Case: Real-time Notifications
    ├── 4\. Limitations của Pub/Sub
    └── Tóm tắt
```

---

## Pub/Sub: Real-time Messaging

## Mục tiêu bài học

Sau bài này, bạn sẽ:

-   Hiểu mô hình Pub/Sub trong Redis
-   Sử dụng SUBSCRIBE, PUBLISH, PSUBSCRIBE commands
-   Implement Pub/Sub trong Go với go-redis
-   Biết các use case: notifications, chat, event broadcasting
-   Hiểu limitations của Redis Pub/Sub

## 1\. Pub/Sub Model

**Pub/Sub** (Publish/Subscribe) là mô hình messaging nơi:

-   **Publisher** gửi messages tới một **channel** (không cần biết ai đang listen)
-   **Subscriber** đăng ký nhận messages từ channel (không cần biết ai publish)

```
Publisher 1 ──►┌──────────────┐──► Subscriber A
               │   Channel    │
Publisher 2 ──►│ "notifications"│──► Subscriber B
               │              │
               └──────────────┘──► Subscriber C

Publisher không biết về Subscribers.
Subscribers không biết về Publishers.
Channel là "điểm gặp" duy nhất.
```

### Pub/Sub trong Redis CLI

```
# Terminal 1: Subscribe
127.0.0.1:6379> SUBSCRIBE notifications
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "notifications"
3) (integer) 1

# Terminal 2: Publish
127.0.0.1:6379> PUBLISH notifications "Bạn có đơn hàng mới!"
(integer) 1   # Số subscribers nhận được message

# Terminal 1 nhận:
1) "message"
2) "notifications"
3) "Bạn có đơn hàng mới!"
```

### Pattern Subscribe

```
# Subscribe tất cả channels bắt đầu bằng "user:"
127.0.0.1:6379> PSUBSCRIBE user:*

# Publish tới channel cụ thể
127.0.0.1:6379> PUBLISH user:1001 "Welcome!"
127.0.0.1:6379> PUBLISH user:1002 "New course available"

# Subscriber nhận cả 2 messages vì match pattern "user:*"
```

## 2\. Go Implementation

### Publisher và Subscriber cơ bản

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

    // === Subscriber (chạy trong goroutine) ===
    go func() {
        sub := rdb.Subscribe(ctx, "events", "notifications")
        defer sub.Close()

        // Chờ xác nhận subscribe thành công
        _, err := sub.Receive(ctx)
        if err != nil {
            log.Fatalf("Subscribe failed: %v", err)
        }
        fmt.Println("[Subscriber] Subscribed to channels")

        // Nhận messages
        ch := sub.Channel()
        for msg := range ch {
            fmt.Printf("[Subscriber] Channel=%s, Message=%s\n",
                msg.Channel, msg.Payload)
        }
    }()

    // Chờ subscriber sẵn sàng
    time.Sleep(200 * time.Millisecond)

    // === Publisher ===
    messages := []struct {
        channel string
        payload string
    }{
        {"events", "user_login: user-001"},
        {"notifications", "Chào mừng bạn quay lại!"},
        {"events", "course_enrolled: Go Basics"},
        {"notifications", "Bạn đã đạt 100 XP!"},
    }

    for _, msg := range messages {
        receivers, err := rdb.Publish(ctx, msg.channel, msg.payload).Result()
        if err != nil {
            log.Printf("Publish error: %v", err)
            continue
        }
        fmt.Printf("[Publisher] Sent to %s (%d receivers)\n", msg.channel, receivers)
        time.Sleep(100 * time.Millisecond)
    }

    time.Sleep(500 * time.Millisecond) // Chờ subscriber xử lý
}
```

### Pattern Subscribe với go-redis

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

// Event là sự kiện được publish
type Event struct {
    Type      string      `json:"type"`
    UserID    string      `json:"user_id"`
    Data      interface{} `json:"data"`
    Timestamp time.Time   `json:"timestamp"`
}

// EventBus quản lý Pub/Sub
type EventBus struct {
    rdb *redis.Client
}

func NewEventBus(rdb *redis.Client) *EventBus {
    return &EventBus{rdb: rdb}
}

// Publish gửi event
func (eb *EventBus) Publish(ctx context.Context, channel string, event Event) error {
    event.Timestamp = time.Now()
    data, err := json.Marshal(event)
    if err != nil {
        return err
    }
    return eb.rdb.Publish(ctx, channel, data).Err()
}

// Subscribe lắng nghe events từ channels
func (eb *EventBus) Subscribe(ctx context.Context, handler func(channel string, event Event), channels ...string) {
    sub := eb.rdb.Subscribe(ctx, channels...)
    defer sub.Close()

    ch := sub.Channel()
    for msg := range ch {
        var event Event
        if err := json.Unmarshal([]byte(msg.Payload), &event); err != nil {
            log.Printf("Invalid event on %s: %v", msg.Channel, err)
            continue
        }
        handler(msg.Channel, event)
    }
}

// PSubscribe lắng nghe events theo pattern
func (eb *EventBus) PSubscribe(ctx context.Context, handler func(channel, pattern string, event Event), patterns ...string) {
    sub := eb.rdb.PSubscribe(ctx, patterns...)
    defer sub.Close()

    ch := sub.Channel()
    for msg := range ch {
        var event Event
        if err := json.Unmarshal([]byte(msg.Payload), &event); err != nil {
            log.Printf("Invalid event: %v", err)
            continue
        }
        handler(msg.Channel, msg.Pattern, event)
    }
}

func main() {
    ctx := context.Background()
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    defer rdb.Close()

    bus := NewEventBus(rdb)

    // Subscriber 1: lắng nghe tất cả user events
    go bus.PSubscribe(ctx, func(channel, pattern string, event Event) {
        fmt.Printf("[User Handler] channel=%s, type=%s, user=%s\n",
            channel, event.Type, event.UserID)
    }, "user:*")

    // Subscriber 2: lắng nghe notifications
    go bus.Subscribe(ctx, func(channel string, event Event) {
        fmt.Printf("[Notification] type=%s, data=%v\n", event.Type, event.Data)
    }, "system:notifications")

    time.Sleep(200 * time.Millisecond) // Chờ subscribers sẵn sàng

    // Publish events
    bus.Publish(ctx, "user:login", Event{
        Type:   "login",
        UserID: "user-001",
        Data:   map[string]string{"ip": "127.0.0.1"},
    })

    bus.Publish(ctx, "user:xp_earned", Event{
        Type:   "xp_earned",
        UserID: "user-001",
        Data:   map[string]int{"amount": 50},
    })

    bus.Publish(ctx, "system:notifications", Event{
        Type: "announcement",
        Data: "Hệ thống sẽ bảo trì lúc 2:00 AM",
    })

    time.Sleep(500 * time.Millisecond)
}
```

## 3\. Use Case: Real-time Notifications

```
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/redis/go-redis/v9"
)

type Notification struct {
    ID        string `json:"id"`
    UserID    string `json:"user_id"`
    Title     string `json:"title"`
    Body      string `json:"body"`
    Type      string `json:"type"`
    Timestamp int64  `json:"timestamp"`
}

type NotificationService struct {
    rdb *redis.Client
}

func NewNotificationService(rdb *redis.Client) *NotificationService {
    return &NotificationService{rdb: rdb}
}

// Send gửi notification tới user cụ thể
func (ns *NotificationService) Send(ctx context.Context, notif Notification) error {
    notif.Timestamp = time.Now().Unix()

    // Lưu vào list (persistent storage)
    data, _ := json.Marshal(notif)
    pipe := ns.rdb.Pipeline()
    pipe.LPush(ctx, "notifications:"+notif.UserID, data)
    pipe.LTrim(ctx, "notifications:"+notif.UserID, 0, 99) // Giữ 100 gần nhất
    pipe.Expire(ctx, "notifications:"+notif.UserID, 30*24*time.Hour)

    // Publish cho real-time delivery
    pipe.Publish(ctx, "notify:"+notif.UserID, data)
    _, err := pipe.Exec(ctx)
    return err
}

// GetRecent lấy notifications gần đây
func (ns *NotificationService) GetRecent(ctx context.Context, userID string, limit int64) ([]Notification, error) {
    results, err := ns.rdb.LRange(ctx, "notifications:"+userID, 0, limit-1).Result()
    if err != nil {
        return nil, err
    }

    notifications := make([]Notification, 0, len(results))
    for _, r := range results {
        var n Notification
        if json.Unmarshal([]byte(r), &n) == nil {
            notifications = append(notifications, n)
        }
    }
    return notifications, nil
}

// SSE handler: Server-Sent Events cho real-time notifications
func sseHandler(rdb *redis.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        userID := c.Param("user_id")

        c.Header("Content-Type", "text/event-stream")
        c.Header("Cache-Control", "no-cache")
        c.Header("Connection", "keep-alive")

        ctx := c.Request.Context()
        sub := rdb.Subscribe(ctx, "notify:"+userID)
        defer sub.Close()

        ch := sub.Channel()
        c.Stream(func(w *gin.ResponseWriter) bool {
            select {
            case msg, ok := <-ch:
                if !ok {
                    return false
                }
                c.SSEvent("notification", msg.Payload)
                return true
            case <-ctx.Done():
                return false
            }
        })
    }
}

func main() {
    rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
    if err := rdb.Ping(context.Background()).Err(); err != nil {
        panic(err)
    }

    ns := NewNotificationService(rdb)

    r := gin.Default()

    // SSE endpoint cho real-time
    r.GET("/events/:user_id", sseHandler(rdb))

    // Send notification
    r.POST("/notifications", func(c *gin.Context) {
        var notif Notification
        if err := c.ShouldBindJSON(&notif); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }
        if err := ns.Send(c.Request.Context(), notif); err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }
        c.JSON(http.StatusOK, gin.H{"message": "Notification sent"})
    })

    // Get recent notifications
    r.GET("/notifications/:user_id", func(c *gin.Context) {
        notifications, err := ns.GetRecent(c.Request.Context(), c.Param("user_id"), 20)
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }
        c.JSON(http.StatusOK, notifications)
    })

    fmt.Println("Server on :8080")
    r.Run(":8080")
}
```

## 4\. Limitations của Pub/Sub

| Limitation | Mô tả | Giải pháp |
| --- | --- | --- |
| No persistence | Messages không được lưu — nếu subscriber offline, message bị mất | Dùng Redis Streams |
| At-most-once | Không đảm bảo delivery — subscriber có thể miss messages | Dùng Redis Streams với ACK |
| No message queue | Không có queue — messages gửi đi ngay, không chờ | Dùng List hoặc Streams |
| Memory | Subscriber chậm → Redis buffer messages → dùng memory | Set `client-output-buffer-limit` |
| No consumer groups | Không chia tải giữa nhiều consumers | Dùng Redis Streams |

> **Khi nào dùng Pub/Sub:**
> 
> -   Real-time notifications (không critical nếu miss)
> -   Cache invalidation events
> -   Chat messages (kết hợp với persistent storage)
> -   Live updates (dashboard, monitoring)

> **Khi nào KHÔNG dùng Pub/Sub:**
> 
> -   Job processing (cần reliable delivery) → Redis Streams
> -   Event sourcing (cần persistence) → Redis Streams
> -   Task queue (cần acknowledgment) → Redis Streams hoặc List

## Tóm tắt

| Khái niệm | Mô tả |
| --- | --- |
| PUBLISH | Gửi message tới channel |
| SUBSCRIBE | Lắng nghe messages từ channels |
| PSUBSCRIBE | Lắng nghe theo pattern (wildcard) |
| Fire-and-forget | Messages không được lưu |
| Use cases | Notifications, cache invalidation, live updates |
| Limitations | No persistence, at-most-once delivery |

> **Bài tiếp theo:** Distributed Lock — cách sử dụng Redis để lock resources trong hệ thống phân tán, tránh race conditions.
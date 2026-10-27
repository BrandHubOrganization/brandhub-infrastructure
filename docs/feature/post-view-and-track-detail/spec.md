# Đặc tả Nghiệp vụ: Dashboard Post View & Track Detail (DA-E52-07)

## 1. Mục tiêu (Objective)
Cung cấp tính năng toàn diện cho thành viên Workspace theo dõi hiệu quả bài đăng mạng xã hội:
- Xem tổng quan các bài viết đã xuất bản (Dashboard post view — FR 3.8.3).
- Xem chi tiết chỉ số tương tác thực tế: reactions, comments, shares, và link bài gốc trên nền tảng (Post track detail — FR 3.8.4).
- Xem danh sách bình luận thực tế (Comment detail list — FR 3.8.5).
- Xem lịch đăng bài theo múi giờ Workspace (Schedule platform post — FR 3.8.7).
- Xem trước layout bài đăng đa nền tảng (Preview post — FR 3.8.6).

---

## 2. User Story
- **Là một** Member (Manager, Creator, Client) trong Workspace,
- **Tôi muốn** xem chi tiết tương tác thực tế và bảng điều khiển tổng quan các bài đăng mạng xã hội,
- **Để** đo lường hiệu suất nội dung, lắng nghe phản hồi của người theo dõi và điều chỉnh kế hoạch truyền thông phù hợp.

---

## 3. Tiêu chí Chấp nhận (Acceptance Criteria)

### AC-1: Endpoint Chi tiết Tương tác (`Post Track Detail`)
- `GET /api/v1/workspaces/{workspaceId}/posts/{postId}`:
  - Trả về thông tin bài đăng kèm chỉ số tương tác:
    - `platformPostUrl`: URL xem trực tiếp bài đăng trên nền tảng (Facebook, Instagram, TikTok, Threads).
    - `reactionCount`: Tổng số lượt thích / thả cảm xúc.
    - `commentCount`: Tổng số lượt bình luận.
    - `shareCount`: Tổng số lượt chia sẻ.
    - `engagementUpdatedAt`: Thời điểm cập nhật số liệu gần nhất.
  - Phân quyền: Thành viên Workspace (`MANAGER`, `CREATOR`, `CLIENT`).

### AC-2: Xử lý Bài viết Không tồn tại hoặc Chưa xuất bản
- Khi gọi xem chi tiết bài đăng hoặc track detail:
  - Nếu `postId` không tồn tại trong Workspace ➔ Trả về `404 NOT_FOUND` với mã lỗi `POST_NOT_FOUND`.
  - Nếu bài viết ở trạng thái chưa xuất bản (ví dụ: `DRAFT`, `SUBMITTED`, `PENDING_REVIEW`) khi yêu cầu chỉ số tương tác ➔ Trả về `404 NOT_FOUND` kèm thông điệp `Post has not been published yet` hoặc mã `POST_NOT_FOUND`.

### AC-3: Bộ đệm chống Vượt giới hạn API Nền tảng (Rate-limiting Cache)
- Lấy số liệu tương tác từ nền tảng xã hội có thể bị giới hạn tần suất (Rate limit).
- Hệ thống áp dụng cơ chế bộ đệm (Caching):
  - Lưu trữ `reactionCount`, `commentCount`, `shareCount`, `engagementUpdatedAt` trong tài liệu `Post`.
  - Khi có yêu cầu lấy số liệu, nếu thời gian từ lần cập nhật gần nhất nhỏ hơn ngưỡng cấu hình (mặc định 10 phút) ➔ Trả về dữ liệu từ cache ngay lập tức.
  - Hỗ trợ tham số query `?refresh=true` để buộc đồng bộ số liệu mới nếu cần, đồng thời ghi nhận lại timestamp `engagementUpdatedAt`.

### AC-4: Bảng điều khiển Tổng quan Bài viết (`Dashboard Post List` — FR 3.8.3)
- `GET /api/v1/workspaces/{workspaceId}/posts/dashboard`:
  - Trả về:
    - `kpis`: `totalPosts`, `scheduledCount`, `successRate`, `failedCount`.
    - `platformBreakdown`: Thống kê số lượng bài và tỉ lệ theo từng nền tảng (`FACEBOOK`, `INSTAGRAM`, `TIKTOK`, `THREADS`).
    - `recentPosts`: Danh sách bài viết gần nhất với trạng thái (`PUBLISHED`, `SCHEDULED`, `FAILED`).
  - Hỗ trợ lọc theo `platform`, `status`, `dateRange` và phân trang (`page`, `limit`).

### AC-5: Danh sách Bình luận Chi tiết (`Comment Detail List` — FR 3.8.5)
- `GET /api/v1/workspaces/{workspaceId}/posts/{postId}/comments`:
  - Trả về danh sách bình luận gồm: `id`, `authorName`, `authorAvatar`, `content`, `commentedAt`.
  - Có cơ chế dự phòng dữ liệu lưu trữ / cache khi API nền tảng gặp sự cố hoặc rate-limit.

### AC-6: Xem Lịch Đăng Bài theo Múi giờ (`Schedule Platform Post` — FR 3.8.7)
- `GET /api/v1/workspaces/{workspaceId}/posts/schedule?month=YYYY-MM`:
  - Trả về danh sách bài đăng đã lên lịch trong tháng.
  - Định dạng thời gian `scheduledAt` chuẩn ISO-8601, chuyển đổi hiển thị chuẩn xác theo `Workspace.timezoneConfig`.

### AC-7: Xem Trước Bố cục Đa nền tảng (`Preview Post` — FR 3.8.6)
- Cung cấp dữ liệu preview tương ứng cho Facebook, Instagram, TikTok, Threads với giới hạn độ dài ký tự và tỷ lệ media.

---

## 4. API Contract

### 4.1. Track Detail & Engagement
```http
GET /api/v1/workspaces/{workspaceId}/posts/{postId}
Response 200:
{
  "success": true,
  "data": {
    "id": "6ad0dab507418d5266ff0f62",
    "workspaceId": "6a4bb422-3ef2-43d4-8019-93adb1dfa982",
    "caption": "Bí quyết dưỡng da...",
    "hashtags": ["#Skincare"],
    "media": [...],
    "platform": "FACEBOOK",
    "targetPlatforms": ["FACEBOOK"],
    "status": "PUBLISHED",
    "platformPostId": "1044303168777709_122097495034871234",
    "platformPostUrl": "https://www.facebook.com/1044303168777709",
    "reactionCount": 1420,
    "commentCount": 348,
    "shareCount": 112,
    "engagementUpdatedAt": "2026-10-24T02:00:00Z",
    "publishedAt": "2026-10-15T13:52:53Z"
  }
}
```

### 4.2. Dashboard Summary
```http
GET /api/v1/workspaces/{workspaceId}/posts/dashboard
Response 200:
{
  "success": true,
  "data": {
    "kpis": {
      "totalPosts": 48,
      "scheduledCount": 12,
      "successRate": 95.8,
      "failedCount": 2
    },
    "platformBreakdown": [
      { "platform": "FACEBOOK", "count": 24, "percentage": 50.0 },
      { "platform": "INSTAGRAM", "count": 14, "percentage": 29.2 }
    ],
    "recentPosts": [...]
  }
}
```

### 4.3. Comments Detail
```http
GET /api/v1/workspaces/{workspaceId}/posts/{postId}/comments
Response 200:
{
  "success": true,
  "data": [
    {
      "id": "c-1",
      "authorName": "Nguyen Van A",
      "content": "Sản phẩm dùng rất thích!",
      "commentedAt": "2026-10-15T14:00:00Z"
    }
  ]
}
```

---

## 5. Xử lý Lỗi (Error Handling)
- `POST_NOT_FOUND` (404): Bài viết không tồn tại hoặc chưa ở trạng thái `PUBLISHED`.
- `FORBIDDEN` (403): Người dùng không thuộc Workspace hoặc không có quyền truy cập.
- `PLATFORM_API_ERROR` (502): Lỗi khi kết nối tới nền tảng mạng xã hội; fallback trả về cache cũ nhất.

---

## 6. Lưu ý Kỹ thuật Quan trọng khi Tích hợp Meta Graph API (Facebook & Instagram)

### 6.1. Phân loại Tài khoản Hỗ trợ (Account Types)
- **Facebook:** BẮT BUỘC là **Facebook Fanpage** (sử dụng Page Access Token). Meta TUYỆT ĐỐI KHÔNG hỗ trợ đọc bài viết/tương tác từ tài khoản Facebook cá nhân (Personal Profile) qua Graph API kể từ sau các thay đổi chính sách bảo mật dữ liệu.
- **Instagram:** BẮT BUỘC là **Instagram Professional/Business/Creator Account** đã được liên kết với một Facebook Fanpage do hệ thống quản lý.

### 6.2. Danh mục Quyền Hạn Bắt buộc (Required Permissions)
- **Facebook Graph API:**
  - `pages_read_engagement`: Cho phép đọc lượt reaction, like, shares và comment trên Fanpage.
  - `pages_read_user_content`: Cho phép đọc nội dung chi tiết của bình luận từ người dùng.
  - `pages_manage_posts`: Hỗ trợ đăng bài và quản trị bài viết.
- **Instagram Graph API:**
  - `instagram_basic`: Cho phép lấy thông tin bài media (`like_count`, `comments_count`, `permalink`).
  - `instagram_manage_comments`: Cho phép đọc chi tiết nội dung các bình luận trên Instagram media.

### 6.3. Giới hạn Tần suất & Bộ đệm (Rate Limiting & Caching Policy)
- **Giới hạn gọi:** Meta áp dụng quota tính theo công thức `200 calls * số lượng users đang hoạt động / giờ` cho mỗi ứng dụng.
- **Chiến lược Caching:** BẮT BUỘC áp dụng cơ chế cache TTL 10 phút tại `PostServiceImpl.syncEngagementMetrics` thông qua trường `engagementUpdatedAt`.
- **Tránh Spam API:** Khi nhiều người dùng cùng mở xem chi tiết một bài viết trong vòng 10 phút, hệ thống lập tức trả về số liệu đã lưu trong MongoDB thay vì gọi lặp lại sang Meta Graph API.
- **Cơ chế Force Refresh:** Chỉ khi người dùng bấm nút "Làm mới số liệu" (truyền query param `?refresh=true`) thì mới thực hiện cuộc gọi API thực tế tới Meta để đồng bộ.

### 6.4. Môi trường Kiểm thử vs Môi trường Thực tế (Dev vs Production)
- **Môi trường Development (Sandbox):** Chỉ các tài khoản Facebook/Instagram đã được thêm vai trò **Developer / Tester / Admin** trong bảng điều khiển Meta App Dashboard mới có thể cấp quyền và lấy được dữ liệu thật.
- **Môi trường Production (Live):** Ứng dụng Meta phải trải qua quy trình **Meta App Review** và được cấp phép chính thức cho các quyền `pages_read_engagement` và `instagram_manage_comments`.

### 6.5. Xử lý Token Hết hạn & Chiến lược Dự phòng (Fallback Strategy)
- Page Access Token có thể bị mất hiệu lực khi người dùng đổi mật khẩu Facebook, xóa quyền của App hoặc sau thời gian sống tối đa (60 ngày với Long-lived Token).
- Khi API Meta trả về mã lỗi `OAuthException` (Code `190` - Token Expired hoặc Code `4` / `17` - Rate Limit), hệ thống không làm gián đoạn trải nghiệm người dùng (`Graceful Degradation`):
  1. Ghi log cảnh báo server (`log.warn`).
  2. Tự động trả về số liệu tương tác đã cache gần nhất được lưu trong MongoDB.
  3. Gửi thông báo nhắc nhở người quản trị Workspace kết nối lại Fanpage/Instagram khi token hết hạn.


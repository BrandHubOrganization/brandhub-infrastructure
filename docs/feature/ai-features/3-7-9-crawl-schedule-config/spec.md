# 3.7.9 Crawl Schedule Config

| | |
|---|---|
| FR Code | 3.7.9 |
| Feature | Crawl Schedule Config |
| Domain | AI Features (FR 3.7) |
| Role | SYSTEM_ADMIN |
| Version | 2.5 — 2026-09-27 — Chuyển đổi chuẩn SRS, bổ sung proxy pool, target channels, manual trigger "Run Now", log crawl history, config snapshot execution isolation (PO D12/D02). |
| Document status | Target Spec |
| Implementation status | In Progress |

## Function Trigger

Bắt đầu khi người dùng có vai trò `SYSTEM_ADMIN` điều hướng tới trang Quản trị Hệ thống tại đường dẫn `/admin/ai/crawl-config` để xem, cập nhật lịch trình cào xu hướng, quản trị danh sách nguồn kênh, cấu hình nhóm proxy, kiểm tra nhật ký các lần cào gần nhất, hoặc bấm nút kích hoạt thủ công "Run Now".

## Function Description

- **Actors / Roles:** `SYSTEM_ADMIN` (sở hữu Bearer JWT chứa claim `role=SYSTEM_ADMIN`). Toàn bộ các vai trò khác (`OWNER`, `MANAGER`, `CREATOR`, `CLIENT`) đều bị chặn truy cập cấp độ gateway/API, do crawler tác động trực tiếp tới tài nguyên máy chủ toàn hệ thống và tần suất gọi API ra mạng ngoài.
- **Purpose:** Cung cấp giao diện và API quản trị tập trung để lập lịch định kỳ thu thập dữ liệu xu hướng (social media, tin tức báo chí, search trends), quản lý danh sách kênh mục tiêu (TikTok, Facebook, Google Trends, News), cấu hình nhóm proxy xoay vòng để chống chặn IP/rate-limit, thiết lập hạn mức dữ liệu mỗi đợt cào (`postsPerRun`), cung cấp nút kích hoạt khẩn cấp ("Run Now"), và lưu vết toàn bộ lịch sử thực thi phục vụ giám sát vận hành.
- **Interface:** Màn hình Quản trị `/admin/ai/crawl-config`:
  - Thẻ *Cấu hình Lịch trình (Schedule & Budget)*: Thiết lập Cron Expression kèm bộ trợ giúp trực quan (Presets: mỗi 30 phút, 1 giờ, 2 giờ, 6 giờ, 12 giờ, 24 giờ hoặc Cron tự nhập), time zone (mặc định `Asia/Ho_Chi_Minh`), số bài viết tối đa mỗi lần chạy (`postsPerRun`, từ 10 đến 500 bài).
  - Thẻ *Kênh Mục tiêu (Target Channels & Sources)*: Bảng danh sách các nguồn cào (TikTok, Facebook, Google Trends, Báo điện tử/VnExpress/TuoiTre/CafeF...) kèm switch bật/tắt (active/inactive), URL gốc/tag theo dõi, và hạn mức phân bổ bài cho từng nguồn.
  - Thẻ *Quản lý Nhóm Proxy (Proxy Pool Manager)*: Danh sách proxy server (HTTP/HTTPS/SOCKS5), định dạng `protocol://user:pass@host:port`, cơ chế xoay vòng (Round-Robin / Least-Used), trạng thái sức khỏe (Alive/Dead/Degraded), và độ trễ phản hồi (ms).
  - Thẻ *Thao tác & Trạng thái Thực thi (Execution Control & Status)*: Nút "Run Now" (kèm popup xác nhận), hiển thị trạng thái crawler thời gian thực (`IDLE`, `RUNNING`, `ERROR`), thông tin lần chạy gần nhất (`lastRunAt`), và thời điểm chạy dự kiến kế tiếp (`nextRunAt`).
  - Thẻ *Nhật ký Lịch sử Cào (Crawl Execution History)*: Bảng phân trang hiển thị 20 lần chạy gần nhất gồm ID, loại kích hoạt (`CRON` / `MANUAL`), thời gian bắt đầu, kết thúc, tổng số bài thu thập, trạng thái (`SUCCESS`, `PARTIAL_SUCCESS`, `FAILED`), danh sách lỗi proxy/nguồn nếu có, và link xem log chi tiết.
- **Data Processing:**
  - Khi lưu cấu hình: Hệ thống xác thực cú pháp Cron Expression (theo chuẩn 5 hoặc 6 trường Quartz/Unix), kiểm tra tính hợp lệ của định dạng Proxy URL và danh sách kênh mục tiêu. Cấu hình được lưu vào bảng `crawl_configs` trong PostgreSQL của hệ thống.
  - Sau khi lưu, bộ lập lịch hệ thống (APScheduler / Celery Beat / n8n) cập nhật lịch trình mới và tính toán `nextRunAt`.
  - **Cô lập Snapshot khi đang chạy (Config Snapshot Isolation - PO D12/D02):** Nếu tiến trình cào đang thực thi trong lúc Admin lưu cấu hình mới, tiến trình đang chạy tiếp tục sử dụng snapshot cấu hình cũ đến khi kết thúc. Cấu hình mới lưu chỉ có hiệu lực cho các lần chạy kế tiếp, tuyệt đối không hủy ngang job đang chạy.
  - **Khóa Chống Chạy Trùng (Distributed Lock):** Sử dụng Redis distributed lock với key `lock:crawl:job` (TTL tối đa 30 phút) để đảm bảo tại một thời điểm chỉ có duy nhất 1 tiến trình crawler hoạt động, ngăn chặn xung đột giữa lịch Cron tự động và thao tác "Run Now" thủ công.
  - **Kích hoạt "Run Now":** Gửi lệnh kích hoạt qua internal HTTP request tới `brandhub-ai-service` với header xác thực `X-Internal-Api-Key`. Nếu Redis lock đang bị giữ, hệ thống từ chối với lỗi 409 `CRAWL_JOB_ALREADY_RUNNING`.
  - Mọi sự kiện thực thi đều ghi nhận chi tiết vào bảng `crawl_history_logs` để theo dõi và đối soát chất lượng dữ liệu.

## Routes / DTOs (ground truth: `admin/ai/crawl-config`, `trends.py`, `trend_scheduler.py`)

| Route | Auth | Request body | Response | Notes |
|---|---|---|---|---|
| `GET /api/v1/admin/ai/crawl-config` | Bearer (SYSTEM_ADMIN) | none | `ApiResponse<CrawlConfigResponse>` 200 | Lấy cấu hình cào hiện hành, trạng thái lock hiện tại, và thời điểm `nextRunAt`. |
| `PUT /api/v1/admin/ai/crawl-config` | Bearer (SYSTEM_ADMIN) | `UpdateCrawlConfigRequest` | `ApiResponse<CrawlConfigResponse>` 200 | Cập nhật cron, proxy pool, sources, `postsPerRun`. Áp dụng từ chu kỳ tiếp theo. |
| `POST /api/v1/admin/ai/crawl-config/trigger-now` | Bearer (SYSTEM_ADMIN) | none | `ApiResponse<CrawlTriggerResponse>` 200 | Kích hoạt cào ngay lập tức nếu không có job nào đang chạy. Trả về `jobId`. |
| `GET /api/v1/admin/ai/crawl-config/history` | Bearer (SYSTEM_ADMIN) | Query: `page=1&limit=20&status=&source=` | `ApiResponse<PageResponse<CrawlHistoryItem>>` 200 | Danh sách lịch sử cào phân trang, kèm thống kê bài cào và trạng thái lỗi. |

### Chi tiết Request / Response DTO

```json
// UpdateCrawlConfigRequest
{
  "cronExpression": "0 */2 * * *",
  "timezone": "Asia/Ho_Chi_Minh",
  "postsPerRun": 100,
  "sources": [
    { "platform": "tiktok", "enabled": true, "maxPosts": 30, "targetTags": ["trend", "viral", "review"] },
    { "platform": "facebook", "enabled": true, "maxPosts": 30, "targetPages": ["kenh14", "vnexpress"] },
    { "platform": "google_trends", "enabled": true, "geo": "VN", "maxKeywords": 20 },
    { "platform": "news", "enabled": true, "maxPosts": 20, "rssFeeds": ["https://vnexpress.net/rss/tin-moi-nhat.rss"] }
  ],
  "proxyPool": [
    { "proxyUrl": "http://user1:pass1@103.152.11.20:8080", "protocol": "HTTP", "enabled": true },
    { "proxyUrl": "socks5://user2:pass2@103.152.11.21:1080", "protocol": "SOCKS5", "enabled": true }
  ],
  "retryAttempts": 3,
  "timeoutSeconds": 1800
}
```

```json
// CrawlConfigResponse
{
  "success": true,
  "data": {
    "configId": "cfg_9a8b7c6d-5e4f-3a2b-1c0d-e9f8a7b6c5d4",
    "cronExpression": "0 */2 * * *",
    "timezone": "Asia/Ho_Chi_Minh",
    "postsPerRun": 100,
    "sources": [...],
    "proxyPool": [...],
    "status": "IDLE",
    "activeJobId": null,
    "lastRunAt": "2026-09-27T08:00:00+07:00",
    "nextRunAt": "2026-09-27T10:00:00+07:00",
    "updatedAt": "2026-09-27T08:30:15+07:00",
    "updatedBy": "admin@brandhub.io"
  }
}
```

```json
// CrawlTriggerResponse
{
  "success": true,
  "data": {
    "jobId": "crawl_job_7f8e9d0c-1b2a-3c4d-5e6f-7a8b9c0d1e2f",
    "triggerType": "MANUAL",
    "startedAt": "2026-09-27T09:15:00+07:00",
    "status": "RUNNING",
    "message": "Crawl job has been dispatched successfully."
  }
}
```

```json
// Internal Service Mapping (business-service -> ai-service)
POST http://ai-service:8082/api/v1/ai/trends/crawl
Headers: { "X-Internal-Api-Key": "${INTERNAL_API_KEY}" }
Body: {
  "jobId": "crawl_job_7f8e9d0c-1b2a-3c4d-5e6f-7a8b9c0d1e2f",
  "sources": ["google_trends", "tiktok", "facebook", "news"],
  "limit": 100,
  "proxies": ["http://user1:pass1@103.152.11.20:8080"]
}
```

## Screen Layout

Căn cứ trang Quản trị `/admin/ai/crawl-config`:
- **Top Bar:** Breadcrumbs `Admin / AI Engine / Crawl Schedule & Data Pipeline`, kèm huy hiệu trạng thái crawler: Dot xanh (`IDLE - Sẵn sàng`), Dot vàng nhấp nháy (`RUNNING - Đang cào dữ liệu...`), Dot đỏ (`ERROR - Lỗi kết nối`).
- **Khối Schedule Settings:**
  - Nhóm radio button chọn tần suất mẫu: `Mỗi 30 phút`, `Mỗi 1 giờ`, `Mỗi 2 giờ`, `Mỗi 6 giờ`, `Tùy chỉnh (Cron)`.
  - Ô nhập liệu Cron Expression (VD: `0 */2 * * *`), bên dưới hiển thị văn bản giải nghĩa tự động bằng tiếng Việt: *"Chạy vào phút 0 của mỗi 2 giờ (Ví dụ: 08:00, 10:00, 12:00...)"*.
  - Ô chọn Timezone (mặc định `Asia/Ho_Chi_Minh GMT+7`).
  - Thanh trượt hoặc ô số `postsPerRun` (Ngân sách bài cào mỗi đợt, mặc định 100, min 10, max 500).
- **Khối Target Channels:**
  - Bảng 4 dòng tương ứng 4 nền tảng hỗ trợ: Google Trends, TikTok, Facebook, Báo điện tử (News).
  - Mỗi dòng gồm: Tên nền tảng, Icon, Toggle kích hoạt, Ô nhập chỉ tiêu số bài, Cấu hình danh sách nguồn/link theo dõi, nút "Cấu hình chi tiết".
- **Khối Proxy Pool:**
  - Nút "+ Thêm Proxy", nút "Kiểm tra toàn bộ Proxy (Test Latency)".
  - Bảng danh sách Proxy: Cột IP:Port, Giao thức, Trạng thái (Active/Dead), Ping (ms), Số lượt dùng, Lần lỗi cuối, Nút xóa/sửa.
- **Action Footer:** Nút "Lưu Cấu Hình" (Primary, hiển thị trạng thái saving), nút "Hủy thay đổi" (Secondary), nút "Run Now" (Nổi bật, icon Play, có badge cảnh báo nếu job đang chạy).
- **Khối Crawl History Table:**
  - Bảng dữ liệu: Cột Mã Job, Kích hoạt bởi, Giờ bắt đầu, Thời lượng (s), Thu thập (bài), Trạng thái, Lỗi, Thao tác xem chi tiết.
  - Phân trang 20 dòng/trang, bộ lọc theo trạng thái (`ALL`, `SUCCESS`, `PARTIAL_SUCCESS`, `FAILED`).

## Function Details

### Data Specifications

- **Input required:**
  - `cronExpression`: Chuỗi biểu thức cron hợp lệ (5 hoặc 6 trường theo chuẩn Unix/Quartz).
  - `timezone`: Tên định danh timezone IANA hợp lệ (VD: `Asia/Ho_Chi_Minh`).
  - `postsPerRun`: Số nguyên dương trong khoảng [10, 500].
  - `sources`: Danh sách ít nhất 1 nguồn cào có trạng thái `enabled: true`.
- **Input optional:**
  - `proxyPool`: Mảng danh sách proxy (có thể để trống nếu dùng IP direct của worker crawler, nhưng khuyến nghị có ít nhất 2 proxy).
  - `retryAttempts`: Số lần thử lại khi gặp lỗi mạng/bị chặn (mặc định 3, phạm vi [1, 5]).
  - `timeoutSeconds`: Thời gian timeout tối đa của 1 job cào (mặc định 1800 giây = 30 phút).
- **System data:**
  - `configId`: UUID định danh bản ghi cấu hình.
  - `activeJobId`: ID của job đang chiếm Redis lock (hoặc null nếu crawler đang IDLE).
  - `lastRunAt`: Thời gian hoàn tất đợt cào gần nhất.
  - `nextRunAt`: Thời điểm hệ thống dự kiến kích hoạt job cào tiếp theo.
  - `updatedBy`: Email hoặc User ID của Admin thực hiện thay đổi.
  - `updatedAt`: Thời điểm cập nhật cuối cùng.
- **Output:**
  - `CrawlConfigResponse`: Dữ liệu cấu hình đầy đủ kèm trạng thái vận hành.
  - `CrawlTriggerResponse`: Mã job và trạng thái khởi chạy thủ công.
  - `PageResponse<CrawlHistoryItem>`: Danh sách lịch sử cào phục vụ kiểm toán và theo dõi.

### Business Rules

- **BR-AI-01 (Phân quyền Quản trị cấp Hệ thống):** Chỉ tài khoản mang vai trò `SYSTEM_ADMIN` mới có quyền đọc, sửa đổi cấu hình hoặc kích hoạt "Run Now". Tất cả các vai trò khác (`OWNER`, `MANAGER`, `CREATOR`, `CLIENT`) đều bị từ chối với mã lỗi 403 `FORBIDDEN`. Quyền này được thực thi tại API Gateway và `SecurityFilterChain` của `business-service`.
- **BR-AI-02 (Tần suất Lịch trình Tối thiểu):** Để bảo vệ tài nguyên mạng, ngăn ngừa tình trạng bị các nền tảng mạng xã hội đưa vào danh sách đen (IP blacklisting/ban), chu kỳ kích hoạt cron không được phép dày hơn 15 phút/lần (ví dụ `*/10 * * * *` sẽ bị từ chối). Tần suất khuyến nghị là từ 1 đến 6 giờ mỗi lần.
- **BR-AI-03 (Bảo vệ Job Đang Chạy - Snapshot Isolation):** Khi Admin thay đổi và lưu cấu hình trong lúc crawler đang thực thi một chu kỳ cào:
  - Job đang chạy giữ nguyên snapshot tham số tại thời điểm nó được tạo (sử dụng danh sách nguồn, hạn mức `postsPerRun` và proxy ban đầu).
  - Cấu hình mới được ghi bền vững vào cơ sở dữ liệu và tái nạp vào scheduler, chỉ có hiệu lực kể từ lần chạy kế tiếp (`nextRunAt`).
  - Tuyệt đối không hủy bỏ (kill) tiến trình cào đang thực hiện dở dang để tránh làm rác dữ liệu raw trên S3.
- **BR-AI-04 (Khóa Chống Chạy Trùng Lặp - Concurrency Lock):** 
  - Tại một thời điểm, chỉ cho phép duy nhất một chu kỳ cào được diễn ra trên toàn hệ thống.
  - Trước khi khởi động cào (dù từ Cron tự động hay nút "Run Now"), scheduler phải giành được Redis Lock `lock:crawl:job` với TTL bằng `timeoutSeconds` (mặc định 1800 giây).
  - Khi job kết thúc (thành công hoặc thất bại), lock được giải phóng ngay lập tức.
  - Nếu Admin bấm "Run Now" trong lúc lock đang tồn tại, hệ thống lập tức từ chối và thông báo lỗi 409 `CRAWL_JOB_ALREADY_RUNNING`.
- **BR-AI-05 (Cơ chế Xoay vòng và Loại bỏ Proxy Lỗi):**
  - Hệ thống crawler sử dụng thuật toán xoay vòng Round-Robin hoặc Least-Used trên danh sách proxy đang kích hoạt (`enabled=true`).
  - Nếu một proxy gặp lỗi kết nối (Connection Timeout, 403 Forbidden, 429 Too Many Requests) liên tiếp 3 lần, crawler tự động đánh dấu proxy đó là `DEGRADED`/`DEAD`, ghi log cảnh báo và chuyển sang proxy tiếp theo trong pool.
  - Job vẫn tiếp tục thực thi chừng nào còn ít nhất 1 proxy hoạt động hoặc cấu hình cho phép fallback sang IP trực tiếp.
- **BR-AI-06 (Lưu trữ và Truy vết Nhật ký Lịch sử):**
  - Mỗi phiên cào phải ghi nhận bản ghi nhật ký độc lập vào `crawl_history_logs` bao gồm: `jobId`, `triggerType`, `startedAt`, `finishedAt`, `durationSeconds`, `rawPostsCollected`, `status` (`SUCCESS`, `PARTIAL_SUCCESS`, `FAILED`), và `errorSummary`.
  - Dữ liệu nhật ký phải được lưu giữ tối thiểu 90 ngày phục vụ đối soát và phân tích chất lượng dữ liệu xu hướng.

### Validation

- `cronExpression` rỗng hoặc không đúng chuẩn cú pháp cron 5-6 trường → 400 `INVALID_CRON_FORMAT`, hiển thị: MSG-AI-01.
- `cronExpression` có tần suất nhỏ hơn 15 phút (ví dụ mỗi 5 phút, mỗi 10 phút) → 400 `CRON_FREQUENCY_TOO_HIGH`, hiển thị: MSG-AI-02.
- `timezone` không nằm trong danh sách định danh IANA hợp lệ → 400 `INVALID_TIMEZONE`, hiển thị: MSG-AI-03.
- `postsPerRun` không phải số nguyên hoặc nằm ngoài phạm vi [10, 500] → 400 `INVALID_POSTS_PER_RUN`, hiển thị: MSG-AI-04.
- Danh sách `sources` không có bất kỳ nguồn nào được bật (`enabled: true`) → 400 `NO_ACTIVE_SOURCE`, hiển thị: MSG-AI-05.
- Chuỗi URL trong `proxyPool` sai định dạng URI (thiếu host, sai protocol) → 400 `INVALID_PROXY_URL`, hiển thị: MSG-AI-06.
- Người dùng không có vai trò `SYSTEM_ADMIN` → 403 `FORBIDDEN`, hiển thị: MSG-AI-07.
- Bấm "Run Now" khi hệ thống đang có job cào đang chạy (Redis lock đang tồn tại) → 409 `CRAWL_JOB_ALREADY_RUNNING`, hiển thị: MSG-AI-08.

## Functionalities

### Normal Flow

1. **Truy cập trang Quản trị:** `SYSTEM_ADMIN` đăng nhập vào BrandHub, mở menu Admin và chọn "AI Engine / Crawl Config". Trình duyệt gửi `GET /api/v1/admin/ai/crawl-config`.
2. **Hiển thị dữ liệu:** Hệ thống kiểm tra quyền `SYSTEM_ADMIN`, tải bản ghi cấu hình hiện hành từ cơ sở dữ liệu, kiểm tra trạng thái khóa Redis `lock:crawl:job` để xác định trạng thái (`IDLE` hoặc `RUNNING`), tính toán thời điểm `nextRunAt`, và đồng thời tải danh sách 20 lịch sử cào gần nhất (`GET /api/v1/admin/ai/crawl-config/history`). Giao diện hiển thị đầy đủ các thông số.
3. **Chỉnh sửa cấu hình:** Admin thay đổi biểu thức cron sang `0 */4 * * *` (mỗi 4 giờ), điều chỉnh `postsPerRun` thành 150 bài, bật thêm nguồn báo điện tử mới và thêm 1 proxy mới vào nhóm proxy pool.
4. **Gửi lưu cấu hình:** Admin bấm "Lưu Cấu Hình". Trình duyệt gửi `PUT /api/v1/admin/ai/crawl-config` kèm dữ liệu đã sửa đổi.
5. **Xác thực và Cập nhật Lịch trình:** Hệ thống xác thực định dạng dữ liệu (cron, proxy, nguồn). Cập nhật bảng `crawl_configs`, gửi tín hiệu cập nhật tới Job Scheduler để tái lập lịch trình, tính lại `nextRunAt`, và ghi nhận audit log `ACTION_UPDATE_CRAWL_CONFIG`. Trả về 200 `CrawlConfigResponse`. Giao diện hiển thị toast thông báo thành công.
6. **Kích hoạt Cào Thủ công ("Run Now"):** Khi cần cập nhật dữ liệu xu hướng ngay lập tức, Admin bấm nút "Run Now". Modal xác nhận xuất hiện: *"Bạn có chắc chắn muốn kích hoạt cào dữ liệu ngay lập tức? Thao tác này sẽ tiêu tốn tài nguyên mạng và proxy."*
7. **Xác nhận kích hoạt:** Admin bấm "Xác nhận". Trình duyệt gửi `POST /api/v1/admin/ai/crawl-config/trigger-now`.
8. **Khởi tạo Job và Dispatch:** Hệ thống kiểm tra Redis lock. Không có job nào đang chạy, hệ thống cấp khóa `lock:crawl:job` với TTL 1800 giây, tạo bản ghi `crawl_history_logs` ở trạng thái `RUNNING`, gửi yêu cầu nội bộ tới `ai-service` qua `POST /api/v1/ai/trends/crawl` kèm internal API key.
9. **Phản hồi người dùng:** Hệ thống trả về 200 `CrawlTriggerResponse` kèm `jobId`. Giao diện chuyển trạng thái sang `RUNNING`, hiển thị thanh tiến trình và tự động refresh bảng lịch sử cào khi job hoàn tất.

### Abnormal Cases

- **1.a1: Người dùng không phải SYSTEM_ADMIN truy cập trang hoặc gọi API (BR-AI-01)**
  - *Hành vi:* API Gateway / Security Filter chặn ngay lập tức, trả về HTTP 403 `FORBIDDEN` kèm mã lỗi MSG-AI-07.
  - *Xử lý phía UI:* Điều hướng người dùng về trang lỗi 403 hoặc trang chủ Workspace kèm thông báo toast: *"Bạn không có quyền truy cập khu vực cấu hình hệ thống này."*
- **3.a1: Nhập biểu thức Cron sai định dạng hoặc không thể phân tích cú pháp (BR-AI-02)**
  - *Hành vi:* Backend từ chối với HTTP 400 `INVALID_CRON_FORMAT` kèm thông báo chi tiết lỗi cú pháp (MSG-AI-01).
  - *Xử lý phía UI:* Ô nhập Cron hiển thị viền đỏ và text lỗi: *"Cú pháp Cron không hợp lệ. Vui lòng kiểm tra lại định dạng 5 trường (phút giờ ngày tháng thứ)."*
- **3.a2: Nhập tần suất Cron quá dày dưới 15 phút (BR-AI-02)**
  - *Hành vi:* Backend kiểm tra khoảng cách tối thiểu giữa 2 lần chạy, từ chối với HTTP 400 `CRON_FREQUENCY_TOO_HIGH` (MSG-AI-02).
  - *Xử lý phía UI:* Báo lỗi: *"Tần suất cào không được phép nhỏ hơn 15 phút/lần để tránh bị chặn IP."*
- **3.b1: Định dạng Proxy URL không hợp lệ (sai schema, thiếu port)**
  - *Hành vi:* Backend Regex check thất bại, trả về HTTP 400 `INVALID_PROXY_URL` (MSG-AI-06).
  - *Xử lý phía UI:* Highlight dòng proxy bị lỗi, yêu cầu định dạng chuẩn `http://user:pass@host:port` hoặc `socks5://host:port`.
- **4.a1: Thay đổi cấu hình khi có một Job đang chạy trong nền (BR-AI-03)**
  - *Hành vi:* Backend vẫn lưu cấu hình mới bình thường vào DB và lên lịch cho chu kỳ tiếp theo, nhưng không can thiệp vào job đang chạy. Trả về 200 OK kèm thông báo bổ sung `warning: "Active job is running with previous configuration snapshot. New configuration will take effect on the next scheduled run."`
  - *Xử lý phía UI:* Hiển thị banner thông báo: *"Cấu hình đã được lưu thành công và sẽ áp dụng cho lần cào kế tiếp lúc {nextRunAt}."*
- **7.a1: Bấm "Run Now" khi Redis Lock đang tồn tại (Job tự động hoặc job thủ công khác đang chạy) (BR-AI-04)**
  - *Hành vi:* Backend kiểm tra thấy `lock:crawl:job` đang bị chiếm giữ, từ chối yêu cầu với HTTP 409 `CRAWL_JOB_ALREADY_RUNNING` (MSG-AI-08).
  - *Xử lý phía UI:* Modal đóng lại, hiển thị toast cảnh báo: *"Tiến trình cào dữ liệu đang diễn ra. Vui lòng chờ job hiện tại hoàn thành trước khi kích hoạt đợt cào mới."*
- **8.a1: Worker AI Service sập hoặc không phản hồi kết nối nội bộ khi trigger (Downstream Failure)**
  - *Hành vi:* `business-service` gọi `ai-service` bị Connection Refused hoặc Timeout sau 10 giây. Hệ thống tự động xóa Redis lock vừa tạo, cập nhật trạng thái bản ghi lịch sử thành `FAILED` với lý do `DOWNSTREAM_SERVICE_UNAVAILABLE`, trả về HTTP 502 `BAD_GATEWAY`.
  - *Xử lý phía UI:* Hiển thị thông báo lỗi: *"Không thể kết nối tới AI Crawler Service. Vui lòng kiểm tra trạng thái máy chủ worker."*
- **8.a2: Toàn bộ Proxy trong pool đều bị chết trong quá trình cào (BR-AI-05)**
  - *Hành vi:* Crawler thử lần lượt các proxy và đều thất bại quá 3 lần. Nếu cấu hình không cho phép direct IP, job dừng lại và đánh dấu trạng thái `FAILED` với lỗi `ALL_PROXIES_EXHAUSTED`.
  - *Xử lý phía UI:* Bảng lịch sử ghi nhận trạng thái Đỏ (`FAILED`), gửi thông báo cảnh báo tới Admin qua Notification Bell.

## Post-Conditions

- **Khi lưu cấu hình thành công:**
  - Bảng `crawl_configs` trong cơ sở dữ liệu được cập nhật bản ghi mới nhất.
  - Scheduler hệ thống hủy bỏ trigger cũ và thiết lập trigger mới theo đúng biểu thức cron và timezone đã lưu.
  - Trường `nextRunAt` được tính toán lại chính xác.
  - Một dòng Audit Log được ghi nhận với hành vi `UPDATE_CRAWL_CONFIG`, lưu rõ ID của Admin và thời điểm thực hiện.
- **Khi kích hoạt "Run Now" thành công:**
  - Redis Lock `lock:crawl:job` được tạo lập với TTL xác định.
  - Bản ghi mới trong `crawl_history_logs` được tạo với trạng thái `RUNNING`.
  - Tiến trình cào thô dữ liệu tại AI Service bắt đầu nạp bài viết từ các kênh mục tiêu vào buffer lưu trữ tạm trước khi chuyển sang pipeline xử lý xu hướng.
- **Khi job cào hoàn tất:**
  - Redis Lock `lock:crawl:job` được giải phóng.
  - Bản ghi `crawl_history_logs` được cập nhật thời gian kết thúc, thời lượng chạy, tổng số bài cào được, và trạng thái `SUCCESS` hoặc `PARTIAL_SUCCESS`.
  - Dữ liệu thô thu thập được sẵn sàng cho Pipeline Trend 7 Tầng (FR 3.7.1) xử lý.

## Out of Scope

- Tự động thanh toán mua thêm gói Proxy từ các nhà cung cấp bên thứ 3 (Admin phải tự mua và dán thông tin proxy vào hệ thống).
- Cấu hình các tham số scoring thuật toán chuyên sâu của AI Pipeline (trọng số BM25, đồ thị cộng đồng - các tham số này thuộc cấu hình pipeline kỹ thuật nội bộ của đội ngũ AI, không nằm trong màn hình quản trị lịch cào này).
- Tùy chỉnh lịch cào riêng biệt theo từng Workspace của khách hàng (Crawler là hạ tầng dùng chung toàn hệ thống).

## References

- **Căn cứ kế hoạch & Quyết định PO:** `docs/plan/ai-features-spec-alignment-plan.md` (Mục 1 Quyết định 2026-09-27, Mục 2.3 Trend Collection, Mục 3 Quyết định D02, D12, Mục 4 Bảng điều chỉnh FR 3.7.9, Mục 7.1 Kịch bản nghiệm thu kiểm soát lịch cào).
- **Phân tích Nghiệp vụ:** `docs/ba/06-ai-features.md` (Mục 3.7.9 Crawl Schedule Config - duy nhất thuộc ADMIN); `docs/ba/use-cases/05-ai-features.md` (UC-80 Configure Trend Crawl Schedule).
- **Kiến trúc & Service Contract:** `docs/architecture/business-ai-rest-contract.md` (Giao tiếp REST nội bộ, `X-Internal-Api-Key`); `docs/architecture/service-boundaries.md`.
- **Hiện trạng Codebase:** `brandhub-ai-service/app/api/v1/endpoints/trends.py` (`POST /crawl`, `GET /pipeline-config`), `brandhub-ai-service/app/services/trend_scheduler.py`, `brandhub-ai-service/app/services/trend_service.py`.
- **Mã thông báo & Quy tắc:** `Section5_Requirement_Appendix.md` (Quy ước mã lỗi `MSG-AI-xx`, quy tắc phân quyền `BR-AI-xx`).

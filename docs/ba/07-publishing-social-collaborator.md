# 07 — Kết nối Mạng xã hội, Lên lịch & Xuất bản Đa Nền tảng (Publishing & Social Integration)

> [<< 06 - AI Features](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/06-ai-features.md) | [Overview](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/00-overview.md) | [Tiếp: 08 - Subscription & Billing >>](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/08-subscription-billing.md)
>
> **Phạm vi FR chuẩn**: **Mục `3.8 Publishing & Social` — 15 FR (`3.8.1` – `3.8.15`)** | `UC-107` – `UC-121`.
> Tuân thủ nghiêm ngặt quy tắc **4 nền tảng mạng xã hội chuẩn: Facebook, Instagram, TikTok, và Threads** (không có Zalo OA theo `AGENTS.md`).
> *(Lưu ý: Nhóm Danh bạ Cộng tác viên / KOL Directory đã được chuẩn hóa sang mục `3.7.15`–`3.7.19` trong [06-ai-features.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/06-ai-features.md)).*

---

## 1. Bảng Tổng hợp 15 Yêu cầu Chức năng Chuẩn (`3.8.1` – `3.8.15`)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (Atomic CRUD FR) | Actors / Roles Chuẩn | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :--- |
| **`3.8.1`** | `UC-107` | **Connect Social Account** | `Client`, `Manager` *(và `Owner` ở chế độ `PERSONAL`)* | Kết nối tài khoản mạng xã hội chính chủ (Facebook Page, Instagram Business, TikTok Account, Threads Profile) vào Workspace qua giao thức OAuth 2.0. |
| **`3.8.2`** | `UC-108` | **Disconnect Account** | `Client`, `Manager` *(và `Owner` ở chế độ `PERSONAL`)* | Ngắt kết nối một tài khoản mạng xã hội khỏi Workspace; thu hồi token lưu trữ và dừng các lịch đăng tự động gắn với tài khoản đó. |
| **`3.8.3`** | `UC-109` | **View Dashboard Post** | `Owner`, `Manager`, `Creator`, `Client` | Xem bảng tổng hợp hiệu quả và danh sách các bài đã đăng trên các kênh mạng xã hội của Workspace (lượt tiếp cận, tương tác, bình luận tổng hợp). |
| **`3.8.4`** | `UC-110` | **View Posted Detail** | `Owner`, `Manager`, `Creator`, `Client` | Xem chi tiết một bài viết đã xuất bản kèm đường dẫn trực tiếp tới bài đăng gốc trên từng nền tảng và các chỉ số tương tác chi tiết. |
| **`3.8.5`** | `UC-111` | **Preview Post** | `Owner`, `Manager`, `Creator`, `Client` | Xem trước giao diện hiển thị của bài viết (`Mockup Preview` chuẩn xác theo khung giao diện của Facebook, Instagram, TikTok, Threads trên cả Mobile & Desktop) trước khi duyệt hoặc xuất bản. |
| **`3.8.6`** | `UC-112` | **Schedule Platform Post** | `Manager`, `Creator` | Thiết lập thời điểm xuất bản tự động (`scheduledAt`) và chọn danh sách nền tảng mục tiêu (`targetPlatforms`) trong phần `POST.CHANNELS` / `VIDEO.CHANNELS`. |
| **`3.8.7`** | `UC-113` | **Track Post Status** | `Owner`, `Manager`, `Creator`, `Client` | Theo dõi trạng thái xuất bản thời gian thực của từng nền tảng (`SCHEDULED` → `PUBLISHING` → `PUBLISHED` / `PARTIALLY_PUBLISHED` / `FAILED`) kèm thông báo lỗi chi tiết và nút thử đăng lại (`Retry`). |
| **`3.8.8`** | `UC-114` | **Publish Facebook Post** | `Manager`, `Creator` | Xuất bản bài viết thường (văn bản, bộ ảnh hoặc video) lên Facebook Page qua Meta Graph API. |
| **`3.8.9`** | `UC-115` | **Publish Facebook Reels** | `Manager`, `Creator` | Xuất bản video ngắn dọc (`9:16`) lên mục Facebook Reels của Fanpage. |
| **`3.8.10`** | `UC-116` | **Publish Facebook Stories** | `Manager`, `Creator` | Xuất bản tin ngắn 24 giờ (ảnh hoặc video dọc) lên Facebook Page Stories. |
| **`3.8.11`** | `UC-117` | **Publish Instagram Post** | `Manager`, `Creator` | Xuất bản bài đăng ảnh đơn, album轮播 (Carousel) hoặc video lên tài khoản Instagram Business/Creator. |
| **`3.8.12`** | `UC-118` | **Publish Instagram Reels** | `Manager`, `Creator` | Xuất bản video ngắn dọc lên Instagram Reels kèm ảnh bìa (`cover`) và caption. |
| **`3.8.13`** | `UC-119` | **Publish Instagram Stories** | `Manager`, `Creator` | Xuất bản ảnh/video lên Instagram Stories. |
| **`3.8.14`** | `UC-120` | **Publish TikTok Video** | `Manager`, `Creator` | Xuất bản video ngắn lên kênh TikTok qua TikTok Content Posting API (kèm tùy chọn quyền riêng tư và cho phép bình luận/duet/stitch). |
| **`3.8.15`** | `UC-121` | **Publish Threads Post** | `Manager`, `Creator` | Xuất bản bài viết văn bản, hình ảnh hoặc video ngắn lên nền tảng Meta Threads qua Threads API. |

---

## 2. Đặc tả Nghiệp vụ Kết nối Tài khoản Mạng xã hội (`3.8.1` – `3.8.2`)

### 2.1. Quyền Kết nối trong Chế độ `AGENCY` vs. `PERSONAL`
- **Trong Chế độ `AGENCY` (`workspaceMode = "AGENCY"`)**:
  - Cả **`Client`** (tại `Client Portal` hoặc trang kết nối) và **`Manager`** (cùng `Owner`) đều có quyền thực hiện OAuth kết nối tài khoản MXH của thương hiệu vào Workspace.
- **Trong Chế độ `PERSONAL` (`workspaceMode = "PERSONAL"`)**:
  - Chủ không gian (**`Owner` / `Manager`**) kết nối trực tiếp các kênh Facebook, Instagram, TikTok, Threads cá nhân của mình tại `/workspaces/:id/social-accounts` (hoặc bấm từ **Bệ phóng Sáng tạo Cá nhân — Personal Quick Launchpad** trên Dashboard) mà không cần thông qua bất kỳ tài khoản `Client` nào.

### 2.2. Quản lý Vòng đời Token OAuth
- Mọi `accessToken` và `refreshToken` của 4 nền tảng được mã hóa an toàn trước khi lưu trữ và được quản lý bởi `brandhub-publisher-service` / `brandhub-business-service`.
- Khi token sắp hết hạn, dịch vụ tự động gia hạn ngầm (`Token Refresh`); nếu người dùng đổi mật khẩu MXH hoặc thu hồi quyền từ phía nền tảng khiến token hết hiệu lực (`EXPIRED`), hệ thống hiển thị cảnh báo trạng thái cần kết nối lại (`Reconnect`).

---

## 3. Quy trình Lên lịch, Phê duyệt & Xuất bản Đa Nền tảng (`3.8.5` – `3.8.15`)

### 3.1. Điều kiện Tiên quyết Để Xuất bản (`Publishing Gate`)
Để đảm bảo không bao giờ đăng nhầm nội dung chưa được phê duyệt lên mạng xã hội:
1. **Quyền cấu hình kênh & lịch đăng (`POST.CHANNELS` / `VIDEO.CHANNELS`)**:
   - Người giữ vai trò `POST_PUBLISHING` (với Task `POST`), `VIDEO_PUBLISH` (với Task `SHORT_VIDEO`), Điều phối viên (`assigneeId`), hoặc `Manager` / `Owner` có thể chọn kênh xuất bản và đặt giờ đăng dự kiến (`scheduledAt`) bất cứ lúc nào khi phần còn mở.
   - Riêng công việc loại `SHORT_VIDEO` chỉ cho phép chọn các kênh hỗ trợ định dạng video ngắn: **TikTok (`3.8.14`), Instagram Reels (`3.8.12`), Facebook Reels (`3.8.9`)**.
2. **Điều kiện mở khóa Xuất bản thật (`Publish Now` & `PostSchedulePublishJob`)**:
   - Lệnh xuất bản thật sang `brandhub-publisher-service` (qua hàng đợi RabbitMQ `PublishJobMessage`) **chỉ được kích hoạt khi Công việc cha đã hoàn tất phê duyệt**:
     - `task.status == TaskStatus.FINISHED` **VÀ** `task.lastSubmission.outcome == ApprovalOutcome.APPROVED`.
   - **Ở chế độ `AGENCY`**: Đạt được sau khi `Manager` duyệt nội bộ và `Client` duyệt đủ các phần sản phẩm đầu ra (`CLIENT_APPROVED`).
   - **Ở chế độ `PERSONAL`**: Đạt được **ngay lập tức chỉ với 1 cú nhấp chuột** khi chủ không gian bấm nút **"Hoàn tất & Duyệt ngay (`Self-Approve`)"** (`POST /api/v1/workspaces/{id}/tasks/{taskId}/self-approve`).

### 3.2. Cơ chế Hủy lịch Tự động Khi Nội dung Bị Trả lại
- Nếu một bài viết đã được đặt lịch (`status = SCHEDULED`), nhưng trước giờ đăng mà `Client` hoặc `Manager` bấm **Trả lại (`Return`)** một phần nội dung để yêu cầu chỉnh sửa:
  - Hệ thống tự động đưa Task cha về `IN_PROGRESS` và gọi `PostService.cancelTaskSchedule(workspaceId, taskId)` để chuyển bài viết về `DRAFT`, xóa `scheduledAt`.
  - Nhờ đó, `PostSchedulePublishJob` (quét định kỳ mỗi 30 giây) sẽ tự động bỏ qua bài viết đó cho đến khi nội dung được sửa, duyệt lại và đặt lịch mới.

### 3.3. Quy chuẩn Kỹ thuật Theo Từng Định dạng Xuất bản (`3.8.8` – `3.8.15`)

| Mã FR | Định dạng Xuất bản | Nền tảng | Yêu cầu Nội dung & Media Đầu vào |
| :-: | :--- | :---: | :--- |
| **`3.8.8`** | **Facebook Post** | Facebook Page | Văn bản (`caption` ≤ 63.206 ký tự), kèm tùy chọn 1–10 ảnh (JPG/PNG/WebP) hoặc 1 video. |
| **`3.8.9`** | **Facebook Reels** | Facebook Page | Bắt buộc 1 video dọc (`9:16` khuyến nghị, thời lượng 3s–90s, MP4/MOV) + mô tả ngắn. |
| **`3.8.10`** | **Facebook Stories** | Facebook Page | Bắt buộc 1 ảnh hoặc 1 video ngắn dọc hiển thị trong 24 giờ. |
| **`3.8.11`** | **Instagram Post** | Instagram Business | Bắt buộc ít nhất 1 ảnh hoặc album Carousel (tối đa 10 media) + `caption` (≤ 2.200 ký tự, tối đa 30 hashtag). |
| **`3.8.12`** | **Instagram Reels** | Instagram Business | Bắt buộc 1 video dọc (MP4/MOV, tối đa 15 phút, khuyến nghị ≤ 90s) + `caption` + ảnh bìa tùy chọn. |
| **`3.8.13`** | **Instagram Stories** | Instagram Business | Bắt buộc 1 ảnh hoặc 1 video ngắn dọc hiển thị trong 24 giờ. |
| **`3.8.14`** | **TikTok Video** | TikTok | Bắt buộc 1 video (MP4/WebM/MOV, 3s–10 phút) + tiêu đề/caption (≤ 2.200 ký tự). |
| **`3.8.15`** | **Threads Post** | Threads | Văn bản (≤ 500 ký tự mỗi bài) và/hoặc ảnh/video đính kèm. |

# UC 06 — Publishing & Social (`UC-107` – `UC-121`)

> [<< 05-ai-features.md](./05-ai-features.md) | [UC Index](./README.md) | [Domain BA Spec: 07-publishing-social.md](../07-publishing-social.md) | [07-subscription.md >>](./07-subscription.md)
>
> Đồng bộ chuẩn xác 1-đối-1 với `Các FR của hệ thống - Feature_Function Requirement.csv` và `AGENTS.md`. Chỉ sử dụng **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)**.

---

## 1. Bảng Tổng Hợp Use Cases (15 UCs)

| UC ID | Use Case Title | Canonical Actor(s) | Related FR | Business Rules |
| :-: | :--- | :--- | :-: | :--- |
| `UC-107` | Connect Social Account | `Owner`, `Manager`, `Client` | `3.8.1` | `BR-20, BR-53` |
| `UC-108` | Disconnect Account | `Owner`, `Manager`, `Client` | `3.8.2` | `BR-20, BR-53` |
| `UC-109` | View Dashboard Post | `Owner`, `Manager`, `Creator`, `Client` | `3.8.3` | `BR-20, BR-57` |
| `UC-110` | View Posted Detail | `Owner`, `Manager`, `Creator`, `Client` | `3.8.4` | `BR-20, BR-57` |
| `UC-111` | Preview Post | `Owner`, `Manager`, `Creator`, `Client` | `3.8.5` | `BR-55` |
| `UC-112` | Schedule Platform Post | `Owner`, `Manager`, `Creator` | `3.8.6` | `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56, BR-63` |
| `UC-113` | Track Post Status | `Owner`, `Manager`, `Creator`, `Client` | `3.8.7` | `BR-20, BR-22, BR-56` |
| `UC-114` | Publish Facebook Post | `Owner`, `Manager`, `Creator` | `3.8.8` | `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56` |
| `UC-115` | Publish Facebook Story | `Owner`, `Manager`, `Creator` | `3.8.9` | `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56` |
| `UC-116` | Publish Facebook Reels | `Owner`, `Manager`, `Creator` | `3.8.10` | `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56` |
| `UC-117` | Publish Instagram Post | `Owner`, `Manager`, `Creator` | `3.8.11` | `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56, BR-57` |
| `UC-118` | Publish Instagram Reels | `Owner`, `Manager`, `Creator` | `3.8.12` | `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56` |
| `UC-119` | Publish Instagram Story | `Owner`, `Manager`, `Creator` | `3.8.13` | `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56` |
| `UC-120` | Publish TikTok Video | `Owner`, `Manager`, `Creator` | `3.8.14` | `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56` |
| `UC-121` | Publish Threads Post | `Owner`, `Manager`, `Creator` | `3.8.15` | `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56` |

---

## UC-107 — Connect Social Account

- **Related FR:** `3.8.1` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-20, BR-53`
- **System Messages:** `MSG02, MSG03, MSG07, MSG51, MSG54`
- **Specification & Flow:** Kết nối tài khoản mạng xã hội chính thức (Facebook Page, Instagram Business, TikTok Creator/Business, Threads) vào Workspace qua OAuth 2.0 (Connect Social Account — /workspaces/:id/social-accounts). Cho phép Client hoặc quản trị viên Workspace ủy quyền đăng bài tự động; hệ thống kiểm tra giới hạn số kênh theo gói đăng ký (BR-53), mã hóa AES-256 đối với Access/Refresh Token và tự động làm mới token định kỳ (BR-53).

---

## UC-108 — Disconnect Account

- **Related FR:** `3.8.2` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-20, BR-53`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG51`
- **Specification & Flow:** Ngắt kết nối tài khoản mạng xã hội khỏi Workspace (Disconnect Account — /workspaces/:id/social-accounts). Hệ thống thu hồi khóa OAuth đã lưu, hủy các lịch đăng tự động đang chờ (PENDING_SCHEDULE) của kênh đó và giữ nguyên lịch sử các bài đã đăng thành công trước đây (BR-53, BR-53).

---

## UC-109 — View Dashboard Post

- **Related FR:** `3.8.3` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-57`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem bảng điều khiển tổng hợp các bài viết đã đăng thành công trên các mạng xã hội của Workspace (View Dashboard Post — /workspaces/:id/publishing/dashboard). Hiển thị danh sách bài đã xuất bản, biểu đồ phân bổ theo nền tảng (Facebook, Instagram, TikTok, Threads) và tổng hợp nhanh hiệu suất tương tác (BR-57).

---

## UC-110 — View Posted Detail

- **Related FR:** `3.8.4` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-57`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem chi tiết nội dung và các chỉ số tương tác của một bài đăng đã xuất bản trên mạng xã hội (View Posted Detail — /workspaces/:id/publishing/posts/:postId). Hiển thị nội dung đã đăng, liên kết trực tiếp tới bài viết trên nền tảng đích (permalink), thời điểm xuất bản và các số liệu tương tác chi tiết: tổng lượt yêu thích/cảm xúc (Reactions), bình luận (Comments), chia sẻ (Shares) và lượt xem (Views) (BR-57).

---

## UC-111 — Preview Post

- **Related FR:** `3.8.5` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-55`
- **System Messages:** `MSG02, MSG03, MSG07, MSG52`
- **Specification & Flow:** Xem trước giao diện hiển thị của bài đăng theo đúng bố cục đặc thù của từng mạng xã hội trước khi duyệt hoặc xuất bản (Preview Post — /workspaces/:id/tasks/:taskId/preview). Mô phỏng trực quan khung hiển thị (Desktop & Mobile) của Facebook Feed/Reels/Story, Instagram Post/Reels/Story, TikTok Video và Threads Post kèm kiểm tra giới hạn ký tự và tỷ lệ khung hình (BR-55).

---

## UC-112 — Schedule Platform Post

- **Related FR:** `3.8.6` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56, BR-63`
- **System Messages:** `MSG02, MSG03, MSG07, MSG36, MSG52, MSG53`
- **Specification & Flow:** Lên lịch xuất bản tự động bài viết đã được phê duyệt vào ngày giờ cụ thể trên các kênh mạng xã hội đã chọn (Schedule Platform Post — /workspaces/:id/publishing/schedule). Hệ thống kiểm tra bài viết phải đạt trạng thái APPROVED (BR-54), quy đổi thời gian hẹn giờ theo Timezone của Workspace (BR-22, phải ở tương lai tối thiểu 5 phút BR-56) và đẩy vào hàng đợi lập lịch đăng tự động.

---

## UC-113 — Track Post Status

- **Related FR:** `3.8.7` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-22, BR-56`
- **System Messages:** `MSG01, MSG07, MSG54`
- **Specification & Flow:** Theo dõi trạng thái tiến trình xuất bản bài đăng theo thời gian thực qua 4 trạng thái: PENDING, IN_PROGRESS, DONE (PUBLISHED), FAIL (Track Post Status — /workspaces/:id/publishing/queue). Hiển thị nhật ký phản hồi từ API mạng xã hội, số lần thử lại tự động (tối đa 3 lần với exponential backoff khi gặp lỗi mạng tạm thời) và cho phép nhấn Retry thủ công đối với các bài đăng bị FAIL (BR-56).

---

## UC-114 — Publish Facebook Post

- **Related FR:** `3.8.8` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56`
- **System Messages:** `MSG07, MSG36, MSG52, MSG53, MSG54`
- **Specification & Flow:** Xuất bản trực tiếp hoặc theo lịch bài viết tiêu chuẩn (văn bản, bộ ảnh hoặc video) lên trang Facebook Page đã kết nối qua Meta Graph API (Publish Facebook Post). Kiểm tra bài viết đã được phê duyệt (BR-54), định dạng tệp hợp lệ (BR-55) và ghi nhận post_id / permalink trả về từ Facebook (BR-56, BR-55).

---

## UC-115 — Publish Facebook Story

- **Related FR:** `3.8.9` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56`
- **System Messages:** `MSG02, MSG07, MSG36, MSG52, MSG53, MSG54`
- **Specification & Flow:** Xuất bản tin ngắn 24 giờ (Ảnh hoặc Video dọc 9:16) lên Facebook Page Story thông qua Meta Graph API (Publish Facebook Story). Kiểm tra điều kiện phê duyệt (BR-54), kích thước khung hình dọc và thời lượng video hợp lệ trước khi đẩy qua hàng đợi xuất bản (BR-55, BR-56, BR-55).

---

## UC-116 — Publish Facebook Reels

- **Related FR:** `3.8.10` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56`
- **System Messages:** `MSG07, MSG36, MSG52, MSG53, MSG54`
- **Specification & Flow:** Xuất bản video ngắn định dạng dọc (Reels) kèm mô tả và âm thanh lên Facebook Page thông qua quy trình tải lên 2 pha của Meta Reels Publishing API (Publish Facebook Reels). Kiểm tra thời lượng video (3–90 giây), tỷ lệ 9:16 (BR-55) và cập nhật trạng thái xuất bản qua RabbitMQ worker (BR-56, BR-55).

---

## UC-117 — Publish Instagram Post

- **Related FR:** `3.8.11` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56, BR-57`
- **System Messages:** `MSG02, MSG07, MSG36, MSG52, MSG53, MSG54`
- **Specification & Flow:** Xuất bản bài đăng ảnh đơn hoặc bộ ảnh xoay vòng (Carousel) kèm caption và hashtag lên tài khoản Instagram Business qua Instagram Graph API (Publish Instagram Post). Thực hiện quy trình khởi tạo Media Container và Publish Container chuẩn của Meta, kiểm tra trạng thái duyệt (BR-54) và quy chuẩn ảnh (BR-55, BR-55).

---

## UC-118 — Publish Instagram Reels

- **Related FR:** `3.8.12` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56`
- **System Messages:** `MSG07, MSG36, MSG52, MSG53, MSG54`
- **Specification & Flow:** Xuất bản video ngắn lên Instagram Reels kèm ảnh bìa (cover frame) và caption thông qua Instagram Graph API (Publish Instagram Reels). Kiểm tra định dạng MP4/MOV, tỷ lệ khung hình dọc và theo dõi tiến trình xử lý video container cho đến khi hoàn tất xuất bản (BR-55, BR-56, BR-55).

---

## UC-119 — Publish Instagram Story

- **Related FR:** `3.8.13` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56`
- **System Messages:** `MSG02, MSG07, MSG36, MSG52, MSG53, MSG54`
- **Specification & Flow:** Xuất bản hình ảnh hoặc video ngắn 24 giờ lên Instagram Business Story qua Instagram Graph API (Publish Instagram Story). Kiểm tra bài đăng đã được duyệt (BR-54) và tuân thủ chuẩn tỷ lệ hiển thị toàn màn hình 9:16 của Instagram Story (BR-55, BR-56, BR-55).

---

## UC-120 — Publish TikTok Video

- **Related FR:** `3.8.14` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56`
- **System Messages:** `MSG02, MSG07, MSG36, MSG52, MSG53, MSG54`
- **Specification & Flow:** Xuất bản video ngắn lên tài khoản TikTok thông qua TikTok Content Posting API v2 (Publish TikTok Video). Hỗ trợ cấu hình tiêu đề/caption, quyền riêng tư (Public/Friends/Private), cho phép Duet/Stitch/Comment; thực hiện truyền tải video theo từng phân đoạn (chunked upload) và ghi nhận mã bài đăng TikTok (BR-55, BR-56, BR-55).

---

## UC-121 — Publish Threads Post

- **Related FR:** `3.8.15` (3.8 Publishing & Social)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-22, BR-34, BR-42, BR-53, BR-54, BR-55, BR-56`
- **System Messages:** `MSG02, MSG07, MSG36, MSG52, MSG53, MSG54`
- **Specification & Flow:** Xuất bản bài viết văn bản (tối đa 500 ký tự) kèm hình ảnh hoặc video lên mạng xã hội Threads thông qua Threads Publishing API (Publish Threads Post). Kiểm tra giới hạn ký tự, định dạng tệp đính kèm (BR-55) và ghi nhận đường dẫn bài đăng Threads sau khi xuất bản thành công (BR-56, BR-55).

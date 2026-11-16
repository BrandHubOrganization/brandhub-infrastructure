# 09 — Quản trị Hệ thống Nền tảng (Admin Functions)

> [<< 08 - Subscription & Billing](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/08-subscription-billing.md) | [Overview](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/00-overview.md) | [Tiếp: 10 - Roles & Permissions Matrix >>](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/10-roles-permissions-matrix.md)
>
> **Phạm vi FR chuẩn**: **Mục `3.10 Admin Functions` — 14 FR (`3.10.1` – `3.10.14`)** | `UC-128` – `UC-141` (cùng `3.7.13 Crawl Schedule Config` thuộc quyền `Admin`).
> Toàn bộ 14 chức năng trong miền này chỉ dành riêng cho vai trò chuẩn **`Admin`** (`ADMIN`).

---

## 1. Bảng Tổng hợp 14 Yêu cầu Chức năng Chuẩn (`3.10.1` – `3.10.14`)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (Atomic CRUD FR) | Actors / Roles Chuẩn | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :--- |
| **`3.10.1`** | `UC-128` | **View User List** | `Admin` | Xem danh sách toàn bộ tài khoản người dùng trên nền tảng (tìm kiếm theo tên/email, lọc theo trạng thái hoạt động, vai trò, mức độ vi phạm và phân trang chuẩn). |
| **`3.10.2`** | `UC-129` | **View User Detail** | `Admin` | Xem hồ sơ chi tiết của một người dùng, danh sách các `Agency`/`Workspace` họ tham gia, lịch sử hoạt động và lịch sử vi phạm (hỗ trợ mở bằng 3 chế độ `Side Peek`, `Center Modal`, `Full Page`). |
| **`3.10.3`** | `UC-130` | **Update User Status** | `Admin` | Khóa (`BAN` / `LOCK`) hoặc mở khóa (`ACTIVATE`) tài khoản người dùng; khi bị khóa, thu hồi ngay lập tức các phiên đăng nhập JWT đang hoạt động của tài khoản đó. |
| **`3.10.4`** | `UC-131` | **Content Moderation Queue** | `Admin` | Xem và xử lý Hàng đợi Kiểm duyệt Nội dung (`Content Moderation Queue`): duyệt cho phép (`APPROVE`), gỡ bỏ/từ chối (`REJECT`) các bài viết/bình luận bị hệ thống AI gắn cờ vi phạm tiêu chuẩn cộng đồng. |
| **`3.10.5`** | `UC-132` | **Update User Violation Status** | `Admin` | Cập nhật mức độ cảnh cáo / điểm vi phạm (`violationStatus` / `strikeCount`) của người dùng sau khi xác minh nội dung vi phạm tại hàng đợi kiểm duyệt. |
| **`3.10.6`** | `UC-133` | **View Subscription Plan List** | `Admin` | Xem danh sách cấu hình các gói cước dịch vụ (`Basic`, `Plus`/`Pro`, `Enterprise`) trên toàn hệ thống cùng số lượng thuê bao đang đăng ký mỗi gói. |
| **`3.10.7`** | `UC-134` | **Create Subscription Plan** | `Admin` | Tạo mới một gói cước dịch vụ (Mã gói, Tên hiển thị `vi`/`en`, Giá tiền VND, Chu kỳ tháng/năm, Định mức AI Credit cấp định kỳ, Định mức gửi Email Newsletter và danh sách tính năng). |
| **`3.10.8`** | `UC-135` | **Update Subscription Plan** | `Admin` | Cập nhật đơn giá, định mức quyền lợi hoặc mô tả của gói cước (áp dụng cho các đơn đăng ký/gia hạn mới; bảo toàn quyền lợi đã chốt của chu kỳ đang chạy). |
| **`3.10.9`** | `UC-136` | **Delete Subscription Plan** | `Admin` | Xóa hoặc ngừng cung cấp (`Archive`/`Deactivate`) một gói cước khi không còn thuê bao đang hoạt động trên gói đó. |
| **`3.10.10`** | `UC-137` | **View AI Credit Price List** | `Admin` | Xem bảng giá AI Credit hiện hành cho các nhóm tác vụ AI tính phí (`CONTENT_GENERATE`, `AMBASSADOR_GENERATE`, `COMMERCIAL_IMAGE`, `VIDEO_GENERATE`) cùng lịch sử phiên bản giá (`rate_version`). |
| **`3.10.11`** | `UC-138` | **Update AI Credit Price** | `Admin` | Cập nhật số lượng AI Credit tiêu tốn (`unit_credits`) hoặc bật/tắt trạng thái kích hoạt của từng tác vụ AI; tự động tạo bản chụp phiên bản giá mới để không ảnh hưởng các giao dịch đang tạm giữ (`HOLD`). |
| **`3.10.12`** | `UC-139` | **Import AI Credit Price CSV** | `Admin` | Nhập hàng loạt bảng cấu hình giá AI Credit từ tệp CSV chuẩn (kiểm tra định dạng cột, mã tác vụ hợp lệ, số credit nguyên không âm và áp dụng nguyên tử). |
| **`3.10.13`** | `UC-140` | **View Revenue Dashboard** | `Admin` | Xem Bảng điều khiển Doanh thu & Tài chính toàn hệ thống: tổng doanh thu SePay theo khoảng thời gian, cơ cấu doanh thu theo gói cước, thống kê hóa đơn (`PAID`, `PENDING`, `EXPIRED`) và lượng tiêu thụ AI Credit. |
| **`3.10.14`** | `UC-141` | **Export Report File PDF** | `Admin` | Xuất báo cáo tổng hợp doanh thu, hóa đơn và vận hành hệ thống ra tệp **PDF** chính thức để lưu trữ và đối soát kế toán. |

---

## 2. Đặc tả Nghiệp vụ Chi tiết Các Phân hệ Quản trị (`Admin Portal`)

### 2.1. Quản trị Người dùng & Kiểm duyệt An toàn Nội dung (`3.10.1` – `3.10.5`)
1. **Quản lý Tài khoản (`3.10.1`, `3.10.2`, `3.10.3`)**:
   - Tại `/admin/users`, `Admin` tra cứu người dùng, mở xem chi tiết (`3.10.2`) bằng 1 trong 3 chế độ **Notion Peek (`Side Peek`, `Center Modal`, `Full Page`)**.
   - `Admin` không thể tự khóa (`BAN`) chính tài khoản `Admin` đang đăng nhập của mình.
   - Khi một tài khoản bị chuyển sang trạng thái khóa (`3.10.3`), hệ thống bắt buộc ghi nhận lý do khóa, hủy hiệu lực `refreshToken` trên Redis và chặn mọi API request tiếp theo của tài khoản đó.
2. **Hàng đợi Kiểm duyệt Nội dung & Xử lý Vi phạm (`3.10.4` & `3.10.5`)**:
   - Khi người dùng tạo bài viết/caption (`3.6.33 Check Compliance Content`), bộ lọc an toàn AI kiểm tra các dấu hiệu ngôn từ kích động, bạo lực, lừa đảo hoặc vi phạm tiêu chuẩn cộng đồng và đưa các nội dung nghi vấn vào **`Content Moderation Queue (3.10.4)`**.
   - Tại `/admin/moderation`, `Admin` xem nội dung bị gắn cờ, ngữ cảnh bài viết và quyết định:
     - **Chấp thuận (`Approve`)**: Gỡ cờ cảnh báo để bài viết tiếp tục quy trình bình thường.
     - **Từ chối / Gỡ bỏ (`Reject`)** kèm cập nhật trạng thái vi phạm của người dùng (**`3.10.5 Update User Violation Status`**): Tăng mức cảnh cáo (`Warning` → `Restricted` → `Suspended`/`Banned`).

### 2.2. Quản trị Gói Cước Dịch vụ (`3.10.6` – `3.10.9`)
- Tại `/admin/subscriptions`, `Admin` quản lý danh mục các gói cước (`Basic`, `Plus`, `Enterprise`).
- **Quy tắc bảo toàn thuê bao đang hoạt động**:
  - Khi `Admin` cập nhật giá hoặc định mức của gói (`3.10.8`), các `Agency` đang trong chu kỳ đã thanh toán vẫn giữ nguyên quyền lợi đã cấp (`BillingPeriodBenefits`); cấu hình mới áp dụng cho các đơn nâng cấp/gia hạn tiếp theo.
  - Khi `Admin` xóa gói (`3.10.9`), nếu gói đang có `Agency` đăng ký hoạt động thì chỉ chuyển gói sang trạng thái ngừng bán mới (`isActive = false`) thay vì xóa vật lý để bảo toàn khóa ngoại lịch sử hóa đơn.

### 2.3. Quản trị Bảng giá AI Credit (`3.10.10` – `3.10.12`)
- Tại `/admin/credit-pricing`, `Admin` kiểm soát chi phí credit cho **4 nhóm tác vụ tính phí duy nhất**:
  1. `CONTENT_GENERATE`
  2. `AMBASSADOR_GENERATE`
  3. `COMMERCIAL_IMAGE`
  4. `VIDEO_GENERATE`
- Các tác vụ miễn phí cố định (`CAPTION_VARIANTS`, `HASHTAG_GENERATE`, `CHARACTER_SHEET`) luôn giữ `unit_credits = 0`.
- Hỗ trợ cập nhật trực tiếp từng dòng (`3.10.11`) hoặc tải lên tệp CSV bảng giá (`3.10.12`) với kiểm tra hợp lệ toàn phần trước khi lưu.

### 2.4. Bảng điều khiển Doanh thu SePay, Xuất Báo cáo PDF & Giám sát Hệ thống (`3.10.13`, `3.10.14`, `3.7.13`)
- **Doanh thu & Hóa đơn (`3.10.13` & `3.10.14`)**:
  - Tại `/admin/revenue` và `/admin/invoices`, `Admin` theo dõi biểu đồ doanh thu thực thu từ cổng **SePay / PayOS (VietQR)** theo ngày/tháng/quý, xem chi tiết từng hóa đơn và bấm **Xuất báo cáo PDF (`3.10.14`)**.
- **Quản lý Đường ống Thu thập Xu hướng & Sức khỏe Hệ thống (`3.7.13` & `/admin/crawler`, `/admin/health`)**:
  - Cấu hình nguồn thu thập xu hướng đa nền tảng, đặt lịch cron (`3.7.13`), kích hoạt chạy đường ống xu hướng ngay lập tức (`Run Pipeline Now`) và giám sát trạng thái các dịch vụ (`business-service`, `ai-service`, `publisher-service`, PostgreSQL, MongoDB, Redis, Neo4j, RabbitMQ).

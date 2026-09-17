# 02 — Authentication & Profile

> [<< Về Overview](00-overview.md)

## 1. Authentication (FR 3.2)

### 3.2.1 — Sign Up
- Đăng ký bằng email, **verify OTP** để xác thực email là thật.
- **Check lỗi viết hoa chữ đầu email**: `User@gmail.com` và `user@gmail.com` phải được nhận diện là **cùng 1 tài khoản** — không tạo account trùng do khác hoa/thường ở phần local-part email.
- Role: GUEST (chưa đăng nhập thực hiện được).

### 3.2.2 — Sign In With Email
- Đăng nhập bằng email/password, **không cần gửi OTP lại** (khác với Sign Up).
- Role: GUEST.

### 3.2.3 — Sign In with Google OAuth
- **Ghi chú hiện trạng**: login hiện tại theo báo cáo **vẫn chưa chạy được** — cần coi lại toàn bộ flow (không chỉ là feature mới, là bug fix trên flow cũ).
- Role: GUEST.

### 3.2.4 — Reset Password
- Khi user quên mật khẩu: hệ thống gửi **link đổi mật khẩu HOẶC mã OTP** đến email để xác nhận trước khi cho đổi mật khẩu mới.
- Role: USER.

### 3.2.5 — Change Password
- Đổi mật khẩu khi đã đăng nhập.
- **Bắt buộc có bước confirm lại** trước khi áp dụng đổi mật khẩu (ví dụ nhập lại mật khẩu mới 2 lần, hoặc confirm modal).
- Role: USER.

### 3.2.6 — OTP Verification
- Màn hình chuyên dụng để user điền mã OTP (dùng chung cho Sign Up, Reset Password, 2FA).
- Role: USER.

### 3.2.7 — Two-Factor Authentication (2FA, TOTP)
- Hiện trạng: đang có 2 cách xác thực song song — scan QR để add vào app Authenticator, VÀ nhập mã OTP.
- **Thay đổi**: bỏ tính năng copy secret key và bỏ backup codes — chỉ giữ scan QR + nhập OTP, đơn giản hóa để giảm bề mặt tấn công và giảm phức tạp UI.
- Role: USER.

### 3.2.8 — Sign Out
- Đăng xuất, nhưng **phải lưu lại thông tin "last used platform"** (nền tảng đăng nhập lần cuối) để user đăng nhập lại tiện hơn (ví dụ nhớ đã dùng Google OAuth lần trước, gợi ý nút đó nổi bật hơn khi quay lại).
- Role: USER.

### 3.2.9 — Deactivate Account
- **Soft delete** tài khoản — không xóa cứng dữ liệu.
- Role: USER.

## 2. Profile (FR 3.3)

### 3.3.1 — View User Profile
- **[CONFIRMED 2026-09-17]** Field chuẩn cho User Profile — thiết kế theo nhu cầu thực tế của người làm truyền thông (Agency member):
  - Họ tên đầy đủ (`fullName`)
  - Avatar (`avatarUrl`)
  - Email (`email`) — cố định, không sửa được ở đây (đổi email là flow riêng, nếu có)
  - Số điện thoại (`phone`)
  - Chức danh/vai trò chuyên môn (`professionalTitle` — ví dụ: Content Creator, Photographer, Account Manager — khác với `role` hệ thống ở Workspace, đây chỉ là label mô tả nghề nghiệp)
  - Bio ngắn (`bio`)
  - Portfolio/link mẫu việc đã làm (`portfolioUrl`, có thể nhiều link)
  - Ngôn ngữ làm việc (`workingLanguage`)
  - Timezone cá nhân (`timezone` — khác với Timezone Configuration của Workspace ở FR 3.4.13, đây là timezone hiển thị UI cho riêng user)
  - Ngày tham gia hệ thống (`joinedAt`)
- Role: USER.

### 3.3.2 — Update User Profile
- Đổi tên FR: **gộp thành 1 FR duy nhất là "Update Profile"** (không tách View riêng khỏi Update ở tầng đặt tên FR, theo ghi chú gốc "Chuyển thành 1 FR là Update Profile").
- Role: USER.

### 3.3.3 — View Client Profile
- Khi 1 User đóng vai trò **Client** tham gia vào Workspace của Agency khác (không phải Agency của chính họ), hệ thống có 1 **Client Profile riêng biệt** với User Profile thông thường.
- Mục đích: khi Client đó tham gia workspace của Agency khác (dự án khác), **không cần cập nhật lại thông tin từ đầu** — chỉ cần dùng lại Client Profile đã có.
- Đây chính là cơ chế hỗ trợ "Client là actor ngoài, tái sử dụng profile xuyên Agency/Workspace" đã nêu ở [01-organization-structure.md](01-organization-structure.md) mục 5.
- **[CONFIRMED 2026-09-17]** `ClientProfile` là **bảng tách riêng hoàn toàn khỏi `User`** (không dùng chung bảng User + thêm cột) — vì **1 User có thể có nhiều Client Profile khác nhau** (ví dụ: cùng 1 người vừa là Client của Agency A với thông tin công ty X, vừa là Client của Agency B với thông tin công ty Y — 2 profile độc lập, không gộp chung). Xem chi tiết field ở [11-data-entities-glossary.md](11-data-entities-glossary.md).
- Role: USER (với vai trò Client).

### 3.3.4 — Update Client Profile
- Cập nhật Client Profile, nhưng **KHÔNG được update email** — email Client cố định, có thể vì email là khóa liên kết định danh Client xuyên các Agency khác nhau, đổi sẽ phá vỡ liên kết đó.
- Role: USER (với vai trò Client).

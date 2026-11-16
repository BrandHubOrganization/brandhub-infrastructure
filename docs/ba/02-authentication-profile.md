# 02 — Xác thực, Phân quyền & Hồ sơ Người dùng / Khách hàng (Authentication, Authorization & Profiles)

> [<< 01 - Organization Structure](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/01-organization-structure.md) | [Overview](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/00-overview.md) | [Tiếp: 03 - Agency & Workspace >>](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/03-agency-workspace-management.md)
>
> **Phạm vi FR chuẩn**:
> - **Mục `3.2 Authentication & Authorization`**: **9 FR (`3.2.1` – `3.2.9`)** | `UC-001` – `UC-009`
> - **Mục `3.3 User & Client Profile`**: **4 FR (`3.3.1` – `3.3.4`)** | `UC-010` – `UC-013`

---

## 1. Bảng Tổng hợp Yêu cầu Chức năng Chuẩn (`3.2` & `3.3` — 13 FRs)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (Atomic CRUD FR) | Actors / Roles Chuẩn | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :--- |
| **`3.2.1`** | `UC-001` | **Register Account** | `Guest` | Đăng ký tài khoản mới bằng Email, Mật khẩu và Họ tên; gửi mã OTP xác thực qua email. |
| **`3.2.2`** | `UC-002` | **Login** | `Guest` | Đăng nhập vào hệ thống bằng Email & Mật khẩu; cấp cặp JWT (`accessToken` + `refreshToken`). |
| **`3.2.3`** | `UC-003` | **Social Login (Google)** | `Guest` | Đăng nhập hoặc đăng ký nhanh một chạm thông qua tài khoản Google OAuth 2.0. |
| **`3.2.4`** | `UC-004` | **Verify Email** | `Guest`, `Owner`, `Manager`, `Creator`, `Client` | Xác thực địa chỉ email bằng mã OTP 6 chữ số để kích hoạt tài khoản (`status = ACTIVE`). |
| **`3.2.5`** | `UC-005` | **Forgot Password** | `Guest` | Yêu cầu đặt lại mật khẩu khi quên; hệ thống gửi mã OTP đặt lại mật khẩu về email đã đăng ký. |
| **`3.2.6`** | `UC-006` | **Change Password** | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | Đổi mật khẩu khi đã đăng nhập (yêu cầu nhập đúng mật khẩu hiện tại) hoặc đặt lại mật khẩu mới sau bước xác thực OTP. |
| **`3.2.7`** | `UC-007` | **Setup Two-Factor Authentication** | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | Bật/tắt và cấu hình xác thực 2 yếu tố (2FA TOTP qua ứng dụng Google Authenticator / Authy kèm mã khôi phục dự phòng). |
| **`3.2.8`** | `UC-008` | **Logout** | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | Đăng xuất khỏi phiên làm việc hiện tại; thu hồi `refreshToken` trên Redis/DB và xóa trạng thái phiên trên trình duyệt. |
| **`3.2.9`** | `UC-009` | **Delete Account** | `Owner`, `Manager`, `Creator`, `Client` | Yêu cầu xóa/vô hiệu hóa tài khoản cá nhân (cần xác nhận mật khẩu và kiểm tra không còn giữ quyền `Owner` duy nhất của Agency đang hoạt động). |
| **`3.3.1`** | `UC-010` | **View User Profile** | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | Xem thông tin hồ sơ cá nhân của bản thân (Họ tên, Email, Ảnh đại diện, Số điện thoại, Chức danh, Múi giờ, Ngôn ngữ làm việc `vi`/`en`, trạng thái 2FA). |
| **`3.3.2`** | `UC-011` | **Update User Profile** | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | Cập nhật thông tin hồ sơ cá nhân, tải lên ảnh đại diện mới và đổi ngôn ngữ giao diện/email (`workingLanguage`). |
| **`3.3.3`** | `UC-012` | **View Client Profile** | `Owner`, `Manager`, `Creator`, `Client` | Xem hồ sơ thương hiệu của Khách hàng (`ClientProfile`) gắn với Workspace (Tên thương hiệu, Logo, Ngành hàng, Website, Bộ nhận diện, Thông tin liên hệ). |
| **`3.3.4`** | `UC-013` | **Update Client Profile** | `Owner`, `Manager`, `Client` | Cập nhật thông tin hồ sơ thương hiệu Khách hàng (`ClientProfile`), tải lên logo thương hiệu (dùng cho xuất file PDF/DOCX và tên hiển thị người gửi Newsletter). |

---

## 2. Đặc tả Chi tiết Nhóm `3.2 Authentication & Authorization`

### 2.1. `3.2.1 Register Account` & `3.2.4 Verify Email`
- **Actor**: `Guest` (đăng ký) → xác thực OTP để kích hoạt tài khoản.
- **Quy tắc kiểm tra đầu vào (Validation Rules)**:
  - `email`: Định dạng email hợp lệ, chuẩn hóa chữ thường (`lowercase`), duy nhất trong bảng `users`. Nếu đã tồn tại tài khoản `ACTIVE` → báo lỗi email đã được sử dụng.
  - `password`: Tối thiểu 8 ký tự, bao gồm chữ hoa, chữ thường, chữ số và ký tự đặc biệt; băm bằng `BCryptPasswordEncoder` trước khi lưu.
  - `displayName` / `fullName`: Bắt buộc, từ 2 đến 100 ký tự.
- **Luồng xử lý chuẩn**:
  1. Tạo bản ghi `User` ở trạng thái chờ xác thực email (`emailVerified = false`).
  2. Sinh mã OTP 6 chữ số có thời hạn hiệu lực (TTL 5–10 phút lưu trên Redis) và gửi email qua `MailService` theo ngôn ngữ người dùng chọn (`vi` hoặc `en`).
  3. Tại màn hình `Verify Email (3.2.4)`, người dùng nhập mã OTP:
     - Nếu khớp và còn hạn: cập nhật `emailVerified = true`, `status = ACTIVE`, cấp JWT để đăng nhập ngay và hiển thị màn hình chọn hướng bắt đầu (**Bắt đầu với Không gian Cá nhân — Personal Studio** hoặc **Thiết lập Công ty — Agency B2B**).
     - Hỗ trợ gửi lại OTP (`Resend OTP`) có giới hạn tần suất (cooldown 60 giây) để chống spam.

### 2.2. `3.2.2 Login` & `3.2.3 Social Login (Google)`
- **Actor**: `Guest`.
- **Luồng `3.2.2 Login`**:
  1. Kiểm tra tồn tại `email` và đối chiếu `password` qua BCrypt.
  2. Kiểm tra trạng thái tài khoản:
     - Nếu `status == BANNED` / `LOCKED` (do `Admin` khóa tại FR `3.10.3` / `3.10.5`) → từ chối đăng nhập kèm thông báo tài khoản bị khóa.
     - Nếu `emailVerified == false` → chuyển hướng sang bước `3.2.4 Verify Email`.
  3. Nếu tài khoản đã bật 2FA (`twoFactorEnabled == true`) → trả về cờ `requiresTwoFactor = true` và `tempAuthToken` để người dùng nhập mã TOTP 6 số từ ứng dụng xác thực.
  4. Khi hợp lệ hoàn toàn → cấp `accessToken` + `refreshToken` và điều hướng theo vai trò:
     - Nếu là `Admin` (`systemRole == ADMIN`) → điều hướng vào `/admin/dashboard`.
     - Nếu là `Client` → điều hướng vào `/workspaces/:id/portal` (Cổng Khách hàng).
     - Nếu là `Owner`, `Manager`, `Creator` → điều hướng vào không gian làm việc gần nhất hoặc trang Hub `/agency` (nơi có sẵn nút 1 chạm vào **Personal Studio**).
- **Luồng `3.2.3 Social Login (Google)`**:
  - Xác thực `idToken` / OAuth code với Google.
  - Nếu email chưa tồn tại trong hệ thống: tự động tạo tài khoản `User` mới với `emailVerified = true`, `authProvider = GOOGLE`, lấy tên và ảnh đại diện từ Google.
  - Nếu email đã tồn tại và đang `ACTIVE`: liên kết tài khoản Google và cấp phiên đăng nhập ngay.

### 2.3. `3.2.5 Forgot Password` & `3.2.6 Change Password`
- **`3.2.5 Forgot Password` (`Guest`)**:
  - Người dùng nhập `email` đã đăng ký → hệ thống gửi mã OTP khôi phục mật khẩu qua email → người dùng nhập OTP kèm `newPassword` + `confirmPassword` → cập nhật mật khẩu mới và thu hồi toàn bộ các phiên đăng nhập cũ của tài khoản đó.
- **`3.2.6 Change Password` (`Owner`, `Manager`, `Creator`, `Client`, `Admin`)**:
  - Người dùng đang đăng nhập vào trang Cài đặt bảo mật (`/profile`), nhập `currentPassword`, `newPassword`, `confirmPassword`.
  - Mật khẩu mới không được trùng với mật khẩu hiện tại.

### 2.4. `3.2.7 Setup Two-Factor Authentication (2FA)`
- **Actors**: `Owner`, `Manager`, `Creator`, `Client`, `Admin`.
- **Luồng bật 2FA**:
  1. Hệ thống sinh khóa bí mật TOTP (`secretKey`) và mã QR chuẩn `otpauth://totp/BrandHub:<email>`.
  2. Người dùng quét mã QR bằng Google Authenticator / Authy và nhập mã xác nhận 6 số đầu tiên.
  3. Hệ thống kích hoạt `twoFactorEnabled = true` và cung cấp danh sách mã khôi phục dự phòng (`recoveryCodes`).
- **Luồng tắt 2FA**: Yêu cầu xác nhận mật khẩu hiện tại hoặc mã OTP hợp lệ.

### 2.5. `3.2.8 Logout` & `3.2.9 Delete Account`
- **`3.2.8 Logout`**: Thu hồi `refreshToken` hiện tại ở phía Server và xóa token lưu ở phía Client, đưa người dùng về `/login`.
- **`3.2.9 Delete Account`**:
  - Cho phép `Owner`, `Manager`, `Creator`, `Client` yêu cầu xóa/đóng tài khoản của mình.
  - **Ràng buộc toàn vẹn**: Nếu người dùng đang là `Owner` của một `Agency` B2B có các thành viên khác đang hoạt động, hệ thống yêu cầu chuyển quyền hoặc đóng Agency trước khi xóa tài khoản. Thực hiện soft-delete (`deletedAt = now()`, `status = DELETED`) để giữ toàn vẹn lịch sử kiểm toán (`audit log`) và hóa đơn tài chính.

---

## 3. Đặc tả Chi tiết Nhóm `3.3 User & Client Profile`

### 3.1. Hồ sơ Người dùng Cá nhân (`3.3.1 View User Profile` & `3.3.2 Update User Profile`)
- **Actors**: `Owner`, `Manager`, `Creator`, `Client`, `Admin`.
- **Các trường dữ liệu quản lý**:
  - `displayName` / `fullName` (Họ và tên hiển thị)
  - `avatarUrl` (Ảnh đại diện tải lên kho lưu trữ đối tượng S3/MinIO)
  - `phone` (Số điện thoại liên hệ)
  - `jobTitle` / `bio` (Chức danh / Giới thiệu ngắn)
  - `timezone` (Múi giờ mặc định, VD: `Asia/Ho_Chi_Minh`)
  - `workingLanguage` (`vi` hoặc `en` — quyết định ngôn ngữ giao diện và ngôn ngữ của các email hệ thống gửi tới người dùng đó).
- **Quy tắc bảo mật**: Trường `email` là định danh đăng nhập nên hiển thị chỉ-đọc (read-only) trên form cập nhật hồ sơ thường.

### 3.2. Hồ sơ Thương hiệu Khách hàng (`3.3.3 View Client Profile` & `3.3.4 Update Client Profile`)
- **Actors**:
  - Xem (`3.3.3`): `Owner`, `Manager`, `Creator`, `Client` trong Workspace.
  - Cập nhật (`3.3.4`): `Owner`, `Manager`, `Client` trong Workspace.
- **Các trường dữ liệu quản lý (`client_profiles`)**:
  - `displayName` / `brandName` (Tên thương hiệu hiển thị — đồng thời được dùng làm `From Name` khi gửi bản tin `EMAIL_NEWSLETTER` của thương hiệu đó).
  - `logoUrl` (Logo thương hiệu lưu trên bucket nội bộ `image/client-logos/<profileId>/...` — được in lên đầu trang khi xuất file PDF/DOCX của công việc hoặc gói dịch vụ).
  - `industry` (Ngành hàng / Lĩnh vực hoạt động).
  - `website`, `contactEmail`, `contactPhone`, `address`.
  - `brandGuidelines` / `toneOfVoice` (Mô tả giọng văn và định hướng thương hiệu, phục vụ ngữ cảnh cho AI sinh nội dung).
- **Hành vi trong Chế độ `PERSONAL` (`workspaceMode = "PERSONAL"`)**:
  - Trong Workspace `PERSONAL`, menu `Hồ sơ Khách hàng (/client-profile)` được ẩn khỏi Sidebar để giao diện gọn nhẹ; các thông tin tên dự án/thương hiệu cá nhân (`brandName`, `industry`, `timezoneConfig`) được chỉnh sửa trực tiếp ngay trong trang **Cài đặt Không gian (`/workspaces/:id/settings`)**. Nếu người dùng nâng cấp Workspace sang chế độ `"AGENCY"`, trang `Hồ sơ Khách hàng` sẽ tự động hiển thị trở lại.

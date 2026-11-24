# UC 01 — Authentication & User/Client Profile (`UC-001` – `UC-013`)

> [← UC Master Index](./README.md) | [Domain BA Spec: 02-authentication-profile.md](../02-authentication-profile.md) | [02-agency-workspace.md >>](./02-agency-workspace.md)
>
> Đồng bộ chuẩn xác 1-đối-1 với `Các FR của hệ thống - Feature_Function Requirement.csv` và `AGENTS.md`. Chỉ sử dụng **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)**.

---

## 1. Bảng Tổng Hợp Use Cases (13 UCs)

| UC ID | Use Case Title | Canonical Actor(s) | Related FR | Business Rules |
| :-: | :--- | :--- | :-: | :--- |
| `UC-001` | Sign Up | `Guest` | `3.2.1` | `BR-01, BR-02, BR-03, BR-04` |
| `UC-002` | Sign In with Email | `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.2.2` | `BR-01, BR-02, BR-05, BR-06, BR-09` |
| `UC-003` | Sign In with Google OAuth | `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.2.3` | `BR-01, BR-05, BR-07` |
| `UC-004` | Reset Password | `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.2.4` | `BR-01, BR-02, BR-03, BR-04, BR-08` |
| `UC-005` | Change Password | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.2.5` | `BR-02, BR-08` |
| `UC-006` | OTP Verification | `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.2.6` | `BR-03, BR-04, BR-05` |
| `UC-007` | Two-Factor Authentication (2FA, TOTP) | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.2.7` | `BR-05, BR-09` |
| `UC-008` | Logout | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.2.8` | `BR-05` |
| `UC-009` | Delete Account | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.2.9` | `BR-10, BR-16` |
| `UC-010` | View User Profile | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.3.1` | `BR-05, BR-11` |
| `UC-011` | Update User Profile | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.3.2` | `BR-11, BR-12` |
| `UC-012` | View Client Profile | `Owner`, `Manager`, `Client` | `3.3.3` | `BR-13, BR-14` |
| `UC-013` | Update Client Profile | `Owner`, `Manager`, `Client` | `3.3.4` | `BR-12, BR-13, BR-14` |

---

## UC-001 — Sign Up

- **Related FR:** `3.2.1` (3.2 Authentication & Authorization)
- **Canonical Actor(s):** `Guest`
- **Business Rules:** `BR-01, BR-02, BR-03, BR-04`
- **System Messages:** `MSG02, MSG04, MSG05, MSG06, MSG08, MSG10`
- **Specification & Flow:** Đăng ký tài khoản mới bằng Họ tên, Email và Mật khẩu trên màn hình Register (/register). Hệ thống chuẩn hóa email về chữ thường (lowercase) để kiểm tra trùng lặp không phân biệt hoa/thường (BR-01), kiểm tra độ mạnh mật khẩu (tối thiểu 8 ký tự và có ít nhất 1 chữ số) và băm mật khẩu một chiều bằng bcrypt (BR-02). Tài khoản mới khởi tạo ở trạng thái PENDING_VERIFICATION, hệ thống sinh mã OTP 6 chữ số có hiệu lực 10 phút (BR-03) gửi qua email và chuyển hướng sang màn hình xác thực OTP (3.2.6).

---

## UC-002 — Sign In with Email

- **Related FR:** `3.2.2` (3.2 Authentication & Authorization)
- **Canonical Actor(s):** `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-01, BR-02, BR-05, BR-06, BR-09`
- **System Messages:** `MSG02, MSG04, MSG08, MSG09, MSG11, MSG12`
- **Specification & Flow:** Đăng nhập trực tiếp bằng Email và Mật khẩu trên màn hình Sign In (/login) mà không cần gửi lại OTP mỗi lần đăng nhập (trừ trường hợp tài khoản bật 2FA TOTP ở 3.2.7). Hệ thống chuẩn hóa email về chữ thường, đối chiếu mật khẩu băm (BR-02), kiểm tra trạng thái tài khoản đã xác thực email và không bị khóa/vô hiệu hóa (BR-05). Nếu hợp lệ, cấp cặp JWT Access Token (15 phút) và Refresh Token (30 ngày) để khởi tạo phiên làm việc.

---

## UC-003 — Sign In with Google OAuth

- **Related FR:** `3.2.3` (3.2 Authentication & Authorization)
- **Canonical Actor(s):** `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-01, BR-05, BR-07`
- **System Messages:** `MSG02, MSG03, MSG08, MSG12, MSG13`
- **Specification & Flow:** Đăng nhập hoặc đăng ký nhanh một chạm thông qua Google OAuth 2.0 (/login, /register). Hệ thống xác thực Google ID Token và cờ email_verified với máy chủ Google, chuẩn hóa email về chữ thường (BR-01). Nếu email đã tồn tại thì tự động liên kết/đăng nhập vào tài khoản hiện có; nếu chưa tồn tại thì tự động khởi tạo tài khoản ở trạng thái ACTIVE (lấy tên và ảnh đại diện từ Google), kiểm tra trạng thái không bị khóa (BR-05) và cấp JWT phiên làm việc.

---

## UC-004 — Reset Password

- **Related FR:** `3.2.4` (3.2 Authentication & Authorization)
- **Canonical Actor(s):** `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-01, BR-02, BR-03, BR-04, BR-08`
- **System Messages:** `MSG02, MSG04, MSG05, MSG06, MSG07, MSG08, MSG14, MSG15, MSG17`
- **Specification & Flow:** Khôi phục mật khẩu khi quên trên màn hình Forgot Password (/forgot-password, /reset-password). Người dùng nhập email đã đăng ký để nhận mã xác thực OTP 6 chữ số hoặc liên kết đặt lại mật khẩu có thời hạn 10 phút (BR-03, tối đa 5 lần nhập sai BR-04). Sau khi xác nhận mã hợp lệ và nhập mật khẩu mới kèm xác nhận mật khẩu thỏa chính sách bảo mật (BR-02), hệ thống cập nhật mật khẩu băm mới và thu hồi toàn bộ các phiên đăng nhập cũ (BR-08).

---

## UC-005 — Change Password

- **Related FR:** `3.2.5` (3.2 Authentication & Authorization)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-02, BR-08`
- **System Messages:** `MSG02, MSG05, MSG06, MSG07, MSG17, MSG18`
- **Specification & Flow:** Đổi mật khẩu chủ động khi đang đăng nhập tại phần Security Settings (/profile/security). Người dùng bắt buộc nhập Mật khẩu hiện tại, Mật khẩu mới (thỏa chuẩn bảo mật BR-02 và phải khác mật khẩu hiện tại BR-08) và Nhập lại mật khẩu xác nhận trùng khớp. Sau khi cập nhật mật khẩu băm mới, hệ thống thu hồi các Refresh Token của các thiết bị khác để bảo vệ tài khoản.

---

## UC-006 — OTP Verification

- **Related FR:** `3.2.6` (3.2 Authentication & Authorization)
- **Canonical Actor(s):** `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-03, BR-04, BR-05`
- **System Messages:** `MSG02, MSG15, MSG16`
- **Specification & Flow:** Xác thực mã OTP 6 chữ số gửi qua email trên màn hình Verify OTP (/verify-otp) để kích hoạt tài khoản mới đăng ký (3.2.1) hoặc xác nhận khôi phục mật khẩu (3.2.4). Mã OTP chỉ sử dụng một lần trong thời hạn 10 phút (BR-03). Nếu nhập sai quá 5 lần liên tiếp, hệ thống khóa mã OTP hiện tại và bắt buộc nhấn Resend OTP (có thời gian chờ cooldown 60 giây) để nhận mã mới (BR-04).

---

## UC-007 — Two-Factor Authentication (2FA, TOTP)

- **Related FR:** `3.2.7` (3.2 Authentication & Authorization)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-05, BR-09`
- **System Messages:** `MSG02, MSG07, MSG15, MSG19`
- **Specification & Flow:** Thiết lập và xác thực bảo mật 2 lớp (2FA TOTP chuẩn RFC 6238) bằng ứng dụng Authenticator (Google/Microsoft Authenticator). Hệ thống chỉ hiển thị mã QR để người dùng quét bằng ứng dụng Authenticator và ô nhập mã TOTP 6 chữ số (chu kỳ 30 giây, lệch tối đa ±1 bước) để kích hoạt hoặc xác nhận khi đăng nhập (BR-09); đã lược bỏ hoàn toàn phần hiển thị chuỗi Secret Key dạng văn bản copy và danh sách Backup Codes để tăng tính bảo mật và gọn giao diện.

---

## UC-008 — Logout

- **Related FR:** `3.2.8` (3.2 Authentication & Authorization)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-05`
- **System Messages:** `MSG02, MSG03, MSG07, MSG20`
- **Specification & Flow:** Đăng xuất khỏi phiên làm việc hiện tại từ thanh điều hướng chính. Hệ thống đưa JWT Access Token và Refresh Token hiện hành vào danh sách thu hồi trên Redis (Token Blacklist) để vô hiệu hóa phiên ngay lập tức, xóa thông tin xác thực nhạy cảm trên trình duyệt, nhưng giữ lại thông tin phương thức đăng nhập/nền tảng sử dụng gần nhất (last-used login hint & workspace preference) để người dùng đăng nhập lại thuận tiện hơn (BR-05).

---

## UC-009 — Delete Account

- **Related FR:** `3.2.9` (3.2 Authentication & Authorization)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-10, BR-16`
- **System Messages:** `MSG02, MSG07, MSG18, MSG20, MSG36`
- **Specification & Flow:** Xóa tài khoản cá nhân theo cơ chế xóa mềm (Soft Delete) tại màn hình Account Settings (/profile/security). Người dùng bắt buộc nhập lại mật khẩu xác nhận và đồng ý hộp thoại cảnh báo. Hệ thống kiểm tra tài khoản không còn giữ quyền Owner duy nhất của Agency đang hoạt động hoặc còn giao dịch thanh toán treo (BR-10), chuyển trạng thái tài khoản sang DELETED (lưu vết thời gian xóa mềm 30 ngày) và thu hồi toàn bộ phiên đăng nhập (BR-16).

---

## UC-010 — View User Profile

- **Related FR:** `3.3.1` (3.3 User & Client Profile)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-05, BR-11`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36`
- **Specification & Flow:** Xem thông tin hồ sơ cá nhân trên màn hình User Profile (/profile). Hiển thị đầy đủ các trường: Ảnh đại diện (Avatar), Họ và tên (Full Name), Địa chỉ Email (chỉ đọc), Số điện thoại, Chức danh/Vai trò hệ thống, Múi giờ, Ngôn ngữ giao diện (VI/EN), Ngày tham gia và trạng thái bảo mật 2FA.

---

## UC-011 — Update User Profile

- **Related FR:** `3.3.2` (3.3 User & Client Profile)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-11, BR-12`
- **System Messages:** `MSG02, MSG03, MSG07, MSG21, MSG22`
- **Specification & Flow:** Cập nhật thông tin hồ sơ cá nhân và tải lên ảnh đại diện mới trên màn hình User Profile (/profile). Cho phép chỉnh sửa Họ tên, Số điện thoại, Giới thiệu ngắn, Ngôn ngữ/Múi giờ và tải ảnh Avatar (định dạng JPG, PNG, WEBP, dung lượng tối đa 5 MB lưu trữ trên S3); trường Email đăng nhập chính bị khóa cố định không cho phép thay đổi để bảo toàn định danh tài khoản (BR-11).

---

## UC-012 — View Client Profile

- **Related FR:** `3.3.3` (3.3 User & Client Profile)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-13, BR-14`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36`
- **Specification & Flow:** Xem hồ sơ thương hiệu của Khách hàng (Client Profile) tại màn hình Client Profile (/client/profile). Mỗi tài khoản Client có một hồ sơ thương hiệu độc lập có thể tái sử dụng xuyên suốt nhiều Agency và Workspace khác nhau (gồm Tên công ty/thương hiệu, Logo, Lĩnh vực ngành nghề, Website, Mã số thuế, Địa chỉ, Thông tin liên hệ và Tông giọng thương hiệu) mà không cần phải nhập lại thông tin khi tham gia dự án mới (BR-13).

---

## UC-013 — Update Client Profile

- **Related FR:** `3.3.4` (3.3 User & Client Profile)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-12, BR-13, BR-14`
- **System Messages:** `MSG02, MSG03, MSG07, MSG21, MSG22`
- **Specification & Flow:** Cập nhật hồ sơ thương hiệu (Client Profile) gồm Tên thương hiệu, Logo, Ngành hàng, Website, Địa chỉ, Số điện thoại liên hệ và mô tả nhận diện thương hiệu (/client/profile). Không cho phép thay đổi địa chỉ Email định danh của tài khoản Client (BR-14); mọi cập nhật sẽ tự động đồng bộ hiển thị tới các Workspace mà Client đang tham gia (BR-13).

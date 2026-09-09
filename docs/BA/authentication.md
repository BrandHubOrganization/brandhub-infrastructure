# BA — Authentication

> Nguồn: `brandhub-business-service/src/main/java/com/brandhub/business/{controller/AuthController.java, controller/GoogleOAuthController.java, service/impl/AuthServiceImpl.java}`.
> Tài liệu mô tả đúng quy trình nghiệp vụ hiện đang triển khai trong code — không mô tả kế hoạch tương lai trừ khi ghi rõ `[PLANNED]`.

## Tổng quan luồng

```
Register (email+password) → Verify OTP (email) → Login
                                                     │
                    ┌────────────────────────────────┼──────────────────────┐
                    │                                 │                      │
              Login (email/phone)              Login (OAuth)          Forgot Password
                    │                                 │                      │
                    └──────────────┬──────────────────┘                Reset Password
                                   Access Token (15p) + Refresh Token (30 ngày, HttpOnly cookie)
                                   │
                    ┌──────────────┼──────────────┬─────────────┬──────────────┐
                Refresh Token   Change Password  Link Phone   Link/Unlink OAuth   Logout
                                       │
                          Set Password (OAuth-only) · Get Me
```

**Actor:** Guest (chưa đăng nhập), User (đã đăng nhập).

**Cơ chế token:** Access token JWT RS256, 15 phút, mang claim `sub` (userId), `role` (SystemRole: `ADMIN`/`USER`), `workspaceId` (workspace active đầu tiên của user, có thể null). Refresh token JWT RS256, 30 ngày, lưu cookie `refreshToken` (HttpOnly, Secure, SameSite=Strict, path `/api/v1/auth`) — không trả về trong response body. Token thu hồi qua Redis blacklist theo `jti`.

---

## Case 1 — Register (Đăng ký tài khoản email + password)

- **Actor:** Guest
- **Trigger:** Guest submit form đăng ký với email/password/họ tên tại `/register`.
- **Pre-condition:** Email chưa tồn tại trong hệ thống.
- **Main Flow:**
  1. Guest nhập email, password, họ tên.
  2. Hệ thống tạo `User` với `passwordHash` (BCrypt 12 rounds), sinh OTP 6 số, hạn 10 phút.
  3. Hệ thống gán `SystemRole = USER` mặc định (bảng `user_system_roles`).
  4. Hệ thống gửi email chứa OTP.
  5. Hệ thống trả về `userId` (chưa cấp token — phải verify OTP trước).
- **Post-condition:** User tồn tại ở trạng thái chưa xác thực email (`emailVerifiedAt = null`), chưa thể login.
- **Exception Flow:**
  - Email đã tồn tại → `409 EMAIL_ALREADY_EXISTS` (bắt qua `DataIntegrityViolationException` từ unique constraint DB, không phải pre-check — tránh race condition).
- **Business Rules:**
  - BR-01: Email chuẩn hóa lowercase + trim trước khi lưu và so khớp.
  - BR-02: Password hash bằng BCrypt, không bao giờ log plaintext.
  - BR-03: Mỗi user luôn có đúng 1 row `UserSystemRole`, mặc định `USER`.

---

## Case 2 — Verify OTP (Xác thực email sau đăng ký)

- **Actor:** Guest (đã register, chưa verify)
- **Trigger:** Guest nhập mã OTP 6 số nhận qua email.
- **Pre-condition:** User tồn tại, có `otpCode` + `otpExpiry` chưa hết hạn.
- **Main Flow:**
  1. Guest submit email + OTP.
  2. Hệ thống so khớp OTP, kiểm tra chưa hết hạn.
  3. Hệ thống set `emailVerifiedAt = now()`, xóa `otpCode`/`otpExpiry`.
- **Post-condition:** User có thể login.
- **Exception Flow:**
  - Email không tồn tại → `404 USER_NOT_FOUND`.
  - OTP sai, hết hạn, hoặc không còn OTP nào đang chờ → `400 OTP_INVALID`.
  - Email đã verify trước đó → trả về thành công (idempotent), không lỗi.
- **Business Rules:**
  - BR-04: OTP có hạn 10 phút kể từ lúc sinh (register hoặc resend).
  - BR-05: Verify OTP là idempotent — gọi lại nhiều lần trên tài khoản đã verify không lỗi.

---

## Case 3 — Resend OTP

- **Actor:** Guest (đã register, chưa verify)
- **Trigger:** Guest bấm "Gửi lại mã" khi chưa nhận được OTP hoặc OTP hết hạn.
- **Pre-condition:** User tồn tại, chưa verify email.
- **Main Flow:**
  1. Guest submit email.
  2. Hệ thống kiểm tra rate-limit (Redis key `otp:resend:{email}`, cooldown 60 giây).
  3. Hệ thống sinh OTP mới (ghi đè OTP cũ), hạn 10 phút, gửi lại email.
- **Post-condition:** OTP cũ vô hiệu, OTP mới có hiệu lực 10 phút.
- **Exception Flow:**
  - Đang trong cooldown 60s → `400 RESET_TOKEN_USED` *(dùng chung error code với reset-password — xem Gap bên dưới)*.
  - Email không tồn tại → `404 USER_NOT_FOUND`.
  - Email đã verify → trả về thành công, không gửi lại (no-op).
- **Business Rules:**
  - BR-06: Rate-limit 1 lần / 60 giây / email.

> **Gap phát hiện:** `resendOtp` khi bị rate-limit trả `ErrorCode.RESET_TOKEN_USED` — đây là error code của flow reset-password, tái dùng sai ngữ cảnh (message hiển thị cho user sẽ sai nghĩa). Cần `ErrorCode.OTP_RATE_LIMITED` riêng.

---

## Case 4 — Login (Email hoặc Số điện thoại + Password)

- **Actor:** Guest
- **Trigger:** Guest submit định danh (email hoặc SĐT) + password tại `/login`.
- **Pre-condition:** User tồn tại, đã set password (qua register hoặc set-password sau OAuth).
- **Main Flow:**
  1. Guest nhập identifier (tự động nhận diện email nếu chứa `@`, ngược lại chuẩn hóa như số điện thoại) + password.
  2. Hệ thống tìm user theo email hoặc phone.
  3. Hệ thống kiểm tra `user.isActive()` và `status == ACTIVE`.
  4. Hệ thống so khớp password với `passwordHash` (BCrypt).
  5. Hệ thống cập nhật `lastLoginAt`, ghi `AuditLog(LOGIN)`.
  6. Hệ thống phát hành access token (15p) + refresh token (30 ngày, set cookie HttpOnly).
- **Post-condition:** User có phiên đăng nhập hợp lệ, `accessToken` trả về body, `refreshToken` trong cookie.
- **Exception Flow:**
  - Identifier không tồn tại (email/phone không khớp user nào) → `401 INVALID_CREDENTIALS` (không tiết lộ email/phone có tồn tại hay không).
  - Sai password → `401 INVALID_CREDENTIALS` (message giống hệt trường hợp không tồn tại — chống user enumeration).
  - Tài khoản bị khóa/không active (`status != ACTIVE`) → `403 ACCOUNT_SUSPENDED`.
- **Business Rules:**
  - BR-07: Không phân biệt "sai email" và "sai password" trong response — cùng 1 error code.
  - BR-08: `workspaceId` trong JWT lấy từ workspace active đầu tiên của user (`WorkspaceMemberRepository.findFirstByUserIdAndIsActiveTrue`) — nếu user chưa thuộc workspace nào, claim này null.

> **Gap bảo mật phát hiện — KHÔNG có account lockout:** Code hiện tại không đếm số lần login sai, không tạm khóa tài khoản sau N lần thất bại liên tiếp. Mọi lần sai password chỉ trả `401 INVALID_CREDENTIALS`, không giới hạn tần suất thử. Đây là lỗ hổng cho phép brute-force password không giới hạn tốc độ. Cần bổ sung: đếm lần sai theo Redis (`login:fail:{userId}`), khóa tạm thời (vd 15 phút) sau 5 lần sai, hoặc bắt buộc CAPTCHA sau 3 lần sai.

---

## Case 5 — Login qua OAuth (Google / GitHub / LinkedIn / Microsoft)

- **Actor:** Guest
- **Trigger:** Guest bấm nút "Đăng nhập với Google" (hoặc GitHub/LinkedIn/Microsoft) tại trang login.
- **Pre-condition:** Không yêu cầu tài khoản tồn tại trước — tự động tạo mới nếu email chưa có trong hệ thống.
- **Main Flow (backend-driven redirect, ví dụ Google):**
  1. FE điều hướng trình duyệt thẳng tới `GET /api/v1/auth/oauth/google`.
  2. BE redirect (302) sang trang authorization của Google.
  3. User đăng nhập/cấp quyền phía Google.
  4. Google callback về `GET /api/v1/auth/oauth/google/callback?code=...&state=...`.
  5. BE exchange `code` lấy thông tin email từ Google, tìm hoặc tạo `User` + row `UserOAuthProvider`.
  6. BE phát hành access token + refresh token (set cookie), redirect FE về `/oauth-callback?token={accessToken}`.
  7. FE đọc `token` từ query string, lưu vào store, điều hướng vào dashboard.
- **Post-condition:** User có phiên đăng nhập hợp lệ; nếu là lần đầu, tài khoản mới được tạo tự động gắn provider.
- **Alternative Flow — Link-mode (user đã đăng nhập muốn gắn thêm 1 provider):**
  1. User đã login, bấm "Liên kết Google" tại `/settings`.
  2. FE gọi `GET /api/v1/auth/oauth/google/link?token={accessToken hiện tại}`.
  3. BE redirect Google kèm `state` mang theo `userId` hiện tại.
  4. Callback về, BE gắn provider vào đúng `userId` đó (không tạo user mới, không phát token mới).
  5. BE redirect FE về `/settings?linked=google`.
- **Exception Flow:**
  - Link-mode: email Google khác email tài khoản đang login → `OAUTH_EMAIL_MISMATCH`, redirect `/settings?error=OAUTH_EMAIL_MISMATCH` (không lộ raw JSON error).
  - Link-mode: provider đã được gắn vào tài khoản khác → `OAUTH_ALREADY_LINKED`, redirect tương tự.
  - Login-mode: `code`/`state` không hợp lệ hoặc hết hạn → lỗi ném thẳng cho `GlobalExceptionHandler`, không redirect thân thiện.
- **Business Rules:**
  - BR-09: Login-mode và Link-mode phân biệt qua `state` param — không dùng chung logic xử lý lỗi.
  - BR-10: Tài khoản tạo qua OAuth lần đầu không có `passwordHash` — phải gọi `set-password` nếu muốn thêm đăng nhập bằng password sau này.

---

## Case 6 — Refresh Token

- **Actor:** User (có refresh token cookie còn hạn)
- **Trigger:** FE tự động gọi khi access token hết hạn (interceptor 401) hoặc định kỳ.
- **Pre-condition:** Cookie `refreshToken` tồn tại, chưa hết hạn, chưa bị blacklist.
- **Main Flow:**
  1. FE gọi `POST /api/v1/auth/refresh` (cookie tự động đính kèm).
  2. BE parse + verify chữ ký refresh token.
  3. BE kiểm tra `jti` không nằm trong blacklist Redis.
  4. BE kiểm tra `issuedAt` của token không nằm trước thời điểm `lastPasswordChange` của user (chống dùng token cũ sau khi đổi password).
  5. BE blacklist refresh token cũ (rotation — mỗi lần refresh sinh token mới, token cũ không dùng lại được).
  6. BE phát hành access token + refresh token mới, set cookie mới.
- **Post-condition:** Access token mới cấp, refresh token cũ vô hiệu vĩnh viễn.
- **Exception Flow:**
  - Không có cookie hoặc rỗng → `401 REFRESH_TOKEN_INVALID`.
  - Token sai chữ ký / hết hạn → `401 REFRESH_TOKEN_INVALID`.
  - Token đã bị blacklist (đã dùng 1 lần rồi, hoặc đã logout) → `401 REFRESH_TOKEN_BLACKLISTED`.
  - Token phát hành trước lần đổi password gần nhất → `401 REFRESH_TOKEN_INVALID` (buộc login lại).
- **Business Rules:**
  - BR-11: Refresh token rotation — one-time use, mỗi lần refresh vô hiệu hóa token cũ.
  - BR-12: Đổi password vô hiệu hóa toàn bộ refresh token phát hành trước đó (so `issuedAt` với `lastPasswordChange`).

---

## Case 7 — Logout

- **Actor:** User
- **Trigger:** User bấm "Đăng xuất".
- **Pre-condition:** Có access token hợp lệ trong header `Authorization: Bearer`.
- **Main Flow:**
  1. FE gọi `POST /api/v1/auth/logout` kèm access token header + refresh token cookie.
  2. BE blacklist cả access token và refresh token (nếu có) vào Redis theo `jti`.
  3. BE ghi `AuditLog(LOGOUT)` kèm IP + User-Agent.
  4. BE xóa cookie `refreshToken` (maxAge=0).
- **Post-condition:** Cả 2 token không còn dùng được, kể cả khi chưa hết hạn tự nhiên.
- **Exception Flow:**
  - Thiếu hoặc sai định dạng header `Authorization` → `401 INVALID_CREDENTIALS`.
- **Business Rules:**
  - BR-13: Logout blacklist ngay lập tức — không chờ token tự hết hạn.

---

## Case 8 — Forgot Password

- **Actor:** Guest
- **Trigger:** Guest bấm "Quên mật khẩu?", nhập email.
- **Pre-condition:** Không yêu cầu — chấp nhận mọi email input.
- **Main Flow:**
  1. Guest submit email.
  2. Hệ thống tìm user theo email.
  3. Nếu tồn tại: sinh reset token ngẫu nhiên 32 byte (hex), lưu Redis với TTL cấu hình (`app.password-reset-ttl-seconds`), gửi email chứa link reset.
  4. Nếu không tồn tại: không làm gì, không báo lỗi.
  5. Hệ thống luôn trả về `200 OK` bất kể email có tồn tại hay không.
- **Post-condition:** Nếu email hợp lệ, token reset tồn tại trong Redis chờ dùng.
- **Business Rules:**
  - BR-14: Không tiết lộ email có tồn tại trong hệ thống hay không (chống user enumeration) — luôn trả 200.
  - BR-15: Token reset là random 256-bit, không đoán được, lưu Redis (không lưu DB) — tự hết hạn theo TTL.

---

## Case 9 — Reset Password

- **Actor:** Guest (có token từ email)
- **Trigger:** Guest bấm link trong email, nhập mật khẩu mới.
- **Pre-condition:** Token tồn tại trong Redis, chưa dùng, chưa hết hạn.
- **Main Flow:**
  1. Guest submit token + mật khẩu mới.
  2. Hệ thống tra `userId` từ token trong Redis.
  3. Hệ thống xóa token khỏi Redis ngay (atomic, one-time use).
  4. Hệ thống cập nhật `passwordHash` mới, set `lastPasswordChange = now()`.
  5. Hệ thống ghi `AuditLog(PASSWORD_RESET)`.
- **Post-condition:** Password mới có hiệu lực; mọi refresh token cũ tự động vô hiệu (theo BR-12).
- **Exception Flow:**
  - Token không tồn tại trong Redis (sai/hết hạn) → `400 RESET_TOKEN_INVALID`.
  - Token vừa bị xóa bởi request đồng thời khác (race condition — dùng 2 lần cùng lúc) → `400 RESET_TOKEN_USED`.
- **Business Rules:**
  - BR-16: Reset password tự động buộc logout mọi phiên khác (qua cơ chế BR-12), không cần thao tác thêm.

---

## Case 10 — Change Password

- **Actor:** User (đã đăng nhập, đã có password)
- **Trigger:** User vào Settings, nhập password hiện tại + password mới.
- **Pre-condition:** User đã có `passwordHash` (không áp dụng cho tài khoản OAuth-only chưa set password).
- **Main Flow:**
  1. User submit password hiện tại + password mới.
  2. Hệ thống so khớp password hiện tại.
  3. Hệ thống cập nhật `passwordHash` mới, `lastPasswordChange = now()`.
  4. Hệ thống ghi `AuditLog(PASSWORD_RESET)` *(dùng chung action với reset-password — xem Gap)*.
- **Post-condition:** Password mới có hiệu lực; theo BR-12, mọi refresh token cũ vô hiệu — user hiện tại cũng bị đăng xuất khỏi các thiết bị khác (kể cả access token hiện tại vẫn còn hạn tới khi hết 15 phút).
- **Exception Flow:**
  - Password hiện tại sai → `400 WRONG_CURRENT_PASSWORD`.
- **Business Rules:**
  - BR-17: Đổi password không tự logout access token đang dùng (access token vẫn sống tới khi hết hạn tự nhiên, chỉ refresh token bị chặn) — access token cũ dùng được tối đa 15 phút sau khi đổi password.

> **Gap phát hiện:** `changePassword` và `resetPassword` cùng ghi `AuditAction.PASSWORD_RESET` — audit log không phân biệt được "user tự đổi khi đang login" và "user reset qua email quên mật khẩu". Nên tách `AuditAction.PASSWORD_CHANGE` riêng cho case 10.

---

## Case 11 — Link / Unlink Phone

- **Actor:** User
- **Trigger:** User vào Settings, nhập số điện thoại muốn gắn thêm làm phương thức đăng nhập.
- **Pre-condition (Link):** Số điện thoại chưa được dùng bởi tài khoản khác.
- **Main Flow (Link):**
  1. User nhập số điện thoại.
  2. Hệ thống chuẩn hóa số (loại ký tự thừa, format quốc tế) — số không hợp lệ bị từ chối ngay.
  3. Hệ thống kiểm tra số chưa tồn tại ở user khác.
  4. Hệ thống sinh OTP, lưu tạm Redis `phone:otp:{userId}` = `"{otp}:{phone}"`, TTL 10 phút, gửi OTP **qua email** (không phải SMS).
  5. User nhập OTP để xác nhận (`verify-phone-otp`).
  6. Hệ thống so khớp OTP, set `user.phone`.
- **Post-condition:** Số điện thoại trở thành phương thức đăng nhập hợp lệ (dùng ở Case 4).
- **Exception Flow:**
  - Số điện thoại không đúng định dạng → `400 INVALID_PHONE`.
  - Số đã dùng bởi tài khoản khác (check ở bước link lẫn bước verify — double-check tránh race) → `409 PHONE_ALREADY_IN_USE`.
  - OTP sai/hết hạn/không tồn tại → `400 OTP_INVALID`.
- **Main Flow (Unlink):**
  1. User bấm "Gỡ số điện thoại".
  2. Hệ thống kiểm tra user còn ít nhất 1 phương thức đăng nhập khác (password hoặc ≥1 OAuth provider).
  3. Nếu còn phương thức khác: xóa `user.phone`.
- **Exception Flow (Unlink):**
  - Phone là phương thức đăng nhập duy nhất (không có password, không có OAuth) → `400 LAST_LOGIN_METHOD` (chặn để tránh khóa tài khoản vĩnh viễn).
- **Business Rules:**
  - BR-18: OTP xác thực số điện thoại gửi qua **email** đã đăng ký, không qua SMS thật (không tích hợp SMS gateway).
  - BR-19: Không cho phép unlink phương thức đăng nhập cuối cùng của tài khoản.

---

## Case 12 — Link / Unlink OAuth Provider

- **Actor:** User
- **Trigger:** User vào Settings, bấm liên kết/gỡ liên kết 1 provider (Google/GitHub/LinkedIn/Microsoft).
- **Pre-condition (Link):** Xem Case 5 — Alternative Flow (Link-mode).
- **Main Flow (Unlink):**
  1. User bấm "Gỡ liên kết" trên 1 provider cụ thể.
  2. Hệ thống kiểm tra còn ít nhất 1 phương thức đăng nhập khác (password, phone, hoặc provider OAuth khác).
  3. Nếu hợp lệ: xóa row `UserOAuthProvider` tương ứng.
- **Exception Flow:**
  - Provider đang gỡ là phương thức đăng nhập cuối cùng (không password, không phone, chỉ còn đúng 1 provider) → `400 LAST_LOGIN_METHOD`.
- **Business Rules:**
  - BR-20: Cùng nguyên tắc BR-19 — luôn phải còn ≥1 phương thức đăng nhập.

---

## Case 13 — Set Password (đặt password lần đầu cho tài khoản OAuth-only)

- **Actor:** User (tạo tài khoản qua OAuth, chưa từng có password)
- **Trigger:** User vào Settings, bấm "Đặt mật khẩu" để có thêm phương thức đăng nhập bằng email+password.
- **Pre-condition:** `user.passwordHash == null` (chưa từng set password).
- **Main Flow:**
  1. User submit password mới.
  2. Hệ thống kiểm tra `passwordHash` hiện đang null.
  3. Hệ thống set `passwordHash` (BCrypt) + `lastPasswordChange = now()`.
- **Post-condition:** User có thể login bằng email/phone + password (Case 4), song song với OAuth.
- **Exception Flow:**
  - User đã có password từ trước → `400 PASSWORD_ALREADY_SET`.
- **Business Rules:**
  - BR-21: `set-password` chỉ dùng được đúng 1 lần (khi chưa có password) — đổi password sau đó phải qua Case 10 (Change Password), không gọi lại endpoint này.

---

## Case 14 — Get Current User (Me)

- **Actor:** User
- **Trigger:** FE gọi khi load app / vào trang Settings để biết trạng thái tài khoản hiện tại.
- **Pre-condition:** Có access token hợp lệ trong header `Authorization: Bearer`.
- **Main Flow:**
  1. FE gọi `GET /api/v1/auth/me`.
  2. BE trả về `userId`, `email`, `phone`, `hasPassword` (boolean), danh sách `providers` (OAuth đã liên kết).
- **Post-condition:** FE biết được user có password chưa, đã link phone/provider nào — dùng để quyết định hiện nút "Đặt mật khẩu" / "Liên kết thêm" ở Settings.
- **Exception Flow:**
  - Token không hợp lệ/thiếu → `401 INVALID_CREDENTIALS`.
- **Business Rules:**
  - Không có business rule riêng — endpoint chỉ đọc dữ liệu (read-only), không thay đổi state.

---

## Bảng tổng hợp Error Code

| Error Code | HTTP | Case liên quan |
|---|---|---|
| `EMAIL_ALREADY_EXISTS` | 409 | 1 |
| `USER_NOT_FOUND` | 404 | 2, 3, 10, 11, 12 |
| `OTP_INVALID` | 400 | 2, 11 |
| `RESET_TOKEN_USED` *(tái dùng sai — xem Gap Case 3)* | 400 | 3, 9 |
| `INVALID_CREDENTIALS` | 401 | 4, 7 |
| `ACCOUNT_SUSPENDED` | 403 | 4 |
| `OAUTH_EMAIL_MISMATCH` | — (redirect) | 5 |
| `OAUTH_ALREADY_LINKED` | — (redirect) | 5 |
| `REFRESH_TOKEN_INVALID` | 401 | 6 |
| `REFRESH_TOKEN_BLACKLISTED` | 401 | 6 |
| `RESET_TOKEN_INVALID` | 400 | 9 |
| `WRONG_CURRENT_PASSWORD` | 400 | 10 |
| `INVALID_PHONE` | 400 | 11 |
| `PHONE_ALREADY_IN_USE` | 409 | 11 |
| `PASSWORD_ALREADY_SET` | 400 | 13 |
| `LAST_LOGIN_METHOD` | 400 | 11, 12 |

## Danh sách Gap bảo mật/nghiệp vụ phát hiện khi đọc code

1. **Không có account lockout / rate-limit login** (Case 4) — brute-force password không giới hạn. Ưu tiên cao nhất.
2. **`resendOtp` tái dùng `RESET_TOKEN_USED`** thay vì error code riêng (Case 3) — sai message hiển thị.
3. **`changePassword` và `resetPassword` cùng ghi `AuditAction.PASSWORD_RESET`** (Case 10) — audit log không phân biệt được nguồn gốc đổi mật khẩu.
4. **OTP xác thực số điện thoại gửi qua email, không qua SMS thật** (Case 11) — cần xác nhận đây là thiết kế tạm thời (chưa tích hợp SMS gateway) hay chủ đích.

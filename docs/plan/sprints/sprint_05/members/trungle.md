# Sprint 5 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Lê Trí Trung |
| GitHub | [@letritrung] |
| Role | Leader / Backend Engineer |
| Sprint | Sprint 5 |
| Ngày nộp | 2026-08-02 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-E12-01 | [DA-E12-01](https://letritrung2605.atlassian.net/browse/DA-E12-01) | Register API (validate email uniqueness, bcrypt cost=12) | 🔴 Critical | ✅ Done |
| DA-E12-02 | [DA-E12-02](https://letritrung2605.atlassian.net/browse/DA-E12-02) | Login API (JWT access 15min + refresh 30d cookie) | 🔴 Critical | ✅ Done |
| DA-E12-03 | [DA-E12-03](https://letritrung2605.atlassian.net/browse/DA-E12-03) | Refresh Token API (rolling refresh) | 🔴 Critical | ✅ Done |
| DA-E12-04 | [DA-E12-04](https://letritrung2605.atlassian.net/browse/DA-E12-04) | Logout API (Redis JWT blacklist + clear cookie) | 🔴 Critical | ✅ Done |
| DA-E12-05 | [DA-E12-05](https://letritrung2605.atlassian.net/browse/DA-E12-05) | Forgot Password & Reset Password (OTP email flow) | 🔴 Critical | ✅ Done |
| DA-E12-06 | [DA-E12-06](https://letritrung2605.atlassian.net/browse/DA-E12-06) | Google OAuth login (callback + user creation) | 🟡 High | ❌ To Do |
| DA-E12-07 🆕 | — | Research HS256 vs RS256 vs ES256 for JWT signing | 🔴 Critical | ✅ Done |
| DA-E11-14 🆕 | — | Add all JPA models + repository layer (11 PostgreSQL tables) | 🔴 Critical | ✅ Done |
| DA-E13-01 | [DA-E13-01](https://letritrung2605.atlassian.net/browse/DA-E13-01) | GET/PUT /api/v1/users/me (view & update own profile) | 🔴 Critical | ❌ To Do |
| DA-E13-02 | [DA-E13-02](https://letritrung2605.atlassian.net/browse/DA-E13-02) | Avatar upload (file → S3 → save URL to MongoDB) | 🟡 High | ❌ To Do |
> 🆕 DA-E12-07 và DA-E11-14 là task phát sinh ngoài plan gốc — phát hiện trong quá trình implement.
> 🔀 DA-E14-01/02/03 (RBAC) dời sang Sprint 6.

**Tổng:** 10 tasks | Done: 8 | To Do: 2 | In Review: 0

---

## 3. Chi tiết công việc đã làm

---

### DA-E12-01 — Register API

**Jira status:** Done
**Branch:** `develop`
**File chính:**
- `src/main/java/com/brandhub/business/controller/AuthController.java` — `POST /api/v1/auth/register`
- `src/main/java/com/brandhub/business/service/AuthService.java` — register logic
- `src/main/java/com/brandhub/business/dto/request/RegisterRequest.java`
- `src/main/java/com/brandhub/business/dto/response/RegisterResponse.java`
- `src/test/java/com/brandhub/business/service/AuthServiceTest.java`

**Mô tả công việc đã làm:**
- Implement endpoint `POST /api/v1/auth/register` với validation: email uniqueness check, password strength (min 8 chars, 1 uppercase, 1 digit, 1 special), bcrypt hash cost=12.
- Tạo User trong PostgreSQL (`users` table), tự động assign role mặc định `AGENCY_OWNER` cho self-registration.
- Trả về `LoginResponse` (access token 15min + refresh token 30d trong HttpOnly cookie) ngay sau register để user không cần login lại.
- Xử lý edge cases: email đã tồn tại → `USER_ALREADY_EXISTS`, email không hợp lệ → `INVALID_EMAIL_FORMAT`, password yếu → `WEAK_PASSWORD`.

**Kết quả đạt được:**
- [x] Register API hoạt động, trả về JWT + refresh token cookie
- [x] bcrypt cost=12 — không lower vì "performance"
- [x] Test coverage: AuthServiceTest + AuthControllerTest

---

### DA-E12-02 — Login API

**Jira status:** Done
**File chính:**
- `AuthController.java` — `POST /api/v1/auth/login`
- `AuthService.java` — login logic (verify password, issue tokens)
- `dto/request/LoginRequest.java`
- `dto/response/LoginResponse.java`
- `src/test/java/com/brandhub/business/service/AuthServiceLoginTest.java`
- `src/test/java/com/brandhub/business/controller/AuthControllerLoginTest.java`

**Mô tả công việc đã làm:**
- Implement `POST /api/v1/auth/login`: nhận email + password → verify bcrypt hash → issue RS256-signed JWT access token (15min TTL) + refresh token (30d TTL, stored in HttpOnly `SameSite=Strict` cookie).
- JWT payload: `{sub: userId, role: SystemRole, workspaceId, jti: UUID}`.
- Refresh token lưu trong `user_refresh_tokens` table → hỗ trợ multi-device (mỗi device có refresh token riêng).
- Rate limiting: 5 attempts / email / 15 phút → lock 30 phút nếu vượt quá.

**Kết quả đạt được:**
- [x] Login API hoạt động, JWT RS256 + refresh token cookie
- [x] Rate limiting login attempts
- [x] Test: AuthServiceLoginTest + AuthControllerLoginTest

---

### DA-E12-03 — Refresh Token API

**Jira status:** Done
**File chính:**
- `AuthController.java` — `POST /api/v1/auth/refresh`
- `AuthService.java` — refresh logic (verify refresh token, rotate)
- `src/test/java/com/brandhub/business/service/AuthServiceRefreshTest.java`
- `src/test/java/com/brandhub/business/controller/AuthControllerRefreshTest.java`

**Mô tả công việc đã làm:**
- Implement rolling refresh token: mỗi lần refresh → invalidate refresh token cũ, issue refresh token mới (rotation). Nếu refresh token đã bị revoked mà vẫn được sử dụng → revoke tất cả refresh tokens của user đó (potential token theft detection).
- Refresh token đọc từ HttpOnly cookie, không từ request body → chống XSS.
- Access token mới trả về trong response body (không phải cookie) → frontend lưu trong memory.

**Kết quả đạt được:**
- [x] Rolling refresh token với rotation + theft detection
- [x] HttpOnly cookie → chống XSS
- [x] Tests pass

---

### DA-E12-04 — Logout API

**Jira status:** Done
**File chính:**
- `AuthController.java` — `POST /api/v1/auth/logout`
- `AuthService.java` — logout logic (blacklist JWT + revoke refresh token)
- `src/test/java/com/brandhub/business/controller/AuthControllerLogoutTest.java`

**Mô tả công việc đã làm:**
- Implement `POST /api/v1/auth/logout`: thêm JWT jti vào Redis blacklist (`jwt:blacklist:{jti}`, TTL = 15 phút = remaining access token lifetime), revoke refresh token trong DB, clear refresh token cookie.
- Gateway check Redis blacklist trước khi forward request → JWT đã logout bị reject ngay cả khi chưa hết hạn.
- Nếu không có JWT (đã hết hạn) → vẫn clear cookie + return 200 (idempotent logout).

**Kết quả đạt được:**
- [x] Logout API với Redis blacklist + DB revoke + cookie clear
- [x] Idempotent — gọi nhiều lần không lỗi
- [x] Tests pass

---

### DA-E12-05 — Forgot Password & Reset Password

**Jira status:** Done
**File chính:**
- `AuthController.java` — `POST /api/v1/auth/forgot-password`, `POST /api/v1/auth/reset-password`, `POST /api/v1/auth/verify-otp`, `POST /api/v1/auth/resend-otp`
- `service/MailService.java` — gửi OTP email qua SMTP
- `dto/request/ForgotPasswordRequest.java`, `ResetPasswordRequest.java`, `VerifyOtpRequest.java`
- `model/PasswordResetToken.java`

**Mô tả công việc đã làm:**
- Implement flow: user gửi email → system gửi OTP 6-digit qua email (SMTP) → user nhập OTP + password mới → verify OTP → reset password.
- OTP lưu trong DB (`password_reset_tokens` table) với TTL 10 phút. Tối đa 3 lần nhập sai OTP → token bị hủy.
- Resend OTP: tối đa 3 lần/email/giờ.
- Sau khi reset password thành công → revoke tất cả refresh tokens của user (force re-login trên mọi thiết bị).

**Kết quả đạt được:**
- [x] Full forgot/reset password flow với OTP email
- [x] Rate limiting: 3 OTP attempts, 3 resends/giờ
- [x] Force re-login sau reset

---

### DA-E12-07 🆕 — JWT Signing Algorithm Research

**Jira status:** Done (phát sinh)
**Branch:** `develop`

**Mô tả công việc đã làm:**
- Research và quyết định chọn RS256 (RSA 2048-bit asymmetric) thay vì HS256 (HMAC symmetric):
  - **RS256:** Gateway xác thực bằng public key (không cần shared secret) → business-service là service duy nhất giữ private key → giảm attack surface.
  - **HS256:** Tất cả service cần shared secret → nếu 1 service bị compromise, toàn bộ JWT bị fake.
  - **ES256:** Tốt hơn RS256 về performance và key size nhưng Spring Security ecosystem chưa hỗ trợ tốt bằng (ít library, ít example).
- Sinh RSA key pair (`private_key.pem` + `public_key.pem`) bằng OpenSSL.
- Gateway config: `spring.security.oauth2.resourceserver.jwt.public-key-location: classpath:public_key.pem`.
- Business-service config: `jwt.private-key-path` + NimbusJwtEncoder với RSAKey.

**Kết quả đạt được:**
- [x] RS256 được chọn và document lý do
- [x] Key pair generated, gateway xác thực bằng public key

---

### DA-E11-14 🆕 — JPA Models & Repository Layer

**Jira status:** Done (phát sinh)
**File chính:**
- `model/User.java` — JPA entity map với `users` table
- `model/UserRefreshToken.java` — refresh tokens per device
- `model/UserOAuthProvider.java` — OAuth provider links
- `model/PasswordResetToken.java` — OTP password reset
- `model/Workspace.java`, `WorkspaceMember.java`, `WorkspaceInvitation.java`, `WorkspaceMemberPermission.java`
- `model/Client.java`
- `model/AuditLog.java`, `Invoice.java`, `Payment.java`
- `model/SubscriptionPlan.java`, `WorkspaceSubscription.java`
- `repository/` — Spring Data JPA repositories cho tất cả entities trên
- Enums: `SystemRole.java`, `MemberRole.java`, `OAuthProvider.java`, `UserStatus.java`

**Mô tả công việc đã làm:**
- Tạo toàn bộ JPA entity classes map với 11 PostgreSQL tables từ Sprint 3 schema (`init-postgres.sql`).
- Thiết lập quan hệ: `User` 1→N `UserRefreshToken`, `User` 1→N `UserOAuthProvider`, `Workspace` 1→N `WorkspaceMember`, v.v.
- Viết Spring Data JPA repositories với custom query methods (findByEmail, findByWorkspaceId, v.v.).
- Enum mapping dùng `@Enumerated(EnumType.STRING)` để tránh ordinal bugs.

**Kết quả đạt được:**
- [x] 11 entity classes + repositories hoàn chỉnh
- [x] Entity relationships mapping chính xác với schema

---

## 4. Tasks chưa hoàn thành

| Task ID | Lý do chưa xong | Tiến độ | Kế hoạch |
|---|---|---|---|
| DA-E12-06 | Google OAuth — mới có model + enum scaffold, chưa implement OAuth2 flow (token exchange, callback, user creation) | 20% | Sprint 6 Week 1 |
| DA-E13-01 | GET/PUT /users/me — chưa có UserController | 0% | Sprint 6 Week 1 |
| DA-E13-02 | Avatar upload — chưa có S3 integration trong business-service | 0% | Sprint 6 Week 2 |

> 🔀 DA-E14-01/02/03 (RBAC) đã dời sang Sprint 6.

> **Nguyên nhân chính:** 8/13 tasks Done (auth core + models) là phần quan trọng nhất. RBAC + OAuth + profile bị dồn sang Sprint 6 do auth core chiếm nhiều thời gian hơn estimate (RS256 research, JPA models phát sinh, multi-device refresh token rotation).

---

## 5. Đóng góp ngoài tasks chính

- Phát hiện và thêm 2 task phát sinh (DA-E12-07 RS256 research, DA-E11-14 JPA models) — đây là những prerequisite không có trong plan gốc nhưng không thể skip.
- Thiết kế rolling refresh token với rotation + theft detection — pattern bảo mật cao hơn yêu cầu gốc (plan chỉ nói "issue new access token", không đề cập rotation).
- Gateway JWT filter (từ Sprint 4) được sync với business-service RS256 implementation — đảm bảo gateway đọc đúng public key format.
- Viết test coverage cho auth flow: AuthServiceTest, AuthServiceLoginTest, AuthServiceRefreshTest, AuthControllerTest, AuthControllerLoginTest, AuthControllerLogoutTest, AuthControllerRefreshTest.

---

## 6. Học được gì trong sprint này

1. **RS256 asymmetric JWT:** Lần đầu implement RS256 trong Spring Security. Khác biệt chính với HS256: business-service dùng `NimbusJwtEncoder` + `RSAKey` (private key) để sign, gateway dùng `NimbusJwtDecoder` + `RSAPublicKey` để verify — không cần shared secret. Key rotation dễ hơn: chỉ cần update public key trên gateway.
2. **Rolling refresh token:** Mỗi lần refresh → rotate token. Nếu token cũ bị replay → detect theft → revoke tất cả. Pattern này phổ biến trong OAuth2 best practices (RFC 6819 §5.2.2) nhưng phức tạp hơn "issue new access token" đơn thuần.
3. **HttpOnly cookie cho refresh token:** Access token trong memory (JS đọc được), refresh token trong HttpOnly `SameSite=Strict` cookie (JS không đọc được) → chống XSS đánh cắp refresh token. Trade-off: mobile app không dùng được cookie → cần endpoint riêng cho mobile.
4. **OTP email flow:** Rate limit OTP attempts + resends là critical — nếu không có, attacker có thể spam email hoặc brute-force OTP. 3 attempts + 3 resends/giờ là đủ cho UX mà vẫn an toàn.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc

- DA-E12-07 và DA-E11-14 là task phát sinh không có trong plan gốc → nguyên nhân: estimate ban đầu không tính đến research + model setup. Các sprint sau nên buffer 20% cho prerequisite work.
- RBAC (E14) bị dồn sang Sprint 6 → ảnh hưởng đến Sprint 6 timeline (vốn đã có E15/E16/E17). Cần prioritize E14 ngay tuần 1 Sprint 6.

### 7.2 Về technical

- `SecurityConfig` hiện tại `.anyRequest().permitAll()` — tất cả endpoint đều public. Phải enable method security (`@EnableMethodSecurity`) + `@PreAuthorize` trước khi deploy production.
- Gateway injects `X-User-Role`, `X-Workspace-Id` nhưng business-service chưa đọc/verify → nếu attacker bỏ qua gateway gọi thẳng business-service, role và workspace sẽ không được enforce.

### 7.3 Đề xuất cho Sprint 6

- DA-E14-01 (@RequireRole) phải làm đầu tiên — nó block tất cả các task khác cần authorization.
- Cân nhắc tách Google OAuth (DA-E12-06) thành sprint riêng nếu Sprint 6 quá tải.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 3/5 | 8/13 Done; 5 task chưa xong do auth core chiếm nhiều thời gian hơn estimate + 2 task phát sinh |
| Chất lượng deliverable | 5/5 | Auth core đầy đủ test, rolling refresh token + theft detection, RS256 implementation chuẩn |
| Giao tiếp với team | 4/5 | Phát hiện và document 2 prerequisite task phát sinh; chưa kịp align RBAC timeline với Phước |
| Chủ động xử lý blocker | 4/5 | Tự research RS256, quyết định đúng; RBAC bị delay do auth core scope lớn hơn dự kiến |
| **Tổng** | **16/20** | |

---

*Deadline nộp: 2026-07-28 | Nộp muộn: 2026-08-02*

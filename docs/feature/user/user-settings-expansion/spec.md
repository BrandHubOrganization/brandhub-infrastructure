# UC — User Settings Expansion (Nav link, General tab, Phone link, OAuth connections)

| | |
|---|---|
| Feature | Mở rộng User Settings: nav link, theme/language, phone link, OAuth connections |
| Phụ thuộc | `docs/feature/user/user-settings/` (đã build: Profile/Avatar/Security tabs) |
| Nhóm | C. User & Profile Management |

## 1. Objective

Trang `/settings` hiện có 3 tab (Profile/Avatar/Security), chỉ vào được qua dropdown Navbar. Feature này bổ sung:
1. Lối vào thứ 2 qua Sidebar (section "Hệ thống").
2. Tab mới "Chung" (General) — theme sáng/tối, ngôn ngữ Việt/Anh (đã có logic ở landing Navbar, chưa có trong dashboard).
3. Link/unlink số điện thoại (API `linkPhone`/`verifyPhoneOtp`/`unlinkPhone` đã có sẵn backend, chưa dùng ở đâu).
4. Tab mới "Kết nối tài khoản" — link/unlink Google, GitHub với account hiện tại.

## 2. User Story

Là một user đã đăng nhập,
tôi muốn vào Settings dễ dàng từ Sidebar, đổi theme/ngôn ngữ, thêm số điện thoại, và liên kết tài khoản Google/GitHub vào account của mình,
để quản lý toàn diện tài khoản ở 1 nơi.

## 3. Acceptance Criteria

### Nav link
- Sidebar section "Hệ thống" (cùng chỗ Admin Panel) có thêm mục "Thiết lập" → `/settings`, hiện cho **mọi role** (không giới hạn ADMIN như Admin Panel).
- Dropdown Navbar "Thiết lập" giữ nguyên song song, không xoá.

### Tab General (mới, đặt trước tab Security)
- Toggle theme sáng/tối — tái dùng `useTheme()` hook đã có (`components/theme-provider.tsx`).
- Toggle ngôn ngữ Việt/Anh — tái dùng logic `i18n.changeLanguage()` + `localStorage.setItem("brandhub-lang", ...)` đã có ở `components/landing/Navbar.tsx`, không phát minh lại.

### Phone link (trong tab Profile hoặc tab riêng nhỏ — xem UI/UX)
- Hiện số điện thoại hiện tại nếu có (`GET /auth/me` đã trả `phone` field).
- Chưa có phone → form nhập số + nút gửi OTP (`POST /auth/link/phone`).
- Nhập OTP → xác nhận (`POST /auth/verify-phone-otp`).
- Đã có phone → nút "Gỡ liên kết" (`POST /auth/unlink/phone`).

### Tab Kết nối tài khoản (OAuth connections)
- Liệt kê 2 provider: Google, GitHub (theo yêu cầu — không làm LinkedIn/Microsoft dù backend có sẵn, tránh scope creep).
- Trạng thái mỗi provider: đã liên kết / chưa, lấy từ `GET /auth/me` field `linkedProviders`.
- Đã liên kết → nút "Ngắt kết nối" gọi `POST /auth/unlink/oauth` (đã có sẵn, dùng thẳng).
- Chưa liên kết → nút "Kết nối" → redirect sang flow OAuth **link-mode mới** (xem mục 5, khác endpoint login).

### Backend: OAuth link-mode (mới, sửa an toàn theo chuẩn ngành)
- **Vấn đề đã xác nhận:** flow OAuth hiện tại (`OAuthService.handleCallback`) không biết "ai đang login muốn link" — chỉ match theo email của tài khoản Google/GitHub được chọn. User đang login email A, chọn nhầm tài khoản Google email B → tự động link vào/tạo account B, KHÔNG phải link vào A đang dùng. Sai chuẩn ngành (Coursera/Google/GitHub đều yêu cầu xác thực JWT hiện tại trước khi redirect, so khớp email sau callback).
- Route mới `GET /api/v1/auth/oauth/{provider}/link` — yêu cầu `Authorization` header (JWT hiện tại), lưu `userId` vào Redis state (khác state login không mang userId) trước khi redirect.
- Callback phân biệt 2 case theo state Redis: nếu state có `userId` (link-mode) → sau khi fetch profile Google, so khớp `profile.email()` với email của `userId` trong JWT — khác nhau → lỗi rõ ràng (`OAUTH_EMAIL_MISMATCH`), không tạo/link user nào cả; khớp → link `UserOAuthProvider` vào đúng `userId` đó, redirect về `/settings?linked=google` (không phải `/oauth-callback` cấp token mới — user đã có session, không cần token mới).
- State Redis TTL giữ nguyên theo `OAUTH_STATE_PREFIX` pattern đã có, không đổi cấu trúc khác ngoài thêm `userId` vào value.

## 4. UI / UX

- Sidebar: thêm `NavItem` mới trong `NAV_SECTIONS[3]` ("nav.sections.system"), label key `nav.settings`.
- Trang `/settings`: đổi từ 3 tab sang 5 tab: Chung / Hồ sơ / Ảnh đại diện / Kết nối tài khoản / Bảo mật (thêm phone link vào cuối tab Hồ sơ, không tạo tab riêng — số điện thoại là 1 field profile, không đủ lớn để thành tab).
- Tab Kết nối tài khoản: mỗi provider 1 row (icon + tên + trạng thái + nút hành động), style theo pattern list đã dùng ở `WorkspaceMembersPage.tsx`.
- Nút "Kết nối" ghi chú nhỏ dưới: "Dùng tài khoản {provider} có cùng email {email hiện tại}" — cảnh báo UI vẫn giữ dù đã sửa backend (defense in depth, giảm khả năng user thử sai từ đầu).

### UI States
- OAuth link callback trả lỗi `OAUTH_EMAIL_MISMATCH` (qua query param lỗi ở URL redirect) → toast rõ ràng "Email tài khoản Google không khớp email hiện tại".
- Phone OTP: giống pattern `VerifyOtpPage.tsx` đã có (countdown resend nếu có, input 6 số).

## 5. API Contract

**Đã có sẵn, dùng thẳng:**
```
POST /api/v1/auth/link/phone       { phone }
POST /api/v1/auth/verify-phone-otp { otpCode }
POST /api/v1/auth/unlink/phone
POST /api/v1/auth/unlink/oauth     { provider }
GET  /api/v1/auth/me               → { linkedProviders: string[], phone, ... }
```

**Mới — sửa backend:**
```
GET /api/v1/auth/oauth/{provider}/link   (yêu cầu Authorization header)
→ 302 redirect sang provider, state Redis mang kèm userId

GET /api/v1/auth/oauth/{provider}/callback  (route cũ, mở rộng logic)
→ nếu state là link-mode: so khớp email, link vào đúng userId, redirect
  /settings?linked={provider}  hoặc  /settings?error=email_mismatch
→ nếu state là login-mode (cũ): giữ nguyên hành vi hiện tại, không đổi
```

`{provider}` giới hạn `google`, `github` theo scope frontend — nhưng route backend nên generic theo cả 4 provider có sẵn (LinkedIn/Microsoft) để nhất quán code, chỉ FE không hiển thị UI cho 2 provider đó.

## 6. Error Handling

- `OAUTH_EMAIL_MISMATCH` (mới, thêm vào `ErrorCode` enum) — 409, message rõ "Email tài khoản {provider} không khớp email hiện tại của bạn".
- Provider đã được link vào account KHÁC (không phải account đang login) — giữ nguyên lỗi hiện có nếu `UserOAuthProviderRepository` có unique constraint theo `(provider, providerId)` (cần kiểm tra khi code, không giả định).
- Phone OTP sai — theo lỗi có sẵn từ flow OTP khác trong hệ thống (đăng ký), dùng cùng error code nếu logic tương tự.

## 7. Edge Cases

- User chưa từng có mật khẩu (chỉ đăng ký qua OAuth, `hasPassword: false` theo `MeResponse` đã có field này) — vẫn cho link thêm provider khác bình thường, nhưng KHÔNG cho vào tab Bảo mật đổi mật khẩu (chưa có mật khẩu để đổi) — cần check `hasPassword` trước khi hiện form đổi mật khẩu, hoặc hiện thông báo "Đặt mật khẩu trước" trỏ sang `POST /auth/set-password` (đã có API, chưa dùng — có thể cần thêm vào scope nếu phát sinh khi code, ghi nhận ở đây trước).
- Link-mode redirect nhưng user đóng tab giữa chừng (không hoàn tất callback) — state Redis tự hết hạn theo TTL sẵn có, không cần xử lý dọn dẹp thêm.
- Unlink provider cuối cùng khi user không có mật khẩu/phone — **đã có sẵn guard** trong `AuthServiceImpl.unlinkOAuth`/`unlinkPhone` (throw `ErrorCode.LAST_LOGIN_METHOD` nếu đây là phương thức đăng nhập duy nhất còn lại). Không cần sửa backend, chỉ cần FE hiển thị đúng message lỗi này khi gọi unlink.

## 8. Definition of Done

- Toàn bộ Acceptance Criteria mục 3 đạt.
- Backend: route `GET /oauth/{provider}/link` mới, `handleCallback` phân biệt link-mode/login-mode, `ErrorCode.OAUTH_EMAIL_MISMATCH` mới.
- Frontend: Sidebar nav item mới, `SettingsPage.tsx` mở rộng 5 tab, `authService.ts` thêm method cho phone link nếu chưa đủ.
- Test case mục test.md pass.
- `tsc --noEmit`, `eslint`, `mvn compile`/`mvn test` clean.

## Out of Scope

- LinkedIn/Microsoft trong UI Kết nối tài khoản (backend hỗ trợ sẵn nhưng không hiện — theo yêu cầu chỉ Google/GitHub).
- 2FA/TOTP, session management, xem lịch sử đăng nhập.
- Đặt mật khẩu lần đầu cho OAuth-only user (`set-password` API) — ghi nhận là gap liên quan phát hiện ở mục 7, không tự ý mở rộng scope, cần xác nhận riêng nếu muốn làm.

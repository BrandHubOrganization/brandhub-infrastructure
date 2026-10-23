# G1 — Authentication (Mobile)

> [<< Về plan tổng](../mobile-app-plan.md)
> [plan.md](./plan.md) | [task.md](./task.md) | [test.md](./test.md)
> Nguồn tham chiếu đã đọc thật (không đoán):
> - `brandhub-business-service/src/main/java/com/brandhub/business/controller/AuthController.java`
> - `brandhub-business-service/src/main/java/com/brandhub/business/controller/GoogleOAuthController.java`
> - `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/*.java`, `dto/response/*.java`
> - `brandhub-business-service/src/main/java/com/brandhub/business/exception/ErrorCode.java`
> - `brandhub-business-service/src/main/java/com/brandhub/business/config/OAuthProperties.java`
> - `brandhub-infrastructure/docs/ba/02-authentication-profile.md`
> - `brandhub-web/src/pages/auth/LoginPage.tsx`, `OAuthCallbackPage.tsx`, `hooks/useOAuthCallback.ts`
> - `brandhub-mobile-app/README.md`, `package.json`

## 1. Mục tiêu & phạm vi

G1 đưa mobile từ "chưa có auth thật" lên ngang hàng với web cho các luồng auth chính: Sign In Email, Sign In Google OAuth, Forgot/Reset Password, OTP Verification (dùng chung), 2FA Verify (nếu user đã bật), Sign Out. **Register (Sign Up) được đưa vào G1** vì OTP verification là dependency chung và app cần một điểm vào cho user hoàn toàn mới.

**Phạm vi G1 trên mobile:**
- Login (email/password), Register + verify OTP, Forgot Password, Reset Password (qua deep link), Logout.
- Sign In Google OAuth — bám theo flow backend-driven hiện có của web, chuyển sang pattern `expo-auth-session` phù hợp Expo managed.
- 2FA Verify màn hình (nhập mã OTP) khi `login` trả về `requireTwoFactor`. **Không làm màn hình Setup 2FA / bật 2FA mới trên mobile ở G1** — đó thuộc Settings, để domain sau.
- Change Password, Deactivate Account, link/unlink phone, 2FA setup/disable: **không làm ở G1** (xem mục 7).

**Khoảng cách với web (parity gap) cần biết trước khi build:**
- BA doc ghi rõ: *"3.2.3 — Ghi chú hiện trạng: login hiện tại theo báo cáo vẫn chưa chạy được — cần coi lại toàn bộ flow (không chỉ là feature mới, là bug fix trên flow cũ)"* (`docs/ba/02-authentication-profile.md` dòng 17). Nghĩa là Google OAuth trên web bản thân nó đang được coi là chưa ổn định; mobile implement theo cùng API backend nên rủi ro lỗi tương tự có thể lặp lại, cần test kỹ trước khi coi G1 xong.
- Web dùng flow redirect trình duyệt thuần (backend redirect sang Google, Google redirect lại backend, backend redirect về frontend kèm token trên URL fragment `#token=...`). Mobile không có "URL fragment" theo nghĩa browser history như web — cần dùng `expo-web-browser` (`WebBrowser.openAuthSessionAsync`) để mở phiên trình duyệt trong app và bắt lại redirect về qua custom scheme deep link, xem mục 4.3.

## 2. FR tham chiếu

Theo `docs/ba/02-authentication-profile.md`:

| FR | Tên | Tóm tắt 1 dòng |
|---|---|---|
| 3.2.1 | Sign Up | Đăng ký email/password, bắt buộc verify OTP; email so khớp không phân biệt hoa/thường ở local-part |
| 3.2.2 | Sign In With Email | Đăng nhập email/phone + password, không cần OTP lại |
| 3.2.3 | Sign In with Google OAuth | OAuth qua Google — hiện trạng được BA ghi là chưa chạy ổn, cần test kỹ |
| 3.2.4 | Reset Password | Quên mật khẩu → gửi link hoặc OTP tới email → đổi mật khẩu mới |
| 3.2.6 | OTP Verification | Màn hình nhập OTP dùng chung cho Sign Up / Reset Password / 2FA |
| 3.2.7 | Two-Factor Authentication (TOTP) | Chỉ còn scan QR + nhập OTP (đã bỏ copy secret key và backup codes) |
| 3.2.8 | Sign Out | Đăng xuất, phải lưu "last used platform" để gợi ý nút đăng nhập lần sau |

Không thuộc G1 nhưng có API đã tồn tại ở backend, ghi nhận để không trùng lặp sau: 3.2.5 Change Password, 3.2.9 Deactivate Account, 2FA setup/disable, link/unlink phone & OAuth.

## 3. API cần dùng

Base path: `/api/v1/auth` (từ `AuthController.java`). Tất cả response bọc trong `ApiResponse<T>` (có `requestId`). Lỗi dùng `ErrorCode` enum ở `exception/ErrorCode.java`.

### 3.1 Register — `POST /api/v1/auth/register`
- Request `RegisterRequest`: `{ email: string (email, bắt buộc), password: string (bắt buộc, >=8 ký tự, phải có ít nhất 1 số), fullName: string (bắt buộc) }`
- Response `201 Created`, `RegisterResponse`: `{ userId: string (UUID) }`
- Sau khi register thành công, flow bắt buộc chuyển sang OTP Verification (không tự login).

### 3.2 Verify OTP — `POST /api/v1/auth/verify-otp`
- Request `VerifyOtpRequest`: `{ email: string (email), otpCode: string (đúng 6 ký tự) }`
- Response: `ApiResponse<Void>` — không có body data, chỉ `requestId`.
- Dùng chung cho luồng Sign Up (kích hoạt email) và các luồng khác cần OTP tương tự.

### 3.3 Resend OTP — `POST /api/v1/auth/resend-otp`
- Request: `ForgotPasswordRequest` shape — thực chất chỉ `{ email: string }` (controller dùng lại DTO `ForgotPasswordRequest` cho resend).
- Response: `ApiResponse<Void>`.

### 3.4 Login — `POST /api/v1/auth/login`
- Request `LoginRequest`: `{ identifier: string (bắt buộc — email hoặc phone, theo placeholder web "hello@company.com / 0912 345 678"), password: string (bắt buộc) }`
- Response `LoginResponse`:
  ```
  { accessToken: string|null, refreshToken: string|null, tokenType: "Bearer"|null,
    expiresIn: number (giây), requireTwoFactor: boolean, twoFactorToken: string|null }
  ```
  - Nếu `requireTwoFactor === true`: `accessToken`/`refreshToken` là `null`, chỉ có `twoFactorToken` — **chưa đăng nhập xong**, phải điều hướng sang màn 2FA Verify, lưu `twoFactorToken` tạm (web dùng `sessionStorage`, mobile dùng state trong memory/Zustand, không cần SecureStore vì token này sống rất ngắn).
  - Nếu login thành công bình thường: có `accessToken` + `refreshToken` đầy đủ.
- Response headers: server set cookie `refreshToken` (HttpOnly) — **mobile không dùng được cookie theo cách này** (không có browser cookie jar mặc định dùng chung với Axios/fetch trừ khi tự quản lý) → mobile phải lấy `refreshToken` từ **response body**, không trông chờ cookie. Cần xác nhận với backend rằng field `refreshToken` trong body luôn có giá trị khi gọi từ mobile (không bị set `null` với giả định FE luôn đọc cookie) — xem mục 8 rủi ro.
- Error cases: `INVALID_CREDENTIALS` (401), `ACCOUNT_LOCKED` (403, khóa tạm do nhiều lần sai), `ACCOUNT_SUSPENDED` (403).

### 3.5 Refresh Token — `POST /api/v1/auth/refresh`
- Request `RefreshTokenRequest`: `{ refreshToken: string }` — gửi trong body (vì mobile không có cookie).
- Response: `LoginResponse` (giống Login, có `accessToken` mới + `refreshToken` mới — rotate).
- Error: `REFRESH_TOKEN_INVALID` (401) nếu thiếu/rỗng cả cookie và body; `REFRESH_TOKEN_BLACKLISTED` (401) nếu đã bị revoke (ví dụ sau logout).
- Đây chính là endpoint mà Axios interceptor hiện có trong README ("Auto-refresh on 401") phải gọi.

### 3.6 Forgot Password — `POST /api/v1/auth/forgot-password`
- Request `ForgotPasswordRequest`: `{ email: string (email) }`
- Response: `ApiResponse<Void>`.
- Theo BA: gửi **link đổi mật khẩu HOẶC mã OTP** tới email — cần xác nhận với backend hình thức thực tế gửi là gì (link kèm token trong URL, hay OTP 6 số) để thiết kế đúng màn Reset Password (xem mục 8).

### 3.7 Reset Password — `POST /api/v1/auth/reset-password`
- Request `ResetPasswordRequest`: `{ token: string (bắt buộc), newPassword: string (bắt buộc, >=8 ký tự, có số) }`
- Response: `ApiResponse<Void>`.
- `token` lấy từ link trong email (deep link) hoặc từ OTP nhập tay — tùy cách backend thực hiện (xem mục 8).

### 3.8 Google OAuth

Ba endpoint theo `GoogleOAuthController.java`, **đều là GET trả `302 redirect`, không phải JSON API thông thường**:

- `GET /api/v1/auth/oauth/google?client=mobile` — **mobile phải thêm query `client=mobile`** (backend đã hỗ trợ, mục 8 câu 1) để callback redirect về deep link `brandhub://oauth-callback` thay vì web `frontendUrl`. Thiếu param này = mặc định hành vi web, mobile không bắt được redirect.
- `GET /api/v1/auth/oauth/google/callback` (và alias `/login/oauth2/code/google`) — Google gọi lại endpoint này sau khi user đồng ý; backend exchange code lấy token, rồi **redirect tiếp về `{frontendUrl}/oauth-callback#token={accessToken}`** (token nằm trên URL fragment) kèm set cookie `refreshToken` HttpOnly.
- `GET /api/v1/auth/oauth/google/link?token={jwt}` — link-mode, user đã đăng nhập muốn gắn thêm Google vào account (không dùng ở G1 mobile — thuộc Settings/Connections).

Trường hợp lỗi, backend redirect về frontend kèm query `?error=...`:
- `error=oauth_failed` — lỗi chung (code invalid, exchange fail, ...).
- `error=ACCOUNT_SUSPENDED` — tài khoản bị khóa, redirect về `/oauth-callback?error=ACCOUNT_SUSPENDED` (có message riêng, không dùng toast chung — theo comment trong code dòng 75-79 `GoogleOAuthController.java`).
- `error=OAUTH_EMAIL_MISMATCH` / `error=OAUTH_ALREADY_LINKED` — chỉ xảy ra ở link-mode, redirect về `/settings/connections`, không liên quan luồng Sign In ở G1.

`frontendUrl` lấy từ `AppProperties` (config phía backend) — với mobile, backend cần một `redirectUri`/`frontendUrl` riêng trỏ về deep link scheme của app (ví dụ `brandhub://oauth-callback`) khi request đến từ mobile, **hiện backend chỉ có 1 `frontendUrl` cấu hình cứng cho web** → cần backend thêm cấu hình hoặc tham số phân biệt nguồn gọi (web vs mobile). Đây là việc phải làm ở backend trước khi mobile implement được, ghi nhận ở mục 8.

Sau khi có `accessToken` từ fragment, mobile phải tự gọi tiếp `GET /api/v1/users/me` (hoặc `GET /api/v1/auth/me`, xem dưới) để lấy profile đầy đủ, giống hệt cách `useOAuthCallback.ts` làm ở web (dòng 52 — gọi `authService.getProfile()` sau khi có token).

### 3.9 Me (lấy profile tối giản auth) — `GET /api/v1/auth/me`
- Header: `Authorization: Bearer {accessToken}`.
- Response `MeResponse`: `{ userId, email, phone, hasPassword: boolean, linkedProviders: OAuthProvider[], twoFactorEnabled: boolean }`.
- Lưu ý: đây KHÔNG phải endpoint Profile đầy đủ (fullName, avatar, role, workspaceId) mà web `LoginPage.tsx` dùng (`profileRes.data.data` có `fullName`, `role`, `workspaceId`, `avatarUrl` — chắc chắn gọi `/api/v1/users/me` ở service khác, không phải `/api/v1/auth/me`). **Mobile sau khi login cũng phải gọi endpoint Users Profile thật (ngoài phạm vi G1, thuộc domain Profile) để có đủ field hiển thị** — G1 chỉ cần đảm bảo lưu đúng token, verify qua `/auth/me` là optional health-check.

### 3.10 2FA Verify — `POST /api/v1/auth/2fa/verify`
- Request `TwoFactorVerifyRequest`: `{ twoFactorToken: string, code: string (đúng 6 ký tự) }`
- Response: `LoginResponse` đầy đủ (giống Login thành công) — set cookie refresh (mobile vẫn lấy từ body).
- Dùng khi bước Login trả `requireTwoFactor: true`.

### 3.11 Logout — `POST /api/v1/auth/logout`
- Header: `Authorization: Bearer {accessToken}` (bắt buộc, thiếu → 401 `INVALID_CREDENTIALS`).
- Body (mobile **bắt buộc** gửi, web vẫn dùng cookie): `{ refreshToken: string }` — backend đã sửa (mục 8 câu 3b) để nhận `RefreshTokenRequest` qua body, ưu tiên cookie nếu có, fallback đọc body nếu không — mobile phải gửi field này để backend revoke đúng token.
- Response: `ApiResponse<Void>`.
- Theo FR 3.2.8: phải lưu "last used platform" (email hay Google) — đây là **client-side local state** (không thấy field nào trong `MeResponse`/`LoginResponse` lưu việc này phía backend), nên mobile tự lưu vào AsyncStorage/SecureStore non-sensitive key, không cần API riêng.

## 4. Luồng màn hình (screen flows)

### 4.1 Login Screen
1. Form 2 input: `identifier` (email hoặc phone — placeholder giống web "hello@company.com / 0912 345 678"), `password`.
2. Nút "Đăng nhập" → gọi `POST /auth/login`.
3. Loading state: disable nút + spinner trong lúc chờ.
4. Kết quả:
   - `requireTwoFactor === true` → lưu `twoFactorToken` vào state tạm, điều hướng `TwoFactorVerify` screen.
   - Thành công: lưu `accessToken`/`refreshToken` vào `expo-secure-store`, điều hướng vào app chính (Dashboard) theo redirect đã lưu nếu có (tương đương `consumeAuthRedirect()` ở web).
5. Lỗi: toast theo `ErrorCode` — `INVALID_CREDENTIALS` → "Email hoặc mật khẩu không đúng"; `ACCOUNT_LOCKED` → "Tài khoản tạm khóa do đăng nhập sai nhiều lần"; `ACCOUNT_SUSPENDED` → "Tài khoản đã bị khóa".
6. Link "Quên mật khẩu?" → `ForgotPassword` screen.
7. Nút "Đăng nhập với Google" → trigger flow 4.3.
8. Link chuyển sang `Register` screen.
9. Nếu app đã lưu "last used platform" = Google (FR 3.2.8), hiển thị nút Google nổi bật hơn (ví dụ đặt trên cùng, hoặc badge "lần trước bạn dùng Google").

### 4.2 Register Screen
1. Form: `email`, `password` (hiển thị rule validate: >=8 ký tự + có số, tương tự `PasswordStrengthMeter.tsx` ở web), `fullName`.
2. Submit → `POST /auth/register` → nhận `userId`.
3. Điều hướng ngay sang `VerifyOtp` screen, truyền kèm `email` đã đăng ký (OTP được gửi tới email đó).
4. Không tự động login sau register — phải verify OTP xong, rồi quay lại Login để đăng nhập tay (giống hành vi "Sign Up khác Sign In — bắt buộc OTP" ở BA 3.2.1 vs 3.2.2).

### 4.3 VerifyOtp Screen (dùng chung)
1. Nhận tham số `email` + `purpose` (context: `register` | `forgotPassword` — chỉ ảnh hưởng UI text, API giống nhau).
2. 6 ô nhập OTP (hoặc 1 input numeric maxLength=6).
3. Submit → `POST /auth/verify-otp` với `{ email, otpCode }`.
4. Nút "Gửi lại mã" → `POST /auth/resend-otp` với `{ email }`, có cooldown (ví dụ 30-60s đếm ngược ở client — không thấy rate-limit cụ thể từ BA, cần xác nhận, xem mục 8).
5. Lỗi: `OTP_INVALID` → "Mã không đúng hoặc đã hết hạn"; `OTP_TOO_MANY_ATTEMPTS` → "Nhập sai quá nhiều lần, hãy gửi lại mã mới".
6. Thành công: nếu `purpose === register` → điều hướng về Login kèm toast "Xác thực thành công, hãy đăng nhập"; nếu `purpose === forgotPassword` → luồng Reset Password dùng OTP đã verify (xem 4.5 nếu backend chọn nhánh OTP thay vì link).

### 4.4 ForgotPassword Screen
1. 1 input `email`.
2. Submit → `POST /auth/forgot-password` với `{ email }`.
3. Luôn hiển thị thông báo thành công chung (không lộ việc email có tồn tại hay không, theo thông lệ bảo mật) — ví dụ "Nếu email tồn tại, chúng tôi đã gửi hướng dẫn đặt lại mật khẩu".
4. Tùy hình thức backend gửi (xem mục 8 — cần xác nhận link hay OTP):
   - Nếu gửi **link**: user mở email trên điện thoại → tap link → deep link mở thẳng `ResetPassword` screen với `token` lấy từ query param của deep link (xem 4.6 cấu hình scheme).
   - Nếu gửi **OTP**: điều hướng app sang `VerifyOtp` screen (purpose=`forgotPassword`) trước, sau khi verify OTP thành công mới cho vào `ResetPassword` screen (lúc này `token` để gửi `reset-password` có thể chính là OTP code, hoặc một token tạm backend trả về sau verify — cần xác nhận).

### 4.5 ResetPassword Screen
1. Nếu vào từ deep link: đọc `token` từ URL, không cho sửa.
2. Nếu vào từ flow OTP: `token` đã có từ bước trước, ẩn field này khỏi UI (không bắt user tự gõ token).
3. Input `newPassword` + `confirmPassword` (confirm chỉ validate client-side, API không có field confirm).
4. Submit → `POST /auth/reset-password` với `{ token, newPassword }`.
5. Lỗi: token hết hạn/invalid → thông báo rõ "Link đã hết hạn, vui lòng yêu cầu lại" + nút quay về `ForgotPassword`.
6. Thành công → điều hướng về `Login` kèm toast.

### 4.6 Google OAuth flow (Expo managed — dùng `expo-web-browser` + `expo-auth-session`)
Vì đây không phải OAuth chuẩn client-side (PKCE trực tiếp với Google) mà là **backend-driven redirect** (toàn bộ client secret nằm ở backend, giống hệt web), pattern đúng cho Expo managed là:

1. App gọi `WebBrowser.openAuthSessionAsync(startUrl, returnUrl)` trong đó:
   - `startUrl` = `{API_BASE_URL}/api/v1/auth/oauth/google` (endpoint bắt đầu flow ở mục 3.8).
   - `returnUrl` = deep link scheme của app, ví dụ `brandhub://oauth-callback` (đăng ký qua `app.json`/`app.config.ts` field `scheme`, dùng `expo-auth-session`'s `makeRedirectUri({ scheme: "brandhub", path: "oauth-callback" })` để tạo URI chuẩn cho cả Expo Go và standalone build).
2. User thấy WebView hệ thống (SFSafariViewController / Chrome Custom Tab) → đăng nhập Google → Google redirect về backend callback → backend redirect tiếp **về `returnUrl` đã đăng ký** (không phải `frontendUrl` web mặc định) kèm `#token=...` hoặc `?error=...`.
3. `WebBrowser.openAuthSessionAsync` tự đóng WebView và trả `result.url` chứa URL redirect cuối cùng — app tự parse `token`/`error` từ đó, **không cần Linking listener riêng** cho trường hợp này (khác với universal link mở app từ ngoài).
4. Parse xong: nếu có `token` → lưu vào SecureStore, gọi tiếp `GET /api/v1/auth/me` (health-check) rồi tới endpoint Profile đầy đủ (domain khác) để lấy `fullName`/`role`/`avatarUrl`, set Zustand store, vào app chính.
5. Nếu có `error=ACCOUNT_SUSPENDED` → toast riêng "Tài khoản đã bị khóa"; `error=oauth_failed` hoặc không có token → toast chung "Đăng nhập Google thất bại".
6. **Điều kiện chặn trước khi code**: backend phải hỗ trợ redirect về `returnUrl` custom scheme của mobile thay vì hardcode `frontendUrl` web — đây là thay đổi backend cần làm trước (ghi ở mục 8), hoặc mobile phải tự host 1 trang callback trung gian (web) để nhận token rồi forward vào app qua deep link — phương án dự phòng nhưng thêm độ phức tạp.

### 4.7 TwoFactorVerify Screen
1. Nhận `twoFactorToken` từ bước Login.
2. Input 6 số OTP (dùng app Authenticator, theo FR 3.2.7).
3. Submit → `POST /auth/2fa/verify` với `{ twoFactorToken, code }`.
4. Thành công → nhận `LoginResponse` đầy đủ → lưu token, vào app.
5. Lỗi → `OTP_INVALID`/tương tự → cho nhập lại, không tự động quay về Login (giữ `twoFactorToken` còn hiệu lực trong thời gian của nó).

### Error/Loading states chung
- Mọi submit button: disable + spinner khi đang gọi API, tránh double-submit.
- Lỗi network (không có response, timeout): toast "Không thể kết nối, vui lòng thử lại" — khác với lỗi nghiệp vụ có `ErrorCode`.
- Lỗi theo `ErrorCode` nên map qua 1 bảng message tiếng Việt tập trung (1 file constants), tái dùng được cho toast ở mọi screen.

## 5. State & storage

- **Token storage**: dùng `expo-secure-store` (đã có trong `package.json`, đúng như README mô tả "Tokens stored in expo-secure-store... Auto-refresh on 401"). Lưu 2 key riêng: `accessToken`, `refreshToken`. Không lưu `twoFactorToken` vào SecureStore (sống ngắn, chỉ cần trong memory/Zustand state, mất khi app bị kill giữa chừng là chấp nhận được — user login lại).
- **Zustand store** (`useAuthStore` — mirror ý tưởng `authStore` ở web):
  ```
  {
    accessToken: string | null,
    refreshToken: string | null,
    user: { userId, email, fullName, role, workspaceId, avatarUrl } | null,   // field đầy đủ lấy từ Profile API, ngoài scope DTO auth thuần
    lastUsedPlatform: "email" | "google" | null,   // FR 3.2.8, lưu cả vào SecureStore/AsyncStorage để tồn tại qua session
    isAuthenticated: boolean,
    setAuth(user, accessToken, refreshToken): void,
    setTokens(accessToken, refreshToken): void,     // dùng khi chỉ có token, chưa có profile (OAuth callback, giống web)
    clearAuth(): void,
  }
  ```
- **TanStack Query hooks cần có**:
  - `useLoginMutation` — gọi `POST /auth/login`, side-effect set Zustand store khi không cần 2FA.
  - `useRegisterMutation` — `POST /auth/register`.
  - `useVerifyOtpMutation`, `useResendOtpMutation`.
  - `useForgotPasswordMutation`, `useResetPasswordMutation`.
  - `useVerifyTwoFactorMutation`.
  - `useLogoutMutation` — gọi `POST /auth/logout`, luôn `clearAuth()` ở `onSettled` (dù API lỗi vẫn phải xóa token local).
  - `useMeQuery` (optional, cho health-check sau OAuth) — `GET /auth/me`.
  - Refresh token **không** nên là 1 TanStack hook thông thường — nó chạy trong Axios response interceptor (401 → gọi refresh → retry request gốc), đúng theo mô tả README hiện tại, giữ nguyên pattern đó.

## 6. Business rules đặc biệt

- **Email case-insensitive ở local-part** (FR 3.2.1): `User@gmail.com` và `user@gmail.com` là cùng 1 account — đây là rule backend xử lý, mobile chỉ cần **không tự uppercase/lowercase email khi hiển thị lại** để tránh gây hiểu nhầm, nhưng khi submit để nguyên input user gõ (backend chịu trách nhiệm normalize).
- **Sign Up bắt buộc OTP, Sign In không cần** — không được tự động đăng nhập ngay sau register thành công dù có `userId` trả về.
- **Change Password yêu cầu confirm 2 lần hoặc modal** (FR 3.2.5) — không thuộc G1 nhưng nếu sau này thêm, nhớ áp dụng cùng rule UX.
- **2FA chỉ còn QR + OTP**, không còn copy secret key / backup codes (FR 3.2.7) — G1 mobile chỉ cần implement màn **Verify** (nhập OTP khi được yêu cầu lúc login), không cần implement Setup (quét QR) ở G1.
- **Last used platform phải persist qua logout** (FR 3.2.8) — không xóa field này trong `clearAuth()`, chỉ xóa token/user.
- **Password rule validate client-side trước khi submit** (để UX nhanh, backend vẫn validate lại): tối thiểu 8 ký tự + có ít nhất 1 số (từ `@Pattern` và `@Size` trong `RegisterRequest`/`ResetPasswordRequest`).
- **Không tiết lộ email có tồn tại hay không** ở Forgot Password — luôn trả message thành công chung phía UI dù backend response thế nào (đây là rule UX chuẩn, chưa thấy backend code quyết định rõ nhưng nên áp dụng phòng hộ).

## 7. Việc KHÔNG làm ở G1

- Setup/bật mới 2FA (scan QR) — chỉ làm Verify khi đã bật từ trước (có thể bật qua web).
- Disable 2FA.
- Change Password (khi đã đăng nhập, không phải Forgot Password).
- Deactivate Account.
- Link/Unlink Phone, Link/Unlink OAuth provider (Settings/Connections) — ngoại trừ đọc để hiển thị trạng thái nếu cần ở màn Settings (thuộc domain khác).
- Profile đầy đủ (View/Update User Profile, Client Profile) — thuộc FR 3.3, domain riêng, không viết trong G1 này.
- Background/offline token refresh khi app bị kill (ngoài phạm vi theo quyết định chung ở `mobile-app-plan.md` mục 1 — foreground only giai đoạn đầu).

## 8. Rủi ro / câu hỏi mở — đã xác nhận bằng code thật (2026-10-22)

1. **Google OAuth redirect target cho mobile — ĐÃ SỬA BACKEND (2026-10-22).**
   Thêm query param `client` cho `GET /oauth/google` (`?client=mobile`) → `GoogleOAuthController.redirect()` gọi `GoogleOAuthService.buildAuthorizationUrlForClient("mobile")` thay vì `buildAuthorizationUrl()` mặc định. Flag này được nhét vào OAuth `state` string lưu Redis (format mới `provider|linkingUserId|client`, field thứ 3 thêm vào `OAuthService`), đọc lại ở `handleCallback()` thành `CallbackResult.isMobileClient()`. Controller chọn redirect base qua `callbackBaseUrl(isMobileClient, webPath)`: nếu `isMobileClient=true` và `app.mobile-redirect-uri` có cấu hình → dùng thẳng giá trị đó (deep link `brandhub://oauth-callback`, không thêm path); ngược lại giữ hành vi web cũ `{frontendUrl}{webPath}`.
   **Việc còn lại phía backend config**: set giá trị thật cho `app.mobile-redirect-uri=brandhub://oauth-callback` trong `application.yml`/biến môi trường môi trường mobile dùng — code đã sẵn sàng đọc field này qua `AppProperties.getMobileRedirectUri()`, nhưng nếu không set thì mobile vẫn fallback về `frontendUrl` web như cũ (an toàn, không crash, chỉ là chưa hoạt động đúng cho mobile).
   **Giới hạn đã biết**: nhánh lỗi (`businessFailure`, `loginFailure` khi `BusinessException`/`RestClientException` xảy ra) chưa đọc được `isMobileClient` vì `state` đã bị `getAndDelete` trước khi exception ném ra trong `handleCallback()` — các lỗi đó luôn redirect về web `frontendUrl`. Mobile code phía app cần tự coi "redirect về web URL thay vì deep link app" là 1 dạng lỗi gián tiếp (không bao giờ thấy redirect quay lại app) và xử lý timeout hợp lý ở `WebBrowser.openAuthSessionAsync`, không chỉ trông chờ mọi lỗi đều quay về app.

2. **BA ghi Google OAuth "chưa chạy được" trên web — XÁC NHẬN: KHÔNG phải trạng thái lỗi hiện tại, ghi chú đã cũ.**
   Đọc `GoogleOAuthController.java` đầy đủ: flow có xử lý đủ 3 nhánh (`OAUTH_EMAIL_MISMATCH`/`OAUTH_ALREADY_LINKED` link-mode, `ACCOUNT_SUSPENDED` riêng biệt, success kèm set cookie + fragment token), code hoàn chỉnh, không thấy TODO/FIXME/lỗi rõ ràng nào trong controller lẫn `AppProperties`. Dòng ghi chú ở BA doc (dòng 17 `02-authentication-profile.md`) là input do BA note lại từ báo cáo tại thời điểm viết doc, không phải trạng thái code đọc được hôm nay — coi là **đã fix hoặc chưa bao giờ đúng ở mức backend**, nhưng **vẫn cần test tay thật trên môi trường chạy** (không đọc code suy ra được lỗi integration thật với Google) trước khi đóng G1.

3. **Refresh token cookie vs body — XÁC NHẬN cả 2 phần của câu hỏi.**
   - (a) `AuthController.login()` (dòng 52-74) và `.refresh()` (dòng 76-103): response `LoginResponse` body **luôn** chứa `accessToken`/`refreshToken` đầy đủ khi không cần 2FA — cookie chỉ là **thêm**, không phải thay thế. Mobile đọc `refreshToken` từ body là đúng và được backend hỗ trợ sẵn, không cần xin thêm gì.
   - (b) `AuthController.logout()` — **ĐÃ SỬA BACKEND (2026-10-22)**: thêm `@RequestBody(required = false) RefreshTokenRequest request`, cùng pattern với `/refresh` — ưu tiên cookie nếu có, fallback đọc `request.refreshToken()` từ body nếu không. Mobile giờ gọi `POST /auth/logout` kèm body `{ "refreshToken": "..." }` để revoke đúng token, không chỉ xóa local.

4. **Forgot Password gửi link hay OTP — XÁC NHẬN: chỉ gửi LINK, không có nhánh OTP.**
   Đọc `AuthServiceImpl.forgotPassword()` (dòng 331-354) + `MailServiceImpl.sendPasswordResetEmail()`: sinh `token` random 32-byte hex, lưu Redis TTL = `appProperties.getPasswordResetTtlSeconds()` (default 3600s = 1h), gửi email HTML với nút bấm link `{frontendUrl}/reset-password?token={token}`. **Không có code nào sinh/gửi OTP 6 số cho forgot-password flow** — câu chữ BA "gửi link HOẶC mã OTP" chỉ là tả 2 khả năng thiết kế, thực tế code chọn **link only**. → Mục 4.4-4.5 trong spec này **chỉ cần giữ nhánh deep link**, bỏ hẳn nhánh OTP cho Reset Password (nhánh OTP ở 4.4 bước 4 "Nếu gửi OTP" không áp dụng — xoá khỏi UI/code mobile để tránh làm thừa màn hình). Token sống 1h, dùng 1 lần (`resetPassword()` dòng 356-368 xoá key Redis ngay khi dùng, dùng lại báo `RESET_TOKEN_USED`).

5. **Deep link scheme chưa đăng ký — vẫn mở, cần quyết định của team mobile** (không đọc được từ backend, đây là việc phía `brandhub-mobile-app` tự quyết `app.json`). Giữ nguyên câu hỏi: chọn `scheme` (đề xuất `brandhub`), và quyết định có cần Universal Links/App Links thật hay dùng custom scheme thuần (ảnh hưởng link reset-password mở từ email client Android/iOS một số hãng có thể chặn custom scheme — cần test thật trên thiết bị, không tìm thấy cấu hình Universal Link nào trong repo hiện tại).

6. **Rate limit resend OTP — XÁC NHẬN: cố định 60 giây, không cấu hình được.**
   `AuthServiceImpl.resendOtp()` dòng 163-183: set Redis key rate-limit với TTL hard-code `Duration.ofSeconds(60)` (dòng 183, comment "1-min cooldown" ngay trong code). Không có field trả về `retryAfter` trong response (`ApiResponse<Void>`), nên mobile **phải tự đếm ngược 60s cố định ở client** sau khi gọi `resend-otp` thành công — không cần hỏi backend, giá trị đã chốt cứng, chỉ cần client code đúng số 60.

7. **`/api/v1/auth/me` vs Users Profile đầy đủ — XÁC NHẬN path chính xác: `GET /api/v1/users/me`.**
   `UserController.java` dòng 18-19, 28-35: `@RequestMapping("/api/v1/users")`, endpoint `GET /me` nhận `@AuthenticationPrincipal AuthenticatedUser`, trả `UserProfileResponse` qua `userService.getUserProfile()`. Đây đúng là API domain Profile (ngoài scope G1) mà mobile phải gọi sau OAuth/login để có `fullName`/`avatarUrl`/`role` — xác nhận không trùng với `/api/v1/auth/me` (`MeResponse`, chỉ có `userId/email/phone/hasPassword/linkedProviders/twoFactorEnabled`). Domain Profile viết doc riêng có thể dùng thẳng path này, không cần đoán nữa.

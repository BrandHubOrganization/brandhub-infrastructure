# Plan — User Settings Expansion

## Mục tiêu
4 việc độc lập, gộp chung 1 feature vì cùng đích "mở rộng Settings": (1) nav link Sidebar, (2) tab General theme/language, (3) phone link, (4) OAuth account-linking đúng chuẩn (cần sửa backend).

## Thành phần liên quan

**Backend (`brandhub-business-service`):**
- `service/OAuthService.java` — `buildAuthorizationUrl()` hiện lưu Redis `state → provider().name()` (string đơn giản). Đổi format thành `state → "{providerName}|{userId hoặc rỗng}"` (pipe-delimited, tránh thêm dependency JSON serialize cho 1 giá trị đơn giản). Thêm overload `buildAuthorizationUrl(UUID linkingUserId)` cho link-mode, giữ `buildAuthorizationUrl()` không tham số cho login-mode cũ (không đổi behavior cũ).
- `handleCallback()` — parse lại state, nếu có `userId` phần link-mode: fetch profile → so `profile.email()` với email của `userId` (query `userRepository.findById`) → khác thì throw `BusinessException(ErrorCode.OAUTH_EMAIL_MISMATCH)` → không tạo/link gì; khớp thì gọi thẳng `oAuthProviderRepository.save(...)` với `userId` đã biết (bỏ qua `linkOrCreateUser`, vì user đã tồn tại và đã xác định).
- `controller/GoogleOAuthController.java` (+ GitHub tương tự) — thêm `@GetMapping("/{provider}/link")` yêu cầu `Authorization` header, parse JWT lấy userId, gọi `buildAuthorizationUrl(userId)`, redirect. Endpoint `/callback` giữ nguyên route, sửa response redirect: link-mode thành công → `{frontendUrl}/settings?linked={provider}`; login-mode giữ `{frontendUrl}/oauth-callback?token=...` như cũ.
- `exception/ErrorCode.java` — thêm `OAUTH_EMAIL_MISMATCH(HttpStatus.CONFLICT, "OAuth account email does not match your current account")`.

**Frontend (`brandhub-web-dashboard`):**
- `src/components/layout/Sidebar.tsx` — thêm 1 `NavItem` vào `NAV_SECTIONS` section "Hệ thống" (`titleKey: "nav.sections.system"`), label `nav.settings`, `to: "/settings"`. Không có role filter đặc biệt (khác Admin Panel) — hiện cho mọi user.
- `src/pages/settings/SettingsPage.tsx` — mở rộng từ 3 tab lên 5: thêm `"general"` (đầu tiên) và `"connections"` (trước Security). Thêm phone link vào cuối tab Profile (không tách tab riêng).
- `src/services/authService.ts` — đã có đủ `linkPhone`, `verifyPhoneOtp`, `unlinkPhone`, `unlinkOAuth`, `me()`. Thêm `oauthLinkUrl(provider)` (khác `oauthUrl` cũ dùng cho login) trỏ `/api/v1/auth/oauth/{provider}/link` — cần gửi kèm `Authorization` header dù là link `<a href>` thẳng (browser GET không tự gắn header) → **không dùng `<a href>` như login flow cũ, phải dùng `window.location.href` sau khi gọi fetch thủ công gắn header, hoặc đơn giản hơn: BE nhận token qua query param `?token=` thay vì header cho riêng route `/link`** (quyết định cụ thể ở mục Quyết định kiến trúc).
- `src/i18n/locales/{vi,en}.json` — thêm `nav.settings`, mở rộng `settings.tabs.*` (thêm `general`, `connections`), `settings.general.*`, `settings.connections.*`, `settings.phone.*`.

## Quyết định kiến trúc

- **Link-mode auth qua query param, không phải header.** Route `/api/v1/auth/oauth/{provider}/link` được truy cập bằng browser navigation (`window.location.href = url`), không phải `fetch`/`axios` — browser điều hướng thẳng không tự đính kèm `Authorization` header từ JS. 2 lựa chọn: (a) truyền JWT qua query param `?token=...` cho riêng route này, hoặc (b) dùng cookie-based session. Chọn (a) — hệ thống hiện tại đã có precedent JWT trên query string (dòng callback OAuth cũ trả `?token=` về FE), nhất quán pattern có sẵn hơn là thêm cookie session mới. Backend đọc `@RequestParam String token` thay vì header cho riêng endpoint `/link`, verify bằng `jwtUtil.parseToken(token)` — không đổi cách xác thực API khác.
- **State Redis dùng pipe-delimited string, không JSON.** `"{PROVIDER}|{userId}"` — login-mode thì `userId` rỗng (`"{PROVIDER}|"`), parse bằng `split("\\|", 2)`. Tránh thêm Jackson serialize cho 1 cặp giá trị đơn giản, giữ nhất quán với cách `buildAuthorizationUrl()` cũ chỉ lưu string thuần.
- **Không tạo JWT mới sau khi link thành công.** User đã có session hợp lệ (đó là điều kiện để vào được flow link) — chỉ cần redirect về `/settings?linked={provider}` để FE tự re-fetch `GET /auth/me` cập nhật `linkedProviders`, không cần cấp access token mới.
- **`{provider}` route param dùng chung cho cả 4 controller** (Google/GitHub/LinkedIn/Microsoft) — sửa đồng bộ cả 4 file dù FE chỉ hiện UI Google+GitHub, để không tạo lệch hành vi giữa các provider (nếu sau này FE mở rộng thêm LinkedIn/Microsoft, backend đã sẵn sàng).
- **Phone link nằm trong tab Profile, không tách tab riêng** — đã quyết trong spec.md, lý do: chỉ 1 field, tách tab tạo thêm 1 tab cho lượng nội dung rất nhỏ.

## Thứ tự build

1. Backend: `ErrorCode.OAUTH_EMAIL_MISMATCH`.
2. Backend: `OAuthService.buildAuthorizationUrl(UUID)` overload + đổi state format (kiểm tra kỹ `handleCallback` parse đúng cả state cũ dạng không-pipe nếu có request đang treo — TTL 10 phút nên rủi ro thấp, deploy giờ thấp điểm nếu cần).
3. Backend: sửa `handleCallback` phân nhánh link-mode/login-mode.
4. Backend: thêm route `/{provider}/link` ở cả 4 controller (Google/GitHub/LinkedIn/Microsoft), nhận `token` query param.
5. Backend: `mvn compile` + `mvn test` (test case mới cho link-mode, xem test.md).
6. Frontend: `authService.ts` thêm `oauthLinkUrl(provider)`.
7. Frontend: `Sidebar.tsx` thêm nav item.
8. Frontend: `SettingsPage.tsx` — tab General (theme/language, tái dùng logic có sẵn).
9. Frontend: `SettingsPage.tsx` — phone link UI vào tab Profile.
10. Frontend: `SettingsPage.tsx` — tab Connections (Google/GitHub link/unlink).
11. Frontend: xử lý query param `?linked=`/`?error=` khi `SettingsPage` mount (toast tương ứng).
12. i18n — thêm đủ key cả 2 file.
13. Test tay qua Chrome DevTools: nav link từ Sidebar, đổi theme/language, link phone (cần OTP thật — kiểm tra có thể test end-to-end được không, nếu không thì test logic qua code review + unit test), link Google với đúng email hiện tại, thử link Google với email khác (nếu có 2 tài khoản Google test) → xác nhận lỗi đúng.
14. `tsc --noEmit` + `eslint` + `mvn test`.

## Rủi ro

- **JWT trên query string (`?token=`) có thể lộ qua log server/browser history/Referer header** khi redirect sang trang khác — rủi ro bảo mật thật, nhưng đã là pattern có sẵn trong hệ thống (`oauth-callback?token=`) nên không phải rủi ro mới phát sinh, chỉ mở rộng pattern cũ. Ghi nhận, không tự ý đổi kiến trúc lớn hơn (cookie session) ngoài scope đã chốt.
- **Không test được OTP thật qua Chrome DevTools** nếu SMS provider chưa cấu hình ở môi trường dev — cần xác nhận khi code tới bước 13, có thể chỉ verify qua log OTP (nếu dev mode có in ra log) thay vì SMS thật.
- **Đổi format Redis state có thể phá vỡ request đang treo** (user bấm login OAuth ngay trước lúc deploy, redirect về sau khi code mới lên) — do TTL chỉ 10 phút, rủi ro thấp và tạm thời, không cần migration đặc biệt.
- **`UserOAuthProviderRepository` không có unique constraint DB-level rõ ràng trên `(provider, providerId)`** (chỉ thấy trong entity annotation, cần kiểm tra migration SQL riêng khi code) — nếu race condition xảy ra (2 request link cùng lúc), có thể tạo duplicate record. Ngoài scope xử lý concurrency ở lần này, ghi nhận rủi ro.

# Test — Sign In with Google OAuth

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Consent → callback thành công | AC "redirect consent" | 200, access+refresh token | Chưa test |
| TC-02 | Email Google đã có User (password) | Edge "merge" | Login account cũ, không tạo User trùng | Chưa test |
| TC-03 | Email Google chưa có User | AC "tạo User mới" | Tạo User `emailVerified=true` + `isNewUser=true` | Chưa test |
| TC-04 | User cancel consent | Error "user cancel" | Redirect `/login` + thông báo lỗi | Chưa test |
| TC-05 | Token exchange body form-urlencoded | AC "fix bug flow không chạy" | Google trả access_token, không lỗi content-type | Chưa test |
| TC-06 | State sai/đã dùng | Error (CSRF) | Từ chối, redirect `/login` + lỗi | Chưa test |
| TC-07 | Google code exchange fail | Error "OAUTH_CODE_INVALID" | 400 `OAUTH_CODE_INVALID` | Chưa test |
| TC-08 | Callback user deactivated/suspended | Error "ACCOUNT_SUSPENDED" | 403 `ACCOUNT_SUSPENDED` | Chưa test |
| TC-09 | State replay (dùng lại state đã consume) | Edge "CSRF replay" | 400 `OAUTH_STATE_INVALID` | Chưa test |

## Completion checks
HTTP callback: success returns 302 plus HttpOnly cookie and fragment token; cancellation and invalid state return frontend error; configured callback alias is reachable. Provider URL matches configured client ID/callback; unverified email is rejected; state is consumed atomically. UI success loads profile, saves role, clears token from URL; failures clear auth and return to login. Test localized error in vi/en; retain semantic theme classes. Actual Google consent must be exercised by the account owner.

## Verified 2026-09-19
- PASS: 3 MockMvc callback tests, 4 OAuth service tests (existing account, new verified user, state replay, configured callback).
- PASS: 3 Chromium UI tests (success, cancellation, profile failure).
- PASS: frontend production build.
- PASS: live gateway returns 302 to Google; client ID and redirect URI match credential JSON; cancellation returns to frontend.
- PASS: credential file absent from local index and all fetched origin branches/tags; ignore rule published as 68fa7b8.
- PENDING: account owner completes real Google consent; automated tests do not replace this check.

## Live Google verification with chrome-devtools-mcp
The downloaded JSON contained an outdated /login/oauth2/code/google callback: actual Google returned redirect_uri_mismatch. Google accepts http://localhost:8080/api/v1/auth/oauth/google/callback and displays Sign in to BrandHub. Backend GOOGLE_REDIRECT_URI and .env.example now use that verified URI. Credentials still come from JSON. Actual account sign-in remains pending user interaction.

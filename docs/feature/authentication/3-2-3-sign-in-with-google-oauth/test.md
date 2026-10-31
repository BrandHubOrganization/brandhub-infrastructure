# Test Specification — FR 3.2.3: Sign In with Google OAuth

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.2.3` |
| **Function Name** | Sign In with Google OAuth |
| **Functional Domain** | Authentication |
| **Canonical Actors / Roles** | `Guest, Owner, Manager, Creator, Client` |
| **Target Class & Method** | `OAuthService (GoogleOAuthService).handleCallback()` (78 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/OAuthServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Verify Google OAuth state and code, login or auto-provision ACTIVE user account, and issue JWT tokens or 2FA challenge |
| **Preconditions** | Can connect with server; OAuth state valid in Redis for GOOGLE |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 2, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; OAuth state valid in Redis for GOOGLE; Google account already linked to a user | `code` = `valid code`, `state` = `valid state` | 200 OK - CallbackResult(loginResult), access + refresh token issued | Audit LOGIN saved | **Passed** |
| `UTCID02` | `N` | Can connect with server; OAuth state valid in Redis for GOOGLE; No user with Google email | `code` = `valid code`, `state` = `valid state` | 200 OK - new OAuth-only user created (emailVerifiedAt set, role USER) and logged in | Audit LOGIN saved | **Passed** |
| `UTCID03` | `N` | Can connect with server; OAuth state valid in Redis for GOOGLE; Existing password user with same email | `code` = `valid code`, `state` = `valid state` | 200 OK - Google provider linked to existing account, logged in | Audit LOGIN saved | **Passed** |
| `UTCID04` | `N` | Can connect with server; OAuth state valid in Redis for GOOGLE; Google account already linked to a user; 2FA enabled for user | `code` = `valid code`, `state` = `valid state` | 200 OK - CallbackResult(twoFactorToken), no access token | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; OAuth state valid in Redis for GOOGLE with linkingUserId; Link email equals current user email | `code` = `valid code`, `state` = `valid link state` | 200 OK - CallbackResult(isLinkMode=true, linkedProvider=GOOGLE) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; OAuth state valid in Redis for GOOGLE; Google account already linked to a user | `code` = `valid code`, `state` = `valid state` | 200 OK - state key consumed (getAndDelete), lastLoginAt updated | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; OAuth state valid in Redis for GOOGLE; No user with Google email; Google profile has avatar | `code` = `valid code`, `state` = `valid state` | 200 OK - new user avatarUrl taken from Google profile | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; OAuth state valid in Redis for GOOGLE; Existing user has active workspace | `code` = `valid code`, `state` = `valid state` | 200 OK - access token has workspaceId claim | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; OAuth state valid in Redis for GOOGLE; Google email has mixed case/spaces | `code` = `valid code`, `state` = `valid state` | 200 OK - email lowercased and trimmed before lookup/create | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; OAuth state valid in Redis for GOOGLE with linkingUserId; Link email differs only by case | `code` = `valid code`, `state` = `valid link state` | 200 OK - equalsIgnoreCase match, provider linked | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; State not in Redis (expired or reused) | `code` = `valid code`, `state` = `expired state` | OAUTH_STATE_INVALID - 400 OAuth state is invalid or has expired | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; State stored for a different provider | `code` = `valid code`, `state` = `foreign state` | OAUTH_STATE_INVALID - 400 OAuth state is invalid or has expired | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; OAuth state valid in Redis for GOOGLE | `code` = `null`, `state` = `valid state` | OAUTH_CODE_INVALID - 400 OAuth authorization code exchange failed | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; OAuth state valid in Redis for GOOGLE | `code` = `invalid code`, `state` = `valid state` | OAUTH_CODE_INVALID - 400 OAuth authorization code exchange failed | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; OAuth state valid in Redis for GOOGLE; Google account linked to user isActive=false | `code` = `valid code`, `state` = `valid state` | ACCOUNT_SUSPENDED - 403 Account has been suspended | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; OAuth state valid in Redis for GOOGLE; Google account linked to user status DEACTIVATED | `code` = `valid code`, `state` = `valid state` | ACCOUNT_SUSPENDED - 403 Account has been suspended | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; OAuth state valid in Redis for GOOGLE with linkingUserId; Link email differs from Google email | `code` = `valid code`, `state` = `valid link state` | OAUTH_EMAIL_MISMATCH - 409 OAuth account email does not match your current account | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; OAuth state valid in Redis for GOOGLE with linkingUserId; Google account linked to another user | `code` = `valid code`, `state` = `valid link state` | OAUTH_ALREADY_LINKED - 409 linked to a different account | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; OAuth state valid in Redis for GOOGLE with linkingUserId; Linking user deleted | `code` = `valid code`, `state` = `valid link state` | USER_NOT_FOUND - 404 User not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.2.3`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Sign In with Google OAuth

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Consent → callback thành công | AC "redirect consent" | 302 redirect `{FRONTEND_URL}/oauth-callback#token=...` + Set-Cookie refreshToken | Chưa test |
| TC-02 | Email Google đã có User (password) | Edge "gắn thêm provider" | Login account cũ, gắn Google vào account đó, không tạo User trùng | Chưa test |
| TC-03 | Email Google chưa có User | AC "tạo User mới" | Tạo User `emailVerifiedAt=now`, không `passwordHash` | Chưa test |
| TC-04 | User cancel consent (callback không kèm code) | Error "user cancel" | 302 redirect `{FRONTEND_URL}/oauth-callback?error=oauth_failed` | Chưa test |
| TC-05 | Token exchange body form-urlencoded | AC "fix bug flow không chạy" | Google trả access_token, không lỗi content-type | Chưa test |
| TC-06 | State sai/đã dùng | Error (CSRF) | 302 redirect `?error=oauth_failed`, ErrorCode nội bộ `OAUTH_STATE_INVALID` | Chưa test |
| TC-07 | Google code exchange fail | Error "OAUTH_CODE_INVALID" | 302 redirect `?error=oauth_failed`, ErrorCode nội bộ `OAUTH_CODE_INVALID` | Chưa test |
| TC-08 | Callback user deactivated/suspended | Error "ACCOUNT_SUSPENDED" | 302 redirect `{FRONTEND_URL}/oauth-callback?error=ACCOUNT_SUSPENDED` (distinct redirect, dedicated toast `auth.login.oauthAccountSuspended`), ErrorCode nội bộ `ACCOUNT_SUSPENDED` | Chưa test |
| TC-09 | State replay (dùng lại state đã consume) | Edge "CSRF replay" | 302 redirect `?error=oauth_failed`, ErrorCode nội bộ `OAUTH_STATE_INVALID` | Chưa test |
| TC-10 | User bật 2FA đăng nhập Google | AC "2FA bắt buộc qua OAuth" | 302 redirect `{FRONTEND_URL}/2fa-verify?twoFactorToken=...`, chưa cấp accessToken/refreshToken | Chưa test |

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

# Test Specification — FR 3.2.2: Sign In with Email

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.2.2` |
| **Function Name** | Sign In with Email |
| **Functional Domain** | Authentication |
| **Canonical Actors / Roles** | `Guest, Owner, Manager, Creator, Client, Admin` |
| **Target Class & Method** | `AuthServiceImpl.login()` (55 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AuthServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Authenticate by email/phone identifier and password, verify account status, and issue JWT access + refresh tokens or 2FA challenge |
| **Preconditions** | Can connect with server; Account ACTIVE and email verified |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 1, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Account ACTIVE and email verified | `identifier` = `user@brandhub.vn`, `password` = `Abc@12345` | 200 OK - LoginResponse(accessToken, expiresIn) + refresh token | Audit LOGIN saved | **Passed** |
| `UTCID02` | `N` | Can connect with server; Account ACTIVE and email verified | `identifier` = `USER@BrandHub.VN`, `password` = `Abc@12345` | 200 OK - identifier matched case-insensitively | Audit LOGIN saved | **Passed** |
| `UTCID03` | `N` | Can connect with server; Account ACTIVE and email verified; Identifier is a linked phone number | `identifier` = `+84901234567`, `password` = `Abc@12345` | 200 OK - login by phone identifier | Audit LOGIN saved | **Passed** |
| `UTCID04` | `N` | Can connect with server; Account ACTIVE and email verified | `identifier` = `user@brandhub.vn`, `password` = `Abc@12345` | 200 OK - lastLoginAt updated | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Account ACTIVE and email verified; User has active workspace | `identifier` = `user@brandhub.vn`, `password` = `Abc@12345` | 200 OK - access token contains workspaceId claim | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Account ACTIVE and email verified; User has role ADMIN | `identifier` = `admin@brandhub.vn`, `password` = `Abc@12345` | 200 OK - access token role=ADMIN | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Account ACTIVE and email verified; User has no workspace | `identifier` = `user@brandhub.vn`, `password` = `Abc@12345` | 200 OK - workspaceId claim null | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Account ACTIVE and email verified; 2FA enabled for user | `identifier` = `user@brandhub.vn`, `password` = `Abc@12345` | 200 OK - LoginResponse.twoFactorChallenge(twoFactorToken), no access token | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Account ACTIVE and email verified | `identifier` = `user@brandhub.vn`, `password` = `Abc@12345` | 200 OK - refresh token returned with refreshExpirationMs | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Account ACTIVE and email verified | `identifier` = `user@brandhub.vn`, `password` = `A1234567` | 200 OK - 8-char password matches | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Email not registered | `identifier` = `ghost@brandhub.vn`, `password` = `Abc@12345` | INVALID_CREDENTIALS - 401 Invalid email or password | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Account ACTIVE and email verified | `identifier` = `user@brandhub.vn`, `password` = `WrongPass1` | INVALID_CREDENTIALS - 401 Invalid email or password | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; OAuth-only account (passwordHash null) | `identifier` = `oauth@brandhub.vn`, `password` = `Abc@12345` | INVALID_CREDENTIALS - 401 Invalid email or password | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User isActive=false | `identifier` = `user@brandhub.vn`, `password` = `Abc@12345` | ACCOUNT_SUSPENDED - 403 Account has been suspended | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User status DEACTIVATED | `identifier` = `user@brandhub.vn`, `password` = `Abc@12345` | ACCOUNT_DEACTIVATED - 403 Account has been deactivated | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User status not ACTIVE (pending/banned) | `identifier` = `user@brandhub.vn`, `password` = `Abc@12345` | ACCOUNT_SUSPENDED - 403 Account has been suspended | — | **Passed** |
| `UTCID17` | `A` | Can connect with server | `identifier` = `empty`, `password` = `Abc@12345` | VALIDATION_ERROR - identifier must not be blank | — | **Passed** |
| `UTCID18` | `A` | Can connect with server | `identifier` = `user@brandhub.vn`, `password` = `null` | VALIDATION_ERROR - password must not be blank | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.2.2`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Sign In With Email

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Login đúng email/pw (2FA tắt) | AC "trả JWT" | 200, access+refresh token | Chưa test |
| TC-02 | Login sai pw | Error "INVALID_CREDENTIALS" | 401, không tiết lộ email tồn tại | Chưa test |
| TC-03 | Login email case khác (`USER@gmail.com`) | Edge "chuẩn hóa email" | login thành công | Chưa test |
| TC-04 | Login account deactivated | Error "ACCOUNT_DEACTIVATED" | 403 `ACCOUNT_DEACTIVATED` | Chưa test |
| TC-05 | Login account 2FA bật | AC "chặn trước khi cấp token" | 200 `requireTwoFactor=true` + `twoFactorToken`, KHÔNG accessToken | Chưa test |
| TC-06 | Login 2FA bật, gọi /2fa/verify đúng | AC "hoàn tất login-2FA" | 200 access+refresh token | Chưa test |
| TC-07 | Không yêu cầu OTP ở login (2FA tắt) | AC "không OTP" | login thẳng, không bước OTP | Chưa test |
| TC-08 | Login account suspended | Error "ACCOUNT_SUSPENDED" | 403 `ACCOUNT_SUSPENDED` | Chưa test |
| TC-09 | Login OAuth-only account (không password) | — | 401 `INVALID_CREDENTIALS` | Chưa test |
| TC-10 | Login bằng phone identifier không tồn tại | — | 401 `INVALID_CREDENTIALS` | Chưa test |
| TC-11 | Refresh token sai/hết hạn | Error "REFRESH_TOKEN_INVALID" | 401 `REFRESH_TOKEN_INVALID` | Chưa test |
| TC-12 | Refresh token đã blacklist (sau logout) | Error "REFRESH_TOKEN_BLACKLISTED" | 401 `REFRESH_TOKEN_BLACKLISTED` | Chưa test |
| TC-13 | Refresh sau reset password (`iat < lastPasswordChange`) | Edge "revoke mọi thiết bị" | 401 `REFRESH_TOKEN_INVALID` | Chưa test |
| TC-14 | Refresh khi user deactivated | Edge "không login được" | 401 `REFRESH_TOKEN_INVALID` | Chưa test |

## Dev Quick Login repair — 2026-10-04

- RED: Manager không được đưa tới UUID cũ, Creator không được dừng ở Agency khi API có Workspace đúng CREATOR.
- Quyền lấy từ myRole trả về; test API trả CREATOR trước MANAGER để chứng minh chọn theo quyền, không chọn phần tử đầu tiên; không ép store systemRole theo nhãn nút.
- OWNER → Agency; CLIENT → ClientProfile; ADMIN → Admin. Không có role phù hợp → fallback Agency/hướng dẫn seed.
- 2FA challenge không gọi users/me, chuyển xác minh; stale-token login tests vẫn pass.
- Live bốn role: login/profile/Workspace hoặc ClientProfile đọc thành công, không 401/403 ngoài hành vi bảo vệ quyền hợp lệ.
- Seed rerun hai lần không nhân bản users/agency/workspaces/member/profile/package; không đổi mật khẩu/status tài khoản hiện hữu và không đụng dữ liệu Admin demo.

Kết quả đã kiểm tra ngày 2026-10-04:

| Kiểm tra | Kết quả |
|---|---|
| RED trước sửa | 3 test thất bại đúng nguyên nhân: Manager dùng UUID cũ, Creator dừng ở Agency, challenge 2FA gọi profile trước xác minh. |
| E2E sau sửa | 16/16 pass: 4 Dev Quick Login, 2 stale-session, 10 Admin overview. |
| Owner qua API thật | `/agency`; login, profile và danh sách Agency đều HTTP 200. |
| Manager qua API thật | `/workspaces/d3100000-0000-4000-8000-000000000002/dashboard`; login, profile và dashboard HTTP 200. |
| Creator qua API thật | `/workspaces/d3100000-0000-4000-8000-000000000003/dashboard`; login, profile và dashboard HTTP 200. |
| Client qua API thật | `/client-profiles`; login, profile và danh sách brand profile HTTP 200. |
| Quyền/session | Cả bốn phiên có systemRole USER, authenticated; không lỗi JavaScript hoặc API 4xx/5xx khi mở màn tương ứng. |
| SQL fixture | Dry-run kết thúc ROLLBACK thành công, áp dụng COMMIT thành công; chạy lại cho snapshot dữ liệu fixture/credentials/status/roles giống hệt (`Idempotent: true`). |
| Chất lượng frontend | ESLint các file TS thay đổi, `tsc -b` và Vite production build đều exit 0. |

Test 2FA ở đây kiểm tra nhánh điều hướng frontend bằng response mock; chưa thay thế kiểm thử backend login → OTP verify trong checklist phía trên.

# Test Specification — FR 3.2.7: Two-Factor Authentication (2FA, TOTP)

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.2.7` |
| **Function Name** | Two-Factor Authentication (2FA, TOTP) |
| **Functional Domain** | Authentication |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Target Class & Method** | `AuthServiceImpl.verifyTwoFactor()` (38 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AuthServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Verify 2FA challenge token and 6-digit RFC 6238 TOTP code with 5-attempt lockout and issue JWT session tokens |
| **Preconditions** | Can connect with server; User has 2FA enabled with TOTP secret |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 2, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User has 2FA enabled with TOTP secret | `twoFactorToken` = `valid 2fa token`, `code` = `valid TOTP` | 200 OK - LoginResult with access + refresh token | Audit LOGIN saved | **Passed** |
| `UTCID02` | `N` | Can connect with server; User has 2FA enabled with TOTP secret | `twoFactorToken` = `valid 2fa token`, `code` = `valid TOTP` | 200 OK - lastLoginAt updated, attempt counter cleared | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User has 2FA enabled with TOTP secret; User role ADMIN | `twoFactorToken` = `valid 2fa token`, `code` = `valid TOTP` | 200 OK - access token role=ADMIN | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User has 2FA enabled with TOTP secret; User has active workspace | `twoFactorToken` = `valid 2fa token`, `code` = `valid TOTP` | 200 OK - access token has workspaceId | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; 2FA not enabled, setup secret in Redis | `code` = `valid TOTP`, `userId` = `authenticated` | 200 OK - confirmTwoFactor enables 2FA, secret saved, setup key deleted | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; 2FA not enabled | `userId` = `authenticated` | 200 OK - setupTwoFactor returns otpauth URL, secret cached 10 min | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User has 2FA enabled with TOTP secret | `code` = `valid TOTP`, `userId` = `authenticated` | 200 OK - disableTwoFactor clears totpSecret and flag | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User has 2FA enabled with TOTP secret; 4 failed attempts already | `twoFactorToken` = `valid 2fa token`, `code` = `wrong TOTP` | TWO_FA_TOO_MANY_ATTEMPTS - 429 5th wrong code locks out | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User has 2FA enabled with TOTP secret; 0 failed attempts | `twoFactorToken` = `valid 2fa token`, `code` = `wrong TOTP` | TWO_FA_CODE_INVALID - 400 Invalid two-factor authentication code | — | **Passed** |
| `UTCID10` | `A` | Can connect with server | `twoFactorToken` = `malformed/expired token`, `code` = `valid TOTP` | TWO_FA_TOKEN_INVALID - 401 challenge is invalid or expired | — | **Passed** |
| `UTCID11` | `A` | Can connect with server | `twoFactorToken` = `access token (type != 2fa)`, `code` = `valid TOTP` | TWO_FA_TOKEN_INVALID - 401 challenge is invalid or expired | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; 2FA token subject user deleted | `twoFactorToken` = `valid 2fa token`, `code` = `valid TOTP` | TWO_FA_TOKEN_INVALID - 401 challenge is invalid or expired | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User status DEACTIVATED | `twoFactorToken` = `valid 2fa token`, `code` = `valid TOTP` | ACCOUNT_DEACTIVATED - 403 Account has been deactivated | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User 2FA disabled after challenge | `twoFactorToken` = `valid 2fa token`, `code` = `valid TOTP` | TWO_FA_NOT_ENABLED - 400 Two-factor authentication is not enabled | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; 2FA already enabled | `userId` = `authenticated` | TWO_FA_ALREADY_ENABLED - 400 setupTwoFactor when already enabled | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; No setup secret in Redis (expired) | `code` = `valid TOTP`, `userId` = `authenticated` | TWO_FA_NOT_ENABLED - 400 confirm without setup | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; 2FA not enabled | `code` = `valid TOTP`, `userId` = `authenticated` | TWO_FA_NOT_ENABLED - 400 disable when not enabled | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; 2FA setup in progress | `code` = `wrong TOTP`, `userId` = `authenticated` | TWO_FA_CODE_INVALID - 400 confirm with wrong code | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.2.7`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Two-Factor Authentication (2FA, TOTP)

| ID | Mô tả | AC | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Setup khi chưa bật 2FA | AC "hiển thị QR" | 200, `otpAuthUrl` dạng `otpauth://totp/...`, KHÔNG có `secretKey`/`qrCodeUrl` | Happy | Chưa test |
| TC-02 | Setup khi đã bật | AC "confirm → bật" | 400 `TWO_FA_ALREADY_ENABLED` | Error | Chưa test |
| TC-03 | Confirm code đúng (sinh từ secret pending) | AC "nhập OTP confirm" | 200, `twoFactorEnabled=true` trong DB | Happy | Chưa test |
| TC-04 | Confirm code sai | Error "mã confirm sai" | 400 `TWO_FA_CODE_INVALID`, 2FA vẫn tắt | Error | Chưa test |
| TC-05 | Confirm khi chưa gọi setup (không có pending) | — | 400 `TWO_FA_NOT_ENABLED` | Edge | Chưa test |
| TC-06 | Disable code đúng | AC "disable" | 200, `twoFactorEnabled=false`, `totpSecret=null` | Happy | Chưa test |
| TC-07 | Disable khi chưa bật | — | 400 `TWO_FA_NOT_ENABLED` | Error | Chưa test |
| TC-08 | Verify (login-2FA) code đúng + token hợp lệ | AC "sau email/pw yêu cầu OTP" | 200, access+refresh token | Happy | Chưa test |
| TC-09 | Verify token sai type (dùng access token thường) | — | 401 `TWO_FA_TOKEN_INVALID` | Error | Chưa test |
| TC-10 | Verify token hết hạn (>5 phút) | — | 401 `TWO_FA_TOKEN_INVALID` | Edge | Chưa test |
| TC-11 | Verify code sai | Error "mã confirm sai" | 400 `TWO_FA_CODE_INVALID`, không cấp token | Error | Chưa test |
| TC-12 | Không có bất kỳ UI/field copy secret hay backup codes | AC "KHÔNG copy secret/backup" | Response không chứa secret; không endpoint trả secret | Edge | Chưa test |
| TC-13 | Code lệch ±1 time-step (clock drift) | Edge "đổi giờ" | verify vẫn pass (WINDOW=1) | Edge | Chưa test |
| TC-14 | Disable code sai (đã bật) | Error "mã sai" | 400 `TWO_FA_CODE_INVALID` | Error | Chưa test |
| TC-15 | Verify khi user tắt 2FA giữa chừng | — | 400 `TWO_FA_NOT_ENABLED` | Edge | Chưa test |
| TC-16 | Verify user suspended/deactivated | — | 403 `ACCOUNT_SUSPENDED` / `ACCOUNT_DEACTIVATED` | Error | Chưa test |
| TC-17 | Confirm khi pending secret hết hạn (>10 phút) | — | 400 `TWO_FA_NOT_ENABLED` | Edge | Chưa test |
| TC-18 | BR-86: 5 lần confirm code sai liên tiếp trong 10 phút | Error "quá nhiều lần sai" | Lần 1-4: 400 `TWO_FA_CODE_INVALID`; lần 5: 429 `TWO_FA_TOO_MANY_ATTEMPTS`, counter reset | Error | Chưa test |
| TC-19 | BR-86: verify (login-2FA) sai 5 lần trong 10 phút | Error "quá nhiều lần sai" | Lần 5: 429 `TWO_FA_TOO_MANY_ATTEMPTS` | Error | Chưa test |
| TC-20 | BR-86: code đúng sau vài lần sai (chưa tới 5) | — | 200, counter Redis `2fa:attempt:{userId}` bị xóa | Happy | Chưa test |

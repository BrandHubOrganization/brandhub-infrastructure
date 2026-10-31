# Test Specification — FR 3.2.6: OTP Verification

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.2.6` |
| **Function Name** | OTP Verification |
| **Functional Domain** | Authentication |
| **Canonical Actors / Roles** | `Guest, Owner, Manager, Creator, Client` |
| **Target Class & Method** | `AuthServiceImpl.verifyOtp()` (40 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AuthServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Verify 6-digit email OTP within 10-minute TTL with 5-attempt lockout and activate PENDING_VERIFICATION account |
| **Preconditions** | Can connect with server; User registered, email not verified, OTP valid |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User registered, email not verified, OTP valid | `email` = `user@brandhub.vn`, `otpCode` = `123456` | 200 OK - emailVerifiedAt set, otpCode/otpExpiry cleared | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User registered, email not verified, OTP valid | `email` = `USER@BrandHub.VN`, `otpCode` = `123456` | 200 OK - email normalized then verified | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User registered, email not verified, OTP valid | `email` = `user@brandhub.vn`, `otpCode` = `123456` | 200 OK - attempt counter deleted from Redis | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User registered, email not verified, OTP valid | `email` = `user@brandhub.vn`, `otpCode` = `123456` | 200 OK - user NOT auto logged in (no tokens) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Email already verified | `email` = `user@brandhub.vn`, `otpCode` = `000000` | 200 OK - idempotent no-op, no error | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User registered, email not verified, OTP valid; 1 wrong attempt already | `email` = `user@brandhub.vn`, `otpCode` = `123456` | 200 OK - correct code after a failure still verifies | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Email not verified, no cooldown in Redis | `email` = `user@brandhub.vn` | 200 OK - resendOtp issues new OTP (10 min) and 60s cooldown | OTP email sent | **Passed** |
| `UTCID08` | `N` | Can connect with server; Email already verified | `email` = `user@brandhub.vn` | 200 OK - resendOtp no-op, no email sent | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User registered, email not verified, OTP valid; OTP expires in 1 second | `email` = `user@brandhub.vn`, `otpCode` = `123456` | 200 OK - verified just before expiry | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User registered, email not verified, OTP valid; OTP expired 1 second ago | `email` = `user@brandhub.vn`, `otpCode` = `123456` | OTP_INVALID - 400 Verification code is invalid or has expired | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User registered, email not verified, OTP valid; 4 failed attempts already | `email` = `user@brandhub.vn`, `otpCode` = `111111` | OTP_TOO_MANY_ATTEMPTS - 5th wrong attempt clears OTP, 400 | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User registered, email not verified, OTP valid; 0 failed attempts | `email` = `user@brandhub.vn`, `otpCode` = `111111` | OTP_INVALID - first wrong attempt, counter=1 with 10 min TTL | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Email not registered | `email` = `ghost@brandhub.vn`, `otpCode` = `123456` | USER_NOT_FOUND - 404 User not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User registered, email not verified, OTP valid | `email` = `user@brandhub.vn`, `otpCode` = `999999` | OTP_INVALID - 400 Verification code is invalid or has expired | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; OTP already cleared (otpCode null) | `email` = `user@brandhub.vn`, `otpCode` = `123456` | OTP_INVALID - 400 Verification code is invalid or has expired | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; otpExpiry null | `email` = `user@brandhub.vn`, `otpCode` = `123456` | OTP_INVALID - 400 Verification code is invalid or has expired | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Resend cooldown active (<60s) | `email` = `user@brandhub.vn` | RATE_LIMIT_EXCEEDED - 429 Rate limit exceeded. Please try again later | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Email not registered | `email` = `ghost@brandhub.vn` | USER_NOT_FOUND - 404 resendOtp for unknown email | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.2.6`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — OTP Verification

## Email OTP

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Verify OTP đúng | Verify đúng → `emailVerifiedAt` set | 200, `emailVerifiedAt != null` | Chưa test |
| TC-02 | OTP sai (chưa tới 5 lần) | Error OTP sai | 400 `OTP_INVALID` | Chưa test |
| TC-03 | OTP hết hạn | Error OTP hết hạn | 400 `OTP_INVALID` (gộp chung, không tách `OTP_EXPIRED`) | Chưa test |
| TC-04 | Resend OTP | Sinh OTP mới + gửi | 200, OTP mới trong `users.otp_code` | Chưa test |
| TC-05 | Sai 5 lần liên tiếp | Giới hạn thử | 400 `OTP_TOO_MANY_ATTEMPTS`, `otpCode`/`otpExpiry` bị xóa | Chưa test |
| TC-06 | Verify email chưa đăng ký | — | 404 `USER_NOT_FOUND` | Chưa test |
| TC-07 | Verify email đã verify (gọi lại) | Idempotent | 200, không check lại OTP | Chưa test |
| TC-08 | Resend trong vòng 60s | Rate-limit | 429 `RATE_LIMIT_EXCEEDED` | Chưa test |
| TC-09 | Resend email không tồn tại | — | 404 `USER_NOT_FOUND` | Chưa test |
| TC-10 | Resend khi đã verify | Idempotent | 200, không gửi lại | Chưa test |

## Phone OTP

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-11 | Link phone hợp lệ | Sinh OTP, gửi qua email | 200, Redis `phone:otp:{userId}` có giá trị | Chưa test |
| TC-12 | Link phone không hợp lệ | `PhoneUtil.normalize` trả null | 400 `INVALID_PHONE` | Chưa test |
| TC-13 | Link phone đã được user khác dùng | — | 409 `PHONE_ALREADY_IN_USE` | Chưa test |
| TC-13b | Gọi lại `/link/phone` trong vòng 60s | Rate-limit resend phone | 429 `RATE_LIMIT_EXCEEDED`, OTP cũ không bị ghi đè | Chưa test |
| TC-14 | Verify phone OTP đúng | Verify đúng → set `user.phone` | 200, `user.phone` được cập nhật | Chưa test |
| TC-15 | Verify phone OTP sai (chưa tới 5 lần) | — | 400 `OTP_INVALID` | Chưa test |
| TC-16 | Verify phone OTP khi chưa gọi link/phone hoặc đã hết hạn (10 phút) | Không có key Redis | 400 `OTP_INVALID` | Chưa test |
| TC-17 | Verify phone OTP đúng nhưng phone đã bị người khác lấy trong lúc chờ (race condition) | Edge case race | 409 `PHONE_ALREADY_IN_USE` | Chưa test |
| TC-18 | Verify phone OTP sai 5 lần liên tiếp | Giới hạn thử phone OTP | 400 `OTP_TOO_MANY_ATTEMPTS`; Redis `phone:otp:{userId}` + `phone:otp:attempt:{userId}` bị xóa | Chưa test |
| TC-19 | Sau khi bị `OTP_TOO_MANY_ATTEMPTS`, verify lại bằng mã cũ | Edge (OTP đã hủy) | 400 `OTP_INVALID` (không còn OTP session) | Chưa test |
| TC-20 | `/link/phone` sau khi cooldown 60s hết hạn | Rate-limit resend | 200, sinh OTP mới, counter attempt reset | Chưa test |

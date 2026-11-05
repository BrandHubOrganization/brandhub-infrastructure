# Test Specification — FR 3.2.4: Reset Password

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.2.4` |
| **Function Name** | Reset Password |
| **Functional Domain** | Authentication |
| **Canonical Actors / Roles** | `Guest, Owner, Manager, Creator, Client, Admin` |
| **Target Class & Method** | `AuthServiceImpl.resetPassword()` (31 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AuthServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Consume a valid one-time reset token, update bcrypt password hash, and revoke prior sessions via lastPasswordChange |
| **Preconditions** | Can connect with server; Reset token valid in Redis |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 2, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Reset token valid in Redis | `token` = `valid 64-hex token`, `newPassword` = `NewPass123` | 200 OK - password hash updated | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Reset token valid in Redis | `token` = `valid 64-hex token`, `newPassword` = `NewPass123` | 200 OK - lastPasswordChange set (old refresh tokens rejected) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Reset token valid in Redis | `token` = `valid 64-hex token`, `newPassword` = `NewPass123` | 200 OK - reset token key deleted from Redis | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Reset token valid in Redis | `token` = `valid 64-hex token`, `newPassword` = `NewPass123` | 200 OK - per-user reset pointer key deleted | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Reset token valid in Redis; User has 2FA enabled | `token` = `valid 64-hex token`, `newPassword` = `NewPass123` | 200 OK - password reset, 2FA setting unchanged | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Reset token valid in Redis; OAuth-only user (no password) | `token` = `valid 64-hex token`, `newPassword` = `NewPass123` | 200 OK - password set for the first time | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Reset token valid in Redis | `token` = `valid 64-hex token`, `newPassword` = `P@ss w0rd!long-pass` | 200 OK - long password with symbols accepted | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Reset requested twice (second token valid) | `token` = `second token`, `newPassword` = `NewPass123` | 200 OK - latest token works | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Reset token valid in Redis | `token` = `valid 64-hex token`, `newPassword` = `Abcdef12` | 200 OK - password exactly 8 chars with digit accepted | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Reset token valid in Redis | `token` = `valid 64-hex token`, `newPassword` = `Abcdef1` | VALIDATION_ERROR - Password must be at least 8 characters (7 chars) | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Token not in Redis | `token` = `unknown token`, `newPassword` = `NewPass123` | RESET_TOKEN_INVALID - 400 Password reset token is invalid or has expired | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Token TTL expired | `token` = `expired token`, `newPassword` = `NewPass123` | RESET_TOKEN_INVALID - 400 Password reset token is invalid or has expired | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Token replaced by newer reset request | `token` = `old token`, `newPassword` = `NewPass123` | RESET_TOKEN_INVALID - 400 Password reset token is invalid or has expired | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Token deleted concurrently after read | `token` = `racing token`, `newPassword` = `NewPass123` | RESET_TOKEN_USED - 400 Password reset token has already been used | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Token maps to deleted user | `token` = `valid 64-hex token`, `newPassword` = `NewPass123` | RESET_TOKEN_INVALID - 400 Password reset token is invalid or has expired | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Reset token valid in Redis | `token` = `valid 64-hex token`, `newPassword` = `Abcdefgh` | VALIDATION_ERROR - Password must contain at least one number | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Reset token valid in Redis | `token` = `valid 64-hex token`, `newPassword` = `empty` | VALIDATION_ERROR - newPassword must not be blank | — | **Passed** |
| `UTCID18` | `A` | Can connect with server | `token` = `empty`, `newPassword` = `NewPass123` | VALIDATION_ERROR - token must not be blank | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.2.4`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Reset Password

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Forgot-password email tồn tại | AC "gửi email" | 200, gửi email thật | Chưa test |
| TC-02 | Forgot-password email không tồn tại | Error "không tiết lộ" | 200, KHÔNG gửi email thật | Chưa test |
| TC-03 | Reset với token hợp lệ | AC "đổi thành công" | 200, password mới có hiệu lực | Chưa test |
| TC-04 | Reset token sai/hết hạn | Error "RESET_TOKEN_INVALID" | 400 `RESET_TOKEN_INVALID` | Chưa test |
| TC-05 | Đổi xong → refresh token cũ bị từ chối | AC "buộc login lại mọi thiết bị" | `/refresh` với token cũ (issued < `lastPasswordChange`) → 401 | Chưa test |
| TC-06 | Request forgot-password 2 lần liên tiếp → dùng token đầu (chưa hết TTL) | Edge "chỉ token mới hiệu lực" | Token đầu → `400 RESET_TOKEN_INVALID` ngay (đã bị reverse-index xoá khi token 2 được tạo), KHÔNG phải `RESET_TOKEN_USED` | Chưa test |
| TC-06b | Sau TC-06, dùng token 2 (mới nhất) | Edge "chỉ token mới hiệu lực" | 200, reset thành công | Chưa test |
| TC-07 | Reset token dùng lần 2 (cùng 1 token, gọi lại) | Error "RESET_TOKEN_USED" | 400 `RESET_TOKEN_USED` | Chưa test |
| TC-08 | newPassword yếu (<8 ký tự / thiếu số) | Error "VALIDATION_ERROR" | 400 `VALIDATION_ERROR` | Chưa test |

> Lưu ý TC-06: trước đây (code cũ) token đầu vẫn hợp lệ song song tới khi tự hết hạn hoặc bị dùng — giờ đã đổi hành vi: token đầu bị vô hiệu hoá NGAY khi token 2 được sinh ra (reverse-index `pwd:reset:user:{userId}` xoá token cũ). Test case sửa lại kỳ vọng cho khớp.

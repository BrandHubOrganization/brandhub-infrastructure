# Test — Deactivate Account

## Flow A — User có password

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Deactivate password đúng | AC "set status=DEACTIVATED" | 200, soft-delete (không xóa cứng) | Chưa test |
| TC-02 | Password sai | Error "WRONG_CURRENT_PASSWORD" | 400 `WRONG_CURRENT_PASSWORD` | Chưa test |
| TC-03 | Owner Agency active | Edge "Owner duy nhất Agency" | 409 `AGENCY_OWNERSHIP_ACTIVE`, không deactivate | Chưa test |
| TC-04 | Login sau deactivate | AC "không login được" | 403 `ACCOUNT_DEACTIVATED` | Chưa test |
| TC-05 | Dữ liệu liên quan còn trong DB | AC "giữ dữ liệu" | User/Agency/Workspace record vẫn tồn tại | Chưa test |
| TC-06 | Agency chỉ còn SOFT_DELETED/INACTIVE | Edge "không còn agency active" | 200, cho deactivate | Chưa test |
| TC-07 | Deactivate lại user đã deactivated | Edge "idempotent" | 400 `WRONG_CURRENT_PASSWORD` (re-match password) | Chưa test |

## Flow B — User OAuth-only (OTP) — MỚI

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-08 | `send-otp` thành công | AC "nhận OTP qua email" | 200, Redis có key `otp:deactivate:{userId}` TTL~10 phút, email gửi đi | Chưa test |
| TC-09 | `send-otp` thiếu/sai Bearer token | Error "INVALID_CREDENTIALS" | 401 `INVALID_CREDENTIALS` | Chưa test |
| TC-10 | `deactivate` với OTP đúng (đã gọi send-otp trước) | AC "set status=DEACTIVATED" | 200, soft-delete, Redis key bị xóa | Chưa test |
| TC-11 | `deactivate` với OTP sai | Error "OTP_INVALID" | 400 `OTP_INVALID` | Chưa test |
| TC-12 | `deactivate` với OTP hết hạn (>10 phút) | Error "OTP_INVALID" | 400 `OTP_INVALID` | Chưa test |
| TC-13 | `deactivate` không gửi `otpCode`, hoặc chưa từng gọi `send-otp` | Error "OTP_INVALID" | 400 `OTP_INVALID` | Chưa test |
| TC-14 | `deactivate` dùng lại OTP đã verify thành công trước đó | Edge "OTP dùng 1 lần" | 400 `OTP_INVALID` (key đã bị xóa) | Chưa test |
| TC-15 | User OAuth-only là Owner Agency active | Edge "Owner duy nhất Agency" (Flow B) | 409 `AGENCY_OWNERSHIP_ACTIVE`, không deactivate, OTP đã bị xóa (không tái sử dụng) | Chưa test |
| TC-16 | Login sau deactivate (Flow B) | AC "không login được" | 403 `ACCOUNT_DEACTIVATED` | Chưa test |

## Regression — đảm bảo 2 flow không lẫn nhau

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-17 | User có password gửi `otpCode` thay vì `password` | Edge "field sai flow bị bỏ qua" | 400 `WRONG_CURRENT_PASSWORD` (BE vẫn theo nhánh password vì `passwordHash != null`) | Chưa test |
| TC-18 | User OAuth-only gửi `password` thay vì `otpCode` | Edge "field sai flow bị bỏ qua" | 400 `OTP_INVALID` (BE vẫn theo nhánh OTP vì `passwordHash == null`) | Chưa test |

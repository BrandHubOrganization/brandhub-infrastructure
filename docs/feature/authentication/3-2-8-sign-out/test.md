# Test — Sign Out

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Logout hợp lệ | AC "revoke + xóa storage" | 200, refresh token bị revoke | Chưa test |
| TC-02 | Logout token đã hết hạn | Error "idempotent" | 200 idempotent, refresh vẫn bị revoke nếu có | Chưa test |
| TC-03 | Logout thiết bị A không ảnh hưởng B | Edge "đa thiết bị" | B vẫn active | Chưa test |
| TC-04 | Sau logout, lần sau highlight đúng method | AC "lastUsedLoginMethod" | FE local storage lưu đúng, render đúng | Chưa test |
| TC-05 | Không có token | — | 401 (controller trả unauthorized) | Chưa test |
| TC-06 | Logout token tampered/sai chữ ký | Error "không 500" | 200 idempotent, không 500 | Chưa test |
| TC-07 | Logout hợp lệ có header `X-Forwarded-For` + `User-Agent` | AC audit log | Bản ghi `audit_logs` (LOGOUT) có `ip_address` + `user_agent` đúng giá trị header | Chưa test |
| TC-08 | Logout không gửi `X-Forwarded-For`/`User-Agent` | Edge | 200; audit log có `ip_address`/`user_agent` = null, không lỗi | Chưa test |
| TC-09 | **[MỚI 2026-09-25]** FE click "Log out" (Navbar) | AC "FE gọi endpoint thật" | `authService.logout()` được gọi (network tab thấy `POST /api/v1/auth/logout`), `clearAuth()` + redirect `/login` không chờ response | Chưa test |
| TC-10 | **[MỚI 2026-09-25]** FE logout khi API lỗi/offline | Edge "best-effort catch" | `.catch(() => {})` nuốt lỗi; vẫn `clearAuth()` + redirect `/login`, không toast lỗi | Chưa test |

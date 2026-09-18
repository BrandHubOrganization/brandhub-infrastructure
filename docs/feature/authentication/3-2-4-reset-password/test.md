# Test — Reset Password

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Forgot-password email tồn tại | AC "gửi email" | 200, gửi email thật | Chưa test |
| TC-02 | Forgot-password email không tồn tại | Error "không tiết lộ" | 200, KHÔNG gửi email thật | Chưa test |
| TC-03 | Reset với token hợp lệ | AC "đổi thành công" | 200, password mới có hiệu lực | Chưa test |
| TC-04 | Reset token sai/hết hạn | Error "INVALID_OR_EXPIRED_TOKEN" | 400 `RESET_TOKEN_INVALID` | Chưa test |
| TC-05 | Đổi xong → revoke refresh cũ | AC "revoke toàn bộ" | Mọi thiết bị buộc login lại | Chưa test |
| TC-06 | Request nhiều lần → token cũ invalid | Edge "chỉ token mới hiệu lực" | Chỉ token mới nhất dùng được | Chưa test |
| TC-07 | Reset token dùng lần 2 | Error "RESET_TOKEN_USED" | 400 `RESET_TOKEN_USED` | Chưa test |
| TC-08 | newPassword yếu (<8 ký tự / thiếu số) | Error "VALIDATION_ERROR" | 400 `VALIDATION_ERROR` | Chưa test |

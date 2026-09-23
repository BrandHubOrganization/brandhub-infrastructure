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

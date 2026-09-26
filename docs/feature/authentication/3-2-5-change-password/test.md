# Test — Change Password

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Đổi password với currentPassword đúng | AC "đổi thành công" | 200, login được bằng password mới | Chưa test |
| TC-02 | currentPassword sai | Error "WRONG_CURRENT_PASSWORD" (check trước) | 400 `WRONG_CURRENT_PASSWORD` | Chưa test |
| TC-03 | currentPassword đúng, newPassword == currentPassword | Error "SAME_AS_CURRENT_PASSWORD" (check sau khi currentPassword đã đúng) | 400 `SAME_AS_CURRENT_PASSWORD` | Chưa test |
| TC-04 | Đổi xong không tự logout session hiện tại | AC "không logout" | 200, access token hiện tại vẫn dùng được | Chưa test |
| TC-05 | Không có token / sai format Bearer | — | 401 `INVALID_CREDENTIALS` | Chưa test |
| TC-06 | newPassword yếu (<8 ký tự / thiếu số) | Error "VALIDATION_ERROR" | 400 `VALIDATION_ERROR` | Chưa test |
| TC-07 | OAuth-only account (không password) | — | 400 `WRONG_CURRENT_PASSWORD` | Chưa test |
| TC-08 | currentPassword vừa sai vừa newPassword trùng currentPassword thật | Thứ tự ưu tiên: check currentPassword sai trước | 400 `WRONG_CURRENT_PASSWORD` (không phải `SAME_AS_CURRENT_PASSWORD`) | Chưa test |
| TC-09 | Đổi password thành công, sau đó thử refresh token cũ (issued trước lúc đổi) | Side-effect `lastPasswordChange` | 401 `REFRESH_TOKEN_INVALID` | Chưa test |

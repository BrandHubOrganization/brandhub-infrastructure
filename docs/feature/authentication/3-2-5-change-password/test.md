# Test — Change Password

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Đổi password với currentPassword đúng | AC "đổi thành công" | 200, login được bằng password mới | Chưa test |
| TC-02 | currentPassword sai | Error "INVALID_CURRENT_PASSWORD" | 400 `WRONG_CURRENT_PASSWORD` | Chưa test |
| TC-03 | newPassword == currentPassword | Error "SAME_AS_CURRENT_PASSWORD" | 400 `SAME_AS_CURRENT_PASSWORD` | Chưa test |
| TC-04 | Đổi xong không tự logout | AC "không logout" | Session vẫn active | Chưa test |
| TC-05 | Không có token | — | 401 `INVALID_CREDENTIALS` | Chưa test |
| TC-06 | newPassword yếu (<8 ký tự / thiếu số) | Error "VALIDATION_ERROR" | 400 `VALIDATION_ERROR` | Chưa test |
| TC-07 | OAuth-only account (không password) | — | 400 `WRONG_CURRENT_PASSWORD` | Chưa test |

# Test — Sign In with Google OAuth

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Consent → callback thành công | AC "redirect consent" | 200, access+refresh token | Chưa test |
| TC-02 | Email Google đã có User (password) | Edge "merge" | Login account cũ, không tạo User trùng | Chưa test |
| TC-03 | Email Google chưa có User | AC "tạo User mới" | Tạo User `emailVerified=true` + `isNewUser=true` | Chưa test |
| TC-04 | User cancel consent | Error "user cancel" | Redirect `/login` + thông báo lỗi | Chưa test |
| TC-05 | Token exchange body form-urlencoded | AC "fix bug flow không chạy" | Google trả access_token, không lỗi content-type | Chưa test |
| TC-06 | State sai/đã dùng | Error (CSRF) | Từ chối, redirect `/login` + lỗi | Chưa test |
| TC-07 | Google code exchange fail | Error "OAUTH_CODE_INVALID" | 400 `OAUTH_CODE_INVALID` | Chưa test |
| TC-08 | Callback user deactivated/suspended | Error "ACCOUNT_SUSPENDED" | 403 `ACCOUNT_SUSPENDED` | Chưa test |
| TC-09 | State replay (dùng lại state đã consume) | Edge "CSRF replay" | 400 `OAUTH_STATE_INVALID` | Chưa test |

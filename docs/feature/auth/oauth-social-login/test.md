# Test — OAuth social login

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Redirect đúng | GET /oauth/{provider} | 302, URL có client_id/redirect_uri/scope/state | ☐ |
| 2 | State lưu Redis | redirect | `oauth:state:*` tồn tại TTL | ☐ |
| 3 | Callback state hợp lệ | code + state | 200 JWT, user link/tạo đúng | ☐ |
| 4 | Callback state sai/hết hạn | state lạ | 400 OAUTH_STATE_INVALID | ☐ |
| 5 | Email mới | provider email chưa có | tạo user + link provider | ☐ |
| 6 | Email trùng | provider email có sẵn | link user cũ, không tạo mới | ☐ |
| 7 | Email null | provider không trả email | 400 EMAIL_REQUIRED | ☐ |
| 8 | Login cùng provider 2 lần | lặp lại | cùng user, không trùng provider_id | ☐ |
| 9 | Frontend | bấm nút OAuth | redirect provider, callback → dashboard | ☐ |

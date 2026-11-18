# BrandHub load test (k6)

Chỉ test các API đọc (workspace, dashboard, posts, campaigns, members). Không gọi AI vì sẽ tốn quota Groq.

## Chuẩn bị
1. Cài k6: `winget install GrafanaLabs.k6`
2. Tạo 20–50 tài khoản test (tài khoản đã xác thực, không bật 2FA, mỗi tài khoản có ít nhất 1 workspace).
3. Tạo file `users.json` (đã git-ignore):
   ```json
   [{"identifier":"loadtest1@example.com","password":"..."}]
   ```
   Gateway giới hạn 100 request/phút cho mỗi user. Nếu chỉ dùng 1 tài khoản, kết quả sẽ chủ yếu là lỗi 429.

## Chạy
| Profile | Mục đích | Thời gian |
|---|---|---|
| `smoke` | Kiểm tra script, 5 VU | 1 phút |
| `load` | Tăng dần tới 600 VU, xác nhận mức ước tính | 14 phút |
| `stress` | Tăng tới 1600 VU, tìm điểm gãy | 13 phút |
| `soak` | Giữ 400 VU trong 1 giờ, xem gateway t3.small khi hết CPU credit | 60 phút |

```
k6 run -e BASE_URL=https://api.brandhub.id.vn -e USERS_FILE=users.json -e PROFILE=smoke brandhub-api.k6.js
```

## Đọc kết quả
- Mỗi VU gửi khoảng 1 request mỗi 10 giây, nên số VU giữ được ở `p(95)<800ms` và lỗi dưới 1% chính là số người online chịu được.
- Trong lúc test, theo dõi CPU/RAM của core (`docker stats`) và chỉ số `CPUCreditBalance` của gateway trên CloudWatch.
- Nên chạy vào giờ thấp điểm vì test bắn vào prod thật.

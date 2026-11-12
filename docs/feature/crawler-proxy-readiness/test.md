# Test — crawler-proxy-readiness

Chạy: `cd social_crawler && python -m pytest tests/test_proxy_runtime.py -q`

| # | Test | Kỳ vọng |
|---|---|---|
| T1 | Proxy từ chối 4 lần rồi nhận kết nối ở lần 5 | `check_proxy` trả về bình thường, gọi kết nối 5 lần |
| T2 | Proxy timeout mọi lần | `PROXY_CONNECT_FAILED` sau đúng 12 lần kết nối, 11 lần nghỉ; log có `TIMEOUT`, không có mật khẩu |
| T3 | Lỗi tạm thời rồi thành công (hiện có) | Qua ở lần 2 |
| T4 | Proxy không tới được trong `prepare_proxy` (hiện có) | `PROXY_CONNECT_FAILED`, `FB_CRAWLER_HTTP_PROXY` giữ giá trị cũ |
| T5 | Toàn bộ `test_proxy_runtime.py` | Pass |

## Kiểm chứng thực tế

| Ngày | Cách đo | Kết quả |
|---|---|---|
| 12/11/2026 | Xin proxy `new`, thử TCP + CONNECT mỗi giây | Sẵn sàng ở giây 18,1 |
| Sau deploy | Admin → Crawl → Lịch sử | Lần chạy dùng proxy mới không còn `PROXY_CONNECT_FAILED` |

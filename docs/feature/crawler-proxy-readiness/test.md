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

## Diagnostics

| # | Test | Kỳ vọng |
|---|---|---|
| D1 | Lỗi tạm rồi thành công | stdout có `[PROXY] connect ok attempt=2/3`, không có mật khẩu/host/port |
| D2 | Timeout mọi lần | stdout có đúng 3 dòng `PROXY_CONNECT_ATTEMPT_FAILED ... reason=TIMEOUT` |
| D3 | `current` hết hạn → `new` | stdout có `provider current not reusable`, `provider new: ... allowed_ip=13.x.x.126`, `note=...`; không có key/host/port |

Đọc kết quả trên production:

| Dòng log | Ý nghĩa |
|---|---|
| `reason=TIMEOUT` ở cả 3 lần, `age` nhỏ | Proxy mới chưa sẵn sàng (cần chờ lâu hơn) |
| `reason=CONNECTION_REFUSED` | Proxy chủ động từ chối (sai IP được phép hoặc proxy chết) |
| `reason=DNS_FAILED` / `NETWORK_ERROR` | Lỗi mạng phía EC2 |
| `provider current unavailable: PROXY_PROVIDER_HTTP_...` | API KiotProxy lỗi hoặc key hết hạn |

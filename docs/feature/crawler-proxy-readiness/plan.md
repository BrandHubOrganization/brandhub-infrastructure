# Plan — crawler-proxy-readiness

## Thay đổi

Repo `brandhub-ai-service`, nhánh `fix/DA-1238-crawler-proxy-readiness`:

| File | Thay đổi |
|---|---|
| `social_crawler/src/crawlfb/proxy_runtime.py` | Thêm hằng số `CONNECT_ATTEMPTS = 12`; vòng thử trong `check_proxy` dùng hằng số này thay cho `3`; log `attempt=%s/%s` |
| `social_crawler/tests/test_proxy_runtime.py` | Cập nhật test giới hạn số lần thử; chặn `time.sleep` thật trong test proxy không tới được; thêm test proxy sẵn sàng ở lần thử thứ 5 |

Không đổi `prepare_proxy`, `resolve_proxy`, mã lỗi, cấu hình, Docker hay tài liệu khác.

## Lý do chọn số lần thử

Đo thật: proxy mới sẵn sàng sau khoảng 18 giây. 12 lần × (timeout 4 giây + nghỉ 1 giây) ≈ 59 giây,
dư hơn 3 lần thời gian đo được. Giữ cấu trúc vòng thử hiện có, chỉ đổi số lần.

## Rủi ro

Proxy chết hẳn → lần crawl báo lỗi chậm hơn khoảng 45 giây. Không ảnh hưởng dữ liệu.

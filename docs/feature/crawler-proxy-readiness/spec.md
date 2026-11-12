# Spec — crawler-proxy-readiness

## Objective

Crawler không được bỏ một lần crawl chỉ vì proxy KiotProxy vừa cấp chưa kịp nhận kết nối.

## Bối cảnh

- Từ commit `ef6fcbd` (02/11/2026), `prepare_proxy` kiểm tra proxy bằng `check_proxy` trước khi crawl.
  Kiểm tra thất bại → `PROXY_CONNECT_FAILED` → cả lần crawl dừng (trước đó crawler vẫn chạy tiếp).
- `check_proxy` thử TCP 3 lần, mỗi lần timeout 4 giây, nghỉ 1 giây: tổng khoảng 14 giây.
- Đo thật ngày 12/11/2026: proxy vừa xin bằng `new` timeout liên tục, **nhận kết nối ở giây 18,1**,
  CONNECT tới `www.facebook.com:443` trả `200` ở giây 18,3.
- Log production 12/11: proxy cấp lúc `09:16:02 UTC`, crawl dừng `09:16:16 UTC` với `PROXY_CONNECT_FAILED`.
  Key hợp lệ, `allowedIp` đúng IP EC2, Security Group cho mọi kết nối đi ra.

## User Story

Là admin, khi lịch crawl chạy và crawler phải xin proxy mới, tôi muốn crawler chờ proxy sẵn sàng
thay vì kết thúc thất bại, để mỗi ngày đều có dữ liệu trend.

## Acceptance Criteria

1. `check_proxy` chờ proxy tối đa khoảng 60 giây (12 lần thử, timeout 4 giây, nghỉ 1 giây giữa các lần).
2. Proxy nhận kết nối ở lần thử bất kỳ trong khoảng đó → kiểm tra qua, crawl tiếp.
3. Proxy không nhận kết nối sau 12 lần → vẫn báo `PROXY_CONNECT_FAILED` như cũ.
4. `PermissionError` (`ACCESS_DENIED`) vẫn dừng ngay, không thử lại.
5. Log vẫn không chứa endpoint, mật khẩu hay nội dung exception; chỉ ghi số lần thử và lý do.
6. `FB_CRAWLER_HTTP_PROXY` không bị ghi đè khi kiểm tra thất bại (hành vi hiện có).

## API Contract

Không đổi. `check_proxy(value)` giữ chữ ký; mã lỗi giữ nguyên.

## Error Handling

| Tình huống | Kết quả |
|---|---|
| Timeout / từ chối / lỗi mạng | Thử lại tới lần 12 rồi `PROXY_CONNECT_FAILED` |
| `PermissionError` | `PROXY_CONNECT_FAILED` ngay |
| Endpoint sai định dạng | `PROXY_INVALID_ENDPOINT` (không đổi) |

## Edge Cases

- Proxy hỏng hẳn: lần crawl chờ thêm khoảng 45 giây trước khi báo lỗi. Chấp nhận được với lịch crawl hằng ngày.
- Proxy dùng lại bằng `current` (đã sẵn sàng): thường qua ở lần thử đầu, không chậm thêm.

## Definition of Done

Code + test pass trong `social_crawler/tests/test_proxy_runtime.py`; tài liệu 4 file; commit local trên nhánh riêng,
chờ người duyệt merge.

## Out of Scope

- Ngưỡng bộ nhớ `CRAWLER_RAM_SOFT_PERCENT` (container 5 GB).
- Chạy bù lần crawl bị deploy ngắt.
- Cookie Facebook hết hạn.
- Tham số hoá thời gian chờ qua biến môi trường.

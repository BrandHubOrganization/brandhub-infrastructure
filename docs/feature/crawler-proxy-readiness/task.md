# Task — crawler-proxy-readiness

- [x] Tái hiện lỗi production: `PROXY_CONNECT_FAILED` 14 giây sau khi xin proxy mới (log admin 12/11).
- [x] Đo thời gian proxy mới sẵn sàng: khoảng 18 giây.
- [x] Loại trừ: key, `allowedIp`, Security Group egress.
- [x] Viết spec/plan/task/test.
- [x] Viết test proxy sẵn sàng ở lần thử thứ 5 (đỏ trước khi sửa: dừng ở 3/3).
- [x] Đổi `check_proxy` sang 12 lần thử.
- [x] Cập nhật test giới hạn số lần thử và chặn `sleep` thật.
- [x] Chạy `social_crawler/tests/test_proxy_runtime.py` → 19 pass. Toàn bộ `social_crawler/tests` → 262 pass,
      2 lỗi có sẵn do môi trường Windows/worktree (cũng lỗi trên code chưa sửa).
- [x] Commit local trên nhánh riêng (không push).
- [ ] Sau khi merge + deploy: kiểm tra trang Admin → Crawl → Lịch sử không còn `PROXY_CONNECT_FAILED`.

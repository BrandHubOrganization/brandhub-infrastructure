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

## Diagnostics (12/11/2026, sau khi PR #70 bị revert ở PR #71)

- [x] Tìm lý do log Admin thiếu chi tiết: Admin chỉ giữ stdout, stderr bị bỏ (`crawler_management.py`, `stderr=DEVNULL`).
- [x] `proxy_runtime.py` in `[PROXY] ...` ra stdout: nguồn proxy (current/new), location, authMode, authNote,
      allowed_ip (che 2 số giữa), ttc, age; mỗi lần thử kết nối kèm reason và thời gian; thành công ở lần thử nào.
- [x] Không đổi số lần thử (giữ 3 như develop).
- [x] Test: không in key, host, port, mật khẩu.
- [x] Deploy (`sha-6a21ffb-62`), chạy crawl 13/11 01:43 UTC. Admin không hiện `[PROXY]` vì `detail()` chỉ giữ
      dòng `[RUN]`/`[CRAWL]`/`[DELIVERY]`/`[WARN]`; đọc file log gốc trên EC2 qua SSM.

## Kết luận và sửa lần 2 (13/11/2026)

- [x] Log gốc run `d235bccacb594cfdaf171b2abc6df876`: đầu run proxy mới (`age=0s`) TIMEOUT lần 1, ok lần 2;
      lúc đổi proxy định kỳ proxy mới TIMEOUT cả 3 lần (14s) → `proxy refresh failed`, dừng 25 nguồn.
      Xác nhận nguyên nhân: proxy mới cần hơn 14s mới nhận kết nối.
- [x] Đưa lại 12 lần thử (~59s) trên nền code diagnostics; log ghi `attempt=x/12`.
- [x] Admin hiện dòng `[PROXY]` (thêm vào bộ lọc `detail()`; dòng này không chứa key/host/port).
- [x] Test: `test_proxy_runtime.py` 20 pass; `test_crawler_management.py` 8 pass; toàn bộ crawler 263 pass,
      2 lỗi có sẵn do môi trường Windows.
- [ ] Sau deploy: Admin → Crawl → Lịch sử thấy dòng `[PROXY]`, lần đổi proxy không còn `PROXY_CONNECT_FAILED`.

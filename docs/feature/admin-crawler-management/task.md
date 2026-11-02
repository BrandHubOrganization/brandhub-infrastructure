# Checklist thực hiện — IMPLEMENTING

- [x] Review 18 BA còn lại (giữ mã cũ, bỏ BA-01 và BA-17) và chốt 6 quyết định trong spec.
- [x] Đọc đủ spec/plan/task/test, kiểm tra AGENTS/CLAUDE/rule của repo trước code.
- [x] Chuẩn hóa Docker deps/browser và kiểm chứng non-root, không bake session/env vào image.
- [x] Thiết kế persistent runtime root, migration và rollback config/session/manifest/history.
- [x] Xác định scheduler owner, khóa chạy chung, heartbeat và timezone migration.
- [x] API readiness nhiều check độc lập, phân biệt stale/unknown và manual/scheduled.
- [x] API session upload/metadata/probe/revoke, version và bản làm việc theo run.
- [ ] Secret encryption, TLS nội bộ, limits, allowlist và redaction; không thêm account/role.
- [x] Proxy/TikTok masked replace/probe; kiểm soát rate/cost và no-direct-fallback.
- [x] Nguồn/giới hạn và preview snapshot, chọn platform cho một run.
- [x] Stop-request state machine, flush/manifest closure và xử lý batch đã gửi.
- [x] Event/log/detail/history pagination và recovery; dùng `/admin?view=trends` hiện có để kiểm tra dữ liệu đầu ra.
- [ ] Business auth/audit/file validation/error contracts; kiểm tra secret logging gateway.
- [x] Web layout các mục, form trạng thái và run details trên trang hiện có.
- [x] Cập nhật key song song `vi/admin.json` + `en/admin.json`, không hardcode UI text.
- [ ] Kiểm tra light/dark mode, keyboard/screen reader và responsive.
- [ ] Chạy tests bảo mật, concurrency, restart, publication và stop/recovery theo test.md.
- [x] Chạy Web `npm run ci`, AI checks và Business checks phù hợp theo CI repo.
- [ ] Review diff + demo dev + xác nhận readiness triển khai; không tự thay production.
- [ ] Sau khi được phép: CI/CD deploy immutable image/migration có backup và smoke checks.
- [ ] P1 BA-16/20 chỉ thực hiện khi scope này được duyệt.

## Kết quả dev

- Đã hiện thực nhóm P0 ở code và P1 cảnh báo/retry nguồn Facebook như giới hạn ghi trong plan.
- Secret encryption/allowlist/redaction và chặn Business → AI qua HTTP ngoài loopback đã có code/test. TLS thực tế toàn đường truyền, key mount và migration production là release gates chưa thực hiện.
- Đã kiểm tra UI vi/en, light/dark, mobile 390px không tràn ngang, keyboard Escape và semantic accessibility tree. Chưa kiểm bằng thiết bị screen reader thực tế.
- Regression: 23 Python tests, 9 Java tests; Web npm run ci đạt. Docker image build đạt; browser offline non-root đạt; container recreation giữ credential/config/history bằng volume giả đạt.
- Chưa chạy crawl thật, chưa thử provider/proxy thật, chưa E2E worker với dịch vụ production và chưa deploy. Các task kiểm chứng toàn hệ thống/release vẫn mở để không ghi nhận hoàn tất giả.

- [x] Sửa browser readiness theo Python của runner, thêm mã lỗi rõ ràng cho local/Windows và kiểm tra venv thực tế. API local đã trả Browser OK và manualReady true.

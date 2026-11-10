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

## Proxy runtime Docker
- [x] Thay luồng ghi dotenv bằng resolver trong bộ nhớ và truyền env cho child.
- [x] Retry Facebook và Threads dùng resolver chung; lỗi proxy dừng sớm và giữ manifest/delivery.
- [x] Kiểm tra regression thiếu .env, env cũ, provider/TCP lỗi, fixed/direct và log không lộ secret.

## Session RAM theo yêu cầu (2026-11-02)
- [x] Store RAM và IPC stdin cho preflight/run/probe/CLI; bỏ fallback file/Redis trong luồng admin session.
- [x] UI upload session không cần khóa, thông báo mất session khi restart; giữ bảo vệ proxy/TikTok.
- [x] Test snapshot/revoke/restart/no-write/child handoff, validation và Web CI.

## Deploy disk guard (2026-11-02)
- [x] Thêm script cleanup có scope/retention/disk guard và unit test bằng Docker giả lập.
- [x] Gắn preflight trước sửa compose/pull; xác minh workflow và chạy dry-run production chỉ đọc.

## Sửa quyền volume và chẩn đoán rollback (2026-11-02)
- [x] Init volume crawler có giới hạn đường dẫn, quyền appuser và kiểm tra an toàn/idempotence.
- [x] Gắn init trước recreate; log/health redacted trước rollback và kiểm tra ảnh mới sau healthy.
- [x] Unit tests, workflow syntax/order và smoke Docker volume giả bằng non-root scheduler.

## Retention khi rollout thất bại (2026-11-02)
- [x] Sửa chọn rollback image để không giữ image rollout thất bại mới hơn bản đang chạy.
- [x] Regression trường hợp failed image mới nhất, old rollback, target, foreign tag và initial deploy.
- [x] Dry-run production chỉ đọc và xác nhận vẫn giữ image đang chạy/ngưỡng 6 GiB.


## Rút gọn overview (2026-11-02)
- [x] Chỉ render run gần nhất trong managed control, bao gồm run đã kết thúc.
- [x] Hiện banner khi có history; giữ tab lịch sử đầy đủ.
- [x] Kiểm tra build và UI nhiều run, active, completed, interrupted, empty, mobile/light/dark.


## Thư mục worker có quyền ghi (2026-11-03)
- [x] Đồng bộ config, Dockerfile, env example, compose và workflow.
- [x] Init quyền thư mục worker trong volume; regression paths/init.
- [x] Unit tests lưu batch/aggregation/label-check và init volume: 18 passed.
- [x] Smoke Docker UID1000 ghi atomic batch và label_check trên volume giả root-owned; init idempotent; parent/dữ liệu ngoài crawler không đổi.


## Cài browser ổn định trong build (2026-11-03)
- [x] Thêm installer pinned và regression cấm update nền.
- [x] Chạy đầy đủ CI AI: flake8 pass, 995 unit tests pass với coverage.
- [x] Full Docker build Linux pass sau khi Docker bật; installer + info --quick pass, final-image smoke browser/worker pass; warm-cache rebuild 4.8 giây.


## Giới hạn RAM AI 4.5 GiB (2026-11-03)
- [x] Cập nhật Compose/overlay và lệnh deploy CI/CD.
- [x] Kiểm tra Compose render và generated deployment command giữ cấu hình khác.
- [x] Chạy CI AI sau thay đổi: flake8 pass, 995 tests pass.

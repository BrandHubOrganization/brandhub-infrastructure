# Kế hoạch kiểm chứng — DEV VERIFIED / release gates còn mở

Dev dùng fixture session giả, provider mock, queue/DB cô lập. Không commit file cookie thật, không tự gọi provider trả phí hoặc ghi live trong QA. Đây là acceptance/integration/security scenarios; không viết unit test chỉ lặp lại implementation.

| Case | BA | Kết quả cần chứng minh |
|---|---|---|
| T01 | 18 | Existing Admin được phép; non-admin/anonymous/internal key sai bị chặn ở backend; không tạo account/role. |
| T02 | 02,03 | Thiếu browser + session + worker đồng thời hiển thị đủ; check lỗi không che check khác; timestamp cũ là stale/unknown. |
| T03 | 03,10 | Scheduler dừng không chặn manual đủ điều kiện; schedule enabled nhưng không heartbeat không báo healthy. |
| T04 | 04 | TikTok thiếu key không chặn run Facebook-only; chọn TikTok phải giải thích blocker, không silently skip. |
| T05 | 05 | JSON hỏng, quá size, domain sai, cookie shape/type sai, filename traversal đều bị từ chối; bản active cũ không đổi. |
| T06 | 05,18 | Upload/probe/status/error/audit/log/frontend cache không chứa cookie/key; CSRF/rate limit/access control phù hợp cơ chế auth. |
| T07 | 06,08 | Probe phân biệt login/checkpoint/proxy timeout/provider auth và unknown; static polling không phát sinh external call. |
| T08 | 07,19 | Replace/revoke lúc run hoạt động: run hiện tại giữ version, run sau đổi version; browser ghi cookie không sửa upload gốc. |
| T09 | 07,18 | Secret ciphertext không đọc được nếu thiếu khóa; file decrypt quyền tối thiểu; retention không xóa version còn tham chiếu. |
| T10 | 08,09 | Chặn endpoint nội bộ/metadata IP và redirect không được phép; proxy lỗi không tự direct; key chỉ replace, không read-back. |
| T11 | 10 | Đúng timezone/next 3 fires; giữ cron custom; migration lịch UTC không tự đổi giờ chạy; pause không hủy active run. |
| T12 | 11 | Manual đồng thời/scheduler/API nhiều process chỉ tạo 1 run; retry request không duplicate; preview không start. |
| T13 | 11,12 | Test nhỏ không ghi live; run thật dùng cùng pipeline và snapshot; không mock success hoặc fake progress %. |
| T14 | 12 | Worker disconnect/failed batch/resolution failure phản ánh QUEUED/PARTIAL/FAILED đúng; DB success + cache failure không COMPLETED. |
| T15 | 13 | Stop khi starting/crawling/queued/processing: không nhận nguồn mới, giữ dữ liệu, manifest closure đúng, downstream đã nhận tiếp tục; race hoàn thành xử lý idempotent. |
| T16 | 14 | Fault chứa secret trong exception/proxy URL bị redaction; log pagination bounded; correlation theo run/source đúng. |
| T17 | 15,19 | Recreate container vẫn có config/session/history/manifest; interrupted recovery không crawl lại/publish trùng; mất artifact có lỗi rõ. |
| T19 | 19 | Concurrent admin save gây 409; không mất thay đổi form khi polling; partial disk write không làm hỏng active config. |
| T20 | UI | vi/en key parallel, text không tràn; light/dark tương phản đúng; keyboard/focus/role alert và mobile/tablet/desktop hoạt động. |
| T21 | Deploy | Image không chứa session/env; dependency/browser launch non-root, worker/scheduler heartbeat; startup không tải browser/cài package. Rollback không xóa volume. |
| T22 | 16,20 | Nếu P1 được duyệt: selective retry preview + idempotency; cảnh báo đúng threshold, không spam hoặc gửi thông tin ra ngoài app. |

Không dùng kết quả production trước đây thay thế các test này. Live smoke/crawl chỉ chạy sau khi được phép triển khai và thực thi cụ thể.


## Bằng chứng đã chạy ngày 2026-11-02

- AI: `flake8 app tests/unit` đạt; 23 tests trong test_crawler_credentials, test_crawler_management, test_source_config, test_trend_schedule_ownership, test_trend_persistence_failure đạt. Có 2 deprecation warnings từ datetime.utcnow hiện có.
- Business: 9 tests thuộc AdminCrawlerManagementControllerTest, AiServiceSecretTransportTest, AiTrendControllerTest đạt; bao gồm role guard trước đọc body, giới hạn upload và chặn HTTP non-loopback.
- Web: `npm run ci` đạt (lint không có errors, 188 warnings của repo; type-check và production build đạt). 127 key crawler vi/en song song.
- Playwright CLI với API fixture và chặn mọi outbound request thật: vi/en, dark/light, desktop/mobile 390px, không overflow, preview nhỏ 1 nguồn × 2 bài và đóng modal bằng Escape. Ảnh QA nằm trong `brandhub-web/output/playwright/crawler-*.png` (artifact local, không commit). Console chỉ có tài nguyên fonts/analytics bên ngoài bị chủ động chặn.
- Docker local: build `brandhub-ai-crawler:dev-review` đạt; launch browser non-root UID 1000 với network none, đọc title trang data offline đạt; assert không có /app/.env và hai file session thật trong image.
- Persistence smoke: hai container mới dùng một volume QA và key fixture mount read-only; credential được mã hóa, config và history giữ nguyên qua recreation. Volume và key QA đã xóa sau test.
- Bài thử đầu dùng Page.set_content chờ load timeout; browser smoke chính thức dùng navigation data với domcontentloaded như collector thực tế và đạt. Không dùng kết quả timeout đó làm bằng chứng thành công.
- Chưa xác minh TLS production, provider login/proxy thực, live worker processing, screen reader thiết bị hoặc deploy/rollback thực tế. Không chạy paid providers hoặc thao tác production trong đợt này.

- Browser readiness local: test thiếu package, thiếu binary, timeout, executable lỗi và cache browser có sẵn; xác minh bằng venv service thật mà không crawl hoặc gọi provider.

## Regression proxy runtime Docker
- Không có .env: provider giả trả proxy mới, child/browser đầu tiên dùng đúng proxy mới và không tạo file.
- Retry browser lấy lại proxy bằng resolver, thay proxy cũ; lỗi refresh không tiếp tục các source còn lại, giữ kết quả đã thu thập.
- Provider HTTP/lỗi dữ liệu và TCP timeout trả mã lỗi an toàn; không fallback âm thầm sang proxy cũ hoặc direct.
- --proxy, --no-proxy và proxy quản lý cố định không gọi API xoay; Threads nhận proxy runtime và không đọc lại dotenv.
- Không log endpoint, mật khẩu, API key; dùng mock, không thay production.

Kết quả dev: 45 test crawler đạt; thêm test giới hạn retry proxy cố định và chạy lại 15/15 test proxy runtime đạt. Regression AI API/crawler 35/35 đạt; flake8 đạt. Provider/socket/browser đều được giả lập, không chạy crawl thật hoặc deploy production.

## Session RAM theo yêu cầu (2026-11-02)
Upload không key thành công, metadata không chứa cookie; store mới cùng process đọc được, process mới mất session. Run chụp session cũ trước replace/revoke và stdin tới browser dùng dict không ghi file. Thiếu session chặn start. Probe/legacy cookie API không ghi session file hoặc Redis. Kiểm tra song ngữ, dark/light và npm run ci.

Kết quả session RAM: 55 test crawler/IPC/browser/proxy đạt; 37 test AI API/crawler đạt, sau chỉnh cache chạy lại 17 test liên quan đạt; flake8 và Web npm run ci đạt (188 cảnh báo lint hiện có, không lỗi). Preflight thực tế cho Facebook/Threads đọc RAM qua stdin đạt. UI fixture vi/en, light/dark, mobile 390px, file input không key và keyboard focus đạt. Không gọi provider thật, không chạy crawl thật, không deploy.

## Deploy disk guard (2026-11-02)
Giữ image mọi container, foreign/shared tags, target và một rollback; cleanup chỉ repo AI không force và không volume/container prune. Thiếu disk/inode sau cleanup trả lỗi trước deploy. Dry-run không mutate. Chạy unit tests mock Docker và parse workflow; chỉ inventory/dry-run production.

Disk guard: 6 unit test đạt, flake8 đạt; YAML và command base64/argparse/order được kiểm tra. Production dry-run chỉ đọc chọn 8 image AI cũ (10 tag), giữ image đang chạy và sha-f435746-20 dự phòng. Disk trống 2.21 GiB nên guard báo ready=false. Chưa chạy --apply, chưa push/deploy.

## Sửa quyền volume và chẩn đoán rollback (2026-11-02)
Volume parent root:755 vẫn giữ nguyên; control/output thuộc appuser và ghi được. Chạy init lần hai không đổi dữ liệu; không theo symlink/hardlink ra ngoài. Init failure không recreate service. Startup failure capture health/log trước compose restore, che env secrets/cookie/URL. Test Docker offline với volume giả, không mount production.

Kết quả dev: 12 unit test disk/volume/diagnostics đạt; flake8 và YAML/Bash/command SSM sau giải mã đạt. Docker local volume giả root:755 tái hiện lỗi trước init; sau init appuser UID1000 ghi được scheduler lock/heartbeat/output, dữ liệu cũ giữ nguyên, parent/other-service không đổi. Init lần hai đạt; volume QA đã xóa. Chưa đổi production, chưa commit/push/deploy.

## Retention khi rollout thất bại (2026-11-02)
Regression: active image cũ + failed image mới + previous image cũ hơn => cleanup failed, giữ active/previous. Target mới được giữ; không có active image vẫn giữ một unused. Dry-run không mutate. Đối chiếu production sha-6060fc3-25 unused, unique4.063GB; không hạ disk guard.

Kết quả: 16 test disk/volume/diagnostics đạt, flake8 đạt. Production dry-run mới chỉ chọn sha-6060fc3-25 (unused, 4.063GB unique), giữ current sha-0ed93a6-21 và không sửa/xóa dữ liệu. Disk hiện vẫn5.57GiB vì chưa apply; ngưỡng6GiB không đổi. Chưa commit/push/deploy.


## Kiểm tra overview rút gọn (2026-11-02)
Nhiều history không theo thứ tự: chỉ run startedAt mới nhất hiện. Active ưu tiên hơn history. Khi latest completed/failed vẫn hiện; latest interrupted giữ recovery. Không có run thì ẩn banner. Tab lịch sử giữ mọi run. Kiểm tra vi/en, light/dark, mobile và keyboard với fixture, không chạy crawler thật.

Kết quả: npm run ci pass (188 warning có sẵn, 0 error); Playwright fixture vi/en pass cho active, completed, failed, interrupted, lịch sử đầy đủ và empty; screenshot light/dark/mobile đã kiểm tra.


## Thư mục worker có quyền ghi (2026-11-03)
Kiểm tra volume /app/data root:root 0755: trước init UID1000 không ghi được; sau init ghi atomic batch JSON và label_check.state tại crawler/trend_runs. Parent/ngoài crawler giữ nguyên owner/dữ liệu. Kiểm tra workflow áp TREND_RUN_DIR trước init/up, YAML/Compose hợp lệ, unit aggregation/label check pass.

Kết quả dev: flake8 pass; 18 unit tests pass; parse workflow YAML/Compose JSON và thực thi lệnh cập nhật Compose trên fixture pass, environment khác giữ nguyên. Smoke Docker chưa chạy được do Docker daemon local tắt. Chưa đổi production hay replay run cũ.


## Cài browser ổn định trong build (2026-11-03)
Installer phải truyền phiên bản chính xác vào ensure_binary, kiểm tra path tồn tại/executable và surface lỗi download. Unit CI đầy đủ phải pass. Build không bỏ qua diagnostic hoặc lỗi cài đặt; kiểm tra YAML và Docker build nếu daemon hoạt động.

Kết quả: full flake8 pass; full pytest tests/unit với junit + coverage: 995 passed, 128 warning có sẵn. Workflow YAML và Docker layer order pass. Docker build Linux chưa chạy được do Linux Engine local không hoạt động, dù đã thử khởi động Docker Desktop. Crash exit 139 do thread teardown là giả thuyết từ log và nhánh installer upstream; chưa có faulthandler trace từ build lỗi để khẳng định.

Bổ sung khi Docker đã bật: smoke Linux volume root-owned pass (UID1000, atomic batch + label-check, init 2 lần, không đổi parent). Installer pinned 5 lần không tạo background threads; Chromium mở/đóng trang offline pass trong image cache cùng CloakBrowser 0.5.10. Full Dockerfile build đang kiểm tra. Đã loại data/crawler khỏi build context và đặt runtime ENV sau dependency layers.

Kết quả cuối khi Docker bật: full Dockerfile build exit 0, pinned installer và info --quick pass (không exit139); image brandhub-ai-crawler:browser-fix-review. Final-image offline smoke: UID1000, TREND_RUN_DIR đúng, không chứa .env/session; 5 lần ensure_binary pinned không có update thread, Chromium page launch/close pass. Worker volume smoke dùng code trong image (không bind dev source) pass, volume QA đã xóa. Build lặp lại sử dụng cache: exit0 trong 4.8 giây. Chưa push/deploy.


## Giới hạn RAM AI 4.5 GiB (2026-11-03)
Render Compose xác nhận ai-service.mem_limit tương đương 4831838208 bytes. Thực thi generated compose updater trên fixture 2300m: đổi thành 4608m, giữ env khác và memory service khác. YAML hợp lệ, CI flake8/unit pass. Production chỉ nhận cấu hình khi deploy; chưa restart hay retry run.

Kết quả: Compose base và base+overlay render 4608m (4.5 GiB); generated updater áp memory mới và giữ env/limit service khác. Full flake8 pass, pytest unit 995 passed (128 warning có sẵn). Chưa commit/push/deploy, production chưa đổi.

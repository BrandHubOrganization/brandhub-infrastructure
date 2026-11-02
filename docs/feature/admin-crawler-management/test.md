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

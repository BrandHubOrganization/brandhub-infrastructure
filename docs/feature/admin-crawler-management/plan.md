# Kế hoạch kỹ thuật — IMPLEMENTING

Người dùng đã duyệt triển khai dev; mọi thay đổi production vẫn qua CI/CD sau kiểm chứng.

## Kiến trúc và thứ tự thực hiện

1. Chốt BA, state machine, readiness policy, publication failed-all-sources và retention secret. Đối chiếu hợp đồng tính năng cũ; không chỉnh spec cũ trước khi scope mới được duyệt.
2. Chuẩn hóa runtime trong dev: Dockerfile chứa collector deps/browser/libs, CPU-only NLP, image smoke test chạy non-root. Không gộp nguyên requirements crawler đang pin pydantic khác root mà chưa giải quyết tương thích. Persistent volume cho config/session/control/output/manifest; UID/GID và cấu trúc version rõ. Scheduler owner do Compose/process lifecycle quản lý, share lock/state với manual API; API startup không tự tạo nhiều scheduler. Kiểm tra tương thích và chuyển giờ UTC cũ trước timezone migration.
3. AI service: health checks độc lập có deadline; heartbeat worker/scheduler; secret storage adapter mã hóa có key managed riêng; session validation/version/working copy; allowlist proxy/provider; async probes có rate limit; command stop và reconciliation; event/log redaction. API health probes không download browser hoặc chạy provider tự động.
4. Business service: giữ requireAdmin + internal auth; facade cho endpoint mới, validate file/limit, audit command, không lưu body secret trong logs. Gateway limit/timeout và đường truyền TLS mang secret được cấu hình qua repo hạ tầng. Lựa chọn KMS/encrypted volume theo thiết lập AWS thực tế, không tự tạo key/account hoặc mở rộng IAM ngoài scope đã duyệt.
5. Web: mở rộng trang hiện có, reuse styles/components và hooks; group tác vụ, masked secret form, run detail inline, lý do disable đầy đủ; không tự skip nền tảng. Giữ endpoint/khu replay và graph, liên kết sang khi phù hợp thay vì nhân bản tính năng.
6. Chạy test theo test.md; local/staging verification bằng fixture/mock providers trước. Build immutable image, review diff, CI/CD và deploy sau approval riêng; smoke test read-only trước một run live được phép. Không lấy trạng thái production từ các lần kiểm tra trước làm bằng chứng môi trường hiện tại.

## Vùng code dự kiến

- Web: `src/pages/admin/components/AdminTrendPipelinePanel.tsx`, control/run/settings/source components; hooks/services/types pipeline; thêm session/connection/health/run-detail components trong feature admin; `src/i18n/locales/vi/admin.json` và `en/admin.json`.
- Business: AdminTrendPipelineController/Service, DTOs, ErrorCode và audit hiện có; endpoint file upload có giới hạn và role check.
- AI: trend_pipeline_control, local_trend_runner, crawl_run_service, worker heartbeat và router pipeline; social_crawler run_control/pipeline_settings/stealth để chốt version và stop an toàn. Giữ publication/dedup core, chỉ thay policy đã duyệt rõ.
- Infra: Compose/Dockerfile/CI/runtime mount/lifecycle/secret transport; dữ liệu runtime không commit vào Git hoặc build context.

## Dữ liệu và migration

- Không dự kiến đổi domain schema PostgreSQL/Neo4j. Mở rộng metadata run/check/event với version schema, backward-compatible read.
- Runtime config, history, manifests và locks chuyển sang persistent root qua setting triển khai; một lần copy/validate/backup, không purge dữ liệu cũ.
- Secret file mã hóa có opaque version, active pointer và metadata. Không ghi giá trị vào Redis status, config snapshot, audit hoặc API response. Worker/browser nhận bản giải mã tối thiểu trong vùng hạn chế và dọn theo lifecycle; bản cookie browser cập nhật tách khỏi upload gốc.
- Các run cũ có field thiếu vẫn đọc được. Không dùng Redis TTL làm bản lưu lịch sử duy nhất.

## Các mốc bàn giao

- M1: runtime tái lập được + readiness chính xác (BA-02,03,19).
- M2: cấu hình nguồn/session/kết nối/lịch an toàn (BA-04..10, 18).
- M3: điều khiển, dừng và quan sát run hoàn chỉnh (BA-11..15); kiểm tra dữ liệu trend trên `/admin?view=trends` hiện có.
- M4: P1 retry chọn lọc và cảnh báo sau khi duyệt (BA-16,20).

Mỗi mốc gồm API/UI tương ứng, test, demo dev và review. Không ước lượng lịch hoàn thành trước khi chốt scope và cơ chế secret/TLS.


## Hợp đồng triển khai đã cài trong code (chưa thao tác production)

- Docker image dùng Debian bookworm, cài `requirements-crawler.txt` cùng requirements chính, cài browser ở build time dưới appuser. Entrypoint quản lý Uvicorn + một scheduler; `CRAWLER_SCHEDULER_ENABLED=false` tắt scheduler khi cần. Không cài package/browser lúc startup.
- Volume `/app/data` chứa `CRAWLER_STATE_DIR=/app/data/crawler/control`, `CRAWLER_OUTPUT_DIR=/app/data/crawler/output`. `CRAWLER_WORK_DIR=/dev/shm/crawler` giữ bản session giải mã theo run/probe trong tmpfs, dọn khi run kết thúc. Không dùng volume cookie plaintext cũ làm kho upload mới.
- Provision file Fernet key riêng ngoài volume chứa ciphertext, mount read-only với UID appuser, đặt `CRAWLER_SECRET_KEY_FILE`. Code không tự tạo key production. Dev/test dùng key tạm; không commit key/env/session. Upload disabled nếu key thiếu/sai. Cần bảo vệ disk/backup và key bằng cơ chế triển khai hiện có; không tạo AWS account/IAM key mới.
- `CRAWLER_PROXY_HOSTS`, `CRAWLER_TIKTOK_HOSTS` là allowlist chính xác do deployment quản lý. Endpoint nhập mới phải resolve ra địa chỉ public; URL redirect không được probe theo. Proxy mang credential chỉ chấp nhận HTTPS. TikTok probe cần `CRAWLER_TIKTOK_PROBE_PATH` là read-only endpoint thực tế của provider; nếu thiếu báo chưa cấu hình, không tự đoán API tốn phí.
- Business `postSecret` chặn truyền secret tới AI qua HTTP ngoài loopback. Phải provision HTTPS + trust hợp lệ cho AI endpoint trước khi bật upload production, và bảo vệ các chặng edge/gateway/business mang payload. Đây là release gate; không bypass bằng cấu hình insecure. HTTP loopback local chỉ dành dev.
- Migration offline: dừng collector/scheduler trước, sao lưu cây state/output cũ; chạy `python -m scripts.migrate_crawler_state --source <old-control> --target <new-control>` và tương tự cho output bằng UID service. Tool không xóa nguồn, không ghi đè file xung đột và kiểm tra lock. So sánh config/manifests/history trước startup; rollback giữ cả volume và image cũ. Nếu còn batch xử lý, chờ publication hoặc phục hồi manifest trước chuyển.
- Retry P1 trong bản này tạo run mới cho các nguồn Facebook thất bại còn trong source config, có preview/confirm và dedup hiện có. Recovery interrupted run vẫn dùng ID gốc. Không cung cấp forced requeue worker/DLQ. Retry Threads/TikTok dùng lựa chọn nền tảng ở Run pipeline; chưa có retry theo từng worker batch.
- Cảnh báo P1 trong trang gồm thiếu thành phần bắt buộc/scheduler, backlog queue (mặc định 100) và log run im lặng quá 1800 giây. Không gửi thông tin ra dịch vụ ngoài.


Overlay opt-in nằm tại `docker/compose/ec2-ecr/crawler-management.compose.yaml`; đã kiểm tra `docker compose config --no-env-resolution --no-path-resolution -q`, chưa áp dụng. Chỉ đưa vào lệnh CI/CD sau khi provision key/TLS/migration được review. Không đổi image tag production hoặc tự bật endpoint insecure.


Chẩn đoán browser local dùng subprocess đồng bộ có timeout trong worker thread và đúng runner.python; không dùng asyncio.create_subprocess_exec vì Uvicorn Windows có thể dùng SelectorEventLoop. Dependency cài ở venv chạy service, Docker image riêng không cấp package cho venv local.

## Sửa proxy runtime
Thêm crawlfb.proxy_runtime dùng chung để lấy proxy KiotProxy, kiểm tra endpoint/TCP và trả mã lỗi không chứa credential. run.py chuẩn bị proxy trong tiến trình cha, truyền bằng env cho Facebook/Threads. CLI Facebook refresh trực tiếp khi retry; không dùng subprocess ghi dotenv. Tool rotate_proxy trở thành kiểm tra runtime không ghi file. Threads standalone dùng cùng resolver. Regression giả lập provider, socket và browser; không gọi provider thật.

## Session RAM theo yêu cầu (2026-11-02)
Dùng store RAM có lock, version/revision và deepcopy trong AI process. Truyền snapshot session qua stdin pipe tới preflight, runner và CLI con; marker memory:facebook/threads dùng storage_state dict, không lưu cookie khi đóng browser. Scheduler gọi API hiện có để dùng chung RAM. Probe cũng dùng stdin. Legacy cookie API chuyển cùng RAM; không backup/restore Redis/file. UI mở session upload độc lập kho khóa, ghi rõ restart cần nạp lại. Một API worker sở hữu RAM (entrypoint hiện tại một worker).

Session RAM thay thế các yêu cầu file khóa/working-copy session ở phần thiết kế trước. Overlay crawler-management.compose.yaml không còn cần mount key; chỉ thêm crawler-connections.compose.yaml nếu muốn quản lý proxy/TikTok mã hóa qua UI. Các file/ciphertext session cũ không được đọc/phục hồi tự động; không tự xóa dữ liệu deployment cũ. Không tăng số API worker: RAM chỉ thuộc API process hiện tại. Sau rollout/restart admin nạp lại session.

## Deploy disk guard (2026-11-02)
Thêm scripts/prepare_deploy_disk.py: mặc định dry-run, chọn image đúng repository và không có tag thuộc repo khác; bảo vệ toàn bộ container đang chạy/đã dừng, target và image unused mới nhất. Apply bỏ từng tag bằng docker image rm không force, kiểm tra lại container trước khi xóa. Workflow nhúng script base64 qua SSM trước backup/sửa compose, kiểm tra tối thiểu 6 GiB và inode. Không tự dọn production ngoài CI/CD.

## Sửa quyền volume và chẩn đoán rollback (2026-11-02)
Thêm scripts.prepare_crawler_volume chạy một lần bằng root trong container compose --rm --no-deps với image mới đã pull. Lấy UID/GID appuser từ image, tạo control/output và chown/chmod cây crawler giới hạn; reject symlink/hardlink/path ngoài base. API/scheduler vẫn chạy appuser. Thêm scripts.capture_deploy_failure chỉ in trạng thái/health và các dòng startup/error đã redaction, không in Env; gọi trước rollback và không để lỗi capture cản rollback.

## Retention khi rollout thất bại (2026-11-02)
Trong candidates(), xác định mốc Created mới nhất của image thuộc repo đang được container tham chiếu. Chỉ chọn bản dự phòng từ image unused có Created <= mốc đó; các image unused mới hơn vẫn là ứng viên cleanup. Mọi container/target/foreign tags tiếp tục được bảo vệ và recheck trước remove không force. Nếu chưa có container tham chiếu repo thì giữ retention mặc định cho initial deployment.


## Rút gọn run trên overview (2026-11-02)
AdminTrendPipelineControl managed chọn active hoặc history mới nhất theo startedAt, không phụ thuộc thứ tự API. Panel hiển thị banner khi có run bất kỳ. Không sửa API hay tab lịch sử.


## Thư mục worker có quyền ghi (2026-11-03)
Đổi default local thành data/crawler/trend_runs; Docker và EC2 Compose dùng TREND_RUN_DIR=/app/data/crawler/trend_runs. Workflow set environment override trước init/recreate để env_file cũ không trỏ về data/trend_runs. Init tạo thư mục với UID/GID appuser trong phạm vi crawler.


## Cài browser ổn định trong build (2026-11-03)
Installer riêng gọi ensure_binary(browser_version=get_chromium_version()) để dùng nhánh pinned không tạo background update threads; Docker chạy installer rồi info --quick với faulthandler. Giữ layer browser trước COPY source để bảo toàn cache.

Runtime ENV đặt sau dependency layer; data/crawler/ bị loại khỏi build context để không đưa dữ liệu run local vào image.


## Giới hạn RAM AI 4.5 GiB (2026-11-03)
Đặt ai-service.mem_limit=4608m trong EC2 Compose và overlay crawler. Workflow AI cập nhật mem_limit cùng image/TREND_RUN_DIR trước recreate, có sẵn backup/rollback compose. Không thay limit service khác, không đổi Docker image/browser code.

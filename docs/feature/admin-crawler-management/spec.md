# Quản lý toàn diện crawler trên Trend Pipeline

Trạng thái: IMPLEMENTING — BA được người dùng duyệt ngày 2026-11-02; chỉ triển khai dev, chưa deploy production.
Ngày: 2026-11-02. Trang: `/admin?view=trendPipeline`.

## Mục tiêu và phạm vi

Admin hiện có quản lý cấu hình, session, kết nối, lịch, chạy và theo dõi bộ crawler Facebook/Threads/TikTok trên một trang. Không tạo tài khoản BrandHub, tài khoản mạng xã hội, tài khoản nhà cung cấp hoặc role mới. Dùng lại RBAC Admin và audit hiện tại; không thay đổi hệ thống đăng nhập.

Mọi thay đổi code/dependency/Dockerfile/hạ tầng được làm trong repo dev, kiểm chứng rồi deploy qua CI/CD. Không sửa code, cài package hoặc tải browser thủ công trên production. Sau khi tính năng được deploy, thao tác cấu hình qua API Admin là luồng vận hành được thiết kế, không phải chỉnh code production.

Kế thừa admin-trend-pipeline-now, admin-multiplatform-trend-pipeline, admin-trend-source-config và trend-cold-storage. Không thay đổi thuật toán trend, hợp đồng publication, hoặc tự hợp nhất trang legacy crawl/replay/graph.

## Hiện trạng đã xác minh

- Có chạy thủ công, lịch sử, recovery interrupted run, cấu hình lịch/nền tảng và nguồn Facebook.
- Readiness mới có một lý do lỗi; worker consumer, đăng nhập thực tế và proxy chưa được biểu diễn đầy đủ.
- Collector cần dependency/browser/session riêng; API health UP không chứng minh collector hoạt động.
- Config/history/manifest có phần nằm trong filesystem container, cần lưu bền vững.
- Cấu hình session trên production từng thiếu file; cài runtime trực tiếp không tái lập được khi deploy lại.

## Danh sách BA và acceptance criteria

P0: bắt buộc cho bản vận hành đầu. P1: hoàn thiện quản lý; cần review nhưng có thể triển khai sau.

| ID | Ưu tiên | User story / nghiệp vụ | Acceptance criteria |
|---|---|---|---|
| BA-02 | P0 | Admin thấy đầy đủ điều kiện vận hành | Liệt kê collector, browser, từng session được chọn, proxy, TikTok API, broker, worker, tracking, scheduler, lưu trữ và downstream publication dependencies. Mỗi mục có trạng thái, thời điểm đo, mã lỗi và cách xử lý; timeout là UNKNOWN, không giả định healthy. Lỗi không che các kết quả còn lại. |
| BA-03 | P0 | Phân biệt sẵn sàng chạy và đang hoạt động | Tách manualReady, schedulerHealthy và kết quả run gần nhất. Chỉ điều kiện bắt buộc của nền tảng được chọn chặn start; scheduler dừng không chặn manual. Worker dùng heartbeat/consumer đúng queue; Redis ping không chứng minh pipeline hoàn tất. |
| BA-04 | P0 | Admin quản lý nền tảng và nguồn | Giữ Facebook pages/groups, Threads Trending Now, TikTok hashtag/Creative Center và giới hạn hiện có. Chọn ít nhất một nền tảng; không tự bỏ nền tảng lỗi. Run thủ công có thể chọn tập con rõ ràng mà không âm thầm đổi lịch mặc định. Preview số nguồn, giới hạn và revision trước khi chạy. |
| BA-05 | P0 | Admin nạp/thay session Facebook và Threads | Upload JSON riêng từng nền tảng, giới hạn mặc định đề xuất 1 MiB/file. Validate schema hỗ trợ bởi crawler, cookie domain/name/type, giới hạn số phần tử và loại bỏ trường không cần thiết theo schema. Tên/path do server quyết định. File sai bị từ chối, không thay bản đang dùng. Không có API tải file hoặc đọc cookie. |
| BA-06 | P0 | Admin biết session có dùng được hay không | Phân biệt MISSING, FORMAT_VALID_UNVERIFIED, VERIFIED, EXPIRED_OR_LOGIN_REQUIRED, CHECKPOINT_REQUIRED và CHECK_FAILED. Nút kiểm tra thực hiện probe giới hạn thời gian bằng browser và proxy của nền tảng, không crawl feed hàng loạt. Không kết luận session hết hạn khi lỗi mạng. Timestamp/cookie expiry chỉ tham khảo, không bảo đảm hiệu lực đăng nhập. |
| BA-07 | P0 | Thay session không phá run đang chạy | Lưu version bất biến, cập nhật active pointer nguyên tử; mỗi run chốt version và có bản làm việc riêng để browser cập nhật cookie. Session mới áp dụng run kế tiếp. Admin có thể ngừng dùng session cho run tương lai; UI cảnh báo run đang chạy vẫn dùng bản snapshot. Chỉ giữ bản còn tham chiếu; chính sách hết hạn bản cũ ở phần quyết định. |
| BA-08 | P0 | Admin quản lý proxy hiện có | Xem trạng thái đã cấu hình, kiểm tra kết nối và thay endpoint/credential của provider đang dùng. Trường secret chỉ nhập thay mới, không trả lại giá trị. Hiển thị lỗi auth/quota/timeout khi nhận diện được, không tự suy diễn. Không tự chuyển sang IP trực tiếp khi proxy lỗi. Chặn URL/protocol/đích nội bộ ngoài allowlist server; không biến probe thành proxy truy cập tùy ý. |
| BA-09 | P0 | Admin thay cấu hình TikTok API hiện có | Chỉ hỗ trợ provider hiện tại và endpoint trong allowlist triển khai; secret write-only. Không tạo account/key mới. Hiển thị chưa cấu hình/kết nối được/auth lỗi/không xác minh được. Không tự gọi API tốn phí khi mở trang. Các key LLM/AWS/Neo4j không nằm trong form này. |
| BA-10 | P0 | Admin quản lý lịch chạy | Bật/tắt lịch, chọn giờ theo timezone IANA hiển thị rõ, preview ít nhất 3 lần chạy kế tiếp. Preserve cron tùy chỉnh hiện có. Không tự diễn giải giờ UTC thành giờ Việt Nam. Chỉ một scheduler owner, có heartbeat; lịch bật nhưng scheduler chết phải báo lỗi. Pause lịch không hủy run hiện tại. |
| BA-11 | P0 | Admin chạy ngay hoặc chạy kiểm tra nhỏ | Chạy cùng pipeline thật; chế độ kiểm tra giới hạn nguồn/bài nhưng mặc định không publish vào live, đánh dấu rõ mục đích. Start trả accepted với run ID; chống double click và request trùng. Khóa giữa manual/scheduler/recovery, worker API nhiều process. Snapshot cấu hình/session/proxy version cho run; probe có chi phí cần thao tác rõ ràng. |
| BA-12 | P0 | Admin theo dõi từ crawl đến live trend | Hiển thị tiến độ từng nền tảng/nguồn, bài thu được, dedup/bỏ qua, batch queued/processing/completed/failed, DB saved, Redis published và resolution. Không giả lập phần trăm khi chưa biết tổng. Chỉ COMPLETED khi run đáp ứng publication/resolution contract hiện có; PARTIAL/FAILED/INTERRUPTED phải phản ánh đúng dữ liệu thực. |
| BA-13 | P0 | Admin dừng thu thập có kiểm soát | Nút yêu cầu dừng có xác nhận, STOP_REQUESTED rồi terminal status khi xác nhận dừng. Collector ngừng bắt đầu nguồn mới, flush output và đóng manifest an toàn; các batch đã nhận được tiếp tục xử lý. UI phân biệt collection stopped với downstream still processing. Không xóa queue, kill worker chung hoặc báo đã dừng khi chưa có xác nhận. Timeout dừng báo rõ và giữ recoverability. |
| BA-14 | P0 | Admin đọc lỗi và log an toàn | Log/sự kiện có run/source/stage/time và mã lỗi; phân trang, giới hạn retention. Không trả cookie, auth header, proxy credential, presigned URL hoặc env dump. Có kiểm thử redaction; log nhạy cảm không gửi analytics. HTTP/proxy timeout không bị gộp thành lỗi session. |
| BA-15 | P0 | Admin xem lịch sử và phục hồi | Lọc theo thời gian/nền tảng/trạng thái; xem snapshot metadata và tổng kết. Giữ recovery interrupted run hiện có: dùng dữ liệu đã lưu và ID gốc, không tự crawl lại hay publish trùng. Restart dịch vụ vẫn đọc được lịch sử, manifest, receipt và progress. Hết dữ liệu phục hồi phải giải thích rõ. |
| BA-16 | P1 | Admin chạy lại phần thất bại | Preview nguồn/batch sẽ retry, chi phí và tác động live trước khi xác nhận. Phân biệt retry batch với crawl mới; chống trùng và không retry vô hạn. Không cho push payload tùy ý hoặc bulk requeue DLQ từ trình duyệt. |
| BA-18 | P0 | Thao tác quản trị được bảo vệ và truy vết | Kiểm tra quyền server-side cho tất cả endpoint; CSRF phù hợp cơ chế auth hiện có; audit actor/action/environment/version/result. Không chứa secret. TLS các chặng mang secret, mã hóa secret/session khi lưu, quyền tối thiểu và khóa tách khỏi ciphertext; frontend không lưu secret vào cache/localStorage. |
| BA-19 | P0 | Cấu hình không mất hoặc ghi đè nhau | Config có optimistic revision, atomic update, lịch sử metadata và lỗi stale rõ ràng. Runtime config/session/manifest/control/history dùng persistent storage và đúng UID/GID. Bản chạy giữ snapshot cũ; secret rotation không tự restart service hoặc đổi run đang chạy. |
| BA-20 | P1 | Admin thấy bất thường chủ động | Cảnh báo trong trang khi không có consumer, queue tăng, run lâu không tiến triển, proxy/session lỗi hoặc lâu chưa publish. Có mốc lastChecked; ngưỡng cấu hình qua deployment. Không gửi email/Slack hoặc tạo automation ngoài app ở phạm vi này. |

## Quy tắc nghiệp vụ trọng yếu

- Không tạo account mới ở bất kỳ hệ thống nào; chỉ dùng admin và tài khoản crawler/provider đã có.
- Không yêu cầu nhập mật khẩu/OTP mạng xã hội vào BrandHub. Người vận hành đăng nhập thủ công bằng công cụ local rồi nạp session.
- Kiểm tra tĩnh không gọi provider; health polling không crawl, không rotate proxy và không chạy inference. Probe từ xa có nút riêng, rate limit và thời hạn.
- Readiness có freshness/UNKNOWN. Lỗi nền tảng không chọn không chặn run được chọn. Không dùng `ready=true` như cam kết nhà cung cấp sẽ không lỗi sau đó.
- Dependency/browser thiếu: hiển thị hướng xử lý qua dev/CI/CD; UI không có nút pip install, shell, sửa env tùy ý hay restart container.
- Queue và DLQ mặc định chỉ đọc; không purge. Retry chỉ theo BA-16 nếu được duyệt.
- Tránh ghi snapshot rỗng lên live khi toàn bộ nguồn thất bại; run thu thập thành công nhưng thực sự không có trend phải được phân biệt. Quy tắc publication này cần review riêng vì là thay đổi so với đường ghi hiện tại.
- Session/proxy là secret; không nhét vào snapshot config hoặc audit. Run snapshot chỉ tham chiếu opaque version ID.

## UI/UX và trạng thái

Trang hiển thị lần kiểm tra; khu tình trạng vận hành và lỗi cần xử lý; run đang hoạt động; các mục Tổng quan, Nguồn & giới hạn, Session & kết nối, Lịch chạy, Lịch sử. Chi tiết run hiển thị ngay trong trang, giữ được back/deep link. Form dài dùng toàn chiều rộng; dialog ngắn cho xác nhận stop/revoke/retry. Giữ màu/theme/component BrandHub. Không hiển thị nhãn môi trường hoặc phiên bản ứng dụng. Kiểm tra danh sách/số lượng trend và dữ liệu đầu ra dùng trang `/admin?view=trends` hiện có; trang pipeline chỉ giữ trạng thái các bước xử lý của từng run theo BA-12.

Giữ dữ liệu form chưa lưu khi polling; không overwrite khi người dùng đang nhập. Error gần trường, focus tới lỗi đầu; feedback accessible qua role/status, không chỉ màu. Hỗ trợ bàn phím, mobile/tablet/desktop, light/dark.

Các nhóm i18n mới song song trong `src/i18n/locales/{vi,en}/admin.json`: `admin.crawler.health.*`, `sources.*`, `sessions.*`, `connections.*`, `schedule.*`, `runs.*`, `logs.*`, `audit.*`, `errors.*`, `confirm.*`. Tái sử dụng key hiện có nếu cùng nghĩa; mọi chuỗi/enum hiển thị mới phải có key vi/en.

## API contract đề xuất, chưa chốt implementation

Giữ Business `/api/v1/admin/ai/trend-pipeline` và AI internal prefix hiện có. Mở rộng status thành `checks[]` (component/platform/status/code/checkedAt/remedy), thêm manual/scheduled readiness và heartbeat age. Giữ tương thích field cũ trong giai đoạn chuyển đổi.

Các nhóm endpoint thêm: session metadata + upload/revoke/probe; proxy/TikTok masked metadata + replace/probe; run preview/start/stop/events/detail; history pagination. Không thêm endpoint output summary; dùng trang trends hiện có để kiểm tra đầu ra. Tất cả command dùng ID và enum được kiểm tra, không nhận shell/path/CLI tùy ý. Metadata GET không chứa secret; command accepted trả operation ID/status, probe async khi cần. 400 invalid, 401/403 auth, 404 unknown, 409 stale/busy/state conflict, 413 quá dung lượng, 429 rate limit, 503 unavailable; lỗi provider chuẩn hóa và redacted.

## Các quyết định cần review

1. Duyệt P0 cho bản đầu; BA-16 retry chọn lọc và BA-20 cảnh báo là P1.
2. Session/proxy/TikTok secret đều quản trị write-only trong cùng trang; không thêm trang quản lý account hoặc generic env editor.
3. Đề xuất giữ tối đa 1 session trước đó trong 24 giờ để khôi phục, chỉ xóa sau khi không còn run tham chiếu; metadata audit giữ theo chính sách hệ thống. Không hứa có thể thu hồi cookie phía Facebook/Threads bằng việc xóa file tại BrandHub.
4. Timezone mặc định đề xuất Asia/Ho_Chi_Minh; migration lịch cũ giữ nguyên thời điểm chạy thực tế, chỉ đổi giờ khi admin xác nhận.
5. Kiểm tra nhỏ mặc định không publish live. Failed-all-sources không thay thế snapshot tốt đang có; kết quả empty hợp lệ có chính sách riêng.
6. Triển khai đầu trên cùng một AI host và scheduler owner hiện có, không thêm nền tảng orchestration hoặc multi-host crawler.

## Definition of Done và ngoài phạm vi

BA được duyệt, code/dev checks và security/integration checks đạt; migration persistent state có backup/rollback; build image chứa dependency/browser đúng user; scheduler được quản lý bằng deployment; E2E chứng minh run và publication trung thực. Chưa deploy production khi người dùng chưa duyệt BA/triển khai. Không tạo account, không đổi thuật toán scoring, không sửa trực tiếp production và không mở API hạ tầng tổng quát.


## Bổ sung chẩn đoán local (2026-11-02)
Readiness phải kiểm tra bằng đúng Python của runner, phân biệt BROWSER_DEPENDENCIES_MISSING, BROWSER_MISSING, BROWSER_CHECK_TIMEOUT và BROWSER_CHECK_UNAVAILABLE. Không mặc định mọi runtime là Docker. Trên Windows không phụ thuộc event loop có hỗ trợ asyncio subprocess; polling không cài/download browser.

## Sửa lỗi proxy Docker (2026-11-02)
Proxy runtime không phụ thuộc đọc/ghi .env trong container. Proxy từ provider phải được truyền trong bộ nhớ tới browser/tiến trình con ngay lần đầu và khi retry. Khi provider/proxy lỗi, dừng trước khi quét toàn bộ nguồn; log chỉ mã lỗi an toàn. Giữ lựa chọn proxy cố định và kết nối trực tiếp rõ ràng; không đổi session hoặc production khi sửa dev.

## Session RAM theo yêu cầu (2026-11-02)
Session Facebook/Threads do admin nạp chỉ giữ trong RAM của một API process; không cần CRAWLER_SECRET_KEY_FILE, không ghi session ra file hoặc Redis. Restart/deploy mất session và UI phải nói rõ yêu cầu nạp lại. Thay/revoke không đổi snapshot của run đang chạy. Proxy/TikTok giữ cơ chế mã hóa hiện có, không mở khóa các trường này khi thiếu key.

## Deploy disk guard (2026-11-02)
Deploy phải kiểm tra disk/inode trước pull image; chỉ dọn image AI cũ không được container nào sử dụng, giữ một image dự phòng và target image. Không đụng volume/container/service khác. Thiếu dung lượng sau dọn thì dừng trước khi sửa compose, giữ dịch vụ hiện tại.

## Sửa quyền volume và chẩn đoán rollback (2026-11-02)
Trước khi recreate AI service, deployment chuẩn bị thư mục volume crawler cho appuser của image mới. Chỉ thay owner/quyền trong /app/data/crawler, không đổi owner toàn /app/data hoặc dữ liệu dịch vụ khác. Lỗi init chặn rollout. Thu metadata health và log startup đã che secret trước rollback.

## Retention khi rollout thất bại (2026-11-02)
Retention không chọn image unused mới hơn bản đang được container sử dụng làm bản dự phòng; các image như vậy có thể là rollout thất bại/prefetch, chỉ bảo vệ nếu là target hiện tại hoặc được container tham chiếu. Giữ ngưỡng disk 6 GiB, không giảm để bypass.


## Tổng quan chỉ hiển thị lần chạy gần nhất (2026-11-02)
Tab overview hiển thị tối đa một run: run đang chạy nếu có, nếu không chọn history có startedAt mới nhất, kể cả completed/failed/interrupted. Các run khác xem ở tab lịch sử. Giữ recovery cho run gần nhất bị gián đoạn. Không thêm text/i18n key; giữ theme light/dark và điều hướng bàn phím hiện có.


## Thư mục worker có quyền ghi (2026-11-03)
Worker lưu batch/label-check vào /app/data/crawler/trend_runs, trong volume có quyền appuser. Không đổi owner toàn /app/data. Giữ dữ liệu cũ; không tự replay DLQ hoặc dừng run production.


## Cài browser ổn định trong build (2026-11-03)
Build cài đúng binary theo phiên bản CloakBrowser đã pin, không chạy auto-update daemon trong installer ngắn hạn. Giữ fail-fast khi download/kiểm tra binary lỗi, không nuốt exit 139.

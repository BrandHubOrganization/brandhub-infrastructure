# Test matrix — phần 3.5 còn lại

Ngày 2026-10-13. Bảng dưới là tiêu chí nghiệm thu toàn lộ trình; kết quả thực tế giai đoạn 2 ghi riêng bên dưới, không suy ra toàn bộ matrix đã pass.

| ID | Kịch bản | Kết quả mong đợi |
|---|---|---|
| R01 | Client đúng Workspace, Campaign IN_PROGRESS + deploy SUCCEEDED tạo | 201 PENDING, fields/date/version hợp lệ, chưa có Task |
| R02 | Không Campaign, draft/approved hoặc deploy pending/failed/partial | Không tạo; lỗi business rõ ràng |
| R03 | Campaign COMPLETED tạo mới | Bị từ chối dù deployment từng SUCCEEDED |
| R04 | Campaign complete trong lúc create | Kết quả nhất quán theo lock/version; không bỏ qua server guard |
| R05 | Request đã có, Campaign hoàn thành | Vẫn edit/cancel nếu PENDING hoặc receive/review nếu hợp lệ; không tự hủy |
| R06 | Owner/Manager/Creator tự tạo, Client ngoài Workspace | 403, không persist |
| R07 | Xem list/detail, refresh nhiều lần | Không đổi PENDING sang IN_PROGRESS |
| R08 | Creator Client sửa riêng hoặc cả bốn fields PENDING | Type/date/title/description và version mới đúng |
| R09 | Empty patch/unknown fields/type/date không hợp lệ | 400, không ghi một phần |
| R10 | Client khác sửa/hủy hoặc ID thuộc Workspace khác | Từ chối không lộ dữ liệu, không mutation |
| R11 | Manager nhận PENDING | IN_PROGRESS, lưu actor/time, Client mất sửa/hủy |
| R12 | Owner có membership MANAGER tiếp nhận | Được xử lý theo role Workspace hiệu lực |
| R13 | Accept/deny trực tiếp PENDING hoặc Client đổi status | Bị từ chối, chưa Task |
| R14 | Race edit/cancel/receive và hai Client edits | CAS/version cho một kết quả hợp lệ, không silent overwrite |
| R15 | Accept IN_PROGRESS | ACCEPTED và một Task BACKLOG cùng transaction; campaignId null, source/type/date đúng |
| R16 | Concurrent/retry accept, response mất sau commit | Cùng generatedTaskId, một source unique; không reset Task đã làm |
| R17 | Lỗi insert Task/schema chưa ready/transaction failure | Không báo ACCEPTED thiếu Task; rollback/retry đúng, không partial audit |
| R18 | Deny/cancel và terminal reopen | Không tạo Task, terminal giữ nguyên, lịch sử còn |
| R19 | List/filter/detail/timestamps/task link | Scope và phân trang đúng; nguồn Request khác Campaign được phân biệt |
| R20 | Legacy statuses thiếu mapping hoặc type/date | Preflight abort không ghi; trình quyết định dữ liệu |
| R21 | Migration rerun, init parity | Không mất dữ liệu, không duplicate; validator/index giống nhau |
| R22 | Request/Directory UI vi↔en, light↔dark | Không thiếu key, không vỡ layout/contrast; chỉ đổi UI thuộc scope |
| R23 | 375/768/1440px, keyboard/dialog focus | Form/action/read-only/error usable; loading chống double submit |
| R24 | Workspace Package chưa approved | Gate/Chat/Manager settings giữ nguyên, không scheduled reminder |
| R25 | Request mock vs Task workflow | Workspace UI dùng API V2, không còn assign/review Task giả; editor/social consumers khác không đổi |
| R26 | Regression Package → Campaign → Task/editor | Hai approval/version, unique Campaign, deploy retry/complete không bị Request phá |

Directory tests chi tiết: [partner-directory/test.md](../partner-directory/test.md). Package history tests phải thêm cùng DA-945 trước giai đoạn 5, không tự suy ra lịch sử legacy đã có.

## Kiểm chứng giai đoạn 1

- Review quyết định Q1/Q2/Q3 với câu trả lời người dùng và đối chiếu master-plan/BA/spec.
- `git diff --check`, kiểm tra đủ bốn tài liệu, liên kết tương đối, phát hiện mâu thuẫn direct accept/deny, editable fields và reminder cũ.
- Kiểm tra diff chỉ tài liệu thuộc scope; không chạm ChromaDB, code, schema init/migrations hoặc dữ liệu thật.
- Test service/browser/Atlas ở trên chưa chạy vì chưa implementation; không đánh dấu chúng pass.

## Kiểm chứng giai đoạn 2 — 2026-10-13

### Đã chạy

- Backend compile thành công. 71 tests thuộc `ContentRequestServiceTest`, `ContentRequestInputTest`,
  `ContentRequestCampaignGateTest`, `ContentRequestAccessTest`, `ContentRequestStoreTest`,
  `ContentRequestControllerTest` pass: role/membership, create gate, status/version guard,
  unknown/null fields, offset date, partial edit, audit/CAS, cross-Workspace, pagination,
  201/204/400/403/409 và endpoint receive chưa triển khai.
- Lượt regression chọn lọc: **151 pass**, **1 skipped** (Atlas inventory opt-in không bật),
  gồm các tests Request trên + MediaPackageServiceImpl, MediaCampaignServiceImpl,
  CampaignPlanValidator, CampaignWorkspaceAccess, CampaignTaskStore,
  CampaignDeploymentServiceImpl/Processor, CampaignAllocationValidator, ChatServiceImpl.
  Không phải toàn bộ `mvn test`; chưa đo coverage bằng JaCoCo.
- Một lượt inventory opt-in riêng đã kết nối Atlas read-only: 0 documents,
  indexes `_id_`, `idx_content_requests_ws_status`, `idx_content_requests_ws_client_id`,
  `idx_content_requests_ws_assigned_to`. Không insert/update/delete hoặc apply migration.
- `node docs/database/migrations/tests/content-requests-v2.test.cjs`: test offline dry-run,
  preflight abort, giữ legacy fields/version/history, rerun, init validator/index parity.
- Web: ESLint các file mới và AppRoutes pass; TypeScript app/node pass; Vite production build pass.
  OpenAPI YAML parse được, 299 local refs resolve; vi/en keys mới đồng bộ.
- Playwright CLI dùng fixture chặn toàn bộ `/api/**`: create PENDING → edit cả bốn fields
  (POST → SURVEY, date/title/description) → version 2 → CANCELLED version 3, audit còn đủ.
  PATCH 409 giữ nội dung form và focus error summary; Manager không có nút tạo/receive;
  Client create bị disabled khi canCreate=false; schema 503 có message và retry hoạt động.
- UI kiểm tra 375/768/1440px, light/dark, vi/en; đã xem ảnh mobile light và desktop dark.
  Form tự focus tiêu đề khi mở; error summary có focus, native required và labels.
  Provider chỉ ở trang Request; không thay root/layout hoặc màn hình của thành viên khác.

### Chưa xác minh / không thuộc phase 2

- Chưa apply migration Atlas, chưa test API ghi thật qua Gateway hoặc create/complete race
  trên PostgreSQL + Mongo đang chạy. R04/R14 mới được kiểm tra lock/CAS bằng unit tests,
  chưa phải stress test đồng thời trên database thật.
- Chưa có receive/accept/deny, transaction tạo Task, Task link hoặc fault-injection của phase 3.
- Chưa nghiệm thu đầy đủ keyboard/screen-reader, mọi trạng thái form trên mọi breakpoint,
  và full end-to-end Package → Campaign → Request trên dữ liệu thật.
- Không seed, tạo account, sửa/xóa Workspace hoặc dữ liệu dùng chung. Không thay ChromaDB.

### Chạy lại

Backend: `mvn -Dtest=ContentRequestServiceTest,ContentRequestInputTest,ContentRequestCampaignGateTest,ContentRequestAccessTest,ContentRequestStoreTest,ContentRequestControllerTest test`.
Web: `npm run type-check`, ESLint các file WorkspaceRequest và `npm run build`.
Sau khi operator review/apply migration theo `docs/database/mongo-atlas-migrations.md`,
chạy live smoke bằng account test hiện có; chưa đánh dấu DA-951 Done trước phase 3.

## Test bổ sung trước implementation giai đoạn 3

- Receive: Manager + Owner có membership MANAGER; Client/Creator/Owner không có
  membership MANAGER bị 403; PENDING→IN_PROGRESS audit đúng một lần, version+1.
- Deny: chỉ IN_PROGRESS, note <=2000 và unknown fields bị chặn; giữ reviewer,
  lưu decision actor/time/note + audit; không insert Task, không reopen terminal.
- Accept: Request/Task/audit cùng session, commit atomic; insert/schema failure
  rollback; concurrent accept và retry response-lost trả một source/Task duy nhất.
- Retry ACCEPTED xác minh scope/source/type/id; giữ Task đang IN_PROGRESS/COMPLETED,
  content/assignment đã thay đổi; orphan/different source báo conflict, không repair ngầm.
- Standalone/no sessions/schema/index thiếu không ghi; JPA transaction manager
  không bị thay thế bởi cấu hình transaction của Request.
- Task summary Client/Manager đọc được đúng Workspace; Client không có editor link;
  POST Manager link đúng UUID vào content-writing, type khác không giả lập editor.
- Migration dry-run/apply-rerun, duplicate source và thiếu sourceRefId abort trước ghi;
  unique partial index không ảnh hưởng Task CAMPAIGN/manual; init parity.
- Browser fixture Manager receive→accept/deny, Client khóa sau receipt, 409 giữ note,
  loading chống double submit, retry + vi/en/light/dark/mobile; không API ghi thật.

## Kiểm chứng giai đoạn 3 — 2026-10-13

- Backend compile + lượt regression chọn lọc **160 pass, 1 skipped** (Atlas inventory
  opt-in không bật trong lượt regression). Bao gồm Request phase 2, ReviewService,
  ReviewController MockMvc, session/transaction unit tests, 13 real Mongo integration
  cases và các tests Package/Campaign deployment/Chat. Không phải full `mvn test`;
  chưa đo coverage bằng JaCoCo.
- 13 cases `ContentRequestAcceptanceMongoTest` chạy trên replica-set Mongo 7 local
  cô lập, cổng 27028: commit Task/Request/audit, default fields, POST/LIVESTREAM/SURVEY,
  rollback sau insert Task, rollback lỗi validator, duplicate ID conflict không overwrite,
  accept đồng thời một Task/một audit, retry giữ Task đã IN_PROGRESS và assignment/name,
  provenance sai không tự repair, receive→deny metadata, receive/cancel race,
  accept/deny race và source index thiếu không ghi ACCEPTED.
- `ContentRequestTransactionsTest` kiểm tra session binding/close, standalone/no
  session bị chặn, nhãn transient gốc được chuyển lại cho driver, lỗi storage,
  duplicate/validation mapping. Chưa chạy failover/unknown-commit network injection thật;
  retry ACCEPTED sau mất response đã được kiểm tra bằng gọi lại trên Task durable.
- Atlas chỉ read-only hello/inventory: replicaSet=true, mongos=false, sessions=true,
  maxWireVersion=25; content_requests 0 records/legacy indexes. Không apply migration.
- Migration offline **12 pass tổng** (7 phase 2 + 5 acceptance), gồm schema/index
  parity với init, default dry-run, ambiguity/duplicate/missing source abort, rerun.
  Init mới và acceptance migration cũng chạy thật dry-run→apply→rerun trên container
  tạm riêng: Request/Task count vẫn 0, source index unique/partial đúng. Không chạy init
  trên Atlas hoặc Mongo đang dùng của team.
- Web lint các file Request, TypeScript app/node, Vite production build pass.
  OpenAPI parse + 326 local refs resolve; vi/en keys song song.
- Playwright CLI fixture chặn toàn bộ API thật: Manager receive→accept (Task summary +
  POST editor URL đúng), Client không có review/editor actions, receive→deny lưu note/audit,
  409 giữ note và focus error, retry thành công, double-click chỉ một lần submit thành công.
  Client đọc được note, không reopen terminal. Không tương tác editor/Yjs hoặc API thật.
- UI 375/768/1440px, vi/en, light/dark; đã xem ảnh mobile confirmation/error và desktop
  dark. Không phải audit đầy đủ screen reader/contrast trên mọi trạng thái.

### Chạy lại integration test an toàn

Dùng replica-set test tạm **riêng** ở `127.0.0.1:27028`, không dùng Atlas. Test chỉ
được bật khi `BRANDHUB_REQUEST_TEST_URI` khớp host/cổng local này, tạo database có
prefix `brandhub_da951_it_` riêng mỗi case rồi cleanup chính database đó.

```powershell
$env:BRANDHUB_REQUEST_TEST_URI='mongodb://127.0.0.1:27028/?directConnection=true&replicaSet=da951test'
mvn -Dtest=ContentRequestAcceptanceMongoTest test
Remove-Item Env:\BRANDHUB_REQUEST_TEST_URI
```

### Phần còn lại để nghiệm thu runtime

Operator backup/freeze/review rồi apply phase-2 Request V2 và phase-3 acceptance
theo `docs/database/mongo-atlas-migrations.md`; sau đó smoke qua Gateway bằng account
test hiện có. Không có PostgreSQL migration mới. Chưa commit/push hoặc đóng Jira.
Giai đoạn 4 tiếp tục DA-949/950; giai đoạn 5 còn Package history/full regression.

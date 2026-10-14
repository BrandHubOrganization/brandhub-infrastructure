# Kế hoạch phần 3.5 còn lại

Ngày 2026-10-13; dựa trên spec đã chốt. Đây là thiết kế, chưa phải code/test đã chạy.

## 1. Thứ tự bàn giao và commit

| Giai đoạn | Phạm vi | Jira | Exit gate |
|---|---|---|---|
| 1 (hiện tại) | Đồng bộ BA/master-plan, spec → plan → task → test | DA-951, DA-949, DA-950, DA-943 | Quyết định Q1–Q3 đã chốt, tài liệu đủ và diff sạch |
| 2 | Request create/list/detail/update/cancel thật | DA-951 | Scope/quyền, Campaign gate, conditional writes và migration kiểm chứng |
| 3 | Manager receipt/review, accept → một Task Mongo | DA-951 | Retry/concurrency/rollback, Task provenance, editor handoff |
| 4 | Directory CRUD/deactivate và nối Campaign | DA-949 → DA-950 | Owner-only, lifecycle/history, race assign/delete, API/UI thật |
| 5 | History Package và regression xuyên suốt | DA-945; DA-943/946/947/948 theo lỗi | Package → Campaign → Task và Request → Task pass trên dữ liệu thật |

Commit nhỏ bằng tiếng Anh theo đúng Jira: `docs(DA-951): ...`, `feat(DA-951): ...`, `feat(DA-949): ...`, `fix(DA-950): ...`. Không tạo task ngoài scope bằng cách gắn vào Jira cũ; không tự cập nhật Jira Done. Làm trên feature branch, không code develop. Không commit thay đổi ChromaDB đang có.

## 2. Content Request — DA-951

### Contract dự kiến

Prefix `/api/v1/workspaces/{workspaceId}/content-requests`.

| Method/path | Quyền và hành vi |
|---|---|
| POST `/` | Client; title/description/type/dueDate; Campaign IN_PROGRESS + deployment SUCCEEDED; 201 PENDING |
| GET `/`, GET `/{id}` | Client/Manager hợp lệ theo Workspace; lọc status, search, page/size; DTO gồm version, requester, reviewer, generatedTaskId và timestamps |
| PATCH `/{id}` | Client tạo Request, PENDING; partial title/description/type/dueDate + expectedVersion |
| DELETE `/{id}?expectedVersion=...` | Client tạo Request, PENDING; CANCELLED, không xóa document |
| POST `/{id}/receive` | Manager của Workspace; PENDING → IN_PROGRESS; expectedVersion |
| POST `/{id}/accept` hoặc `/deny` | Manager; IN_PROGRESS → terminal; expectedVersion; deny có optional note |

Đối chiếu OpenAPI/routing/ApiResponse/ErrorCode trước implementation. Namespace lỗi dự kiến: REQUEST_NOT_FOUND, REQUEST_NOT_EDITABLE, REQUEST_NOT_CANCELLABLE, REQUEST_STATE_CONFLICT, REQUEST_VERSION_CONFLICT, CAMPAIGN_NOT_DEPLOYED, TASK_SCHEMA_NOT_READY; dùng HTTP 400/403/404/409 theo convention, không trả Mongo/SQL internals. Không cho query param/payload tự khai role/actor/Agency scope. Owner đang là Manager trong Workspace dùng quyền MANAGER hiệu lực, không bị role hệ thống che khuất.

Trường đầu vào tối thiểu: title không rỗng sau trim, type POST/LIVESTREAM/SURVEY, dueDate ISO-8601 có offset; description plain text. Giới hạn chiều dài và xử lý hạn đã qua phải đối chiếu validation Task/UI hiện có trước code; không tự truncate hoặc đổi múi giờ. PUT legacy nếu có consumer thật phải có adapter, không đổi contract âm thầm.

### Persistence và cạnh tranh

- Document V2: `_id`, workspaceId, requestedBy, title, description, type, dueDate, status, version, reviewedBy/reviewedAt, generatedTaskId, decision metadata, createdAt/updatedAt. Audit transition append trong cùng transaction, không mất lịch sử khi retry. Không dùng status Request để mô tả execution của Task.
- Request/update/cancel/receive/deny dùng filter `_id + workspaceId + status + version`; tăng version atomically, actor lấy từ principal. Không cho stale Client sửa sau receipt; race cancel/receipt có một người thắng.
- Guard create lấy Campaign của đúng Workspace và trạng thái deployment SUCCEEDED. Phối hợp lock/version với endpoint complete để quyết định thứ tự create/complete; không dựa vào status APPROVED hoặc UI cache. Sau complete chỉ chặn tạo mới, các endpoint của Request cũ giữ FSM riêng.
- Accept ưu tiên transaction Mongo chứa tạo Task + cập nhật Request ACCEPTED/generatedTaskId/audit. Xác minh Atlas topology và Spring MongoTransactionManager/config trước dùng; nếu không hỗ trợ thì dừng và trình phương án durable recovery, không ghi ACCEPTED trước rồi bỏ quên Task khi lỗi.
- Task ID ổn định từ requestId, unique partial index `(sourceType, sourceRefId)` cho CONTENT_REQUEST; nguồn/membership được verify nếu gặp duplicate. Task BACKLOG, campaignId null, assignee/QC null, provenance và defaults khớp TaskDocument; không tạo một bản Task PostgreSQL song song.
- Retry sau commit trả Task cũ; không reinsert/ghi đè Task đã bắt đầu làm. Schema guard kiểm tra đúng index/schema cho Request sources, không chỉ `uq_tasks_campaign_work_item` của Campaign.

### Migration và cutover

Implementation giai đoạn 2 (2026-10-13): API camelCase, `requests.v2.*` vi/en.
Title bắt buộc, trim và tối đa 255; description bắt buộc là chuỗi (cho phép rỗng),
tối đa 10.000; type chỉ POST/LIVESTREAM/SURVEY; dueDate bắt buộc ISO-8601 có offset.
Chưa bổ sung quy tắc hạn phải ở tương lai khi BA chưa yêu cầu.
PATCH bắt buộc `expectedVersion >= 1` và ít nhất một field được phép; DELETE nhận
`expectedVersion` qua query, hủy mềm và trả 204. Search tối đa 100; page >= 0,
size 1–50 (mặc định 20), sort createdAt/id giảm dần.
UI có QueryClientProvider riêng, không sửa provider/layout gốc; form giữ input khi
409, cảnh báo bỏ thay đổi, ngăn gửi lặp và giữ nguyên timestamp khi không sửa hạn.

1. Chỉ read-only inventory Atlas được phép: collection options, fields/types/status counts, thiếu workspace/type/dueDate, liên kết editor/task và nguồn dữ liệu. Báo các record không ánh xạ được; SUBMITTED có thể tương đương PENDING nhưng không tự quyết định ASSIGNED/APPROVED/REJECTED.
2. Viết migration JS mới có preflight, idempotency, dry-run và count verification; backup trước backfill. Nếu có legacy ambiguous thì abort trước mọi write; không xóa/ghi đè hoặc nhét type/date mặc định để chạy qua validator.
3. Đồng bộ `docs/database/init-mongo.js`, indexes và hướng dẫn `mongo-atlas-migrations.md`; không sửa migration đã merge hoặc init shared Atlas. Chạy schema parity trên DB test riêng khi được phép.
4. Chạy validation/index preflight trước bật API; rollout backend/gateway rồi UI. Rollback app không revert dữ liệu ACCEPTED/CANCELLED hay drop index; backup/restore chỉ theo phê duyệt riêng. Giữ migration cũ.

### Chi tiết giai đoạn 3 — 2026-10-13

- Tách `ContentRequestReviewService` và controller riêng cho receive/accept/deny để không
  đổi constructor/luồng create/update/cancel đã kiểm thử. Payload whitelist
  `expectedVersion` (integer >=1), deny thêm optional plain-text `note` <=2000.
- Receive/deny CAS một document, reviewer lấy từ principal. Receive chỉ PENDING;
  accept/deny chỉ IN_PROGRESS; stale version 409. Không kiểm tra trạng thái Campaign
  ở các thao tác Request đã tồn tại. Note lưu `decisionNote`, `decidedBy/decidedAt`
  và trong audit snapshot; không ghi đè reviewer đã tiếp nhận.
- Accept dùng Java driver `ClientSession.withTransaction` và MongoOperations gắn
  đúng session cho cả Request và Task; SNAPSHOT + MAJORITY. Driver retry transient
  transaction/unknown commit theo cơ chế chuẩn. Không đăng ký MongoTransactionManager
  bean toàn cục vì có thể làm Boot ngừng tạo JPA transaction manager của module khác.
- Kiểm tra `hello` read-only: replica-set/mongos, logicalSessionTimeoutMinutes,
  maxWireVersion >=7; nếu không hỗ trợ trả 503 và hỏi lại, không fallback partial writes.
  Không chạy `hello` hay schema/index commands bên trong transaction.
- Task ID UUID ổn định từ `content-request:{requestId}`; unique partial index
  `(sourceType, sourceRefId)` chỉ CONTENT_REQUEST. Không upsert/save Task đã có.
  Request ACCEPTED retry trả cùng Task nếu scope/source/type/id còn đúng; không sửa
  Task status/name/content/assignment đã được workflow E51 thay đổi.
- GET `/{id}/task` cung cấp Task summary read-only theo quyền đọc Request (id, name,
  type, dueDate, status). Chỉ effective Workspace MANAGER với Task POST có link vào
  editor hiện có; Client xem kết quả/status, không được mở editor hoặc nhận quyền mới.
- Migration phase 3 riêng, mặc định dry-run, kiểm tra duplicate/missing provenance
  trước tạo unique index; giữ migration phase 2. Init đồng bộ decision metadata/index.
- UI detail thêm actions theo capabilities server; confirmation cho accept/deny,
  giải thích accept sẽ tạo một Task; loading chống double submit, 409 giữ note.
  Giữ theme/tokens/typography hiện tại, không đổi layout/root hoặc UI thành viên khác.
- Runtime kiểm thử transaction chỉ trên DB local cô lập khi có Docker; không ghi
  vào Atlas hoặc dùng dữ liệu Workspace/account đang test của team.
- Tài liệu kỹ thuật tham chiếu: [Spring Data session-scoped operations](https://docs.spring.io/spring-data/mongodb/reference/mongodb/client-session-transactions.html)
  và [MongoDB Java driver 5.0 transactions](https://www.mongodb.com/docs/drivers/java/sync/v5.0/fundamentals/transactions/).
- Người dùng chốt: Task mới giữ default hiện có, BACKLOG, assignee/QC null,
  `requiresClientApproval=false`; Manager cấu hình ở bước xác định chi tiết E51.
  Read-only hello Atlas đã xác minh replicaSet=true, sessions=true, maxWireVersion=25.
  Retry ACCEPTED chấp nhận expectedVersion của lần accept gốc hoặc phiên bản terminal
  hiện tại, không nhận version tùy ý và không append thêm audit.

### Các repo/file dự kiến

- Business: document/repository Request mới, scoped controller/service/DTO/ErrorCode, generic Task source store và schema guard; phối hợp TaskContentService/editor owner, không sửa thuật toán Yjs.
- Gateway: kiểm tra route policy cho prefix Workspace, principal và lỗi; giữ auth/WebSocket hiện có.
- Web: `pages/requests`, typed API service/model mới, API thật theo workspaceId. Không đổi global mock/client-profile consumers ngoài phạm vi; bỏ assign/my-tasks từ UI Request V2 vì thuộc E51. Chỉ thay UI Workspace Request, không đổi shared layout module khác.
- Locales: `src/i18n/locales/{vi,en}/requests.json`; keys song song, namespace trạng thái riêng. Giữ thiết kế hiện có, light/dark, mobile, dirty form/conflict state. Đọc skill UI phù hợp trước khi chỉnh UI và Playwright skill trước browser automation.

## 3. Đối tác — DA-949/950

Xem [partner-directory/plan.md](../partner-directory/plan.md). Tái dùng entity/service liên kết DA-950; không AI/booking. Migration SQL và init parity chỉ ở giai đoạn 4, chưa chạy trong giai đoạn 1.

## 4. Phần Package/Campaign còn lại

- DA-945: giữ giới hạn clientProposalCount hiện có, thêm lịch sử immutable version/actor/action/snapshot và API đọc; terms/version/reset approvals/event cùng transaction. Không bịa lịch sử trước khi có event; đánh dấu snapshot legacy là baseline.
- DA-943: không scheduler; regression gate/redirect/Manager settings/Chat.
- DA-946/947/948: smoke approval đồng thời, một Campaign/Workspace, deploy/retry, Task source, editor và complete có lý do. Full negotiation history/withdraw approval chỉ implement sau đối chiếu spec sở hữu, không mở rộng ngầm.
- Không seed account mới hoặc sửa dữ liệu dùng chung. Cần quyền riêng trước test mutation trên Atlas/local có dữ liệu của team. Dùng account test hiện có và fixture kiểm soát, cleanup không đụng Workspace khác.

# Giai đoạn 1 — đề xuất kỹ thuật

Theo [spec.md](spec.md); A1–A3 được xác nhận 2026-10-08. Đây là contract để triển khai
các giai đoạn sau. Không có migration/application code trong giai đoạn này.

## 1. Campaign trong PostgreSQL

| Field / nhóm | Đề xuất | Nguồn và quy tắc |
|---|---|---|
| id | UUID, server generated | ID Campaign |
| workspaceMediaPackageId | UUID, required, UNIQUE, immutable | FK tới agreement; agreement.workspaceId đã UNIQUE nên đảm bảo một Campaign/Workspace |
| workspaceId | Trả trong DTO, suy ra từ agreement | Không cần lưu hai nguồn Workspace có thể lệch nhau |
| name | String, required, tối đa 255 | Manager nhập |
| strategyDetail | Text, tối đa 10000 | Có thể trống khi draft; bắt buộc trước approve |
| brandGuideline | Text, tối đa 10000, optional | Nội dung cho kế hoạch, không sửa Client profile |
| timeline | JSON object có startDate/endDate và milestones | Chốt timezone Workspace; các ngày ISO date, không suy mốc từ durationWeeks |
| packageTermsSnapshot / packageTermsVersion | JSONB / integer, server-only | Copy finalTerms/termsVersion khi tạo; immutable |
| deliverablePlan | JSONB | Các đầu ra của toàn gói, có ID ổn định và tổng số lượng; không có monthly allowance |
| workItems | JSONB array | Đầu việc tạo backlog, có ID ổn định; danh sách chưa đủ được lưu draft |
| contentVersion | Integer >= 1 | Tăng khi nội dung thay đổi thực sự; metadata vận hành không tăng |
| rowVersion | Optimistic-lock revision | Khác contentVersion; bảo vệ update/approve/deploy cạnh tranh |
| status | DRAFT / APPROVED / IN_PROGRESS / COMPLETED | Giữ enum hiện tại; triển khai riêng với deployment state |
| approvedByAgencyAt/Id/Version | Timestamp, actor UUID, integer | Duyệt phía Agency |
| approvedByClientAt/Id/Version | Timestamp, actor UUID, integer | Duyệt phía Client |
| completedAt / completedBy | Timestamp / UUID, server-only | Manager complete từ IN_PROGRESS |
| completionReason | Text <= 2000 | Bắt buộc, không chỉ whitespace, nếu còn Task chưa COMPLETED |
| completionTaskSummary | JSONB, server-only | Thống kê total/completed/unfinished ghi nhận tại thời điểm complete |
| createdAt / updatedAt | Timestamps | Audit |

Giữ các cột prototype allocations/allocation_period để tương thích đọc dữ liệu cũ.
Luồng mới dùng tổng sản lượng; payload period mới phải bị từ chối thay vì âm thầm bỏ.
Thêm dấu hiệu rõ `quantityBasis=TOTAL` trong catalogue và snapshot mới; nullable cho
legacy. UI không yêu cầu chọn ba offeringModel cũ. Không tự đổi gói "12 bài/tháng"
thành "12 bài cả gói"; phải
nhận diện từng snapshot thiếu thời hạn và yêu cầu xử lý tường minh, không sửa agreement đã chốt.

Work item đề xuất: id (UUID), deliverableId, name (<=255), type, dueDate (ISO instant).
Tham chiếu deliverablePlan để truy vết; không tính sản lượng bằng số Work item vì
một đầu ra có thể có nhiều bước thực hiện. Nếu đầu ra được tách thành nhiều đơn vị,
đặt ID cho từng đơn vị/nhóm và phân bổ rõ, tránh cộng sản lượng lặp giữa các bước.
Không dùng Task ID thay work item ID: Task chưa tồn tại trước deploy.

Campaign feedback lưu append-only record: id, campaignId, contentVersion, actorId,
comment, createdAt. Approval audit và nội dung các phiên bản cần lưu bền vững
(campaign_versions/approval events), không chỉ hai timestamp; version lưu snapshot
đủ để đối chiếu và không đổi sau khi được approve. Nhận xét của Client không tăng
contentVersion; Manager sửa mới tăng version/reset approvals atomically.

## 2. API đề xuất cho giai đoạn 2–4

Base: /api/v1/workspaces/{workspaceId}/campaigns. Giữ ApiResponse và X-Request-Id.

| Method/path | Payload chính | Quyền / kết quả |
|---|---|---|
| GET base | — | Thành viên được xem; danh sách 0 hoặc 1 Campaign |
| POST base | name, strategyDetail?, brandGuideline?, timeline?, workItems? | Manager/Agency Owner hợp lệ; server chọn agreement APPROVED của Workspace; 201 |
| GET /{id} | — | Kiểm tra id thuộc Workspace; 200 |
| PATCH /{id} | expectedVersion, các field kế hoạch được phép | Manager; DRAFT; 200/409; không nhận status/approval/snapshot từ client |
| POST /{id}/feedback | contentVersion, comment | Client; 201; thông báo phía Agency |
| GET /{id}/feedback | pagination | Hai phía xem lịch sử |
| GET /{id}/versions | pagination | Hai phía xem phiên bản/diff |
| POST /{id}/approve | expectedVersion | Agency hoặc Client đúng Workspace; 200; thao tác lặp cùng phía/version không nhân đôi |
| POST /{id}/deploy | expectedVersion, idempotency key | Manager; APPROVED; đề xuất 202 cùng deployment ID hoặc kết quả hiện có |
| GET /{id}/deployment | — | Tiến trình/error/retry state, không lộ stack trace |
| POST /{id}/complete | expectedVersion, reason? | Manager; IN_PROGRESS; 200; reason required nếu có Task chưa COMPLETED |

API cũ /api/v1/media-campaigns cùng gọi service mới và cùng uniqueness/RBAC checks;
không để client cũ vượt giới hạn. Gói chưa chốt không được tạo Campaign kể cả gọi route cũ.
Không thêm approval-required state mới tùy tiện; one-sided approval vẫn DRAFT.
No-op update không tăng contentVersion. Fully approved content immutable theo BA hiện hành.

Complete: server đọc Task Mongo theo campaignId và ghi summary/time/actor; Mongo lỗi
thì không suy số Task bằng 0. Có unfinished và reason trống trả 400 field error.
Không có unfinished thì reason optional. Request lặp khi đã COMPLETED trả bản hoàn
thành hiện có, không ghi đè lý do/actor. Không có re-open endpoint trong scope này.
Trạng thái COMPLETED của Campaign không khóa workflow Task con. Summary phản ánh
lần đọc khi hoàn thành, không hứa transaction chung giữa PostgreSQL và Mongo.

## 3. Mongo Task và specialist content

Mongo tasks giữ fields V2: workspaceId, campaignId, campaignWorkItemId, type, name,
dueDate, status, assigneeId, qcAssigneeId, requiresClientApproval, description,
typeMetadata, sourceType/sourceRefId và timestamps. Bổ sung createdBy khi cần giữ
tương thích editor. Mongo _id cho Task mới dùng UUID string canonical; API id vẫn UUID string.
Không đổi _id tài liệu Mongo hiện hữu một cách ngầm định: phải inventory kiểu ID,
refs và collisions trước khi thống nhất mapping cho dữ liệu legacy.

| Service | Task đề xuất | Nội dung chuyên biệt / trách nhiệm |
|---|---|---|
| SOCIAL_POST | POST | Editor hiện tại; posts chỉ đại diện bài đã publish |
| LIVESTREAM_PREPARATION | LIVESTREAM | livestream_sessions; idea/script theo E51, không làm phát sóng |
| WORKSHOP_SUPPORT | SURVEY cho khảo sát | survey_forms/responses và Meet capability gắn Task theo E51-08d; xác nhận adapter với chủ module |
| EVENT_PLANNING | EVENT_PLAN | event_plans theo taskId; chỉ nội dung kế hoạch bàn giao |
| PRESS_RECOMMENDATION | PRESS_RECOMMENDATION | press_recommendations theo taskId; không thay danh bạ/tracking DA-949/950 |

Contract tối thiểu cho hai collection mới: _id, taskId (unique), contentVersion,
createdAt, updatedAt. event_plans thêm planContent (nội dung kế hoạch dạng text),
referenceLinks[]; press_recommendations thêm recommendations[] gồm id, partnerName,
websiteUrl?, rationale và notes. Thông tin đối tác chỉ là đề xuất, không booking,
không tự tạo/cập nhật third_party_collaborators hoặc trạng thái hợp tác. Payload
chuyên biệt được bổ sung ở bước Identify Detail/authoring, không bắt buộc khi deploy
Task backlog. Schema form chi tiết được review cùng chủ E51 trước implementation.

Collection chuyên biệt không giữ workflow/assignee/status độc lập trùng với tasks.
Thêm Task type cần review validator, enums, filters/views, approval, notification và
publisher routing: chỉ POST được đưa vào pipeline publish hiện có. Không chỉ tạo collection.

## 4. Nối editor hiện tại với Task Mongo

Đề xuất ưu tiên: Mongo là nguồn Task; giữ Yjs operations/snapshots trong PostgreSQL,
tham chiếu bằng UUID task_id. Đây là dữ liệu nội dung editor, không phải bản sao Task.

Bằng chứng code đã đọc:
- Task.java + TaskRepository hiện là JPA/JpaRepository<Task, UUID>.
- TaskContentServiceImpl dùng TaskService.findTaskOrThrow, rồi truy vấn Yjs bằng UUID.
- TaskController, TaskContentWebSocketController và REST/WS dùng UUID taskId.
- Migration 2026-10-01-create-task-content-tables.sql đặt FK hai bảng nội dung tới PG tasks.
- Content Writing UI tự POST tạo Task khi URL thiếu taskId; cần giữ tương thích hoặc
  thay entry flow cùng chủ module, không để mở Campaign Task lại sinh một Task khác.
- WebSocket controller hiện chỉ lấy principal từ session rồi gọi appendOperation;
  handshake xác minh JWT, chưa thấy kiểm tra Workspace tại các entry point đã đọc.

Các bước chuyển đổi cho giai đoạn 4, cần phối hợp chủ editor:
1. Inventory PG tasks, mọi FK tới tasks, Mongo tasks/_id và refs từ approvals/posts;
   kiểm tra counts, UUID collision, orphan refs. Không chạy init/seed.
2. Backfill Task PG sang Mongo giữ nguyên UUID và timestamps/title→name. Không overwrite
   document trùng ID; sai Workspace/type là conflict phải dừng. Không suy tình trạng
   task cũ chỉ từ việc đã có Yjs content; quy tắc status mapping cần review dữ liệu.
3. Dùng maintenance window ngắn chặn ghi Task/editor; reconcile delta và counts.
   Sau verify mới cut over lookup/create sang Mongo. Trước cutover có thể bỏ bản
   backfill chưa dùng; sau cutover không rollback bằng cách trỏ lại PG đã lỗi thời.
4. Migration mới bỏ đúng FK từ bảng nội dung tới PG tasks, giữ NOT NULL/index và
   toàn bộ Yjs dữ liệu. Soft refs kiểm tra qua service Mongo và quyền Workspace.
   Không drop PG tasks ở lần đầu; giữ read-only để đối chiếu, không cho writer cũ chạy.
5. REST read/write/snapshot/restore và WS SEND/SUBSCRIBE cùng xác minh membership,
   Task Workspace/type và quyền hiện tại; không coi JWT hợp lệ là quyền với mọi Task.
6. Giữ wire DTO title như alias của name cho editor trong giai đoạn tương thích;
   GET content/version/restore và Yjs payload không đổi. Test các ID/URL cũ.
7. Chạy recovery, permission và editor regression trước bật Campaign deploy.

Đây là thiết kế tích hợp, không tự sửa editor hoặc tháo FK trong giai đoạn 1.
Rủi ro sequenceNumber đa tiến trình/snapshot đang thuộc editor phải review cùng
chủ module; không gộp refactor toàn bộ CRDT vào task Campaign.

## 5. Deployment và dữ liệu cũ

PostgreSQL transaction tạo deployment/outbox cùng campaign/contentVersion; worker
dùng workItems snapshot đã duyệt. Sinh ID Task một lần hoặc xác định ổn định và giữ
unique (campaignId, campaignWorkItemId); retry dùng set-on-insert, không update Task.
Chỉ index tài liệu có hai trường hợp lệ; fail/reconcile nếu tồn tại duplicate cũ.
Chỉ cập nhật Campaign IN_PROGRESS khi mọi insert được xác nhận; failure lưu retry
state, không tạo lại campaign. Logs có requestId/campaignId/deploymentId, không token.

Trước constraint 1:1, báo các Workspace có nhiều Campaign. Không tự xóa/gộp.
Mọi schema change có migration mới và init tương đương; không chạy trên Atlas ở giai đoạn 1.

## 6. Ranh giới bàn giao

DA-947: Campaign planning/schema/UI; DA-948: feedback/approval/deploy/complete.
Task/editor thay đổi xuyên E51 phải thống nhất task/owner trước implementation;
Post/Livestream/Survey/Meet chuyên biệt giữ owner trong master-plan. Task type mới
nếu được chốt cần cập nhật AC E51 và phân công, không giả định thuộc DA-947 toàn bộ.
Duplicate Workspace giai đoạn 5, không chặn Campaign planning. UI thêm namespace
campaign vi/en và đăng ký locale theo cấu trúc hiện tại; kiểm tra light/dark/mobile.

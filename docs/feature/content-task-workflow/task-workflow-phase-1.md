# Giai đoạn 1 — Task Detail, Assignment và Comments

Ngày 2026-10-14. DA-978 / DA-E51-04 (FR 3.6.1/2), DA-1236 / DA-E51-04b (FR 3.6.3).

## Kết quả và giới hạn

- BA mới nhất Q13 confirmed 2026-10-14: Client active xem/bình luận mọi Task cùng Workspace, kể cả
  Task Manager tạo thủ công và Task cũ. Bỏ phân biệt nội bộ/thường, field/default/index hiển thị và
  validation Q12. requiresClientApproval chỉ cấu hình duyệt kết quả; notification Q11 giữ nguyên.
- Q8 giữ nguyên: **Creator bấm Bắt đầu làm**, không tự start khi mở editor. Legacy thiếu lịch sử
  start/revision cần review trước mutation quản lý, không chặn đọc/bình luận theo membership.
- Mỗi FR có spec → plan → task → test; [contract chung](task-workflow-contract.md) chứa API mục tiêu,
  ma trận quyền, lifecycle/CAS, private upload/outbox và ranh giới module.
- Viết migration foundation additive, fresh init Mongo, checker và regression tests.
- **Chưa triển khai API/UI/worker**. Không đánh dấu FR hoặc Jira Done bằng kết quả schema tests.
- Không chạy migration trên Atlas/PostgreSQL đang dùng, không seed/backfill/xóa dữ liệu người dùng.
- Một test Business mới là tooling inventory **opt-in, chỉ đọc**, không load Spring context/seeders.

## Baseline và đồng bộ Infrastructure

Business `ecfdd84`, Web `b63b3a9`, Gateway `0364426`; chưa đổi code ứng dụng trong phase1.
Infrastructure merge `156e2c2`, gộp origin/develop `3f6689d` (15 commit mới), không conflict.
Stash đúng các tài liệu Task rồi apply lại thành công; giữ backup
`phase-1-task-docs-before-develop-sync-20261014`, không drop/pop/push.
Branch Infrastructure `docs/media-workflow-phase-1`; không code trên develop.

## Inventory thật — chỉ đọc

Chạy hai opt-in tests `ContentRequestAtlasInventoryTest` và `TaskWorkflowAtlasInventoryTest`,
chỉ aggregate/count/list metadata, URI lấy trong môi trường cấu hình nhưng không in/log ra ngoài.
Kết quả là snapshot lúc kiểm tra, không phải dữ liệu seed hay cam kết DB không đổi sau đó.

| Kiểm tra brandhub | Kết quả |
|---|---|
| Topology | Replica set + sessions, maxWireVersion 25 |
| Task tổng | 8, tất cả BACKLOG |
| Task CAMPAIGN | 4 POST |
| Task CONTENT_REQUEST | 1 POST + 1 SURVEY |
| Task thiếu sourceType | 2 POST, không tự suy nguồn để backfill |
| Thiếu workflowRevision/firstStartedAt | 8 / 8 |
| Task ASSIGNED thiếu lịch sử start | 0 tại snapshot; không suy dữ liệu tương lai an toàn |
| Request Task chưa gắn Campaign | 1; cần reconcile riêng trước closure Workspace tương ứng |
| task_approvals | Có collection/index, 0 documents |
| Comments/uploads/outbox | Chưa có ba collection mới |
| Content Request | 3: 1 IN_PROGRESS, 2 ACCEPTED |
| Unique source indexes | Có Campaign work item và Content Request; không trùng Request source |
| Task cancellation schema | **Chưa có CANCELLED và cancellation audit** |

Vì thiếu closure schema, foundation mới **chủ động từ chối** chạy trước dependency.
Không tự gán start marker cho 8 Task cũ. Không có thao tác tự gắn Campaign cho Request Task cũ.
Inventory là snapshot trước Q13; quyền đọc/bình luận mới không cần backfill hay marker hiển thị.
Playground inventory để thành viên kiểm tra lại: [task-workflow-inventory.mongodb.js](../../database/migrations/task-workflow-inventory.mongodb.js).

## Inventory writers và hợp đồng không được phá

| Writer hiện tại (Business) | Dữ liệu/đặc điểm phải giữ | Bổ sung về sau |
|---|---|---|
| CampaignTaskStore | ID deterministic theo Campaign/work item; sourceRefId=workItem ID | revision=0, marker null; đọc/bình luận theo WS |
| ContentRequestTaskStore | Request source unique, BACKLOG; campaign hiện tại, workItem=null | revision=0, marker null; đọc/bình luận theo WS |
| TaskServiceImpl | Editor tạo POST tối giản, Mongo identity; legacy SQL content/history còn dùng | Metadata revision/start; không đổi quyền/editor auto-create; Client đọc/bình luận theo WS |
| CampaignClosureService / cancellation store | Agreement lock; CAS status+updatedAt, cancellation audit | Cùng contract revision, không phục hồi CANCELLED |
| E51-03 Approval | approvalRound/history/submit/reject thuộc chủ module | Review first-start/CAS và duyệt lại QC ở lượt mới |

Phối hợp E51-05 list endpoint/entry point, E51-03 start/resubmit trước code tích hợp.
Chưa tự liên hệ/đổi Jira hoặc sửa code Approval/editor của thành viên khác.

## Migration và setup khi đến đợt rollout

File: [2026-10-14-task-detail-comments-foundation.js](../../database/migrations/2026-10-14-task-detail-comments-foundation.js).

1. Backup có thể phục hồi, xác nhận connection/database brandhub và tạm dừng writers.
2. Chạy checker chỉ đọc; nếu closure schema thiếu, review và áp **đúng**
   `2026-10-14-campaign-closure.js` theo [hướng dẫn Atlas](../../database/mongo-atlas-migrations.md).
   Review `unlinkedRequestTasks`; không tự sửa/xóa để làm preflight xanh.
3. Run All foundation với `globalThis.TASK_WORKFLOW_FOUNDATION_APPLY = false`.
   Script luôn chọn brandhub, kiểm validator/index xung đột, document không hợp lệ và duplicate unique keys
   trước mọi DDL. `blocked=true` hoặc exception → dừng review, không xóa dữ liệu/field/index tự động.
4. Chỉ khi operator đã duyệt preflight: đặt flag true trong cùng Playground run với toàn bộ script.
   Kết thúc đặt flag false, không để APPLY=true cho lần chạy sau. Đây là hướng dẫn, **chưa thực hiện trên Atlas**.
5. Chạy checker: `schemaChecks.taskWorkflowFoundation=true`; inventory số documents không thay đổi.
   Thiếu Mail/Chat/Post Versions không tự rerun toàn bộ migration Task cũ vì có thể ghi đè validator mới.
6. DDL nhiều collection không cùng transaction: nếu có lỗi vận hành sau khi bắt đầu DDL, giữ feature
   disabled, kiểm metadata và chạy lại an toàn. Không drop collections/indexes để rollback.
7. Khi triển khai ứng dụng mới, kiểm ACL/defaults/legacy review/start/transactions trước khi bật tính năng;
   schema MATCH không phải chứng minh permission hoặc API đã hoạt động.

Foundation chỉ thêm optional fields vào tasks và tạo ba collection riêng; không thêm required cho
Task cũ. Không xóa TTL/index cũ hoặc task_approvals; không thay typeMetadata/approved Campaign plan.
Draft foundation chưa commit/merge và chưa được agent áp lên Atlas nên chỉnh trực tiếp draft để
bỏ field/index hiển thị. Nếu môi trường khác đã tự áp draft trước Q13: không tự drop field/index hoặc
xóa documents; kiểm inventory và review riêng. Metadata dư không được dùng làm gate quyền trong ứng dụng mới.
SQL inbox `user_notifications` hiện có đã đủ; không tạo migration PostgreSQL cho ba FR này.

## Đồng bộ init và phần ngoài phạm vi

`init-mongo.js` fresh-only hiện có 24 collections, khớp 11 migration effects (gồm hai Mail Mongo
migration vừa merge). Mail validators/indexes được sao đúng từ migration, không sửa các migration đã merge.
Không chạy init lên Atlas hoặc database đang có dữ liệu.

Phát hiện riêng: upstream `2026-10-12-create-mail-sending-tables.sql` chưa được fold vào
`init-postgres-v2.sql`. Đây là thiếu đồng bộ **Mail của develop**, không phải schema Task cần thêm;
giữ ngoài đợt sửa Task này để người phụ trách review. Môi trường PostgreSQL mới cần chạy Mail migration
riêng nếu test Mail; không tuyên bố init PostgreSQL đã cover mọi thay đổi upstream.

## Kiểm chứng

Offline, không kết nối DB:

```powershell
node --test --test-isolation=none docs/database/migrations/tests/check-mongo-migrations.test.cjs docs/database/migrations/tests/content-requests-v2.test.cjs docs/database/migrations/tests/content-request-acceptance.test.cjs
```

**34/34 pass (sau Q13)**: checker read-only, init/cumulative validator/index parity, dependency guards,
DRY_RUN/APPLY/repeat, bảo toàn required/unknown fields/root clauses/indexes, xung đột trước mọi DDL,
invalid legacy/duplicate blocking, upload không TTL, Request V2/acceptance regression và inventory utility.
Q13 thêm case schema mới không có field/index hiển thị, và không drop metadata dư nếu operator từng
áp draft cũ ở môi trường khác. Đây không phải test API authorization; API/UI còn chưa triển khai.

MongoDB thật **7 local cô lập**, không network/host port và không dùng volume dữ liệu người dùng:
test [task-workflow-foundation.integration.js](../../database/migrations/tests/task-workflow-foundation.integration.js).
Pass DRY_RUN/APPLY/repeat, legacy no-backfill/old writer compatibility, enums/revision/date validation,
5MB WebP boundary, MIME/size reject, unique comment/outbox, preflight invalid data/late conflict;
checker thật đạt **11 MATCH, 0 MISSING/DRIFT/UNKNOWN**. Đã chạy lại sau Q13, xác nhận không tạo field/index
hiển thị và Task thủ công vẫn lưu requiresClientApproval=true độc lập nguồn.
Đây là schema test, không phải Task API/Mongo transaction/S3 integration hoặc test trên Mongo Atlas 8.x.

Test destructive chỉ được chạy trong container mới, DB brandhub trống, có đủ ba guard:
loopback URI + `BRANDHUB_SCHEMA_TEST_CONTAINER=1` + `BRANDHUB_ISOLATED_SCHEMA_TEST=true`.
Mount thư mục database read-only tại `/schema`; tuyệt đối không chạy file integration trên shared DB.

Business test inventory opt-in đã compile lại sau khi bỏ count của field hiển thị. Lần kiểm compile này
không đặt BRANDHUB_MONGO_INVENTORY_URI nên test được skip đúng guard, không kết nối DB thật.

Các test ứng dụng trong test.md vẫn **Chưa test**. Phase tiếp: nền API đọc workflow/ACL/Task Detail;
assignment/start và comments theo các giai đoạn tiếp theo, không lấy schema tests thay nghiệm thu FR.

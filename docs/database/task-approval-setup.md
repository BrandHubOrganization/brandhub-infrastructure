# FR 3.6.9 — Task Approval foundation / giai đoạn 2

Ngày 2026-10-18. [Spec](../feature/content-task-workflow/3-6-9-approval-sequence-creator-manager-client/spec.md), [plan](../feature/content-task-workflow/3-6-9-approval-sequence-creator-manager-client/plan.md), [migration](migrations/2026-10-18-task-approval-foundation.js), [checker](migrations/check-mongo-migrations.mongodb.js).

**Đã APPLY metadata/index trên Atlas ngày 18/10 sau khi người dùng duyệt reset đúng 5 Task về TODO. Preflight sạch; checker Approval/Task structure=true; document không đổi trong bước DDL. Mutation vẫn mặc định tắt, chưa rollout API/E2E thật. Xem [báo cáo 18/10](task-approval-preflight-2026-10-18.md). Inventory và mô tả blocked phía dưới là lịch sử trước APPLY. Không chạy init lên DB đang có dữ liệu.**

## 1. Thay đổi và tương thích

| Collection | Bổ sung | Giữ nguyên |
|---|---|---|
| tasks | lastSubmission optional/null: round, submittedBy/At, closedBy/At?, outcome? | Document, first-start evidence, revision, status, source, legacy QC/history |
| posts | task_id optional/null/string không trắng; uq_posts_task partial unique cho string | Bài độc lập; validator/required cũ, content_version, warn/error policy hiện có |
| task_approvals | uq_task_approvals_round_step (taskId,approvalRound,step); idx_task_approvals_timeline (taskId,createdAt DESC,_id DESC) | APPROVE/REJECT/comment/QC history, index đọc cũ |
| task_notification_outbox | TASK_REVIEW_REQUESTED/REJECTED + TASK_POST_SUBMITTED nội bộ; optional approvalRound, reviewStep, decisionId, postId, postContentVersion | Event types cũ/custom, payload, unique eventKey, lease/retry; không thêm collection |

Không thêm snapshot/kho phiên bản/collection round. Không thêm required field vào Task/Post cũ. Không đổi SQL init, PostgreSQL, task_content_operations/snapshots, Chat/Mail/AI/publisher hoặc Admin post_versions. Init mới vẫn giữ post_versions của Admin, không phải snapshot mới cho Task Approval.

Posts hiện validationAction=warn: migration **không** chuyển thành error. Unique index vẫn bảo vệ task_id dạng string; invalid task_id kiểu khác được DRY_RUN phát hiện và phải xử lý riêng, không được hiểu là DB đã chặn mọi Post field. Validation/khóa sửa linked Post ở ứng dụng thuộc giai đoạn 3/4.

## 2. Inventory Atlas chỉ đọc ngày 18/10

Kết quả là thời điểm kiểm kê, có thể đổi do team tiếp tục làm việc; phải DRY_RUN lại trước mọi APPLY.

| Dữ liệu | Kết quả |
|---|---|
| Task | 16; 5 thiếu revision/first-start evidence; 5 có QC assignment lịch sử |
| Active review chưa xác minh | **2 — chặn APPLY**, không tự đổi trạng thái/đoán lịch sử |
| Post | 39; 33 không khớp validator legacy đang warn (thông tin, không tự sửa/siết) |
| Post link trùng/sai kiểu/sai Workspace/type | 0 tại thời điểm kiểm kê |
| Task approval | 0 decision, 0 duplicate/orphan |
| Task notification outbox | 1 event, không document invalid theo validator đích |

Checker: Task structure/five-state/foundation/Request/Campaign metadata hiện có sẵn. Approval mới còn DRIFT vì field/index mới chưa APPLY. Tổng checker có MATCH=9, MISSING=2, DRIFT=3 (gồm các phần khác ngoài scope); không tự chạy các migration cũ/không liên quan để ép tất cả MATCH.

Không có lệnh write tới Atlas trong đợt này. Muốn APPLY: review riêng hai active Task, thống nhất với chủ dữ liệu/phần nội dung; reconciliation chỉ làm bằng danh sách được người dùng duyệt. Không đổi chúng thành TODO/IN_PROGRESS, đặt lastSubmission giả hoặc xóa Task để vượt preflight. Năm Task thiếu evidence vẫn đọc được; optional metadata migration không tự mở quyền sửa/giao việc cho chúng.

## 3. Dependency và preflight

Baseline cần Task/Campaign/Request acceptance + closure + Task foundation + five-state + **task-structure-simplification 17/10**. Dùng checker để biết effect hiện tại; file cũ đã nằm trong old_migration là lịch sử, không phải danh sách cần chạy lại.

Migration mới từ chối khi thiếu collection/baseline, field/index conflict, validation policy lạ, document invalid trong collection strict/error, Post link invalid/duplicate/orphan/cross-Workspace/wrong-type, decision trùng/orphan hoặc active review chưa xác minh. Reports chỉ chứa số đếm/lý do metadata, không URI/token/email/nội dung bài.

Trước APPLY: có phương án khôi phục theo chính sách team, pause **tất cả writer dùng chung Atlas** liên quan Task/Post/Admin/notifications (không chỉ Business local), kiểm report blocked=false, operator duyệt. Metadata DDL nhiều collection **không atomic**; nếu hỏng một phần thì giữ feature tắt, inventory lại và khôi phục/rerun có kiểm soát, không drop collection/index tự động.

## 4. VS Code MongoDB Playground

### DRY_RUN (an toàn, chạy được ngay)

Mở file `migrations/2026-10-18-task-approval-foundation.js`, chọn đúng connection và **Run All toàn bộ file**. Script tự chọn brandhub dù Playground hiện test. Không chỉ chạy dòng `globalThis...=false` vì dòng đó chỉ trả false, chưa thực thi migration.

Kiểm report: database=brandhub, mode=DRY_RUN, blocked, problems và inventory. Hiện Atlas có blocked=true do hai active review cũ: **dừng tại đây**. Metadata checker là chỉ metadata; DRY_RUN migration đọc thêm thống kê document/link để preflight.

### APPLY (chỉ sau khi đã được duyệt, hiện chưa được thực hiện)

Trong một Playground tạm, dùng khung dưới và dán **nguyên nội dung migration** vào vị trí comment, chạy cùng một lần. Không dựa vào global flags tồn tại qua nhiều lần Run All khác nhau. Không có load() thì không dùng đường dẫn file làm thay cho nội dung.

```javascript
globalThis.TASK_APPROVAL_FOUNDATION_APPLY = true;
globalThis.TASK_APPROVAL_WRITERS_PAUSED = true; // Chỉ khi mọi writer thực sự đã dừng.
try {
  // Dán nguyên nội dung 2026-10-18-task-approval-foundation.js vào đây.
} finally {
  globalThis.TASK_APPROVAL_FOUNDATION_APPLY = false;
  globalThis.TASK_APPROVAL_WRITERS_PAUSED = false;
}
globalThis.BRANDHUB_TASK_APPROVAL_MIGRATION_REPORT;
```

Chỉ coi thành công khi report có applied=true. blocked=true hoặc exception thì không resume feature. Không dùng flag paused để bỏ qua preflight: flag chỉ xác nhận thao tác vận hành, không tự dừng service hay khóa DB.

## 5. Mongosh và kiểm tra sau APPLY

Trong phiên shell đã kết nối đúng deployment (không đưa URI/password vào command/ticket):

```javascript
globalThis.TASK_APPROVAL_FOUNDATION_APPLY = false;
load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-18-task-approval-foundation.js');
globalThis.BRANDHUB_TASK_APPROVAL_MIGRATION_REPORT;
```

Nếu được duyệt và preflight sạch, bọc load() bằng try/finally như phần Playground, bật cả hai flag trong cùng phiên. Sau thành công, chạy lại migration DRY_RUN và checker toàn file. Trong mongosh, load() trả true; xem report qua `globalThis.BRANDHUB_MONGO_MIGRATION_REPORT`.

Kỳ vọng checker có schemaChecks.taskApprovalFoundation=true và taskStructureSimplification=true. Không có bảo đảm API đã implement chỉ vì metadata ready. Đối chiếu count/hash dữ liệu trước/sau bằng công cụ được team duyệt; không init/seed/backfill để “test”. Không chạy lại foundation/five-state cũ sau migration mới: chúng có thể thay enum/validator đích.

## 6. Kiểm thử đã thực hiện / cách chạy lại

Offline, không kết nối DB, không tạo test trong src:

```powershell
node docs/database/migrations/tests/check-mongo-migrations.test.cjs
node docs/database/migrations/tests/task-approval-foundation.test.cjs
node docs/database/migrations/tests/content-request-acceptance.test.cjs
node docs/database/migrations/tests/content-requests-v2.test.cjs
```

Kết quả 18/10: **48 tests Pass** (25 checker + 11 Approval + 5 acceptance + 7 Request V2). Sửa đường dẫn test tới file archived, không sửa nội dung migration cũ. Checker kiểm 14 schema effects và parity init↔migrations.

Rehearsal Mongo 7 replica set riêng, không port host, tmpfs, chỉ mount docs/database read-only: **79 assertions Pass**. Chứng minh DRY_RUN không ghi; APPLY/rerun không đổi document cũ; schema fresh init↔upgrade bằng nhau; legacy writer/QC history giữ nguyên; partial unique/decision unique hoạt động; invalid lastSubmission/outbox bị chặn; warn Post giữ nguyên; unknown review/duplicate/orphan/cross-Workspace/type conflict chặn trước DDL; transaction rollback khi duplicate.

Test `migrations/tests/task-approval-foundation.integration.js` tự từ chối nếu thiếu `TASK_APPROVAL_TEST_DATABASES_ALLOWED=true`, replica set khác `approval-test` hoặc host không loopback. Nó **có dropDatabase và fixture inserts/deletes trên server test riêng**; tuyệt đối không chạy trên Atlas/demo. Test yêu cầu mount docs/database vào /schema. Ví dụ sau chỉ dành cho container kiểm thử do operator tự tạo đúng cấu hình:

```powershell
docker exec <dedicated-test-container> mongosh --quiet --eval "globalThis.TASK_APPROVAL_TEST_DATABASES_ALLOWED=true; load('/schema/migrations/tests/task-approval-foundation.integration.js');"
```

Giai đoạn 3 bổ sung: 91 tests hồi quy hiện có và 187 kiểm tra smoke backend/Mongo transaction riêng Pass; chi tiết ở [test plan](../feature/content-task-workflow/3-6-9-approval-sequence-creator-manager-client/test.md#kiểm-tra-giai-đoạn-3--2026-10-18).

Chưa kiểm: UI/end-to-end, SQL ACL/Campaign concurrency/inbox thực tế và tích hợp Editor/Admin/publishing của giai đoạn 4–6, Atlas APPLY và reconciliation hai active Task. Không đánh Done FR/Jira từ kết quả DB/backend tests.

## 7. Trạng thái rollout backend giai đoạn 3

Code Business có sáu endpoint review/history/submit/withdraw/approve/reject. `TaskApprovalProperties` mặc định `app.task-approval.post-integration-ready=false` (environment tương ứng `APP_TASK_APPROVAL_POST_INTEGRATION_READY`); không cần thay .env hay bật cờ để chạy các tính năng cũ. Mutation mới trả 503 `TASK_REVIEW_INTEGRATION_NOT_READY` nếu schema đã sẵn nhưng POST integration chưa bật; nếu schema thiếu thì `TASK_SCHEMA_NOT_READY`. Read/history vẫn dùng ACL hiện có và có thể xem trạng thái/lịch sử.

**Không bật cờ trên môi trường chung lúc này.** Giai đoạn 4 phải tích hợp link Task–Post, khóa mọi writer của bài liên kết, expectedTaskRevision/content_version, POST submit cũ và hook Admin. Chỉ bật trong bài test Mongo riêng của giai đoạn 3 không chứng minh đã an toàn cho demo/Atlas. Không có snapshot, không gọi publisher, không có migration PostgreSQL mới.

Harness local đặt ngoài src, dưới target ignored. Đã kiểm bằng classes javac 21 riêng do IDE có lúc ghi đè target/classes bằng bytecode báo lỗi “Flexible Constructor Bodies”; không sửa POM hoặc cấu hình IDE của team để vượt qua. Khi tái kiểm cần build sạch bằng Java 21 và tránh IDE auto-build ghi cùng output trong lúc Maven/test chạy. Đây không phải lỗi schema và không được xử lý bằng init DB.

## 8. Bổ sung core giai đoạn 4 (chưa mở rollout)

Foundation migration **chưa merge/chưa APPLY** đã được bổ sung optional outbox postId (nullable string không rỗng), postContentVersion (int/long >=1) và TASK_POST_SUBMITTED. Init/checker đồng bộ, 48 offline tests + 84 assertions schema replica set mới Pass. Không sửa migration lịch sử đã merge, không thêm PostgreSQL migration, không chạy Atlas.

TASK_POST_SUBMITTED là durable Admin handoff, không phải notification gửi User: worker riêng chỉ claim event này, kiểm Post/link/version rồi gọi hook onSubmitted hiện có ngoài Mongo callback; notification worker chỉ claim event được giao. Retry dùng cùng lease/deterministic event key, Admin dedup theo Post/content version hiện có. Không có snapshot mới cho Task; post_versions của Admin vẫn thuộc module Admin.

Task Editor/API mới dùng GET/POST /tasks/{taskId}/post và POST /tasks/{taskId}/submit; bài chưa tạo GET trả post=null, không ghi. Save nhận expectedRevision và expectedPostContentVersion khi cập nhật, touch Task cùng transaction. PATCH/submit Post cũ chặn linked Post với TASK_POST_WORKFLOW_REQUIRED; Post độc lập giữ DTO/flow cũ. Admin DRAFT vẫn giữ Task ở lượt/bước đang chờ, chỉ mở recovery withdraw/reject đúng quyền, không tự decision.

94 hồi quy + 231 kiểm tra smoke backend Pass; browser chỉ fixtures riêng, không dữ liệu demo. Frontend lint/bundle Pass nhưng type-check toàn Web còn lỗi baseline không thuộc phần này (xem test.md). Chưa kiểm SQL/Admin/inbox end-to-end. Người dùng chốt ngày 2026-10-18 giữ nguyên publish, chờ thành viên phụ trách tích hợp writer; **không bật APP_TASK_APPROVAL_POST_INTEGRATION_READY trên môi trường chung**. Atlas inventory giai đoạn 2 không được dùng thay DRY_RUN mới; hai Task active cũ vẫn chưa được xác minh hoặc sửa.

## 9. UI giai đoạn 5 (không có migration mới)

Popup Task đã có phần Phê duyệt kết quả, nội dung POST hiện tại, action theo API và lịch sử decision theo lượt. Bước cuối chỉ FINISHED, không publish. Nhận xét duyệt tách khỏi bình luận Task. Lỗi/conflict giữ note; tải lại rồi kiểm nội dung trước khi xác nhận lại, không tự replay.

Giai đoạn này chỉ đổi Web/tài liệu, không thêm schema/PostgreSQL migration hoặc yêu cầu chạy init. 30 kiểm tra browser fixtures + 71 guard/locale checks Pass không chứng minh Atlas/inbox/Gateway đã sẵn sàng. Khi gate false, UI hiển thị chưa bật tích hợp và không mở action; đây là dự kiến, không phải lý do chạy lại init. Vẫn giữ gate false tới khi chủ publish phối hợp writer, operator xử lý preflight/legacy và kiểm thử tích hợp giai đoạn 6 hoàn tất.

## 10. Yêu cầu APPLY và kiểm tra lại ngày 18/10

Người dùng đã xác nhận tất cả writer dùng chung dừng. DRY_RUN thực tế mới đọc 28 Task / 44 Post / 0 decision / 1 outbox; **blocked bởi 5 unverifiedActiveReviews**, không phải 2 như inventory cũ. Chưa APPLY, không live document/DDL writes. Danh sách Task và phạm vi schema ở [báo cáo preflight](task-approval-preflight-2026-10-18.md). Cần quyết định riêng để xử lý dữ liệu cũ, không bỏ guard hoặc suy lịch sử để chạy tiếp. Khi tiếp tục phải preflight lại và xác nhận writer freeze còn hiệu lực.

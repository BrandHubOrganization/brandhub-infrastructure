# Test Specification — FR 3.6.9: Approval Sequence (Creator -> Manager -> Client)

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.9` |
| **Function Name** | Approval Sequence (Creator -> Manager -> Client) |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `TaskApprovalService.approve()` (64 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/TaskApprovalServiceTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Enforce multi-stage approval workflow (Creator -> Manager -> Client) and reset to Creator with audit log on rejection |
| **Preconditions** | Can connect with server; Task exists in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 21** (`Passed`: 21, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 12, `Boundary (B)`: 2, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID21`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR of workspace; Task status is ASSIGNED, no QC, no client approval | `action` = `submit` | 200 OK - status=MANAGER_REVIEW | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR of workspace; Task status is ASSIGNED, QC assigned | `action` = `submit` | 200 OK - status=QC_REVIEW | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR of workspace; Task status is ASSIGNED, QC approval already passed | `action` = `submit` | 200 OK - status=MANAGER_REVIEW (skip QC) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR of workspace; Task status is ASSIGNED, QC and Manager approvals passed | `action` = `submit` | 200 OK - status=CLIENT_REVIEW (skip QC, Manager) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is QC assignee; Task status is QC_REVIEW | `action` = `approve`, `step` = `qc` | 200 OK - status=MANAGER_REVIEW | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is MANAGER of workspace; Task status is MANAGER_REVIEW, no client approval | `action` = `approve`, `step` = `manager` | 200 OK - status=COMPLETED | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MANAGER of workspace; Task status is MANAGER_REVIEW, requiresClientApproval=true | `action` = `approve`, `step` = `manager` | 200 OK - status=CLIENT_REVIEW | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is CLIENT of workspace; Task status is CLIENT_REVIEW | `action` = `approve`, `step` = `client` | 200 OK - status=COMPLETED | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; User is QC assignee; Task status is QC_REVIEW | `action` = `reject`, `step` = `qc`, `reason` = `needs fix` | 200 OK - status=ASSIGNED | — | **Passed** |
| `UTCID10` | `N` | Can connect with server; User is MANAGER of workspace; Task status is MANAGER_REVIEW, QC approved | `action` = `reject`, `step` = `manager`, `reason` = `needs fix` | 200 OK - status=ASSIGNED, QC approval kept | — | **Passed** |
| `UTCID11` | `N` | Can connect with server; User is CLIENT of workspace; Task status is CLIENT_REVIEW, Manager approved | `action` = `reject`, `step` = `client`, `reason` = `needs fix` | 200 OK - status=ASSIGNED, Manager approval kept | — | **Passed** |
| `UTCID12` | `N` | Can connect with server; User is MANAGER of workspace; Task has 3 approval records | `action` = `list approvals` | 200 OK - list(step, action, actorId, comment, createdAt) | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is CREATOR of workspace; Task status is ASSIGNED, no QC, no client approval | `action` = `submit`, `path` = `shortest chain` | 200 OK - submit then manager approve gives COMPLETED (2 steps) | — | **Passed** |
| `UTCID14` | `B` | Can connect with server; User is MANAGER of workspace; Task status is MANAGER_REVIEW | `action` = `reject`, `step` = `manager`, `reason` = `1 char` | 200 OK - status=ASSIGNED | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Task status is QC_REVIEW; User is CLIENT of workspace | `action` = `approve`, `step` = `client` | 403 WRONG_APPROVAL_STEP | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Task status is QC_REVIEW; User is MANAGER of workspace | `action` = `approve`, `step` = `manager` | 403 WRONG_APPROVAL_STEP | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Task status is QC_REVIEW; User is another creator (not QC) | `action` = `approve`, `step` = `qc` | 403 WRONG_APPROVAL_STEP | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is MANAGER of workspace; Task status is ASSIGNED (not submitted) | `action` = `approve`, `step` = `manager` | 409 TASK_NOT_SUBMITTED | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; User is MANAGER of workspace; Task status is MANAGER_REVIEW | `action` = `reject`, `step` = `manager`, `reason` = `null` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; User is CREATOR of workspace; User is not the assignee | `action` = `submit` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; User is MANAGER of workspace; Task does not exist | `action` = `approve`, `step` = `manager` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.9`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test plan — FR 3.6.9

## Kiểm trang duyệt riêng

Kiểm menu/URL deep link đúng Workspace, POST/IN_REVIEW mặc định, search/page/status thực gọi API; loading/error/retry/empty. Chọn bài chỉ tải review của bài đó, đúng caption/version; action vẫn APIallowedActions. Duyệt/từ chối cập nhật danh sách, bài được chọn vẫn xem được kể cả rời filter sau quyết định. Note chưa gửi có app discard guard khi chuyển bài/lọc/page; pending chặn chuyển. Task Detail không có review section nhưng có link. Mobile 375/tablet768/desktop1440, vi/en, light/dark, keyboard; API fixtures không ghi DB demo. Notification cũ vẫn mở Task và đi tiếp bằng link, không thay backend notification trong scope này.

Kết quả tách trang: 15 browser checks flow/list/detail/reject/note-preservation/search/pagination/mobile return/viewport đạt; 6 checks bổ sung en/status filter/list 503-retry/keyboard đạt. Playwright CLI session riêng, Vite 3012, mọi API đều fixtures. Đã xem ảnh 375/768/1440 light/dark, vùng cuộn nằm trong viewport và không tràn ngang; đổi theme đợi transition trước chụp. Lỗi locator/timing ban đầu sửa trong harness rồi chạy lại sạch, 503 console là fixture cố ý. 15 key approvalPage vi/en song song; lint page/component/menu/access/layout/navbar đạt, Vite production bundle đạt. Toàn Web type-check còn đúng 12 lỗi baseline ở content-writing/useTaskContentSync, editor/MediaDropzone, workspace/dashboard và hai unused imports AppRoutes; không sửa ngoài scope, không gọi npm build/typecheck toàn repo Pass. Không kiểm HTTP/Gateway/ACL thật, browser back khi note chưa gửi hoặc mọi role end-to-end. Không thay DB/backend/publish, không thêm test trong src; artifact local ignored, không commit/push.

## Kiểm tra bổ sung — bỏ cờ tích hợp

Không khai báo cờ: Creator IN_PROGRESS được lưu/gửi; Manager/Client đúng bước được quyết định; worker handoff đăng ký bình thường. TODO/chưa start, sai assignee, schema thiếu, version cũ và nội dung đang duyệt vẫn bị chặn; reject/withdraw/resubmit giữ hành vi cũ. Cờ cũ không còn tác động. Không test publish thật hoặc mở Spring writer vào Atlas. Các kết quả gate=false bên dưới là kiểm thử lịch sử.

Kết quả: Maven compile BUILD SUCCESS; javac 21 classes riêng đạt; ApprovalSmoke 186 checks và TaskPostSmoke tổng 230 checks đạt trên Mongo 7 replica set approval-api-test chỉ localhost 62871, tmpfs. Harness bỏ các assertion cờ cũ, thay bằng default-config canSubmit/blockReason checks; các kịch bản state/ACL/concurrency/rollback/save/handoff còn lại giữ nguyên. Không thêm test trong src. SQL/ACL/Admin/inbox dùng mock, chưa phải HTTP UI/Gateway E2E. Source src/main không còn tham chiếu cờ/config; không diff PostPublishServiceImpl, không thay schema/Atlas.

Theo [spec](spec.md) và [task](task.md). TA-28 đã kiểm DB/schema giai đoạn 2; giai đoạn 3 đã kiểm backend/Mongo riêng theo mục kết quả cuối file. Các ca bên dưới vẫn là phạm vi đích end-to-end: ghi Pass BE hoặc Một phần không có nghĩa Editor/UI/SQL runtime đã hoàn tất. Không suy ra Pass từ review tài liệu; không dùng Atlas/demo data làm dữ liệu test tự động, không gửi bài lên mạng xã hội thật. Không thêm/commit file test trong src; tests schema đặt ngoài src dưới docs/database/migrations/tests.

| ID | AC | Loại | Điều kiện / thao tác | Mong đợi | Trạng thái |
|---|---|---|---|---|---|
| TA-01 | 01,05 | Happy | Assignee active, POST IN_PROGRESS, bài hợp lệ, Manager active, không yêu cầu Client; submit | IN_REVIEW/MANAGER, lượt đầu 1, bài khóa; không decision tạo sẵn | Pass BE; khóa mọi Post writer chờ GĐ4 |
| TA-02 | 07,14 | Happy | Manager approve TA-01 | FINISHED, reviewStep=null, một APPROVE, không publish job | Pass BE 18/10 |
| TA-03 | 07,08,16 | Happy | Cần Client, đủ thành viên; Manager approve rồi một Client approve | Chờ CLIENT rồi FINISHED, hai decision cùng lượt, notification đúng bước | Pass BE/outbox; chưa inbox E2E |
| TA-04 | 10,12 | Happy | Manager reject có lý do, Creator sửa chính bài rồi submit | IN_PROGRESS→IN_REVIEW/MANAGER, round+1, brief/assignee vẫn khóa | Pass BE; chưa sửa qua Editor |
| TA-05 | 06,10 | Happy | Client reject sau Manager approve; sửa/gửi lại | Giữ hai decision lượt cũ; lượt mới bắt đầu Manager, không skip | Pass BE; chưa Editor |
| TA-06 | 11 | Happy | Creator withdraw trước Manager decision | IN_PROGRESS, mở bài hiện tại, không REJECT giả; submit lại round+1 | Pass BE; chưa Editor |
| TA-07 | 11 | Error | Withdraw khi đang chờ Client hoặc Task chưa submit | 409, không đổi Task/Post/lượt/history | Một phần BE: chờ Client bị chặn |
| TA-08 | 01 | Error | Creator khác submit/withdraw; Client duyệt bước Manager; Owner không có membership Manager | 403; không side-effect | Chưa test |
| TA-09 | 01 | Error | Sai Workspace/task/post, member đã rời hoặc User bị khóa | 401/403/404 đúng envelope; không lộ content/ID ngoài scope | Chưa test |
| TA-10 | 02,05 | Error | Chưa có Post, caption trắng, Task TODO hoặc loại chưa có adapter | Lỗi rõ; không auto-start/auto-create/submit giả | Pass BE 18/10 |
| TA-11 | 09 | Error | Cần Client nhưng không có Client active; hoặc chỉ profile chưa gắn User | Chặn submit, báo bổ sung Client, Task/Post/round giữ nguyên | Một phần: danh sách active mock, chưa SQL profile |
| TA-12 | 09 | Edge | Hết Client khi đang chờ CLIENT; bổ sung Client mới | Giữ bước/Manager decision; Client mới có quyền, không tự skip | Pass BE với ACL mock |
| TA-13 | 08,15 | Edge | Hai Client active đồng thời approve/reject cùng revision | Chỉ một decision thắng; bên còn lại conflict, không chuyển hai lần | Pass BE/Mongo transaction |
| TA-14 | 11,15 | Edge | Creator withdraw đồng thời Manager approve/reject | Một thao tác thắng; không tồn tại trạng thái mở bài + decision có hiệu lực trái nhau | Pass BE/Mongo transaction |
| TA-15 | 03,15 | Edge | Save Post đồng thời submit; approve dùng Post version cũ | CAS conflict khi stale; không duyệt nội dung chưa xem; Task/Post nhất quán | Một phần: stale Post version Pass; save race chờ GĐ4 |
| TA-16 | 03,14 | Error | Gọi API update/submit cũ để sửa linked Post đang review; Admin đổi Post về DRAFT | Khóa theo Task vẫn chặn; API cũ không bypass, không tự Task reject | Chưa test |
| TA-17 | 02 | Edge | Tạo Post cho cùng Task từ hai tab; reopen sau save/submit/reject | Một Post linked; mở đúng bài, không tự tạo draft thay lỗi | Chưa test |
| TA-18 | 04,06 | Edge | Reject nhiều lượt, xem history rồi sửa bài hiện tại | History append-only đúng round/actor/comment; không hiển thị bản cũ/diff giả | Pass history BE; chưa UI/Editor |
| TA-19 | 10,15 | Error | Reject lý do trống/quá dài; thiếu revision/round; step giả | 400/409 đúng contract, không tăng round/notification/decision | Pass BE/MockMvc |
| TA-20 | 12 | Edge | Task đã FINISHED hoặc CANCELLED, thao tác submit/withdraw/decision | Chặn; không reopen; comment Task vẫn theo FR3.6.3 | Một phần BE; chưa comment sau terminal E2E |
| TA-21 | 13,15 | Edge | Bulk cancel đang IN_REVIEW đồng thời approve; closure Campaign đồng thời submit | Không approval sau hủy/hoàn thành; giữ audit/history; bước chờ được dọn | Mongo cancel↔decision Pass; SQL closure race chưa test |
| TA-22 | 15 | Error | Lỗi giữa Task update/Post update/decision insert/outbox insert; duplicate key | Rollback toàn Mongo transaction; không record nửa chừng/thông báo giả | Pass BE: outbox failure/duplicate decision rollback |
| TA-23 | 15 | Edge | Response bị mất sau commit, người dùng bấm lại cùng revision | 409 rồi reload; không nhân đôi decision/lượt; không replay tự động | Pass BE stale replay; chưa UI reload |
| TA-24 | 16 | Happy | Submit, Manager chuyển Client, Client/Manager reject | In-app đúng nhóm, dedup, không email; không gửi caption/reason nhạy cảm | Pass outbox/worker với inbox mock |
| TA-25 | 16 | Edge | Withdraw/chuyển bước/rời Workspace trước worker delivery; worker chết sau SQL insert | Suppress yêu cầu chờ lỗi thời; retry inbox không trùng; reject vẫn theo ACL | Một phần: step/round/removed ACL suppression Pass |
| TA-26 | 03,14 | Edge | Post độc lập, Admin moderation và publishing hiện có | Không ép Task, không bỏ hook Admin, không tự publish; hồi quy không gửi social thật | Chưa test |
| TA-27 | 12,15 | Error | Legacy QC/missing reviewStep/round evidence | Đọc lịch sử được; mutation fail closed, không đoán lịch sử/backfill | Một phần: thiếu first-start và working/QC step bị chặn |
| TA-28 | 02,06,15 | Edge | Migration DRY_RUN/rerun/fresh-init/upgrade, duplicates và index conflicts | DRY_RUN không ghi; conflict dừng trước ghi; metadata parity, không xóa document | Pass DB 18/10; API chưa test |
| TA-29 | 17 | Happy | UI light/dark ở 375/768/1440px; chuyển vi/en | Token/contrast, key-parallel, không tràn popup, không text key thô | Pass UI fixtures; không audit contrast toàn app |
| TA-30 | 17 | Edge | Keyboard submit/reject/withdraw, network chậm/lỗi, conflict khi đang nhập | Focus hợp lý, lỗi gần field, loading/disable, giữ input; không native dialog | Pass UI fixtures focus/Escape/lý do/409/double action; chưa E2E |
| TA-31 | 12,17 | Edge | Refresh Approval khi đang gõ Task comment; sau reject Manager sửa brief | Không mất draft comment; brief/assignment vẫn khóa sau start | Pass UI giữ comment; quyền brief backend theo GĐ3, chưa E2E |
| TA-32 | 01,07 | Edge | Manager bị thay; người cũ dùng tab cũ, người mới duyệt | Người cũ bị chặn; Manager active hiện tại quyết định đúng lượt | Chưa test |
| TA-33 | 05 | Edge | Task IN_PROGRESS quá dueDate nhưng còn Campaign hợp lệ | Không thêm luật chặn nộp quá hạn ngoài BA; quyền/validation khác vẫn kiểm | Pass BE, fixture quá dueDate; Campaign SQL mock |
| TA-34 | 03,14 | Edge | URL media bên ngoài đổi byte nhưng field không đổi | Ghi đúng giới hạn không snapshot; không công bố khả năng khôi phục media cũ | Chưa test |
| TA-35 | 14,15 | Error | Stage 3 default config, hoặc schema chưa APPLY | Read/history còn xem được; mutation fail closed 503, không đổi Task/Post/decision/outbox | Pass BE gate/schema drift |
| TA-36 | 02,03,15 | Edge | Lưu mới/cập nhật cùng Task; hai tab tạo/lưu cùng revision; đổi Workspace | Một link đúng scope, CAS conflict, không tăng round, không ghi ngoài scope | Pass BE create/save/submit race; scope theo ACL mock |
| TA-37 | 03,10,11,14 | Edge | Admin đổi linked Post về DRAFT trong lúc IN_REVIEW | Giữ lượt/step; approve bị chặn; withdraw trước Manager/reject đúng bước còn làm được, không tự decision | Pass BE recovery; Admin BLOCK thực tế chưa E2E |
| TA-38 | 14,15 | Edge | Crash sau submit commit/trước Admin hook; retry worker; sửa sang version mới trước delivery | Handoff tồn tại trong outbox; hook idempotent hoặc suppress version cũ; không capture sai version/không gọi hook trong retry callback | Mongo/outbox/retry/stale version Pass; SQL Admin mock |
| TA-39 | 03,14 | Error | Gọi PATCH/submit Post cũ trên linked Post đang làm/đang duyệt/FINISHED | TASK_POST_WORKFLOW_REQUIRED, không save/hook; Post độc lập không bị ép vào Task | Service guard + hồi quy standalone Pass; chưa Gateway E2E |
| TA-40 | 02,03,17 | Edge | Editor Task reload/reject/reopen, route đổi khi request/save đang chạy | Đúng bài, không prefill brief/mock, giữ s3Key, không stale response/auto-create fallback, lỗi vẫn dirty | Browser fixture + S3 helper Pass; route race chưa mô phỏng |
| TA-41 | 03,15,17 | Error | Popup tải review và nội dung có version/revision khác nhau, hoặc refetch lỗi | Vẫn đọc được trạng thái nhưng khóa quyết định; tải lại nội dung để đối chiếu, không tự duyệt bản chưa xem | Pass guard/UI fixtures mismatch, lỗi refetch và khôi phục |
| TA-42 | 10,15,17 | Error | Dialog reject lý do trắng, conflict/response mất, tải lại trạng thái/nội dung | Lý do giữ nguyên; người dùng xem lại nội dung và bấm xác nhận mới gửi; không tự replay | Pass UI rỗng/409/giữ lý do/reload/xác nhận lại; response mất sau commit chưa mô phỏng |
| TA-43 | 04,17 | Edge | History nhiều cursor, có QC legacy; Task loại chưa hỗ trợ; caption có HTML/script | Nhóm theo lượt, giữ label lịch sử không có nội dung cũ; không action/QC mới; render text an toàn; không gọi Post adapter cho loại khác | Pass UI fixtures + URL guards |

Hồi quy bắt buộc: Campaign sinh Task và hủy/hoàn thành; Request acceptance gắn Campaign; Manager assignment/deadline/autosave; Creator explicit Start; comments/mentions/private images; Post độc lập; Yjs history không đổi; notification cũ. Khi chạy phải ghi môi trường/cách ly và kết quả thật, không tự đánh Done FR khi các điểm tích hợp chưa được kiểm chứng.

## Kiểm tra tài liệu giai đoạn 1 — 2026-10-18

- PASS: 49 liên kết local trong bộ FR mới/các dòng liên kết được thêm ở tài liệu chung đều trỏ tới file tồn tại.
- PASS: cả 17 AC có test case tham chiếu; 34 ca runtime vẫn là “Chưa test”, không đổi thành Pass từ review tài liệu.
- PASS: git diff --check không có lỗi whitespace; thay đổi chỉ ở 15 file Markdown Infrastructure. Business/Web/Gateway clean, docs/database không đổi; không commit/push/APPLY.
- Chưa thực hiện: fetch/merge develop, team review, Report 3/4 chính thức, xác minh/cập nhật Jira; không giả định những bước này đã hoàn tất.

## Kiểm tra giai đoạn 2 — 2026-10-18

- PASS: 48 tests offline (25 checker, 11 Approval foundation, 5 Request acceptance, 7 Request V2). Fresh init đủ 14 schema effects; sửa resolver archived trong tests, không sửa migration cũ.
- PASS: Mongo 7 replica set riêng, 79 assertions; schema fresh↔upgrade parity, DRY_RUN không ghi, APPLY/rerun giữ document, BSON/index enforcement, unknown/duplicate/orphan/type/Workspace conflicts, transaction rollback. Container không gắn volume demo hoặc port host.
- ATLAS READ_ONLY: 16 Task, 39 Post, 0 approval, 1 outbox; hai active review chưa xác minh chặn APPLY. 33 Post legacy validator warn được báo, không siết/sửa. Không Atlas writes; không SQL changes.
- Giới hạn: chưa APPLY Atlas, chưa reconciliation hai Task cũ, chưa test API/UI/Editor/Admin/publishing. Chi tiết và cách chạy lại ở [setup](../../../database/task-approval-setup.md).

## Kiểm tra giai đoạn 3 — 2026-10-18

- PASS: Maven compile và javac Java 21 cho toàn bộ source thay đổi. Local IDE có lúc ghi đè target/classes bằng error bytecode, nên smoke cuối dùng thư mục classes riêng; không sửa cấu hình/POM của team.
- PASS: 91 tests hồi quy hiện có, 12 suite TaskWorkflow (controller/access/dates/fields/members/service/store/structure), TaskNotification (worker/inbox), CampaignClosure (controller/service); không chạy Atlas inventory hoặc integration test dùng cấu hình chia sẻ.
- PASS: 187 kiểm tra smoke, Mongo 7 replica set `approval-api-test` trong container riêng, localhost-only random port, tmpfs không có volume demo. Không nạp Spring application/config/seeder; SQL access/members/Campaign và inbox dùng mock.
- Smoke bao phủ submit một/hai bước, active reviewers thiếu, reject trống/quá dài, resubmit tăng lượt đúng lúc, withdraw không tạo REJECT giả, khóa terminal/legacy/type/caption/link, replay/stale revision/lượt/Post version, hai Client tranh quyết định, withdraw↔approve và cancel↔approve. Rollback outbox failure và duplicate decision không để lại Task/Post/history/thông báo nửa chừng.
- History: cursor page-size 1 trên BSON `_id` trộn ObjectId/String cùng timestamp, không trùng hoặc mất dòng; invalid cursor/limit bị từ chối. Broken cross-Workspace Post link không lộ postId/version trong read response.
- Worker: Manager request → Client requests; chuyển bước/lượt cũ suppress; reject vẫn tới Creator dù đã resubmit, nhưng người mất quyền bị suppress. MockMvc kiểm validation body, step chỉ MANAGER/CLIENT, lỗi dùng ApiResponse và giữ requestId.
- Không thêm/chỉnh test trong src. Harness/classes local dưới target ignored, không phải artifact để commit. Không tính các kiểm tra này là coverage ≥80% hoặc test E2E.
- Chưa kiểm: live SQL ACL/ClientProfile resolution và transaction lock giữa Campaign/Task; Gateway HTTP; inbox SQL mới và fault crash-after-delivery; Editor/save↔submit writer guards/Admin/publisher; UI. Atlas APPLY/reconciliation vẫn pending. Default integration gate vẫn false, không bật trên môi trường chung.

## Kiểm tra core giai đoạn 4 — 2026-10-18

- PASS: 94 tests hồi quy hiện có (91 của giai đoạn 3 + 3 PostServiceImpl), zero failures/errors/skips. Không sửa test dưới src, không chạy test cấu hình Atlas hoặc Admin DB dùng chung.
- PASS: tổng 231 kiểm tra smoke backend (187 giai đoạn 3 + 44 Task–Post), classes javac 21 riêng, Mongo 7 replica set `approval-api-test` localhost/tmpfs. GET không tạo bài; create/save đúng link/assignee/scope; version+revision tăng, round không đổi; unknown teammate field giữ nguyên; giữ S3 key; tạo hai tab chỉ một Post; save↔submit có một kết quả hợp lệ; terminal/review/legacy old APIs fail closed.
- PASS: Admin DRAFT không tự tạo Task decision, vẫn withdraw trước Manager/reject tại Client; approve/edit tiếp bị chặn. Durable handoff commit cùng submit, hook lỗi được retry, stale content_version suppress; Admin service và SQL ACL/inbox dùng mock, không gọi đây là kiểm thử Admin PostgreSQL thật.
- PASS: 48 tests offline và 84 assertions rehearsal schema mới. Foundation/init/checker bao gồm TASK_POST_SUBMITTED + optional postId/postContentVersion, không tạo collection mới. Tests nhận BSON version hợp lệ, chặn version 0/postId rỗng và kiểm drift hai field mới; fresh↔upgrade/rerun parity vẫn Pass.
- PASS: Playwright CLI trong session riêng với toàn bộ /api/v1/** mocked; Task mới caption/hashtag/media trống; autosave/manual save giữ cùng post-fixture-1; cố ý trả 409 giữ text và dirty, có alert + app Dialog, giữ bản đang nhập; retry save và submit một lần giữ URL Task/editor, Tiptap contenteditable=false/aria-readonly=true; không có nút Publish trong Task branch. Console chỉ có 409 fixture được cố ý tạo, không runtime exception.
- PASS: xem ảnh 375/768/1440px và light/dark; phát hiện banner clip toolbar ở 768px và chuyển riêng Task actions xuống hàng đủ rộng, không sửa PageWrapper/chung hoặc layout bài độc lập. vi/en của phần mới đổi đúng, S3 helper không biến key thành URL ký. Không công bố accessibility audit toàn Editor; text/preview minh họa cũ của module khác chưa được viết lại.
- PASS: ESLint tất cả file frontend thay đổi, Vite production bundle. Type-check toàn Web vẫn FAIL với 12 lỗi ở bốn file không đổi: content-writing/hooks/useTaskContentSync.ts (unused prepareTaskSocket, missing useAuthStore), editor/components/MediaDropzone.tsx (unused isUploading), workspace/dashboard.tsx (unused imports, missing PageWrapper title, legacy TaskStatus map), routes/AppRoutes.tsx (unused imports). Không sửa các phần này; không coi `vite build` là `npm run build` Pass.
- PENDING tích hợp với thành viên phụ trách: PostPublishServiceImpl đang save whole document; có thể overwrite content/version khi race. Người dùng chốt ngày 2026-10-18 giữ nguyên publish và chờ chủ module, nên không sửa publish queue/callback/API hoặc thêm guard hẹp. SQL/Admin/inbox/Gateway E2E, Atlas APPLY và hai active review legacy vẫn chưa xử lý; feature gate vẫn false, chưa commit/push.
- Kiểm tra bàn giao tiếp theo cùng ngày: 48 offline tests và javac 21 chạy lại Pass. Không tính lượt thử smoke/rehearsal tiếp theo là Pass: hai container kiểm thử đã dừng nên Mongo localhost từ chối kết nối; các kết quả 231/84 phía trên thuộc lượt chạy trước đã hoàn tất, không phải lượt này. Đã dọn đúng hai container tạm sau khi xác minh tên/nhãn và không có volume; không sửa dữ liệu demo/Atlas.

## Kiểm tra UI giai đoạn 5 — 2026-10-18

- PASS: 71 kiểm tra offline cho so khớp Post ID/version/Task revision, quyền action, payload expected theo action, URL không an toàn và key-parallel của 81 keys tasks.review vi/en. Harness chỉ ở output/playwright ignored, không thêm test dưới src.
- PASS: 25 kiểm tra flow bằng Playwright CLI trên Vite riêng cổng 3012; toàn bộ /api/v1/** được route sang fixture, không gọi backend thật. Lý do rỗng không gửi API, focus vào lỗi; 409 giữ lý do, khóa thử lại, reload hiển thị nội dung mới nhưng không replay; người dùng xác nhận lại dùng revision/version mới. Gửi lại tăng lượt, thu hồi chỉ lúc Manager, hai lần click cùng tick chỉ một quyết định Manager, Client kết thúc Task, không gọi publish.
- PASS: lịch sử nhóm lượt, load cursor cũ và QC legacy chỉ có nhãn lịch sử; decision note khác comment. Caption chứa script hiển thị text, không thực thi; javascript URL không render thành link/ảnh. Mismatch không mở nút quyết định; gate tắt không có action; EVENT_PLAN không gọi Post adapter hoặc hiện hướng dẫn soạn bài sai ngữ cảnh.
- PASS: 5 kiểm tra browser lỗi tải review/history và phục hồi. Cache dữ liệu cũ vẫn không cho quyết định khi refetch lỗi. Bình luận đang viết còn nguyên sau mutation, reload review/history và lỗi tải, không unmount composer. Refresh workflow toàn phần vẫn dùng app discard guard hiện có; không mở native confirm/prompt trong luồng duyệt.
- PASS: screenshot và kiểm DOM ở 375/768/1440px, không tràn ngang popup; xem thực tế ảnh sáng/tối. Dialog vi/en giữ note; Escape → tiếp tục viết giữ note, bỏ note là thao tác rõ ràng. Error role=alert/focus, textarea label/describedby, giảm chuyển động cục bộ; không tuyên bố đã audit toàn app/screen-reader/contrast bằng thiết bị thật. Đã sửa nesting Spinner div trong p phát hiện ở lần browser đầu; lượt sạch sau sửa chỉ có lỗi 409/503 fixtures cố ý tạo, không runtime exception.
- PASS: ESLint các file mới/đổi và Vite production bundle. Type-check toàn Web vẫn đúng 12 lỗi baseline ở bốn file ngoài scope đã liệt kê tại giai đoạn 4; không phát sinh lỗi ở phần Approval. Không gọi npm build Pass khi type-check chưa đạt.
- Không có thay đổi backend/schema ở giai đoạn 5; notification dùng outbox/inbox/actionUrl đã có, không sửa chuông thông báo hoặc thêm polling/email. SQL/inbox/Gateway thật, actor membership thật, response mất sau commit, full media delivery và rollout vẫn chờ giai đoạn 6/phối hợp publisher. Atlas không APPLY, feature gate vẫn false, chưa commit/push/Jira Done.

## Kiểm tra lại khi yêu cầu APPLY Atlas — 2026-10-18

Người dùng xác nhận tất cả writer đã dừng. DRY_RUN Atlas mới **blocked bởi 5 active review chưa xác minh** (28 Task/44 Post), chưa ghi schema/document. Không bỏ guard hoặc reset/xóa dữ liệu cũ. [Danh sách, phạm vi schema và kết quả kiểm tra lại](../../../database/task-approval-preflight-2026-10-18.md).

Đã chạy lại Pass: 48 tests migration, 231 backend checks trên Mongo transaction riêng, 71 guard/locale, 30 UI checks fixtures và visual/locale/Escape. Chưa phải kiểm thử sau APPLY hoặc SQL/inbox/Gateway E2E. Đã dọn 36 file UI/CLI tạm + 51 class tạm, giữ tests migration/harness cần hồi quy; không thêm test vào src hoặc xóa test của team. Giữ gate false; dừng APPLY chờ quyết định xử lý legacy.

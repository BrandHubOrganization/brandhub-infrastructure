# Roadmap đề xuất — Task Detail, Assignment và Comments

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

Ngày: 2026-10-14. Jira: DA-978 / DA-E51-04 (FR 3.6.1, 3.6.2), DA-1236 / DA-E51-04b (FR 3.6.3).

**Cập nhật 2026-10-15:** đã khôi phục bản lưu giai đoạn 1, tiếp tục code đọc Task Detail, xác định chi tiết, giao/giao lại và Bắt đầu lần đầu (giai đoạn 2/3). Comments vẫn chưa triển khai. Review phối hợp Approval và nghiệm thu Atlas còn riêng; không tự đánh dấu Jira Done. Xem [bàn giao đợt 2/3](task-workflow-phase-2-3.md).
Tài liệu này giữ lộ trình và các điểm cần quyết định. Sau khi chốt BA mới lần lượt cập nhật
spec → plan → task → test cho từng FR, theo team guide; không sửa spec để hợp thức hóa code.
Không làm tài liệu report trong phạm vi yêu cầu của người dùng.

## 1. Nguồn tham chiếu và baseline

- [Team guide](../../team_guide.md), [workflow](../../rule/feature-workflow.md), [commit convention](../../rule/git-commit-convention.md).
- [FR 3.6.1](3-6-1-identify-task-detail/spec.md), [FR 3.6.2](3-6-2-assign-task-to-creator/spec.md), [FR 3.6.3](3-6-3-add-comments-on-task/spec.md).
- [BA Task](../../ba/05-content-task-workflow.md), [Use Cases UC-42/43/44](../../ba/use-cases/04-content-task-workflow.md), [state machines](../../ba/12-state-machines.md).
- [Master plan](../../plan/brandhub-master-plan.md), [Campaign closure](../media-package-campaign/campaign-closure/spec.md).
- CSV FR gốc tại root infrastructure xác nhận cả ba FR do Lộc thực hiện; tên file có hai khoảng trắng trước dấu `-`.

Baseline sau cập nhật origin/develop: Business `ecfdd84`, Web `b63b3a9`, Gateway `0364426`.
Business/Web đang ở `feature/DA-951-content-requests`; Gateway ở `develop`.
Không code trực tiếp trên develop. Nếu cần sửa Gateway, tạo nhánh feature trước.
Trước implementation cần thống nhất nhánh Task riêng hoặc tiếp tục nhánh feature hiện có;
không tự chuyển/rebase lịch sử các commit chưa push.

Đã có TaskDocument Mongo và các field chung; Campaign/Request tạo Task BACKLOG.
TaskServiceImpl đã đọc/ghi Mongo; entity Task PostgreSQL là legacy, không quay lại dùng làm workflow.
TaskController hiện phục vụ editor, chưa có detail/assign/comments; response còn tối giản.
Ba FR đã có spec/plan/task/test trong giai đoạn 1. Calendar vẫn dùng mock và thuộc phạm vi E51-05.
Compile Business/Gateway và type-check Web đạt sau merge; không phải bằng chứng các FR này đã triển khai.

## 2. Quyết định người dùng đã xác nhận — 2026-10-14

| ID | Nội dung | Quyết định đã xác nhận |
|---|---|---|
| Q1 | Hai thời điểm | Tách hạn hoàn thành mọi Task và ngày đăng dự kiến POST; không tự schedule/publish. |
| Q2 | Sửa/giao lại | Cho đến trước khi Creator bắt đầu; sau khi bắt đầu hoặc đang duyệt chưa mở sửa/giao lại. Reject về ASSIGNED không được vô tình mở khóa. |
| Q3 | Phạm vi chi tiết | Chỉ khung yêu cầu/mô tả, deadline và đầu vào/tham khảo cho 5 loại; không làm thay editor/script/form chuyên biệt. |
| Q4 | Comment trên Task terminal | Vẫn cho bình luận mới trên COMPLETED/CANCELLED nếu còn quyền xem Task/Workspace; không mở lại trạng thái công việc. |
| Q5 | Mention và ảnh | Triển khai đầy đủ: mention, ảnh/link; JPEG/PNG/WebP, tối đa 5 ảnh mỗi comment, mỗi ảnh 5 MB. |
| Q6 | Quyền Client (quyết định cũ) | Phần ẩn Task nội bộ đã được Q13 thay thế: Client xem/bình luận mọi Task cùng WS. |
| Q7 | Resubmit sau reject | Duyệt lại từ QC nếu có; nếu không có QC, bắt đầu từ Manager. Lịch sử approval cũ giữ nguyên nhưng không thay thế duyệt cho nội dung mới. |
| Q9 | Phạm vi hiển thị (quyết định cũ) | Đã được Q13 thay thế; không còn field/bộ chọn phân biệt nội bộ/thường hoặc default theo nguồn. |
| Q10 | Giới hạn ngày | Task Campaign: dueDate trong max(today,start)..end; ngày đăng POST không trước dueDate và cũng trong Campaign. Task thủ công không Campaign: hạn từ hôm nay. Dùng ngày theo múi giờ Workspace. |
| Q11 | Notification comment | In-app cho người được mention, assignee, QC, Manager Workspace; loại trùng/tác giả/người mất quyền Task. Client chỉ nhận khi được mention. |

### Q8 đã xác nhận trong giai đoạn 1 — 2026-10-14

| ID | Câu hỏi | Quyết định đã xác nhận |
|---|---|---|
| Q8 | Trigger bắt đầu lần đầu? | Creator bấm Bắt đầu làm, ASSIGNED → IN_PROGRESS, lưu dấu mốc lần đầu; không tính mở trang/editor là bắt đầu. Reject không xóa dấu mốc. |

Phải phối hợp contract “đã bắt đầu” với chủ E51-03, không chỉ kiểm tra ASSIGNED vì reject cũng quay về ASSIGNED. BA trigger đã chốt; chưa tuyên bố chủ module đã review tích hợp.
Q10 giới hạn ngày giữ nguyên. Q13 thay phần phân quyền Q6/Q9: Client active đọc/bình luận mọi Task cùng WS, kể cả manual và legacy; thiếu start/revision chỉ chặn mutation quản lý cần review.
Điều kiện tạo Task thủ công và hợp đồng tích hợp editor vẫn cần phối hợp; không sửa auto-create của editor trong đợt planning.
Q7 đã được ghi vào spec/master plan để gỡ mâu thuẫn tài liệu; người dùng/lead cần thông báo chủ Approval trước implementation, không tự sửa code của thành viên đó.

### Q13 — đơn giản hóa Task, confirmed 2026-10-14 (thay Q6/Q9 về hiển thị và Q12)

Client active được xem/bình luận **mọi Task trong Workspace**, kể cả Task Manager tạo thủ công
và Task cũ. Không chia nội bộ/thường; bỏ visibility, bộ chọn/default/index tương ứng và lỗi Q12.
Q12 chỉ là quyết định lịch sử, không còn áp dụng sau khi bỏ phân biệt này.
requiresClientApproval chỉ quyết định có bước Client duyệt kết quả; không ảnh hưởng quyền xem/bình luận.
Vẫn kiểm membership/scope, giữ quyền mutation/editor theo vai trò, ảnh DRAFT chỉ chủ upload preview.
Không tự sửa/xóa dữ liệu DB; start/revision legacy vẫn cần review trước sửa/giao lại.
Notification Q11 không thay đổi: Client chỉ nhận khi được mention, không tự nhận mọi bình luận.

## 3. Năm giai đoạn triển khai dự kiến

### Giai đoạn 1 — chốt BA và hợp đồng tích hợp

1. Áp BA mới nhất Q13; ghi rõ hợp đồng còn chờ thành viên khác review.
2. Chuẩn hóa tên role CREATOR thay MEMBER ở spec giao việc; thực thi quyền theo membership thật.
3. Đã bổ sung DA-E51-04b / DA-1236 vào bảng và phần chi tiết master plan; không tạo task Jira trùng.
4. Cập nhật spec từng FR, sau đó mới viết plan/task/test tương ứng.
5. Chốt Task type: POST, LIVESTREAM, SURVEY, EVENT_PLAN, PRESS_RECOMMENDATION;
   không làm module vận hành sự kiện/booking/báo điện tử.
6. Chốt contract với E51-03 (Approval — Phước), E51-05 (Views — Phước), chủ editor và
   Livestream/Survey: identity, status, version, quyền đọc/ghi và metadata riêng.

**Checkpoint:** đủ 4 file mỗi FR, BA schema/quyền/lifecycle đã chốt; review tích hợp được ghi riêng.
Không tự sửa editor/approval hoặc mở Client vào endpoint content để giải quyết quyền đọc Task.

### Giai đoạn 2 — nền đọc Task và màn hình chi tiết

Business dự kiến có TaskWorkflowController/Service/Store/Access và DTO riêng, dùng Mongo Task hiện có.
Không phá contract TaskResponse tối giản mà editor đang dùng.

- Đề xuất endpoint đọc workflow riêng `GET /api/v1/workspaces/{id}/tasks/{taskId}/workflow`.
- Cung cấp điểm vào backlog tối thiểu cho Manager, phân trang ổn định; thống nhất với E51-05 trước
  khi chọn dùng list chung hay endpoint backlog riêng. Không xây lại Calendar/Gantt/Kanban/filter đầy đủ.
- Đọc member options từ membership hiện có; assigneeId/qcAssigneeId là User ID, không nhầm WorkspaceMember ID.
- Task Detail `/workspaces/:id/tasks/:taskId/detail`: thông tin nguồn Campaign/Request, trạng thái,
  brief, người phụ trách; bình luận và hành động được bổ sung ở giai đoạn sau.
- Campaign/Request đặt link đến Task Detail, giữ link editor hiện có cho người có quyền.
- Manager mới có thao tác quản lý; Owner khi là Manager của WS áp dụng role Manager thực tế.
- Client active đọc metadata/bình luận mọi Task cùng WS theo Q13, không có quyền sửa content/editor.

**Checkpoint:** vào được Task từ Campaign/Request/manual, Client đọc mọi Task cùng WS nhưng không lộ dữ liệu Workspace khác,
không làm mất chức năng editor và không giả dữ liệu mock thành Task thật.

### Giai đoạn 3 — xác định chi tiết và giao việc (DA-978)

- `PATCH .../tasks/{taskId}/detail`: validate field theo spec final, BACKLOG → DETAIL_IDENTIFIED.
- `POST .../tasks/{taskId}/assign`: Creator bắt buộc, QC tùy chọn và khác Creator,
  requiresClientApproval; DETAIL_IDENTIFIED → ASSIGNED.
- Creator/QC phải active, đúng role và đúng Workspace. Manager không được gửi arbitrary userId.
- Lưu thông tin diễn viên/thời điểm và revision; contract sửa/giao lại theo Q2, không ngầm reset approval.
- Trả capabilities/allowed actions cho UI; backend luôn tự kiểm tra lại quyền và trạng thái.
- Form có min/max ngày theo Q10 đã xác nhận, kiểm tra thứ tự hai thời điểm; inline errors và error summary focus được, không tự clamp dữ liệu.
- Notification giao việc phải bền vững/idempotent, không mất hoặc nhân đôi khi retry.

**Checkpoint:** Manager xác định/giao Task thật; đúng Creator thấy việc và nhận notification;
double-submit/concurrent change không ghi đè; Task terminal không bị mở lại.

### Giai đoạn 4 — bình luận theo Task (DA-1236)

- Tạo collection riêng task_comments và GET/POST `.../tasks/{taskId}/comments`.
- Đề xuất field: id, workspaceId, taskId, authorId, role/display-name snapshot, content,
  mentions, attachment references, createdAt, clientRequestId để retry không tạo trùng.
- Timeline phân trang/cursor ổn định theo createdAt + id, có tên/role/thời gian.
- Membership và quyền Task được kiểm tra cho đọc, gửi, mention và xem ảnh; áp Q4/Q13.
- Nội dung là plain text; link an toàn; không render HTML tùy ý. Không làm edit/delete comment theo spec.
- Q5 đã chọn đầy đủ: upload/reference ảnh có ownership, kiểm tra MIME thực, tối đa 5 ảnh × 5 MB,
  truy cập riêng; không nhận arbitrary URL hoặc dùng endpoint Mail Attachment làm storage chung.
  Có cơ chế cleanup upload chưa gắn comment; không tự biến ảnh comment thành tài nguyên Library của thành viên khác.
- Notification comment/mention theo Q11 đã chốt, kiểm tra quyền ở thời điểm gửi. Realtime là tùy chọn kỹ thuật sau khi chốt
  yêu cầu; không coi Chat Workspace là nơi lưu Task comments và không bắt buộc sửa Chat.

**Checkpoint:** ba role hợp lệ trao đổi trên đúng Task, phân trang/retry không mất/trùng comment;
Client đọc/bình luận được cả Task thủ công; notification/ảnh không vượt quyền Workspace, DRAFT upload vẫn riêng tư.

### Giai đoạn 5 — kiểm thử hồi quy, migration và bàn giao

- Unit/API: quyền, state guards, validation, revision conflict, Creator/QC, nguồn Task, Workspace scope.
- Integration Mongo cô lập: migration DRY_RUN/APPLY/repeat, targeted updates, transaction,
  comment idempotency và notification retry. PostgreSQL inbox kiểm thử cô lập khi cần.
- Race tests: detail/assign với cancellation; Assignment/Comment với membership removal;
  không hồi sinh CANCELLED, không cho sửa/giao lại công việc thuộc Campaign completed;
  bình luận mới trên Task terminal vẫn được phép theo Q4, không đổi trạng thái Task/Campaign.
- Regression Campaign planned/supplemental groups và completion preflight; editor Yjs/history;
  hệ thống notification/mail mới merge không bị thay đổi contract.
- Playwright mock UI, sau đó test account hiện có có xác nhận; vi/en, light/dark,
  keyboard, responsive 375/768/1440 và lỗi mạng.
- Update test evidence và hướng dẫn setup; không seed user mới, không tự chạy migration lên Atlas/shared DB.
- Commit tách DA-978 và DA-1236 sau khi người dùng yêu cầu; chưa tự push/đóng Jira.

**Checkpoint:** test happy/error/concurrency pass, không chỉ compile; BA và thành viên liên quan review contract.

## 4. Định hướng kỹ thuật cần giữ

- Task metadata và comments ở Mongo; giữ ID Task và các field source/campaign/work item.
  Không replace toàn document bằng DTO làm mất approvalRound/cancellation/typeMetadata ngoài scope.
- Bổ sung revision cho workflow để chống ghi đè; migration phải xử lý document chưa có revision
  một cách tường minh. CAS kiểm tra cả revision và status; không dùng timestamp đơn độc làm version.
- Mọi writer trạng thái phải giữ updatedAt và tôn trọng CANCELLED. Phối hợp writer của E51-03;
  không tự đổi approvalRound hoặc xóa task_approvals khi sửa yêu cầu/giao việc.
- Task gắn Campaign: phối hợp cùng SQL agreement lock mà completion đang dùng để serialize thao tác
  với closure; Task mới thủ công có campaignId=null cần policy riêng theo spec final.
- Ghi Task/comment và sự kiện notification trong cùng Mongo transaction/outbox; worker đưa vào inbox
  PostgreSQL với ID delivery ổn định, ON CONFLICT chống trùng, recheck recipient access. Không coi
  PostgreSQL + Mongo là một ACID transaction. Tách notification domain Task để không phá Mail/Admin.
- Dự kiến migration Mongo additive: workflow revision/audit, task_comments,
  notification outbox và indexes; thêm field ngày đăng dự kiến POST theo Q1 đã chốt.
  Quyền đọc/bình luận theo Q13, deadline/notification theo Q10/Q11; firstStartedAt/By theo Q8, không suy legacy thiếu marker là chưa bắt đầu.
- Tạo migration mới, giữ validator/index cũ, DRY_RUN mặc định; sync init-mongo và checker/tests.
  Nếu phát sinh SQL schema thì phải có migration + init-postgres tương ứng; không mặc định cần SQL mới.
- Gateway hiện route `/api/v1/**`; dự kiến không cần code mới. Chỉ thay nếu route/auth thực tế thiếu,
  không dùng thay đổi global auth để lách membership của Task.

## 5. UI dự kiến và phạm vi file

Tái sử dụng layout và component của Web. Desktop chia thông tin/chi tiết và bình luận bên cạnh;
mobile xếp dọc, không nhét toàn bộ workflow vào một modal. Skill UI dùng hướng dẫn error summary
focus được + lỗi cạnh field, loading/disabled/success rõ; không đổi theme/UI toàn hệ thống.

- Web: module feature `src/pages/tasks/` (components/hooks/services/types), route và link Campaign/Request;
  locale `tasks.json` vi/en song song; không sửa CanvasTextEditor, Mail, Calendar hay Approval UI ngoài contract phối hợp.
- Business: controller/service/store/access/DTO cho workflow và comments; notification adapter/outbox riêng;
  chỉ thêm field TaskDocument đã chốt; không thay PostgreSQL legacy Task hoặc editor content tables.
- Infrastructure: 4 tài liệu từng FR, master-plan mapping, migration/init/checker, setup/test instructions.

## 6. Nhóm commit dự kiến

- `docs(DA-978)(DA-1236): confirm task workflow requirements and implementation plan`
- `feat(DA-978): add scoped task detail and assignment workflow` (BE)
- `feat(DA-978): add task detail and assignment interface` (Web)
- `feat(DA-1236): implement scoped task comments and notifications` (BE)
- `feat(DA-1236): add task comment timeline and composer` (Web)
- `docs(DA-978)(DA-1236): add task workflow migrations and setup guide` (Infra)
- Test-only/refactor commits dùng đúng task liên quan; không gắn DA-975/976 chỉ vì dùng lại collection đã có.

Mỗi giai đoạn có checkpoint trước khi đi tiếp. Đây không phải lịch ngày cố định;
không ước lượng thời gian triển khai khi chưa chốt scope và dependencies với các thành viên khác.

## 7. Kế hoạch thực thi theo đầu ra — cập nhật sau Q13

Đây là phân rã để review, không thay thế plan/task/test final của từng FR.
Q8 đã chốt trigger bấm Bắt đầu làm. Contract kỹ thuật và evidence giai đoạn 1 xem
[task-workflow-contract.md](task-workflow-contract.md) và [task-workflow-phase-1.md](task-workflow-phase-1.md).
Chưa triển khai ứng dụng; schema foundation không tự bật quyền/lifecycle mới.

| Đợt | Đầu ra dự kiến | Điều kiện nghiệm thu / điểm chờ | Jira |
|---|---|---|---|
| 1 | Spec/plan/task/test; ma trận quyền; inventory schema và writer Task; migration nền | BA Q13 mới nhất; không sửa dữ liệu cũ; review tích hợp trước code ứng dụng | DA-978, DA-1236 |
| 2 | API đọc workflow, backlog tối thiểu và trang Task Detail theo Workspace membership | Client xem mọi Task cùng WS qua API/link/ảnh ATTACHED; không lộ WS khác; không phá editor | DA-978 |
| 3 | Detail/Assign/reassign/start, deadline + plannedPublishAt, notification giao việc | Kiểm tra role, Creator/QC, revision và first-start guard; phối hợp Approval trước nghiệm thu | DA-978 |
| 4 | Comments API, upload riêng, mention, timeline UI, notification bền vững | Terminal vẫn comment; ảnh 5 × 5 MB đúng định dạng; retry không trùng; recipient có quyền | DA-1236 |
| 5 | Regression, migration parity, setup và demo | Không rò rỉ dữ liệu sang WS khác; không hồi sinh Task hủy; editor/Approval/Campaign không hồi quy | DA-978, DA-1236 |

### Đợt 1 — chốt thiết kế trước code

- [x] Ghi Q8 thành quyết định, không dùng mở editor làm trigger.
- [x] Hoàn thiện spec phần đã xác nhận, rồi plan → task → test.
- [x] Inventory read-only: validator/index hiện có, Task legacy thiếu source/revision/start,
  writer từ Campaign, Request, editor/manual và cancellation; không tự backfill lịch sử start hoặc sửa dữ liệu.
- [ ] Chốt với chủ E51-05 điểm vào backlog và hợp đồng list; chỉ list tối thiểu phục vụ ba FR này.
- [ ] Đối chiếu chủ E51-03/editor về lifecycle và việc giữ Task ID; không sửa submit/approval/content APIs.
- [x] Thiết kế migration additive + fresh init/checker/tests; riêng Mongo cho Task/comments/outbox,
  chỉ thêm SQL nếu schema inbox thực sự cần, không mặc định tạo thêm bảng PostgreSQL.

### Đợt 2 — nền Task Detail và quyền

- [ ] Tạo lớp TaskWorkflowAccess với quyền Workspace thực tế; Owner chỉ quản lý khi là Manager tại WS.
- [ ] Trả workflow DTO riêng: dữ liệu chung, nguồn, dueDate, plannedPublishAt,
  assignee/QC, requiresClientApproval, revision và allowedActions; không thay TaskResponse editor.
- [ ] Mọi Task manual/Campaign/Request/legacy cho Client active cùng WS đọc/bình luận theo Q13.
  Với auto-create của editor chỉ phối hợp metadata nguồn/revision/start, không đổi UI/quyền edit của thành viên khác.
- [ ] Legacy thiếu revision/start cần review trước mutation quản lý; không dùng marker thiếu để chặn đọc/bình luận.
  Không có field/default/bộ chọn phân biệt nội bộ/thường.
- [ ] Web tách module tasks, nối link từ Campaign/Request; giữ link editor theo quyền hiện có.
- [ ] API Gateway giữ route hiện có nếu đủ; không chỉnh global auth để giải quyết quyền Task.

### Đợt 3 — xác định chi tiết, giao việc và khóa sửa

- [ ] Lưu brief/đầu vào/tham khảo, deadline, thời điểm đăng dự kiến POST; targeted update,
  không ghi đè typeMetadata chuyên biệt, nguồn Task, audit hủy hoặc kế hoạch/sản lượng Campaign.
- [ ] Thực thi BACKLOG → DETAIL_IDENTIFIED → ASSIGNED; chỉnh trước bắt đầu giữ trạng thái hiện có.
- [ ] Validate Creator và QC active cùng WS, hai người khác nhau, cờ Client duyệt chỉ cấu hình duyệt kết quả, không chặn quyền xem/bình luận.
- [ ] Deadline picker/API cùng quy tắc Q10 theo timezone Workspace; đổi deadline phải kiểm tra lại
  plannedPublishAt, không tự sửa một thời điểm để làm payload có vẻ hợp lệ.
- [ ] CAS revision + status; Task gắn Campaign phối hợp lock với completion/cancellation.
- [ ] Áp Q8 confirmed: start khi bấm, reject về ASSIGNED không được coi là “chưa từng bắt đầu”.
  Không triển khai logic Approval mới thay chủ E51-03; cần review contract trước tích hợp.
- [ ] Thông báo giao việc có idempotency và cơ chế retry; UI giữ input và báo conflict, không tự retry mutation cũ.

### Đợt 4 — bình luận, ảnh và thông báo

- [ ] Tạo task_comments với source Task/Workspace, author snapshot, timestamp, mentions,
  attachmentIds và clientRequestId; unique index chống gửi trùng, cursor theo createdAt/id.
- [ ] API đọc/gửi comment, upload/download ảnh có auth và quyền Task; kiểm tra MIME thực,
  số lượng/kích thước, quyền sở hữu upload và trạng thái gắn file. Có cleanup upload bỏ dở.
- [ ] Task COMPLETED/CANCELLED vẫn bình luận; chỉ comment không sửa status/approvalRound/Campaign.
- [ ] Mentions và notification dùng User ID, resolve ClientProfile theo membership thực tế.
- [ ] Outbox cùng Mongo transaction với comment; worker idempotent đưa vào inbox hiện có,
  recheck access trước delivery, không gửi email và không rò rỉ nội dung sang người ngoài/đã rời Workspace qua title/URL.
- [ ] Timeline phân trang và composer hỗ trợ giữ draft, preview ảnh, lỗi cạnh field/error summary,
  bàn phím mention, vi/en và semantic light/dark. Không đổi Chat/Mail/Material Library.

### Đợt 5 — tiêu chí demo và bàn giao

- [ ] Demo Manager: mở Task Campaign/Request → xác định chi tiết → giao Creator/QC → thông báo.
- [ ] Demo Q13: Client xem/bình luận Task thủ công, Campaign, Request và legacy cùng WS,
  kể cả requiresClientApproval=false; direct URL sang WS khác hoặc sau rời WS bị chặn.
- [ ] Demo Creator/Client/Manager comment + mention + ảnh, cả sau COMPLETED/CANCELLED.
- [ ] Test stale revision, double submit, đổi quyền, MIME giả/ảnh quá lớn, cursor cùng timestamp,
  retry worker, schema thiếu, Task cancelled đồng thời với assign và timezone day rollover.
- [ ] Kiểm tra UI keyboard/error feedback theo ui-ux-pro-max; Playwright mock light/dark,
  vi/en/mobile trước test bằng account hiện có, không seed account mới.
- [ ] Migration DRY_RUN/APPLY/repeat trên DB cô lập; so init/checker với tổng migrations.
  Hướng dẫn operator backup/chạy migration trên DB đang dùng, không rerun init.
- [ ] Chỉ đóng phần Task có start/reassign khi integration test với E51-03 đạt; không coi compile/typecheck là Done.
- [ ] Commit theo DA-978 và DA-1236 khi được yêu cầu; docs dùng tag docs. Không tự push hoặc đổi Jira.

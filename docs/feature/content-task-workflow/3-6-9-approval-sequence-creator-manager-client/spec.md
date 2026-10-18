# FR 3.6.9 — Phê duyệt công việc

| Thuộc tính | Giá trị |
|---|---|
| FR / Use case / Task | 3.6.9 / UC-47 / DA-E51-03; chưa xác minh mã Jira số |
| Vai trò | Creator được giao, Manager thực tế của Workspace, Client đang hoạt động |
| Phiên bản | 3.0 — BA được người dùng xác nhận ngày 2026-10-18 |
| Tiến độ | Giai đoạn 1–3, core Task–Post/Editor giai đoạn 4 và UI duyệt giai đoạn 5 đã có code/kiểm thử cô lập; mutation mặc định tắt. Còn checkpoint publisher, SQL/inbox/Gateway end-to-end và rollout giai đoạn 6; Atlas APPLY chưa thực hiện |
| Phụ trách | Lộc tiếp nhận FR 3.6.9 theo yêu cầu người dùng; chưa tuyên bố Jira đã đổi assignee |

Thay thế quy tắc QC, trạng thái trung gian và skip approval cũ của FR 3.6.9. Quyết định 2026-10-18: dùng `/editor` trước; một bản nội dung hiện tại, không snapshot; thu hồi trước quyết định Manager; một Client bất kỳ quyết định; thiếu Client thì chặn gửi duyệt. [Kế hoạch](plan.md), [checklist](task.md), [kiểm thử](test.md).

## 1. Objective

Cho Creator gửi kết quả tới Manager và Client khi cần, theo dõi quyết định từng lượt mà không trộn với bình luận Task hoặc thao tác xuất bản.

## 2. User story và phạm vi

- Creator được giao gửi bài POST từ `/editor`, thu hồi đúng thời điểm và sửa lại sau từ chối.
- Manager xem bài được liên kết, duyệt hoặc từ chối có lý do.
- Client quyết định ở bước của khách hàng và xem lịch sử duyệt.
- Khung workflow dùng chung cho năm loại Task; đợt này chỉ nối nội dung POST. Chưa có adapter nội dung thì không gửi/duyệt giả các loại khác.

## 3. Acceptance criteria

### Quyền, nội dung và lượt duyệt

- **AC-01 — Scope:** xác minh User/membership đang hoạt động, đúng Workspace/Task. Owner Agency không tự có quyền Manager. Chỉ assignee Creator được submit/withdraw; Manager/Client đúng bước mới approve/reject. Client vẫn xem/bình luận mọi Task trong Workspace theo FR 3.6.3.
- **AC-02 — Một bài:** Task POST liên kết tối đa một Post cùng Workspace; Post độc lập không bắt buộc có Task. Chưa có bài thì chưa submit. Mở lại phải mở đúng bài đã lưu, không tạo bản mới do bài bị khóa/lỗi API. Mô tả yêu cầu Task không phải kết quả nội dung đã viết.
- **AC-03 — Một bản hiện tại:** không thêm snapshot, kho phiên bản Approval, `reviewSnapshotId` hay `reviewContentVersion`. Khi Task `IN_REVIEW`, khóa sửa caption/hashtag/media/kênh của bài liên kết ở backend và UI; không chỉ dựa vào `posts.status`. Giữ `content_version` hiện có phục vụ Admin moderation/concurrency, không xây kho phiên bản mới.
- **AC-04 — Giới hạn lịch sử:** sau reject/withdraw hợp lệ, sửa chính bài hiện tại. Lịch sử chỉ giữ người quyết định, bước, lượt, nhận xét và thời gian; không xem/diff nội dung cũ vì không lưu bản cũ. Không gắn nhãn như thể nội dung hiện tại là nội dung của lượt cũ. Không xóa content history của module khác.
- **AC-05 — Submit:** chỉ từ `IN_PROGRESS`, assignee còn hợp lệ, có bài POST hợp lệ theo validation Editor hiện có (ít nhất caption không trắng). Mở trang không tự start/submit. Không bổ sung quy tắc chặn nộp quá hạn trong FR này. Gửi thành công chuyển `IN_REVIEW/MANAGER`.
- **AC-06 — Lượt:** lượt đầu là 1; mỗi lần gửi lại thành công sau reject/withdraw dùng lượt tiếp theo. Chỉ approve/reject tạo decision trong `task_approvals`, không tạo sẵn dòng cho người chưa duyệt. Một lượt tối đa hai decision: Manager, Client. Không tạo collection round riêng; không kế thừa hiệu lực approval cũ.

### Chuyển bước và ngoại lệ

- **AC-07 — Manager:** approve ở bước MANAGER: không yêu cầu Client thì FINISHED; có yêu cầu thì giữ IN_REVIEW, chuyển bước CLIENT.
- **AC-08 — Client:** một Client bất kỳ còn hoạt động trong Workspace quyết định tại bước CLIENT; không yêu cầu tất cả hoặc chỉ định đại diện. Chỉ decision hợp lệ đầu tiên được ghi nhận. Client approve chuyển FINISHED.
- **AC-09 — Thiếu người duyệt:** yêu cầu Client nhưng chưa có Client có tài khoản hoạt động thì chặn submit, giữ nguyên Task/Post/lượt, báo Manager bổ sung Client. ClientProfile chưa gắn User đăng nhập không đủ điều kiện. Hết Client khi đang chờ Client: giữ nguyên bước, không tự approve/skip; dùng chức năng quản lý thành viên hiện có để bổ sung. Không xây flow mời mới trong FR này.
- **AC-10 — Reject:** Manager/Client đúng bước nhập lý do không trắng; append REJECT, Task về IN_PROGRESS, xóa bước chờ. Creator sửa bài hiện tại, gửi lại từ Manager ở lượt mới. Không sửa/xóa decision cũ.
- **AC-11 — Withdraw:** assignee Creator chỉ thu hồi khi IN_REVIEW/MANAGER và Manager chưa quyết định lượt hiện tại. Task về IN_PROGRESS, xóa bước chờ, mở sửa bài hiện tại. Không tạo REJECT thay người duyệt. Sau Manager approve đang chờ Client thì không thu hồi. Withdraw và Manager decision đồng thời: chỉ một thao tác hợp lệ thắng.
- **AC-12 — Giữ nền Task:** không QC/review chéo; giữ TODO/IN_PROGRESS/IN_REVIEW/FINISHED/CANCELLED. Sau lần bắt đầu đầu tiên Manager không sửa brief/deadline/giao lại, kể cả sau reject/withdraw. Không mở lại FINISHED hoặc chọn trạng thái tùy ý. Giữ field `task_approvals.comment`; UI gọi “Nhận xét duyệt”, khác bình luận Task.
- **AC-13 — Cancel/Campaign:** Task bị hủy hoặc Campaign đã hoàn thành không nhận submit/decision/withdraw. Hủy Task đang duyệt theo flow hiện có phải chặn decision tiếp theo, giữ lịch sử, không mở lại. Giữ điều kiện hoàn thành Campaign: còn Task chưa kết thúc vẫn chặn.
- **AC-14 — Nội dung/publishing:** bước cuối chỉ hoàn thành Task, không enqueue/publish bài thật. Bài đã chốt không được sửa bằng flow draft để làm khác kết quả được duyệt. Admin moderation độc lập, không thay quyết định Manager/Client. Không thay Yjs, AI hoặc publisher; phối hợp các điểm tích hợp có ảnh hưởng module khác trước rollout.
- **AC-15 — Concurrency:** mutation nhận revision/lượt đang xem; request cũ trả conflict, không cập nhật nửa chừng hoặc tạo decision/thông báo trùng. Post đã đổi so với bản đang xem thì không tự duyệt/gửi thay người dùng. Chỉ báo thành công sau commit.
- **AC-16 — Notification:** in-app cho người duyệt bước tiếp theo khi submit/chuyển bước; reject báo assignee Creator. Không email. Recheck quyền/lượt/bước; bỏ trùng và thông báo chờ duyệt lỗi thời. Giữ hành vi notification bình luận/giao việc hiện có.

## 4. State machine

| Trước | Actor / hành động | Sau |
|---|---|---|
| TODO | Assignee Creator / Bắt đầu (FR 3.6.2 hiện có) | IN_PROGRESS |
| IN_PROGRESS | Assignee Creator / Gửi duyệt | IN_REVIEW / MANAGER |
| IN_REVIEW / MANAGER | Manager / Duyệt, không cần Client | FINISHED, reviewStep=null |
| IN_REVIEW / MANAGER | Manager / Duyệt, cần Client | IN_REVIEW / CLIENT |
| IN_REVIEW / CLIENT | Một Client active / Duyệt | FINISHED, reviewStep=null |
| IN_REVIEW / MANAGER hoặc CLIENT | Đúng người duyệt / Từ chối có lý do | IN_PROGRESS, reviewStep=null |
| IN_REVIEW / MANAGER, chưa decision | Assignee Creator / Thu hồi | IN_PROGRESS, reviewStep=null |
| Task chưa kết thúc | Flow hủy được cấp quyền hiện có | CANCELLED; không còn quyền duyệt |

Ngoài IN_REVIEW, writer mới để reviewStep=null. Legacy QC/thiếu bước/lượt chưa xác minh: chỉ đọc và báo cần rà soát, không tự reinterpret/backfill.

## 5. UI/UX và UI states

Giữ popup Task Detail hiện có; thêm phần “Phê duyệt” gồm bước chờ, lượt, bài hiện tại và lịch sử decision. Không thay layout danh sách, Chat hoặc editor khác. Người có quyền đọc Task xem được lịch sử; quyền action lấy từ backend, không suy từ lockReason sửa brief.

- Creator lưu bài thành công rồi submit; chờ Manager có Withdraw, chờ Client chỉ xem.
- Manager/Client xem bài, Approve hoặc Reject; lý do trong Dialog ứng dụng, không window.confirm/prompt/alert.
- Missing Post/thiếu Client/loại chưa hỗ trợ: hiển thị nguyên nhân và cách xử lý, không báo thành công giả.
- Loading/submitting: giữ bố cục, disable thao tác trùng, aria-busy/status phù hợp. Lỗi gần field; conflict giữ lý do đang nhập và tải lại trạng thái, không tự replay mutation cũ.
- Label/focus/keyboard rõ; focus vào lỗi khi gửi thất bại, trả focus khi đóng Dialog; không chỉ dùng màu. Refresh Approval không làm mất bình luận đang viết.
- **AC-17 — i18n/theme:** key song song trong `src/i18n/locales/{vi,en}/tasks.json` và `editor.json` khi đổi text Editor. Dùng token semantic, light/dark, 375/768/1440px; không tạo theme/layout mới.

Keys dự kiến `tasks.review`: title, currentRound, currentStep, steps.manager, steps.client, submit, withdraw, approve, reject, reviewNote, reasonRequired, history, historyNoContentVersions, noHistory, contentUnavailable, missingClient, waitingForClient, pending, success, conflict, unsupportedType, legacyReviewRequired, errors.*. Text Editor dùng editor.review.*; không đưa bài/lý do nhạy cảm vào notification chung.

## 6. API contract đề xuất

Prefix `/api/v1/workspaces/{workspaceId}/tasks/{taskId}`:

| Method / suffix | Mục đích |
|---|---|
| GET /review | Trạng thái, lượt, bước, bài liên kết, allowedActions và lý do chặn |
| POST /submit | Gửi bài hiện tại ở lượt đầu/lượt mới |
| POST /withdraw | Thu hồi trước decision Manager |
| POST /approve | Ghi decision duyệt đúng bước |
| POST /reject | Ghi decision từ chối có lý do |
| GET /approvals | Lịch sử append-only theo lượt |

Giữ ApiResponse; shape/CAS và contract tìm/tạo bài theo Task ở [plan §3](plan.md#3-api-contract-đích). Sáu endpoint review/approvals/submit/withdraw/approve/reject đã có code backend giai đoạn 3; chưa được mở mutation trên môi trường dùng chung. Endpoint tìm/tạo bài theo Task thuộc giai đoạn 4.

## 7. Error handling và edge cases

- 401 mất/hết phiên; 403 sai role/bước/membership; 404 Task/Post ngoài scope.
- 400 validation reason/caption/input; 409 sai trạng thái/revision/lượt, thiếu bài/người duyệt; 503 schema/storage/transaction chưa sẵn sàng. Mã ở plan; không coi lỗi migration là lỗi nhập liệu.
- Hai Client quyết định ngược nhau; withdraw cùng approve; Post save cùng submit; cancel cùng approve: chỉ một kết quả hợp lệ, không approval mồ côi.
- Hết Client giữa lượt không làm mất Manager approval. Manager thay thế: chỉ Manager active hiện tại được quyết định, không gắn cứng người cũ.
- Admin đổi Post status không tự là decision Task; khóa nội dung theo Task vẫn có hiệu lực. Không tự đặt quy tắc Admin BLOCK đổi Task status.
- Chốt bổ sung 18/10: nếu Admin đưa bài về DRAFT trong lúc Task vẫn IN_REVIEW, giữ nguyên lượt/bước. Creator vẫn thu hồi trước quyết định Manager; Manager/Client đúng bước vẫn từ chối có lý do để sửa. Không cho APPROVE khi Post không còn PENDING_APPROVAL; không tự chuyển Admin BLOCK thành Task REJECT.
- Bài gắn Task lưu qua API Task với revision/version bắt buộc. PATCH/submit Post cũ từ chối bài linked và hướng sang API Task; bài độc lập giữ contract cũ. Không fallback tạo bài độc lập để vượt lỗi/khóa.
- External media URL có thể đổi nội dung ngoài hệ thống: chỉ khóa field/quan hệ trong hệ thống; không tuyên bố lưu bất biến byte của tài nguyên bên thứ ba.

## 8. Definition of Done và out of scope

FR chỉ hoàn thành khi API + UI + liên kết POST + khóa sửa + notification + hồi quy được kiểm chứng theo test.md. Giai đoạn 1 chỉ hoàn thành tài liệu; không đánh Done Jira/FR, không APPLY Atlas/init/seed/clean dữ liệu.

Checkpoint giai đoạn 2 (2026-10-18): [migration/setup](../../../database/task-approval-setup.md) đã có, init/checker đồng bộ và test DB cô lập đã chạy. Atlas chỉ kiểm kê đọc, còn hai active review chưa xác minh nên chưa APPLY. Không coi đây là Approval runtime đã hoàn thành.

Rollout giai đoạn 3: API read/history được triển khai độc lập, mutation mặc định khóa bằng cờ kỹ thuật `app.task-approval.post-integration-ready=false`. Chưa nối guard mọi Post writer/hook Admin ở giai đoạn 4 thì không bật cờ trên môi trường dùng chung. Read vẫn trả trạng thái/lịch sử; allowedActions=false với lý do tích hợp chưa sẵn sàng. Đây là khóa rollout an toàn, không phải trạng thái Task hoặc BA mới.

Ngoài phạm vi: snapshot/diff các lượt; role/QC mới; editor/Yjs mới; mở lại FINISHED; nội dung chuyên biệt bốn loại Task còn lại; tự publish/đổi queue/callback; email; thay Admin moderation; backfill legacy chưa duyệt allowlist. Report 3/4 chính thức và thông báo team/Jira là checkpoint bàn giao, không tuyên bố đã làm.

## Tham chiếu BA

[BA Task](../../../ba/05-content-task-workflow.md), [UC-47](../../../ba/use-cases/04-content-task-workflow.md), [state machines](../../../ba/12-state-machines.md), [glossary](../../../ba/11-data-entities-glossary.md), [Task structure](../task-structure-simplification/spec.md), [contract Task](../task-workflow-contract.md), [đề xuất lịch sử](../task-approval-simplification/spec.md), [team guide](../../../team_guide.md).

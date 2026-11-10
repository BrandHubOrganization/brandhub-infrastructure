# Plan — FR 3.6.9 / DA-E51-03

## Tách trang duyệt — triển khai hiện hành

Lazy route và Sidebar/route access/breadcrumb riêng. Feature task-approvals dùng Task list API POST có filter/pagination, Query theo user/Workspace/filter; chỉ tải workflow/review/Post/history của bài được chọn, tái sử dụng TaskApprovalSection trong TaskWorkflowProvider. Guard canLeave khi đổi bài/lọc/phân trang/đóng vùng xem, không mất nhận xét hoặc rời khi mutation pending. Task Detail bỏ section, thay link. Không thay notification/backend trong đợt UI này; link notification cũ tới Task vẫn có đường sang trang duyệt. Kiểm lint/typecheck/bundle và browser fixtures vi/en/mobile/dark; không tạo test trong src.

## Điều chỉnh 18/10 — bỏ cờ tích hợp

Xóa TaskApprovalProperties, dependency/guard cờ trong TaskPostService và TaskApprovalService, bỏ ConditionalOnProperty của TaskPostSubmissionWorker. Không thay transaction/schema/ACL/CAS/state policy, publish hoặc dữ liệu DB. Các nội dung gate phía dưới là thiết kế rollout cũ. Kiểm tra compile và regression bằng Mongo cô lập, không khởi động Spring writer trên Atlas.

Theo [spec v3](spec.md), BA xác nhận 2026-10-18. Đây là thiết kế đích để review/triển khai; **giai đoạn 1 không có thay đổi runtime/DB**. Các tên class/field/API mới bên dưới là đề xuất kỹ thuật đã ghi thành contract, không mô tả code đang tồn tại.

**Checkpoint giai đoạn 2:** metadata/index migration, init và checker đã triển khai trong Infrastructure; [setup/kết quả](../../../database/task-approval-setup.md). 48 offline tests + 79 Mongo assertions Pass. Atlas chỉ đọc, APPLY đang chặn bởi hai active review chưa xác minh.

**Checkpoint giai đoạn 3:** sáu API backend đã có code, default gate tắt; 91 tests hồi quy hiện có và 187 kiểm tra smoke trên Mongo 7 replica set riêng Pass. SQL ACL/Campaign trong smoke dùng mock, không thay cho test end-to-end. Giai đoạn 4–6 (POST integration/UI/rollout) chưa hoàn thành; không APPLY Atlas/không commit hoặc push. Các mục baseline dưới đây mô tả thời điểm trước code, không phải trạng thái mới.

Đã fetch origin/develop ngày 18/10 tới abb2e66: không có file database/FR3.6.9 khác baseline HEAD của nhánh tài liệu hiện tại. Không merge/chuyển nhánh khi đang có các thay đổi local giai đoạn 1/2.

Business đã fetch origin/develop tới d512f0e trước code giai đoạn 3; các file Task liên quan không khác HEAD. Không merge/check-out hoặc tác động nhánh của thành viên khác.

**Checkpoint giai đoạn 4 (core đã triển khai, rollout chưa mở):** TaskPostController/Service/Store, shared content mapping, linked old-API guards, durable Admin handoff và Task Editor riêng đã có code. 94 tests hồi quy + 231 kiểm tra smoke + 48 tests schema offline + 84 assertions rehearsal mới Pass. Browser dùng API fixtures riêng; eslint các file thay đổi và Vite bundle Pass. Type-check toàn Web còn 12 lỗi ở bốn file baseline không đổi. Publisher vẫn save toàn bộ Post, có thể race ghi đè phiên bản/nội dung. Quyết định người dùng ngày 2026-10-18: giữ nguyên phần publish, chờ thành viên phụ trách; không thêm guard tại Business publish API trong đợt này. Default gate vẫn false, chưa APPLY Atlas; không coi đây là E2E/Jira Done.

**Checkpoint giai đoạn 5:** section duyệt/history trong popup Task, preview nội dung hiện tại, Dialog quyết định và lỗi/conflict/reload đã có code Web. 30 kiểm tra browser fixtures (25 flow + 5 lỗi tải/khôi phục) và 71 guard/locale checks Pass; 81 locale keys review song song vi/en. Kiểm 375/768/1440px, light/dark, Escape/discard, giảm chuyển động và vi/en không mất nhận xét. Không mở rollout, không thay backend/schema/publish/Yjs/notification feed. Toàn Web type-check vẫn còn 12 lỗi baseline ngoài scope; không coi Vite bundle Pass là npm build Pass. Xem test.md cho giới hạn SQL/inbox/Gateway chưa kiểm.

## 1. Baseline đọc từ code local ngày 2026-10-18

| Thành phần | Đã có / khoảng trống |
|---|---|
| Business TaskDocument | Năm trạng thái, reviewStep, approvalRound=1, workflowRevision, first-start evidence; chưa có service/API Approval |
| TaskWorkflowController/Service | read/detail/field/assign/start, membership, SQL agreement lock, Mongo transaction; không phải submit/decision |
| TaskWorkflowPolicy/Store | Khóa sau start; Store.update đòi firstStartedAt=null. Không tái dùng trực tiếp cho Approval của Task đã bắt đầu |
| Mongo init | task_approvals có APPROVE/REJECT, comment, QC legacy; index đọc chưa unique mỗi Task/lượt/bước |
| PostDocument/PostServiceImpl | Không có task_id; submit hiện chỉ PENDING_APPROVAL và hook Admin; updateDraft dựa vào status DRAFT, save chưa CAS |
| Editor useEditorForm | Nhận taskId nhưng lấy brief làm caption mẫu; lỗi 400 khi lưu có thể tạo draft mới; submit xong đi /requests và bỏ draftId |
| TaskContentServiceImpl | Yjs operations/snapshots nằm PostgreSQL; không nối vào Approval POST đợt này |
| Notification | task_notification_outbox + SQL user_notifications, worker mới nhận TASK_ASSIGNED/TASK_COMMENTED |
| Admin moderation | Có thể đưa Post PENDING_APPROVAL về DRAFT khi BLOCK; không tự đồng nghĩa Task reject |
| Publishing | Module riêng; không được giả định FINISHED tự enqueue hoặc tự được phép publish |

Đây không phải inventory Atlas. Không dùng số đếm Atlas cũ của plan 16/10 để quyết định APPLY. Chưa fetch/merge develop trong giai đoạn tài liệu; đối chiếu baseline/đồng bộ nhánh là checkpoint trước code, không âm thầm merge thay đổi khác.

## 2. Ranh giới thành phần

- Business: dự kiến TaskApprovalController, TaskApprovalService/Policy/Store/Schema, TaskPostLinkService, DTO review/decision/history, adapter notification. Reuse ACL, membership resolver ClientProfile→User, ContentRequestTransactions và agreement lock; không thay JPA transaction manager toàn ứng dụng.
- Không dùng lockReason/canEditDetail để suy quyền duyệt: Task đang làm bị khóa brief là đúng; Approval dùng policy riêng và CAS cho Task đã firstStartedAt khác null.
- Giai đoạn 3 dùng `TaskApprovalProperties` (`app.task-approval.post-integration-ready`, default false) để fail closed mutation cho đến khi guard Post/hook Admin ở giai đoạn 4 được nghiệm thu. Chỉ enable trong kiểm thử cô lập giai đoạn 3. Không thay PostServiceImpl/Editor/publisher ở đợt này; không phát sinh hook Admin thiếu bền vững từ transaction mới. Read/history không phụ thuộc cờ.
- Web: bổ sung component/hook/service trong pages/tasks cho Approval; giữ popup TaskDetailPanel. Sửa hẹp điểm tích hợp trong pages/editor/hooks/useEditorForm.ts và services/postService.ts, không viết lại editor/canvas/Yjs.
- Gateway: dùng route Business hiện có; chỉ sửa nếu test chứng minh thiếu route, không đổi global auth.
- Infrastructure: DB thiết kế/migration/init/checker và docs tập trung; không sửa migration đã merge, không reset/seed DB.

## 3. API contract đích

Prefix `B=/api/v1/workspaces/{workspaceId}/tasks/{taskId}`; luôn ApiResponse, UTC ISO timestamp, UUID/String ID theo writer hiện có. Read trả dữ liệu người dùng có quyền, không leak storageKey/token.

| Method / path | Body/query | data |
|---|---|---|
| GET B/review | — | TaskReviewResponse |
| POST B/submit | expectedRevision, expectedApprovalRound, expectedPostContentVersion | TaskReviewResponse mới |
| POST B/withdraw | expectedRevision, expectedApprovalRound | TaskReviewResponse mới |
| POST B/approve | expectedRevision, expectedApprovalRound, expectedStep, expectedPostContentVersion, comment? | TaskReviewResponse mới |
| POST B/reject | expectedRevision, expectedApprovalRound, expectedStep, expectedPostContentVersion, comment | TaskReviewResponse mới |
| GET B/approvals | cursor?, limit=30, max=100 | items, nextCursor |
| GET B/post | — | TaskPostResponse {post:null nếu chưa tạo, taskRevision, canEdit, blockedReason}; không tạo dữ liệu qua GET |
| POST B/post | expectedRevision, expectedPostContentVersion? (bắt buộc khi đã có bài), post: SavePostInput | TaskPostResponse {post, taskRevision, canEdit, blockedReason} |

`TaskReviewResponse`: taskId, workspaceId, status, reviewStep, approvalRound, workflowRevision, lastSubmission (metadata), postId?, postContentVersion?, allowedActions {canSubmit,canWithdraw,canApprove,canReject}, blockedReason?, supportedType. Bài xem qua Post API scoped hiện có; history đọc được dù schema mutation/date config chưa sẵn sàng. Bài bị mất liên kết trả lý do rõ, không tạo lại để che lỗi.

`TaskApprovalDecision`: id, taskId, approvalRound, step, action, actorId, actorDisplayName, comment, createdAt. Pagination ổn định theo createdAt + _id, UI nhóm round. Không đổi comment thành reviewNote; nhãn hiển thị khác field lưu.

- Revision nguyên không âm bắt buộc; expectedApprovalRound >=1. expectedStep chỉ MANAGER/CLIENT. Backend luôn xác định actor/bước từ Task, không tin step client gửi để cấp quyền.
- Submit body gửi round đang đọc; backend tính round đích (lần đầu 1, gửi lại +1), không để client tự chọn round mới. expectedPostContentVersion dùng bộ đếm hiện có của Post, không lưu snapshot hoặc reviewContentVersion vào Task/decision.
- Reject comment strip không trắng; giới hạn kỹ thuật 5.000 ký tự, approve comment tùy chọn cùng giới hạn. Không áp giới hạn mới lên lịch sử cũ ở validator.
- PATCH `/workspaces/{id}/posts/{postId}` và `/posts/{postId}/submit` cũ giữ nguyên cho bài độc lập; từ chối bài có task_id bằng TASK_POST_WORKFLOW_REQUIRED (409), không ghi. Linked writer chỉ dùng POST B/post và B/submit với concurrency fields. Đây là lựa chọn kỹ thuật giai đoạn 4 để không đổi DTO/luồng cũ của thành viên khác, thay cho mở rộng PATCH cũ. Không tự tạo draft mới khi gặp 400/409/khóa.
- Duplicate mutation cùng revision trả 409 và UI reload; không tự replay với revision mới. Đợt này không thêm collection idempotency/command log.

### Lỗi contract đích

Giữ ErrorCode/envelope hiện có; mã mới cần bổ sung ở giai đoạn 3, không phải code đang chạy:

| HTTP | Mã | Khi nào |
|---|---|---|
| 400 | VALIDATION_ERROR | input/step/comment/caption không hợp lệ |
| 401/403/404 | UNAUTHORIZED / FORBIDDEN / TASK_NOT_FOUND / POST_NOT_FOUND | auth/member/scope; sai bước dùng WRONG_APPROVAL_STEP (403) |
| 409 | TASK_REVISION_CONFLICT / TASK_APPROVAL_ROUND_CONFLICT / POST_CONTENT_CONFLICT | màn hình cũ, nội dung đã đổi |
| 409 | TASK_NOT_SUBMITTED / TASK_REVIEW_STATE_CONFLICT / TASK_WITHDRAW_NOT_ALLOWED | transition không còn hợp lệ |
| 409 | TASK_REVIEW_CLIENT_REQUIRED / TASK_REVIEW_MANAGER_REQUIRED | không còn người duyệt hợp lệ; không tự bỏ bước |
| 409 | TASK_POST_LINK_REQUIRED / TASK_POST_LINK_CONFLICT / TASK_REVIEW_TYPE_UNSUPPORTED | thiếu/sai/trùng liên kết hoặc adapter chưa có |
| 409 | TASK_REVIEW_CONTENT_LOCKED / TASK_START_HISTORY_UNVERIFIED / TASK_CAMPAIGN_COMPLETED | khóa nội dung/legacy/Campaign |
| 503 | TASK_SCHEMA_NOT_READY / TASK_STORAGE_UNAVAILABLE / TASK_TRANSACTIONS_UNAVAILABLE | readiness hoặc hạ tầng; không trả thành công giả |
| 503 | TASK_REVIEW_INTEGRATION_NOT_READY | POST writer guards/Admin integration giai đoạn 4 chưa được bật an toàn |

## 4. Data model — đã chuẩn bị migration ở giai đoạn 2

| Collection | Thiết kế thay đổi dự kiến |
|---|---|
| tasks | Giữ status/reviewStep/approvalRound/workflowRevision; thêm optional lastSubmission metadata cho lượt gần nhất, không chứa nội dung |
| posts | task_id optional string, unique có điều kiện cho giá trị string; giữ workspace_id/content_version/status và Post độc lập |
| task_approvals | Giữ action APPROVE/REJECT, comment; unique (taskId,approvalRound,step), giữ index đọc lịch sử; chỉ writer mới dùng MANAGER/CLIENT |
| task_notification_outbox | Bổ sung TASK_REVIEW_REQUESTED / TASK_REVIEW_REJECTED và metadata round/step; giữ event types cũ |

`lastSubmission` dự kiến: round, submittedBy, submittedAt, closedBy?, closedAt?, outcome? (APPROVED/REJECTED/WITHDRAWN/CANCELLED). Chỉ metadata lượt gần nhất, không kho snapshot hoặc collection round; không hứa lưu lịch sử mọi submit/withdraw. Decision cũ append-only trong task_approvals.

Lượt đầu: Task mới approvalRound=1, lastSubmission=null/chưa có, không lịch sử decision. Submit thành công dùng 1. Khi reject/withdraw giữ round và metadata đóng lượt; lần submit tiếp theo tăng round+1. Không tăng round khi validate thất bại, Manager→Client hoặc retry. Legacy đã có round/decision không khớp metadata: inventory và fail closed, không đoán đây là lượt đầu hoặc reset về 1.

Không thêm snapshotId/reviewContentVersion, post_versions hoặc bảng round. Không cần migration PostgreSQL mới cho workflow/decision; tái dùng user_notifications. task_content_operations/snapshots PostgreSQL của FR 3.6.10 giữ nguyên, không liên kết ngầm qua tiêu đề/tác giả.

Migration mới default DRY_RUN/explicit APPLY: kiểm metadata, duplicate, type/index conflict, legacy đang QC/thiếu bước; dừng trước ghi khi có vấn đề. Không auto-link Post cũ, không xóa legacy QC history; không siết validator Post ngoài field mới. Bổ sung optional fields trước writer, tương thích reader cũ. Mỗi thay đổi đồng bộ init-mongo.js + check-mongo-migrations.mongodb.js; chứng minh fresh-init và upgraded metadata tương đương, rerun an toàn. Không chạy init lên Atlas.

File đã tạo: `docs/database/migrations/2026-10-18-task-approval-foundation.js` (một migration gộp preflight tất cả bốn collection trước DDL). Thêm index lịch sử `idx_task_approvals_timeline` để hỗ trợ cursor createdAt/_id; giữ index cũ. Dùng optional `approvalRound` (int>=1), `reviewStep` (MANAGER/CLIENT/null), `decisionId` (string/null) cho outbox; các field mới không required trên document cũ. `lastSubmission` dùng round int>=1, submittedBy string, submittedAt date; closedBy/At và outcome optional/null. APPLY thêm xác nhận `TASK_APPROVAL_WRITERS_PAUSED=true`, không phải thao tác tự khóa writer. Thiếu revision/start trên Task chưa review là inventory cảnh báo; active review thiếu bằng chứng thì chặn toàn APPLY, không tự backfill.

## 5. Xử lý nguyên tử và khóa nội dung

1. Auth/User/membership active → scope Task → schema readiness → acquire SQL agreement lock cho Task gắn Campaign, kiểm Campaign chưa COMPLETED. Không áp lock policy brief trước-start lên Approval.
2. Trong Mongo transaction đọc lại Task/Post, revision/status/step/round/lastSubmission, link/type/Workspace. Resolve và recheck actor + người nhận hợp lệ qua ACL; không lấy ClientProfile ID làm User ID.
3. Validate action. Khi submit yêu cầu Manager hợp lệ; cần Client thì xác nhận ít nhất một Client có User active. Bước đang chờ Client không tự skip nếu hết Client; UI vẫn hiện blockedReason/cách bổ sung.
4. CAS Task bằng ID + workspaceId + revision + status + reviewStep + round + updatedAt. Giữ firstStartedAt/By và khóa Manager; không save/replace toàn document từ DTO. Approve/reject chỉ insert decision khi CAS thành công trong cùng transaction; duplicate index làm rollback toàn bộ.
5. Đồng bộ trạng thái linked Post trong transaction: gửi=PENDING_APPROVAL; reject/withdraw mở lại DRAFT; cuối chuỗi=APPROVED. Đây là adapter đích, không thay ý nghĩa Admin moderation hoặc publisher; nội dung FINISHED giữ khóa sửa. Chỉ dùng state mapping khi Post chưa bị publish/đổi trạng thái bởi writer khác; xung đột thì fail closed, không ghi đè trạng thái ngoài luồng.
6. Mọi linked Post edit phải kiểm Task IN_PROGRESS, revision/Post content_version và cập nhật guard của Task trong cùng transaction. Như vậy save↔submit/decision cạnh tranh cùng document; chỉ đọc Task rồi save Post không đủ chống race. Post độc lập giữ contract cũ. Kiểm mọi writer của posts trước bật feature.
7. Task mutation + Post state + decision + outbox cùng Mongo transaction; SQL agreement lock phối hợp Campaign closure, **không gọi đây là distributed ACID giữa SQL/Mongo**. Notification SQL qua outbox sau commit. Không tái dùng mapper lỗi ContentRequest theo cách biến duplicate approval thành lỗi Request sai nghĩa.
8. CampaignClosureStore hiện không tăng workflowRevision/xóa reviewStep khi cancel: giai đoạn 3 phải phối hợp targeted cleanup lastSubmission/reviewStep và CAS; giữ cancellation audit, kiểm race hai phía. Không thay BA/bulk-cancel UI.

### Chi tiết tích hợp giai đoạn 4

- TaskPostService GET không tạo bài; POST lưu mới/cập nhật bài duy nhất qua partial unique task_id. Chỉ assignee Creator IN_PROGRESS có first-start evidence; touch Task bằng CAS tăng workflowRevision cùng transaction với Post write. Save không tăng approvalRound. Update chỉ $set nội dung thuộc Editor, không replace field ngoài scope.
- GET trả metadata canEdit/block reason riêng, không lấy khóa brief làm khóa nội dung. Bài linked reopen đúng bài, giữ media s3Key/mediaType thay vì biến URL ký thành external URL mới. Blank draft được lưu, submit vẫn yêu cầu caption.
- Không thay SavePostRequest/PostResponse hiện có hoặc publisher/Yjs. PostDocument thêm mapping task_id để writer hiện có không vô tình bỏ link khi round-trip. PostServiceImpl chặn linked PATCH/submit trước mọi save/hook. Extract mapping nội dung thuần dùng chung, không đổi validation bài độc lập.
- Dùng lại task_notification_outbox cho event nội bộ TASK_POST_SUBMITTED (không phải notification UI), optional postId/postContentVersion. Dedicated worker chỉ claim event này, worker notification hiện có không claim. Event cùng Mongo transaction với submit; sau commit worker gọi hook moderation.onSubmitted có idempotency post/version hiện có. Không gọi SQL/Admin hook bên trong callback Mongo có retry, không thêm review snapshot Task/collection mới.
- Worker kiểm workspace/post/task/link/version; version cũ đã được sửa thì suppress, không capture nhầm nội dung mới dưới version cũ. Retry lease bảo đảm hook chưa xong không mất; SQL inbox/Admin vẫn là eventual consistency, không hứa distributed ACID. Admin hook/source/strike/audit không bị viết lại. ACTIVE-only ACL hiện có vẫn giữ, không tự mở quyền cho FLAGGED user.
- Metadata bổ sung vào migration Approval foundation **đang untracked/chưa merge/chưa APPLY** cùng init/checker; không sửa migration lịch sử đã merge. Phải chạy lại toàn bộ schema tests vì definitions mới; inventory Atlas cũ chỉ là snapshot thời điểm giai đoạn 2.
- Admin DRAFT khi IN_REVIEW: policy cho reject/withdraw đúng quyền trên cùng link/version; approve fail closed. Giữ lượt, audit và khóa mọi linked content writer; không tự tạo Task REJECT từ Admin.
- Editor dùng hook riêng cho Task thay vì đổi flow bài độc lập; load review/post song song, cleanup response khi route đổi, serialize save→submit và chặn double action. Lỗi save giữ dirty/content; không xóa draftId hoặc navigate /requests sau Task submit. Khi Task đang duyệt/terminal: read-only, không gọi publish từ Task editor. Đây là UI boundary, publisher backend chưa được tích hợp không được tuyên bố đã chặn mọi API publish.

### Điểm phối hợp bắt buộc trước giai đoạn 4

- Editor: bỏ prefill nội dung mẫu và fallback tạo draft khi linked Post bị khóa; giữ draftId/link khi submit; load đúng Post khi quay lại; lưu xong mới gửi; không đổi bài độc lập.
- Admin: Post bị BLOCK có thể thành DRAFT trong khi Task vẫn IN_REVIEW. Khóa linked Post vẫn theo Task; không tự biến Admin BLOCK thành Task REJECT. Nếu cần tự động chuyển Task do Admin thì hỏi BA riêng, không thêm ở đây. Hook moderation.onSubmitted hiện có phải chạy qua cùng cơ chế bền vững được thống nhất, không mất hook/nhân đôi review do transaction retry.
- Publishing: giữ queue/callback/API; bàn giao link và kết quả duyệt, không gọi publish từ Approval. Hiện publisher không kiểm mọi điều kiện duyệt Task; không tuyên bố rollout bảo đảm chặn publish trước duyệt nếu module đó chưa tích hợp. Không tự sửa thay người phụ trách.
- External URL/S3 object: guard khóa field, không tự đổi storage policy hoặc cam kết byte snapshot. Yjs và editor độc lập không bị giả là cùng một bài.

## 6. Notification và frontend

TASK_REVIEW_REQUESTED: submit→Manager active; Manager approve cần Client→tất cả Client đủ điều kiện (chỉ một người cần quyết định). EventKey theo Task/round/step/recipient. Delivery recheck member/User/status/step/round, suppress thông báo chờ đã withdraw/reject/cancel/chuyển bước. TASK_REVIEW_REJECTED gửi Creator được giao, dedup theo decisionId/recipient; không suppress chỉ vì Creator đã sửa lại trạng thái, nhưng vẫn kiểm ACL. Không bắt worker cũ lọc tất cả recipient thành Creator.

Tái dùng SQL inbox UPDATE, lease/retry/deterministic ID; không gửi caption/lý do nhạy cảm qua payload chung. Không tự bổ sung email hoặc thông báo hoàn thành chưa được BA yêu cầu.

Web query `/review` và `/approvals` tách khỏi autosave brief/comment. Mutation thành công invalidate task-workflow/list/review/history/Campaign progress; không reset draft comment. Post save cập nhật revision cho Task đang mở. Không lạc quan chuyển FINISHED trước commit. Dùng action policy từ `/review`, không mở quyền dựa vào role text trên header. 409 giữ input, hiển thị “Dữ liệu đã thay đổi”, reload rồi cho quyết định lại; không auto-submit.

Locale dự kiến `src/i18n/locales/vi/tasks.json`, `en/tasks.json`, `vi/editor.json`, `en/editor.json`; keys ở spec §5. Tiêu chí UX từ ui-ux-pro-max: lỗi inline + đường khôi phục, loading/disable chống bấm trùng, focus/keyboard và semantic tokens; không tái thiết kế popup/danh sách.

### Triển khai UI giai đoạn 5

- `TaskApprovalSection` nằm giữa chi tiết/Start và bình luận trong `TaskWorkflowContent`; bỏ khối link Editor có text lỗi mã hóa, thay bằng nội dung/link có i18n trong section mới. Không đổi layout popup hoặc comments.
- `useTaskApproval` dùng Query riêng, scope cả user/Workspace/Task; tải review và Task Post song song cho POST, history cursor tách riêng. Chỉ cho quyết định khi postId/contentVersion và taskRevision của nội dung hiển thị khớp review. Lỗi tải/refetch không mở action trên dữ liệu cũ.
- Section hiển thị caption dạng text an toàn, hashtag/kênh/ảnh/video hiện tại, không chèn HTML người dùng. Không cung cấp Publish. Loại chưa có adapter chỉ xem trạng thái/lịch sử và lý do; không gọi Post API cho các loại này.
- Submit/approve/reject/withdraw dùng Dialog ứng dụng xác nhận, chụp revision/round/step/Post version đang xem. Reject bắt buộc lý do, approve tùy chọn, tối đa 5.000 ký tự theo API. Conflict/lỗi giữ lý do, khóa gửi lại đến khi người dùng tải lại và xác nhận nội dung mới; không tự replay. Nội dung đối chiếu hiển thị ngay trong Dialog để tránh duyệt bản chưa nhìn thấy.
- Mutation chỉ báo thành công sau response commit; khóa đóng khi đang gửi qua edit session hiện có. Sau thành công refresh task-workflow, review/history và gọi onUpdated cho list background; không invalidate/unmount bình luận. Campaign dùng state local, tự tải lại khi vào trang theo code hiện có, không tạo cache key giả hoặc sửa module Campaign.
- Chỉ mở Dialog action bằng allowedActions từ API; không suy role từ header. Refresh review không đổi key TaskComments/TaskInlineDetails. Draft nhận xét duyệt đăng ký edit session để có app discard guard khi rời Task.
- Không thêm backend/schema/notification mới trong giai đoạn này; dùng outbox/inbox đã có. Không bật rollout, không APPLY Atlas, không sửa publish hoặc Yjs. Các kiểm chứng UI dùng API fixtures cô lập, không thay cho SQL/inbox/Gateway E2E.

## 7. Lộ trình và commit/bàn giao

| Giai đoạn | Đầu ra | Điều kiện chuyển tiếp |
|---|---|---|
| 1 — đã hoàn thành tài liệu | spec/plan/task/test; đồng bộ BA/UC/state/glossary/master plan, tham chiếu tài liệu cũ | BA đã ghi; review consistency/link; không runtime/DB |
| 2 — schema chuẩn bị xong, rollout pending | inventory read-only, migration + init/checker; rehearsal Mongo replica set Pass | Hai active review Atlas chưa xác minh chặn APPLY; operator/team duyệt reconciliation riêng |
| 3 — backend đã kiểm thử cô lập | service/policy/API, unique decision, outbox, phối hợp cancel; default gate tắt | 91 hồi quy + 187 kiểm tra smoke Pass; chưa thay cho SQL/Editor/Admin/notification end-to-end |
| 4 | liên kết Task–Post, Editor submit/lock, kiểm mọi writer | thống nhất điểm chạm với chủ Editor/Admin/publishing; chưa xong không công bố E2E |
| 5 | phần duyệt/history trong Task popup, thông báo, i18n/theme | kiểm flow thật theo Creator/Manager/Client; không đổi UI ngoài phạm vi |
| 6 | hồi quy/rollout/setup/bàn giao | test.md pass theo phạm vi, Report 3/4 và team review/Jira riêng |

Commit tách docs / schema / backend / POST integration / frontend / verification theo task E51-03; dùng mã Jira số **sau khi xác minh**, không tự đoán DA-977 hoặc sửa trạng thái Jira từ checkbox local. Giai đoạn 1 không commit/push tự động. Không thêm/commit file test trong src theo yêu cầu người dùng; kiểm thử cô lập/manual hoặc harness local ngoài src, không đưa artifact lên Git.

Trước triển khai code: đồng bộ nhánh có kiểm soát, giữ thay đổi local; không lấy kế hoạch làm quyền merge/push/APPLY. Báo trước điểm ảnh hưởng module khác; nếu BA thay đổi thì quay lại spec → plan → task → test.

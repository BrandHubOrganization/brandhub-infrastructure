# Hợp đồng Task Detail / Assignment / Comments

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

Ngày 2026-10-14. DA-978 (FR 3.6.1/2), DA-1236 (FR 3.6.3).
Nguồn BA: [roadmap, quyết định Q13 mới nhất](task-detail-assignment-comments-roadmap.md).
Nguồn thiết kế giai đoạn 1. Đợt 2026-10-15 đã code các workflow endpoints đọc/detail/assign/start và notification giao việc; comments/uploads vẫn là contract mục tiêu. Không thay editor hoặc Approval của thành viên khác. Bằng chứng và giới hạn ở [bàn giao đợt 2/3](task-workflow-phase-2-3.md).

## 1. Ranh giới dữ liệu và quyền

| Dữ liệu/hành động | Manager thực tế trong WS | Creator active trong WS | Client active trong WS |
|---|---|---|---|
| Đọc workflow, bình luận, xem ảnh ATTACHED | Có | Có | Mọi Task cùng Workspace |
| Sửa brief/deadline | Trước lần bắt đầu đầu tiên | Không | Không |
| Giao Creator/QC | Sau DETAIL_IDENTIFIED, trước lần bắt đầu | Không | Không |
| Bắt đầu làm | Không thay Creator | Chỉ assignee, ASSIGNED, lần đầu | Không |
| Bình luận Task COMPLETED/CANCELLED | Có | Có | Có, nếu vẫn active cùng Workspace |
| Editor/content/submit/approval | Giữ contract của module hiện có; không suy ra quyền từ bảng này |||

Owner cấp Agency không tự có quyền Manager trong WS. Owner có membership Manager thì dùng quyền Manager.
Resolve ClientProfile → User ID, không nhầm ID membership/profile thành assignee/mention userId.
Mọi truy cập đều scope workspaceId + taskId, xác minh membership active của đúng WS.
**Q13 confirmed 2026-10-14:** Client được xem/bình luận mọi Task cùng Workspace, kể cả Task Manager
tạo thủ công, Task cũ, lịch sử bình luận và ảnh ATTACHED. Không phân biệt nội bộ/thường, không có
field/filter/bộ chọn visibility. Q13 thay thế phần phân quyền Q6/Q9 và ràng buộc Q12 trước đây.
`requiresClientApproval` chỉ quyết định bước Client duyệt kết quả; true/false không đổi quyền đọc/bình luận.
Không cấp quyền editor/content/assign cho Client hoặc quyền xem cho người ngoài/đã rời Workspace.
DRAFT upload vẫn chỉ chủ upload được preview. Client chỉ nhận notification comment khi được mention (Q11 giữ nguyên).
Thiếu revision/start marker ở legacy chỉ ảnh hưởng mutation quản lý, không chặn đọc/bình luận.

## 2. Schema bổ sung, không thay identity

| Collection | Bổ sung / mục đích |
|---|---|
| tasks | workflowRevision; plannedPublishAt; inputReferences; detailIdentifiedAt/By; assignedAt/By; firstStartedAt/By |
| task_comments | Bình luận append-only, snapshot tác giả, mention User IDs, attachment IDs, clientRequestId |
| task_comment_uploads | Ảnh riêng tư của Task, chủ upload, MIME/byteSize, storageKey, trạng thái gắn comment/cleanup |
| task_notification_outbox | Sự kiện gửi từng người, eventKey chống trùng, lease/retry; worker đưa vào inbox SQL hiện có |

Field mới của `tasks` **optional trong validator**, không thêm required và không sửa documents cũ.
Writer mới phải khởi tạo workflowRevision=0, firstStartedAt/By=null, giữ source metadata để truy vết, không phân quyền theo nguồn.
Spring Data có thể bỏ field null khi serialize: phải dùng `@Field(write = ALWAYS)` hoặc targeted
insert bảo đảm marker null thực sự được ghi; test kiểm tra BSON field presence, không chỉ Java DTO.
Thiếu firstStartedAt ở legacy là **chưa biết lịch sử**, không đồng nghĩa chưa bắt đầu;
inventory/reconcile tường minh trước cho sửa/giao lại. Không mở khóa chỉ vì status=ASSIGNED.
Migration chỉ mở rộng schema, không bật workflow hay ACL ở ứng dụng.

Giữ nguyên Task ID, type, sourceType/sourceRefId, campaignId/campaignWorkItemId,
typeMetadata, approvalRound, cancellation và task_approvals.
Campaign sourceRefId hiện là **workItem ID**; Content Request sourceRefId là Request ID.
Mốc Campaign không phải Task. Đầu việc bổ sung không thay sản lượng/kế hoạch đã duyệt.

Giới hạn kỹ thuật dự kiến (không phải BA mới): description 10.000 ký tự ở API; tối đa 20 reference
HTTP(S), label 200/url 2.048; comment plain text 1..10.000 ký tự; tên file 255;
cursor opaque, limit mặc định 30/tối đa 100. Không đặt giới hạn mới lên description legacy ở DB.
Ảnh theo BA: tối đa 5 JPEG/PNG/WebP, mỗi ảnh 5 MB = 5×1024×1024 byte.

## 3. API workflow (contract mục tiêu)

Prefix `/api/v1/workspaces/{workspaceId}/tasks`:

| Method / suffix | Input chính | Output `data` |
|---|---|---|
| GET `/{taskId}/workflow` | — | Workflow DTO và allowedActions |
| GET prefix hiện có (không suffix) | page, size, sort, status, type, search, campaignId | Spring Page; reuse DA-979, không thêm list `/workflow` |
| GET `/{taskId}/member-options` | purpose=ASSIGNMENT hoặc MENTION | User ID, displayName, role hợp lệ |
| PATCH `/{taskId}/detail` | description, dueDate, plannedPublishAt?, inputReferences, expectedRevision | Workflow DTO mới |
| POST `/{taskId}/assign` | assigneeId, qcAssigneeId=null hoặc UUID, requiresClientApproval, expectedRevision | Workflow DTO ASSIGNED |
| POST `/{taskId}/start` | expectedRevision | Workflow DTO IN_PROGRESS |

Đợt 2026-10-15 reuse list đã nối dữ liệu thật của DA-979; không thêm list `/workflow` hoặc Calendar/Kanban thứ hai. member-options hiện chỉ phục vụ ASSIGNMENT và chỉ Manager, chưa triển khai MENTION.
Đặt route tĩnh tránh va chạm `/{taskId}` hiện tại. Editor TaskResponse giữ nguyên;
không mở Client vào endpoints content/Yjs/versions để đọc workflow.

Workflow DTO: id/workspaceId/type/name/status/source/campaign IDs, description, dueDate,
plannedPublishAt, inputReferences, assignee/QC, requiresClientApproval,
workflowRevision, firstStartedAt, allowedActions và trạng thái `legacyReviewRequired` khi thiếu dữ liệu an toàn.
Không trả storageKey hoặc nội dung typeMetadata chuyên biệt qua DTO chung.

`expectedRevision` nguyên không âm bắt buộc. Dùng UTC timestamp RFC3339 có offset;
API so sánh thời gian theo timezone Workspace, không theo timezone trình duyệt.
DueDate Campaign: từ đầu ngày max(today,start) đến hết ngày end; plannedPublishAt POST
không trước dueDate và cùng khung Campaign. Manual không Campaign: từ đầu hôm nay.
Ngày đăng POST là optional trong đợt này; bỏ trống không tự schedule. Không cho field này với loại khác.

HTTP lỗi dự kiến: 401 hết/mất phiên; 403 FORBIDDEN do role/membership; 404 TASK_NOT_FOUND
cho task không thuộc scope (tránh tiết lộ tồn tại);
400 VALIDATION_ERROR/INVALID_ASSIGNEE/INVALID_QC_ASSIGNEE/QC_CANNOT_BE_SAME_AS_ASSIGNEE;
409 TASK_REVISION_CONFLICT/TASK_DETAIL_NOT_IDENTIFIED/TASK_WORKFLOW_LOCKED/
TASK_START_HISTORY_UNVERIFIED/CAMPAIGN_COMPLETED; 503 TASK_SCHEMA_NOT_READY.
Luôn dùng error envelope hiện có + field errors; UI giữ input, không tự retry mutation cũ khi 409.

## 4. Concurrency và lifecycle tích hợp

1. Auth/member → Task scope → schema readiness → đọc revision/status và metadata.
   Legacy/start guards chỉ chặn mutation quản lý, không chặn Client đọc/bình luận Task cùng WS.
2. Mutation Task gắn Campaign dùng cùng SQL agreement lock với CampaignClosureService.
3. Validate toàn payload + membership assignee/QC hiện tại. Targeted `$set/$inc`, CAS
   theo revision + status + first-start guard; không save/replace document từ DTO.
4. Giữ updatedAt tương thích writer cancellation. Các writer cùng sửa trạng thái phải phối hợp revision;
   trước khi đủ phối hợp dùng thêm điều kiện updatedAt và không tuyên bố mọi writer đã CAS an toàn.
5. Task mutation/comment + outbox trong **cùng Mongo transaction**. Không gọi SQL inbox
   như thể PostgreSQL và Mongo cùng transaction ACID. Không tạo Task/notification nửa chừng.
6. Start đầu tiên: chỉ assignee active bấm, ASSIGNED → IN_PROGRESS, ghi firstStartedAt/By một lần.
   Reject về ASSIGNED vẫn giữ marker. Resubmit/review thuộc E51-03; chưa sửa module đó ở đây.
7. E51-03 phải duyệt lại QC (nếu có) trên nội dung mới sau reject, giữ lịch sử approval cũ.
   Việc quay lại IN_PROGRESS/submit sau reject cần cùng chủ Approval tích hợp, không reset marker.

Campaign completed không sửa/giao/bắt đầu Task gắn Campaign; comments vẫn cho phép theo BA.
Cancel mọi trạng thái chưa terminal giữ audit; workflow không phục hồi CANCELLED.
Membership có thể thay đổi ngoài Mongo: kiểm tra lại trước commit/delivery/download và không cache quyền dài hạn;
không hứa cross-store atomicity. Cần test race removal ở giai đoạn tích hợp.

## 5. API comments và file riêng tư

Prefix `.../tasks/{taskId}`:

- GET `/comments?cursor=&limit=30` → 200 `{items,nextCursor}` theo createdAt DESC + id DESC;
  UI đảo thứ tự để đọc timeline, không làm mất/trùng khi timestamp bằng nhau.
- POST `/comments` → 201 `{id,taskId,authorId,authorDisplayName,authorRole,content,mentions,attachmentIds,createdAt}`.
  Payload `{content,mentions:[],attachmentIds:[],clientRequestId:UUID}`; không nhận authorId/role từ Client.
  Retry cùng tác giả/task/clientRequestId và cùng payload trả comment đã tạo; cùng key khác payload → 409.
- POST `/comment-uploads` multipart `file` → 201 `{id,name,contentType,byteSize}`.
- GET `/comment-uploads/{uploadId}/content` → stream ảnh qua API đã auth sau kiểm tra ACL;
  không lộ public S3 URL/key và không dùng MailAttachment/Material Library làm endpoint chung.

Kiểm tra MIME thật, kích thước và decode ảnh; không chỉ tin extension/content-type từ browser.
Bind upload cùng Task/WS/chủ gửi đúng một comment, tối đa 5, bằng CAS trong transaction;
không nhận URL arbitrary, không cho bind lại upload ATTACHED. Người có quyền Task mới đọc được ảnh ATTACHED;
DRAFT chỉ chủ upload được preview. Plain text, link HTTP(S) an toàn, không render HTML tùy ý.

Upload metadata có expiresAt cho DRAFT; cleanup worker lấy lease/chuyển CLEANUP_PENDING,
xóa object thành công rồi mới xóa metadata. **Không TTL**: TTL metadata có thể làm mất dấu object rác.
Cleanup và bind CAS state để không xóa ảnh đã gắn. Thời gian lưu DRAFT là cấu hình kỹ thuật cần ghi setup,
không tự đặt thành BA hay xóa shared data trong phase 1.

## 6. Notification

TASK_ASSIGNED gửi Creator mới nhận việc; TASK_COMMENTED lấy hợp của mentions + assignee + QC + Managers.
Dedup/exclude author; Client chỉ khi được mention; recheck ACL trước delivery. Không gửi email.
Mỗi delivery có eventKey ổn định và UUID id dùng cho SQL `user_notifications.id`.
Worker lease + retry; INSERT ON CONFLICT chống trùng, đánh SENT chỉ sau SQL commit.
Nếu người nhận mất quyền → SUPPRESSED; lỗi tạm thời retry, log chỉ IDs/code, không log comment/token.
Không payload nội dung bình luận nhạy cảm vào notification; link Task Detail kiểm tra ACL lại khi mở.
SQL inbox đã đủ cột, **không có migration PostgreSQL mới cho ba FR này**.

## 7. Phạm vi và checkpoint phối hợp

- Business dự kiến TaskWorkflowController/Service/Access/Store/DTO, TaskCommentService/UploadService,
  TaskNotificationOutboxWorker; reuse WorkspaceAccessService và FileStorageService ở mức adapter.
- Web module Tasks riêng; locale `src/locales/{vi,en}/tasks.json` (xác minh registry i18n trước code),
  route detail và link Campaign/Request. Không thay UI Chat/Mail/editor/Calendar của người khác.
- Gateway route API hiện có; chỉ sửa nếu test chứng minh thiếu route, không chỉnh global auth.
- Infrastructure migration + init + checker + tests; không chạy init lên Atlas, không backfill.
- Chủ E51-03 (Phước): marker/start/CAS/resubmit. Chủ E51-05 (Phước): list/entry point.
  Chủ editor/Livestream/Survey: không đổi identity/content contract. Chưa tuyên bố đã được họ review.
- Phase 1 chỉ schema/tài liệu/offline tests. Chỉ chuyển phase ứng dụng sau review hợp đồng tích hợp.

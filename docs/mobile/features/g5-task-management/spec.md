# G5 — Task Management đầy đủ trên Mobile

> Trạng thái: DRAFT — spec, không code. Phụ thuộc G1 (Auth) + G2 (Creator Upload) đã xong.
> Nguồn: `docs/mobile/mobile-app-plan.md` mục 3 dòng G5; `docs/ba/05-content-task-workflow.md`
> (đọc lại bản mới nhất 2026-10-22, áp dụng ghi chú BA 2026-10-18 FR 3.6.9 — thay toàn bộ
> QC/approval cũ); code thật đọc trực tiếp trong `brandhub-business-service`
> (`controller/Task*.java`, `dto/request|response/Task*.java`, `model/Task.java`,
> `model/enums/TaskType.java`, `document/TaskDocument.java`).

## 1. Mục tiêu & phạm vi

Mở rộng mobile từ "Approval Queue" (chỉ xem Task đang chờ duyệt) thành Task Management đầy
đủ như web: list Task, xem detail, bình luận, và thực hiện toàn bộ chuyển trạng thái
(start/submit/approve/reject/withdraw) theo đúng Approval Sequence FR 3.6.9.

**Trong phạm vi G5 (bắt buộc):**
- Task List View (FR 3.6.4) — filter/sort/search.
- Task Detail — xem đầy đủ field, trạng thái, lịch sử approval, action button theo role.
- Comment thread (FR 3.6.3) — mention + ảnh đính kèm.
- Status transitions: start, submit for review, approve (Manager/Client), reject, withdraw.
- Kanban Board (FR 3.6.7) — tối thiểu 1 kiểu board (TODO/IN_PROGRESS/IN_REVIEW/FINISHED),
  kéo thả giới hạn theo transition hợp lệ.

**Stretch / có thể cắt nếu thiếu thời gian (xem mục 7 để biết lý do):**
- Calendar Task View (FR 3.6.5).
- 2 kiểu board Kanban còn lại trong 3 kiểu board yêu cầu ở FR 3.6.7.
- Gantt Timeline View (FR 3.6.6) — **đề xuất loại khỏi V1 mobile hoàn toàn**, xem mục 7.

Việc Manager "Identify Task Detail" (gán assignee/dueDate lần đầu, FR 3.6.1/3.6.2) **không**
nằm trong G5 — đó là tác vụ quản trị nặng form, phù hợp hơn với web; G5 trên mobile tập
trung vào luồng Creator/Manager/Client thực thi Task đã được giao.

## 2. FR tham chiếu

- FR 3.6.1 — Identify Task Detail (đọc để hiểu field, không làm UI tạo mới trên mobile).
- FR 3.6.2 — Assign Task To Creator (đọc để hiểu field assigneeId, không làm UI gán trên mobile V1).
- FR 3.6.3 — Add Comments On Task (đầy đủ trên mobile).
- FR 3.6.4 — List Task View (đầy đủ trên mobile).
- FR 3.6.5 — Calendar Task View (stretch).
- FR 3.6.6 — Gantt Timeline Task View (loại khỏi V1, xem mục 7).
- FR 3.6.7 — Kanban Board Task View, 3 kiểu board (tối thiểu 1 kiểu trong V1).
- FR 3.6.8 — View Task Filter (đầy đủ, tích hợp vào List + Kanban).
- FR 3.6.9 — Approval Sequence Creator→Manager→Client (đầy đủ, đây là phần business rule lõi).

## 3. API cần dùng

Tất cả endpoint dưới `/api/v1/workspaces/{workspaceId}/tasks` hoặc
`/api/v1/workspaces/{workspaceId}/tasks/{taskId}`. Base path xác nhận từ
`TaskController`, `TaskWorkflowController`, `TaskApprovalController`, `TaskCommentController`.

**Lưu ý quan trọng về model:** có 2 tầng dữ liệu Task trong code hiện tại:
- `model/Task.java` (SQL, bảng `tasks`) — entity tối giản chỉ để anchor FR 3.6.10 content
  writing (id, workspaceId, type, title, createdBy, timestamps) — **không có** assignee,
  dueDate, status, comment. Đây KHÔNG phải Task object chính cho workflow.
- `document/TaskDocument.java` (MongoDB, collection `tasks`) — **source of truth thật cho
  workflow**: status, reviewStep, assigneeId, requiresClientApproval, approvalRound,
  lastSubmission, workflowRevision, firstStartedAt, inputReferences, cancellation, v.v.
  Mobile phải build toàn bộ UI xung quanh `TaskListItemResponse` /
  `TaskWorkflowResponse` / `TaskReviewResponse` (đều map từ `TaskDocument`), **không** dùng
  `TaskResponse` (map từ SQL `Task.java`) để hiển thị status/assignee — field đó không tồn
  tại ở đó.

### 3.1 List
`GET /tasks?page&size&sort&direction&status&type&search&campaignId`
(`TaskController.getTasks`, query shape = `TaskListQuery(page, size, sort, direction, status,
type, search, campaignId)`). Role cho phép: OWNER, MANAGER, CREATOR, CLIENT. Trả về
`Page<TaskListItemResponse>` — field: `id, workspaceId, campaignId, type(TaskType), name,
status, dueDate, publishDate, assigneeId, createdAt, updatedAt, description, sourceType,
sourceRefId, reporterId, assigneeName, assigneeAvatar, reporterName`.

Theo Q13 (BA 2026-10-14, đã confirm): Client active thấy **toàn bộ Task cùng Workspace**,
không lọc theo "Task cần tôi duyệt" — client-side mobile không tự thêm filter ẩn theo
role, chỉ hiển thị filter UI chuẩn (status/type/search/campaignId) giống Manager/Creator.

### 3.2 Detail / Workflow
`GET /tasks/{taskId}/workflow` → `TaskWorkflowResponse` (`TaskWorkflowController.read`):
`id, workspaceId, campaignId, campaignName, type, name, status, sourceType, sourceRefId,
description, dueDate, publishDate, inputReferences, assigneeId, assigneeName,
requiresClientApproval, workflowRevision, firstStartedAt, legacyReviewRequired, schemaReady,
lockReason, allowedActions{canEditDetail, canAssign, canStart}, dates{timezone, minDate,
maxDate, ready}, reviewStep`.

`GET /tasks/{taskId}/review` → `TaskReviewResponse` (`TaskApprovalController.read`):
`taskId, workspaceId, status, reviewStep, approvalRound, workflowRevision, lastSubmission,
postId, postContentVersion, supportedType, schemaReady, blockedReason,
allowedActions{canSubmit, canWithdraw, canApprove, canReject}`.

Mobile Task Detail screen gọi cả hai (workflow cho metadata, review cho action-gating) —
`allowedActions` ở cả hai response là nguồn chân lý để show/hide nút hành động theo
role+status hiện tại, **không tự suy luận lại rule ở client**.

`GET /tasks/{taskId}/approvals?cursor&limit` → `TaskApprovalDecisionResponse.Page`
(lịch sử approve/reject từng round, dùng cho tab "Lịch sử duyệt" trong Task Detail):
`id, taskId, approvalRound, step, action, actorId, actorDisplayName, comment, createdAt`.

`GET /tasks/{taskId}/member-options` → danh sách Option gán assignee (chỉ cần nếu mobile
làm thêm UI gán — không bắt buộc V1).

### 3.3 Status transitions
Tất cả request đều có field optimistic-concurrency `expectedRevision` /
`expectedApprovalRound` / `expectedPostContentVersion` — mobile **phải** gửi đúng giá trị
đọc được từ response gần nhất, server reject nếu stale (conflict do người khác vừa đổi).

- `POST /tasks/{taskId}/start` — `TaskStartRequest(expectedRevision)`. Role: Creator được
  giao, Task đang TODO. → IN_PROGRESS.
- `POST /tasks/{taskId}/submit` — `TaskReviewSubmitRequest(expectedRevision,
  expectedApprovalRound, expectedPostContentVersion)`. IN_PROGRESS → IN_REVIEW/MANAGER.
- `POST /tasks/{taskId}/approve` — `TaskReviewDecisionRequest(expectedRevision,
  expectedApprovalRound, expectedStep["MANAGER"|"CLIENT"], expectedPostContentVersion,
  comment?)`. Manager approve → FINISHED (nếu !requiresClientApproval) hoặc
  IN_REVIEW/CLIENT. Client approve → FINISHED.
- `POST /tasks/{taskId}/reject` — cùng shape `TaskReviewDecisionRequest`, `comment` nên bắt
  buộc ở UI (dù DTO chỉ validate `@Size(max=5000)`, không `@NotBlank`) vì BA yêu cầu "reject
  có lý do". → IN_PROGRESS.
- `POST /tasks/{taskId}/withdraw` — `TaskReviewWithdrawRequest(expectedRevision,
  expectedApprovalRound)`. Chỉ Creator, chỉ trước Manager decision. → IN_PROGRESS.

### 3.4 Comment (FR 3.6.3)
- `GET /tasks/{taskId}/comments?cursor&limit` → `TaskCommentResponse.Page`.
- `POST /tasks/{taskId}/comments` body `TaskCommentRequest(content, mentions[], 
  attachmentIds[], clientRequestId)` — `clientRequestId` dùng để idempotent retry khi mất
  mạng giữa chừng (mobile network không ổn định, tái dùng pattern này cho optimistic send).
  Giới hạn: `mentions` tối đa 100, `attachmentIds` tối đa **5** — khớp đúng rule BA "tối đa 5
  ảnh × 5MB/comment".
- `GET /tasks/{taskId}/comment-members?search&page` → gợi ý mention (`@` autocomplete).
- `POST /tasks/{taskId}/comment-uploads` (multipart, field `file`) → `TaskCommentResponse.
  Upload(id, name, contentType, byteSize)`. Gọi endpoint này **trước** khi tạo comment để
  lấy `attachmentIds`, giống luồng 2 bước presign-rồi-gắn của G2 Creator Upload — mobile tái
  dùng y nguyên UI picker (camera native / chọn từ thư viện) đã làm ở G2, chỉ đổi target
  endpoint. Giới hạn 5 ảnh × 5MB phải validate ở client trước khi gọi API để tránh user chờ
  lâu rồi bị reject.
- `GET /tasks/{taskId}/comment-uploads/{uploadId}/content` → trả bytes ảnh để hiển thị
  (response có `Content-Security-Policy: sandbox`, `X-Content-Type-Options: nosniff` — chỉ
  dùng để render trong `<Image>`/tương đương, không mở trong WebView).

### 3.5 Không dùng ở G5
- `TaskController` (`/tasks`, `/tasks/{id}`, `/tasks/{id}/content*`) — đây là CRUD cho
  Task SQL tối giản + Yjs content editor (FR 3.6.10). Không dùng cho list/detail workflow.
  Không dùng cho mobile G5 (xem mục 7 — không làm editor).
- `TaskPostController` (`/tasks/{id}/post`) — đọc/lưu nội dung Post (field editor). Không
  dùng ở G5 (đọc field có thể cần nếu muốn hiển thị preview nội dung Post trong Task Detail
  — **mở là câu hỏi mở ở mục 8**, nhưng ghi/sửa chắc chắn không làm).
- WebSocket `/app/tasks/{taskId}/content` / `/topic/tasks/{taskId}/content`
  (`TaskContentWebSocketController`) — đây là kênh sync Yjs real-time cho rich-text editor
  content, **không phải** kênh thông báo đổi status/comment. Không áp dụng cho G5 vì G5
  không làm editor. Xem mục 5 cho quyết định polling.

## 4. Luồng màn hình

### 4.1 Task List
- Mặc định load `GET /tasks` với filter rỗng, sort `createdAt desc`.
- Thanh filter: status (TODO/IN_PROGRESS/IN_REVIEW/FINISHED/CANCELLED), type (POST/
  LIVESTREAM/SURVEY/EVENT_PLAN/PRESS_RECOMMENDATION), search (theo `name`/`description`),
  campaignId. Role-aware theo Q13: Creator/Manager/Client đều thấy cùng danh sách Task
  trong Workspace (server đã filter theo Workspace membership, không filter theo "chỉ Task
  của tôi" trừ khi user tự chọn filter đó trên UI, ví dụ "chỉ Task của tôi" như một filter
  tùy chọn — không phải default ẩn).
- Mỗi item: tên, type badge, status badge màu theo trạng thái, assignee avatar/tên,
  dueDate, campaign (nếu có). Tap → Task Detail.
- Pull-to-refresh + infinite scroll (Page-based, dùng `page`/`size` từ `TaskListQuery`).

### 4.2 Task Detail
- Header: tên, type, status badge, reviewStep (nếu IN_REVIEW, hiện "Đang chờ Manager" hoặc
  "Đang chờ Client").
- Block thông tin: description, dueDate, publishDate, assignee, campaign, inputReferences
  (link tham khảo).
- Block nội dung Post (nếu type=POST): đọc-chỉ xem, không sửa (xem mục 7).
- Action bar — hiện nút theo đúng `allowedActions` từ `TaskWorkflowResponse` /
  `TaskReviewResponse` của chính response vừa gọi (không hardcode rule ở client):
  - `canStart` → nút "Bắt đầu làm" → `POST /start`.
  - `canSubmit` → nút "Gửi duyệt" → `POST /submit`.
  - `canWithdraw` → nút "Thu hồi" → `POST /withdraw`.
  - `canApprove` → nút "Duyệt" → `POST /approve` (chỉ hiện nếu user hiện tại đúng vai trò
    của `reviewStep` hiện tại: MANAGER hoặc CLIENT).
  - `canReject` → nút "Từ chối" → mở dialog nhập `comment` bắt buộc → `POST /reject`.
- Tab "Bình luận" — xem mục 4.4.
- Tab "Lịch sử duyệt" — list từ `GET /approvals`, hiển thị action/step/actor/comment/
  timestamp từng round.

### 4.3 Kanban Board
- 4 cột cố định theo FR 3.6.9: TODO / IN_PROGRESS / IN_REVIEW / FINISHED (CANCELLED hiển thị
  riêng, không kéo thả — đây là trạng thái đóng, không có transition kéo-thả hợp lệ dẫn tới
  CANCELLED trong sơ đồ BA).
- Kéo card giữa cột **không tự do** — chỉ cho phép kéo đúng theo transition hợp lệ (mục 6):
  TODO→IN_PROGRESS (= hành động "start", chỉ Creator được giao), IN_PROGRESS→IN_REVIEW (=
  "submit", chỉ Creator được giao), IN_REVIEW→FINISHED (= "approve", chỉ Manager/Client hợp
  lệ theo reviewStep hiện tại), IN_REVIEW→IN_PROGRESS (= "reject", chỉ Manager/Client, yêu
  cầu nhập comment — kéo thả phải mở dialog reject-reason trước khi commit, không chuyển
  cột im lặng).
- Kéo không hợp lệ (ví dụ TODO→FINISHED trực tiếp, hoặc Client kéo khi đang reviewStep=
  MANAGER) → card bật lại vị trí cũ + toast lỗi, không gọi API.
- V1: 1 kiểu board (theo status, như trên). 2 kiểu board khác (ví dụ group theo assignee,
  hoặc theo type) là stretch nếu còn thời gian.

### 4.4 Comment Thread
- List comment cursor-based (`GET /comments?cursor&limit`), mới nhất trên cùng hoặc dưới
  cùng theo UX chat chuẩn.
- Compose box: text input + mention autocomplete (gọi `comment-members` khi gõ `@`) + nút
  đính kèm ảnh (camera/gallery picker tái dùng từ G2) tối đa 5 ảnh, mỗi ảnh ≤5MB, định dạng
  JPEG/PNG/WebP.
- Gửi: upload từng ảnh qua `comment-uploads` lấy `attachmentIds`, sinh `clientRequestId`
  (UUID) để optimistic-send + idempotent retry, rồi `POST /comments`.
- Comment vẫn khả dụng trên Task FINISHED/CANCELLED (theo BA 2026-10-14 "vẫn cho comment
  trên COMPLETED/CANCELLED") — không ẩn tab comment theo status.

## 5. State & cache

- TanStack Query key gốc: `['tasks', workspaceId, { page, size, sort, direction, status,
  type, search, campaignId }]` cho list; `['task', workspaceId, taskId, 'workflow']`,
  `['task', workspaceId, taskId, 'review']`, `['task', workspaceId, taskId, 'approvals']`,
  `['task', workspaceId, taskId, 'comments']` cho detail — invalidate theo taskId khi có
  mutation thành công.
- Optimistic update cho mọi transition (start/submit/approve/reject/withdraw): cập nhật
  status/allowedActions tạm trên cache trước khi server trả lời, rollback nếu lỗi — lỗi phổ
  biến nhất sẽ là 409 do `expectedRevision`/`expectedApprovalRound` lệch (người khác vừa
  đổi) → khi rollback phải refetch lại `workflow`+`review` để lấy revision mới nhất, không
  chỉ revert về giá trị cũ (giá trị cũ cũng đã stale).
- Kanban kéo-thả cũng là optimistic update trên cùng cache key với Task Detail (cùng
  `taskId`), để tránh lệch state giữa 2 view khi user chuyển qua lại List/Kanban/Detail.

**Câu hỏi mở về realtime (flag, chưa quyết định):** `TaskContentWebSocketController` chỉ
phục vụ sync nội dung Yjs editor (FR 3.6.10), không phát event đổi status/comment mới. Vậy
mobile có 2 lựa chọn cho live update Task status/comment:
1. Polling định kỳ (ví dụ `refetchInterval` 15–30s khi Task Detail đang mở, hoặc khi app vào
   foreground) — đơn giản, không cần backend mới.
2. Yêu cầu backend thêm WS topic mới riêng cho Task status/comment (việc này ngoài scope
   doc này, cần phối hợp module khác) — không có sẵn hôm nay.

Khuyến nghị: **chọn (1) polling nhẹ** cho V1 vì không cần đổi backend, đủ dùng cho nhu cầu
demo capstone; nâng cấp sang WS nếu sau này đo được polling không đủ real-time cho multi-
user review. Đây là quyết định kỹ thuật của doc này, cần xác nhận lại nếu team muốn WS
ngay từ đầu.

## 6. Business rules đặc biệt (Approval Sequence FR 3.6.9)

```text
TODO --Creator được giao bấm Bắt đầu--> IN_PROGRESS
IN_PROGRESS --lưu bài và Gửi duyệt--> IN_REVIEW / MANAGER
  Manager approve:
    requiresClientApproval=false --> FINISHED
    requiresClientApproval=true  --> IN_REVIEW / CLIENT
  Client active bất kỳ approve --> FINISHED
  Manager hoặc Client reject có lý do --> IN_PROGRESS
  Creator withdraw trước Manager decision --> IN_PROGRESS
```

- Chỉ Creator đang là assignee được bấm Start/Submit/Withdraw; Manager/Client không có các
  nút này (server đã gate qua `allowedActions`, mobile chỉ ẩn/hiện theo đó, không tự chặn
  thêm logic trùng).
- Approve/Reject chỉ hợp lệ với role khớp `reviewStep` hiện tại (MANAGER hoặc CLIENT) —
  "bất kỳ Client active nào" được approve, không cần gán Client cụ thể; quyết định hợp lệ
  đầu tiên thắng (nếu 2 Client cùng bấm approve gần như đồng thời, 1 trong 2 sẽ nhận lỗi
  409 do `expectedApprovalRound`/`expectedRevision` lệch — UI cần xử lý lỗi này rõ ràng,
  không phải lỗi hệ thống chung).
- Withdraw chỉ hợp lệ **trước** Manager decision — nếu đã ở reviewStep=CLIENT, Creator không
  còn withdraw được (đã qua Manager decision).
- Client xem TOÀN BỘ Task trong Workspace (Q13), không chỉ Task đang chờ Client duyệt —
  quan trọng cho Task List/Kanban không áp bộ lọc ẩn theo role.
- Reject bắt buộc có lý do (`comment`) theo yêu cầu BA, dù backend không ép `@NotBlank` —
  mobile UI validate client-side.
- FINISHED không tự động publish — mobile không hiện bất kỳ hành động "publish" nào ở G5.

## 7. Việc KHÔNG làm ở G5

- **Không làm Content Editor (Google-Docs-style) trên mobile.** FR 3.6.10 dùng vector-text
  + Yjs CRDT realtime qua WebSocket (`TaskContentWebSocketController`,
  `TaskController`/`/content/*` endpoints, `TaskPostController`). Đây là một trong những
  phần phức tạp nhất của web app (conflict resolution, cursor presence, version history).
  Làm lại trên mobile là effort rất lớn cho lợi ích nhỏ (viết content dài trên màn hình
  điện thoại không phải use case chính). **Quyết định phạm vi (judgment call, chưa được
  user xác nhận riêng):** G5 mobile chỉ đọc/xem nội dung Post ở dạng preview tĩnh trong Task
  Detail (nếu làm — xem câu hỏi mở mục 8), không mở editor, không nhận WS update content,
  không sửa field content. Việc viết/sửa content POST vẫn chỉ làm trên web.
- **Không làm Gantt Timeline View (FR 3.6.6) ở V1.** Gantt là view mật độ thông tin cao
  (nhiều Task, nhiều track thời gian cùng lúc, kéo-giãn thanh thời gian) — rất khó dùng tốt
  trên màn hình điện thoại (độ rộng màn hình nhỏ, thao tác kéo-giãn chính xác bằng ngón tay
  khó hơn chuột). **Quyết định phạm vi (judgment call, chưa được user xác nhận riêng):** đề
  xuất loại hẳn Gantt khỏi roadmap mobile (không chỉ lùi xuống stretch), vì kể cả khi có đủ
  thời gian, giá trị sử dụng thực tế trên mobile thấp so với List/Kanban. Nếu user cần
  Gantt trên mobile, cần yêu cầu rõ lại.
- Không làm UI "Identify Task Detail" / "Assign Task" (FR 3.6.1/3.6.2) — tạo Task mới, gán
  assignee lần đầu vẫn làm trên web; G5 mobile chỉ thực thi Task đã được gán.
- Không làm Calendar View (FR 3.6.5) trong V1 bắt buộc — để ở mức stretch, implement sau
  List+Kanban nếu còn thời gian trước deadline cuối tháng 11/2026.
- Không làm 2/3 kiểu Kanban board còn lại ở FR 3.6.7 — chỉ 1 kiểu (group theo status) bắt
  buộc ở V1.

## 8. Rủi ro / câu hỏi mở

1. **Realtime status/comment:** polling vs. yêu cầu thêm WS topic riêng (mục 5) — cần team
   xác nhận trước khi code, vì đổi sau sẽ tốn công refactor cache layer.
2. **Preview nội dung Post trong Task Detail:** có cần gọi `GET /tasks/{id}/post` để hiển
   thị nội dung đã viết (readonly) trong Task Detail không, hay chỉ hiện thông tin workflow
   (status/assignee/dueDate) và để user mở web nếu cần xem content? Ảnh hưởng scope —
   nếu cần, phải xác nhận `TaskPostResponse` shape (chưa đọc trong lượt này, cần đọc thêm
   nếu quyết định làm).
3. **Conflict UX khi `expectedRevision` lệch:** cần thiết kế rõ thông báo lỗi 409 thân
   thiện ("Task đã được cập nhật bởi người khác, đang tải lại...") thay vì lỗi generic,
   vì đây là tình huống dễ gặp trên mobile (nhiều người cùng xem/sửa 1 Task, mạng chậm hơn
   web).
4. **Gantt loại bỏ hoàn toàn hay chỉ lùi vô hạn:** quyết định ở mục 7 là judgment call của
   doc này, không phải xác nhận chính thức từ BA/stakeholder — cần user duyệt lại trước khi
   chốt vào implementation plan.
5. **5 loại TaskType nhưng chỉ POST có workflow nội dung tích hợp (`TaskPostController`)** —
   LIVESTREAM/SURVEY/EVENT_PLAN/PRESS_RECOMMENDATION theo BA "chỉ chuẩn bị contract, tích
   hợp nội dung theo chủ module sau" (05-content-task-workflow.md mục 4). Mobile G5 chỉ cần
   hiển thị các type này ở mức metadata chung (list/kanban/detail khung sườn), không có
   màn hình chuyên biệt (ví dụ Livestream script, Survey question builder) — khớp với việc
   các module đó chưa có API/UI riêng ngay cả trên web ở thời điểm đọc code này.

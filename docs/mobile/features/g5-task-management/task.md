# Task — G5 Task Management (Mobile)

> [spec.md](./spec.md)

## Task List (FR 3.6.4)

- [ ] `GET /tasks?page&size&sort&direction&status&type&search&campaignId` — filter UI: status/type/search/campaignId.
- [ ] Item hiển thị: tên, type badge, status badge màu, assignee avatar/tên, dueDate, campaign.
- [ ] Pull-to-refresh + infinite scroll (page-based).
- [ ] Client thấy TOÀN BỘ Task trong Workspace (Q13) — KHÔNG tự thêm filter ẩn theo role, chỉ filter UI chuẩn như Manager/Creator.

## Task Detail

- [ ] Gọi cả `GET /tasks/{id}/workflow` (metadata) + `GET /tasks/{id}/review` (action-gating) — show/hide nút theo `allowedActions` của chính response, không tự suy luận rule ở client.
- [ ] Header: tên, type, status badge, reviewStep (nếu IN_REVIEW: "Đang chờ Manager"/"Đang chờ Client").
- [ ] Block info: description, dueDate, publishDate, assignee, campaign, inputReferences.
- [ ] Tab "Lịch sử duyệt" — `GET /tasks/{id}/approvals?cursor&limit`.
- [ ] Preview nội dung Post (type=POST) — **chặn bởi mục 8 câu 2, chưa quyết định có làm không, đọc `TaskPostResponse` trước nếu làm**.

## Status transitions

- [ ] `canStart` → `POST /start` body `{expectedRevision}`.
- [ ] `canSubmit` → `POST /submit` body `{expectedRevision, expectedApprovalRound, expectedPostContentVersion}`.
- [ ] `canWithdraw` → `POST /withdraw` body `{expectedRevision, expectedApprovalRound}`.
- [ ] `canApprove` → `POST /approve` body `{expectedRevision, expectedApprovalRound, expectedStep, expectedPostContentVersion, comment?}` — chỉ hiện nếu role khớp `reviewStep` hiện tại.
- [ ] `canReject` → dialog nhập `comment` **bắt buộc ở UI** (DTO không `@NotBlank`) → `POST /reject` cùng shape approve.
- [ ] Optimistic update mọi transition — rollback + refetch `workflow`+`review` khi lỗi (không chỉ revert giá trị cũ, vì cũng đã stale).
- [ ] Xử lý 409 conflict (`expectedRevision`/`expectedApprovalRound` lệch) — thông báo thân thiện "Task đã được cập nhật, đang tải lại...", không lỗi generic (mục 8 câu 3).

## Kanban Board (FR 3.6.7, V1 — 1 kiểu board)

- [ ] 4 cột: TODO/IN_PROGRESS/IN_REVIEW/FINISHED (CANCELLED hiển thị riêng, không kéo thả).
- [ ] Kéo card chỉ cho phép theo transition hợp lệ: TODO→IN_PROGRESS (start, chỉ Creator), IN_PROGRESS→IN_REVIEW (submit, chỉ Creator), IN_REVIEW→FINISHED (approve, đúng role theo reviewStep), IN_REVIEW→IN_PROGRESS (reject — mở dialog nhập comment trước khi commit, không chuyển cột im lặng).
- [ ] Kéo không hợp lệ → card bật lại vị trí cũ + toast lỗi, không gọi API.
- [ ] Dùng cùng cache key với Task Detail (theo `taskId`) để tránh lệch state giữa List/Kanban/Detail.

## Comment Thread (FR 3.6.3)

- [ ] `GET /tasks/{id}/comments?cursor&limit` — list cursor-based.
- [ ] Compose box: text + mention autocomplete (`GET /comment-members?search`) + đính kèm ảnh (tối đa 5 ảnh, mỗi ảnh ≤5MB, JPEG/PNG/WebP — validate client trước khi gọi API).
- [ ] Upload ảnh qua `POST /comment-uploads` (multipart) lấy `attachmentIds` trước, rồi `POST /comments` với `clientRequestId` (UUID) cho optimistic-send + idempotent retry.
- [ ] Tái dùng UI picker camera/gallery đã làm ở G2 Creator Upload, chỉ đổi target endpoint.
- [ ] Render ảnh qua `GET /comment-uploads/{id}/content` trong `<Image>`, **không mở trong WebView** (response có `Content-Security-Policy: sandbox`).
- [ ] Comment vẫn khả dụng trên Task FINISHED/CANCELLED — không ẩn tab theo status.

## Realtime (quyết định đã chốt — polling, xem spec mục 5)

- [ ] `refetchInterval` 15-30s khi Task Detail đang mở hoặc app vào foreground — không có WS topic riêng cho status/comment, chỉ dùng polling nhẹ cho V1.

## Business rules cần enforce ở client (Approval Sequence FR 3.6.9)

- [ ] Chỉ Creator đang là assignee thấy nút Start/Submit/Withdraw.
- [ ] Approve/Reject chỉ hợp lệ role khớp `reviewStep` hiện tại.
- [ ] Withdraw chỉ hợp lệ trước Manager decision (không còn ở reviewStep=CLIENT).
- [ ] FINISHED không tự động publish — không hiện action "publish" nào ở G5.

## Stretch (cắt nếu thiếu thời gian)

- [ ] Calendar Task View (FR 3.6.5).
- [ ] 2 kiểu Kanban board còn lại (group theo assignee/type).

## Chưa làm / out of scope G5 (xem spec mục 7)

- [ ] Không làm: Content Editor (FR 3.6.10, Yjs realtime), Gantt Timeline View (FR 3.6.6 — loại hẳn, judgment call cần user duyệt lại), Identify Task Detail/Assign Task (FR 3.6.1/3.6.2).

## Rủi ro cần chốt trước khi code (xem spec mục 8)

1. Realtime polling vs WS topic riêng — xác nhận trước khi code, đổi sau tốn công refactor cache layer.
2. Preview nội dung Post trong Task Detail — quyết định có làm không, đọc `TaskPostResponse` nếu làm.
3. Conflict UX 409 — thiết kế rõ thông báo lỗi, tình huống dễ gặp trên mobile (nhiều người xem/sửa, mạng chậm).
4. Gantt loại bỏ hoàn toàn — judgment call của spec, cần user duyệt lại trước khi chốt implementation.
5. 5 loại TaskType chỉ POST có content workflow — LIVESTREAM/SURVEY/EVENT_PLAN/PRESS_RECOMMENDATION chỉ hiện metadata khung sườn, không màn hình chuyên biệt.

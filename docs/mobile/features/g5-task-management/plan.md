# Plan — G5 Task Management (Mobile)

> [spec.md](./spec.md) — chi tiết API/flows/business rules đầy đủ. File này là bản tóm tắt thứ tự implement + quyết định kỹ thuật chốt.

## Thứ tự implement (theo dependency)

1. **Task List** (FR 3.6.4) — list + filter + pull-to-refresh/infinite scroll. Nền tảng cho Detail/Kanban.
2. **Task Detail** — gọi cả `workflow` (metadata) và `review` (action-gating), `allowedActions` là nguồn chân lý cho show/hide nút, không tự suy luận rule ở client.
3. **Status transitions** (start/submit/withdraw/approve/reject) — optimistic update + xử lý 409 conflict.
4. **Kanban Board** (V1, 1 kiểu) — dùng cùng cache key với Task Detail để tránh lệch state.
5. **Comment Thread** (FR 3.6.3) — tái dùng picker camera/gallery đã làm ở G2.
6. **Realtime polling** — thêm cuối cùng, không chặn các phần khác.

## Quyết định kỹ thuật đã chốt

- **Nguồn dữ liệu đúng: `TaskDocument` (MongoDB) qua `TaskListItemResponse`/`TaskWorkflowResponse`/`TaskReviewResponse`** — KHÔNG dùng `TaskResponse` (map từ SQL `Task.java` tối giản, không có status/assignee/comment).
- **Client thấy TOÀN BỘ Task trong Workspace** (Q13, CONFIRMED) — không tự thêm filter ẩn theo role, kể cả Client. "Chỉ Task của tôi" là filter UI tùy chọn, không phải default ẩn.
- **Mọi optimistic-concurrency field** (`expectedRevision`/`expectedApprovalRound`/`expectedPostContentVersion`) phải gửi đúng giá trị đọc được từ response gần nhất — server reject nếu stale.
- **Reject bắt buộc có `comment` ở UI** dù DTO backend không `@NotBlank` — validate client-side theo yêu cầu BA.
- **Realtime: polling nhẹ (15-30s), KHÔNG dùng WebSocket** — `TaskContentWebSocketController` chỉ phục vụ Yjs content editor (ngoài scope G5), không phát event status/comment. Quyết định này **chưa chính thức xác nhận với team**, chỉ là khuyến nghị của spec — cần confirm trước khi code nếu muốn đổi sang WS ngay từ đầu.
- **Content Editor (FR 3.6.10) và Gantt View (FR 3.6.6) KHÔNG làm trên mobile** — Content Editor vì Yjs CRDT realtime quá phức tạp cho effort capstone; Gantt vì màn hình mật độ cao không phù hợp điện thoại. Cả 2 là judgment call của spec, **cần user/stakeholder duyệt lại** trước khi chốt vào implementation plan thật.

## Việc cần xác nhận trước khi code (chưa làm, xem spec mục 8)

- Realtime polling vs WS topic riêng — xác nhận trước khi code, đổi sau tốn công refactor cache layer.
- Preview nội dung Post (type=POST) trong Task Detail — quyết định có làm không, đọc `TaskPostResponse` nếu làm.
- Conflict UX 409 — thiết kế rõ thông báo lỗi, tình huống dễ gặp trên mobile (nhiều người xem/sửa cùng lúc, mạng chậm hơn web).

## Rủi ro còn mở

- Gantt loại bỏ hoàn toàn khỏi roadmap mobile là đề xuất riêng của spec, chưa phải quyết định chính thức từ BA/stakeholder.
- 5 loại TaskType (POST/LIVESTREAM/SURVEY/EVENT_PLAN/PRESS_RECOMMENDATION) chỉ POST có content workflow tích hợp — các type khác chỉ hiện metadata khung sườn trên mobile, khớp với việc các module đó chưa có API/UI riêng ngay cả trên web.

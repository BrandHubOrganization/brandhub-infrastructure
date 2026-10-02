# Plan — Realtime Workspace Chat

Liên kết: [spec.md](./spec.md)

## 1. Phạm vi kỹ thuật

- `brandhub-infrastructure`: Mongo migration cho `chat_messages`, tài liệu feature.
- `brandhub-business-service`: WebSocket/STOMP, JWT CONNECT interceptor, membership access service, Mongo repository, REST history/read API và outbound membership guard.
- `brandhub-api-gateway`: route WebSocket `/ws/chat/**` tới Business Service.
- `brandhub-web`: `@stomp/stompjs`, service/store/hooks/components, route chat, sidebar, i18n vi/en.

## 2. Data model

### `chat_messages`

- `_id`: ObjectId.
- `workspaceId`, `senderMemberId`, `senderUserId`: UUID string.
- `senderRole`, `senderDisplayName`: snapshot tại thời điểm gửi.
- `content`: plain text 1..4000.
- `contextType`: `GENERAL|MEDIA_PACKAGE|MEDIA_CAMPAIGN`.
- `contextId`: UUID string hoặc null.
- `clientMessageId`: UUID do client tạo.
- `createdAt`: BSON date.

Indexes:

- `{workspaceId: 1, createdAt: -1, _id: -1}`.
- unique `{workspaceId: 1, senderUserId: 1, clientMessageId: 1}`.
- `{workspaceId: 1, contextType: 1, contextId: 1, createdAt: -1}`.

### `chat_read_states`

- `workspaceId`, `userId`, `lastReadMessageId`, `lastReadAt`.
- unique `{workspaceId: 1, userId: 1}`.

## 3. API và realtime contract

- REST history dùng cursor Base64 chứa `createdAt|id`, trả `items`, `nextCursor`, `hasMore`.
- REST read state upsert theo `(workspaceId,userId)`.
- STOMP CONNECT gửi `Authorization: Bearer <accessToken>`.
- Inbound interceptor xác thực CONNECT; SUBSCRIBE/SEND phân tích Workspace ID từ destination và re-query active membership.
- Message controller lưu Mongo trước rồi publish `/topic/workspaces/{id}/chat`.
- `/user/queue/chat-errors` trả error code an toàn cho client.

## 4. Luồng xử lý

1. Frontend mở `/ws/chat`, xác thực ở STOMP CONNECT và subscribe topic Workspace.
2. Frontend tải history qua REST và merge theo message ID.
3. Khi gửi, UI thêm optimistic item với `clientMessageId`.
4. Backend xác thực member/context, kiểm tra rate limit Redis, lưu Mongo và publish canonical message.
5. Frontend nhận event, thay optimistic item và cập nhật read state.
6. Mỗi SEND/SUBSCRIBE và mỗi outbound chat message đều kiểm tra membership hiện tại; member đã remove/leave không tiếp tục gửi hoặc nhận dữ liệu.

## 5. Broker

- MVP dùng Spring simple broker vì topology hiện tại chỉ có một Business Service instance.
- Cấu hình giữ prefix chuẩn STOMP để có thể chuyển sang RabbitMQ broker relay khi scale nhiều instance.
- MongoDB luôn là source of truth; broker không giữ lịch sử.

## 6. UI

- Trang orchestrator `pages/chat/index.tsx` dưới 150 dòng.
- Component tách riêng: header, message list, bubble, context badge, composer, connection banner.
- Store chuẩn hóa theo message ID; tự reconnect có backoff; logout/workspace switch phải deactivate client.
- Thêm `src/i18n/locales/vi/chat.json`, `src/i18n/locales/en/chat.json` và đăng ký trong `src/i18n/index.ts`.
- Chỉ dùng semantic theme tokens và `dark:` khi cần; không hardcode raw color.

## 7. Rủi ro và kiểm soát

- Sửa `listMyWorkspaces`: trả vai trò membership active trước, chỉ fallback OWNER nếu user sở hữu Agency và không có membership; thêm regression test cho Owner kiêm Manager.
- Khi handshake qua Gateway trả 404 nhưng Business nhận `/ws/chat`, kiểm tra tiến trình Gateway đã nạp cấu hình mới; restart service local rồi kiểm tra HTTP 101 qua Gateway.

- Browser không gửi Bearer header ở handshake: xác thực trong STOMP CONNECT, không truyền token query string.
- Subscription có thể rò dữ liệu nếu chỉ bảo vệ SEND: interceptor bắt buộc kiểm tra cả SUBSCRIBE.
- Retry/reconnect gây duplicate: unique index + `clientMessageId`.
- Removed member còn subscription: outbound interceptor re-query membership trước khi chuyển từng chat message.
- WebSocket frame không đi qua HTTP rate limiter: giới hạn riêng bằng Redis trong message service.

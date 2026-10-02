# UC — Realtime Workspace Chat

| | |
|---|---|
| FR Code | 3.6.36 |
| Jira | DA-1007 / DA-E51-15 |
| Feature | Realtime Workspace Chat |
| Domain | Content & Workflow (FR 3.6) |
| Role | MANAGER, CREATOR, CLIENT |
| Version | 1.0 (2026-10-02) |
| Trạng thái tài liệu | Implemented — pending environment E2E |

## 1. Objective

Cung cấp một kênh trao đổi chung theo Workspace để các thành viên đang hoạt động trao đổi realtime, xem lại lịch sử và thảo luận có ngữ cảnh về Media Package hoặc Media Campaign.

## 2. User Story

Là một thành viên đang hoạt động trong Workspace, tôi muốn gửi và nhận tin nhắn ngay lập tức, để phối hợp công việc với Client, Manager và Creator mà không phải rời khỏi BrandHub.

## 3. Acceptance Criteria

- **AC-01:** Mỗi Workspace có một kênh chat chung; MANAGER, CREATOR và CLIENT đang hoạt động trong Workspace được gửi, nhận và xem lịch sử.
  - Xác nhận ngày 2026-10-02: Agency Owner có membership MANAGER trong Workspace được xử lý là MANAGER tại Workspace đó. `myRole` ưu tiên membership đang active; vai trò OWNER cấp Agency không ghi đè vai trò này.
- **AC-02:** Tin nhắn của thành viên online được chuyển realtime qua WebSocket; sau reconnect hoặc reload, lịch sử vẫn tải được từ server.
- **AC-03:** Tin nhắn được lưu trước khi phát realtime và có `clientMessageId` để retry không tạo bản ghi trùng.
- **AC-04:** Người không thuộc Workspace hoặc thành viên đã bị vô hiệu hóa không được subscribe, gửi hay đọc lịch sử; session đang mở của thành viên bị xóa phải mất quyền nhận dữ liệu tiếp theo.
- **AC-05:** Tin nhắn hỗ trợ ngữ cảnh `GENERAL`, `MEDIA_PACKAGE`, `MEDIA_CAMPAIGN`. Context package dùng `workspaceMediaPackageId`; context campaign dùng `mediaCampaignId`; server phải xác minh tài nguyên thuộc Workspace.
- **AC-06:** Nội dung là plain text sau khi trim, dài từ 1 đến 4.000 ký tự. Không render raw HTML.
- **AC-07:** Lịch sử phân trang bằng cursor, tối đa 50 tin/lần; UI mặc định tải 30 tin gần nhất và tải thêm khi cuộn lên.
- **AC-08:** Thành viên có thể đánh dấu tin cuối đã đọc; server cung cấp số tin chưa đọc, UI chat hiển thị trạng thái kết nối và trạng thái gửi.
- **AC-09:** UI responsive, hỗ trợ light/dark mode và toàn bộ text mới có key song song trong `vi/chat.json` và `en/chat.json`.

## 4. UI / UX

- Route: `/workspaces/:id/chat`.
- Bố cục quen thuộc với các ứng dụng chat phổ biến: header chứa tên Workspace và trạng thái kết nối; vùng tin nhắn cuộn độc lập; tin của bản thân căn phải, tin người khác căn trái; avatar/tên hiển thị theo cụm; ô soạn cố định dưới cùng.
- Message context hiển thị dạng chip/card nhỏ. Liên kết tới màn hình Media Package/Campaign sẽ được gắn sau khi route E50 được merge vào cùng branch.
- Phím `Enter` gửi; `Shift+Enter` xuống dòng. Nút gửi bị khóa khi rỗng, đang mất kết nối hoặc đang gửi.
- Mobile dùng toàn chiều rộng, vùng nhập không bị bottom navigation che khuất.

## 5. API Contract

```http
GET /api/v1/workspaces/{workspaceId}/chat/messages?before={cursor}&limit=30
PUT /api/v1/workspaces/{workspaceId}/chat/read

WebSocket endpoint: /ws/chat
SEND:      /app/workspaces/{workspaceId}/chat.send
SUBSCRIBE: /topic/workspaces/{workspaceId}/chat
ERROR:     /user/queue/chat-errors
```

Payload gửi:

```json
{
  "clientMessageId": "uuid",
  "content": "Nội dung trao đổi",
  "contextType": "GENERAL",
  "contextId": null
}
```

## 6. Error Handling

- JWT thiếu/hết hạn/blacklist tại STOMP CONNECT → từ chối kết nối.
- Không phải active Workspace member → `WORKSPACE_ACCESS_DENIED` và không subscribe/send/read.
- Nội dung không hợp lệ → `CHAT_MESSAGE_INVALID`.
- Context không tồn tại hoặc không thuộc Workspace → `CHAT_CONTEXT_INVALID`.
- Vượt rate limit → `CHAT_RATE_LIMIT_EXCEEDED`.
- MongoDB không lưu được → không phát tin realtime và trả lỗi cho sender.

## 7. Edge Cases

- Retry cùng `clientMessageId` trả lại tin đã lưu, không insert thêm.
- Hai tin cùng thời điểm được sắp xếp ổn định theo `createdAt` và `_id`.
- Reconnect subscribe trước rồi tải phần lịch sử còn thiếu; UI loại trùng theo `id`.
- Thành viên rời/bị xóa khỏi Workspace khi đang kết nối bị chặn ở cả inbound và outbound; socket có thể còn mở nhưng không gửi, nhận hoặc đọc dữ liệu chat tiếp theo.
- Tin nhắn tham chiếu tài nguyên sau đó bị xóa vẫn giữ nội dung lịch sử; context hiển thị là không còn khả dụng.

## 8. Definition of Done

- Realtime hoạt động giữa hai tài khoản cùng Workspace.
- Reload/reconnect vẫn xem được lịch sử và không tạo tin trùng.
- Cross-workspace và removed-member bị chặn ở REST lẫn WebSocket.
- UI responsive, vi/en và light/dark mode đạt yêu cầu.
- Backend unit tests và frontend lint/type-check/build pass; E2E hai tài khoản được thực hiện sau khi migration có mặt trên môi trường test.

## Out of Scope

- File/ảnh/video, emoji picker, reaction, edit/delete, reply thread, typing indicator, presence chi tiết và push notification khi offline.
- Nội dung chat không tự thay đổi trạng thái negotiation/approval của Media Package hoặc Media Campaign.

## Tham chiếu BA

- `docs/plan/brandhub-master-plan.md` — DA-E51-15.
- `docs/ba/05-content-task-workflow.md`.

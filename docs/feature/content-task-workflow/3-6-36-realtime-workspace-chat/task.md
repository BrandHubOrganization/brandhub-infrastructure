# Tasks — Realtime Workspace Chat

- [x] Sửa ưu tiên membership trong Workspace response và kiểm thử Owner kiêm Manager.
- [x] Xác minh handshake HTTP 101 qua Gateway sau khi nạp lại cấu hình local.

- [x] Chốt phạm vi và contract trong `spec.md`.
- [x] Thiết kế kỹ thuật trong `plan.md`.
- [x] Viết test cases trước khi code.
- [x] Tạo Mongo migration idempotent cho `chat_messages` và `chat_read_states`.
- [x] Thêm WebSocket dependency và cấu hình STOMP.
- [x] Tạo document, repository, DTO và cursor pagination.
- [x] Tạo `WorkspaceAccessService` dùng chung cho internal member và Client profile.
- [x] Implement REST history/read/unread endpoints.
- [x] Implement STOMP authentication, authorization, send/persist/publish và rate limit.
- [x] Chặn send/subscribe/delivery ngay khi member không còn active.
- [x] Thêm Gateway WebSocket route và allowed origins phù hợp.
- [x] Thêm `@stomp/stompjs`, chat service và hook trên frontend.
- [x] Tạo UI chat responsive theo BrandHub design system.
- [x] Thêm route/sidebar và context Media Package/Campaign.
- [x] Cập nhật `vi/chat.json`, `en/chat.json` và nav keys song song.
- [ ] Kiểm tra thủ công light/dark mode và responsive trên trình duyệt thật.
- [x] Viết/chạy backend unit tests cho service, membership và WebSocket security.
- [x] Chạy frontend lint, type-check và production build.
- [x] Cập nhật trạng thái test và checklist sau verify.
- [ ] Chạy E2E bằng hai tài khoản thật sau khi áp dụng Mongo migration lên môi trường test.

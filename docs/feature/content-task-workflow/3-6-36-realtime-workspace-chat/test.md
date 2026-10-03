# Tests — Realtime Workspace Chat

| ID | Mô tả | Kết quả mong đợi | Trạng thái |
|---|---|---|---|
| TC-01 | Hai active member cùng Workspace gửi/nhận text | Receiver nhận canonical message realtime | Chờ E2E |
| TC-02 | Reload rồi tải 30 tin gần nhất | Lịch sử đúng thứ tự, có cursor khi còn dữ liệu | Đạt một phần bằng unit test; chờ E2E Mongo |
| TC-03 | Retry cùng `clientMessageId` | Chỉ có một document, trả cùng message ID | Đạt — unit test |
| TC-04 | User không thuộc Workspace đọc/gửi chat | `WORKSPACE_ACCESS_DENIED` | Đạt — unit test access service |
| TC-05 | User subscribe topic Workspace khác hoặc destination lạ | Subscription bị từ chối | Đạt — interceptor unit test |
| TC-06 | Active member bị remove khi đang online | Không tiếp tục gửi hoặc nhận message | Đạt — outbound guard unit test; chờ E2E socket |
| TC-07 | Message gắn Workspace Media Package hợp lệ | Lưu và trả context đúng | Chờ integration test với dữ liệu E50 |
| TC-08 | Message gắn package/campaign thuộc Workspace khác | `CHAT_CONTEXT_INVALID` | Đạt — unit test package context |
| TC-09 | Content rỗng hoặc hơn 4.000 ký tự | `CHAT_MESSAGE_INVALID`, không lưu/publish | Đạt — validation và unit test nội dung rỗng |
| TC-10 | Tải trang trước bằng cursor | Không trùng/thiếu, thứ tự ổn định | Chờ integration test Mongo |
| TC-11 | Mark-read một message thuộc Workspace | Read state upsert và unread về 0 | Chờ integration test Mongo |
| TC-12 | Giao diện mất kết nối rồi reconnect | Trạng thái đúng, tải bù history và loại trùng | Đã implement; chờ E2E trình duyệt |
| TC-13 | Đổi ngôn ngữ vi/en | Toàn bộ text chat đổi và layout không vỡ | Type-check/build đạt; chờ kiểm tra UI |
| TC-14 | Light/dark và desktop/mobile | Contrast đúng, composer không bị che | Production build đạt; chờ kiểm tra UI |
| TC-15 | Vượt giới hạn gửi | `CHAT_RATE_LIMIT_EXCEEDED`, không insert | Đạt — unit test; chờ E2E Redis |

## Kết quả tự động

- Regression (đạt 2026-10-02): hai test `WorkspaceServiceTest#listMyWorkspaces_agencyOwner*` xác nhận Owner có membership MANAGER nhận `myRole=MANAGER`; Owner không có membership vẫn nhận `OWNER` và không tự được cấp chat. Membership/security tests cũng đạt.
- Runtime (đạt 2026-10-02): sau khi restart Gateway đã chạy cấu hình cũ, handshake với Origin `http://localhost:3000` qua cổng 8080 trả HTTP 101. STOMP CONNECT không có token nhận ERROR từ Business như mong đợi. Chưa kiểm thử gửi tin giữa hai tài khoản trong lần sửa này.

- Business Service: `ChatServiceImplTest`, `WorkspaceAccessServiceTest`, `ChatChannelInterceptorTest`, `ChatRateLimiterTest` — đạt.
- API Gateway: Maven compile — đạt.
- Web: TypeScript type-check — đạt; ESLint — 0 lỗi, 61 warning có sẵn trên toàn repository; Vite production build — đạt.
- Mongo migration: kiểm tra cú pháp JavaScript bằng `node --check` — đạt; chưa chạy trên Atlas/shared environment.


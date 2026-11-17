# Kịch bản kiểm thử phạm vi đã chốt

Đã chạy ngày 17/11/2026; kết quả và giới hạn dưới đây.

1. Submit caption/image/video trả 202 sau commit và hiện “Đã nhận yêu cầu”. Không bao gồm ambassador, RAG, trend.
2. Chuyển trang, refresh, đóng/mở tab → cùng job/result; logout/account khác không thấy job cũ.
3. Cùng key/input đồng thời → một job/reservation; khác input → conflict. Payload/context snapshot không thay theo workspace sau submit.
4. Job/reservation rollback cùng nhau. Worker restart trước dispatch phục hồi; paid call outcome unknown không dispatch lần hai.
5. Duplicate finalize/stale lease/notification → không overwrite hoặc lặp phí/inbox.
6. Video đối soát receipt đúng; output/history caption/video và credit giữ hành vi cũ.
7. Bấm toast/inbox/khay hoàn thành mở preview trực tiếp, giữ route/editor draft. Deep link sau reload cũng mở đúng.
8. Ảnh/video tái dùng viewer chat; zoom/rotate/play/seek/fullscreen và đóng bằng Escape; chat không có hai viewer.
9. Caption đọc/copy, không tự apply; result callback sau unmount không tác động editor khác.
10. Job mất quyền bị chặn đọc/dispatch; user khác đoán ID không truy cập. List không trả input/result.
11. Server chưa migration: API lỗi có kiểm soát, worker không làm hỏng startup hoặc endpoint cũ.
12. Poll single-flight, lỗi mạng không thành AI failure; không giả phần trăm; VI/EN/light/dark/mobile/bàn phím đúng.
13. Chạy CI Web + Business và regression phù hợp. Dùng provider fake và DB test cách ly cho fault tests, không gọi AI trả phí hoặc production trong test.

## Kết quả đã thực hiện

- PASS: 25 kiểm tra service/SQL trên schema PostgreSQL tạm: migration chạy lại, request key/reordered JSON/concurrency, atomic rollback reservation + job, claim/heartbeat/fencing, one terminal notification, cursor/list không có result/input, chặn khác actor và quyền bị thu hồi, UNKNOWN không dispatch lại, worker hoàn tất đúng output và xóa snapshot input lớn sau terminal. Schema tạm đã xóa.
- PASS: 25 test hồi quy tracked thuộc caption/video/context/moderation/request/product-video-content.
- PASS: 14 kiểm tra component thật trên Chrome, API giả lập: nhận yêu cầu, tác vụ xuất hiện ngay, đổi trang/refresh không submit lại, click toast/inbox mở preview giữ route/draft, ảnh lấy preview URL mới và dùng chat zoom, video viewer đơn tải/giải mã/phát được, caption mobile vừa viewport, logout xóa result, không pageerror.
- PASS: kiểm tra hình ảnh riêng ở theme light/dark và video playback; đã sửa toast che controls khi mở preview.
- PASS: npm run ci (lint/type-check/build), có cảnh báo sẵn có; compiler Business qua.
- CI Business toàn bộ: 1.989 test, 4 failures, 6 errors, 120 skipped. Chạy đúng các lớp lỗi trên HEAD c0b088f cách ly: 148 test, cùng 4 failures + 6 errors. So sánh tên test lỗi trùng 10/10. Những lỗi đó thuộc AgencyServiceImplTest, WorkspaceServiceTest, PostServiceImplTest, TaskServiceListTasksTest, MailTemplateSeederTest.
- Chưa kiểm thử gọi model/provider thật hoặc tải production; không phát sinh phí AI. Browser dùng API stub, integration dùng credit/provider stub và PostgreSQL thật. Không coi đây là E2E production.

Log, Java QA và screenshot nằm dưới keep-local-only của Web/Business, được Git ignore. Migration ứng dụng đã áp dụng trên PostgreSQL Docker local; production chưa thay đổi. Chưa khởi động lại Business trong lượt này.

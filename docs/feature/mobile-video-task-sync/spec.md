# Mobile video → Task sync — Spec

## Objective
Creator quay video hoặc chọn video/ảnh trên điện thoại; tệp tự lên task. Owner, Manager và Creator thấy tệp ngay trong chi tiết task trên web. Creator chọn take đưa vào bài nháp để Manager duyệt đúng clip.

Nền tảng: `docs/mobile/features/g2-creator-upload`.

## User stories
- Creator: quay xong không cần bấm gì thêm, mất mạng hay tắt app vẫn không mất tệp.
- Creator: chọn take tốt nhất đưa vào bài nháp, rồi tự bấm gửi duyệt.
- Manager/Owner: mở task trên web là xem được các take.

## Acceptance criteria
1. Sau khi quay/chọn tệp, upload tự chạy khi app đang mở, không cần bấm nút.
2. Mất mạng, lỗi tạm thời, hoặc tắt rồi mở lại app: hàng đợi tự chạy lại khi có mạng hoặc app active.
3. Có công tắc "Chỉ tải qua Wi-Fi", mặc định tắt.
4. Session hết hạn hoặc bị từ chối thì tạo session mới và upload lại, không kẹt ở confirm. Lỗi vĩnh viễn (định dạng, quyền) hiện rõ, không tự thử lại.
5. Có % tiến độ; lỗi hiện đúng thông điệp backend.
6. Không tự gửi duyệt. Nút gửi duyệt giữ nguyên ở chi tiết task.
7. Task chưa có bài nháp vẫn upload được; giao diện báo "chưa có bài nháp".
8. Ảnh JPEG/PNG/WebP upload được vào task; HEIC đổi sang JPEG trên app.
9. File `.mov` (`video/quicktime`) và MP4 brand `isom`/`mp42` đều qua validate.
10. Web: chi tiết task có khu "Tệp từ điện thoại", tự làm mới, xem trước được. Client không thấy take thô.
11. Creator được giao đưa một take vào bài nháp, trên web và mobile. Trước khi task vào duyệt, Client nhận `url: null` cho take nội bộ tại `GET /tasks/{id}/post`, và `POST_NOT_FOUND` tại `GET /posts/{id}` như quy tắc bài chưa đăng hiện có. Từ khi vào duyệt, Client nhận được URL.
12. Màn quay dùng VisionCamera: FPS, chất lượng, chống rung, bù phơi sáng, đèn, zoom là thật. Shutter (khóa phơi sáng) và white balance (khóa theo nhiệt độ màu) là thật và chỉ hiện trên máy báo hỗ trợ. Kính lọc ND, focus peaking, zebra, thước thủy và thanh âm thanh giả bị bỏ. Không tự dừng theo mục tiêu thời lượng.
13. Màn quay theo kiểu máy quay chuyên nghiệp (tham chiếu Blackmagic Camera, Sony, Canon): khung máy đen không đè lên hình; dải thông số FPS, Shutter, ISO, WB, Tint, EV luôn hiện, chạm một ô mở dải giá trị của ô đó; ISO và shutter ở chế độ tự động hiện giá trị đọc trực tiếp từ camera. Cột công cụ có đèn, chống rung, lưới, khung, kịch bản, menu; có lấy nét tay và chạm để lấy nét trên máy hỗ trợ. Khi đang quay chỉ đổi được zoom, lấy nét, đèn và kịch bản; có viền tally đỏ. Chỉ hiện điều khiển có tác dụng thật.
14. Quay xong ở lại camera để quay take tiếp, giữ nguyên cài đặt; số take nối tiếp theo cảnh và hiện trạng thái tải lên của take vừa quay.
15. Vuốt back và nút back Android không thoát được khi đang quay.
16. Xoá tệp chưa lên Task phải xác nhận. Từ chối quyền thì có nút Mở Cài đặt.
17. Khu take trên mobile mở xem được từng tệp, đặt tên theo cảnh và take, bỏ được tệp khỏi bài ngay tại chỗ, phân biệt lỗi tải với chưa có tệp.
18. Android: đồng hồ âm thanh đọc mức thu thật theo dB; danh sách micro đang kết nối và micro hệ thống đang thu. Không có nút chọn micro vì không có tác dụng thật.
19. Công cụ đo sáng histogram và zebra đọc từ khung hình thật, chỉ chạy khi bật. Zebra đánh dấu vùng cháy sáng theo ô.

## API contract
- `GET /workspaces/{id}/materials?taskId=`: lọc theo task. Client vẫn chỉ thấy `CLIENT` visibility.
- `POST .../materials/upload-session`: TASK nhận thêm ảnh; `clientRequestId` làm khóa idempotent; TTL 3600s.
- `POST /workspaces/{id}/tasks/{taskId}/post`: đã có, dùng để thêm `media[].materialId`. Response trả lại `media[].materialId`.

## Error handling
| Mã | Xử lý trên mobile |
|---|---|
| `UPLOAD_SESSION_EXPIRED`, `UPLOAD_SESSION_NOT_FOUND`, `UPLOAD_OBJECT_NOT_FOUND` | Xóa `s3Key`, upload lại với `clientRequestId` mới |
| `TASK_NOT_ASSIGNED`, `TASK_NOT_ACTIVE`, `TASK_NOT_FOUND_FOR_UPLOAD`, `INVALID_UPLOAD_CONTENT_TYPE`, `UPLOAD_FILE_TOO_LARGE`, `VALIDATION_ERROR` | `FAILED`, không tự thử lại |
| Mạng, 5xx, khác | `FAILED`, tự thử lại khi có sự kiện mạng/active, tối đa 5 lần |

## Edge cases
- Tắt app giữa upload: mục `UPLOADING`/`CONFIRMING` về `QUEUED` khi khởi động.
- Bài đủ 10 media hoặc take đã có trong bài: báo, không gọi API.
- Task không phải `IN_PROGRESS` hoặc đã khóa: ẩn nút đưa vào bài theo `canEdit`.
- Chạy trên Expo Go hoặc web: màn quay báo cần dev build, vẫn chọn tệp từ thư viện được.

## UI states
Mobile: đang chờ, đang tải %, đang xác nhận, xong, lỗi (có nút thử lại). Web: đang tải, rỗng, lỗi, danh sách.

### i18n
Web thêm key `tasks.phoneMedia.*` vào cả `vi` và `en`. Mobile có `i18n/translations` nhưng các màn upload và camera đang dùng chuỗi tiếng Việt trực tiếp; tính năng này giữ nguyên cách đó, chuyển sang key là việc riêng.

### Light/Dark
Web dùng token theme sẵn có. Các màn của luồng này dùng palette theo theme đang bật (`useAppPreferences`, `ThemedButton`, `ThemedBadge`); màn quay giữ nền tối cố định.

## Definition of done
Test tự động pass ở cả 3 repo; luồng API thật pass trên môi trường Docker riêng; checklist thiết bị trong `test.md` do người dùng xác nhận.

## Out of scope
Upload khi app ở nền; FPS/shutter ngoài khả năng phần cứng; kính lọc ND. Để giai đoạn sau: focus peaking; chọn thủ công micro ghi (VisionCamera không có API, cần thu âm riêng rồi ghép); đồng hồ âm thanh trên iOS.

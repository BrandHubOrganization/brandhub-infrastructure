# Mobile video → Task sync — Test

## Tự động
| # | Kiểm tra | Mong đợi |
|---|---|---|
| A1 | Validator: `isom`, `mp42`, `qt` khai `video/mp4` hoặc `video/quicktime` | Qua |
| A2 | Policy: JPEG vào TASK | Qua; PDF vào TASK bị từ chối |
| A3 | `GET materials?taskId=` | Chỉ trả tệp của task; Client không thấy INTERNAL |
| A4 | Client đọc bài có media INTERNAL đã ghim | Có URL |
| A5 | Pipeline: session hết hạn | Upload lại, thành công |
| A6 | Pipeline: `TASK_NOT_ASSIGNED` | `FAILED`, không thử lại |
| A7 | Khởi động với mục `UPLOADING` | Về `QUEUED` |
| A8 | Chỉ Wi-Fi trên 4G | Không chạy; có Wi-Fi thì chạy |
| A9 | Web: danh sách, rỗng, đưa vào bài | Đúng trạng thái và payload |

## API thật (Docker riêng: Postgres, Mongo replica set, MinIO)
| # | Bước | Mong đợi |
|---|---|---|
| B1 | Creator tạo session, PUT file `.mov`, confirm | Material `READY`, có `taskId` |
| B2 | Như B1 với MP4 `isom` và JPEG | `READY` |
| B3 | `GET materials?taskId=` bằng Manager | Thấy tệp; Client không thấy |
| B4 | Lưu bài với `materialId`, gửi duyệt | Bài có media; task `IN_REVIEW` |
| B5 | Web mở task | Thấy tệp, xem trước, chuyển ngôn ngữ và theme không vỡ |

## Thiết bị (người dùng xác nhận, dev build)
| # | Bước | Mong đợi |
|---|---|---|
| C1 | iPhone quay clip | Tự upload, web thấy trong khoảng 15s |
| C2 | Android quay clip | Như C1 |
| C3 | Bật máy bay giữa upload, tắt lại | Tự tiếp tục |
| C4 | Tắt app giữa upload, mở lại | Tự tiếp tục |
| C5 | Đổi FPS 24/30/60 | Metadata file đúng FPS |
| C6 | Ảnh HEIC trên iPhone | Lên task dạng JPEG |
| C7 | Quay quá mục tiêu thời lượng | Không tự dừng |
| C8 | Quay 3 take liên tiếp | Ở lại camera, giữ cài đặt, số take tăng 01, 02, 03 |
| C9 | Đang quay thì vuốt back (iPhone) và bấm back (Android) | Không thoát, clip vẫn lưu khi dừng |
| C10 | So khung trên màn với file đã quay | Video không bị cắt thêm, khung canh đúng vị trí |
| C11 | Từ chối quyền camera, mở lại màn quay | Có nút Mở Cài đặt, bật quyền xong quay được |
| C12 | Chạm một take trong chi tiết Task | Mở được video bằng trình phát của máy |
| C13 | Bật dark mode, đi hết luồng | Không còn nền sáng lẫn vào, chữ đọc rõ |

## Kết quả chạy emulator (2026-11-02)
Pixel_9a, Android 17 (API 37), camera ảo, debug build, stack e2e riêng. Chưa thay thế xác nhận trên máy thật.

| # | Kết quả | Ghi chú |
|---|---|---|
| C2 | Đạt một phần | Quay, tự tải lên, material `READY`, đúng dung lượng. Chưa kiểm tra phía web |
| C4 | Đạt một phần | Đưa app ra nền rồi mở lại: hàng đợi chạy tiếp và thử lại được. Chưa tắt app giữa lúc upload |
| C8 | Đạt | Ở lại camera, số take tăng 01 → 04. Chưa kiểm tra giữ cài đặt |
| C9 | Đạt phần Android | Nút back bị chặn, có cảnh báo. Chưa thử iPhone |
| C10 | Có vấn đề | File 720x1280 (9:16) nhưng preview 4:3; chọn 1080p ra 720p. Cần xác nhận trên máy thật |
| C1, C3, C5, C6, C7, C11, C12, C13 | Chưa chạy | Xem lượt chạy lại bên dưới |

## Kết quả chạy lại trên emulator (2026-11-02, sau khi sửa UI)
Pixel_9a, debug build + Metro, stack e2e riêng. Vẫn chưa thay thế xác nhận trên máy thật.

| # | Kết quả | Ghi chú |
|---|---|---|
| C3 | Đạt | Cắt mạng lúc `UPLOADING`: take thành `FAILED`, có mạng lại tự tải tiếp đến `SYNCED` sau 9 giây |
| C4 | Đạt | Tắt app lúc `UPLOADING`, mở lại thì tự tải tiếp đến `SYNCED`. Tắt app ngay sau khi dừng quay, trước khi clip vào hàng đợi, thì mất clip đó |
| C7 | Đạt | Mục tiêu 15 giây, quay quá 30 giây, timer đổi màu, không tự dừng |
| C10 | Đạt phần khung trên emulator | Preview đã cắt theo tỉ lệ file, khung canh nằm trong hình, nhãn hiện đúng 720p. Cần so với file trên máy thật |
| C11 | Đạt phần emulator | Từ chối quyền thì có Mở Cài đặt. Cấp lại bằng `pm grant` thì quay được, chưa đi qua màn Cài đặt |
| C12 | Đạt trên Android | Mở bằng trình xem video của máy (Google Photos trên emulator). iOS chưa kiểm tra |
| C13 | Đạt phần đã xem | Home, Chi tiết Task, Tải tệp, màn quay ở theme tối của app. Công tắc theme xoay vòng sáng, tối, theo hệ thống |
| Histogram | Đạt | Góc phải trên của khung, không bị ngăn kéo và thẻ kịch bản che |
| Zebra | Đạt phần vị trí | Đã sửa lỗi lệch 180°. Kiểm tra bằng ngưỡng tạm 150 vì cảnh ảo không chạm 235 |
| EV +2 | Không kiểm chứng được | Giá trị đổi, nhưng hình và histogram của camera ảo gần như không đổi |
| Kim dB | Không kiểm chứng được | Luôn -60 dB dù bật `-allow-host-audio` và phát tiếng ra loa. Track âm thanh của file cũng gần như im lặng (khoảng 102 byte mỗi frame AAC), nên nghi mic ảo không nhận tiếng. Cần thử có tiếng thật trên máy thật |
| Motion | Đạt trên Expo Web, chưa kiểm tra lại trên Android | Khung 412x915: skeleton, nội dung hiện dần, tab drawer trồi nhẹ, thanh tab trượt, Reduce Motion bỏ dịch chuyển. Đổi 10 lần tab drawer với CPU chậm 6 lần không có màn trống. Emulator từng có 1 lần màn trống sau khi mở app, chưa tái hiện được (13 lần mở lại đều đạt); đã bỏ native driver ở 2 animation có thể che cả màn, cần xác nhận trên Android |
| C1, C5, C6 | Chưa chạy | Cần iPhone, kiểm tra metadata file hoặc ảnh HEIC |

## Kết quả trên Expo Web (dark mode và ngôn ngữ)
Khung 412x915, stack e2e riêng, vai trò Creator và Admin. Bộ dò tự động đo vùng nền sáng lớn, độ tương phản chữ/nền và chữ tiếng Việt còn sót trên phần đang hiển thị của mỗi màn. Chưa kiểm tra trên Android.

| Mục | Kết quả | Ghi chú |
|---|---|---|
| Dark mode, các tab và menu More của Creator | Đạt | 19 màn không còn vùng nền sáng lớn. Lỗi tương phản ở nút Lịch sử màn Tạo video AI đã sửa ở Button dùng chung |
| Dark mode, 8 màn chính của Admin | Đạt | Màn con, form và hộp thoại chỉ được chuyển bằng script, chưa mở hết để xem |
| Tiếng Anh, 19 màn của Creator | Đạt | Chỉ còn tên ngôn ngữ "Tiếng Việt" ở ô chọn, là đúng. Nội dung do backend trả về vẫn giữ nguyên ngôn ngữ gốc |
| Đổi ngôn ngữ trong phiên | Đạt | Cập nhật ngay, app quay về màn đầu của luồng |
| Đăng nhập Google | Đạt một phần | Google nhận client_id và redirect_uri, tới trang đăng nhập. Chưa đăng nhập hết luồng nên client secret chưa được kiểm chứng |

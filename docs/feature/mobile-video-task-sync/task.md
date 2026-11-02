# Mobile video → Task sync — Tasks

## Backend
- [x] Lọc material theo `taskId`, có test
- [x] Cho ảnh vào TASK, có test
- [x] Validator nhận `isom`/`mp42`/`qt`, có test
- [x] TTL TASK 3600s
- [x] Client đọc được media đã ghim trong bài từ khi task vào duyệt, có test
- [x] Response bài đăng trả `materialId`

## Web
- [x] `taskId` trong `MaterialFilters`
- [x] Khu tệp từ điện thoại, polling, xem trước
- [x] Đưa take vào bài nháp
- [x] Cập nhật `vi` + `en`
- [x] Kiểm tra light/dark mode

## Mobile
- [x] Sửa `uploadService`: `clientRequestId`, MIME thật
- [x] Viết lại `mediaSyncService`, có test
- [x] Runner tự chạy theo mạng/app, công tắc Wi-Fi
- [x] Rút gọn `UploadScreen`, bỏ tự gửi duyệt
- [x] `TaskUploadScreen`, `MediaLibraryScreen`, HEIC
- [x] `TaskDetailScreen`: nút quay, danh sách take, đưa vào bài
- [x] Chuyển `CameraRecordScreen` sang VisionCamera
- [x] Editor mobile giữ media có sẵn của bài khi lưu
- [x] Gọn màn quay, bảng Cài đặt, khung theo khung hình thật
- [x] Quay nhiều take liên tục, số take nối tiếp
- [x] Chặn thoát khi đang quay, xác nhận trước khi xoá, Mở Cài đặt khi bị từ chối quyền
- [x] Khu take: xem tệp, tên theo take, bỏ khỏi bài, trạng thái lỗi
- [x] Dark mode cho các màn của luồng
- [x] Màn quay kiểu máy quay chuyên nghiệp: dải FPS/Shutter/ISO/WB/Tint/EV, cột công cụ, lấy nét tay, tally
- [ ] Xác nhận trên máy thật: ISO và shutter trực tiếp, khoá ISO/shutter/WB, lấy nét tay, đèn
- [x] Đồng hồ âm thanh và danh sách micro trên Android (module `brandhub-audio`)
- [x] Histogram và zebra từ khung hình thật (cần gói `react-native-vision-camera-worklets`)
- [ ] Xác nhận trên máy thật: mức dB khi có tiếng, micro USB và Bluetooth có được ghi vào file không
- [ ] Giai đoạn sau: focus peaking, chọn thủ công micro ghi, đồng hồ âm thanh trên iOS

## Kiểm chứng
- [x] Test tự động 3 repo
- [x] Luồng API thật trên Docker riêng (test.md mục B)
- [x] Build native có VisionCamera trên Android (debug, emulator)
- [ ] Build native có VisionCamera trên iOS
- [ ] Checklist thiết bị (test.md mục C)

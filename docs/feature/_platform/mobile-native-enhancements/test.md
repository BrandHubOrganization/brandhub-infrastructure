# Kịch bản kiểm chứng

Trạng thái ngày 2026-11-04, trên emulator Android Pixel_6. Chưa chạy trên iOS hay thiết bị thật.

| Mã | Kịch bản | Mong đợi | Kết quả |
|---|---|---|---|
| AC-L2 | Máy chưa đặt khoá, bật Khoá ứng dụng | Báo cần đặt khoá, công tắc vẫn tắt | Đạt (emulator) |
| AC-L1 | Đặt PIN, bật khoá, nhập PIN | Công tắc bật | Đạt (emulator) |
| AC-L1 | Tắt khoá, nhập PIN | Công tắc tắt | Đạt (emulator) |
| AC-L3 | Rời app 65 giây rồi quay lại | Hiện màn khoá | Đạt (emulator) |
| AC-L3 | Đồng hồ chỉnh lùi, dưới 60 giây | Logic trả về khoá | Đạt (jest) |
| AC-L4 | Huỷ hộp xác minh | Vẫn khoá, báo thử lại | Đạt (emulator) |
| AC-L5 | Máy không còn khoá màn hình lúc đang khoá | Chỉ còn Đăng xuất | Chưa chạy |
| AC-L6 | Bấm Back khi đang khoá | Màn phía sau đứng yên | Đạt (emulator) |
| AC-L6 | Bật TalkBack khi đang khoá | Không đọc màn phía sau | Chưa chạy |
| AC-L7 | Mở khoá xong | Về đúng màn Cài đặt | Đạt (emulator) |
| AC-R1 | Bật nhắc hạn | Được cấp quyền, công tắc bật | Đạt (emulator) |
| AC-R1 | Từ chối quyền | Không bật, có nút mở Cài đặt | Chưa chạy |
| AC-R2, R3 | Mốc nhắc, bỏ mốc đã qua, hạn sai, giới hạn 40 | Đúng | Đạt (jest) |
| AC-R2 | Thông báo nổ thật | Hiện đúng giờ | Chưa chạy: DB test không có Task |
| AC-R4, R5 | Task đổi, tắt tính năng, đăng xuất | Lịch được thay hoặc huỷ | Chưa chạy |
| AC-R6 | Chạm thông báo | Mở đúng Task | Chưa chạy |
| AC-O1 | Tắt mạng | Hiện dòng báo, tự ẩn khi có mạng | Chưa chạy |
| AC-H1 | Rung khi bấm | Có phản hồi | Chưa kiểm được: emulator không rung |
| AC-D1 | Thống kê theo trạng thái và tháng, qua năm mới | Đúng | Đạt (jest) |
| AC-D2 | Workspace không có Task | Hiện câu báo | Đạt (emulator) |
| AC-D1 | Biểu đồ với Task thật | Vẽ đúng | Chưa chạy: DB test không có Task |
| AC-I1 | Mọi chuỗi `tr()` có trong `en.json` | Không thiếu | Đạt (script) |
| AC-T1 | Dark mode trên màn mới | Không vỡ màu | Chưa chạy |

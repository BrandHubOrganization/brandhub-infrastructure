# Test — G2 Creator Upload (Mobile)

> [plan.md](./plan.md) | [task.md](./task.md)

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Quay video mới từ camera | Flow 4 bước "Quay video" | Mở camera, ghi ra file local trong cache dir | Chưa test |
| TC-02 | Chọn video từ thư viện | Flow 4 bước "Chọn từ thư viện" | Picker chỉ hiện video (`mediaTypes: Videos`) | Chưa test |
| TC-03 | Upload thành công bình thường | Mục 4, happy path | Progress bar chạy tới 100%, confirm xong, Material record tạo với `type=RAW` | Chưa test |
| TC-04 | Mất mạng giữa upload | Mục 5/6 resilience | Auto retry 3 lần (backoff 2s/5s/10s), giữ nguyên file local | Chưa test |
| TC-05 | Hết 3 lần auto-retry vẫn lỗi | Mục 5 | Hiện nút "Thử lại" thủ công, không mất file đã quay/chọn | Chưa test |
| TC-06 | Presigned URL hết hạn giữa khi upload | Mục 6, TTL 15 phút | PUT trả 403 → client tự gọi lại `upload-session` lấy key mới → PUT lại từ đầu | Chưa test |
| TC-07 | Confirm gọi 2 lần (double-tap hoặc retry) | Mục 6, idempotent theo s3Key | Không tạo Material trùng, trả lại record đã có | Chưa test |
| TC-08 | Task không giao cho Creator này | Mục 6 | 403 `TASK_NOT_ASSIGNED` ở cả `upload-session` và `confirm` | Chưa test |
| TC-09 | Task đã FINISHED/CANCELLED | Mục 6 | 409 `TASK_NOT_ACTIVE` ở cả 2 bước | Chưa test |
| TC-10 | PUT xong nhưng app bị đóng trước khi confirm | Mục 6 | Mở lại app, hiển thị trạng thái "đang chờ xác nhận", cho gọi lại confirm trực tiếp không PUT lại | Chưa test |
| TC-11 | App bị minimize/kill giữa khi đang upload | Mục 4 bước 4, giới hạn Expo managed | Upload dừng, không có background transfer; mở lại app phải tự resume/restart | Chưa test |
| TC-12 | File vượt quá giới hạn dung lượng (khi backend đã chốt số) | Mục 8 câu 1 | Validate ở `upload-session`, không cấp presigned URL cho file quá lớn | Chưa test |
| TC-13 | Content-Type không hợp lệ (không phải video/mp4, video/quicktime) | Mục 3.1 whitelist | Backend từ chối ngay ở `upload-session`, không cấp URL | Chưa test |
| TC-14 | Upload xong, Material xuất hiện đúng trong list Material của Task/Workspace | Mục 4 bước 3 | Material Repository (G2 liên kết) hiển thị record mới với `taskId` đúng | Chưa test |

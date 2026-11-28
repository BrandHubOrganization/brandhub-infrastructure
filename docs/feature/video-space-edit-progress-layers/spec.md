# Video Space: tiến trình dựng + tự đưa lớp lên timeline — spec

## Objective
1. Khi Claude dựng xong, kết quả hiện ngay trên timeline thành các lớp (clip đã cắt, chữ, âm thanh) để người dùng chỉnh tiếp, không phải bấm nút.
2. Khi Claude đang dựng, khung chat hiện tiến trình rõ ràng, đẹp: đang ở bước nào, đã làm gì, chạy bao lâu.

## User story
Là người dựng video, tôi muốn thấy AI đang làm tới đâu và khi xong thì có ngay các lớp trên timeline để sửa tay.

## Acceptance criteria
- AC1: Lượt dựng chuyển sang COMPLETED trong lúc người dùng đang mở dự án, có `plan.editable = true` → tự nhập các lớp vào timeline đúng 1 lần, lưu lên máy chủ, hiện thông báo "Đã đưa các lớp lên timeline" + Ctrl+Z để hoàn tác.
- AC2: Lượt cũ (đã xong trước khi mở trang) KHÔNG tự nhập lại; vẫn có nút "Áp dụng vào timeline".
- AC3: Lượt chỉ có MP4 (`editable = false`) không tự nhập; hiện rõ "Bản này chỉ có MP4 liền" như hiện tại.
- AC4: Thẻ tiến trình có: tiêu đề, đồng hồ thời gian đã chạy (mm:ss, tính từ `created_at`), thanh tiến độ, 4 bước (Nhận yêu cầu → Dựng & chỉnh → Xuất & kiểm tra → Lưu video) với trạng thái xong/đang làm/chờ, danh sách các việc Claude báo (TIEN_DO, 5 dòng mới nhất, dòng mới nhất nổi bật).
- AC5: i18n: chuỗi mới nằm trong `autoEditChatMessages` (vi + en, key song song) của package `vendor/video-space` (package này có bộ message riêng, không dùng `src/i18n`).
- AC6: Light/Dark: chỉ dùng biến theme (`--primary`, `--muted-foreground`, `--border`, `--secondary`), không hex cố định.
- AC7: `prefers-reduced-motion` tắt animation.

## UI states
QUEUED/analyzing → bước 1 đang làm · planning → bước 2 (kèm ghi chú) · rendering/qc → bước 3 · uploading → bước 4 · RECONCILIATION_REQUIRED → thông báo kiểm tra lại · FAILED → báo lỗi như cũ.

## Out of scope
Sửa backend xuất TIMELINE.json; thanh % chính xác theo thời gian thật (chỉ ước lượng theo bước).

# Checklist thực thi

- [x] Tạo migration durable job queue, unique keys, lease/fencing và index.
- [x] Tách prepare/finish caption và video, giữ sync behavior.
- [x] Admission/API worker + atomic credit + notification + safe recovery.
- [x] Store/poll manager global và adapters chỉ caption/image/video.
- [x] Bấm notification/khay mở preview, tái dùng chat media lightbox.
- [x] Cập nhật vi.json + en.json theo namespace common.json song song.
- [x] Kiểm tra light/dark, bàn phím, mobile, không overwrite editor.
- [x] Kiểm thử durable queue/faults, chạy CI Web và Business; không thêm test dưới src hoặc commit local-only.

## Kết quả 17/11/2026

Đã triển khai và kiểm thử local. Migration PostgreSQL Docker local đã chạy (chỉ bổ sung bảng/index, chưa có job ứng dụng). Business cần khởi động lại để nạp controller/worker mới.

Web CI qua. Business: compile và 25 test hồi quy liên quan qua; CI toàn bộ có 4 failures + 6 errors, tái hiện đúng cùng 10 test trên checkout HEAD cách ly. Không sửa phần Agency/Workspace/Task/Post/mail template ngoài phạm vi.
25 kiểm tra integration PostgreSQL cách ly và 14 kiểm tra browser giả lập qua; đã kiểm tra ảnh light, video dark phát/giải mã thật, caption mobile dark. Không gọi provider AI trả phí.

# Test — FR 3.6.3 / DA-1236

Các case ứng dụng chưa test giai đoạn 1; AC theo [spec](spec.md) §3/6/7.

| ID | Input/điều kiện | AC | Mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| C01 | Manager/Creator/Client có quyền Task gửi text/link | Bình luận/timeline | Author snapshot server, thứ tự/cursor đúng | Happy | Chưa test |
| C02 | COMPLETED/CANCELLED hoặc Campaign completed | Terminal comment | Gửi mới được, không đổi state/round/Campaign | Edge | Chưa test |
| C03 | Client xem/bình luận Task thủ công requiresClientApproval=false hoặc true | Q13/Edge §7 | Cả hai đều được, nếu còn active cùng WS | Happy | Chưa test |
| C04 | Client đọc/gửi comment và xem ảnh ATTACHED trên Task cũ thiếu revision/start | Q13/legacy | Được theo membership; không tự sửa state/marker; DRAFT người khác vẫn bị chặn | Edge | Chưa test |
| C05 | Gỡ membership sau từng tham gia | Edge §7 | Chặn đọc/gửi/ảnh và delivery mới | Error | Chưa test |
| C06 | Mention assignee/QC/Managers/tác giả/Client | Recipients | Dedup, bỏ tác giả, Client chỉ mentioned | Happy | Chưa test |
| C07 | Mention wrong WS/inactive/no Task access | Mention ACL | Từ chối, không lộ tên/no delivery | Error | Chưa test |
| C08 | 5 JPEG/PNG/WebP mỗi ảnh đúng 5MB | Ảnh BA | Nhận, private, bind đúng một comment | Happy | Chưa test |
| C09 | 6 ảnh, >5MB, MIME giả, corrupt, arbitrary URL | Ảnh thực/ownership | Field errors, không lưu comment nửa chừng | Error | Chưa test |
| C10 | Upload người khác/Task khác/ATTACHED hoặc bind đồng thời | Ownership | 409/400, không gắn lại | Error | Chưa test |
| C11 | DRAFT cleanup đua bind; S3 delete lỗi | Ảnh không mất | Không xóa ATTACHED, retry giữ metadata tới khi xóa xong | Edge | Chưa test |
| C12 | Cùng clientRequestId cùng/khác payload | Retry | Một comment; khác payload conflict | Edge | Chưa test |
| C13 | Comment cùng timestamp và phân trang trong lúc có comment mới | Timeline | Không mất/trùng item qua cursor | Edge | Chưa test |
| C14 | HTML/script/javascript URL trong text | Text/link an toàn | Escape/plain text, không XSS | Error | Chưa test |
| C15 | Worker crash sau SQL commit; người nhận mất quyền | Notification | Một delivery hoặc SUPPRESSED, không lộ nội dung | Edge | Chưa test |
| C16 | vi/en/light/dark/mobile/keyboard mention; upload lỗi | i18n/theme | Giữ draft/focus, không mất text/ảnh hợp lệ | Happy | Chưa test |
| C17 | Mongo transaction abort giữa comment/bind/outbox | Tạo bình luận | Không comment/notification/binding nửa chừng | Error | Chưa test |
| C18 | Client truy cập comment/ảnh/mention-options của Task WS khác | Workspace isolation | Từ chối, không lộ dữ liệu WS khác | Error | Chưa test |

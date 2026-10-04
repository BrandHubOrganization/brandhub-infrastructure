# Test — 3-10-9-deactive-user

Các kỳ vọng chi tiết: Acceptance Criteria/Edge Cases trong [spec](spec.md) và mục 1 của [plan kỹ thuật](../plan.md).

- [ ] O3/RED chỉ pending
- [ ] confirm cần evidence hiện tại
- [ ] self/peer ADMIN403
- [ ] auto30days
- [ ] token cũ
- [ ] không mở self/legacy
- [ ] SMTP fail vẫn ACTIVE
- [ ] VI/EN và light/dark

- [ ] Chưa đăng nhập401; USER gọi Admin403; ADMIN hợp lệ mới được thao tác.
- [ ] Lỗi server không báo thành công, không mất dữ liệu form; double click không ghi trùng.
- [ ] Không trả passwordHash/otpCode/totpSecret hoặc token trong danh sách/audit.

## Kết quả

Đã chạy các test nền tảng; xem [bằng chứng và giới hạn](../implementation-status-2026-10-02.md). Các checkbox đầu tài liệu vẫn là tiêu chí nghiệm thu toàn FR, chưa tự đánh dấu các phụ thuộc chưa code.

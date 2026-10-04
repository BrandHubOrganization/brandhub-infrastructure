# Test — 3-10-5-user-management-verifydisabledelete

Các kỳ vọng chi tiết: Acceptance Criteria/Edge Cases trong [spec](spec.md) và mục 1 của [plan kỹ thuật](../plan.md).

- [ ] Y3→O1
- [ ] Y4 không→O2
- [ ] Y6→O2
- [ ] gỡ nguồn không cascade
- [ ] ngày29 reset
- [ ] expire không hồi sinh
- [ ] unflag guard
- [ ] VI/EN và light/dark

- [ ] Chưa đăng nhập401; USER gọi Admin403; ADMIN hợp lệ mới được thao tác.
- [ ] Lỗi server không báo thành công, không mất dữ liệu form; double click không ghi trùng.
- [ ] Không trả passwordHash/otpCode/totpSecret hoặc token trong danh sách/audit.

## Kết quả

Đã chạy các test nền tảng; xem [bằng chứng và giới hạn](../implementation-status-2026-10-02.md). Các checkbox đầu tài liệu vẫn là tiêu chí nghiệm thu toàn FR, chưa tự đánh dấu các phụ thuộc chưa code.

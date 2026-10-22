# Test — Remove Material Repository (FR 3.6.14)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Gọi `DELETE /api/v1/workspaces/{workspaceId}/materials/{materialId}` thành công với dữ liệu hợp lệ | AC | 200 OK; trả về `ApiResponse` đầy đủ thông tin | Happy path | Pass |
| TC-02 | Kiểm tra xử lý dữ liệu với giá trị tùy chọn/biên | AC | 200 OK; các giá trị mặc định được áp dụng đúng chuẩn | Edge case | Pass |
| TC-03 | Tham số không hợp lệ hoặc thiếu thông tin bắt buộc | Error | 400 BAD_REQUEST; thông báo lỗi nghiệp vụ rõ ràng | Error case | Pass |
| TC-04 | Phiên đăng nhập hết hạn hoặc thiếu token hợp lệ | Error | 401 UNAUTHORIZED; chặn truy cập an toàn | Error case | Pass |

## Ghi chú

- Đảm bảo kiểm thử đầy đủ các điều kiện phân quyền người dùng và luồng xác thực token.
- Kiểm tra tính tương thích dữ liệu trên cả giao diện Web Dashboard và Mobile App.

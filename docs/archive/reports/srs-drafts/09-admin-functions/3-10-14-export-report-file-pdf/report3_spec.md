**3.10.12 Export Report File PDF (Xuất Báo Cáo Tài Chính và Kiểm Toán Người Dùng PDF)**

**Function Trigger**

Bắt đầu khi Quản trị viên (ADMIN) nhấn nút "Xuất Báo Cáo PDF" tại các màn hình quản trị hệ thống.

**Function Description**

- **Actors / Roles**: ADMIN. Quản trị viên có thẩm quyền xuất tài liệu báo cáo phục vụ lưu trữ và kiểm toán.
- **Purpose**: Xuất A4 về tài chính, trạng thái user/strike, phiên bản kiểm duyệt và tổng quan nền tảng theo cùng định nghĩa/múi giờ màn hình nguồn. Phạm vi Monitoring vẫn thuộc FR 3.10.3.
- **Interface**: Modal Xuất Báo Cáo PDF (SCR-ADM-11), gồm bộ chọn loại báo cáo, chọn khoảng ngày, tùy chọn trường dữ liệu và nút tải file.
- **Data Processing**: Hệ thống kiểm tra quyền ADMIN (BR-35, BR-65), tiếp nhận phân loại báo cáo và khoảng ngày, truy vấn dữ liệu nguồn, định dạng tài liệu PDF chuẩn A4 có tiêu đề, số trang và dấu thời gian, lưu file tạm và trả về đường dẫn tải xuống an toàn (BR-16).

**Screen Layout**

Figure — Modal Xuất Báo Cáo PDF (SCR-ADM-11):

- Left/Header: Tiêu đề hộp thoại "Xuất Báo Cáo Hệ Thống PDF" kèm biểu tượng tài liệu.
- Center: Loại revenue/user/moderation/platform, khoảng ngày, múi giờ UTC / Asia/Ho_Chi_Minh, phần/biểu đồ và xem trước tóm tắt. Báo cáo user tách thẻ hiệu lực, quy đổi, gỡ, hết hạn; tài chính tách MRR/ARR và thu/hoàn tiền.
- Buttons: Nút "Tải xuống file PDF" (màu xanh), Nút "Hủy bỏ".
- Footer: Ghi chú tài liệu mật nội bộ BrandHub và thời gian hết hạn của liên kết tải xuống (24 giờ).

**Function Details**

- **Data Specifications**
    - **Input required**: reportType (enum: "revenue", "user", "moderation", "platform"), startDate (YYYY-MM-DD), endDate (YYYY-MM-DD).
    - **Input optional**: includeCharts, sections, timezone (UTC/Asia/Ho_Chi_Minh, mặc định Asia/Ho_Chi_Minh), bộ lọc màn hình nguồn.
    - **System data**: adminId (UUID Admin yêu cầu), generatedReportId (UUID), downloadUrl (liên kết tải tạm thời), expiresAt (thời hạn 24 giờ).
    - **Output**: Đối tượng JSON chứa { reportId, downloadUrl, fileName, fileSize, expiresAt } kèm mã HTTP 200 OK.

- **Business Rules**
    - **BR-65**: Chỉ ADMIN yêu cầu/xuất báo cáo toàn nền tảng.
    - **BR-35**: Kiểm tra quyền trước truy vấn và trước truy cập tải có kiểm soát.
    - **BR-16**: Audit loại báo cáo, người yêu cầu, bộ lọc, kỳ, múi giờ, asOf, file và hạn tải.
    - **BR-80**: Khớp định nghĩa màn hình FR 3.10.2/5/6/9/11: trạng thái strike, liên kết quy đổi, hạn khóa tài khoản, MRR/ARR, tiền thu gộp/hoàn/ròng; không dùng Trust Score thay thế.
    - **BR-65**: Lưu thời điểm bằng UTC; báo cáo cho chọn UTC hoặc Asia/Ho_Chi_Minh (mặc định). Tính biên ngày và nhóm ngày/tháng theo múi giờ đã chọn; trả múi giờ trong response, bản xuất và khóa cache.
    - **BR-65**: Giữ khổ A4, font tiếng Việt, header, số trang và link tải bảo mật 24 giờ. Không tạo dữ liệu lịch sử Monitoring giả hoặc mở rộng FR 3.10.3.

- **Validation**
    - Người dùng không có quyền ADMIN → Display: MSG39
    - Không có dữ liệu trong khoảng ngày đã chọn → Display: MSG122

**Functionalities**

- **Normal Flow**
    1. Admin nhấn nút "Xuất Báo Cáo PDF" trên thanh công cụ quản trị.
    2. Hệ thống hiển thị modal tùy chọn SCR-ADM-11.
    3. Admin chọn Loại báo cáo, chọn Khoảng thời gian và tích chọn các mục cần xuất.
    4. Admin nhấn nút "Tải xuống file PDF".
    5. Hệ thống xác thực quyền hạn (BR-35, BR-65) và truy vấn dữ liệu tương ứng trong khoảng ngày đã chọn.
    6. Hệ thống tạo file PDF định dạng A4 chuẩn theo mẫu.
    7. Hệ thống tạo liên kết tải xuống tạm thời và kích hoạt trình duyệt tự động tải file PDF về máy tính của Admin.
    8. Hệ thống đóng modal và lưu nhật ký kiểm toán (BR-16).

- **Abnormal Cases**
    - 1.a1: Nếu người dùng không có vai trò ADMIN, hệ thống từ chối và hiển thị MSG39.
    - 5.a1: Nếu không có bản ghi nào trong khoảng ngày đã chọn, hệ thống thông báo MSG122 và không tạo file rỗng.

**Post-Conditions**

- File PDF báo cáo được tạo thành công và lưu tạm trên máy chủ trong 24 giờ.
- Trình duyệt của Admin tải file PDF về máy tính.
- Một bản ghi được lưu vào bảng audit_logs ghi nhận thông tin báo cáo đã xuất (BR-16).

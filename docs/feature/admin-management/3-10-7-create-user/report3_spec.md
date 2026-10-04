**3.10.7 Create User (Tạo Người Dùng Mới)**

**Function Trigger**

Bắt đầu khi Quản trị viên (ADMIN) nhấn nút "+ Tạo người dùng mới" tại trang /admin/users.

**Function Description**

- **Actors / Roles**: ADMIN. Quản trị viên tạo tài khoản người dùng mới trực tiếp từ trang quản trị.
- **Purpose**: Tạo tài khoản ADMIN/USER phải xác thực email và thay mật khẩu ban đầu trước khi sử dụng bình thường.
- **Interface**: Hộp thoại Tạo Người Dùng (SCR-ADM-07), gồm hồ sơ, system role, gói catalog và thông báo kích hoạt bắt buộc.
- **Data Processing**: Kiểm tra ADMIN, email duy nhất, hồ sơ và chính sách mật khẩu; băm mật khẩu tạm theo auth hiện có. Tạo PENDING_VERIFICATION với emailVerifiedAt=null, requirePasswordReset=true và 0 thẻ. Đưa email kích hoạt bắt buộc vào hàng gửi, ghi audit; gửi email lỗi vẫn giữ tài khoản chờ.

**Screen Layout**

Figure — Hộp thoại Tạo Người Dùng Mới (SCR-ADM-07):

- Left/Header: Tiêu đề hộp thoại "Tạo Người Dùng Mới" kèm biểu tượng thêm tài khoản.
- Center: Họ tên, Email, mật khẩu tạm/tự sinh, System Role ADMIN/USER và chọn gói từ catalog subscription hiện có. Email kích hoạt và thay mật khẩu lần đầu là bắt buộc, không có checkbox bỏ qua.
- Buttons: Nút "Tạo tài khoản" (màu xanh), Nút "Hủy bỏ".
- Footer: Tài khoản bắt đầu PENDING_VERIFICATION, 0 thẻ. Trước khi xác thực email và thay mật khẩu, chỉ được kích hoạt, đặt mật khẩu, đăng xuất và hỗ trợ.

**Function Details**

- **Data Specifications**
    - **Input required**: fullName (2–100 ký tự), email (đúng định dạng), role (ADMIN/USER); mật khẩu tạm nếu không tự sinh: ít nhất 8 ký tự, một chữ số và một ký tự đặc biệt.
    - **Input optional**: phoneNumber, requestedPlanId từ catalog subscription; tạo tài khoản không tự cấp quyền gói trả phí khi chưa thanh toán.
    - **System data**: adminId, createdAt, initialStatus=PENDING_VERIFICATION, emailVerifiedAt=null, requirePasswordReset=true, initialStrikes=0, trạng thái gửi email kích hoạt.
    - **Output**: Thông tin người dùng mới tạo (id, email, fullName, role, status) kèm mã HTTP 201 Created.

- **Business Rules**
    - **BR-01**: Email duy nhất toàn nền tảng, theo quy tắc chuẩn hóa hiện có.
    - **BR-02**: Mật khẩu tạm/mới cần ít nhất 8 ký tự, một chữ số và một ký tự đặc biệt; băm BCrypt cost 12 theo FR gốc. Tái sử dụng kiểm tra/băm của auth và đối chiếu điểm khác trong plan kỹ thuật; không log mật khẩu hoặc token kích hoạt.
    - **BR-82**: System role chỉ gồm ADMIN và USER. Quyền thành viên Agency/Workspace quản lý riêng. Mã gói lấy từ catalog subscription hiện có (hiện tại BASIC, PRO, ENTERPRISE), không tạo danh mục gói cứng khác.
    - **BR-63**: Chỉ ADMIN tạo tài khoản. Email kích hoạt bắt buộc xác minh sở hữu email; tạo tài khoản chưa đánh dấu email đã xác thực.
    - **BR-15**: Chưa đủ cả xác thực email và thay mật khẩu ban đầu thì chỉ cho kích hoạt/xác thực email, đặt mật khẩu, đăng xuất và hỗ trợ. Chặn dashboard, dữ liệu Agency, AI, đăng bài và thao tác thanh toán trên cả UI/API.
    - **BR-15**: Hoàn tất thì đặt emailVerifiedAt, xóa requirePasswordReset và kích hoạt nếu không có xử phạt/xóa riêng. Xác thực email không cần Admin duyệt hoặc thiết lập lại 2FA.
    - **BR-60**: Quyền gói trả phí theo luồng subscription/thanh toán hiện có; tạo tài khoản không phải sự kiện thanh toán, hóa đơn hoặc doanh thu.
    - **BR-16**: Audit tạo/kích hoạt nhưng không lưu bí mật.

- **Validation**
    - Người dùng không có quyền ADMIN → Display: MSG39
    - Để trống Họ tên hoặc Email → Display: MSG02
    - Email sai định dạng → Display: MSG04
    - Email đã tồn tại trong hệ thống → Display: MSG08
    - Mật khẩu tạm thời không đạt chuẩn bảo mật → Display: MSG05
    - Tạo tài khoản thành công → Display: MSG10

**Functionalities**

- **Normal Flow**
    1. Admin mở SCR-ADM-07, nhập hồ sơ, role ADMIN/USER và tùy chọn yêu cầu gói catalog.
    2. Hệ thống kiểm tra duy nhất email và quy tắc auth/mật khẩu hiện có.
    3. Tạo tài khoản chờ với 0 thẻ và bắt buộc cả hai điều kiện kích hoạt.
    4. Xếp email kích hoạt vào hàng gửi, ghi audit và hiển thị trạng thái chờ gửi/kích hoạt.
    5. User mở luồng kích hoạt, xác thực email và đặt mật khẩu riêng mới.
    6. Đủ cả hai điều kiện thì kích hoạt tài khoản hợp lệ và mở quyền bình thường; gói trả phí vẫn theo quy tắc thanh toán.

- **Abnormal Cases**
    - 1.a1: Thiếu ADMIN → MSG39; thiếu trường/email sai/mật khẩu sai/email trùng → MSG02/04/05/08 hiện có.
    - 4.a1: Email lỗi → giữ PENDING_VERIFICATION, hiển thị retry/gửi lại; không tạo tài khoản khác.
    - 5.a1: Token kích hoạt hết hạn/đã dùng → theo chính sách gửi lại/xác thực hiện có; không mở quyền ứng dụng.
    - 6.a1: Chỉ hoàn tất một điều kiện → vẫn hạn chế ở luồng kích hoạt; không bỏ qua xử phạt/xóa tài khoản.

**Post-Conditions**

- Tài khoản mới giữ PENDING_VERIFICATION đến khi đủ điều kiện kích hoạt bắt buộc.
- System role là ADMIN/USER; quyền Agency và quyền gói trả phí quản lý riêng.
- Lưu tình trạng gửi email và audit; không log mật khẩu/token.

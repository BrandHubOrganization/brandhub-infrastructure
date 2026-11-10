**3.10.8 Update User (Chỉnh Sửa Chi Tiết Người Dùng)**

**Function Trigger**

Bắt đầu khi Quản trị viên (ADMIN) chọn "Chỉnh sửa" từ menu người dùng hoặc trang chi tiết /admin/users/:id.

**Function Description**

- **Actors / Roles**: ADMIN. Quản trị viên hệ thống có quyền cập nhật thông tin tài khoản người dùng.
- **Purpose**: Cho phép Admin cập nhật thông tin hồ sơ (Họ tên, Số điện thoại, Vai trò, Trạng thái) của người dùng khi có yêu cầu hợp lệ.
- **Interface**: Màn hình Cập nhật Chi tiết Người dùng (SCR-ADM-08), gồm form chỉnh sửa thông tin, khung hiển thị thẻ phạt 30 ngày (chỉ đọc) và nút lưu thay đổi.
- **Data Processing**: Kiểm tra ADMIN, email bất biến, system role và lý do audit. Sửa trường hồ sơ được phép; quyền sở hữu Agency quản lý riêng. Lưu đổi gói cho kỳ thanh toán tiếp theo và vẫn yêu cầu thanh toán. Không đổi quota ngay, ghi đã thu tiền hoặc tạo doanh thu.

**Screen Layout**

Figure — Màn hình Cập nhật Chi tiết Người dùng (SCR-ADM-08):

- Left/Header: Sidebar điều hướng Admin; Breadcrumb "Admin / Quản lý Người dùng / Chỉnh sửa", tiêu đề "Chỉnh sửa Tài khoản" kèm User ID.
- Center: Tên/điện thoại/bio/avatar được sửa, email chỉ đọc; system role ADMIN/USER; quyền Agency chỉ hiển thị ngữ cảnh. Hiện gói hiện tại, gói catalog yêu cầu, ngày hiệu lực kỳ sau và nhắc phải thanh toán. Bắt buộc lý do.
- Buttons: Nút "Lưu thay đổi" (màu xanh), Nút "Hủy bỏ / Quay lại".
- Footer: Ghi chú kiểm toán: "Mọi thay đổi vai trò hoặc thông tin người dùng đều được ghi lại trong Audit Log để phục vụ đối soát".

**Function Details**

- **Data Specifications**
    - **Input required**: userId, fullName (2–100 ký tự), role (ADMIN/USER), justification.
    - **Input optional**: phoneNumber, bio, avatarUrl, requestedPlanId (catalog hiện có).
    - **System data**: adminId, email bất biến, currentRole, currentPlan, nextBillingAt, pendingPlanChange và trạng thái thanh toán, updatedAt.
    - **Output**: Hồ sơ người dùng sau khi cập nhật kèm mã HTTP 200 OK.

- **Business Rules**
    - **BR-19**: Email chỉ đọc; API từ chối sửa email.
    - **BR-82**: System role chỉ gồm ADMIN và USER. Quyền thành viên Agency/Workspace quản lý riêng. Mã gói lấy từ catalog subscription hiện có (hiện tại BASIC, PRO, ENTERPRISE), không tạo danh mục gói cứng khác.
    - **BR-83**: Đổi quyền sở hữu Agency/Workspace dùng luồng thành viên riêng. Màn hình này không được xóa Owner cuối qua sửa system role; vẫn được sửa hồ sơ Owner duy nhất.
    - **BR-23**: Owner duy nhất của Agency/Workspace vẫn được sửa hồ sơ, ghi strike, gắn cờ và khóa tài khoản 30 ngày sau xác nhận. Thành viên khác tiếp tục quyền hiện có; thao tác chỉ Owner được làm tạm dừng đến khi mở khóa. Không khóa cả Agency, không tự chuyển quyền sở hữu. Quyền Owner độc lập với system role.
    - **BR-35**: Admin không hạ/sửa system role của Admin ngang hàng; giữ bảo vệ vai trò bản thân/ngang hàng hiện có.
    - **BR-60**: Admin đổi gói có hiệu lực kỳ thanh toán tiếp theo và khách vẫn phải trả tiền qua subscription hiện có. Giữ quyền gói hiện tại đến biên kỳ. Chưa thanh toán không cấp quyền trả phí; thao tác đổi gói không tạo doanh thu hoặc hóa đơn đã trả.
    - **BR-16**: Audit chênh lệch hồ sơ, role, gói yêu cầu, ngày hiệu lực và lý do riêng với sự kiện thanh toán thật.

- **Validation**
    - Thiếu ADMIN → MSG39; không có đối tượng → MSG38; thiếu trường/lý do → MSG02.
    - Sửa email, system role không hỗ trợ hoặc gói ngoài catalog → từ chối.
    - Sửa role Admin ngang hàng hoặc đổi quyền sở hữu Agency qua form này → từ chối.
    - Sửa hồ sơ hợp lệ của Owner duy nhất → cho phép; cập nhật thành công → MSG26.

**Functionalities**

- **Normal Flow**
    1. Tải hồ sơ, quyền Agency riêng, gói hiện tại và ngày kỳ thanh toán tiếp theo.
    2. Admin sửa hồ sơ/system role được phép hoặc chọn gói kỳ sau, nhập lý do.
    3. Kiểm tra bất biến email, bảo vệ role và giá trị catalog.
    4. Lưu hồ sơ và gói chờ; không đổi quyền gói kỳ hiện tại.
    5. Audit, hiển thị gói hiện tại/chờ cùng ngày hiệu lực và yêu cầu thanh toán.
    6. Subscription hiện có áp dụng đổi gói kỳ sau chỉ sau khi thanh toán cần thiết thành công.

- **Abnormal Cases**
    - 1.a1: Không có user → MSG38; thiếu ADMIN → MSG39.
    - 3.a1: Thiếu lý do hoặc sửa trường/role bị bảo vệ → từ chối, không cập nhật một phần.
    - 6.a1: Thanh toán gia hạn lỗi → theo chính sách subscription hiện có; không cấp miễn phí hoặc ghi doanh thu giả.
    - 6.a2: Chưa có kỳ tiếp theo xác định → qua luồng đăng ký subscription hiện có; không tự nâng gói miễn phí ngay.

**Post-Conditions**

- Trường hồ sơ hợp lệ được cập nhật; form không sửa email và quyền sở hữu Agency.
- Gói chờ lưu ngày kỳ sau và yêu cầu trả tiền; giữ quota hiện tại đến lúc đổi có hiệu lực.
- Audit lưu thay đổi; doanh thu chỉ đổi theo sự kiện tài chính thật.

**3.10.6 View User (Xem Danh Sách Người Dùng)**

**Function Trigger**

Bắt đầu khi Quản trị viên (ADMIN) truy cập danh sách người dùng tại route /admin/users.

**Function Description**

- **Actors / Roles**: ADMIN. Quản trị viên hệ thống tra cứu danh mục người dùng.
- **Purpose**: Tra cứu/lọc user theo trạng thái tài khoản, system role, gói catalog và strike còn hiệu lực; quyền Agency hiển thị riêng.
- **Interface**: Màn hình Danh sách Người dùng (SCR-ADM-06), gồm thanh tìm kiếm, các bộ lọc trạng thái/gói cước/thẻ phạt, bảng dữ liệu đa cột và thanh phân trang.
- **Data Processing**: Kiểm tra ADMIN, truy vấn hồ sơ phân trang với trạng thái hiện tại, cờ kích hoạt và catalog subscription; tính bộ đếm theo FR 3.10.5 thay vì TTL từ ngày tạo.

**Screen Layout**

Figure — Màn hình Danh sách & Quản lý Người dùng (SCR-ADM-06):

- Left/Header: Sidebar điều hướng Admin; Top Header hiển thị breadcrumb "Admin / Quản lý Người dùng" và chỉ báo tổng số người dùng.
- Center: Tìm email/tên; lọc ACTIVE, PENDING_VERIFICATION, FLAGGED, DEACTIVATED, DELETED và SUSPENDED cũ nếu còn; ADMIN/USER; gói catalog; mức strike còn hiệu lực. Dòng hiển thị hồ sơ, system role, quyền sở hữu Agency riêng, gói hiện tại/chờ, bộ đếm YELLOW/ORANGE/RED, trạng thái kích hoạt và hạn khóa. Ngưỡng ORANGE là x/3.
- Buttons: Nút "+ Tạo người dùng mới" (màu xanh góc phải trên), Nút "Áp dụng lọc", Nút "Đặt lại", Menu thao tác ba chấm trên từng dòng (Xem chi tiết, Quản lý vi phạm, Chỉnh sửa).
- Footer: Phân trang: 10/20/50 dòng mỗi trang, điều hướng trang và tổng số; mặc định 20 dòng.

**Function Details**

- **Data Specifications**
    - **Input required**: Không có (mặc định page=1, limit=20).
    - **Input optional**: page, limit, search, status, systemRole (ADMIN/USER), strikeFilter (ALL/HAS_YELLOW/HAS_ORANGE/HAS_RED/CLEAN), planId (catalog), sortBy, sortOrder.
    - **System data**: Danh sách bản ghi users kèm thông tin gói cước và bộ đếm thẻ phạt activeStrikes30d.
    - **Output**: Danh sách người dùng kèm siêu dữ liệu phân trang (total, page, limit, totalPages).

- **Business Rules**
    - **BR-63**: Chỉ ADMIN xem danh bạ toàn nền tảng.
    - **BR-82**: System role chỉ gồm ADMIN và USER. Quyền thành viên Agency/Workspace quản lý riêng. Mã gói lấy từ catalog subscription hiện có (hiện tại BASIC, PRO, ENTERPRISE), không tạo danh mục gói cứng khác.
    - **BR-94**: Dùng trạng thái thẻ còn hiệu lực/đã quy đổi/đã gỡ/hết hạn tại FR 3.10.5. Không nhầm bộ đếm hiệu lực với lịch sử; ORANGE hiển thị x/3.
    - **BR-15**: PENDING_VERIFICATION là chưa xác thực email. DEACTIVATED hiển thị hạn khóa. DELETED là vòng đời tự xóa riêng.
    - **BR-65**: Giữ phân trang, tìm kiếm và bộ lọc trên URL; kiểm tra tham số và allowlist sắp xếp. Không trả hash mật khẩu, token hoặc bí mật Authenticator.

- **Validation**
    - Thiếu quyền ADMIN → MSG39.
    - Không tìm thấy user phù hợp → bảng trống kèm MSG122.

**Functionalities**

- **Normal Flow**
    1. Admin truy cập màn hình Danh sách Người dùng tại /admin/users.
    2. Hệ thống xác thực quyền ADMIN theo BR-35, BR-63.
    3. Hệ thống tải dữ liệu trang 1 (20 bản ghi mới nhất) và hiển thị lên bảng SCR-ADM-06.
    4. Admin có thể nhập từ khóa tìm kiếm (họ tên, email) hoặc chọn lọc theo Trạng thái / Thẻ phạt / Gói cước.
    5. Hệ thống gửi yêu cầu lọc về backend và tải lại danh sách kết quả phù hợp.
    6. Admin có thể chuyển trang hoặc thay đổi số lượng bản ghi hiển thị trên mỗi trang.

- **Abnormal Cases**
    - 1.a1: Thiếu quyền ADMIN → MSG39.
    - 5.a1: Không có user phù hợp → trạng thái trống với MSG122; giữ bộ lọc hiện tại.

**Post-Conditions**

- Danh bạ phân trang phản ánh nhất quán kích hoạt/xử phạt, gói catalog và vòng đời strike.
- Tham số tìm kiếm và lọc được giữ trên URL.

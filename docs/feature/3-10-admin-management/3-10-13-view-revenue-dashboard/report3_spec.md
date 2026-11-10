**3.10.11 View Revenue Dashboard (Bảng Điều Khiển Doanh Thu Nền Tảng)**

**Function Trigger**

Bắt đầu khi Quản trị viên (ADMIN) truy cập trang quản lý tài chính tại /admin/revenue.

**Function Description**

- **Actors / Roles**: ADMIN. Quản trị viên theo dõi doanh thu và số liệu thanh toán toàn nền tảng.
- **Purpose**: Hiển thị chi tiết số liệu doanh thu từ các gói đăng ký dịch vụ (PayOS) và dịch vụ nạp điểm AI Credit.
- **Interface**: Bảng Điều Khiển Doanh Thu Nền Tảng (SCR-ADM-10), gồm các thẻ KPI doanh thu (MRR, ARR, Doanh thu lũy kế), biểu đồ doanh thu theo thời gian, biểu đồ cơ cấu nguồn thu và bảng giao dịch gần nhất.
- **Data Processing**: Kiểm tra ADMIN; tính MRR/ARR từ quyền thuê bao trả phí đang hiệu lực và tổng hợp riêng thanh toán/hoàn tiền đối soát theo múi giờ báo cáo. Áp dụng giảm giá hiện tại và catalog gói hiện có.

**Screen Layout**

Figure — Bảng Điều Khiển Doanh Thu Nền Tảng (SCR-ADM-10):

- Left/Header: Điều hướng Admin, bộ lọc kỳ, múi giờ UTC / Asia/Ho_Chi_Minh (mặc định) và Xuất PDF.
- Center: Thẻ MRR, ARR, tiền thu gộp, tiền hoàn, thu ròng và số giao dịch thành công. Biểu đồ tách tiền subscription/AI Credit; lọc gói catalog; lịch sử thanh toán/hoàn với trạng thái. Phân biệt MRR tại thời điểm thống kê và tiền thu trong kỳ.
- Buttons: Nút "Làm mới số liệu", Bộ lọc thời gian (Tháng này, Quý này, Năm nay, Tùy chỉnh), Nút "Xuất Báo cáo Tài chính PDF".
- Footer: Dấu thời gian đối soát dữ liệu gần nhất và ghi chú bảo mật thanh toán.

**Function Details**

- **Data Specifications**
    - **Input required**: Không có (mặc định hiển thị dữ liệu tháng hiện tại).
    - **Input optional**: period, startDate, endDate, timezone (UTC/Asia/Ho_Chi_Minh), planId (catalog).
    - **System data**: mrrAmount, arrAmount, grossReceipts, refunds, netReceipts, subscriptionReceipts, aiCreditReceipts, successfulTransactionCount, transactions, asOf, timezone.
    - **Output**: Gói dữ liệu JSON doanh thu nền tảng kèm mã HTTP 200 OK.

- **Business Rules**
    - **BR-65**: Chỉ ADMIN xem tài chính toàn nền tảng.
    - **BR-60**: MRR là giá trị thuê bao trả phí đang hiệu lực quy về tháng sau giảm giá áp dụng; gói năm đóng góp giá năm / 12. ARR = MRR × 12. Tiền thu gộp gồm thanh toán subscription và AI Credit mua lẻ thành công trong kỳ. Hiển thị tiền hoàn riêng; thu ròng = tiền thu gộp − tiền hoàn. AI Credit không vào MRR. Hoàn tiền chỉ đổi MRR khi giá trị/trạng thái thuê bao thay đổi; không trừ hai lần.
    - **BR-60**: Dùng sự kiện thanh toán/hoàn tiền thành công thật, gồm hoàn một phần. Giao dịch đã hoàn vẫn thuộc tiền thu gộp; khoản hoàn ghi riêng ở lúc hoàn. Thanh toán chờ/thất bại không đóng góp.
    - **BR-60**: Đổi gói chờ bởi Admin chưa đổi MRR, quota hoặc tiền thu ngay. Kỳ sau vẫn phải thanh toán; thao tác đổi không phải doanh thu.
    - **BR-80**: Tính tiền chính xác theo quy tắc tiền tệ hiện có; hiện asOf cho MRR và khoảng báo cáo cho tiền thu.
    - **BR-65**: Lưu thời điểm bằng UTC; báo cáo cho chọn UTC hoặc Asia/Ho_Chi_Minh (mặc định). Tính biên ngày và nhóm ngày/tháng theo múi giờ đã chọn; trả múi giờ trong response, bản xuất và khóa cache.
    - **BR-82**: System role chỉ gồm ADMIN và USER. Quyền thành viên Agency/Workspace quản lý riêng. Mã gói lấy từ catalog subscription hiện có (hiện tại BASIC, PRO, ENTERPRISE), không tạo danh mục gói cứng khác.
    - **BR-16**: Audit truy vấn tài chính và xuất báo cáo.

- **Validation**
    - Người dùng không có quyền ADMIN → Display: MSG39
    - Khoảng ngày lọc không có dữ liệu giao dịch → Display: MSG122

**Functionalities**

- **Normal Flow**
    1. Admin mở SCR-ADM-10, chọn kỳ, múi giờ và tùy chọn gói catalog.
    2. Kiểm tra ADMIN và xác định biên báo cáo.
    3. Tính MRR thuê bao hiện tại quy về tháng và ARR độc lập với ngày thu tiền.
    4. Tổng hợp thanh toán/hoàn thành công trong kỳ; tách subscription/AI Credit và tính thu ròng.
    5. Hiển thị giá trị với asOf, kỳ và múi giờ; giữ các tham số khi xuất PDF.

- **Abnormal Cases**
    - 2.a1: Nếu người dùng không có vai trò ADMIN, hệ thống chặn truy cập và hiển thị MSG39.
    - 3.a1: Nếu khoảng ngày chọn không có dữ liệu phát sinh, hệ thống hiển thị MSG122.

**Post-Conditions**

- Số liệu doanh thu được hiển thị chính xác và trực quan trên màn hình.
- Dữ liệu đối soát tài chính sẵn sàng để xuất báo cáo PDF khi có yêu cầu.

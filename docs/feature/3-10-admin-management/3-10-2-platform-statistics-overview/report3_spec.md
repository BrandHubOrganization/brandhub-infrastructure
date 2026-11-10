**3.10.2 Platform Statistics Overview (Thống Kê Tổng Quan Nền Tảng)**

**Function Trigger**

Bắt đầu khi Quản trị viên (ADMIN) truy cập trang chủ quản trị tại route /admin/dashboard.

**Function Description**

- **Actors / Roles**: ADMIN. Quản trị viên theo dõi hiệu suất vận hành, người dùng và doanh thu nền tảng.
- **Purpose**: Hiển thị hoạt động đăng nhập thành công, tăng trưởng người dùng, tài khoản FLAGGED, strike còn hiệu lực và chỉ số tài chính có định nghĩa rõ.
- **Interface**: Bảng điều khiển Thống kê Tổng quan (SCR-ADM-02), gồm 4 thẻ KPI, biểu đồ tăng trưởng người dùng, biểu đồ doanh thu và bảng top agency.
- **Data Processing**: Kiểm tra ADMIN; tổng hợp sự kiện đăng nhập, số bài/hoạt động, trạng thái strike còn hiệu lực và thanh toán đối soát. Cache tối đa 15 phút theo bộ lọc, múi giờ và tiêu chí xếp hạng; trả asOf và biên kỳ.

**Screen Layout**

Figure — Bảng điều khiển Thống kê Tổng quan Nền tảng (SCR-ADM-02):

- Left/Header: Điều hướng Admin, bộ lọc kỳ và chọn múi giờ UTC / Asia/Ho_Chi_Minh (mặc định).
- Center: KPI: tổng user / user đăng nhập thành công trong 30 ngày gần nhất, user FLAGGED, strike YELLOW/ORANGE/RED còn hiệu lực, tiền thu gộp. Biểu đồ tăng trưởng, tiền thu và phân bố gói; Top 5 Agency chọn xếp riêng theo số bài, hoạt động nghiệp vụ, doanh thu. Hiển thị tiêu chí và kỳ của bảng xếp hạng.
- Buttons: Nút "Làm mới dữ liệu" (xóa cache Redis và tải lại), Nút chọn "Khoảng ngày tùy chỉnh", Nút "Xuất Báo cáo PDF".
- Footer: Thời điểm đồng bộ, múi giờ đã chọn và chỉ báo dữ liệu cũ/lỗi.

**Function Details**

- **Data Specifications**
    - **Input required**: Không có (mặc định hiển thị 12 tháng gần nhất).
    - **Input optional**: period, startDate, endDate, timezone (UTC hoặc Asia/Ho_Chi_Minh), agencyRankBy (POSTS, ACTIVITY, REVENUE).
    - **System data**: totalUsers, activeUsers30d, flaggedUsersCount, activeStrikeCounts, grossReceipts, refunds, netReceipts, topAgencies, asOf, timezone.
    - **Output**: Gói dữ liệu JSON thống kê tổng quan nền tảng, mã HTTP 200 OK.

- **Business Rules**
    - **BR-65**: Thống kê toàn nền tảng chỉ dành cho ADMIN.
    - **BR-65**: activeUsers30d đếm user khác nhau có đăng nhập thành công trong 30 ngày gần nhất. Đăng nhập lỗi hoặc chỉ refresh token không được tính.
    - **BR-65**: Có đủ ba kiểu xếp hạng Agency theo số bài, số hoạt động nghiệp vụ và doanh thu trong kỳ; không tự đặt điểm tổng hợp có trọng số. Plan kỹ thuật phải ánh xạ rõ nguồn bài viết, sự kiện hoạt động và cách quy thuộc thanh toán hiện có.
    - **BR-94**: Bộ đếm strike dùng điều kiện còn hiệu lực và thời gian sạch tại FR 3.10.5, không lọc createdAt >= now−30 ngày. Lịch sử đã quy đổi/gỡ/hết hạn hiển thị riêng.
    - **BR-60**: MRR là giá trị thuê bao trả phí đang hiệu lực quy về tháng sau giảm giá áp dụng; gói năm đóng góp giá năm / 12. ARR = MRR × 12. Tiền thu gộp gồm thanh toán subscription và AI Credit mua lẻ thành công trong kỳ. Hiển thị tiền hoàn riêng; thu ròng = tiền thu gộp − tiền hoàn. AI Credit không vào MRR. Hoàn tiền chỉ đổi MRR khi giá trị/trạng thái thuê bao thay đổi; không trừ hai lần.
    - **BR-65**: Lưu thời điểm bằng UTC; báo cáo cho chọn UTC hoặc Asia/Ho_Chi_Minh (mặc định). Tính biên ngày và nhóm ngày/tháng theo múi giờ đã chọn; trả múi giờ trong response, bản xuất và khóa cache.

- **Validation**
    - Người dùng không có quyền ADMIN → Display: MSG39
    - Khoảng ngày tùy chỉnh không có dữ liệu → Display: MSG122
    - Vượt quá tần suất yêu cầu làm mới dữ liệu → Display: MSG48

**Functionalities**

- **Normal Flow**
    1. Admin mở SCR-ADM-02; hệ thống kiểm tra quyền ADMIN.
    2. Chọn kỳ, múi giờ và một trong ba tiêu chí xếp hạng Agency.
    3. Trả tổng hợp từ cache còn hạn hoặc tính theo cùng bộ lọc và biên múi giờ.
    4. Hiển thị KPI, biểu đồ, xếp hạng và asOf; giữ bộ lọc khi xuất PDF.

- **Abnormal Cases**
    - 2.a1: Nếu người dùng không có vai trò ADMIN, hệ thống chặn truy cập và hiển thị MSG39.
    - 5.a1: Nếu khoảng ngày chọn không có dữ liệu phát sinh, hệ thống hiển thị MSG122.

**Post-Conditions**

- Dữ liệu thống kê được hiển thị trực quan trên giao diện Admin.
- Dữ liệu tính toán mới được lưu vào Redis cache với TTL 15 phút.

**3.10.1 Push Notification (Soạn và Gửi Thông Báo Hệ Thống)**

**Function Trigger**

Bắt đầu khi Quản trị viên (ADMIN) truy cập /admin/notifications và nhấn nút "Soạn thông báo".

**Function Description**

- **Actors / Roles**: ADMIN. Quản trị viên hệ thống có quyền gửi thông báo tới người dùng toàn nền tảng.
- **Purpose**: Soạn và gửi thông báo hệ thống bằng EMAIL, ngay hoặc theo lịch. In-app và FCM để giai đoạn sau.
- **Interface**: Màn hình Thông báo Hệ thống (SCR-ADM-01), gồm soạn email, điều kiện người nhận, lưu nháp/lên lịch và lịch sử gửi.
- **Data Processing**: Kiểm tra ADMIN, nội dung và điều kiện người nhận; lưu nháp/lịch. Xác định người nhận tại thời điểm gửi thực tế, gửi qua dịch vụ email, lưu kết quả và audit; tránh sửa/hủy đua với gửi và tránh gửi trùng khi retry.

**Screen Layout**

Figure — Màn hình Soạn và Gửi Thông Báo Hệ Thống (SCR-ADM-01):

- Left/Header: Sidebar điều hướng Admin; Top Header hiển thị tiêu đề trang "Quản lý Thông báo Hệ thống" và nút "Soạn thông báo mới".
- Center: Tiêu đề (5–200 ký tự), nội dung (10–5.000), loại System/Maintenance/Update/Promotion, đối tượng ALL/BY_PLAN/BY_ROLE, chọn gói từ catalog hoặc ADMIN/USER, URL tùy chọn, thời gian và múi giờ gửi. Phân biệt số người nhận ước tính với số thực tế.
- Buttons: Gửi ngay, Lên lịch, Lưu nháp; chỉ sửa/hủy DRAFT hoặc SCHEDULED. Đã gửi không được thu hồi.
- Footer: Lịch sử và phân trang; trạng thái DRAFT, SCHEDULED, SENT, FAILED hoặc CANCELLED; số gửi thành công/thất bại. SENT ghi nhận hoàn tất gửi, không có nghĩa người nhận đã đọc email.

**Function Details**

- **Data Specifications**
    - **Input required**: title (5–200), content (10–5.000), type (SYSTEM, MAINTENANCE, UPDATE, PROMOTION), targetType (ALL, BY_PLAN, BY_ROLE).
    - **Input optional**: targetPlans (ID catalog, bắt buộc khi BY_PLAN), targetRoles (ADMIN/USER, bắt buộc khi BY_ROLE), scheduledAt (ISO có offset), actionUrl.
    - **System data**: notificationId, senderId, channel=EMAIL, status (DRAFT, SCHEDULED, SENT, FAILED, CANCELLED), createdAt, sentAt, recipientCount, deliveryResults.
    - **Output**: Bản ghi thông báo đã tạo kèm mã trạng thái HTTP 201 Created.

- **Business Rules**
    - **BR-35**: Mọi thao tác phát thông báo yêu cầu quyền ADMIN đã xác thực.
    - **BR-57**: Giai đoạn này chỉ gửi EMAIL; tiêu đề 5–200 và nội dung 10–5.000 ký tự. In-app và FCM ngoài phạm vi giai đoạn.
    - **BR-65**: Xác định người nhận lúc gửi thực tế từ điều kiện đã lưu. Số xem trước chỉ là ước tính; không có người nhận vẫn hoàn tất với recipientCount=0.
    - **BR-82**: BY_ROLE chỉ nhận ADMIN/USER; BY_PLAN dùng catalog subscription hiện có. Quyền thành viên Agency không phải system role.
    - **BR-57**: Chỉ sửa/hủy DRAFT và SCHEDULED. Hủy đặt CANCELLED và ngăn gửi. Khi bắt đầu gửi phải khóa phiên bản; email đã gửi không thu hồi. Lưu lỗi từng người nhận và chỉ retry người chưa gửi được.
    - **BR-16**: Audit tạo, sửa, lên lịch, hủy và gửi với người thực hiện, điều kiện, thời điểm và số người nhận thực tế.

- **Validation**
    - Người dùng không có quyền ADMIN → Display: MSG39
    - Tiêu đề hoặc nội dung thông báo để trống → Display: MSG02
    - Độ dài tiêu đề hoặc nội dung vượt quá giới hạn cho phép → Display: MSG03
    - Thời gian hẹn giờ gửi không hợp lệ hoặc trong quá khứ → Display: MSG45
    - Gửi thông báo thành công → Display: MSG144

**Functionalities**

- **Normal Flow**
    1. Admin mở SCR-ADM-01 và soạn thông báo email.
    2. Chọn điều kiện người nhận rồi lưu nháp, gửi ngay hoặc lên lịch trong tương lai.
    3. Hệ thống kiểm tra nội dung, giá trị catalog và quyền ADMIN; lưu thao tác và audit.
    4. Admin được sửa/hủy khi DRAFT hoặc SCHEDULED; worker kiểm tra phiên bản hiện tại trước gửi.
    5. Lúc gửi thực tế, lấy người nhận theo vai trò/gói hiện tại và gửi email.
    6. Ghi kết quả gửi, số người nhận thực tế, trạng thái và audit; cập nhật lịch sử.

- **Abnormal Cases**
    - 1.a1: Không có quyền ADMIN → MSG39; thiếu/sai dữ liệu bắt buộc → MSG02/MSG03.
    - 2.a1: Lịch trong quá khứ hoặc thiếu điều kiện người nhận → lỗi kiểm tra; không gửi.
    - 4.a1: Sửa/hủy sau khi bắt đầu gửi hoặc ở SENT/FAILED/CANCELLED → xung đột; không thu hồi email đã gửi.
    - 5.a1: Email lỗi/toàn phần hoặc một phần → lưu kết quả và retry an toàn, không gửi lại người đã thành công.

**Post-Conditions**

- Lưu nội dung, điều kiện người nhận, trạng thái vòng đời và kết quả gửi.
- Chỉ người thỏa điều kiện lúc gửi nhận EMAIL; lịch đã hủy không được gửi.
- Mọi thay đổi quản trị và lần gửi có audit bất biến.

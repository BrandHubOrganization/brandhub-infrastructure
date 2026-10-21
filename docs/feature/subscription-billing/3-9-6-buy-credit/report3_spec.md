**3.9.6 Buy Credit**

**Function Trigger**

Begins when USER (owned budget) thực hiện thao tác trên giao diện `Buy Credit Page` liên quan đến tính năng `Buy Credit`.

**Function Description**

- **Actors / Roles**: USER (owned budget).
- **Purpose**: Mua thêm creadit để tiếp tục sử dụng tính năng AI khi sử dụng hết creadit có trong các gói Pro/Enterprise.
- **Interface**: Giao diện `Buy Credit Page` hiển thị trực quan các thành phần thao tác, dữ liệu và phản hồi trạng thái.
- **Data Processing**: Tiếp nhận yêu cầu tại `BillingController`, xác thực quyền của caller, thực thi kiểm tra và xử lý nghiệp vụ thông qua `BillingService`, truy xuất và cập nhật cơ sở dữ liệu thông qua Repository tương ứng.

**Screen Layout**

Figure — Screen Layout (`Buy Credit Page`):

- Header: Tiêu đề trang, breadcrumb điều hướng và thông tin định danh ngữ cảnh làm việc.
- Main Workspace: Khu vực hiển thị bảng dữ liệu, biểu mẫu nhập liệu hoặc danh sách đối tượng nghiệp vụ.
- Action Panel: Các nút điều khiển thực hiện hành động chính, nút hủy và các bộ lọc tìm kiếm.
- Feedback Area: Khu vực hiển thị trạng thái xử lý (loading spinner, modal xác nhận, toast thông báo kết quả).

**Function Details**
- **Data Specifications**
    - **Input required**: Các trường bắt buộc theo đặc tả của `POST /api/v1/billing/credits/buy`.
    - **Input optional**: Các tham số lọc, phân trang hoặc ghi chú bổ sung.
    - **System data**: Bản ghi dữ liệu liên quan tại các bảng cơ sở dữ liệu (`Web dashboard, AiCreditAccountRepository, UserSubscriptionRepository, SubscriptionPlanRepository`).
    - **Output**: `ApiResponse` kèm mã trạng thái HTTP tiêu chuẩn.

- **Business Rules**
    - **BR-396**: Chỉ các Actor có thẩm quyền hợp lệ (`USER (owned budget)`) mới được phép kích hoạt tính năng.
    - Đảm bảo tính toàn vẹn dữ liệu và kiểm tra xung đột trạng thái trước khi thực hiện thay đổi dữ liệu.
    - Mọi thao tác đều được ghi nhận nhật ký hệ thống phục vụ công tác kiểm toán và giám sát.

- **Validation**
    - Thiếu hoặc sai định dạng tham số bắt buộc → Trả về HTTP 400 `BAD_REQUEST`.
    - Token không hợp lệ hoặc hết hạn → Trả về HTTP 401 `UNAUTHORIZED`.
    - Không đủ thẩm quyền vai trò → Trả về HTTP 403 `FORBIDDEN`.
    - Bản ghi đối tượng không tồn tại → Trả về HTTP 404 `NOT_FOUND`.

**Functionalities**
- **Normal Flow**
    1. Gửi yêu cầu `Select credit quantity and confirm quote` từ `userownedbudget` tới `webdashboard`.
    2. Gửi yêu cầu `Check budget owner and eligible plan` từ `billingservice` tới `billingservice`.
    3. Gửi yêu cầu `Validate quantity; price purchase` từ `billingservice` tới `billingservice`.

- **Abnormal Cases**
    - 2.a1: Token xác thực không hợp lệ hoặc hết hạn → Hệ thống hiển thị thông báo lỗi và yêu cầu đăng nhập lại.
    - 3.a1: Dữ liệu đầu vào không thỏa mãn ràng buộc nghiệp vụ → Hệ thống báo lỗi chi tiết tại từng trường nhập liệu.
    - 4.a1: Đối tượng yêu cầu không tồn tại trong hệ thống → Hiển thị thông báo không tìm thấy bản ghi tương ứng.

**Post-Conditions**

- Trạng thái hệ thống được cập nhật chính xác theo kết quả xử lý của tính năng `Buy Credit`.
- Người dùng nhận được phản hồi trực quan trên giao diện và luồng nghiệp vụ được tiếp diễn theo kế hoạch.

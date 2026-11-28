**3.6.12 Add Material Repository**

**Function Trigger**

Begins when CREATOR / CLIENT / MANAGER thực hiện thao tác trên giao diện `Add Material Repository Page` liên quan đến tính năng `Add Material Repository`.

**Function Description**

- **Actors / Roles**: CREATOR / CLIENT / MANAGER.
- **Purpose**: Cung cấp khả năng thực hiện Add Material Repository cho người dùng trong hệ thống BrandHub.
- **Interface**: Giao diện `Add Material Repository Page` hiển thị trực quan các thành phần thao tác, dữ liệu và phản hồi trạng thái.
- **Data Processing**: Tiếp nhận yêu cầu tại `MaterialController`, xác thực quyền của caller, thực thi kiểm tra và xử lý nghiệp vụ thông qua `MaterialService`, truy xuất và cập nhật cơ sở dữ liệu thông qua Repository tương ứng.

**Screen Layout**

Figure — Screen Layout (`Add Material Repository Page`):

- Header: Tiêu đề trang, breadcrumb điều hướng và thông tin định danh ngữ cảnh làm việc.
- Main Workspace: Khu vực hiển thị bảng dữ liệu, biểu mẫu nhập liệu hoặc danh sách đối tượng nghiệp vụ.
- Action Panel: Các nút điều khiển thực hiện hành động chính, nút hủy và các bộ lọc tìm kiếm.
- Feedback Area: Khu vực hiển thị trạng thái xử lý (loading spinner, modal xác nhận, toast thông báo kết quả).

**Function Details**
- **Data Specifications**
    - **Input required**: Các trường bắt buộc theo đặc tả của `POST /api/v1/workspaces/{workspaceId}/materials`.
    - **Input optional**: Các tham số lọc, phân trang hoặc ghi chú bổ sung.
    - **System data**: Bản ghi dữ liệu liên quan tại các bảng cơ sở dữ liệu (`Web dashboard, S3 storage, WorkspaceRepository, MaterialRepository`).
    - **Output**: `ApiResponse` kèm mã trạng thái HTTP tiêu chuẩn.

- **Business Rules**
    - **BR-3612**: Chỉ các Actor có thẩm quyền hợp lệ (`CREATOR / CLIENT / MANAGER`) mới được phép kích hoạt tính năng.
    - Đảm bảo tính toàn vẹn dữ liệu và kiểm tra xung đột trạng thái trước khi thực hiện thay đổi dữ liệu.
    - Mọi thao tác đều được ghi nhận nhật ký hệ thống phục vụ công tác kiểm toán và giám sát.

- **Validation**
    - Thiếu hoặc sai định dạng tham số bắt buộc → Trả về HTTP 400 `BAD_REQUEST`.
    - Token không hợp lệ hoặc hết hạn → Trả về HTTP 401 `UNAUTHORIZED`.
    - Không đủ thẩm quyền vai trò → Trả về HTTP 403 `FORBIDDEN`.
    - Bản ghi đối tượng không tồn tại → Trả về HTTP 404 `NOT_FOUND`.

**Functionalities**
- **Normal Flow**
    1. Gửi yêu cầu `Check session, scope and add permission` từ `materialservice` tới `materialservice`.
    2. Gửi yêu cầu `Validate file format, size and metadata` từ `materialservice` tới `materialservice`.
    3. Gửi yêu cầu `Confirm file upload (repeat per file)` từ `creatorclientmanager` tới `webdashboard`.
    4. Gửi yêu cầu `POST /api/v1/workspaces/{workspaceId}/materials` từ `webdashboard` tới `materialcontroller`.

- **Abnormal Cases**
    - 2.a1: Token xác thực không hợp lệ hoặc hết hạn → Hệ thống hiển thị thông báo lỗi và yêu cầu đăng nhập lại.
    - 3.a1: Dữ liệu đầu vào không thỏa mãn ràng buộc nghiệp vụ → Hệ thống báo lỗi chi tiết tại từng trường nhập liệu.
    - 4.a1: Đối tượng yêu cầu không tồn tại trong hệ thống → Hiển thị thông báo không tìm thấy bản ghi tương ứng.

**Post-Conditions**

- Trạng thái hệ thống được cập nhật chính xác theo kết quả xử lý của tính năng `Add Material Repository`.
- Người dùng nhận được phản hồi trực quan trên giao diện và luồng nghiệp vụ được tiếp diễn theo kế hoạch.

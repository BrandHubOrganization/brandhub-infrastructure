**3.5.2 View the template Media package**

**Function Trigger**

Begins when WorkspaceMember thực hiện thao tác trên giao diện `WorkspacePackageUI` liên quan đến tính năng `View the template Media package`.

**Function Description**

- **Actors / Roles**: WorkspaceMember.
- **Purpose**: Client (chiến lược truyền thông mẫu như là dài, ngắn). Để giúp cho Client có thể coi được mẫu chiến dịch truyền thông được triển khai sẽ tổ chức với quy mô thế nào, nhân sự ra sao, hình dùng trước được sẽ book agency này trong bao lâu. Có cũng gói là phó mặt toàn bộ cho agency thực hiện miễn là đủ KPI. 
=> các gói truyền thông sẽ chia theo nhiều kiểu: 
+ Trong khoản thời gian sẽ làm những gì
+ Với số tiền sẽ làm những gì
+ Phó mặt toàn bộ.
- **Interface**: Giao diện `WorkspacePackageUI` hiển thị trực quan các thành phần thao tác, dữ liệu và phản hồi trạng thái.
- **Data Processing**: Tiếp nhận yêu cầu tại `MediaPackageController`, xác thực quyền của caller, thực thi kiểm tra và xử lý nghiệp vụ thông qua `MediaPackageService`, truy xuất và cập nhật cơ sở dữ liệu thông qua Repository tương ứng.

**Screen Layout**

Figure — Screen Layout (`WorkspacePackageUI`):

- Header: Tiêu đề trang, breadcrumb điều hướng và thông tin định danh ngữ cảnh làm việc.
- Main Workspace: Khu vực hiển thị bảng dữ liệu, biểu mẫu nhập liệu hoặc danh sách đối tượng nghiệp vụ.
- Action Panel: Các nút điều khiển thực hiện hành động chính, nút hủy và các bộ lọc tìm kiếm.
- Feedback Area: Khu vực hiển thị trạng thái xử lý (loading spinner, modal xác nhận, toast thông báo kết quả).

**Function Details**
- **Data Specifications**
    - **Input required**: Các trường bắt buộc theo đặc tả của `GET /api/v1/workspaces/{workspaceId}/media-package`.
    - **Input optional**: Các tham số lọc, phân trang hoặc ghi chú bổ sung.
    - **System data**: Bản ghi dữ liệu liên quan tại các bảng cơ sở dữ liệu (`MediaPackageRepository, WorkspaceMediaPackageRepository`).
    - **Output**: `WorkspaceMediaPackageResponse` kèm mã trạng thái HTTP tiêu chuẩn.

- **Business Rules**
    - **BR-352**: Chỉ các Actor có thẩm quyền hợp lệ (`WorkspaceMember`) mới được phép kích hoạt tính năng.
    - Đảm bảo tính toàn vẹn dữ liệu và kiểm tra xung đột trạng thái trước khi thực hiện thay đổi dữ liệu.
    - Mọi thao tác đều được ghi nhận nhật ký hệ thống phục vụ công tác kiểm toán và giám sát.

- **Validation**
    - Thiếu hoặc sai định dạng tham số bắt buộc → Trả về HTTP 400 `BAD_REQUEST`.
    - Token không hợp lệ hoặc hết hạn → Trả về HTTP 401 `UNAUTHORIZED`.
    - Không đủ thẩm quyền vai trò → Trả về HTTP 403 `FORBIDDEN`.
    - Bản ghi đối tượng không tồn tại → Trả về HTTP 404 `NOT_FOUND`.

**Functionalities**
- **Normal Flow**
    1. Người dùng mở giao diện `WorkspacePackageUI`.
    2. Giao diện gửi yêu cầu `GET /api/v1/workspaces/{workspaceId}/media-package` tới `MediaPackageController`.
    3. `MediaPackageController` điều phối xử lý sang `MediaPackageService.getWorkspacePackage()`.
    4. Hệ thống thực hiện kiểm tra và xử lý dữ liệu nghiệp vụ.
    5. Hệ thống trả dữ liệu `WorkspaceMediaPackageResponse` về giao diện hiển thị cho người dùng.

- **Abnormal Cases**
    - 2.a1: Token xác thực không hợp lệ hoặc hết hạn → Hệ thống hiển thị thông báo lỗi và yêu cầu đăng nhập lại.
    - 3.a1: Dữ liệu đầu vào không thỏa mãn ràng buộc nghiệp vụ → Hệ thống báo lỗi chi tiết tại từng trường nhập liệu.
    - 4.a1: Đối tượng yêu cầu không tồn tại trong hệ thống → Hiển thị thông báo không tìm thấy bản ghi tương ứng.

**Post-Conditions**

- Trạng thái hệ thống được cập nhật chính xác theo kết quả xử lý của tính năng `View the template Media package`.
- Người dùng nhận được phản hồi trực quan trên giao diện và luồng nghiệp vụ được tiếp diễn theo kế hoạch.

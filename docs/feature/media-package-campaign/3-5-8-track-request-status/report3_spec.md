**3.5.8 Track Request Status**

**Function Trigger**

Begins when Mânger thực hiện thao tác trên giao diện `ContentRequestPage (UI)` liên quan đến tính năng `Track Request Status`.

**Function Description**

- **Actors / Roles**: Mânger.
- **Purpose**: Manager điều chỉnh status của các yêu cầu do client đưa lên thêm công việc mới, điều chỉnh từ pending -> in progress -> accept (chuyển công việc vào trong list backlog) 

ở các trạng thái 
- pending 
- in progress
- accept 
- denied
4 chế độ này do agency setting chứ client không được set 
Templete media pakage: Bào gồm số lượng bài, thời gian thực hiện, chất lượng nối dung, ....
<team truyền thông thảo luận để cụ thể các bài viết>
Cho ra một kế hoạch truyền thông: Bao gồm tiêu đề bài viết, nền tảng đăng tải, ...
<thảo luận với client kế hoạch này có ok không ?>
cho ra hợp đồng chỉnh thức để ký.
- **Interface**: Giao diện `ContentRequestPage (UI)` hiển thị trực quan các thành phần thao tác, dữ liệu và phản hồi trạng thái.
- **Data Processing**: Tiếp nhận yêu cầu tại `ContentRequestController`, xác thực quyền của caller, thực thi kiểm tra và xử lý nghiệp vụ thông qua `ContentRequestService`, truy xuất và cập nhật cơ sở dữ liệu thông qua Repository tương ứng.

**Screen Layout**

Figure — Screen Layout (`ContentRequestPage (UI)`):

- Header: Tiêu đề trang, breadcrumb điều hướng và thông tin định danh ngữ cảnh làm việc.
- Main Workspace: Khu vực hiển thị bảng dữ liệu, biểu mẫu nhập liệu hoặc danh sách đối tượng nghiệp vụ.
- Action Panel: Các nút điều khiển thực hiện hành động chính, nút hủy và các bộ lọc tìm kiếm.
- Feedback Area: Khu vực hiển thị trạng thái xử lý (loading spinner, modal xác nhận, toast thông báo kết quả).

**Function Details**
- **Data Specifications**
    - **Input required**: Các trường bắt buộc theo đặc tả của `PATCH /api/v1/workspaces/{workspaceId}/content-requests/{requestId}/status`.
    - **Input optional**: Các tham số lọc, phân trang hoặc ghi chú bổ sung.
    - **System data**: Bản ghi dữ liệu liên quan tại các bảng cơ sở dữ liệu (`TaskRepository, ContentRequestRepository`).
    - **Output**: `ContentRequestResponse` kèm mã trạng thái HTTP tiêu chuẩn.

- **Business Rules**
    - **BR-358**: Chỉ các Actor có thẩm quyền hợp lệ (`Mânger`) mới được phép kích hoạt tính năng.
    - Đảm bảo tính toàn vẹn dữ liệu và kiểm tra xung đột trạng thái trước khi thực hiện thay đổi dữ liệu.
    - Mọi thao tác đều được ghi nhận nhật ký hệ thống phục vụ công tác kiểm toán và giám sát.

- **Validation**
    - Thiếu hoặc sai định dạng tham số bắt buộc → Trả về HTTP 400 `BAD_REQUEST`.
    - Token không hợp lệ hoặc hết hạn → Trả về HTTP 401 `UNAUTHORIZED`.
    - Không đủ thẩm quyền vai trò → Trả về HTTP 403 `FORBIDDEN`.
    - Bản ghi đối tượng không tồn tại → Trả về HTTP 404 `NOT_FOUND`.

**Functionalities**
- **Normal Flow**
    1. Gửi yêu cầu `claimAcceptanceAtomic(workspaceId, requestId)` từ `contentrequestservic` tới `contentrequestservic`.

- **Abnormal Cases**
    - 2.a1: Token xác thực không hợp lệ hoặc hết hạn → Hệ thống hiển thị thông báo lỗi và yêu cầu đăng nhập lại.
    - 3.a1: Dữ liệu đầu vào không thỏa mãn ràng buộc nghiệp vụ → Hệ thống báo lỗi chi tiết tại từng trường nhập liệu.
    - 4.a1: Đối tượng yêu cầu không tồn tại trong hệ thống → Hiển thị thông báo không tìm thấy bản ghi tương ứng.

**Post-Conditions**

- Trạng thái hệ thống được cập nhật chính xác theo kết quả xử lý của tính năng `Track Request Status`.
- Người dùng nhận được phản hồi trực quan trên giao diện và luồng nghiệp vụ được tiếp diễn theo kế hoạch.

**3.5.6 Approve Media Campaign**

**Function Trigger**

Begins when User (Client / Manager) thực hiện thao tác trên giao diện `MediaCampaignUI` liên quan đến tính năng `Approve Media Campaign`.

**Function Description**

- **Actors / Roles**: User (Client / Manager).
- **Purpose**: Sau khi đưa chiến lược ra và cả 2 bên đồng ý thì tiến hành nhấn triển khai và toàn bộ các công việc để trong media campaign đó sẽ được đẩy vào trong workspace thành một bảng backlog công việc (giống với jira) nhưng chưa đầy đủ quy trình triển khai , yêu cầu cụ thể mà mới chỉ là các công việc, thời gian thông thường.
- **Interface**: Giao diện `MediaCampaignUI` hiển thị trực quan các thành phần thao tác, dữ liệu và phản hồi trạng thái.
- **Data Processing**: Tiếp nhận yêu cầu tại `MediaCampaignController`, xác thực quyền của caller, thực thi kiểm tra và xử lý nghiệp vụ thông qua `MediaCampaignService`, truy xuất và cập nhật cơ sở dữ liệu thông qua Repository tương ứng.

**Screen Layout**

Figure — Screen Layout (`MediaCampaignUI`):

- Header: Tiêu đề trang, breadcrumb điều hướng và thông tin định danh ngữ cảnh làm việc.
- Main Workspace: Khu vực hiển thị bảng dữ liệu, biểu mẫu nhập liệu hoặc danh sách đối tượng nghiệp vụ.
- Action Panel: Các nút điều khiển thực hiện hành động chính, nút hủy và các bộ lọc tìm kiếm.
- Feedback Area: Khu vực hiển thị trạng thái xử lý (loading spinner, modal xác nhận, toast thông báo kết quả).

**Function Details**
- **Data Specifications**
    - **Input required**: Các trường bắt buộc theo đặc tả của `POST /api/v1/media-campaigns/{campaignId}/approve`.
    - **Input optional**: Các tham số lọc, phân trang hoặc ghi chú bổ sung.
    - **System data**: Bản ghi dữ liệu liên quan tại các bảng cơ sở dữ liệu (`TaskRepository (MongoDB), MediaCampaignRepository`).
    - **Output**: `MediaCampaignResponse` kèm mã trạng thái HTTP tiêu chuẩn.

- **Business Rules**
    - **BR-356**: Chỉ các Actor có thẩm quyền hợp lệ (`User (Client / Manager)`) mới được phép kích hoạt tính năng.
    - Đảm bảo tính toàn vẹn dữ liệu và kiểm tra xung đột trạng thái trước khi thực hiện thay đổi dữ liệu.
    - Mọi thao tác đều được ghi nhận nhật ký hệ thống phục vụ công tác kiểm toán và giám sát.

- **Validation**
    - Thiếu hoặc sai định dạng tham số bắt buộc → Trả về HTTP 400 `BAD_REQUEST`.
    - Token không hợp lệ hoặc hết hạn → Trả về HTTP 401 `UNAUTHORIZED`.
    - Không đủ thẩm quyền vai trò → Trả về HTTP 403 `FORBIDDEN`.
    - Bản ghi đối tượng không tồn tại → Trả về HTTP 404 `NOT_FOUND`.

**Functionalities**
- **Normal Flow**
    1. Gửi yêu cầu `set approvedByClientAt = now` từ `mediacampaignservice` tới `mediacampaignservice`.
    2. Gửi yêu cầu `set approvedByAgencyAt = now` từ `mediacampaignservice` tới `mediacampaignservice`.
    3. Gửi yêu cầu `set status = IN_PROGRESS` từ `mediacampaignservice` tới `mediacampaignservice`.

- **Abnormal Cases**
    - 2.a1: Token xác thực không hợp lệ hoặc hết hạn → Hệ thống hiển thị thông báo lỗi và yêu cầu đăng nhập lại.
    - 3.a1: Dữ liệu đầu vào không thỏa mãn ràng buộc nghiệp vụ → Hệ thống báo lỗi chi tiết tại từng trường nhập liệu.
    - 4.a1: Đối tượng yêu cầu không tồn tại trong hệ thống → Hiển thị thông báo không tìm thấy bản ghi tương ứng.

**Post-Conditions**

- Trạng thái hệ thống được cập nhật chính xác theo kết quả xử lý của tính năng `Approve Media Campaign`.
- Người dùng nhận được phản hồi trực quan trên giao diện và luồng nghiệp vụ được tiếp diễn theo kế hoạch.

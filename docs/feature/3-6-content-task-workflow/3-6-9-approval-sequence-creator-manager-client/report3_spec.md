**3.6.9 Approval Sequence (Creator -> Manager -> Client)**

**Function Trigger**

Begins when Creator (Author), Creator (QC Reviewer), Manager (Agency), Creator (Author), Manager (Agency), Creator (Author), Client (Brand), Creator (Author), Client (Brand) thực hiện thao tác trên giao diện `TaskDetailPage (UI)` liên quan đến tính năng `Approval Sequence (Creator -> Manager -> Client)`.

**Function Description**

- **Actors / Roles**: Creator (Author), Creator (QC Reviewer), Manager (Agency), Creator (Author), Manager (Agency), Creator (Author), Client (Brand), Creator (Author), Client (Brand).
- **Purpose**: Mọi công việc khi làm xong thì phải duyệt theo phân cấp từ Creator -> Creator (là người được gán quyền quản lý chất lượng, coi lại check nếu có) -> Manager -> Client (nếu task đó có yêu cầu cần duyệt thông qua khách hàng). Xong đủ quy trình này thì mới đưa vào task được hoàn thành. nếu bị trả về lại thì quay lại quy trình như ban đầu. khi trả lại thì trả lại từ trước đầu người làm creator ở bước đầu tiên.
- **Interface**: Giao diện `TaskDetailPage (UI)` hiển thị trực quan các thành phần thao tác, dữ liệu và phản hồi trạng thái.
- **Data Processing**: Tiếp nhận yêu cầu tại `TaskApprovalController`, xác thực quyền của caller, thực thi kiểm tra và xử lý nghiệp vụ thông qua `TaskApprovalServiceImpl`, truy xuất và cập nhật cơ sở dữ liệu thông qua Repository tương ứng.

**Screen Layout**

Figure — Screen Layout (`TaskDetailPage (UI)`):

- Header: Tiêu đề trang, breadcrumb điều hướng và thông tin định danh ngữ cảnh làm việc.
- Main Workspace: Khu vực hiển thị bảng dữ liệu, biểu mẫu nhập liệu hoặc danh sách đối tượng nghiệp vụ.
- Action Panel: Các nút điều khiển thực hiện hành động chính, nút hủy và các bộ lọc tìm kiếm.
- Feedback Area: Khu vực hiển thị trạng thái xử lý (loading spinner, modal xác nhận, toast thông báo kết quả).

**Function Details**
- **Data Specifications**
    - **Input required**: Các trường bắt buộc theo đặc tả của `GET /api/v1/resource`.
    - **Input optional**: Các tham số lọc, phân trang hoặc ghi chú bổ sung.
    - **System data**: Bản ghi dữ liệu liên quan tại các bảng cơ sở dữ liệu (`TaskRepository, TaskApprovalRepository, TaskRepository, TaskApprovalRepository, TaskRepository, TaskApprovalRepository, TaskRepository`).
    - **Output**: `200 OK (Final approval granted, task COMPLETED` kèm mã trạng thái HTTP tiêu chuẩn.

- **Business Rules**
    - **BR-369**: Chỉ các Actor có thẩm quyền hợp lệ (`Creator (Author), Creator (QC Reviewer), Manager (Agency), Creator (Author), Manager (Agency), Creator (Author), Client (Brand), Creator (Author), Client (Brand)`) mới được phép kích hoạt tính năng.
    - Đảm bảo tính toàn vẹn dữ liệu và kiểm tra xung đột trạng thái trước khi thực hiện thay đổi dữ liệu.
    - Mọi thao tác đều được ghi nhận nhật ký hệ thống phục vụ công tác kiểm toán và giám sát.

- **Validation**
    - Thiếu hoặc sai định dạng tham số bắt buộc → Trả về HTTP 400 `BAD_REQUEST`.
    - Token không hợp lệ hoặc hết hạn → Trả về HTTP 401 `UNAUTHORIZED`.
    - Không đủ thẩm quyền vai trò → Trả về HTTP 403 `FORBIDDEN`.
    - Bản ghi đối tượng không tồn tại → Trả về HTTP 404 `NOT_FOUND`.

**Functionalities**
- **Normal Flow**
    1. Người dùng mở giao diện `TaskDetailPage (UI)`.
    2. Giao diện gửi yêu cầu `GET /api/v1/resource` tới `TaskApprovalController`.
    3. `TaskApprovalController` điều phối xử lý sang `TaskApprovalServiceImpl.processRequest()`.
    4. Hệ thống thực hiện kiểm tra và xử lý dữ liệu nghiệp vụ.
    5. Hệ thống trả dữ liệu `200 OK (Final approval granted, task COMPLETED` về giao diện hiển thị cho người dùng.

- **Abnormal Cases**
    - 2.a1: Token xác thực không hợp lệ hoặc hết hạn → Hệ thống hiển thị thông báo lỗi và yêu cầu đăng nhập lại.
    - 3.a1: Dữ liệu đầu vào không thỏa mãn ràng buộc nghiệp vụ → Hệ thống báo lỗi chi tiết tại từng trường nhập liệu.
    - 4.a1: Đối tượng yêu cầu không tồn tại trong hệ thống → Hiển thị thông báo không tìm thấy bản ghi tương ứng.

**Post-Conditions**

- Trạng thái hệ thống được cập nhật chính xác theo kết quả xử lý của tính năng `Approval Sequence (Creator -> Manager -> Client)`.
- Người dùng nhận được phản hồi trực quan trên giao diện và luồng nghiệp vụ được tiếp diễn theo kế hoạch.

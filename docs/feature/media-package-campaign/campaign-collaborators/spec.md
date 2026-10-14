# E50-09 / DA-950 — Theo dõi đối tác Campaign

## 1. Nguồn và phạm vi

Nguồn: master-plan DA-E50-09; BA 07 (third-party collaborator), BA 12 mục 6.
Đối tác là đơn vị bên ngoài Agency, không phải thành viên Workspace.
E50-08 quản lý danh bạ; E50-09 chỉ đọc danh bạ sẵn có, gán đối tác và theo dõi hợp tác.
Không làm AI recommendation, booking, gửi liên hệ, thanh toán hoặc tự động publish.

## 2. Luồng

Trong Workspace đã chốt Package, mở **Đối tác chiến dịch**. Khi Campaign tồn tại,
Manager/Creator chọn đối tác của Agency, gán vào Campaign và cập nhật thủ công.
Client xem danh sách/trạng thái, không được gán hoặc sửa. Owner được quản lý theo
quyền Workspace; nếu chưa có membership, chủ Agency được quyền quản lý.

## 3. Acceptance criteria

- AC1: Một cặp Campaign/đối tác có một bản ghi; gán lặp trả lại bản ghi cũ,
  không reset trạng thái. Đối tác chỉ thuộc cùng Agency với Workspace.
- AC2: Các trạng thái CONTACTED, NEGOTIATING, CONFIRMED, LIVE; cho phép quay lại
  trạng thái trước theo BA 12, không áp đặt máy trạng thái một chiều.
- AC3: Cùng đối tác ở Campaign khác có trạng thái độc lập. Lưu người/thời gian
  cập nhật; thay đổi hợp tác không sửa nội dung hoặc reset approvals Campaign.
- AC4: Manager/Creator và Owner hợp lệ được ghi; Client chỉ đọc; người ngoài,
  membership hết hiệu lực, Workspace/Agency không hoạt động bị từ chối.
- AC5: Danh sách phân trang, có tên/loại đối tác; giao diện có trạng thái loading,
  empty, retry và thông báo lỗi; chưa có Campaign thì không cho gán.
- AC6: API Workspace kiểm tra Campaign và liên kết đúng scope. Cập nhật từ phiên
  cũ bị 409, không ghi đè âm thầm; dữ liệu đầu vào không hợp lệ bị 400.

## 4. Dữ liệu

Tái sử dụng PostgreSQL third_party_collaborators và campaign_collaborators,
enum cooperation_status và UNIQUE(media_campaign_id, collaborator_id).
Không init Mongo, không seed/xóa dữ liệu, không đổi schema nếu schema V2 đã có.

## 5. Ngoại lệ và quyết định triển khai

Workspace chưa có Package/Campaign trả danh sách rỗng có context, không lỗi 500.
Không khóa theo Campaign status: đây là theo dõi vận hành độc lập với duyệt kế hoạch.
Không bổ sung thao tác xóa liên kết ngoài AC. Danh bạ rỗng hướng dẫn hoàn thành E50-08.
API legacy giữ hợp đồng cũ; endpoint Workspace mới yêu cầu expectedUpdatedAt.

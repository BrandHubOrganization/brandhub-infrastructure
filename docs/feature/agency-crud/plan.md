# Plan — Agency Owner Client Management (CRUD & Assignment)

## Mục tiêu
Triển khai các API quản lý Brand Clients dành cho role `AGENCY_OWNER` và `ACCOUNT_MANAGER`, bao gồm: tạo client (giới hạn theo gói subscription), phân công Account Manager, cấu hình gói dịch vụ (post limit & platforms) và danh sách client được phân quyền.

## Thành phần liên quan
- **ClientController**: Định nghĩa các endpoint `/api/v1/clients`.
- **ClientService & WorkspaceService**: Logic kiểm tra limit subscription, phân công AM, kiểm tra workspace.
- **ClientRepository / MongoTemplate**: Truy vấn danh sách client phân trang + dynamic criteria filter.
- **Security / JWT Filter**: Inject `workspaceId` & `userId` từ token, phân quyền RBAC (`AGENCY_OWNER`, `ACCOUNT_MANAGER`).
- **Notification Module**: Gửi email thông báo cho Account Manager khi được assign client mới.

## Các API chính
1. `POST /api/v1/clients` (DA-E16-01): Tạo client mới + check subscription limit.
2. `PUT /api/v1/clients/{id}/assign` (DA-E16-02): Gán Account Manager cho client.
3. `PUT /api/v1/clients/{id}/service-package` (DA-E16-03): Cấu hình post limit & allowed platforms cho client.
4. `GET /api/v1/clients` (DA-E16-04): Lấy danh sách clients (Phân quyền theo role).

## Thứ tự triển khai
1. Build `POST /api/v1/clients` (Blocking cho các task khác).
2. Build `GET /api/v1/clients`.
3. Build `PUT /api/v1/clients/{id}/assign` & `PUT /api/v1/clients/{id}/service-package`.

## Rủi ro & Lưu ý kỹ thuật
- **Database Isolation & Locking**: Dùng PostgreSQL JPA (`ClientRepository`), khóa lạc quan (Optimistic locking) hoặc `@Transactional` cách ly `workspaceId` lấy từ JWT.
- **Workspace Isolation**: Tất cả query đều phải lồng filter `workspaceId` lấy từ JWT, tuyệt đối không nhận `workspaceId` từ request body.
- **Phân quyền GET**: `AGENCY_OWNER` xem tất cả clients trong workspace, `ACCOUNT_MANAGER` chỉ xem client do mình quản lý.

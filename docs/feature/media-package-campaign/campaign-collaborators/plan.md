# Kế hoạch E50-09 / DA-950

## Hiện trạng

Entity, enum, FK và unique pair đã có trong init PostgreSQL V2. Repository chưa
có truy vấn nghiệp vụ; CollaboratorServiceImpl đang stub. Gateway đã forward
/api/v1/** sang Business Service. Campaign page không dành cho Creator, nên thêm
trang theo dõi đối tác riêng để không mở quyền sửa/approve kế hoạch cho Creator.

## Backend

- CampaignCollaboratorAccess: kiểm tra Workspace/Agency active, membership thực
  trong DB (kể cả ClientProfile), Owner fallback. Không tin role/scope trong JWT.
- CampaignCollaboratorService: context Campaign hiện tại, danh bạ theo Agency,
  danh sách liên kết phân trang; join projection tránh N+1 và không lộ contact
  nội bộ của danh bạ cho Client.
- Gán: khóa hàng Campaign, validate cùng Agency, trả lại liên kết đã tồn tại;
  UNIQUE trong DB là lớp bảo vệ cuối. Cập nhật: khóa link, kiểm tra scope và
  expectedUpdatedAt, ghi timestamp microsecond phù hợp PostgreSQL.
- GET /workspaces/{id}/campaign-collaborators?page=0&size=20 trả context + page.
- GET /workspaces/{id}/collaborators?page=0&size=20 dành cho người có quyền ghi.
- POST /workspaces/{id}/campaigns/{campaignId}/collaborators: {collaboratorId}.
- PUT /workspaces/{id}/campaigns/{campaignId}/collaborators/{linkId}:
  {cooperationStatus, expectedUpdatedAt}.
- Legacy /collaborators/assign và /collaborators/campaign/{id}/cooperation
  delegate cùng service; legacy update không có token vẫn giữ last-write-wins.

## Frontend

Route /workspaces/:id/campaign-partners, sidebar và access rule cho
Owner/Manager/Creator/Client; giữ Package gate hiện có. Trang dùng quyền canEdit
từ backend; Client chỉ thấy danh sách. Chọn đối tác phân trang; mỗi hàng có
trạng thái đang lưu và thông tin cập nhật. Cung cấp liên kết từ Campaign page.
Locale en/vi, responsive và semantic theme tokens.

## Verification và rollout

Unit tests access/scoping/idempotence/reversible state/concurrency, controller
validation, Playwright mock flow cho Manager/Creator/Client/empty/error.
Chạy Maven, lint, type-check, build, browser tests. Không tự sửa dữ liệu thật.
E50-08 CRUD vẫn là dependency để người dùng tự bổ sung danh bạ nếu đang rỗng.

## Delta DA-949/950 — thiết kế 2026-10-13, chưa implementation

Theo [partner-directory/plan.md](../partner-directory/plan.md), picker chỉ active;
assign mới phải lock/verify partner active và ghi first_used_at cùng transaction.
Phối hợp lock ordering với delete/deactivate để không deadlock. Trả link đã tồn tại
idempotently, kể cả partner inactive; giữ đọc/cập nhật hợp tác của link cũ.
Legacy assign dùng cùng rule. Chỉ bổ sung parallel vi/en campaign.json cho badge
inactive/lỗi unavailable và regression light/dark/mobile; không thay quyền DA-950.

OpenAPI đã đồng bộ tại `brandhub-business-service/docs/openapi.yaml` cho bốn
endpoint mới. Opt-in `CampaignCollaboratorPostgresTest` chạy service với JPA thật
trong transaction rollback-only, không khởi động seeders hoặc kết nối Mongo.
HQL validation không có JDBC/DDL giúp kiểm tra projection/joins khi Docker tắt.

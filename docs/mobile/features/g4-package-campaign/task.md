# Task — G4 Media Package / Campaign: View + Approve (Mobile)

> [spec.md](./spec.md)

## Media Package screens

- [ ] Package List theo Workspace — `GET /api/v1/workspaces/{workspaceId}/media-packages`.
- [ ] Package Detail — `GET /api/v1/workspaces/{workspaceId}/media-package`, hiển thị `negotiationStatus`, `finalTerms`, `approvedByAgencyAt`/`approvedByClientAt`.
- [ ] Nút Approve Package — ẩn/hiện theo `approvedBy{Side}At == null`; **đọc `ApproveMediaPackageRequest` DTO thật trước khi code** (mục 8 câu 2, chưa xác nhận có `expectedVersion` hay không).

## Media Campaign screens

- [ ] Campaign List theo Workspace — `GET /api/v1/workspaces/{workspaceId}/campaigns` (**dùng `WorkspaceCampaignController`, KHÔNG dùng `MediaCampaignController`** — xem mục 8 câu 1).
- [ ] Campaign Detail — `GET .../campaigns/{campaignId}`, các section: Strategy, Brand Guideline, Timeline (parse jsonb), Deliverables (`deliverablePlan`+`allocations`+`allocationPeriod`), Work Items.
- [ ] Nút Approve Campaign — role-gated: OWNER/MANAGER thấy "Agency duyệt" nếu `approvedByAgencyAt==null`, CLIENT thấy "Client duyệt" nếu `approvedByClientAt==null`; ẩn nút + hiện "Đã duyệt lúc ..." nếu phía mình đã duyệt.
- [ ] Mutation approve — `POST .../approve` body `{ expectedVersion: campaign.contentVersion }` (đọc tại thời điểm bấm nút, **không dùng `rowVersion`**).

## Error handling approve

- [ ] `onError` HTTP 409 `CAMPAIGN_VERSION_CONFLICT` — refetch campaign detail, hiện lại UI với `contentVersion`/`approvedBy*At` mới nhất, yêu cầu user bấm Approve lại (không tự động retry).
- [ ] Disable nút khi mutation pending (UX, server đã idempotent theo phía nên không bắt buộc nhưng nên làm).
- [ ] `onSuccess` — `invalidateQueries(['campaign', workspaceId, campaignId])` + `invalidateQueries(['campaigns', workspaceId])`.

## Business rules cần enforce ở client

- [ ] Dual approval không theo thứ tự — Agency/Client approve độc lập, status giữ `DRAFT` tới khi đủ cả 2.
- [ ] `CampaignStatus` chỉ 4 giá trị: `DRAFT, APPROVED, IN_PROGRESS, COMPLETED` — UI không hiển thị trạng thái "chờ duyệt 1 phía" riêng, vẫn là DRAFT.
- [ ] Campaign ở `IN_PROGRESS`/`COMPLETED` không hiện nút Approve (server trả `CAMPAIGN_IMMUTABLE` nếu cố gọi).
- [ ] Approve KHÔNG tự động đẩy Task — deploy là hành động riêng, không thuộc G4, không hiển thị gộp 2 bước làm 1.

## Chưa làm / out of scope G4 (xem spec mục 7)

- [ ] Không làm: tạo Campaign mới, sửa Campaign draft, gửi feedback Campaign, deploy Campaign, complete/cancel Campaign, request/negotiate Package, tạo custom Package.

## Rủi ro cần chốt trước khi code (xem spec mục 8)

1. 2 controller Campaign trùng route (`/media-campaigns/...` vs `/workspaces/{id}/campaigns/...`) — xác nhận với backend route nào chính thức, tránh tích hợp sai route cũ.
2. `ApproveMediaPackageRequest` DTO chưa đọc field chi tiết — đọc trước khi code approve Package.
3. BA mô tả "approve tự đẩy backlog" khác code (approve/deploy tách riêng) — cần BA/PO xác nhận chủ định.
4. `PackageDeliverable`/`CampaignWorkItem`/`DeliverableAllocation` DTO con chưa đọc chi tiết — đọc trước khi thiết kế UI render từng field.
5. Push notification khi phía kia approve — chưa cover trong G4, để domain notification sau xử lý nếu cần real-time alert.

# Plan — G4 Media Package/Campaign: View + Approve (Mobile)

> [spec.md](./spec.md) — chi tiết API/flows/business rules đầy đủ. File này là bản tóm tắt thứ tự implement + quyết định kỹ thuật chốt.

## Thứ tự implement (theo dependency)

1. **Package screens trước** (đơn giản hơn Campaign, không có optimistic lock phức tạp):
   - Package List + Detail (`negotiationStatus`, `finalTerms`, `approvedBy*At`).
   - Nút Approve Package — **chặn bởi `ApproveMediaPackageRequest` DTO chưa đọc field chi tiết**, phải đọc trước khi code mutation.
2. **Campaign screens:**
   - Campaign List + Detail (Strategy/BrandGuideline/Timeline/Deliverables/WorkItems).
   - Nút Approve Campaign role-gated theo `approvedByAgencyAt`/`approvedByClientAt`.
   - Mutation approve với `expectedVersion=contentVersion` (optimistic lock).
3. **Error handling:**
   - 409 `CAMPAIGN_VERSION_CONFLICT` → refetch, không tự động retry.
   - Invalidate cache sau approve thành công.

## Quyết định kỹ thuật đã chốt

- **Dùng `WorkspaceCampaignController` (`/workspaces/{id}/campaigns/...`), KHÔNG dùng `MediaCampaignController` (`/media-campaigns/...`)** — route thứ 2 có vẻ cũ/dự phòng, không được web gọi (xác nhận bằng cách đọc `campaignService.ts` của web).
- **1 endpoint approve duy nhất cho cả 2 phía** — server tự xác định AGENCY/CLIENT từ `CampaignWorkspaceAccess.side()`, mobile KHÔNG gửi cờ "tôi là ai" trong body, chỉ gửi `expectedVersion`.
- **`expectedVersion` dùng `contentVersion` (field nghiệp vụ), KHÔNG dùng `rowVersion`** (Hibernate `@Version` nội bộ) — đọc tại thời điểm bấm nút Approve, không cache stale.
- **Approve KHÔNG tự động đẩy Task** — đó là hành động "deploy" riêng (`POST .../deploy`), ngoài scope G4. Khác với mô tả BA "approve → tự động đẩy backlog" — theo code thật, 2 bước tách biệt.
- **Server idempotent theo phía** — double-tap approve không lỗi, trả lại campaign hiện tại. Mobile vẫn nên disable nút khi pending cho UX, không bắt buộc để tránh lỗi server.

## Việc cần xác nhận trước khi code (chưa làm, xem spec mục 8)

- 2 controller Campaign trùng route — cần backend xác nhận route nào chính thức/sắp deprecate.
- `ApproveMediaPackageRequest` DTO — đọc field thật (có `expectedVersion` tương tự Campaign hay không) trước khi code approve Package.
- BA mô tả "approve tự đẩy backlog" khác code — cần BA/PO xác nhận đây là chủ định (2 bước tách biệt do an toàn) hay doc chưa cập nhật.
- `PackageDeliverable`/`CampaignWorkItem`/`DeliverableAllocation` DTO con chưa đọc chi tiết — đọc trước khi thiết kế UI render từng field trong Campaign Detail.

## Rủi ro còn mở

- Push notification khi phía kia approve — server có gọi `notifyOpposite(...)` nhưng G4 chưa cover tích hợp push mobile; để domain notification sau xử lý nếu cần real-time alert.

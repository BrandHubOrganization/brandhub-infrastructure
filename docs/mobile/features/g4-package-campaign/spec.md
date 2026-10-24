# G4 — Media Package / Media Campaign (Mobile): View + Approve

> Thuộc `docs/mobile/mobile-app-plan.md` giai đoạn G4 (xem bảng mục 3, dòng G4: "Media Package/Campaign: xem + approve (Owner/Client)").
> File này KHÔNG phải FR chính thức — tài liệu kỹ thuật mobile bổ sung.

## 1. Mục tiêu & phạm vi

Mobile G4 bao gồm:

1. **VIEW Media Package** — danh sách package khả dụng của Workspace, chi tiết `WorkspaceMediaPackage` (negotiation status, final terms, approval timestamps 2 phía).
2. **VIEW Media Campaign** — danh sách Campaign theo Workspace, chi tiết 1 Campaign: `strategyDetail`, `brandGuideline`, `timeline` (jsonb), `deliverablePlan`, `workItems`, `allocations`.
3. **APPROVE Media Campaign** — cả 2 chiều Agency (OWNER/MANAGER) và Client, dùng **cùng một API**, phân nhánh theo role của người gọi ở server (xem mục 3).

**Xác nhận scope "view + approve" only — đã verify đúng với BA:** theo
`docs/ba/04-media-package-campaign.md` mục 3 (3.5.5 Create Media Campaign), việc **tạo** Campaign là hành động của Agency dựng chiến lược chi tiết từ Package đã duyệt — không nằm trong scope mobile G4. Theo code, `WorkspaceCampaignController.create()` (POST tạo), `.update()` (PATCH sửa khi còn DRAFT) là các entrypoint ghi/soạn — **không đưa vào mobile G4**. Mobile G4 chỉ gọi các entrypoint đọc (list/detail) và đúng 1 entrypoint ghi duy nhất: approve.

Về Media Package: việc **select/negotiate** Package (FR 3.5.3) cũng là hành động ghi phức tạp (đàm phán nhiều vòng) — không đưa vào G4 mobile; G4 chỉ xem danh sách Package + xem trạng thái negotiation hiện tại của Workspace. Approve Package (FR 3.5.4) **có đưa vào scope** vì nằm cùng nhóm "approve" như Campaign — xem mục 3 và mục 6.

## 2. FR tham chiếu

- FR 3.5.1 – 3.5.4 (`docs/ba/04-media-package-campaign.md` mục 2): Create/View/Request/Approve Media Package.
- FR 3.5.5 – 3.5.6 (mục 3): Create/Approve Media Campaign — mobile dùng 3.5.6 (Approve) + phần "view" ngụ ý trong 3.5.5.
- FR 3.6.9 / mục 1 file `05-content-task-workflow.md`: nguồn gốc Task — "Từ Media Campaign approve" là nguồn Task #1 trong backlog (xem mục 6 dưới).
- Thứ tự chuẩn Workspace → Package → Campaign → Task (mục 1 của 04-media-package-campaign.md, CONFIRMED 2026-09-14).

## 3. API cần dùng

Codebase có **2 controller song song** cho Campaign — ground truth web (`brandhub-web/src/pages/campaign/services/campaignService.ts`) dùng `WorkspaceCampaignController`, nên mobile phải dùng route này, KHÔNG dùng `MediaCampaignController` (route `/api/v1/media-campaigns/...`, có vẻ là route cũ/dự phòng, không được web gọi).

Base path: `/api/v1/workspaces/{workspaceId}/campaigns`
(`brandhub-business-service/src/main/java/com/brandhub/business/controller/WorkspaceCampaignController.java`)

| Hành động | Method + path | Request | Response |
|---|---|---|---|
| List campaigns theo workspace | `GET /api/v1/workspaces/{workspaceId}/campaigns` | — | `ApiResponse<List<MediaCampaignResponse>>` |
| Xem chi tiết Campaign | `GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}` | — | `ApiResponse<MediaCampaignResponse>` |
| Approve Campaign (2 phía, cùng 1 endpoint) | `POST /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/approve` | `CampaignApprovalRequest { expectedVersion: Integer }` | `ApiResponse<MediaCampaignResponse>` |
| Lịch sử feedback/review event (tham khảo, không bắt buộc G4) | `GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/feedback` | — | `ApiResponse<List<CampaignReviewEvent>>` |

**Không có 2 endpoint riêng `approveByAgency` / `approveByClient`.** Chỉ có 1 endpoint `POST .../approve`. Server xác định "phía" (`AGENCY` hay `CLIENT`) từ chính người gọi, qua `CampaignWorkspaceAccess.side(workspaceId, user, write=false)`:
- role `OWNER`/`MANAGER` trong Workspace → side = `AGENCY`
- role `CLIENT` active trong Workspace → side = `CLIENT`
- Agency owner gọi trực tiếp (không qua membership) → side = `AGENCY`

→ Mobile **không gửi** cờ "tôi là agency/client" trong body — chỉ gửi `expectedVersion`. UI chỉ cần hiển thị đúng nút theo role đang đăng nhập (xem mục 4), server tự quyết nhánh nào được set.

`MediaCampaignResponse` fields đúng tên (file `dto/response/MediaCampaignResponse.java`):
`id, workspaceMediaPackageId, name, strategyDetail, brandGuideline, timeline, status, approvedByAgencyAt, approvedByClientAt, approvedByAgencyId, approvedByAgencyVersion, approvedByClientId, approvedByClientVersion, completedAt, completedBy, completionReason, completionTaskSummary, createdAt, updatedAt, packageTermsSnapshot, packageTermsVersion, allocationPeriod, allocations, deliverablePlan, workItems, contentVersion, workspaceId`.

Lưu ý quan trọng: optimistic lock dùng trong approve KHÔNG phải `rowVersion` (Hibernate `@Version`) mà là **`contentVersion`** — field business tự quản (tăng khi nội dung Campaign thay đổi). `CampaignApprovalRequest.expectedVersion` phải khớp `campaign.contentVersion` hiện tại, nếu không → lỗi `CAMPAIGN_VERSION_CONFLICT` (HTTP 409). Web gửi `expectedVersion: campaign.contentVersion` (xem `campaignService.ts` dòng `approve:`), mobile phải mirror đúng pattern này.

### Media Package API (view + approve)

Base: `MediaPackageController.java`

| Hành động | Method + path | Role | Response |
|---|---|---|---|
| List package template toàn Admin | `GET /api/v1/media-package-templates` | public/any | `List<MediaPackageResponse>` |
| List package custom của Agency | `GET /api/v1/agencies/{agencyId}/media-package-custom` | — | `List<MediaPackageResponse>` |
| List package khả dụng của Workspace | `GET /api/v1/workspaces/{workspaceId}/media-packages` | OWNER/MANAGER/CLIENT | `List<MediaPackageResponse>` |
| Xem Package hiện tại của Workspace (kèm negotiation state) | `GET /api/v1/workspaces/{workspaceId}/media-package` | OWNER/MANAGER/CLIENT | `WorkspaceMediaPackageResponse` |
| Approve Package (FR 3.5.4) | `POST /api/v1/workspaces/{workspaceId}/media-package/approve` | OWNER/MANAGER/CLIENT | `ApproveMediaPackageRequest` → `WorkspaceMediaPackageResponse` |

`WorkspaceMediaPackageResponse` fields: `workspaceMediaPackageId, workspaceId, mediaPackage, negotiationStatus, finalTerms, previousTerms, termsVersion, clientProposalCount, approvedByAgencyAt, approvedByClientAt, createdAt, updatedAt`. Cùng pattern dual-approval timestamp như Campaign (`approvedByAgencyAt`/`approvedByClientAt`), nhưng không thấy `rowVersion`/`expectedVersion` field tương ứng trong response — cần đọc `ApproveMediaPackageRequest` DTO thật khi implement (chưa đọc field request này, chỉ xác nhận endpoint tồn tại).

## 4. Luồng màn hình

```
Package List (theo Workspace đang chọn)
  ↓ chọn 1 Workspace (nếu nhiều) → GET .../media-packages hoặc GET .../media-package
Package Detail (negotiation status, final terms, nút Approve nếu CLIENT/OWNER/MANAGER và chưa approve phía mình)
  ↓
Campaign List (theo Workspace) → GET /api/v1/workspaces/{workspaceId}/campaigns
  ↓ chọn 1 Campaign
Campaign Detail — tabs/section:
  - Strategy (strategyDetail)
  - Brand Guideline (brandGuideline)
  - Timeline (parse jsonb timeline)
  - Deliverables (deliverablePlan + allocations + allocationPeriod)
  - Work Items (workItems)
  ↓
Approve action — role-gated:
  - OWNER/MANAGER (side=AGENCY) thấy nút "Agency duyệt" nếu approvedByAgencyAt == null
  - CLIENT (side=CLIENT) thấy nút "Client duyệt" nếu approvedByClientAt == null
  - Nếu phía mình đã duyệt rồi (timestamp != null) → ẩn nút, hiện trạng thái "Đã duyệt lúc ..."
  ↓ tap Approve → confirm dialog → POST .../approve { expectedVersion: campaign.contentVersion }
  ↓
Confirmation — refetch Campaign detail, hiển thị status mới (DRAFT → APPROVED khi cả 2 phía đã duyệt)
```

Màn Package Detail áp dụng pattern tương tự (approve theo `approvedByAgencyAt`/`approvedByClientAt` của `WorkspaceMediaPackageResponse`).

## 5. State & cache

TanStack Query key gợi ý (mirror theo cách tổ chức web `campaignService`/`campaignDraftService`):

- `['campaigns', workspaceId]` — list
- `['campaign', workspaceId, campaignId]` — detail
- `['workspace-media-package', workspaceId]` — package hiện tại của workspace
- `['media-package-templates']`, `['agency-media-package-custom', agencyId]`

Mutation approve:
- `useMutation` gọi `POST .../approve` với `expectedVersion` lấy từ `contentVersion` **đọc tại thời điểm bấm nút** (không cache stale) — tốt nhất: refetch/invalidate detail ngay trước khi hiện confirm dialog, hoặc dùng `contentVersion` từ query cache hiện có và để optimistic-lock 409 làm lưới an toàn cuối.
- `onSuccess`: `invalidateQueries(['campaign', workspaceId, campaignId])` + `invalidateQueries(['campaigns', workspaceId])` (status/approvedAt đổi ảnh hưởng cả list).
- `onError` khi HTTP 409 (`CAMPAIGN_VERSION_CONFLICT`): đây là optimistic-lock conflict thật — nghĩa là Campaign đã bị sửa (hoặc phía kia đã duyệt) sau khi mobile load dữ liệu. Pattern mirror web: catch 409 → refetch campaign detail → hiện lại UI với `contentVersion`/`approvedBy*At` mới nhất → yêu cầu user xem lại rồi bấm Approve lần nữa (không tự động retry approve).
- Server tự xử lý **idempotent theo phía**: nếu phía mình đã approve rồi (ví dụ double-tap, hoặc race 2 request cùng lúc từ 1 user), service trả về campaign hiện tại không lỗi (`if ("CLIENT".equals(side) && campaign.getApprovedByClientAt() != null ... return response(campaign)`) — mobile không cần chặn double-submit bằng debounce phức tạp, nhưng vẫn nên disable nút khi mutation đang pending (UX, không phải để tránh lỗi server).
- Trường hợp khác: nếu user đã approve ở phía này rồi lại cố approve ở phía kia (ví dụ cùng 1 tài khoản vừa là approvedByAgencyId vừa cố click client-approve — hiếm, chỉ xảy ra nếu role đổi) → server trả `FORBIDDEN` (403).

## 6. Business rules đặc biệt

- **Dual approval độc lập, không theo thứ tự bắt buộc**: đọc code `MediaCampaignServiceImpl.approveCampaign()` — Agency và Client có thể approve theo thứ tự bất kỳ, không ai phải chờ ai trước. Server chỉ set `status = APPROVED` khi **cả 2** `approvedByAgencyAt` và `approvedByClientAt` đều non-null. Trước đó status giữ `DRAFT`.
- **CampaignStatus enum thật trong code chỉ có 4 giá trị**: `DRAFT, APPROVED, IN_PROGRESS, COMPLETED` (file `model/enums/CampaignStatus.java`) — khác với liệt kê trong brief ban đầu (không có trạng thái riêng cho "chờ duyệt 1 phía"; trạng thái vẫn là DRAFT cho tới khi đủ 2 phía).
- **Approve không tự sinh Task trực tiếp.** Đọc kỹ `MediaCampaignServiceImpl` + `CampaignDeploymentServiceImpl`/`CampaignDeploymentProcessor`: approve chỉ chuyển `DRAFT → APPROVED`. Việc đẩy backlog Task thật xảy ra ở bước **deploy** riêng (`POST .../deploy`, xử lý bởi `CampaignDeploymentService`, chuyển `APPROVED → IN_PROGRESS` qua `CampaignDeploymentProcessor`). Đây là điểm khác so với mô tả BA mục 3.5.6 ("Sau khi đưa chiến lược ra và cả 2 bên đồng ý → tiến hành nhấn triển khai... đẩy tự động vào Workspace") — đọc theo code, "triển khai" (deploy) là **hành động riêng sau approve**, không tự động chạy ngay khi đủ 2 approval. **Deploy không thuộc scope G4** (G4 chỉ view + approve) — xem mục 7.
- **Campaign immutable sau khi rời DRAFT**: `approveCampaign()` chỉ cho approve khi status là `DRAFT` hoặc `APPROVED` (để cho phép approve phía còn lại khi 1 phía đã duyệt trước, status vẫn DRAFT lúc đó — thật ra điều kiện ở code là `status != DRAFT && status != APPROVED` thì throw `CAMPAIGN_IMMUTABLE`, nên campaign ở `IN_PROGRESS`/`COMPLETED` không approve được nữa, hợp lý vì đã deploy/hoàn tất).
- **expectedVersion dùng `contentVersion`, không dùng `rowVersion`.** `rowVersion` là Hibernate `@Version` dùng cho optimistic lock tầng JPA nội bộ (toàn bộ entity), còn `contentVersion` là field nghiệp vụ theo dõi số lần nội dung Campaign (strategy/timeline/deliverable) được sửa — đây mới là field dùng trong flow approve/feedback phía người dùng.

## 7. Việc KHÔNG làm ở G4

- Không tạo Media Campaign mới từ mobile (`POST .../campaigns` — web only).
- Không sửa Campaign draft (`PATCH .../campaigns/{id}` — web only).
- Không gửi feedback/góp ý Campaign (`POST .../feedback`) — cân nhắc thêm ở giai đoạn sau nếu cần, hiện để web xử lý.
- Không deploy Campaign (`POST .../deploy`) — đây là hành động "triển khai" tạo Task backlog thật, không phải approve; để web xử lý ở G4.
- Không complete/close Campaign (`POST .../complete`), không cancel Task theo Campaign.
- Không request/negotiate Media Package (FR 3.5.3) từ mobile — chỉ xem + approve package.
- Không tạo custom Media Package / đổi availability package (Owner-only, web).

## 8. Rủi ro/câu hỏi mở

1. **2 controller Campaign trùng lặp** (`MediaCampaignController` route `/api/v1/media-campaigns/...` vs `WorkspaceCampaignController` route `/api/v1/workspaces/{workspaceId}/campaigns/...`) — cùng gọi `MediaCampaignService.approveCampaign()` nhưng khác path. Web chỉ dùng route thứ 2. Cần hỏi team backend route nào là chính thức/sắp deprecate để mobile không lỡ tích hợp route cũ.
2. `ApproveMediaPackageRequest` DTO chưa đọc chi tiết field (có `expectedVersion`/version lock tương tự Campaign hay không) — cần đọc trước khi code thật phần approve Package.
3. BA mục 3.5.6 mô tả "approve → tự động đẩy backlog" nhưng code tách riêng approve/deploy — cần xác nhận với BA/PO đây là chủ định (2 bước tách biệt do an toàn) hay tài liệu BA chưa cập nhật theo code mới nhất.
4. Timeline, deliverablePlan, workItems là jsonb tự do (`String timeline`, `List<PackageDeliverable>`, `List<CampaignWorkItem>`) — chưa xem cấu trúc chi tiết các DTO con (`PackageDeliverable`, `CampaignWorkItem`, `DeliverableAllocation`) để thiết kế UI render chính xác từng field; cần đọc thêm khi vào giai đoạn implementation thật.
5. Push notification khi phía kia approve (server có gọi `notifyOpposite(...)`) — G4 doc này chưa cover tích hợp push notification mobile, nên note để G-nào-đó sau xử lý nếu cần real-time alert khi đối tác duyệt.

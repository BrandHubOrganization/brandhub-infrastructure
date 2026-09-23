# 11 — Data Entities Glossary (sơ bộ)

> [<< Về Overview](00-overview.md)
> Mục đích: liệt kê toàn bộ entity mới/thay đổi xuất hiện trong nghiệp vụ V2, kèm field sơ bộ và quan hệ — làm nền cho thiết kế DB schema chi tiết sau này. Đây KHÔNG phải DB schema chính thức (chưa có type, constraint, index) — chỉ là glossary giúp không sót entity khi thiết kế.

## 1. Bảng tổng hợp entity

| Entity | Mới/Đổi | File BA liên quan | Tóm tắt |
|---|---|---|---|
| `Agency` | MỚI | [01](01-organization-structure.md), [03](03-agency-workspace-management.md) | Công ty truyền thông, 1 Owner |
| `AgencyMember` | MỚI | [01](01-organization-structure.md), [03](03-agency-workspace-management.md) | Liên kết User↔Agency, không có role |
| `AgencyInvitation` | MỚI | [03](03-agency-workspace-management.md) | Lời mời vào Agency, hết hạn 3 ngày |
| `Workspace` | ĐỔI | [01](01-organization-structure.md), [03](03-agency-workspace-management.md) | Thuộc 1 Agency, phục vụ nhiều Client |
| `WorkspaceMember` | MỚI | [01](01-organization-structure.md), [03](03-agency-workspace-management.md) | Liên kết User↔Workspace + role (OWNER/MANAGER/MEMBER) |
| `WorkspaceTemplate` | MỚI | [03](03-agency-workspace-management.md) | Bản lưu cấu hình Workspace để tái sử dụng |
| `ClientProfile` | MỚI | [02](02-authentication-profile.md) | Profile riêng của Client, tái sử dụng xuyên Agency |
| `MediaPackageTemplate` | MỚI | [04](04-media-package-campaign.md) | Package mẫu do Admin tạo |
| `MediaPackageCustom` | MỚI | [04](04-media-package-campaign.md) | Package do Owner/Manager tự custom |
| `WorkspaceMediaPackage` | MỚI | [04](04-media-package-campaign.md) | Package đã áp dụng + đàm phán cho 1 Workspace cụ thể |
| `MediaCampaign` | MỚI | [04](04-media-package-campaign.md) | Kế hoạch thực thi chi tiết, sinh từ Package đã approve |
| `ContentRequest` | MỚI | [04](04-media-package-campaign.md) | Đề xuất bài đăng riêng do Client tạo |
| `Task` | ĐỔI | [05](05-content-task-workflow.md) | Đơn vị công việc, 3 loại (Post/Livestream/Survey) |
| `TaskApproval` | MỚI | [05](05-content-task-workflow.md) | Lịch sử duyệt theo Approval Sequence |
| `MaterialRepository` | MỚI | [05](05-content-task-workflow.md) | Kho ảnh/video, raw vs retouched |
| `BrandCollection` | MỚI | [05](05-content-task-workflow.md) | Tài liệu do Client cung cấp làm tham khảo |
| `HashtagCollection` | MỚI | [05](05-content-task-workflow.md) | Kho hashtag theo Workspace |
| `ContentVersion` | MỚI | [05](05-content-task-workflow.md) | Lịch sử version nội dung (Content History) |
| `MailTemplate` | MỚI | [05](05-content-task-workflow.md) | Mẫu email |
| `ThirdPartyCollaborator` | MỚI (chưa chốt tên) | [07](07-publishing-social-collaborator.md) | Đối tác truyền thông ngoài (báo/banner/TV), theo dõi thủ công |
| `SocialAccount` | GIỮ | [07](07-publishing-social-collaborator.md) | Tài khoản social đã connect |
| `Post` | GIỮ | [07](07-publishing-social-collaborator.md) | Bài đăng đã publish lên social |
| `Subscription`/`Plan` | GIỮ | [08](08-subscription-billing.md) | Basic/Pro/Enterprise |
| `Transaction` | GIỮ | [08](08-subscription-billing.md) | Giao dịch thanh toán PayOS, ACID |
| `AICreditLedger` | MỚI (tên đề xuất) | [08](08-subscription-billing.md) | Sổ theo dõi credit AI đã dùng/hạn mức |
| `LivestreamSession` | MỚI | [05](05-content-task-workflow.md) | Idea/script/status của 1 phiên livestream (con của Task loại Livestream) |
| `Survey` | MỚI | [05](05-content-task-workflow.md) | Form khảo sát (con của Task loại Survey) |

## 2. Chi tiết field sơ bộ — entity trung tâm

### `Agency`
```
id, name, ownerId (FK User, 1-1), profileInfo, logo, description,
status (active/soft_deleted), deletedAt, createdAt, updatedAt
```

### `AgencyMember`
```
id, agencyId (FK), userId (FK), joinedAt
-- KHÔNG có field "role" ở entity này — role chỉ tồn tại ở WorkspaceMember
```

### `Workspace`
```
id, agencyId (FK), name, timezoneConfig, mediaPackageTemplateId (FK, nullable lúc mới tạo),
status (active/soft_deleted/inactive), deletedAt, createdAt, updatedAt
```

### `WorkspaceMember`
```
id, workspaceId (FK), userId (FK), role (OWNER | MANAGER | MEMBER),
addedAt, addedBy (FK User)
-- unique(workspaceId, userId) — 1 user chỉ 1 role trong 1 workspace tại 1 thời điểm
```

### `ClientProfile`
```
id, userId (FK User — CLIENT dùng chung bảng User hay bảng riêng? [CẦN QUYẾT ĐỊNH]),
displayName, company, phone, note
-- KHÔNG có field email riêng update được (email cố định theo FR 3.3.4)
```

### `MediaPackageTemplate` / `MediaPackageCustom`
```
id, name, type (by_duration | by_budget | full_delegation),
durationWeeks (nullable), budgetAmount (nullable), scopeDescription,
createdBy (FK — Admin cho template, Owner/Manager cho custom)
```

### `WorkspaceMediaPackage`
```
id, workspaceId (FK), packageRefId, packageRefType (template | custom),
negotiationStatus (draft | client_requested_change | agency_countered | approved),
finalTerms (JSON — giá, thời gian, hình thức đã chốt),
approvedByAgencyAt, approvedByClientAt
```

### `MediaCampaign`
```
id, workspaceMediaPackageId (FK), name, strategyDetail,
brandGuideline, timeline, status (draft | approved | in_progress | completed),
approvedByAgencyAt, approvedByClientAt
```

### `ContentRequest`
```
id, workspaceId (FK), createdByClientId (FK ClientProfile),
title, description, status (pending | in_progress | accepted | denied),
generatedTaskId (FK Task, nullable — set khi accepted),
createdAt, updatedAt
```

### `Task`
```
id, workspaceId (FK), sourceType (campaign | content_request | manual),
sourceRefId (FK — MediaCampaign hoặc ContentRequest, nullable nếu manual),
type (post | livestream | survey),
title, description, assigneeId (FK User, nullable ở backlog),
qcAssigneeId (FK User, nullable — tùy chọn theo Approval Sequence),
requiresClientApproval (boolean),
status (backlog | detail_identified | assigned | in_progress |
         qc_review | manager_review | client_review | completed | rejected),
dueDate, createdAt, updatedAt
```

### `TaskApproval` (lịch sử duyệt)
```
id, taskId (FK), step (creator | qc | manager | client),
action (submit | approve | reject), actorId (FK User),
comment, createdAt
```

### `ThirdPartyCollaborator` (SỬA 2026-09-15 — danh bạ chung cấp Agency, không gắn cứng Campaign)
```
id, agencyId (FK), partnerName, partnerType (newspaper | banner | tv | other),
contactInfo, notes, createdBy (FK User), createdAt, updatedAt
```
> Không còn `cooperationStatus` ở đây — trạng thái hợp tác chuyển xuống bảng liên kết `CampaignCollaborator` vì 1 collaborator có thể hợp tác nhiều Campaign cùng lúc với trạng thái khác nhau.

### `CampaignCollaborator` (MỚI 2026-09-15 — bảng liên kết N-N)
```
id, mediaCampaignId (FK), collaboratorId (FK ThirdPartyCollaborator),
cooperationStatus (contacted | negotiating | confirmed | live),
updatedBy (FK User), updatedAt
```

## 3. Quyết định thiết kế đã chốt [CONFIRMED 2026-09-17]

1. **ClientProfile**: **tách bảng riêng hoàn toàn khỏi `User`** — vì 1 User có thể có **nhiều Client Profile khác nhau** (không phải 1-1 với User). Field:
   ```
   id, userId (FK User, KHÔNG unique — 1 user có thể có nhiều ClientProfile),
   displayName, company, phone, note,
   createdAt, updatedAt
   -- KHÔNG có field email riêng update được (email cố định theo FR 3.3.4, lấy từ User gốc)
   ```
2. **MediaPackageTemplate vs MediaPackageCustom**: **giữ 2 bảng riêng** như đề xuất gốc (không gộp về 1 bảng + cột `isTemplate`). Workspace/`WorkspaceMediaPackage` dùng polymorphic reference (`packageRefType` + `packageRefId`) để trỏ tới đúng 1 trong 2 bảng.
3. **Task 3 loại**: **3 bảng riêng** (`PostTask`, `LivestreamTask`, `SurveyTask`) kế thừa 1 bảng `Task` gốc (field chung: id, workspaceId, sourceType, sourceRefId, assigneeId, qcAssigneeId, status, dueDate...) — chọn hướng này để phục vụ scale (mỗi loại task sẽ có nhiều field riêng phát sinh về sau, tách bảng giúp thêm field mới không ảnh hưởng 2 loại khác, tránh 1 bảng `Task` phình to với nhiều cột null theo loại).
4. ~~**ThirdPartyCollaborator**: tên entity chính thức + có cần bảng riêng cho lịch sử thay đổi trạng thái hợp tác không?~~ **[ĐÃ ĐÓNG 2026-09-15]** — danh bạ chung cấp Agency, N-N qua `CampaignCollaborator` (xem trên). Audit trail lịch sử đổi trạng thái: chưa yêu cầu bảng riêng, `updatedAt`/`updatedBy` trên `CampaignCollaborator` là đủ cho MVP.
5. **AICreditLedger**: reset hàng tháng về hạn mức gốc, **không rollover** *(đã đóng 2026-09-15)*. Set Credit (FR 3.9.7): **hạn mức cứng (hard limit)** — hết credit thì chặn hẳn thao tác AI, không phải soft warning. Xem [08-subscription-billing.md](08-subscription-billing.md).
6. **CampaignAddendum** (MỚI 2026-09-17) — bản bổ sung link tới Campaign gốc, dùng khi có khối lượng công việc lớn phát sinh giữa chiến dịch (khác Manual Task đơn lẻ, khác Content Request từ Client). Xem state machine tại [12-state-machines.md](12-state-machines.md) mục 3.
   ```
   id, parentCampaignId (FK MediaCampaign), name, reason,
   status (draft | approved), approvedByAgencyAt, approvedByClientAt,
   createdAt, updatedAt
   ```
   Task sinh ra từ Addendum set `sourceType = campaign_addendum`, `sourceRefId` trỏ tới `CampaignAddendum.id` (mở rộng enum `sourceType` của `Task` ở mục 2, hiện đang chỉ có `campaign | content_request | manual`).

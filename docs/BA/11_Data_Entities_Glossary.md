# 11 — Data Entities Glossary (sơ bộ)

> [<< Về Overview](00_Overview.md)
> Mục đích: liệt kê toàn bộ entity mới/thay đổi xuất hiện trong nghiệp vụ V2, kèm field sơ bộ và quan hệ — làm nền cho thiết kế DB schema chi tiết sau này. Đây KHÔNG phải DB schema chính thức (chưa có type, constraint, index) — chỉ là glossary giúp không sót entity khi thiết kế.

## 1. Bảng tổng hợp entity

| Entity | Mới/Đổi | File BA liên quan | Tóm tắt |
|---|---|---|---|
| `Agency` | MỚI | [01](01_Organization_Structure.md), [03](03_Agency_Workspace_Management.md) | Công ty truyền thông, 1 Owner |
| `AgencyMember` | MỚI | [01](01_Organization_Structure.md), [03](03_Agency_Workspace_Management.md) | Liên kết User↔Agency, không có role |
| `AgencyInvitation` | MỚI | [03](03_Agency_Workspace_Management.md) | Lời mời vào Agency, hết hạn 3 ngày |
| `Workspace` | ĐỔI | [01](01_Organization_Structure.md), [03](03_Agency_Workspace_Management.md) | Thuộc 1 Agency, phục vụ nhiều Client |
| `WorkspaceMember` | MỚI | [01](01_Organization_Structure.md), [03](03_Agency_Workspace_Management.md) | Liên kết User↔Workspace + role (OWNER/MANAGER/MEMBER) |
| `WorkspaceTemplate` | MỚI | [03](03_Agency_Workspace_Management.md) | Bản lưu cấu hình Workspace để tái sử dụng |
| `ClientProfile` | MỚI | [02](02_Authentication_Profile.md) | Profile riêng của Client, tái sử dụng xuyên Agency |
| `MediaPackageTemplate` | MỚI | [04](04_Media_Package_Campaign.md) | Package mẫu do Admin tạo |
| `MediaPackageCustom` | MỚI | [04](04_Media_Package_Campaign.md) | Package do Owner/Manager tự custom |
| `WorkspaceMediaPackage` | MỚI | [04](04_Media_Package_Campaign.md) | Package đã áp dụng + đàm phán cho 1 Workspace cụ thể |
| `MediaCampaign` | MỚI | [04](04_Media_Package_Campaign.md) | Kế hoạch thực thi chi tiết, sinh từ Package đã approve |
| `ContentRequest` | MỚI | [04](04_Media_Package_Campaign.md) | Đề xuất bài đăng riêng do Client tạo |
| `Task` | ĐỔI | [05](05_Content_Task_Workflow.md) | Đơn vị công việc, 3 loại (Post/Livestream/Survey) |
| `TaskApproval` | MỚI | [05](05_Content_Task_Workflow.md) | Lịch sử duyệt theo Approval Sequence |
| `MaterialRepository` | MỚI | [05](05_Content_Task_Workflow.md) | Kho ảnh/video, raw vs retouched |
| `BrandCollection` | MỚI | [05](05_Content_Task_Workflow.md) | Tài liệu do Client cung cấp làm tham khảo |
| `HashtagCollection` | MỚI | [05](05_Content_Task_Workflow.md) | Kho hashtag theo Workspace |
| `ContentVersion` | MỚI | [05](05_Content_Task_Workflow.md) | Lịch sử version nội dung (Content History) |
| `MailTemplate` | MỚI | [05](05_Content_Task_Workflow.md) | Mẫu email |
| `ThirdPartyCollaborator` | MỚI (chưa chốt tên) | [07](07_Publishing_Social_Collaborator.md) | Đối tác truyền thông ngoài (báo/banner/TV), theo dõi thủ công |
| `SocialAccount` | GIỮ | [07](07_Publishing_Social_Collaborator.md) | Tài khoản social đã connect |
| `Post` | GIỮ | [07](07_Publishing_Social_Collaborator.md) | Bài đăng đã publish lên social |
| `Subscription`/`Plan` | GIỮ | [08](08_Subscription_Billing.md) | Basic/Pro/Enterprise |
| `Transaction` | GIỮ | [08](08_Subscription_Billing.md) | Giao dịch thanh toán PayOS, ACID |
| `AICreditLedger` | MỚI (tên đề xuất) | [08](08_Subscription_Billing.md) | Sổ theo dõi credit AI đã dùng/hạn mức |
| `LivestreamSession` | MỚI | [05](05_Content_Task_Workflow.md) | Idea/script/status của 1 phiên livestream (con của Task loại Livestream) |
| `Survey` | MỚI | [05](05_Content_Task_Workflow.md) | Form khảo sát (con của Task loại Survey) |

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

## 3. Câu hỏi thiết kế còn mở (cần quyết định trước khi tạo migration thật)

1. **ClientProfile**: dùng chung bảng `User` (thêm cột) hay tách bảng riêng hoàn toàn? Ảnh hưởng cách 1 User vừa là Owner Agency A vừa là Client ở Agency B.
2. **MediaPackageTemplate vs MediaPackageCustom**: theo FR 3.5.1 nguồn gợi ý tách 2 bảng riêng, cột tham chiếu trong Workspace lưu ID trỏ tới 1 trong 2 — cần xác nhận lại có dùng polymorphic reference (`packageRefType` + `packageRefId`) hay dùng chung 1 bảng `MediaPackage` với cột `isTemplate`.
3. **Task 3 loại**: dùng 1 bảng `Task` chung với cột `type` (đề xuất ở trên) hay 3 bảng riêng (`PostTask`, `LivestreamTask`, `SurveyTask`) kế thừa 1 bảng `Task` gốc? Ảnh hưởng độ phức tạp query nhưng tăng rõ ràng field riêng theo loại.
4. ~~**ThirdPartyCollaborator**: tên entity chính thức + có cần bảng riêng cho lịch sử thay đổi trạng thái hợp tác không?~~ **[ĐÃ ĐÓNG 2026-09-15]** — danh bạ chung cấp Agency, N-N qua `CampaignCollaborator` (xem trên). Audit trail lịch sử đổi trạng thái: chưa yêu cầu bảng riêng, `updatedAt`/`updatedBy` trên `CampaignCollaborator` là đủ cho MVP.
5. ~~**AICreditLedger**: reset hàng tháng hay cộng dồn?~~ **[ĐÃ ĐÓNG 2026-09-15]** — reset hàng tháng về hạn mức gốc, **không rollover**. Set Credit (FR 3.9.7) vẫn là câu hỏi mở: hạn mức cứng hay soft warning — chưa confirm.

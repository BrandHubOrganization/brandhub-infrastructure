# BrandHub — BA Documentation V2 (2026-09-14)

> Tài liệu nghiệp vụ (Business Analysis) đầy đủ cho hệ thống BrandHub phiên bản V2.
> Nguồn: `docs/Các FR của hệ thống - Feature_Function Requirement.csv` (109 FR) + `docs/Flow-AI-System Main Flow.drawio.png` + xác nhận trực tiếp với Trung (2026-09-14).
> Thay thế hoàn toàn giả định nghiệp vụ cũ trong `docs/plan/BrandHub_Master_Plan.md` và `docs/plan/Document_Plan.md` — 2 file đó mô tả mô hình CŨ (Workspace 1 tầng, RBAC 6 role cố định) và cần được re-scope dựa trên tài liệu BA này.

## Bối cảnh thay đổi

- Kế hoạch gốc: dự án kết thúc tháng 11/2026.
- Bị dời sang 19/12/2026 do khối lượng nghiệp vụ mới tăng vọt.
- Mục tiêu của Trung: **vẫn kết thúc cuối tháng 11/2026** — cần re-scope MVP sau khi BA hoàn tất (việc này KHÔNG nằm trong phạm vi bộ tài liệu BA này, sẽ làm ở bước tiếp theo dựa trên các file này).

## Thay đổi lớn nhất so với hệ thống cũ

1. **Cấu trúc tổ chức 3 tầng mới**: `User → Agency → Workspace` (cũ: `User → Workspace` trực tiếp). Xem [01_Organization_Structure.md](01_Organization_Structure.md).
2. **Role gán theo từng Workspace**, không phải role cố định toàn hệ thống. Xem [10_Roles_Permissions_Matrix.md](10_Roles_Permissions_Matrix.md).
3. **Khái niệm hợp đồng 3 tầng mới**: Media Package (mẫu) → Media Campaign (kế hoạch chi tiết) → Task backlog. Xem [04_Media_Package_Campaign.md](04_Media_Package_Campaign.md).
4. **Task có 3 loại nội dung** (Post / Livestream / Survey-Form) dùng chung 1 khung Approval Sequence. Xem [05_Content_Task_Workflow.md](05_Content_Task_Workflow.md).
5. **Mở rộng ngoài social media**: module theo dõi thủ công đối tác truyền thông thứ 3 (báo, banner, TV) — không tự động hóa như Facebook/TikTok. Xem [07_Publishing_Social_Collaborator.md](07_Publishing_Social_Collaborator.md).
6. **Client là actor ngoài Agency**, có profile tái sử dụng xuyên nhiều Agency/Workspace, không phải nội bộ công ty.

## Cấu trúc bộ tài liệu

| File | Nội dung | FR liên quan |
|---|---|---|
| [01_Organization_Structure.md](01_Organization_Structure.md) | Mô hình tổ chức Agency/Workspace/Role 3 tầng, quan hệ giữa các entity | Nền tảng, không map trực tiếp 1 FR |
| [02_Authentication_Profile.md](02_Authentication_Profile.md) | Đăng ký/đăng nhập, OTP, 2FA, quản lý Profile cá nhân & Client Profile | 3.2.1 – 3.3.4 |
| [03_Agency_Workspace_Management.md](03_Agency_Workspace_Management.md) | Quản lý Agency, Workspace, Member, Invitation, Template | 3.4.1 – 3.4.21 |
| [04_Media_Package_Campaign.md](04_Media_Package_Campaign.md) | Luồng Package → Campaign → Content Request, đàm phán, approve | 3.5.1 – 3.5.10 |
| [05_Content_Task_Workflow.md](05_Content_Task_Workflow.md) | Task backlog, Assign, Approval Sequence, Material/Hashtag/Content view | 3.6.1 – 3.6.35 |
| [06_AI_Features.md](06_AI_Features.md) | AI tools: trend, caption, ambassador, image/video gen, recommend collaborator | 3.7.1 – 3.7.12 |
| [07_Publishing_Social_Collaborator.md](07_Publishing_Social_Collaborator.md) | Publish social media tự động + module Third-party Collaborator thủ công | 3.8.1 – 3.8.16 |
| [08_Subscription_Billing.md](08_Subscription_Billing.md) | Plan, thanh toán, credit AI | 3.9.1 – 3.9.7 |
| [09_Admin_Management.md](09_Admin_Management.md) | Quản trị hệ thống, moderation, user management | 3.10.1 – 3.10.12 |
| [10_Roles_Permissions_Matrix.md](10_Roles_Permissions_Matrix.md) | Bảng role tổng hợp, ma trận quyền theo từng FR | Toàn bộ |
| [11_Data_Entities_Glossary.md](11_Data_Entities_Glossary.md) | Danh sách entity mới/đổi, field sơ bộ, câu hỏi thiết kế DB còn mở | Nền cho DB schema |
| [12_State_Machines.md](12_State_Machines.md) | Sơ đồ trạng thái chi tiết từng transition: Content Request, Package, Campaign, Task Approval Sequence, Livestream, Collaborator, Post Publish | Bổ sung chi tiết cho 04, 05, 07 |

## Cách đọc bộ tài liệu này

- Đọc [01_Organization_Structure.md](01_Organization_Structure.md) trước tiên — mọi file khác đều dựa trên mô hình 3 tầng này.
- Mỗi file FR-domain (02–09) đều có mục **"Điểm khác so với đọc thẳng câu chữ CSV gốc"** khi có — vì nhiều mô tả trong CSV gốc dễ gây hiểu nhầm về thứ tự nghiệp vụ (ví dụ: Package tưởng phải có trước Workspace, nhưng thực tế Workspace tạo trước).
- Các quyết định chưa rõ trong CSV đã được confirm trực tiếp với Trung — đánh dấu **[CONFIRMED 2026-09-14]** tại chỗ liên quan.

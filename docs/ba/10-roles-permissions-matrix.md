# 10 — Roles & Permissions Matrix (tổng hợp)

> [<< Về Overview](00-overview.md)

## 1. Bảng role hệ thống V2

| Cấp | Role | Phạm vi | Ghi chú |
|---|---|---|---|
| Chưa đăng nhập | `GUEST` | Toàn hệ thống | Landing page, Sign Up, Sign In only |
| Đã đăng nhập, chưa vào Agency | `USER` | Cá nhân | Có Profile riêng, tạo được Agency mới, quản lý Subscription cá nhân |
| Agency | `OWNER` | 1 Agency cụ thể | Duy nhất 1 Owner/Agency, gắn 1-1 với user tạo ra Agency |
| Agency | *(Member không role)* | 1 Agency cụ thể | Invite vào Agency nhưng CHƯA có quyền quản lý gì — chỉ có quyền khi được add vào 1 Workspace cụ thể |
| Workspace | `OWNER` | 1 Workspace cụ thể | Owner của Agency có thể tự nhận vai trò này ở 1/nhiều Workspace |
| Workspace | `MANAGER` | 1 Workspace cụ thể | Toàn quyền quản lý Workspace đó — KHÔNG áp dụng sang Workspace khác cùng Agency |
| Workspace | `MEMBER` (bao gồm CREATOR) | 1 Workspace cụ thể | Creator là 1 dạng Member có quyền tạo content |
| Workspace (ngoài) | `CLIENT` | 1 hoặc nhiều Workspace | Actor ngoài Agency, Profile riêng dùng lại xuyên Agency/Workspace |
| Hệ thống | `ADMIN` | Toàn hệ thống | Tách biệt hoàn toàn, không thuộc Agency nào |

**Quy tắc cốt lõi (nhắc lại từ [01-organization-structure.md](01-organization-structure.md)):** role Workspace (OWNER/MANAGER/MEMBER) **gán độc lập theo từng Workspace** — 1 user có thể có role khác nhau ở các Workspace khác nhau trong cùng 1 Agency.

## 1.1 Ma trận quyền 2 tầng (V2) — Agency-level vs Workspace-level

> Cập nhật theo DA-E14-06, phản ánh model RBAC 2 tầng: **Agency-level** (chỉ `owner_id`, kiểm tra riêng biệt với `@RequireRole`) nằm trên **Workspace-level** (`MemberRole` theo từng Workspace, cơ chế `@RequireRole` hiện có).

### Tầng 1 — Agency-level (chỉ Agency Owner, không phụ thuộc MemberRole ở Workspace nào)

| FR | Hành động | Role bắt buộc | Ghi chú |
|---|---|---|---|
| 3.4.1 | List Agency (của mình) | OWNER | |
| 3.4.2 | View Agency Dashboard | OWNER | |
| 3.4.3 | Create Agency | USER (bất kỳ user đã đăng nhập) | Tạo xong tự thành OWNER của Agency đó |
| 3.4.4 | View Agency Profile | OWNER | |
| 3.4.5 | Update Agency Profile | OWNER | |
| 3.4.6 | Remove Agency | OWNER | Soft delete, khôi phục 30 ngày |
| 3.4.7 | Invite Agency Member | OWNER | |
| 3.4.8 | View Agency Invitation Status | OWNER / USER (invited) | 2 phía đều xem được |
| 3.4.9 | Remove Agency Member | OWNER | |
| 3.4.10 | List Workspace (toàn bộ của Agency) | OWNER | Member chỉ thấy Workspace mình có mặt — xem Tầng 2 |

### Tầng 2 — Workspace-level (theo `MemberRole` của từng Workspace cụ thể)

| FR | Hành động | Role bắt buộc | Ghi chú |
|---|---|---|---|
| 3.4.10 | List Workspace (của riêng mình) | MEMBER | Chỉ Workspace mình có mặt |
| 3.4.11 | View Workspace Dashboard | OWNER / MANAGER / MEMBER | Owner Agency luôn xem được mọi Workspace (kế thừa Tầng 1) |
| 3.4.12 | Create Workspace | OWNER (Agency) | Bắt buộc gán đúng 1 Manager lúc tạo |
| 3.4.13 | View Workspace Profile | MANAGER | |
| 3.4.14 | Update Workspace Profile | MANAGER | |
| 3.4.15 | Delete Workspace | OWNER (Agency) | Soft delete, khôi phục 30 ngày |
| 3.4.16 | Leave Workspace | MEMBER | |
| 3.4.17 | Save Workspace Template | OWNER (Agency) | |
| 3.4.18 | View Workspace Members | MEMBER | |
| 3.4.19 | Add Workspace Member | MANAGER | Member phải đã thuộc Agency trước |
| 3.4.20 | Update Workspace Member Role | MANAGER | |
| 3.4.21 | Remove Workspace Member | MANAGER | Không xóa khỏi Agency |

**Nguyên tắc kỹ thuật:** Tầng 1 dùng check riêng (`agency.getOwnerId().equals(currentUserId)` hoặc tương đương `@RequireAgencyOwner`), KHÔNG dùng chung cơ chế `@RequireRole(MemberRole...)` của Tầng 2 — 2 cơ chế độc lập, một Agency Owner không tự động có `MemberRole` ở mọi Workspace con trừ khi được gán riêng (trừ hành động list/view đã liệt kê ở Tầng 1 do kế thừa quyền sở hữu).

**Phạm vi mở rộng (E16, E50, E51):** endpoint các nhóm Agency & Client (E16), Media Package/Campaign (E50), Task workflow (E51) áp dụng theo cùng nguyên tắc 2 tầng ở trên — chi tiết role từng FR xem file [04](04-media-package-campaign.md) và [05](05-content-task-workflow.md); các FR đó đã dùng đúng model Workspace-level (`MemberRole`) hiện có, không cần bảng riêng.

## 2. Ma trận quyền theo từng nhóm FR

| Nhóm FR | File chi tiết | Role tham gia chính |
|---|---|---|
| 3.2 Authentication | [02](02-authentication-profile.md) | GUEST, USER |
| 3.3 Profile | [02](02-authentication-profile.md) | USER |
| 3.4 Agency & Workspace | [03](03-agency-workspace-management.md) | OWNER, MEMBER, MANAGER |
| 3.5 Media Package & Contract | [04](04-media-package-campaign.md) | OWNER, MANAGER, CLIENT |
| 3.6 Content & Workflow | [05](05-content-task-workflow.md) | CREATOR, MANAGER, CLIENT |
| 3.7 AI Features | [06](06-ai-features.md) | CREATOR, ADMIN |
| 3.8 Publishing & Social | [07](07-publishing-social-collaborator.md) | CLIENT, MEMBER |
| 3.9 Subscription | [08](08-subscription-billing.md) | USER, OWNER, CREATOR |
| 3.10 Admin Management | [09](09-admin-management.md) | ADMIN |

## 3. Đặc biệt: FR có role hỗn hợp cần lưu ý khi thiết kế RBAC

Các trường hợp role list trong CSV có nhiều actor nhưng **hành động thực tế KHÔNG đồng đều** giữa các actor đó — quan trọng để tránh thiết kế permission sai:

| FR | Role list (CSV) | Ai THỰC SỰ thao tác | Ai chỉ có quyền XEM/DUYỆT |
|---|---|---|---|
| 3.5.7 Create Content Request | OWNER/MANAGER/CLIENT | CLIENT (tạo) | OWNER/MANAGER (xem, duyệt sau) |
| 3.5.3 Request Media Package | OWNER/MANAGER/CLIENT | CLIENT (đề xuất thay đổi) | OWNER/MANAGER (phản hồi) |
| 3.5.8 Track Request Status | ghi MANAGER | MANAGER (set trạng thái) | CLIENT không set được, chỉ xem |

## 4. Chuỗi Approval — vai trò theo thứ tự (tổng hợp từ file 05)

```
Media Package:   Client đề xuất → Owner/Manager phản hồi → CẢ 2 approve
Media Campaign:  Agency tạo → CẢ 2 (Owner/Manager + Client) approve
Task:            Creator làm → [QC Creator khác, tùy chọn] → Manager duyệt → Client duyệt (nếu cần)
```

Mỗi tầng approval đều yêu cầu **đồng thuận 2 phía** (Agency internal + Client) trước khi tiến sang bước kế — điểm chung xuyên suốt toàn bộ nghiệp vụ BrandHub V2, khác với hệ thống cũ (chỉ cần nội bộ Agency duyệt qua các cấp, Client duyệt cuối 1 lần).

## 5. Câu hỏi RBAC còn mở (cần quyết định trước khi code)

1. **[09-admin-management.md]** Admin có xóa được Admin khác không? Số lượng Admin tối đa?
2. **[02-authentication-profile.md]** Field cụ thể của User Profile (FR 3.3.1) — CSV để ngỏ, chưa liệt kê field.
3. **[05-content-task-workflow.md]** Check Copyright Infringement (FR 3.6.34) — "cần làm rõ hơn", CSV chưa mô tả kỹ chi tiết kỹ thuật.
4. **[05-content-task-workflow.md]** Mail Template (FR 3.6.28–3.6.32) — CSV chưa gán role cụ thể.
5. **[07-publishing-social-collaborator.md]** Third-party Collaborator — entity/DB schema và số hiệu FR chính thức chưa được định nghĩa, cần bổ sung CSV gốc.

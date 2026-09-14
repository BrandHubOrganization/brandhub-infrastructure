# 10 — Roles & Permissions Matrix (tổng hợp)

> [<< Về Overview](00_Overview.md)

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

**Quy tắc cốt lõi (nhắc lại từ [01_Organization_Structure.md](01_Organization_Structure.md)):** role Workspace (OWNER/MANAGER/MEMBER) **gán độc lập theo từng Workspace** — 1 user có thể có role khác nhau ở các Workspace khác nhau trong cùng 1 Agency.

## 2. Ma trận quyền theo từng nhóm FR

| Nhóm FR | File chi tiết | Role tham gia chính |
|---|---|---|
| 3.2 Authentication | [02](02_Authentication_Profile.md) | GUEST, USER |
| 3.3 Profile | [02](02_Authentication_Profile.md) | USER |
| 3.4 Agency & Workspace | [03](03_Agency_Workspace_Management.md) | OWNER, MEMBER, MANAGER |
| 3.5 Media Package & Contract | [04](04_Media_Package_Campaign.md) | OWNER, MANAGER, CLIENT |
| 3.6 Content & Workflow | [05](05_Content_Task_Workflow.md) | CREATOR, MANAGER, CLIENT |
| 3.7 AI Features | [06](06_AI_Features.md) | CREATOR, ADMIN |
| 3.8 Publishing & Social | [07](07_Publishing_Social_Collaborator.md) | CLIENT, MEMBER |
| 3.9 Subscription | [08](08_Subscription_Billing.md) | USER, OWNER, CREATOR |
| 3.10 Admin Management | [09](09_Admin_Management.md) | ADMIN |

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

1. **[09_Admin_Management.md]** Admin có xóa được Admin khác không? Số lượng Admin tối đa?
2. **[02_Authentication_Profile.md]** Field cụ thể của User Profile (FR 3.3.1) — CSV để ngỏ, chưa liệt kê field.
3. **[05_Content_Task_Workflow.md]** Check Copyright Infringement (FR 3.6.34) — "cần làm rõ hơn", CSV chưa mô tả kỹ chi tiết kỹ thuật.
4. **[05_Content_Task_Workflow.md]** Mail Template (FR 3.6.28–3.6.32) — CSV chưa gán role cụ thể.
5. **[07_Publishing_Social_Collaborator.md]** Third-party Collaborator — entity/DB schema và số hiệu FR chính thức chưa được định nghĩa, cần bổ sung CSV gốc.

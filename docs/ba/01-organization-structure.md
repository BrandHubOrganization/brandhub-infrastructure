# 01 — Cấu trúc tổ chức: Agency / Workspace / Role

> [<< Về Overview](00-overview.md)

## 1. Mô hình tổng quan

```
User
 └─ là OWNER của N Agency (1 user có thể sở hữu nhiều Agency)
     Agency
      ├─ có đúng 1 OWNER (gắn 1-1 với user tạo ra Agency)
      └─ Member (invite vào Agency — KHÔNG có role gì ở cấp này)
          └─ Workspace (1 Agency có N Workspace)
              ├─ OWNER / MANAGER / MEMBER — role GÁN RIÊNG theo TỪNG Workspace
              └─ CLIENT — actor ngoài Agency, được invite vào Workspace để theo dõi/duyệt
```

Đây là thay đổi lớn nhất so với hệ thống cũ: cũ chỉ có `User → Workspace` 1 tầng, role cố định toàn cục (AGENCY_OWNER/MANAGER/CREATOR/CLIENT). Mới thêm hẳn 1 tầng **Agency** ở giữa, và role không còn cố định mà gán theo từng Workspace.

## 2. Agency

- Agency đại diện 1 công ty truyền thông (media agency) thật.
- 1 User có thể là Owner của nhiều Agency (FR 3.4.1 — List Agency: "mỗi người dùng đều là chủ của các Agency nên họ có trang để list ra các Agency họ đang sở hữu").
- Agency có **đúng 1 OWNER** — gắn 1-1 với user tạo ra nó (FR 3.4.3 Create Agency: "có owner id được liên kết với id của một user duy nhất là người tạo ra agency đó").
- Agency có Profile công khai (FR 3.4.4 View Agency Profile) — thông tin công ty để Client hiểu về Agency trước khi hợp tác.
- Agency Dashboard (FR 3.4.2) — Owner xem thông tin tổng quan công ty.
- Xóa Agency (FR 3.4.6) — **soft delete**, có confirm, khôi phục được trong 30 ngày.

### Member trong Agency

- Owner **invite Member vào Agency** qua email + notification (FR 3.4.7).
- Member vừa được invite **không có role gì trong Agency** — chỉ là thành viên công ty thông thường, chưa có quyền quản lý cụ thể.
- Lời mời (Agency Invitation) hiển thị cho cả người mời và người được mời thấy trạng thái, **tự động hết hạn sau 3 ngày** (FR 3.4.8).
- Xóa Member khỏi Agency (FR 3.4.9 Remove Member):
  - Member mất quyền truy cập tài nguyên Agency.
  - **Tài nguyên họ đã tạo ra khi còn trong Agency vẫn giữ nguyên** — vì thuộc tài sản chung của Agency, không bị xóa theo người.
  - Nếu được thêm lại vào Agency sau đó, họ được chỉnh sửa/sử dụng tiếp các tài nguyên cũ đó.

## 3. Workspace

- 1 Agency có N Workspace.
- **1 Workspace có thể phục vụ nhiều Client cùng lúc** — KHÔNG phải mô hình 1 workspace = 1 client. Workspace giống 1 "không gian dự án/team" dùng chung tài nguyên nội bộ (Material Repository, Hashtag Collection, Chatbot riêng...).
- List Workspace (FR 3.4.10): Member chỉ coi được workspace mình có mặt trong đó; **Owner coi được toàn bộ workspace của Agency**.
- Workspace Dashboard (FR 3.4.11) — thông tin chung + thống kê của workspace.

### Tạo Workspace (FR 3.4.12)

- Chỉ OWNER tạo được Workspace mới.
- **Bắt buộc gán ít nhất 1 Manager ngay lúc tạo** — người này có toàn quyền quản lý workspace đó.
- **BA 2026-11-05** Owner được tạo workspace và gán Manager trước khi có Client. Manager chốt gói với khách bên ngoài, lưu gói workspace rồi mời Client vào làm việc. Việc chuẩn bị workspace/gói/Campaign không chờ Client tham gia hoặc duyệt. Xem [hành trình mới](../feature/3-5-media-package-campaign/3-5-6-view-media-campaign/guest-sharing-manager-led/spec.md).
- **[CONFIRMED 2026-09-14]** Owner tạo Workspace có thể **tự gán mình làm Manager** của workspace đó, **hoặc gán 1 Member khác làm Manager** — cả 2 tình huống đều hợp lệ, không bắt buộc theo 1 chiều.

### Workspace Profile (FR 3.4.13)

- Có field cực quan trọng: **Timezone Configuration** — định nghĩa mốc thời gian chuẩn hoạt động của workspace này.
- Lý do: mỗi sự kiện tổ chức ở địa điểm khác nhau, mốc thời gian theo UTC/timezone riêng giúp bài viết đăng tối ưu theo giờ vàng của từng địa điểm làm truyền thông (viral tùy chỉnh theo địa điểm).
- Update Workspace Profile (FR 3.4.14) — OWNER/MANAGER cùng có quyền update.

### Xóa Workspace (FR 3.4.15)

- **Chỉ OWNER** mới được xóa Workspace.
- Soft delete — khôi phục được trong 30 ngày.
- Khi xóa: toàn bộ Member/Client mất quyền truy cập, mọi dữ liệu trong workspace chuyển trạng thái **inactive**.

### Rời Workspace (FR 3.4.16)

- Member rời Workspace nhưng **vẫn còn trong Agency** — rời Workspace không đồng nghĩa rời Agency.

### Workspace Template (FR 3.4.17)

- Owner lưu lại 1 workspace hiện có thành **template** (thông tin cơ bản + cách triển khai) để tái sử dụng khi tạo workspace mới sau này — tăng tốc setup cho các dự án tương tự.

### Quản lý Member trong Workspace (FR 3.4.18 – 3.4.21)

- View Workspace Members (FR 3.4.18) — mọi Member trong workspace xem được danh sách.
- Add Workspace Member (FR 3.4.19) — OWNER/MANAGER thêm 1 Member **đã có trong Agency** vào Workspace với 1 role cụ thể.
- Update Workspace Member Role (FR 3.4.20) — OWNER/MANAGER đổi role của Member trong chính workspace đó.
- Remove Workspace Member (FR 3.4.21) — OWNER/MANAGER xóa Member khỏi Workspace (không xóa khỏi Agency).

## 4. Role gán theo Workspace — quy tắc cốt lõi

**[CONFIRMED 2026-09-14]** Role hoàn toàn độc lập giữa các Workspace khác nhau trong cùng 1 Agency.

Ví dụ: User A có thể là:
- `MANAGER` ở Workspace X (được Owner gán toàn quyền quản lý workspace đó),
- nhưng chỉ là `MEMBER` thường (ví dụ Creator) ở Workspace Y — cùng thuộc 1 Agency, nhưng vai trò khác hẳn.

Điều này khác biệt hoàn toàn với hệ thống cũ, nơi 1 role gắn cố định cho 1 user trong toàn hệ thống.

## 5. Client — actor ngoài Agency

- **[CONFIRMED 2026-09-14]** Client KHÔNG phải member nội bộ của Agency/Workspace theo nghĩa nhân sự công ty — là khách hàng thuê Agency thực hiện truyền thông.
- Có **Client Profile riêng** (xem [02-authentication-profile.md](02-authentication-profile.md) mục Client Profile) — tái sử dụng được khi Client tham gia làm việc với nhiều Agency/Workspace khác nhau, không cần khai lại thông tin mỗi lần.
- Được Manager **invite vào 1 Workspace cụ thể** sau khi ghi nhận gói đã chốt bên ngoài để xem gói, theo dõi tiến độ và comment góp ý Campaign, kể cả bản nháp. Client không chọn/đàm phán/duyệt Package hoặc duyệt Campaign trong flow mới. Duyệt kết quả Task/nội dung và kết nối social account vẫn theo module tương ứng.
- Không có quyền quản lý nội bộ Agency/Workspace (thêm/xóa member, đổi cấu hình...) — chỉ có quyền trong phạm vi nghiệp vụ: xem, request, approve/reject, comment.

## 6. Admin — tách biệt hoàn toàn hệ thống

- Admin quản trị toàn hệ thống BrandHub — **không thuộc Agency nào**, không nằm trong cấu trúc Agency→Workspace.
- Xem chi tiết tại [09-admin-management.md](09-admin-management.md).

## 7. Thứ tự nghiệp vụ liên quan (tham chiếu)

Theo BA 2026-11-05, Owner tạo gói quảng bá của Agency và chia sẻ cho khách trước. Sau đó Owner tạo workspace/gán Manager, Manager chốt gói bên ngoài và lưu gói workspace để tự tạo Campaign DRAFT/task, rồi mời Client vào xem và góp ý. Manager hoàn thiện và chủ động triển khai khi đủ điều kiện. Xem [04-media-package-campaign.md](04-media-package-campaign.md).

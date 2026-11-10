# 04. Đặc Tả Giao Diện & Trải Nghiệm Người Dùng (UI/UX & Screen Specification)

## 1. Màn Hình Tạo Agency Mới (`/agency/create`)

### 1.1. Khối Chọn Mục Đích Sử Dụng (Purpose Selection Cards)
Ngay ở đầu trang tạo Agency, hiển thị 2 thẻ lựa chọn trực quan (Radio Cards) có kèm biểu tượng và mô tả rõ ràng:

```text
┌───────────────────────────────────────────────┬───────────────────────────────────────────────┐
│  👤 SỬ DỤNG CHO CÁ NHÂN (Khuyên dùng)         │  🏢 SỬ DỤNG CHO DOANH NGHIỆP / AGENCY         │
│                                               │                                               │
│  Dành cho Solo Creator, Freelancer, KOC       │  Dành cho Media Agency, Marketing Team        │
│  • Tự sáng tạo và đăng bài cho kênh của bạn   │  • Quản lý nhiều khách hàng (Clients)         │
│  • Không cần quy trình duyệt bài khách hàng   │  • Phân quyền thành viên (Manager, Creator)   │
│  • Sẵn sàng làm việc ngay sau khi tạo         │  • Cổng duyệt bài riêng cho khách hàng        │
└───────────────────────────────────────────────┴───────────────────────────────────────────────┘
```

### 1.2. Hành vi Động của Form (Dynamic Form Behavior)

| Trường thông tin | Khi chọn "Cá nhân" (`PERSONAL`) | Khi chọn "Doanh nghiệp" (`BUSINESS`) |
|:---|:---|:---|
| **Tiêu đề trường Tên** | *"Tên thương hiệu / Kênh của bạn"* (Gợi ý: Trí Nguyễn Tech, Bếp Nhà Mai...) | *"Tên Agency / Công ty truyền thông"* |
| **Quy mô nhân sự (Company Size)** | **Ẩn** (Hệ thống tự gán mặc định là 1-10 người) | **Hiển thị** (1-10, 11-50, 51-200, 201-500...) |
| **Lĩnh vực hoạt động (Category)** | Hiển thị (Marketing, F&B, Thời trang, Công nghệ, Khác...) | Hiển thị |
| **Website & Số điện thoại** | Hiển thị (Tùy chọn) | Hiển thị (Tùy chọn) |
| **Màu sắc & Nhận diện (Logo/Banner)** | Giữ nguyên bộ chọn Icon / Preset Banner / Upload ảnh | Giữ nguyên |
| **Mạng xã hội kết nối** | Liên kết Fanpage / TikTok / Instagram cá nhân | Liên kết kênh công ty |
| **Nút bấm Submit** | **"Bắt đầu sáng tạo ngay ✨"** | **"Tạo Agency"** |

---

## 2. Trải Nghiệm Chuyển Đổi Tức Thì (Instant Transition)

Khi người dùng nhấn **"Bắt đầu sáng tạo ngay"**:
1. Nút hiển thị trạng thái loading spinner: *"Đang khởi tạo không gian làm việc cá nhân của bạn..."*
2. Sau khi API trả về kết quả thành công:
   - Hiển thị Toast thông báo: *"Chào mừng bạn! Không gian làm việc cá nhân đã sẵn sàng."*
   - Tự động nạp `defaultWorkspaceId` vào `useWorkspaceStore`.
   - Điều hướng lập tức tới:
     * **Màn hình mặc định**: `/workspaces/{defaultWorkspaceId}/dashboard`
     * (Hoặc nếu người dùng muốn viết bài ngay, có thể cung cấp nút tắt dẫn thẳng tới `/workspaces/{defaultWorkspaceId}/content-writing`).

---

## 3. Tối Ưu Hóa Sidebar Cho Chế Độ Cá Nhân (Personal Mode Sidebar)

### 3.1. Các mục Menu bị ẨN khi ở Agency Cá nhân
Để tránh gây rối mắt và loại bỏ các nghiệp vụ B2B không cần thiết, khi `currentAgency.type === 'PERSONAL'`, hệ thống tự động ẩn các mục sau:

| Nhóm Menu | Đường dẫn (Route) | Lý do ẩn trong chế độ Cá nhân |
|:---|:---|:---|
| **Quản lý Khách hàng** | `/clients`, `/clients/create`, `/clients/:id` | Cá nhân không quản lý khách hàng bên ngoài. |
| **Hồ sơ Khách hàng** | `/client-profiles` | Cá nhân tự làm chủ thương hiệu của mình. |
| **Lời mời Khách hàng** | `/client/invitations` | Không có lời mời khách hàng. |
| **Cổng Khách hàng** | `/portal` | Không cần cổng giao tiếp với khách hàng. |
| **Phân quyền Agency** | `/agency/:id/roles` | Chỉ có 1 người duy nhất, không cần phân quyền vai trò. |
| **Thành viên Workspace** | `/workspaces/:id/members` | Ẩn mục quản lý phân quyền thành viên trong workspace. |
| **Khách hàng Workspace** | `/workspaces/:id/clients` | Ẩn danh sách khách hàng trong workspace. |

### 3.2. Cấu hình Menu hiển thị cho Cá nhân (Sidebar Menu To-Be)
Sidebar dành cho Cá nhân chỉ giữ lại các tính năng cốt lõi phục vụ sản xuất và đăng tải:
* 📊 **Tổng quan**: Dashboard làm việc, Báo cáo hiệu suất kênh (`/analytics`).
* ✍️ **Sáng tạo & Đăng bài**:
  * Viết bài mới (`/content-writing`)
  * Trình biên tập hình ảnh Canvas (`/editor`)
  * Mẫu nội dung (`/templates`)
  * Bộ thẻ hashtag (`/hashtag-groups`)
  * Lịch đăng bài (`/calendar`)
  * Thư viện đa phương tiện (`/library`)
  * Xuất bản & Đăng bài (`/publish`)
* 🔗 **Kết nối & Tài khoản**:
  * Kênh mạng xã hội (`/social-accounts`)
  * Cài đặt tài khoản & Bảo mật (`/settings/profile`, `/settings/security`)
  * Trợ giúp & Hướng dẫn (`/help/guide`)

---

## 4. Tinh Chỉnh Luồng Duyệt Bài Trong Trình Viết Bài (Content Writing / Publishing)

Trong giao diện `/content-writing`:
* **Chế độ Doanh nghiệp**: Có nút *"Gửi duyệt cho khách hàng"* (Chuyển trạng thái sang `PENDING_CLIENT_APPROVAL`).
* **Chế độ Cá nhân**: 
  * Ẩn hoàn toàn nút *"Gửi duyệt cho khách hàng"*.
  * Thay thế bằng 2 nút hành động trực tiếp:
    1. 🚀 **"Đăng ngay (Publish Now)"**: Gửi trực tiếp lên Fanpage/TikTok/Instagram đã kết nối.
    2. ⏰ **"Lên lịch đăng (Schedule)"**: Chọn ngày giờ xuất bản tự động vào lịch.

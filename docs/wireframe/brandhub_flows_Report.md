# BÁO CÁO HOÀN THÀNH TÁC VỤ: DA-E08-03

**Tên tác vụ:** Draw user flow diagrams for 3 main flows: content creation, approval, publishing  
**Mức độ ưu tiên:** 🟡 High (Cao)  
**Mục tiêu:** Xây dựng sơ đồ luồng người dùng (User Flow Diagrams) ở tầng UX (screen-to-screen) cho 3 hành trình cốt lõi của người dùng cuối trên Dashboard BrandHub. Giúp lập trình viên Frontend hiểu rõ cơ chế điều hướng, các điểm kích hoạt (triggers), và sự liên kết giữa các màn hình.

---

## 📌 Checklist Nghiệm thu (Acceptance Criteria)

- [x] **Content Creation Flow (Luồng tạo nội dung):**
  - Điểm bắt đầu: `Creator_Dashboard`
  - Nhập prompt AI: `Creator_Editor` (giao diện cấu hình gợi ý AI)
  - Kết quả thế hệ AI: `Creator_Editor` (hiển thị hình ảnh/văn bản sinh ra từ AI)
  - Chỉnh sửa bản thảo: `Creator_Editor` (cho phép edit thủ công kết quả)
  - Hành động cuối: Lưu bản nháp (Save Draft) / Gửi phê duyệt (Submit for Review).
- [x] **Approval Flow (Luồng phê duyệt nội dung):**
  - Điểm bắt đầu: Nhận thông báo trên `AccountManager_Dashboard`
  - Màn hình đánh giá: `AccountManager_ContentEditor` (xem chi tiết bài viết, hình ảnh)
  - Các hành động: Phê duyệt (Approve) / Từ chối hoặc Yêu cầu chỉnh sửa (`AccountManager_DenyContent` modal)
  - Phản hồi cho người sáng tạo: Cập nhật danh sách công việc trên `Creator_Workspaces`
  - Đưa lên lịch đăng (nếu được duyệt): Tự động đặt lịch hiển thị trên `Creator_Calendar`.
- [x] **Publishing Flow (Luồng xuất bản nội dung):**
  - Quản lý lịch trình: `Creator_Calendar` (hiển thị bài đăng theo ngày giờ được lên lịch)
  - Điểm kích hoạt duyệt cuối: `BrandClient_ClientPortal` (phía đối tác/khách hàng duyệt)
  - Cơ chế duyệt/yêu cầu thay đổi: `BrandClient_CreateForm` / `BrandClient_Deny` / `BrandClient_YourRequest` / `BrandClient_NoRequest`
  - Kết quả xuất bản: Chuyển đổi trạng thái sang `PUBLISHED` (thành công) hoặc `FAILED` (thất bại kèm tùy chọn thử lại - Retry).
- [x] **Technical Alignment (Đồng bộ kỹ thuật):**
  - Sử dụng các đường liên kết (connector arrows) mặc định của Figma để đồng bộ trực tiếp với các Frame thiết kế.
  - Mỗi nút của luồng tương ứng 100% với tên Frame của Wireframe tương ứng trong Figma.

---

## 🛠 Chi Tiết Các Luồng Nghiệm Thu Trên Figma

### 1. Luồng Tạo Nội Dung (Content Creation Flow)
Sơ đồ mô tả quy trình từ lúc Creator truy cập hệ thống đến khi hoàn thành lưu bản nháp hoặc gửi duyệt:

* **Màn hình bắt đầu:** `Creator_Dashboard` (Bản Desktop 1440px và Mobile 390px). 
  * *Điểm kích hoạt (Trigger):* Click nút "Create Content" hoặc chọn Editor từ Sidebar.
* **Màn hình nhập gợi ý:** `Creator_Editor` (Trạng thái trống).
  * *Hành động:* Người dùng nhập prompt AI vào khung cấu hình và click nút "Generate Content".
* **Màn hình kết quả & chỉnh sửa:** `Creator_Editor` (Trạng thái hiển thị kết quả).
  * *Hành động:* AI tạo ra hình ảnh sản phẩm (ví dụ: chai nước hoa trên nền hoa đỏ) và nội dung chữ. Creator có thể tinh chỉnh trực tiếp văn bản này.
* **Hành động kết thúc:** Creator chọn:
  * Click **Save Draft** để lưu nháp cục bộ (Bài viết chuyển trạng thái `DRAFT`).
  * Click **Submit for Review** để gửi lên hệ thống phê duyệt (Bài viết chuyển trạng thái `PENDING_REVIEW`).

---

### 2. Luồng Phê Duyệt (Approval Flow)
Sơ đồ hướng dẫn Account Manager (AM) tiếp nhận thông tin và xử lý phê duyệt bài viết:

* **Nhận thông báo:** AM xem danh sách công việc cần duyệt thông qua Notification Badge hoặc bảng thống kê trên `AccountManager_Dashboard`.
  * *Điểm kích hoạt (Trigger):* Click vào thông báo bài viết mới.
* **Đánh giá nội dung:** AM được điều hướng tới màn hình `AccountManager_ContentEditor`.
  * Tại đây, AM xem trực quan bài đăng của Creator và có 2 lựa chọn:
    1. Click **Approve** (Màu xanh): Chấp thuận bài đăng $\rightarrow$ Bài viết chuyển trạng thái `APPROVED` và tự động hiển thị trên lịch `Creator_Calendar`.
    2. Click **Deny** (Màu đỏ) $\rightarrow$ Kích hoạt Modal Dialog `AccountManager_DenyContent` để nhập lý do từ chối / yêu cầu chỉnh sửa.
* **Phản hồi hệ thống:** Creator nhận được cập nhật trạng thái công việc tại `Creator_Workspaces`. Nếu bị từ chối, bài đăng quay lại trạng thái chỉnh sửa kèm lý do phản hồi của AM.

---

### 3. Luồng Xuất Bản & Khách Hàng Phê Duyệt (Publishing Flow)
Mô tả cách thức khách hàng (Brand Client) thực hiện duyệt cuối và quy trình xuất bản tự động:

* **Quản lý lịch trình:** `Creator_Calendar` hiển thị các bài viết ở trạng thái `SCHEDULED` (đã lên lịch đăng).
* **Khách hàng đánh giá:** Khách hàng đăng nhập vào `BrandClient_ClientPortal` để duyệt các bài đăng thuộc thương hiệu của họ.
  * Nếu đồng ý: Kích hoạt xuất bản theo đúng thời gian lên lịch.
  * Nếu không đồng ý hoặc muốn thay đổi: Click từ chối kích hoạt Modal `BrandClient_Deny` hoặc tạo form yêu cầu chỉnh sửa qua `BrandClient_CreateForm`.
* **Trạng thái yêu cầu:** Các yêu cầu của Client được lưu vết tại `BrandClient_YourRequest` (hoặc quay về `BrandClient_NoRequest` khi đã xử lý xong).
* **Kết quả xuất bản tự động (Publishing Trigger):**
  * Hệ thống tự động đẩy bài lên các nền tảng mạng xã hội khi đến giờ.
  * Trạng thái bài viết được cập nhật thành `PUBLISHED` (Thành công) hoặc `FAILED` (Thất bại kèm nút bấm cho phép Creator nhấn thử lại - Retry).

---

## 📐 Đánh Giá Tính Đồng Bộ Figma-to-Code

Tất cả các tên Frame dùng trong sơ đồ luồng người dùng trên Figma đã được đối chiếu và ánh xạ trực tiếp sang cấu trúc định tuyến và các trang thành phần trong dự án React/Vite:

| Tên Figma Frame | Trang Code Tương Ứng | File Code Link |
| :--- | :--- | :--- |
| `Creator_Dashboard` | Dashboard Page | [DashboardPage.tsx](file:///d:/FPT/FA26/brandhub-ui-design/Uibrandhubs/src/app/pages/DashboardPage.tsx) |
| `Creator_Editor` / `AccountManager_ContentEditor` | Editor Page | [EditorPage.tsx](file:///d:/FPT/FA26/brandhub-ui-design/Uibrandhubs/src/app/pages/EditorPage.tsx) |
| `AccountManager_Dashboard` / `Creator_Workspaces` | Workspaces Page | [WorkspacePage.tsx](file:///d:/FPT/FA26/brandhub-ui-design/Uibrandhubs/src/app/pages/WorkspacePage.tsx) |
| `Creator_Calendar` | Calendar Page | [CalendarPage.tsx](file:///d:/FPT/FA26/brandhub-ui-design/Uibrandhubs/src/app/pages/CalendarPage.tsx) |
| `BrandClient_ClientPortal` | Client Portal Page | [ClientPortalPage.tsx](file:///d:/FPT/FA26/brandhub-ui-design/Uibrandhubs/src/app/pages/ClientPortalPage.tsx) |
| `AccountManager_DenyContent` / `BrandClient_Deny` | Dialog Component | [dialog.tsx](file:///d:/FPT/FA26/brandhub-ui-design/Uibrandhubs/src/app/components/ui/dialog.tsx) |

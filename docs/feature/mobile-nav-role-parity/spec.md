# Nav theo role và các màn mobile bổ sung (2026-10-29)

> Phạm vi: sidebar web, menu/drawer mobile và các màn mobile mới. Nguồn sự thật phân quyền trang là [`brandhub-web/src/routes/access.ts`](../../../../brandhub-web/src/routes/access.ts); mobile phản chiếu trong `brandhub-mobile-app/src/utils/navAccess.ts`.

## 1. Quy tắc

- Một trang chỉ hiện trong nav khi role hiện tại nằm trong quy tắc của route đó. Trang không có quy tắc thì mọi role đều thấy.
- Trên mobile, ngoài việc ẩn mục menu còn **bọc kiểm tra quyền ở cấp màn** (`navigation/withAccess.tsx`): role không đủ quyền thấy "Bạn không có quyền truy cập trang này.". Đây chỉ là lớp giao diện; backend vẫn là nơi quyết định quyền.
- Mục "Mẫu email" của Agency (`/agency/:id/mail-templates`) chỉ hiện cho Owner agency (cờ `agencyOwnerOnly`).

## 2. Ma trận role → trang (workspace)

| Trang | OWNER | MANAGER | CREATOR | CLIENT |
|---|---|---|---|---|
| Lịch (Calendar), Chat | không | có | có | có |
| Yêu cầu nội dung | không | có | có | có |
| Chiến dịch, Gói dịch vụ, Mạng xã hội | có | có | không | có |
| Soạn thảo, Mẫu email, AI Studio | có | có | có | không |
| Xuất bản, Dashboard xuất bản | không | có | có | không |
| Thư viện | không | có | có | có |
| Khách hàng, Mời thành viên, Thành viên Workspace | có | có | không | không |

## 3. Trang web được thêm vào nav

Xuất bản và Dashboard xuất bản (nhóm Tạo nội dung); Thống kê công ty và Mẫu email (nhóm Công ty, Agency); Cơ sở tri thức, Xu hướng, AI Video Studio (nhóm Danh sách); Lời mời (nhóm Lời mời); Lịch sử thanh toán và Mẫu Workspace (sidebar Admin).

## 4. Màn mobile được thêm

| Màn | API | Ghi chú |
|---|---|---|
| Yêu cầu nội dung (danh sách, chi tiết, tạo/sửa) | `/api/v1/workspaces/{id}/content-requests` | Nút theo cờ `can*` do backend trả; ghi kèm `expectedVersion`; hạn nhập `DD/MM/YYYY HH:mm`, server kiểm khoảng hạn |
| Thống kê công ty | `GET /api/v1/agencies/{id}/stats` | Chỉ đọc, chỉ Owner agency; vẽ thanh ngang bằng View, không thêm thư viện biểu đồ |
| Dashboard xuất bản | `GET /api/v1/workspaces/{id}/posts/dashboard` | Chỉ đọc, KPI + theo nền tảng + bài gần đây, lọc theo trạng thái |
| Thư viện | `GET /api/v1/workspaces/{id}/materials` | Chỉ đọc, tìm theo tên, lọc Bản gốc/Đã chỉnh sửa/Đã đóng dấu |

Web: tab Media của Thư viện đã đọc dữ liệu thật qua cùng endpoint `/materials` (lọc, sắp xếp, phân trang xử lý phía client).

## 5. Giới hạn đã biết

- **Phân tích (Analytics)** trên web vẫn là dữ liệu giả; backend không có nguồn số liệu tiếp cận/tương tác từ nền tảng mạng xã hội, nên chưa có API và chưa có màn mobile. Cần quyết định tích hợp insights của từng nền tảng trước.
- **Trang Xuất bản chính** (đăng bài) trên web vẫn dùng dữ liệu giả; mobile mới có Dashboard xuất bản. Backend đã có `submit`, `publish`, `reschedule`.
- **Thư viện web**: đã bỏ nút Upload, Xoá và lọc tỉ lệ khung hình vì chưa có luồng upload web, chưa có endpoint xoá, và API không trả kích thước ảnh. `MediaUploadButton.tsx` và service giả lập không còn được dùng.
- Mobile chưa có màn Xuất bản (đăng bài), Phân tích, và các trang agency khác ngoài Thống kê (vai trò, tín dụng, gói dịch vụ agency).
- Chưa có bằng chứng chạy thật trên trình duyệt/thiết bị; web không có testing-library/jsdom nên không có test component.

## 6. Kiểm thử

Web vitest 70, mobile jest 140 (gồm test cho bảng quyền, `withAccess`, dịch vụ và tiện ích của các màn mới).

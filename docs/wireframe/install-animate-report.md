# BÁO CÁO HỆ THỐNG HOẠT HỌA (ANIMATION REPORT)
**Dự án**: BrandHub UI System  

Báo cáo này tập trung giới thiệu các công nghệ, thư viện hoạt họa được tích hợp, cấu trúc các tệp tin mới được thêm vào và các cải tiến giao diện chuyển động chi tiết trên hệ thống.

---

## I. CÁC THƯ VIỆN HOẠT HỌA SỬ DỤNG (ANIMATION LIBRARIES)

Hệ thống hoạt họa được xây dựng dựa trên sự kết hợp của 3 nền tảng chính nhằm đảm bảo tính thẩm mỹ cao, độ mượt mà và tối ưu hóa hiệu năng:

1. **Framer Motion (`motion/react` v12)**: 
   * Thư viện lõi điều phối toàn bộ các hoạt ảnh chuyển đổi trạng thái, tương tác chuột (hover, tap, mouse move tracking) và quản lý chuyển cảnh trang (`AnimatePresence` + `<motion.div>`).
2. **Animate UI (animate-ui.com)**:
   * Thư viện cung cấp các hiệu ứng tương tác cao cấp như thẻ phát sáng động bám theo con trỏ chuột (`CardSpotlight`) và nút hover trượt nền thương hiệu (`InteractiveHoverButton`).
3. **React Bits (reactbits.dev)**:
   * Thư viện cung cấp các giải pháp nền động loang màu (`BlobBackground`) và hiệu ứng xuất hiện tuần tự từng ký tự (`SplitText`) cho tiêu đề trang.

---

## II. CẤU TRÚC CÁC TỆP TIN THÊM MỚI (NEW FILES STRUCTURE)

Để tránh xung đột với cấu trúc giao diện tĩnh gốc (dùng phục vụ việc xuất nhập Figma `html.to.design`), toàn bộ mã nguồn hoạt họa mới được tách biệt hoặc tổ chức thành các cấu trúc tệp tin như sau:

```
Uibrandhubs/
├── src/
│   ├── app/
│   │   ├── components/
│   │   │   ├── ui/
│   │   │   │   ├── animate-ui/
│   │   │   │   │   ├── CardSpotlight.tsx          # Thẻ phát sáng theo con trỏ chuột
│   │   │   │   │   ├── InteractiveHoverButton.tsx # Nút hover trượt nền màu cam
│   │   │   │   │   └── RippleButton.tsx           # Nút bấm hiệu ứng sóng nước
│   │   │   │   ├── react-bits/
│   │   │   │   │   ├── BlobBackground.tsx         # Nền loang màu hữu cơ di chuyển chậm
│   │   │   │   │   └── SplitText.tsx              # Chữ cái xuất hiện staggered
│   │   │   ├── AnimatedLayout.tsx                 # Layout hoạt họa chung (Sidebar + Page transitions)
│   │   ├── pages/
│   │   │   ├── animated/
│   │   │   │   ├── AnimatedLoginPage.tsx          # Trang đăng nhập hoạt họa mới nhẹ nhàng
│   │   │   │   ├── AnimatedDashboard.tsx          # Trang Tổng quan với các thẻ phát sáng
│   │   │   │   └── AnimatedWorkspace.tsx          # Trang không gian làm việc với thẻ glow tùy chọn màu
│   │   ├── routes.tsx                             # Khai báo nhóm tuyến đường `/animated/*`
```

---

## III. CHI TIẾT HOẠT HỌA ĐƯỢC TÍCH HỢP TRÊN CÁC TRANG

### 1. Layout Chuyển Cảnh & Sidebar (`AnimatedLayout.tsx`)
* **Page Transitions**: Sử dụng cơ chế `<AnimatePresence mode="wait">` kết hợp `<motion.div>` bọc ngoài `<Outlet />`. Khi thay đổi liên kết, trang cũ sẽ mờ dần và trượt lên nhẹ, trang mới sẽ trượt từ dưới lên mượt mà.
* **Sidebar mở rộng**: Các mục trên thanh menu bên trái được nạp hiệu ứng chuyển động mượt mà khi rê chuột và thay đổi trạng thái kích hoạt.

### 2. Trang Đăng Nhập (`AnimatedLoginPage.tsx`)
* **Nền động**: Tích hợp `BlobBackground` với 3 khối màu gradient chuyển động tuần hoàn ngẫu nhiên phía sau biểu mẫu đăng nhập.
* **Tab Form**: Hiệu ứng chuyển đổi qua lại giữa tab "Đăng nhập" và "Đăng ký" áp dụng `<motion.span>` fade-in mượt mà thay vì hiển thị tĩnh.
* **Nút bấm**: Nút "Đăng nhập" sử dụng `RippleButton` tạo làn sóng tròn lan rộng từ điểm click chuột.

### 3. Trang Tổng Quan (`AnimatedDashboard.tsx`)
* **Tiêu đề chào mừng**: Sử dụng component `SplitText` tự động tách tiêu đề thành từng ký tự và đẩy xuất hiện lần lượt (staggered delay `0.05s`).
* **Các thẻ số liệu**: 4 thẻ KPI sử dụng `CardSpotlight` tạo hiệu ứng phát sáng màu cam thương hiệu di chuyển theo tọa độ trỏ chuột của người dùng.

### 4. Trang Không Gian Làm Việc (`AnimatedWorkspace.tsx`)
* **Xuất hiện staggered**: Danh sách các workspace xuất hiện tuần tự từ dưới lên.
* **Spotlight tùy biến màu**: Mỗi thẻ workspace sử dụng `CardSpotlight` có màu loang sáng đồng bộ với màu đại diện thương hiệu riêng của khách hàng đó (Ví dụ: Fashion X loang màu hồng, TechStart loang màu xanh).

### 5. Trang Lịch Biểu ([CalendarPage.tsx](file:///d:/FPT/FA26/brandhub-ui-design/Uibrandhubs/src/app/pages/CalendarPage.tsx))
* **Tương tác ô lịch**: Mỗi ô ngày trên lưới lịch biểu áp dụng `whileHover={{ scale: 1.02, zIndex: 10 }}` và `whileTap={{ scale: 0.98 }}` để nổi bật nhẹ khi rê chuột.
* **Chuyển đổi danh sách**: Danh sách lịch trình chi tiết được bọc `<AnimatePresence>` để khi click chọn ngày khác, các bài viết cũ sẽ tự động trượt đi và các bài viết mới trượt vào êm ái.

### 6. Cổng Khách Hàng ([ClientPortalPage.tsx](file:///d:/FPT/FA26/brandhub-ui-design/Uibrandhubs/src/app/pages/ClientPortalPage.tsx))
* **Danh sách đối tác (Sidebar)**: Áp dụng hiệu ứng dịch chuyển nhẹ sang phải (`whileHover={{ x: 4 }}`) cho nút chọn khách hàng.
* **Mockup bài đăng**: Vùng preview bài đăng được tích hợp chuyển động phóng to mờ dần (`initial={{ scale: 0.96 }}`) mỗi khi chuyển đổi nội dung bài đăng đang xem xét.

### 7. Trang Phân Tích Báo Cáo ([AnalyticsPage.tsx](file:///d:/FPT/FA26/brandhub-ui-design/Uibrandhubs/src/app/pages/AnalyticsPage.tsx))
* **Số liệu KPI**: 4 thẻ số liệu trên cùng tích hợp `CardSpotlight` phát sáng màu cam thương hiệu.
* **Biểu đồ & Danh sách**: Các phân vùng chứa biểu đồ đường, biểu đồ tròn và top bài đăng tự động trượt xuất hiện lần lượt từ dưới lên khi trang được tải.

### 8. Trình Soạn Thảo Soạn Bài ([EditorPage.tsx](file:///d:/FPT/FA26/brandhub-ui-design/Uibrandhubs/src/app/pages/EditorPage.tsx))
* **Thanh tác vụ**: Menu chọn loại kênh đăng bài (`contentType`) được thay bằng component `DropdownMenu` với nút bấm và hiệu ứng mở danh sách popover mượt mà, đồng điệu với shadcn/ui.
* **Tương tác tài nguyên**: Các ô ảnh sản phẩm đầu vào và ảnh kết quả gợi ý từ AI có hiệu ứng zoom tương tác `whileHover={{ scale: 1.05 }}` giúp thao tác nhạy bén và sống động hơn.

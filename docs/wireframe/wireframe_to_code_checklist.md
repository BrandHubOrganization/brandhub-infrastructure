# CHECK-LIST: TỪ WIREFRAME ĐẾN CODE (REACT + SHADCN/UI)
**Dự án:** BrandHub MVP  
**Mục tiêu:** Hướng dẫn quy trình chuẩn hóa từng bước để lập trình viên Frontend chuyển đổi từ bản vẽ wireframe Figma sang mã nguồn React thực tế sử dụng tối đa thư viện `shadcn/ui` có sẵn.

---

## GIAI ĐOẠN 1: FIGMA AUDIT & PHÂN TÍCH COMPONENT

- [ ] **1.1. Xác định Cấu trúc Layout chính (Layout Shell):**
  - [ ] Phân tích xem màn hình dùng bố cục Sidebar cố định (Dashboard, Workspace, Calendar, Analytics) hay layout toàn màn hình (Login).
  - [ ] Nhận diện các vùng có thể co giãn, thu gọn (ví dụ: AI Generation Panel bên trái và Post Preview bên phải trong EditorPage).
- [ ] **1.2. Liệt kê Component shadcn/ui cần tải thêm:**
  - [ ] Đối chiếu bản wireframe với danh mục thư viện shadcn/ui hiện có trong `src/app/components/ui`.
  - [ ] Đánh dấu các component mới cần thêm (ví dụ: `Dialog`, `Progress`, `Switch`, `Slider`, `Carousel`, `HoverCard`, `AspectRatio`).
- [ ] **1.3. Xác định các Component Tuỳ biến (Custom components):**
  - [ ] Xác định các phần tử giao diện phức tạp không có sẵn trong shadcn/ui để lên kế hoạch build riêng:
    - [ ] `PostSimulator.tsx` (Mô phỏng Feed Facebook/Instagram/TikTok).
    - [ ] `ModelLibraryDialog.tsx` (Hộp thoại chọn người mẫu AI từ hệ thống).
    - [ ] `TimelineCalendar.tsx` (Lịch đăng bài dạng Timeline dọc cho mobile 375px).

---

## GIAI ĐOẠN 2: SETUP MÔI TRƯỜNG & THÊM COMPONENT

- [ ] **2.1. Cài đặt thêm shadcn/ui component qua CLI:**
  - Chạy lệnh cài đặt các component cần thiết cho luồng Editor, Calendar và Portal:
  ```powershell
  npx shadcn@latest add dialog tooltip slider switch progress carousel hover-card aspect-ratio sheet
  ```
- [ ] **2.2. Kiểm tra File cấu hình Tailwind & CSS Variables:**
  - [ ] Đảm bảo các token màu sắc (`--background`, `--primary`, `--border`, v.v.) trong `src/styles` hoạt động chính xác cả ở chế độ Light/Dark mode.
  - [ ] Kiểm tra font chữ (`font-sans`, `font-mono`) đã được mapping đúng theo CSS variables chưa.

---

## GIAI ĐOẠN 3: XÂY DỰNG KHUNG LAYOUT (LAYOUT SHELL)

- [ ] **3.1. Dựng Layout Sidebar & Header:**
  - [ ] Sử dụng các component `Sidebar` gốc để thiết lập thanh menu bên trái.
  - [ ] Cấu hình Workspace Switcher bằng `DropdownMenu` với trigger là một button hiển thị chevrons-up-down.
  - [ ] Dựng Header chứa `Breadcrumb` điều hướng động và Popover thông báo (`NotificationPopover`).
- [ ] **3.2. Triển khai Layout Cột Co Giãn (cho Editor Page):**
  - [ ] Sử dụng `ResizablePanelGroup` làm container chính.
  - [ ] Chia thành 3 `ResizablePanel` (Trái: AI Panel, Giữa: Soạn thảo, Phải: Preview).
  - [ ] Sử dụng `ResizableHandle` đi kèm thuộc tính `withHandle` để tạo đường kéo giãn trực quan.

---

## GIAI ĐOẠN 4: LẮP RÁP UI CHI TIẾT & CUSTOM SIMULATORS

- [ ] **4.1. Triển khai AI Generation Panel (Cột Trái Editor):**
  - [ ] Dựng tab chuyển đổi Chữ/Ảnh/Video bằng `Tabs`.
  - [ ] Dựng danh sách tài liệu Request Assets bằng thẻ `Card` chứa ảnh sản phẩm được bọc trong `AspectRatio` kèm nút `Checkbox` chọn.
  - [ ] Tích hợp nút mở Thư viện AI Model bằng `Dialog`. Khi mở ra, render Grid chứa danh sách ảnh model dạng `Avatar`, bộ lọc `Select` và cuộn bằng `ScrollArea`.
- [ ] **4.2. Triển khai Editor Area (Cột Giữa Editor):**
  - [ ] Dựng form nhập tiêu đề bài viết bằng `Input` và text area soạn thảo caption bằng `Textarea` hoặc rich text editor.
  - [ ] Thêm khu vực hiển thị các Assets đã chọn (Product + Model) dạng Card nhỏ.
  - [ ] Thêm thanh tiến trình `Progress` sinh ảnh/video của AI kèm Badge mô tả tiến độ.
  - [ ] Dựng `Carousel` hiển thị danh sách ảnh kết quả do AI sinh ra (AI Generation History) kèm nút "Áp dụng" và "Bỏ qua".
- [ ] **4.3. Dựng Giao Diện Mô Phỏng (Post Simulator - Cột Phải):**
  - [ ] Tạo file component riêng `post-simulator.tsx`.
  - [ ] Mô phỏng giao diện Facebook: Thiết kế Card có Avatar brand, tên thương hiệu, thời gian đăng bài, text caption và phần hình ảnh 1:1 hoặc link preview.
  - [ ] Mô phỏng giao diện TikTok/Instagram: Khung dọc tỷ lệ 9:16 có nút thả tim, bình luận giả lập.

---

## GIAI ĐOẠN 5: PHÂN QUYỀN GIAO DIỆN (ROLE-BASED RENDERING)

- [ ] **5.1. Triển khai Auth Context hoặc Hook phân quyền:**
  - [ ] Xây dựng hook `useUser` để lấy thông tin vai trò hiện tại (`ROLE_OWNER`, `ROLE_MANAGER`, `ROLE_ACCOUNT`, `ROLE_CREATOR`, `ROLE_CLIENT`, v.v.).
- [ ] **5.2. Điều khiển Ẩn/Hiện phần tử (Visibility Matrix):**
  - [ ] **Trong Editor Page:**
    - [ ] Nếu là `CREATOR`: Hiện nút "Gửi AM duyệt" (`Submit to AM`). Ẩn thanh công cụ duyệt bài.
    - [ ] Nếu là `AM`: Ẩn nút "Gửi AM duyệt". Hiện thanh công cụ duyệt bài ở chân trang Preview (Gồm nút "Phê duyệt" và nút "Từ chối" mở Dialog nhập feedback).
  - [ ] **Trong Workspace Page:**
    - [ ] Ẩn các nút "Xoá Workspace" hoặc "Cấu hình AI Credits" nếu người dùng không phải là `OWNER`.
    - [ ] Chặn truy cập (Redirect về Client Portal) nếu là `CLIENT`.

---

## GIAI ĐOẠN 6: STATE MANAGEMENT & DỮ LIỆU MOCK (DUMMY STATE)

- [ ] **6.1. Quản lý trạng thái Form & AI Generation:**
  - [ ] Tạo state quản lý: Prompt đầu vào, Ảnh sản phẩm đang chọn, Model đang chọn, Tiến độ AI loading (`boolean`), Danh sách ảnh kết quả sinh ra (`string[]`).
- [ ] **6.2. Thiết lập Trạng thái Tải dữ liệu (Loading/Skeleton):**
  - [ ] Khi `aiLoading === true`, hiển thị component `Skeleton` đè lên vùng soạn thảo và Preview để ngăn tương tác.
- [ ] **6.3. Tích hợp Toast Thông Báo:**
  - [ ] Gọi hàm `toast()` từ hook `useToast` khi Creator bấm gửi bài duyệt thành công, khi AM phê duyệt bài đăng, hoặc khi tải tài liệu RAG lên thành công.

---

## GIAI ĐOẠN 7: TỐI ƯU HÓA RESPONSIVE & MOBILE (375PX)

- [ ] **7.1. Ẩn/Hiện Panel theo Breakpoint:**
  - [ ] Sử dụng các tiền tố Tailwind (`hidden md:block`, `block md:hidden`) để ẩn AI Panel và Preview Panel trên màn hình di động, dồn toàn bộ giao diện thành 1 cột chính.
  - [ ] Dùng `Sheet` (Drawer di động) để chứa Sidebar điều hướng khi người dùng bấm vào Hamburger Menu ở Header.
- [ ] **7.2. Tối ưu hóa Calendar Mobile:**
  - [ ] Ẩn lưới lịch tháng 30 ngày trên màn hình dưới `md`.
  - [ ] Render thanh 7 ngày trong tuần trượt ngang (`ScrollArea` + Flex).
  - [ ] Render timeline dọc chứa các Card bài đăng chi tiết trong ngày được chọn.
- [ ] **7.3. Triển khai Sticky Bottom Bar cho Post Preview:**
  - [ ] Trên mobile, khi ở view Post Preview, cố định nút Phê duyệt và Từ chối bằng class `fixed/sticky bottom-0 left-0 right-0 border-t bg-background p-3 flex gap-2`.

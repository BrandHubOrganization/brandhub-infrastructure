# BÁO CÁO KẾT QUẢ THỰC HIỆN TASK [DA-E08-01]
## THIẾT KẾ FIGMA WIREFRAME CHO CÁC MÀN HÌNH CHÍNH - BRANDHUB PLATFORM

---

### I. THÔNG TIN CHUNG (METADATA)
* **Mã Task:** DA-E08-01
* **Tên Task:** Create Figma wireframes for all main screens (Login, Dashboard, Workspace, Content Editor, Calendar, Client Portal, Analytics)
* **Người thực hiện (Assignee):** Nguyễn Văn Lộc (Frontend Developer)
* **Độ ưu tiên (Priority):** 🔴 Critical (Nghiêm trọng)
* **Trạng thái (Status):** Hoàn thành (Dự thảo Low-to-Mid Fidelity bàn giao cho Frontend & Mentor)
* **Nền tảng mục tiêu:** 
  * Web Dashboard: Desktop Breakpoint 1440px (Primary)
  * Mobile App: Mobile Frame 375px (Cho các luồng core)
* **Tài liệu tham chiếu hệ thống:** 
  * `project_context.md` (Tài liệu đặc tả bối cảnh dự án BrandHub)
  * `brandhub_wireframe_blueprint.md` (Tài liệu đặc tả wireframe dự án BrandHub)
  * `wireframe_to_code_checklist.md` (Checklist quy trình chuẩn hóa từ wireframe sang code React)

---

### II. MỤC TIÊU & TIÊU CHUẨN NGHIỆM THU (OBJECTIVES & ACCEPTANCE CRITERIA)
1. **Mục tiêu cốt lõi:** Xây dựng bản vẽ wireframe độ trung thực thấp đến trung bình (low-to-mid fidelity) cho toàn bộ 7 phân hệ màn hình chính của BrandHub. Tạo cơ sở giao diện trực quan giúp đội ngũ phát triển Frontend có thể lập trình cấu trúc component song song, đồng thời giúp kiểm thử và xác thực luồng trải nghiệm người dùng (UX Flow) với Mentor từ giai đoạn sớm, tránh đập đi xây lại code.
2. **Tiêu chuẩn nghiệm thu đạt được:**
   * Hoàn thành đầy đủ cấu trúc wireframe cho 7 hạng mục màn hình theo yêu cầu.
   * Tích hợp thành công cơ chế hiển thị giao diện biến thể theo vai trò người dùng (Role-Based Access Control - RBAC Layout).
   * Gắn nhãn chú thích (Annotations) chính xác 100% theo tên định danh component của thư viện **shadcn/ui** để lập trình viên thực hiện mapping nhanh chóng.
   * Bổ sung đầy đủ khung hiển thị Mobile 375px cho 3 phân hệ trải nghiệm bắt buộc trên ứng dụng di động: Content Calendar, Notifications, và Post Preview.

---

### III. BÓC TÁCH CHI TIẾT CẤU TRÚC LAYOUT 7 MÀN HÌNH CHÍNH (DESKTOP 1440PX & MOBILE 375PX)

#### 1. Màn hình Đăng nhập & Xác thực (Login / Auth Screen)
* **Bố cục tổng quan (Layout Shell):** Thiết kế dạng Toàn màn hình (Fullscreen Grid Layout) chia làm 2 phần độc lập:
  * *Bên trái (60%):* Khu vực đồ họa thương hiệu tối giản, hiển thị logo BrandHub lớn, slogan và hình ảnh minh họa trừu tượng về quy trình tự động hóa AI Content.
  * *Bên phải (40%):* Khung form điền thông tin đăng nhập được căn giữa theo chiều dọc và chiều ngang.
* **Biến thể giao diện theo Role:** 
  * Màn hình ban đầu áp dụng chung cho mọi phân quyền khách (Guest). Sau khi người dùng nhập thông tin và hệ thống kiểm tra JWT token thành công, phân hệ router sẽ tự động chuyển hướng (Redirect) sang không gian làm việc tương ứng với Role của user (ví dụ: Admin về hệ thống tổng, Client về Client Portal).
* **Bản đồ Component Chú thích shadcn/ui:**
  * Toàn bộ khung form: `[Card]` kết hợp `[CardHeader]`, `[CardTitle]`, `[CardContent]`.
  * Trường nhập liệu tài khoản/mật khẩu: `[Input]` có label rõ ràng.
  * Nút hành động đăng nhập tiêu chuẩn và nút Google OAuth đăng nhập nhanh: `[Button]`.
  * Liên kết đăng ký/quên mật khẩu: Thẻ text anchor kết hợp typography chuẩn.
* **Thiết kế Mobile (375px):** Ẩn hoàn toàn khối đồ họa thương hiệu bên trái (hidden). Đẩy khung form `[Card]` ra toàn màn hình (width: 100%), tối ưu padding 16px để người dùng dễ thao tác trên màn hình cảm ứng di động.

#### 2. Màn hình Tổng quan Hệ thống (Main Dashboard)
* **Bố cục tổng quan (Layout Shell):** Áp dụng kiến trúc khung chuẩn chỉnh (Layout Shell):
  * *Sidebar (Cố định bên trái):* Thanh menu điều hướng chính của hệ thống.
  * *Header (Cố định phía trên):* Chứa bộ chuyển đổi Workspace, thanh tìm kiếm nhanh, nút thông báo và thông tin tài khoản cá nhân.
  * *Main Content Area (Khu vực trung tâm):* Hiển thị lưới số liệu thống kê (Card Grid) và các bảng tóm tắt hoạt động gần đây.
* **Biến thể giao diện theo Role (Role-Specific Variations):**
  * `ROLE_ADMIN`: Hiển thị các chỉ số vĩ mô toàn hệ thống bao gồm: Tổng số lượng agency đang hoạt động, số lượng gói Subscription đăng ký, lượng AI Credit đã tiêu thụ trong tháng, biểu đồ doanh thu tổng và nút xuất báo cáo tổng hợp.
  * `ROLE_AGENCY_OWNER`: Hiển thị số liệu hiệu suất riêng của Agency đó bao gồm: Tỷ lệ đăng bài thành công trên đa kênh, tổng dung lượng lưu trữ AWS S3 đã dùng, bảng theo dõi khối lượng công việc (workload) và hiệu suất xử lý task của các Creator nội bộ.
  * `ROLE_ACCOUNT_MANAGER`: Tập trung hiển thị danh sách các Brand Clients đang phụ trách kèm theo trạng thái tiến độ của các chiến dịch hiện hành và số lượng task đang chờ duyệt chỉnh sửa.
* **Bản đồ Component Chú thích shadcn/ui:**
  * Cấu trúc khung chỉ số: Lưới `[Card]` kết hợp các icon minh họa.
  * Bảng danh sách hoạt động / khách hàng: `[Table]` với các cột phân tách rõ ràng.
  * Bộ lọc khoảng thời gian (Ngày/Tuần/Tháng): Component `[Select]` hoặc `[DatePicker]`.
  * Thanh hiển thị hạn mức tài nguyên (AI Credit, Storage): Component `[Progress]`.

#### 3. Quản lý Không gian làm việc (Workspace Management)
* **Bố cục tổng quan (Layout Shell):** Kế thừa Layout Shell chung (Sidebar + Header). Khu vực nội dung chính chia làm hai khu vực lớn:
  * *Phía trên:* Header của nội dung chứa tiêu đề Workspace hiện tại, thông tin mô tả và thanh công cụ tìm kiếm/lọc thành viên.
  * *Phía dưới:* Chia làm 2 tab lớn để quản lý "Hồ sơ Khách hàng (Brand Client Profiles)" và "Đội ngũ Nhân sự (Team Members)".
* **Biến thể giao diện theo Role (Role-Specific Variations):**
  * `ROLE_AGENCY_OWNER`: Toàn quyền thao tác. Hiển thị nút "Tạo Workspace mới", nút "Mời thành viên" và nút cấu hình hạn mức AI Credits cấp phát cho từng Client.
  * `ROLE_ACCOUNT_MANAGER`: Chỉ xem được danh sách các Client được Agency Owner chỉ định và gán quyền quản lý; có quyền thêm mới tài khoản MXH kết nối cho khách hàng đó nhưng không được quyền cấu hình tài nguyên hệ thống hoặc xóa Workspace.
  * `ROLE_BRAND_CLIENT`: Hệ thống tự động chặn quyền truy cập màn hình này và thực hiện lệnh điều hướng cưỡng bức về phân hệ Client Portal để bảo mật dữ liệu tuyệt đối.
* **Bản đồ Component Chú thích shadcn/ui:**
  * Thanh chuyển đổi danh mục: Bộ component `[Tabs]`, `[TabsList]`, `[TabsTrigger]`, `[TabsContent]`.
  * Hộp thoại thêm mới Client / Mời thành viên: Sử dụng `[Dialog]` (Modal cửa sổ sổ lên) kết hợp form nhập liệu bên trong.
  * Danh sách thành viên và phân quyền tương ứng: Component `[Table]` hiển thị kèm theo `[Badge]` phân loại vai trò (ví dụ: Creator có màu xanh, AM có màu tím) và nút `[DropdownMenu]` ở cuối dòng để thực hiện kích hoạt/hủy quyền.

#### 4. Trình chỉnh sửa nội dung ứng dụng AI (Content Editor)
* **Bố cục tổng quan (Layout Shell):** Đây là màn hình phức tạp nhất hệ thống. Áp dụng bố cục 3 cột linh hoạt có thể co giãn, mở rộng hoặc thu gọn tùy ý bằng giải pháp `[ResizablePanelGroup]` của shadcn/ui:
  * *Cột trái (AI Generation Panel):* Không gian tương tác với các mô hình trí tuệ nhân tạo.
  * *Cột giữa (Editor Area):* Vùng soạn thảo tiêu đề, caption văn bản, đính kèm tài nguyên đa phương tiện và cấu hình thẻ hashtag.
  * *Cột phải (Post Simulator Panel):* Khu vực hiển thị giao diện mô phỏng thực tế của bài viết sau khi xuất bản lên các mạng xã hội target.
* **Biến thể giao diện theo Role (Role-Specific Variations):**
  * `ROLE_CONTENT_CREATOR`: Cột trái hiển thị đầy đủ các trường nhập văn bản prompt đầu vào cho AI, bộ chọn tài liệu thương hiệu tham chiếu từ VectorDB (RAG), nút kích hoạt sinh văn bản/hình ảnh. Phía trên Header xuất hiện nút chủ đạo hành động là `[Button]` "Submit to AM" (Gửi cho Account Manager duyệt).
  * `ROLE_ACCOUNT_MANAGER`: Khóa hoặc ẩn các tính năng sinh nội dung AI ở cột trái nhằm tối ưu không gian làm việc. Thay vào đó, tại chân trang của cột phải (Post Simulator) sẽ hiển thị một thanh công cụ phê duyệt (Review Tooling Bar) nổi bật bao gồm 2 nút: `[Button]` "Approve to Client" (Chấp thuận để gửi cho khách hàng xem) và `[Button]` "Reject / Request Revision" (Từ chối / Yêu cầu sửa đổi, khi bấm sẽ kích hoạt một cửa sổ mở rộng nhập feedback chi tiết).
* **Bản đồ Component Chú thích shadcn/ui:**
  * Khung phân chia 3 cột co giãn: `[ResizablePanelGroup]`, `[ResizablePanel]`, `[ResizableHandle withHandle]`.
  * Phân loại sinh nội dung (Chữ/Ảnh/Video) ở cột trái: Component `[Tabs]`.
  * Tỷ lệ khung hình ảnh sản phẩm / tư liệu sinh ra: Được bọc trong `[AspectRatio]` tỉ lệ 1:1 hoặc 9:16 để tránh vỡ khung layout.
  * Thư viện chọn người mẫu ảnh AI: Component `[Dialog]` hiển thị grid danh sách hình ảnh kết hợp thanh cuộn `[ScrollArea]`.
  * Form nhập liệu caption: Component `[Textarea]` có tích hợp đếm ký tự tự động theo thời gian thực.
  * Trạng thái AI đang xử lý sinh dữ liệu: Sử dụng `[Skeleton]` dạng thanh hoặc khối phối hợp với component `[Progress]` chạy phần trăm để báo hiệu trực quan cho người dùng, ngăn chặn các thao tác click lặp lại gây lỗi.
* **Thiết kế Mobile (375px) - Tích hợp Post Preview Luồng cốt lõi:**
  * Trên thiết bị di động, do giới hạn không gian hiển thị, hệ thống tự động áp dụng class Tailwind `hidden md:block` để ẩn hoàn toàn cột AI Panel bên trái và cột Preview bên phải. Toàn bộ màn hình dồn về 1 cột soạn thảo duy nhất.
  * Thiết kế bổ sung một nút nổi "Xem Preview nhanh" cố định. Khi người dùng click vào, hệ thống sử dụng component `[Sheet]` (Drawer kéo lên từ cạnh đáy màn hình) để hiển thị giao diện mô phỏng bài viết (Post Simulator) chuẩn 100% giao diện di động của Facebook/TikTok.

#### 5. Lịch biên tập & Đăng bài (Content Calendar)
* **Bố cục tổng quan (Layout Shell):** Kế thừa Layout Shell chuẩn. Không gian nội dung chính chiếm trọn vẹn diện tích hiển thị để phục vụ lưới lịch thời gian.
  * *Thanh điều khiển phía trên:* Chứa nút chuyển đổi tháng/tuần, các nút chuyển sang tháng trước/kế tiếp, và bộ lọc nhanh theo Kênh mạng xã hội (Facebook, Instagram, TikTok...) hoặc bộ lọc theo trạng thái bài viết (Đã đăng, Chờ duyệt, Bản nháp).
  * *Vùng lưới chính:* Render lưới lịch chuẩn dạng 7 cột (tương ứng từ Thứ Hai đến Chủ Nhật) và hiển thị từ 4 đến 5 hàng tùy theo tháng.
* **Biến thể giao diện theo Role (Role-Specific Variations):**
  * `ROLE_ACCOUNT_MANAGER` & `ROLE_CONTENT_CREATOR`: Xem được toàn bộ lịch đăng bài trong không gian làm việc chung. AM có quyền thực hiện thao tác kéo thả (Drag-and-Drop) các block bài viết để thay đổi thời gian xuất bản dự kiến, bấm trực tiếp vào ô ngày để lên lịch bài đăng mới.
  * `ROLE_BRAND_CLIENT`: Giao diện chuyển sang trạng thái "Chỉ xem (Read-only Calendar)". Khách hàng hoàn toàn không thể thực hiện kéo thả thay đổi lịch đăng hay tạo bài viết mới trên Calendar, đảm bảo kế hoạch truyền thông của agency không bị can thiệp sai lệch. Khách hàng chỉ có quyền bấm vào bài viết để xem chi tiết nội dung và lịch sử đăng bài thành công.
* **Bản đồ Component Chú thích shadcn/ui:**
  * Bộ lọc nhanh kênh MXH: Sử dụng component `[Popover]` chứa danh sách check-box hoặc dùng `[ToggleGroup]`.
  * Thẻ hiển thị thông tin bài viết thu nhỏ trong từng ô ngày: Sử dụng `[Card]` kích thước siêu nhỏ, có gán màu sắc biên nhận diện theo trạng thái bài đăng, đính kèm một icon nhỏ đại diện cho nền tảng đăng bài (ví dụ: Icon TikTok, Icon Facebook).
  * Khi rê chuột vào thẻ bài viết thu nhỏ: Kích hoạt hiển thị cửa sổ thông tin nhanh bằng `[HoverCard]` để xem trước caption và ảnh thumbnail mà không cần click mở hẳn trang mới.
* **Thiết kế Mobile (375px) - Quy chuẩn Lịch thu gọn:**
  * Ẩn hoàn toàn lưới lịch 30 ngày cồng kềnh trên phiên bản Mobile. Thay thế bằng cấu trúc lịch dạng Timeline dòng chảy: Phía trên cùng hiển thị một thanh gồm 7 ngày trong tuần trượt ngang linh hoạt bằng sự kết hợp của `[ScrollArea]` và thanh định dạng Flexbox.
  * Phía dưới thanh chọn ngày là danh sách dọc hiển thị tuần tự các Card bài đăng chi tiết được sắp xếp theo trục thời gian (Giờ - Phút) của ngày được chọn, giúp người quản lý dễ dàng bao quát lịch trình phân phối bằng một tay trên điện thoại di động.

#### 6. Phân hệ Khách hàng (Client Portal)
* **Bố cục tổng quan (Layout Shell):** Thiết kế hoàn toàn độc lập, tinh gọn và tách biệt với giao diện quản trị phức tạp của Agency. 
  * *Sidebar thu gọn:* Chỉ chứa 3 danh mục tối giản: Tổng quan chiến dịch, Gửi yêu cầu (Content Request), Lịch đăng bài (Calendar - Read-only).
  * *Khu vực nội dung trọng tâm:* Chia làm 2 phần rõ rệt: Khối xử lý tác vụ phê duyệt bài viết ở bên trái và bảng theo dõi tiến độ xử lý yêu cầu ở bên phải.
* **Biến thể giao diện theo Role (Role-Specific Variations):**
  * Phân hệ này được thiết kế may đo đặc thù phục vụ riêng cho đối tượng `ROLE_BRAND_CLIENT`. Khách hàng đăng nhập vào sẽ thấy logo thương hiệu của chính họ hiển thị song song với logo BrandHub để tăng tính chuyên nghiệp (Co-branding).
* **Bản đồ Component Chú thích shadcn/ui:**
  * Nút "Gửi yêu cầu nội dung mới": Sử dụng `[Button]` có biến thể màu nhấn mạnh (Primary), khi bấm sẽ mở ra một form toàn diện bọc trong component `[Sheet]` hoặc `[Dialog]` để khách hàng nhập brief, đính kèm file tài liệu guidelines, chọn đối tượng mục tiêu và deadline.
  * Danh sách bài đăng chờ duyệt: Sử dụng `[Carousel]` để khách hàng có thể vuốt qua lại duyệt nhanh chuỗi các bài viết do Agency gửi sang. Mỗi slide của Carousel là một `[Card]` bài viết tích hợp giao diện Post Simulator thực tế, kèm theo bộ đôi hành động trực tiếp: Nút màu xanh "Phê duyệt đăng bài" và nút màu đỏ "Từ chối / Gửi feedback".

#### 7. Báo cáo & Thống kê dữ liệu (Analytics Dashboard)
* **Bố cục tổng quan (Layout Shell):** Giữ bộ khung Layout Shell chuẩn hệ thống. Khu vực chính được tổ chức khoa học nhằm hiển thị dữ liệu trực quan:
  * *Hàng trên cùng:* Thanh bộ lọc nâng cao cho phép lọc dữ liệu tổng hợp theo từng tài khoản mạng xã hội cụ thể, theo chiến dịch hoặc theo khoảng thời gian tùy chỉnh. Đính kèm nút hành động "Xuất báo cáo".
  * *Hàng trung tâm:* Hệ thống các thẻ thống kê tổng lượng tương tác (Like, Share, Comment, Reach) và tỷ lệ tăng trưởng so với kỳ trước.
  * *Hàng dưới:* Khu vực hiển thị các đồ thị biểu đồ phân tích sâu xu hướng và danh sách các bài viết đạt hiệu suất cao nhất (Top Performing Posts).
* **Biến thể giao diện theo Role (Role-Specific Variations):**
  * `ROLE_AGENCY_OWNER` & `ROLE_ACCOUNT_MANAGER`: Tiếp cận toàn bộ dữ liệu phân tích chi tiết của tất cả các tài khoản MXH của khách hàng đã kết nối. Có quyền cấu hình các chỉ số mục tiêu (KPIs) và xuất file dữ liệu thô (.xlsx) hoặc file báo cáo đẹp mắt gửi khách hàng (.pdf).
  * `ROLE_BRAND_CLIENT`: Tiếp cận phiên bản dashboard phân tích đã được lược bớt các chỉ số vận hành nội bộ của agency, chỉ tập trung hiển thị các biểu đồ hiệu suất bài đăng thực tế thu thập từ API của các nền tảng (Facebook Reach, TikTok Views...).
* **Bản đồ Component Chú thích shadcn/ui:**
  * Khối chứa đồ thị biểu đồ tĩnh/SVG (Hệ thống không chạy JS chart động trên bản in/PDF): Sử dụng cấu trúc `[Card]` làm container nền.
  * Bảng xếp hạng các bài viết hot nhất: Thành phần `[Table]` hiển thị kết hợp `[Avatar]` ảnh thumbnail bài viết thu nhỏ.
  * Nút xuất dữ liệu báo cáo: Component `[Button]` kết hợp menu sổ xuống `[DropdownMenu]` hiển thị hai lựa chọn định dạng tệp tin: "Export as PDF Report" và "Export as Excel Spreadsheet".

---

### IV. HƯỚNG DẪN MAPPING KỸ THUẬT CHO ĐỘI NGŨ FRONTEND (TECHNICAL GUIDELINES)

Dựa trên cấu trúc bản check-list từ wireframe sang code, lập trình viên Frontend khi tiếp nhận bản wireframe này cần tuân thủ quy trình triển khai mã nguồn React + Tailwind + shadcn/ui như sau:

1. **Khởi tạo và bổ sung Thư viện Component:**
   Trước khi tiến hành code chi tiết các vùng nội dung, lập trình viên cần chạy lệnh CLI của shadcn để cài đặt đồng bộ toàn bộ các primitive component đã được gắn nhãn trên wireframe:
   ```powershell
   npx shadcn@latest add dialog tooltip slider switch progress carousel hover-card aspect-ratio sheet tabs resizable
   ```
2. **Cơ chế Phân quyền hiển thị (Role-Based Access Control Implementation):**
   * Sử dụng hoặc thiết lập một React Context / Custom Hook có tên `useUser()` để quản lý trạng thái phiên đăng nhập và phân quyền hiện tại của tài khoản người dùng.
   * Sử dụng mệnh đề điều kiện hoặc kỹ thuật đóng bọc component (Wrapper Components) để quản lý ẩn hiện layout linh hoạt. Tránh viết quá nhiều câu lệnh rẽ nhánh if/else lồng nhau phức tạp bên trong file giao diện chính.
   * *Ví dụ minh họa cấu trúc sạch:*
     ```tsx
     import { useUser } from "@/hooks/use-user";
     import { Button } from "@/components/ui/button";

     export function EditorReviewActions() {
       const { user } = useUser();

       return (
         <div className="flex gap-2">
           {user.role === "ROLE_CONTENT_CREATOR" && (
             <Button variant="default">Submit to AM</Button>
           )}
           {user.role === "ROLE_ACCOUNT_MANAGER" && (
             <>
               <Button variant="outline" className="border-destructive text-destructive">Reject</Button>
               <Button variant="default" className="bg-green-600 hover:bg-green-700">Approve to Client</Button>
             </>
           )}
         </div>
       );
     }
     ```
3. **Quản lý Trạng thái Trực quan (State & Loading UX):**
   * Đồng bộ hóa biến trạng thái `aiLoading: boolean` với các khối UI. Khi trạng thái này mang giá trị true, lập trình viên bắt buộc phải kích hoạt hiển thị che phủ bằng component `[Skeleton]` để vô hiệu hóa tạm thời các nút bấm hành động xung quanh, đảm bảo đúng tinh thần thiết kế wireframe đề ra, tối ưu hóa trải nghiệm tương tác mượt mà và an toàn cho người sử dụng.

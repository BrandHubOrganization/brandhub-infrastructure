# BRANDHUB WIREFRAME BLUEPRINT & SOLUTIONS ARCHITECTURE
**Dự án:** BrandHub (AI-Powered Multi-Channel Content Platform)  
**Vai trò:** UX/UI Specialist & Solutions Architect (shadcn/ui Specialist)  
**Tác giả:** Loc20904 
**Target Breakpoints:** Desktop (1440px) & Mobile (375px)  

---

## I. TỔNG QUAN HỆ THỐNG PHÂN QUYỀN (RBAC) & THIẾT KẾ UX/UI

### 1. Bảng Ma Trận Phân Quyền (Role Access Matrix)
Hệ thống BrandHub vận hành xoay quanh 5 vai trò chính với các mức tiếp cận thông tin khác nhau. Việc thiết kế Wireframe phải đảm bảo cơ chế ẩn/hiện hoặc khoá/mở các UI Component tương ứng:

| Màn hình / Tính năng | Admin | Agency Owner | Account Manager (AM) | Content Creator | Brand Client |
|---|---|---|---|---|---|
| **1. Login/Auth** | Đăng nhập hệ thống | Đăng nhập hệ thống | Đăng nhập hệ thống | Đăng nhập hệ thống | Đăng nhập Portal |
| **2. Main Dashboard** | Toàn hệ thống (System KPI) | Agency KPI & Workspaces | Approval Queue & Tasks | My Tasks & AI Credits | Client Approval List |
| **3. Workspace Management** | Toàn quyền (All Workspaces) | Tạo/Xoá, Mời AM/Creator | Quản lý thành viên & Brands | Xem tài liệu RAG | Không thể truy cập (403) |
| **4. Content Editor** | View-only (Audit) | View-only/Edit | Duyệt bài, Request changes | Tạo/Sửa bài, Gọi AI (RAG) | Không truy cập (Xem qua Portal) |
| **5. Content Calendar** | View-only | Full Control (Kéo/thả) | Full Control (Kéo/thả) | Edit bài của mình (Draft) | Read-only Calendar |
| **6. Client Portal** | Không truy cập | Impersonate (Xem hộ) | Quản lý duyệt bài | Nhận feedback tự động | Duyệt bài, Tạo Request |
| **7. Analytics Dashboard** | Doanh thu & AI credits | Toàn bộ Workspace KPI | KPI của Client phụ trách | KPI của bài viết cá nhân | KPI Social Channels riêng |

### 2. Nguyên tắc thiết kế UX/UI cho BrandHub
1. **Thiết kế nhất quán (Consistency):** Toàn bộ giao diện sử dụng hệ thống Design Token của `shadcn/ui`. Các khoảng cách (spacing), bo góc (radius), màu nền (background/foreground) tuân thủ chặt chẽ cấu trúc CSS variables.
2. **Trạng thái AI (AI State Visibility):** Khi AI đang tạo nội dung (Text/Image/Video), hệ thống bắt buộc phải khóa các trường nhập liệu tương ứng bằng `Skeleton` và hiển thị trạng thái đang xử lý bằng `Progress` hoặc `Loader2` (lucide-react) trong nút bấm.
3. **Cơ chế phản hồi tức thời (Feedback Loops):** Sử dụng `Toast` cho các thông báo nhanh (Thành công/Thất bại), `Dialog` cho các xác nhận quan trọng (Xoá workspace, Duyệt/Từ chối bài viết), và `Alert` cho các lỗi nghiêm trọng.

---

## II. THIẾT KẾ CHI TIẾT 7 MÀN HÌNH WIREFRAME (DESKTOP 1440PX & MOBILE 375PX)

---

### MÀN HÌNH 1: LOGIN/AUTH (ĐĂNG NHẬP / ĐĂNG KÝ)

#### 1. Bố cục tổng quan (Desktop 1440px)
Sử dụng bố cục chia đôi (Split-screen layout) tỉ lệ **35% : 65%**.
- **Panel Trái (35% - 504px):** Nền tối (primary/brand), chứa branding logo, câu quote từ khách hàng lớn, và các chỉ số thống kê uy tín (Social reach, AI output counter).
- **Panel Phải (65% - 936px):** Nền sáng (hoặc dark mode background), căn giữa form đăng nhập/đăng ký.

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
|                                              DESKTOP (1440px)                                         |
+------------------------------------+------------------------------------------------------------------+
| PANEL TRÁI (Branding & Stats)      | PANEL PHẢI (Authentication Form)                                 |
|                                    |                                                                  |
| [Icon] make.ui                     |                                                                  |
|                                    |                                                                  |
| "Chúng tôi rút ngắn thời gian tạo  |                         [Tabs: Đăng nhập | Đăng ký]              |
| nội dung từ 3 ngày xuống còn 2 giờ.|                        +--------------------------------+        |
| make.ui đã thay đổi hoàn toàn      |                        | Email                          |        |
| quy trình làm việc của team."      |                        | [Input: hello@company.com    ] |        |
|                                    |                        |                                |        |
| - Minh Nguyễn                      |                        | Mật khẩu         Quên mật khẩu?|        |
|   Content Director, VCorp Media    |                        | [Input: ••••••••            [Eye]]        |
|                                    |                        |                                |        |
| +----------+----------+----------+ |                        | [Button: Đăng nhập          ->] |        |
| | 50K+     | 2M+      | 99.9%    | |                        +--------------------------------+        |
| | Users    | AI Posts | Uptime   | |                                                                  |
| +----------+----------+----------+ |                        ------------- hoặc --------------        |
|                                    |                                                                  |
|                                    |                     [Button: Google]   [Button: GitHub]          |
+------------------------------------+------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Form Container:** `Card` dùng làm khung bọc ngoài form trên thiết bị di động, trên desktop dùng trực tiếp thẻ `form` căn giữa.
- **Chuyển đổi Đăng nhập/Đăng ký:** `Tabs`, `TabsList`, `TabsTrigger`, `TabsContent` để chuyển đổi mượt mà giữa Form Đăng nhập và Đăng ký mà không cần tải lại trang.
- **Nhập liệu:** `Input` cho Email, Tên, Mật khẩu. Kết hợp `Label` để ghi nhãn trường.
- **Hiển thị mật khẩu:** Sử dụng `Input` tuỳ chỉnh tích hợp nút bấm có icon `Eye` / `EyeOff` từ `lucide-react` để ẩn hiện password.
- **Nút bấm:** `Button` (Variant: `default` cho nút chính; Variant: `outline` cho nút SSO Google/GitHub).
- **Đường chia:** `Separator` đi kèm text "hoặc tiếp tục với".

#### 4. Giao diện biến thể theo Role
- Màn hình này dùng chung cho tất cả các Role. Điểm khác biệt nằm ở **Logic Điều Hướng (Routing Logic)** sau khi API trả về Token chứa JWT Claims:
  - `ROLE_ADMIN` -> Điều hướng đến `/admin/dashboard`
  - `ROLE_OWNER`, `ROLE_MANAGER` & `ROLE_ACCOUNT` -> Điều hướng đến `/` (Main Dashboard)
  - `ROLE_CREATOR` -> Điều hướng đến `/editor` (hoặc Dashboard danh sách nhiệm vụ)
  - `ROLE_CLIENT` -> Điều hướng đến `/clients` (Client Portal)

---

### MÀN HÌNH 2: MAIN DASHBOARD (BẢNG ĐIỀU KHIỂN TRUNG TÂM)

#### 1. Bố cục tổng quan (Desktop 1440px)
- **Sidebar (Trái - 260px):** Menu điều hướng cố định, Workspace switcher ở trên cùng, thông tin User ở dưới cùng.
- **Header (Trên - 64px):** Breadcrumb chỉ đường, ô tìm kiếm nhanh, icon Chuông thông báo (Notification bell), Avatar dropdown.
- **Main Content Area (Còn lại):** Thiết kế dạng lưới responsive (CSS Grid) chứa các thẻ chỉ số (KPI Cards) ở trên, biểu đồ xu hướng ở giữa, và bảng tác vụ ở dưới.

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Workspace v] | [Breadcrumb: Home / Dashboard]                   [Search...]  [Bell] [User Avatar v]  |
+---------------+---------------------------------------------------------------------------------------+
|               |  CHÀO MỪNG TRỞ LẠI, LỘC!                                     [Button: + Tạo bài viết] |
|  - Dashboard  | +--------------------+ +--------------------+ +--------------------+ +----------------+ |
|  - Workspaces | | TỔNG WORKSPACE     | | WORKSPACE ACTIVE   | | AI CREDITS CÒN LẠI | | PENDING APPROV | |
|  - Editor     | | 12                 | | 8                  | | 4,250 / 5,000      | | 18 Bài viết    | |
|  - Calendar   | +--------------------+ +--------------------+ +--------------------+ +----------------+ |
|  - Clients    |                                                                                       |
|  - Analytics  | +--------------------------------------------------+ +-------------------------------+ |
|               | | NHIỆM VỤ CẦN DUYỆT (Approval Queue)  [Xem tất cả]| | HOẠT ĐỘNG GẦN ĐÂY             | |
|               | | +----------------------------------------------+ | | - Creator A nộp bài 'Kem chống'| |
|               | | | [Avatar] Bài viết: 'Kem chống nắng' - TikTok  | | | - Client B từ chối bài viết  | |
|               | | | Gửi bởi: Tuấn (Creator) | Chờ AM duyệt       | | | - Hệ thống đăng bài tự động | |
|               | | | [Button: Xem nhanh] [Button: Duyệt]          | | | - AM C đã kết nối Zalo OA   | |
|               | | +----------------------------------------------+ | | - Hệ thống bảo trì lúc 00:00  | |
| [Lộc AM v]    | +--------------------------------------------------+ +-------------------------------+ |
+---------------+---------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Sidebar Khung:** `Sidebar`, `SidebarHeader`, `SidebarContent`, `SidebarGroup`, `SidebarMenu`, `SidebarMenuItem`, `SidebarMenuButton` (shadcn sidebar component).
- **Workspace Switcher:** `DropdownMenu` với trigger là một `Button` hiển thị tên Workspace kèm icon chevrons-up-down.
- **Thông báo (Notification Bell):** `Popover` chứa danh sách thông báo cuộn trong `ScrollArea`. Mỗi thông báo là một hàng có `Avatar` và nút bấm nhanh.
- **Thẻ chỉ số (KPI):** `Card`, `CardHeader`, `CardTitle`, `CardDescription`, `CardContent`.
- **Hàng chờ duyệt:** `Table` (chứa danh sách bài viết) kết hợp `Badge` (màu sắc phân loại trạng thái: `success` cho Approved, `warning` cho Pending, `destructive` cho Rejected).
- **Hành động nhanh:** `Button` (Variant: `default`, `outline`, `ghost`).
- **Thanh tiến trình tín dụng AI:** `Progress` dùng trong Card AI Credits để hiển thị phần trăm dung lượng đã dùng.

#### 4. Giao diện biến thể theo Role
- **Agency Owner:** Dashboard tập trung vào tài chính và nhân sự. Các KPI hiển thị: "Doanh thu tháng", "AI Credits tiêu thụ của Agency", "Số Client đang hoạt động". Widget hiển thị danh sách các Workspace kèm hiệu suất.
- **Account Manager (AM) [Mặc định]:** Dashboard hiển thị hàng chờ duyệt bài viết (Approval Queue) từ các Creator. Widget hiển thị "Task trễ hạn" và "Lịch đăng bài hôm nay".
- **Content Creator:** Dashboard cá nhân hóa. KPI hiển thị: "Số bài viết đã tạo", "AI Credits đã tiêu dùng cá nhân", "Số bài viết bị Reject". Widget hiển thị "Briefs được giao" và "Lịch sử duyệt bài của tôi".
- **Brand Client:** Điều hướng trực tiếp sang Client Portal (không xem Dashboard chung này).

---

### MÀN HÌNH 3: WORKSPACE MANAGEMENT (QUẢN LÝ KHÔNG GIAN LÀM VIỆC)

#### 1. Bố cục tổng quan (Desktop 1440px)
- **Sidebar & Header:** Nhất quán với Dashboard để giữ liên kết UX.
- **Main Content Area:** Chia làm 2 khu vực:
  - **Bên trái (40%):** Danh sách các Workspace hiện có (dạng Grid Card). Có nút "Tạo Workspace mới".
  - **Bên phải (60%):** Panel cấu hình chi tiết cho Workspace đang được chọn, hiển thị dưới dạng các thẻ tab chức năng (Thành viên, Kênh kết nối, Tài liệu RAG).

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Workspace v] | [Breadcrumb: Home / Workspaces]                                      [User Avatar v]  |
+---------------+---------------------------------------------------------------------------------------+
|               | WORKSPACE MANAGEMENT                                                                  |
|  - Dashboard  | +------------------------------------+ +----------------------------------------------+ |
|  - Workspaces | | DANH SÁCH WORKSPACE   [+ Tạo mới]  | | WORKSPACE CHI TIẾT: "AGENCY FPT"             | |
|  - Editor     | | +--------------------------------+ | | [Tabs: Thành viên | Kênh liên kết | AI RAG]  | |
|  - Calendar   | | | Agency FPT (Active)            | | | +------------------------------------------+ | |
|  - Clients    | | | 12 Members | 5 Brands          | | | | DANH SÁCH THÀNH VIÊN       [+ Mời]       | |
|  - Analytics  | | +--------------------------------+ | | | - Minh AM (AM)       - [Xoá khỏi WS]     | |
|               | | +--------------------------------+ | | | - Tuấn Creator (Cr.) - [Xoá khỏi WS]     | |
|               | | | Brand Client A (Active)        | | | | - Hùng Client (Cl.)  - [Xoá khỏi WS]     | |
|               | | | 2 Members  | 1 Brand           | | | |                                          | |
|               | | +--------------------------------+ | | | Mời thành viên mới:                      | |
|               | | +--------------------------------+ | | | [Input: email@...] [Select: Role] [Button]| |
| [Lộc AM v]    | | | Brand Client B (Inactive)      | | | +------------------------------------------+ | |
|               | +------------------------------------+ +----------------------------------------------+ |
+---------------+---------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Thẻ Workspace:** `Card` đi kèm hover-effect chuyển màu viền khi di chuột qua.
- **Popup Tạo Workspace / Mời thành viên:** `Dialog`, `DialogTrigger`, `DialogContent`, `DialogHeader`, `DialogTitle`, `DialogDescription`, `DialogFooter`.
- **Cấu hình chi tiết:** `Tabs`, `TabsList`, `TabsTrigger`, `TabsContent` chia thành 3 Tab:
  1. *Thành viên (Members):* Chứa `Table` hiển thị Tên, Email, Vai trò (sử dụng `Badge` phân biệt) và nút Xoá (`Button` variant `destructive`).
  2. *Kênh liên kết (Integrations):* Chứa các card kết nối Facebook Page, TikTok, Instagram. Mỗi card có một `Switch` để kích hoạt/tắt kết nối.
  3. *Tài liệu AI RAG (Assets):* Khu vực kéo thả file (`Card` dạng upload file) và danh sách tài liệu RAG đã tải lên (sử dụng `Table` và `Progress` hiển thị dung lượng vector hóa).
- **Dropdown chọn Role:** `Select`, `SelectTrigger`, `SelectValue`, `SelectContent`, `SelectItem`.
- **Thông báo hệ thống:** `Toast` hiển thị thông báo "Đã gửi email mời thành viên thành công".

#### 4. Giao diện biến thể theo Role
- **Agency Owner:** Toàn quyền quản lý. Nhìn thấy nút "Tạo Workspace mới", nút "Xoá Workspace", nút cấu hình gói dịch vụ và giới hạn AI Credits cho từng Workspace.
- **Account Manager (AM):** Chỉ xem được danh sách Workspace được gán quyền. Không có nút "Xoá Workspace". Có quyền mời/xoá thành viên cấp Creator và Client, cấu hình kết nối Kênh Social Media.
- **Content Creator:** Chỉ được phép xem danh sách thành viên trong Workspace (Read-only Member list) và xem danh sách tài liệu RAG (để kiểm tra xem tài liệu thương hiệu nào đã được nạp cho AI). Không có quyền mời thành viên hay kết nối API Social.
- **Brand Client:** Bị chặn quyền truy cập màn hình này (Hiển thị trang 403 Forbidden hoặc redirect về Client Portal).

---

### MÀN HÌNH 4: CONTENT EDITOR (TRÌNH SOẠN THẢO NỘI DUNG TÍCH HỢP AI)

#### 1. Bố cục tổng quan (Desktop 1440px)
Sử dụng bố cục **3 cột co giãn linh hoạt** (Flexible Three-column Layout):
- **Cột Trái (AI Panel - 25%):** Nơi cấu hình AI sinh nội dung (Prompt, Brand Guideline context, Tone of voice, Length).
- **Cột Giữa (Editor - 45%):** Soạn thảo văn bản, tải lên hình ảnh/video, chèn icon, đề xuất hashtag.
- **Cột Phải (Post Preview - 30%):** Giả lập hiển thị bài viết thời gian thực trên các kênh Social Media.

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Workspace v] | [Breadcrumb: Home / Content Editor]                                  [User Avatar v]  |
+---------------+---------------------------------------------------------------------------------------+
|               | CỘT 1: AI GENERATION | CỘT 2: EDITOR AREA              | CỘT 3: MULTI-CHANNEL PREVIEW |
|  - Dashboard  | [Select: Brand Guidelines] | [Input: Tiêu đề bài viết         ] | [Tabs: FB | Insta | Zalo]    |
|  - Workspaces | [Select: Social Channel  ] |                                   | +--------------------------+ |
|  - Editor     | [Select: Tone of Voice   ] | [Textarea: Caption content...]    | | [Avatar] Brand A (FB)    | |
|  - Calendar   |                            |                                   | | 1 phút trước • [Icon]    | |
|  - Clients    | Nhập Brief/Prompt:         |                                   | |                          | |
|  - Analytics  | [Textarea: Viết bài PR...] | [Card: Media Upload (Click/Drop)] | | Nội dung caption hiển thị | |
|               |                            | +-------------------------------+ | | ở đây...                 | |
|               | Nhiệt độ AI (Creativity):  | | [Icon: Image] Tải ảnh/video   | | |                          | |
|               | [Slider: -----o----------] | +-------------------------------+ | | [Hình ảnh Preview]       | |
|               |                            |                                   | |                          | |
|               | [Button: TẠO NỘI DUNG AI]  | [Button: Gửi AM Duyệt]            | +--------------------------+ |
| [Lộc AM v]    |                            |                                   | [Button: Duyệt] [Reject]   |
+---------------+---------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Phân tách cột co giãn:** `ResizablePanelGroup`, `ResizablePanel`, `ResizableHandle` (Cho phép người dùng kéo giãn độ rộng của AI Panel hoặc Preview Panel).
- **Form AI Parameter:**
  - `Select` chọn Brand Guidelines (RAG Database).
  - `Select` chọn Social Channel (Định hình khung bài viết).
  - `Select` chọn Tone of voice (Vui vẻ, trang trọng, giật gân...).
  - `Slider` để tăng giảm độ sáng tạo của AI (Temperature).
  - `Accordion` để thu gọn các cài đặt nâng cao (Hashtag blacklist, Emoji density).
- **Vùng soạn thảo (Editor):** `Textarea` nhập nội dung caption trực tiếp. `Input` cho tiêu đề bài đăng. `Card` cho vùng kéo thả hình ảnh/video tải lên.
- **Preview Tabs:** `Tabs`, `TabsList`, `TabsTrigger` để Client/AM click chọn đổi nền tảng preview (Facebook / Instagram / TikTok / Zalo OA).
- **Hộp thoại Từ chối bài viết:** `Dialog` hiện lên khi bấm nút "Reject", bắt buộc nhập Lý do từ chối (Feedback) để gửi lại cho Creator.
- **Tiến trình AI tạo bài:** `Skeleton` phủ lên vùng Editor khi bấm nút "Tạo nội dung AI" để tránh người dùng thao tác đè lên nhau.

#### 4. Giao diện biến thể theo Role
- **Content Creator:**
  - Nhìn thấy đầy đủ tính năng ở Cột 1 (AI Generation Panel) và Cột 2 (Editor).
  - Nút hành động chính ở Cột 2: **"Gửi AM duyệt"** (Submit to AM). Trạng thái bài viết chuyển từ `Draft` sang `Pending_AM_Review`.
- **Account Manager (AM):**
  - Nhìn thấy bài viết của Creator gửi lên ở chế độ View-only hoặc Edit (có thể sửa trực tiếp lỗi chính tả).
  - Cột 3 (Preview) xuất hiện thanh công cụ duyệt bài: **Nút "Approve"** (Duyệt bài - hệ thống tự động chuyển bài lên Client Portal chờ Client duyệt hoặc đặt lịch nếu không cần Client duyệt) và **Nút "Reject"** (Từ chối - trả về Creator kèm lý do).
- **Brand Client:** Không truy cập được màn hình Editor này. Chỉ xem và duyệt qua Client Portal.

---

### MÀN HÌNH 5: CONTENT CALENDAR (LỊCH ĐĂNG BÀI - HỖ TRỢ MOBILE 375PX)

#### 1. Bố cục tổng quan (Desktop 1440px)
- **Sidebar & Header:** Giữ nguyên.
- **Main Content Area:**
  - **Header Bộ lọc:** Bộ lọc Brand, Social Channel, Trạng thái (Published, Scheduled, Draft). Nút chuyển đổi view: Tháng / Tuần / Ngày. Nút "Tạo bài viết mới".
  - **Calendar Grid:** Lưới 7 cột đại diện cho các ngày trong tuần. Mỗi ô ngày hiển thị danh sách các bài viết đã lên lịch.
  - **Sidebar Phụ (Right Drawer - 350px):** Mở ra từ bên phải khi click vào một bài viết trên lịch để hiển thị chi tiết bài đăng, thời gian, kênh đăng, lịch sử duyệt, và khu vực bình luận nội bộ.

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Workspace v] | [Breadcrumb: Home / Calendar]                                        [User Avatar v]  |
+---------------+---------------------------------------------------------------------------------------+
|               | BỘ LỌC: [Select: Brand]  [Select: Channel]  [Select: Status]     [<] THÁNG 06/2026 [>]    |
|  - Dashboard  | +-----------------------------------------------------------------------------------+ |
|  - Workspaces | | THỨ 2      | THỨ 3      | THỨ 4      | THỨ 5      | THỨ 6      | THỨ 7      | CHỦ NHẬT   | |
|  - Editor     | +------------+------------+------------+------------+------------+------------+-----------+ |
|  - Calendar   | | 01         | 02         | 03         | 04         | 05         | 06         | 07        | |
|  - Clients    | |            | [FB] PostA |            | [Insta]Post|            | [TikTok]   |           | |
|  - Analytics  | |            | (Scheduled)|            | (Draft)    |            | PostC (Pub)|           | |
|               | +------------+------------+------------+------------+------------+------------+-----------+ |
|               | | 08         | 09         | 10         | 11         | 12         | 13         | 14        | |
|               | |            |            |            |            |            |            |           | |
|               | +------------+------------+------------+------------+------------+------------+-----------+ |
| [Lộc AM v]    | +-----------------------------------------------------------------------------------+ |
+---------------+---------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Khung lịch:** Sử dụng component `Calendar` kết hợp logic của FullCalendar hoặc React Big Calendar, CSS styling đồng bộ với shadcn.
- **Thẻ bài viết trên lịch:** `Button` (Kích thước nhỏ, bo góc nhẹ) chứa icon channel (Lucide icons) và tiêu đề bài đăng rút gọn.
- **Trạng thái bài đăng:** Phân biệt bằng `Badge` hoặc màu nền của Card bài viết trên Calendar:
  - Màu xanh lá (success): Đã đăng (`Published`).
  - Màu xanh dương (info): Đã lên lịch đăng (`Scheduled`).
  - Màu vàng (warning): Đang chờ duyệt (`Pending Approval`).
  - Màu xám (secondary): Bản nháp (`Draft`).
- **Drawer Chi tiết bài viết:** `Sheet`, `SheetContent`, `SheetHeader`, `SheetTitle`, `SheetDescription` (Trượt từ bên phải sang khi bấm vào bài viết trên lịch).
- **Hover Preview:** `HoverCard`, `HoverCardTrigger`, `HoverCardContent` hiển thị preview nhanh của bài viết khi rê chuột qua card lịch mà không cần click.

#### 4. Giao diện biến thể theo Role
- **Agency Owner / Account Manager (AM):** Toàn quyền quản trị lịch đăng bài. Hỗ trợ thao tác kéo thả (Drag-and-Drop) card bài viết từ ngày này sang ngày khác để tự động thay đổi lịch đăng (gửi API cập nhật queue). Nhấp đúp vào ô ngày bất kỳ để mở form tạo nhanh bài viết mới.
- **Content Creator:** Xem lịch đăng tổng thể để biết định hướng. Chỉ được phép kéo thả, chỉnh sửa hoặc xoá các bài viết của chính mình đang ở trạng thái `Draft` hoặc `Rejected`. Không thể chỉnh sửa bài viết đã `Approved` hoặc `Scheduled`.
- **Brand Client:** Giao diện Read-only Calendar (Lịch chỉ xem). Client chỉ thấy các bài viết đã được `Approved` (Scheduled) hoặc `Published`. Không thấy bài viết dạng `Draft` nội bộ của Agency. Client có thể click vào bài đăng để xem preview và để lại bình luận.

#### 5. Thiết kế Mobile (375px) — BẮT BUỘC
Trên màn hình di động, hiển thị lưới tháng 30 ngày là bất khả thi. UI được chuyển đổi sang **Chế độ tuần trượt ngang kết hợp danh sách Timeline ngày dọc**:

```
+------------------------------------+
| [=] BrandHub              [Bell]   |
+------------------------------------+
| TÌM KIẾM BÀI VIẾT                  |
| [Input: Nhập từ khoá...]           |
+------------------------------------+
| TUẦN NÀY (Tháng 6, 2026)           |
|  T2   T3   T4   T5   T6   T7   CN  |
|  01   02  [03]  04   05   06   07  | (03 được chọn)
+------------------------------------+
| TIMELINE NGÀY 03/06/2026           |
|                                    |
| 09:30 AM                           |
| +--------------------------------+ |
| | [FB] Ra mắt BST Mùa Hè         | |
| | Trạng thái: [Scheduled]        | |
| | [Thumbnail ảnh bài đăng]       | |
| +--------------------------------+ |
|                                    |
| 15:00 PM                           |
| +--------------------------------+ |
| | [TikTok] Video Review sản phẩm | |
| | Trạng thái: [Draft]            | |
| +--------------------------------+ |
|                                    |
|                       [Floating +] |
+------------------------------------+
```
- **Thanh trượt tuần (Weekly Slider):** Dùng `ScrollArea` cho phép vuốt ngang chọn ngày trong tuần. Ngày được chọn sẽ có nền đậm (Primary color) và chữ trắng.
- **Danh sách Timeline:** Danh sách dọc hiển thị các bài viết của ngày được chọn. Mỗi bài viết là một `Card` gọn gàng gồm: Giờ đăng, Logo nền tảng, Tiêu đề, Thumbnail và `Badge` trạng thái.
- **Tạo nhanh:** Nút Floating Action Button (FAB) hình tròn có dấu `+` ở góc dưới bên phải màn hình để tạo nhanh bài viết.

---

### MÀN HÌNH 6: CLIENT PORTAL (CỔNG THÔNG TIN KHÁCH HÀNG)

#### 1. Bố cục tổng quan (Desktop 1440px)
- **Branding đặc thù:** Logo của Agency được thu nhỏ, nhường chỗ cho **Logo thương hiệu của khách hàng (Brand Client)** ở góc trên trái để cá nhân hoá trải nghiệm (White-label portal).
- **Sidebar (Trái - 240px):** Chỉ có các Tab cần thiết: Hàng chờ duyệt (Approval Queue), Gửi yêu cầu (Content Request), Lịch đăng bài (Calendar - Read only), Thư viện tài nguyên (Media Assets).
- **Main Content Area:** Tập trung toàn bộ sự chú ý vào **Hàng chờ duyệt (Approval Queue)**. Thiết kế dạng Grid hiển thị các Card bài viết đang chờ phê duyệt.

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Client Logo] | [Breadcrumb: Portal / Pending Approval]                              [User Avatar v]  |
+---------------+---------------------------------------------------------------------------------------+
|               | HÀNG CHỜ PHÊ DUYỆT (3 bài đăng cần duyệt)                       [Button: + Gửi yêu cầu]|
|  - Duyệt bài  | +-----------------------------------------------------------------------------------+ |
|  - Gửi Brief  | | BÀI VIẾT CHỜ DUYỆT #01                                                            | |
|  - Calendar   | | Tiêu đề: Khuyến mãi cuối tháng | Kênh: Zalo OA | Lên lịch: 20:00 - 18/06/2026     | |
|  - Thư viện   | | +------------------------------------+------------------------------------------+ | |
|               | | | BẢN XEM TRƯỚC (PREVIEW)            | LỊCH SỬ THẢO LUẬN & PHẢN HỒI             | | |
|               | | | [Avatar] Brand A                   | [10:00] Creator Tuấn: Đã sửa ảnh theo brief| | |
|               | | | 2 giờ trước                        | [11:15] AM Lộc: Đã check nội dung ok.    | | |
|               | | |                                    |                                          | | |
|               | | | Nội dung caption ở đây...          | Nhập phản hồi của bạn:                   | | |
|               | | | [Hình ảnh sản phẩm]                | [Textarea: Sửa lại font chữ...]          | | |
|               | | +------------------------------------+------------------------------------------+ | |
|               | | | [Button: PHÊ DUYỆT (Approve)]      | [Button: TỪ CHỐI (Reject & Feedback)]    | | |
|               | | +------------------------------------+------------------------------------------+ | |
|               | +-----------------------------------------------------------------------------------+ |
+---------------+---------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Khung duyệt bài:** `Card`, `CardHeader`, `CardTitle`, `CardDescription`, `CardContent`, `CardFooter`.
- **Khu vực Preview & Feedback:** Sử dụng layout chia đôi bên trong Card hoặc `ResizablePanelGroup` để phân chia bên trái xem Preview bài viết (giống hiển thị trên điện thoại thật), bên phải là khung Chat thảo luận giữa Client - AM - Creator.
- **Khung Chat:** `ScrollArea` chứa danh sách tin nhắn chat, kết hợp `Avatar` người dùng. Phía dưới có `Textarea` để Client nhập feedback.
- **Nút bấm hành động:** 
  - Nút **Approve:** `Button` (Variant `default`, màu xanh lá cây hoặc màu chính của brand). Bấm vào sẽ kích hoạt `Toast` thông báo thành công và chuyển trạng thái bài viết sang `Scheduled`.
  - Nút **Reject:** `Button` (Variant `destructive` hoặc `outline`).
- **Popup Gửi Yêu Cầu Mới:** `Dialog` chứa form cho phép Client nhập mô tả brief mới (Tiêu đề request, mục tiêu, tệp đính kèm, hạn hoàn thành). Sử dụng `Input`, `Label`, `Textarea` và `Calendar` cho Date Picker.

#### 4. Giao diện biến thể theo Role
- **Brand Client [Mặc định]:** Đây là không gian làm việc chính của họ. Họ chỉ nhìn thấy dữ liệu của thương hiệu mình làm chủ. Có quyền bấm Duyệt/Từ chối bài viết, viết bình luận và tạo Request mới.
- **Account Manager (AM):** Có quyền truy cập vào Portal này dưới dạng chế độ giả lập (Impersonate mode) để xem khách hàng đang nhìn thấy gì nhằm hỗ trợ kỹ thuật hoặc xem trực tiếp các phản hồi chưa đọc.
- **Content Creator:** Không truy cập được giao diện này. Nhận thông tin phản hồi (bình luận, yêu cầu sửa đổi) gián tiếp thông qua hệ thống ticket/task được đồng bộ tự động về trang Dashboard và Editor của Creator.

---

### MÀN HÌNH 7: ANALYTICS DASHBOARD (BÁO CÁO HIỆU QUẢ ĐA KÊNH)

#### 1. Bố cục tổng quan (Desktop 1440px)
- **Sidebar & Header:** Nhất quán.
- **Main Content Area:**
  - **Header điều khiển:** `Popover` chứa Date Range Picker (Chọn khoảng thời gian báo cáo), `Select` chọn Brand, `Select` chọn Social Channel (All, Facebook, Instagram, TikTok...). Nút Export báo cáo.
  - **Dòng 1 - KPI Grid:** 4 Card chỉ số quan trọng (Reach, Engagement, Followers, Conversions). Mỗi card có phần trăm tăng trưởng (+/- %) so với chu kỳ trước (sử dụng Badge).
  - **Dòng 2 - Charts:** Lưới 2 cột chứa biểu đồ đường (Line Chart - Biến động hiệu suất) và biểu đồ tròn/cột (Pie/Bar Chart - Phân phối theo kênh).
  - **Dòng 3 - Tables:** Bảng danh sách "Bài đăng hiệu quả nhất" (Top Performing Posts) và phân tích sắc thái bình luận (Sentiment Analysis).

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Workspace v] | [Breadcrumb: Home / Analytics]                                       [User Avatar v]  |
+---------------+---------------------------------------------------------------------------------------+
|               | BỘ LỌC: [Popover: 01/06/2026 - 17/06/2026] [Select: Brand]         [Button: Xuất PDF v] |
|  - Dashboard  | +-----------------------------------------------------------------------------------+ |
|  - Workspaces | | REACH (LƯỢT TIẾP CẬN) | ENGAGEMENT (TƯƠNG TÁC)| FOLLOWERS (THEO DÕI)  | CTR (TỶ LỆ CLICK) | |
|  - Editor     | | 1,240,500             | 85,400                | 12,450                | 3.2%              | |
|  - Calendar   | | [+12.5% vs tháng trước] | [-1.2% vs tháng trước]| [+8.4% vs tháng trước]| [+0.5% vs tháng tr]| |
|  - Clients    | +-----------------------------------------------------------------------------------+ |
|  - Analytics  | | BIỂU ĐỒ SO SÁNH HIỆU QUẢ CÁC KÊNH (Reach vs Engagement)                           | |
|               | |                                                                                   | |
|               | | [Đồ thị Line Chart mô phỏng xu hướng chạy dọc qua các ngày trong tháng]           | |
|               | |                                                                                   | |
|               | +-----------------------------------------------------------------------------------+ |
|               | | TOP PERFORMING POSTS (Bài viết hiệu quả nhất)                                      | |
|               | | +-------------------------------------------------------------------------------+ | |
|               | | | Tiêu đề bài viết          | Kênh | Lượt tiếp cận | Tương tác | Điểm đánh giá  | | |
|               | | |---------------------------|------|---------------|-----------|----------------| | |
|               | | | BST Mùa Hè Ra Mắt         | FB   | 450,200       | 28,000    | [Badge: Top 1] | | |
| [Lộc AM v]    | +-----------------------------------------------------------------------------------+ |
+---------------+---------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Date Range Picker:** `Popover` kết hợp `Calendar` (chế độ select range) và `Button` hiển thị khoảng thời gian đã chọn.
- **Bộ lọc nhanh:** `Select` để chọn các Brand và Nền tảng cần xuất dữ liệu.
- **Thẻ KPI:** `Card`, `CardHeader`, `CardTitle`, `CardDescription`, `CardContent`. Phần trăm tăng trưởng hiển thị bằng `Badge` với màu xanh (`success`) cho tăng trưởng dương và màu đỏ (`destructive`) cho tăng trưởng âm.
- **Xuất báo cáo:** `DropdownMenu` với các lựa chọn: "Xuất file PDF", "Xuất file Excel (XLSX)", "Xuất CSV".
- **Bảng dữ liệu (Top Posts):** `Table`, `TableHeader`, `TableBody`, `TableRow`, `TableCell`.
- **Đồ thị:** Tích hợp thư viện đồ thị `Recharts` hoặc `Chart.js` được bọc bên trong thẻ `Card` của shadcn để đồng bộ phong cách tối giản.

#### 4. Giao diện biến thể theo Role
- **Agency Owner:** Xem được báo cáo tài chính cấp cao: "Chi phí AI Credits đã mua", "Tỉ lệ hoàn vốn đầu tư (ROI) ước tính", "Hiệu suất làm việc của từng Workspace khách hàng".
- **Account Manager (AM):** Xem chi tiết hiệu quả của các Client mình quản lý. Có đầy đủ quyền cấu hình bộ lọc và xuất file báo cáo để gửi trực tiếp cho khách hàng.
- **Content Creator:** Chỉ xem được chỉ số tương tác của các bài viết do mình tạo ra (Engagement, Reach, Likes, Comments, Shares) để cải tiến nội dung. Bị ẩn các thông tin về doanh thu, chi phí hoặc hiệu suất của Creator khác.
- **Brand Client:** Xem báo cáo tương tự AM nhưng giao diện được tối giản hoá, ẩn các chỉ số nội bộ của Agency (như thông tin về Creator nào sản xuất bài đăng hoặc thời gian duyệt bài nội bộ).

---

## III. THIẾT KẾ MOBILE CHUYÊN BIỆT (375PX) CHO 3 MÀN HÌNH CORE

*BrandHub yêu cầu cung cấp thiết kế khung di động 375px cho 3 màn hình cốt lõi xuất hiện trên Mobile App:* **Content Calendar** (đã trình bày ở Mục II - Màn hình 5), **Notifications** (Thông báo) và **Post Preview** (Xem trước bài viết). Dưới đây là blueprint chi tiết cho 2 màn hình di động còn lại:

### 1. MÀN HÌNH MOBILE: NOTIFICATIONS (THÔNG BÁO - 375PX)

#### A. Bố cục tổng quan
Màn hình toàn phần (Full-screen view) hiển thị danh sách các thông báo công việc thời gian thực. Bố cục từ trên xuống dưới bao gồm:
- **Header:** Nút Back (Quay lại), Tiêu đề "Thông báo", Nút "Đánh dấu đã đọc tất cả" (Mark all as read).
- **Phân loại (Filter Tabs):** Thanh ngang lọc thông báo: Tất cả / Chờ duyệt / Phản hồi mới.
- **Danh sách thông báo:** Danh sách cuộn dọc. Mỗi thông báo là một Card ngang mỏng chứa Avatar người thực hiện hành động, nội dung tóm tắt, thời gian và nút hành động nhanh.

#### B. Sơ đồ Wireframe Mobile (375px)
```
+------------------------------------+
| [<] THÔNG BÁO         [Đã đọc hết] |
+------------------------------------+
| [Tabs: Tất cả (12) | Chờ duyệt (5)]|
+------------------------------------+
| CHƯA ĐỌC                           |
| +--------------------------------+ |
| | [Avatar] Tuấn (Creator)        | |
| | Vừa nộp bài: "Mở bán dự án mới"| |
| | 2 phút trước  •  [Badge: Duyệt]| |
| |                                | |
| | [Button: Xem]   [Button: Duyệt]| |
| +--------------------------------+ |
| +--------------------------------+ |
| | [Avatar] Hùng Client           | |
| | Đã từ chối bài viết: "Review   | |
| | Kem chống nắng" - Yêu cầu sửa. | |
| | 1 giờ trước • [Badge: Feedback]| |
| |                                | |
| | [Button: Xem chi tiết phản hồi]| |
| +--------------------------------+ |
|                                    |
| ĐÃ ĐỌC                             |
| +--------------------------------+ |
| | [Avatar] Hệ thống AI           | |
| | Tự động đăng bài FB thành công | |
| | 5 giờ trước  •  [Badge: System]| |
| +--------------------------------+ |
+------------------------------------+
```

#### C. Bản đồ Component shadcn/ui Mobile
- **Khung thông báo:** `ScrollArea` bao bọc toàn bộ danh sách để cuộn mượt mà.
- **Tab lọc:** `Tabs`, `TabsList`, `TabsTrigger` dạng kích thước nhỏ (`sm`) để tiết kiệm không gian màn hình di động.
- **Thẻ thông báo đơn lẻ:** `Card` với padding nhỏ (`p-3`). Bên trong chứa `Avatar` (sử dụng `AvatarImage` và `AvatarFallback`).
- **Nhãn phân loại:** `Badge` (Đỏ cho Feedback bị Reject, Vàng cho Chờ duyệt, Xanh lá cho Đăng bài thành công, Xám cho hệ thống).
- **Hành động nhanh:** `Button` kích thước nhỏ (`size="sm"`, variant `outline` hoặc `default`) để người dùng có thể duyệt nhanh hoặc xem bài đăng trực tiếp ngay trên Notification Card.

---

### 2. MÀN HÌNH MOBILE: POST PREVIEW (XEM TRƯỚC BÀI VIẾT - 375PX)

#### A. Bố cục tổng quan
Màn hình giả lập giao diện bài đăng thực tế trên ứng dụng mạng xã hội di động, tích hợp bộ công cụ kiểm duyệt nhanh ở dưới cùng (Sticky Bottom Bar). Bố cục gồm:
- **Header:** Nút Back, Tiêu đề "Xem trước bài đăng", Icon chọn kênh (Facebook / Instagram / TikTok).
- **Khu vực giả lập (Feed Simulator):** Hiển thị giả lập 1:1 giao diện bài đăng của nền tảng được chọn.
- **Thanh bình luận/phản hồi:** Hiển thị ý kiến thảo luận của team.
- **Sticky Bottom Action Bar:** Nút Phê duyệt và Từ chối luôn cố định ở dưới cùng màn hình để thuận tiện thao tác bằng một tay.

#### B. Sơ đồ Wireframe Mobile (375px)
```
+------------------------------------+
| [<] XEM TRƯỚC BÀI ĐĂNG     [FB v]  |
+------------------------------------+
| GIẢ LẬP GIAO DIỆN DI ĐỘNG (FB FEED)|
| +--------------------------------+ |
| | [Avatar Brand] Brand Client A  | |
| | Tài trợ  •  Vừa xong           | |
| |                                | |
| | Kem chống nắng thế hệ mới bảo  | |
| | vệ làn da của bạn tối ưu...    | |
| | [Xem thêm]                     | |
| |                                | |
| | +----------------------------+ | |
| | |                            | | |
| | |   [Ảnh sản phẩm tỉ lệ 1:1]  | | |
| | |                            | | |
| | +----------------------------+ | |
| | [Icon Like] [Icon Comment]     | |
| +--------------------------------+ |
|                                    |
| THẢO LUẬN / FEEDBACK               |
| [Avatar AM]: Bài này hình ảnh đẹp, |
| caption cần thêm vài icon.         |
|                                    |
+------------------------------------+
| [Button: Từ chối] [Button: Phê duyệt] | (Sticky Bottom)
+------------------------------------+
```

#### C. Bản đồ Component shadcn/ui Mobile
- **Mô phỏng Feed:** Sử dụng `Card` làm container cho khung giả lập.
- **Chọn nền tảng giả lập:** `Select` hoặc `Tabs` ở góc trên để đổi nhanh giữa các giao diện nền tảng khác nhau.
- **Khu vực bình luận:** `Accordion` hoặc `ScrollArea` hiển thị các feedback để người duyệt có thêm thông tin bối cảnh.
- **Thanh duyệt bài cố định (Sticky Bottom):** Thẻ `div` có class Tailwind `sticky bottom-0 left-0 right-0 bg-background border-t p-3 flex gap-2 z-50`.
  - Nút **Từ chối (Reject):** `Button` (variant `outline` hoặc `destructive`, flex-1). Click vào sẽ mở `Dialog` bắt buộc nhập lý do từ chối.
  - Nút **Phê duyệt (Approve):** `Button` (variant `default` với màu xanh lá, flex-1).

---

## IV. HƯỚNG DẪN MAPPING FIGMA & CƠ CẤU COMPONENT REACT

Khi kéo thả trên Figma hoặc xây dựng Component trong React, Lộc hãy tuân thủ cách đặt tên và tổ chức thư mục như sau để đảm bảo code sạch và đồng bộ với thiết kế:

### 1. Cấu trúc thư mục Component khuyến nghị (React + Vite)
```bash
src/
└── app/
    ├── components/
    │   ├── ui/                 # Thư mục chứa các component shadcn/ui gốc
    │   │   ├── button.tsx
    │   │   ├── card.tsx
    │   │   ├── dialog.tsx
    │   │   └── ...
    │   └── custom/             # Các component ghép từ shadcn/ui phục vụ BrandHub
    │       ├── sidebar-nav.tsx # Sidebar chung cho Dashboard/Editor/Calendar
    │       ├── post-simulator.tsx # Bộ preview bài viết đa kênh (FB/Insta/Zalo)
    │       ├── ai-generation-panel.tsx # Panel nhập prompt và chọn RAG
    │       └── notification-popover.tsx # Khay thông báo trên Header
    └── pages/                  # 7 trang chính được render theo route
        ├── LoginPage.tsx
        ├── DashboardPage.tsx
        ├── WorkspacePage.tsx
        ├── EditorPage.tsx
        ├── CalendarPage.tsx
        ├── ClientPortalPage.tsx
        └── AnalyticsPage.tsx
```

### 2. Từ Wireframe đến Code: Check-list khi dựng giao diện
- **Bước 1 (Figma Setup):** Sử dụng thư viện Figma UI Kit của **shadcn/ui** (bản chính thức hoặc cộng đồng) để lấy đúng kích thước chuẩn của các component: `Button`, `Input`, `Select`, `Dialog`...
- **Bước 2 (Đặt tên Layer trên Figma):** Khi vẽ các wireframe, Lộc hãy đổi tên Group/Layer theo tên component shadcn tương ứng (Ví dụ: thay vì đặt tên "o_nhap_lieu", hãy đặt tên `[Input] Email Input`, thay vì "khung_thong_tin", hãy đặt tên `[Card] KPI Reach`). Điều này giúp lập trình viên (hoặc chính Lộc) khi nhìn vào Figma có thể hình dung ngay các tag code cần dùng.
- **Bước 3 (Implementation - Code):** Khi viết code React, bọc các component thô bằng các CSS class Tailwind của shadcn/ui để điều khiển Layout. Dùng các props chuẩn của shadcn/ui như `variant="outline"`, `size="sm"` để tránh viết CSS tuỳ biến (inline styles/custom classes) không cần thiết, giúp duy trì code chất lượng cao.

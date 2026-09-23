# BRANDHUB WIREFRAME BLUEPRINT & SOLUTIONS ARCHITECTURE (V2)

**Dự án:** BrandHub (AI-Powered Multi-Channel Media Campaign Platform)
**Vai trò:** UX/UI Specialist & Solutions Architect (shadcn/ui Specialist)
**Version:** 2.0 (V2 — nghiệp vụ mới, 2026-09-15)
**Nguồn nghiệp vụ:** `docs/ba/00-overview.md` — cấu trúc Agency → Workspace → Media Package → Media Campaign → Task
**Target Breakpoints:** Desktop (1440px) & Mobile (375px)

---

## I. TỔNG QUAN HỆ THỐNG PHÂN QUYỀN (RBAC) & THIẾT KẾ UX/UI

### 1. Thay đổi cấu trúc lớn nhất so với bản V1

- **Thêm tầng Agency**: trước đây User vào thẳng Workspace, giờ User sở hữu Agency, Agency chứa nhiều Workspace. Cần 2 màn hình mới: **Agency List/Dashboard** và **Agency Member Management** (tách biệt Workspace Management).
- **Role gán theo từng Workspace**, không cố định toàn cục — UI phải hiển thị rõ "vai trò của bạn trong Workspace này" ở Header, vì cùng 1 User có thể là OWNER ở Workspace A và CREATOR ở Workspace B.
- **Bỏ "Content Editor" đơn lẻ, thay bằng chuỗi**: Media Package (chọn mẫu) → Media Campaign (đàm phán + duyệt) → Task Backlog (tự sinh) → Task Detail (thực hiện + Approval Sequence 4 bước) → Publish. UI cần màn hình riêng cho từng bước, không gộp vào 1 trang Editor như V1.
- **Task có 3 loại** (Post / Livestream / Survey-Form) dùng chung khung Approval Sequence — Task Board phải phân biệt loại bằng icon/tag, nhưng luồng duyệt (Kanban column) giống nhau.
- **Zalo OA bị loại khỏi scope** — mọi chỗ V1 có "Zalo" trong preview/kênh đăng phải bỏ, chỉ còn Facebook / Instagram / TikTok / Threads.
- **Third-party Collaborator** (báo, banner, TV) — module mới, không thuộc social publish, cần màn hình riêng dạng CRM danh bạ.

### 2. Bảng Ma Trận Phân Quyền (Role Access Matrix) — V2

6 role: `ADMIN` (system), `OWNER`/`MANAGER`/`CREATOR`/`CLIENT` (theo từng Workspace), `GUEST` (chưa đăng nhập, chỉ thấy Landing + Login).

| Màn hình | ADMIN | OWNER | MANAGER | CREATOR | CLIENT |
|---|---|---|---|---|---|
| **1. Login/Auth** | Đăng nhập hệ thống | Đăng nhập hệ thống | Đăng nhập hệ thống | Đăng nhập hệ thống | Đăng nhập (join qua invite) |
| **2. Agency Dashboard** | Toàn hệ thống (System KPI) | Danh sách Agency mình sở hữu | N/A (không thuộc Agency, chỉ Workspace) | N/A | N/A |
| **3. Workspace Dashboard** | Toàn quyền (mọi Workspace) | Toàn quyền Workspace mình tạo | Vận hành Workspace được giao | Xem Task của mình | Xem tiến độ Campaign mình liên quan |
| **4. Package/Campaign Negotiation** | View-only (Audit) | Đàm phán, Approve | Đàm phán, Approve (thay Owner) | Không truy cập | Đàm phán, Approve |
| **5. Task Board (Kanban)** | View-only | Full control | Assign, QC review, Manager review | Thực hiện Task được giao | Client review (nếu required) |
| **6. Task Detail (Content Editor)** | View-only | View/Edit | Review + AI tools thay Creator nếu cần | Tạo/Sửa nội dung, gọi AI | Xem preview, Approve/Reject (nếu required) |
| **7. Content Calendar** | View-only | Full control | Full control | Chỉ kéo/sửa Task của mình | Read-only |
| **8. Client Portal** | Không truy cập | Không có (Owner dùng Workspace Dashboard) | Không có | Không có | Không gian chính của Client |
| **9. Third-party Collaborator** | View-only | Full control | Quản lý danh bạ + gắn Campaign | Xem (đọc gợi ý AI) | Không truy cập |
| **10. Analytics Dashboard** | Toàn hệ thống + doanh thu | Toàn bộ Workspace KPI | KPI Campaign phụ trách | KPI Task cá nhân | KPI Campaign của mình |
| **11. Admin Console** | Toàn quyền | Không truy cập | Không truy cập | Không truy cập | Không truy cập |

### 3. Nguyên tắc thiết kế UX/UI

1. **Consistency**: toàn bộ dùng Design Token `shadcn/ui` — spacing, radius, màu nền theo CSS variables.
2. **AI State Visibility**: khi AI sinh nội dung (text/ảnh/video), khoá field liên quan bằng `Skeleton`, hiển thị `Progress`/`Loader2`.
3. **Feedback Loops**: `Toast` cho thông báo nhanh, `Dialog` cho xác nhận quan trọng (xoá Workspace, reject Task), `Alert` cho lỗi nghiêm trọng.
4. **Workspace context luôn hiển thị**: Header mọi trang trong Workspace phải show tên Workspace + role hiện tại của User trong Workspace đó (không phải role toàn cục).
5. **Approval state luôn có stepper**: mọi màn hình liên quan Task/Package/Campaign phải hiển thị progress-stepper theo state machine (xem `docs/ba/12-state-machines.md`), không chỉ 1 badge trạng thái đơn.

---

## II. THIẾT KẾ CHI TIẾT CÁC MÀN HÌNH WIREFRAME (DESKTOP 1440PX & MOBILE 375PX)

---

### MÀN HÌNH 1: LOGIN/AUTH (ĐĂNG NHẬP / ĐĂNG KÝ)

#### 1. Bố cục tổng quan (Desktop 1440px)
Giữ nguyên bố cục split-screen 35%:65% — màn hình auth không đổi theo model V2, chỉ đổi logic điều hướng sau login.

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
|                                              DESKTOP (1440px)                                         |
+------------------------------------+------------------------------------------------------------------+
| PANEL TRÁI (Branding & Stats)      | PANEL PHẢI (Authentication Form)                                 |
|                                    |                        [Tabs: Đăng nhập | Đăng ký]              |
| [Icon] BrandHub                    |                        +--------------------------------+        |
| "Không chỉ social media — chúng    |                        | Email                          |        |
|  tôi vận hành cả chiến dịch        |                        | [Input: hello@agency.com     ] |        |
|  truyền thông đa kênh của bạn."    |                        |                                |        |
|                                    |                        | Mật khẩu         Quên mật khẩu?|        |
| +----------+----------+----------+ |                        | [Input: ••••••••            [Eye]]        |
| | 50K+     | 2M+      | 99.9%    | |                        +--------------------------------+        |
| | Agency   | AI Posts | Uptime   | |                        | [Button: Đăng nhập          ->] |        |
| +----------+----------+----------+ |                        +--------------------------------+        |
+------------------------------------+------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
Không đổi so với V1: `Tabs`, `Input`, `Label`, `Button` (`default`/`outline`), `Separator`.

#### 4. Giao diện biến thể theo Role — Logic điều hướng SAU LOGIN (thay đổi trọng yếu V2)
- `ADMIN` → `/admin/dashboard`.
- Mọi User khác (không còn `ROLE_OWNER/MANAGER/ACCOUNT` cố định) → **`/agencies`** (Agency List) — vì role giờ gán theo từng Workspace, hệ thống không biết trước User sẽ vào Workspace nào với vai trò gì cho tới khi họ chọn 1 Agency → 1 Workspace.
- User được Client-invite lần đầu (chưa có Agency nào) → thẳng `/workspaces/{id}/portal` (Client Portal) của Workspace mời họ, bỏ qua Agency List.

---

### MÀN HÌNH 2: AGENCY LIST & AGENCY DASHBOARD (MỚI — TẦNG TỔ CHỨC MỚI)

#### 1. Bố cục tổng quan (Desktop 1440px)
Màn hình gốc sau login (thay cho Main Dashboard cũ). Không có sidebar Workspace — đây là tầng trên Workspace.
- **Header:** Logo, avatar dropdown, nút "Tạo Agency mới".
- **Main Content:** Grid card liệt kê các Agency User sở hữu (mỗi Agency = 1 Owner cố định, xem `docs/ba/01-organization-structure.md`).
- Click vào 1 Agency → vào **Agency Dashboard** (danh sách Workspace bên trong).

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Logo] BrandHub                                            [Bell]  [Avatar v]  [+ Tạo Agency mới]     |
+-------------------------------------------------------------------------------------------------------+
| AGENCY CỦA BẠN (Owner)                                                                                |
| +--------------------------------+ +--------------------------------+ +--------------------------------+
| | Agency FPT Media                | | Sunrise Creative                | | + Tạo Agency mới               |
| | 5 Workspace | 12 Member         | | 2 Workspace | 4 Member          | |                                |
| | [Avatar cluster]                | | [Avatar cluster]                | |                                |
| +--------------------------------+ +--------------------------------+ +--------------------------------+
+-------------------------------------------------------------------------------------------------------+
```

Agency Dashboard (sau khi click 1 Agency):
```
+-------------------------------------------------------------------------------------------------------+
| [< Agency FPT Media]                                        [Tabs: Workspaces | Members | Profile]    |
+-------------------------------------------------------------------------------------------------------+
| DANH SÁCH WORKSPACE                                                    [+ Tạo Workspace mới]          |
| +--------------------------------+ +--------------------------------+                                 |
| | Workspace: Coca-Cola Q3 Camp.   | | Workspace: Samsung Launch       |                                 |
| | Manager: Lộc | Client: Coca-Cola| | Manager: Tuấn | Client: Samsung |                                 |
| | Package: ACTIVE                 | | Package: NEGOTIATING            |                                 |
| +--------------------------------+ +--------------------------------+                                 |
+-------------------------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Thẻ Agency/Workspace:** `Card` + `Avatar`/`AvatarGroup` (cluster member).
- **Tạo Agency/Workspace:** `Dialog` với form `Input` (tên) — theo FR 3.4.3/3.4.12, Workspace bắt buộc gán Manager ngay lúc tạo (`Select` chọn Member làm Manager, có thể tự chọn Owner).
- **Tab Agency Dashboard:** `Tabs` (`Workspaces`/`Members`/`Profile`).
- **Badge trạng thái Package:** `Badge` (`secondary` NEGOTIATING, `success` ACTIVE).

#### 4. Giao diện biến thể theo Role
- **Owner:** Thấy toàn bộ Agency mình sở hữu, nút Tạo Agency/Workspace, nút Xoá Agency (soft-delete 30 ngày).
- **Member khác của Agency (chưa vào Workspace nào)**: thấy Agency nhưng không thấy nút Tạo Workspace (chỉ Owner tạo được — FR 3.4.12).
- **Manager/Creator/Client**: không có màn hình Agency List riêng — họ vào thẳng Workspace họ được mời (bookmark link), không "list Agency" vì họ không phải chủ Agency.

---

### MÀN HÌNH 3: WORKSPACE DASHBOARD (THAY MAIN DASHBOARD CŨ)

#### 1. Bố cục tổng quan (Desktop 1440px)
- **Sidebar (260px):** Workspace switcher (đổi giữa các Workspace User có mặt), menu: Dashboard / Package & Campaign / Tasks / Calendar / Collaborators / Analytics.
- **Header:** Breadcrumb, hiển thị rõ **role hiện tại trong Workspace này** (badge cạnh tên Workspace).
- **Main Content:** KPI card + Task cần duyệt + hoạt động gần đây — giữ layout tương tự V1 nhưng số liệu đổi theo domain mới.

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Workspace: Coca-Cola Q3 v] [Role: MANAGER] | [Search...]  [Bell] [Avatar v]                          |
+---------------+---------------------------------------------------------------------------------------+
|               |  CHÀO MỪNG TRỞ LẠI, LỘC!                                    [Button: + Task thủ công] |
|  - Dashboard  | +--------------------+ +--------------------+ +--------------------+ +----------------+ |
|  - Package &  | | CAMPAIGN STATUS    | | TASK BACKLOG       | | AI CREDITS CÒN LẠI | | PENDING APPROV | |
|    Campaign   | | ACTIVE (2/3 Task)  | | 24 Task            | | 4,250 / 5,000       | | 6 Task duyệt   | |
|  - Tasks      | +--------------------+ +--------------------+ +--------------------+ +----------------+ |
|  - Calendar   |                                                                                       |
|  - Collabora- | +--------------------------------------------------+ +-------------------------------+ |
|    tors       | | TASK CẦN DUYỆT (Approval Queue)      [Xem tất cả]| | HOẠT ĐỘNG GẦN ĐÂY             | |
|  - Analytics  | | +----------------------------------------------+ | | - Creator Tuấn nộp Task 'Post'| |
|               | | | [Icon:Post] 'Ra mắt SP mới' - Facebook       | | | - Client Coca-Cola reject Pkg | |
|               | | | Gửi bởi: Tuấn | Chờ Manager duyệt            | | | - Campaign 'Q3 Launch' active | |
|               | | | [Button: Xem] [Button: Duyệt]                | | | - AI gợi ý 3 Collaborator mới | |
| [Lộc MANAGER v]| +--------------------------------------------------+ +-------------------------------+ |
+---------------+---------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
Giữ nguyên bộ component V1 (`Sidebar`, `DropdownMenu` cho Workspace switcher, `Popover`+`ScrollArea` cho notification, `Card`, `Table`+`Badge` cho Approval Queue, `Progress` cho AI Credits).

#### 4. Giao diện biến thể theo Role
- **Owner:** KPI tập trung Campaign/Package trên toàn Workspace, danh sách Task cần duyệt của mọi Creator, nút cấu hình AI Credits.
- **Manager [mặc định]:** Approval Queue là trung tâm — Task cần Manager review. Widget "Package/Campaign đang đàm phán" nếu có.
- **Creator:** Dashboard cá nhân — "Task được giao", "AI Credits cá nhân đã dùng", "Task bị reject cần sửa lại" (badge riêng cho case reject-giữ-approval-cũ, xem `docs/ba/13`).
- **Client:** Không vào Dashboard này — điều hướng thẳng Client Portal (Màn hình 8).

---

### MÀN HÌNH 4: MEDIA PACKAGE & CAMPAIGN NEGOTIATION (MỚI — THAY CONTENT EDITOR ĐƠN)

#### 1. Bố cục tổng quan (Desktop 1440px)
Đây là màn hình lõi nhất của V2, không tồn tại ở bản cũ. 2 giai đoạn trong cùng 1 layout dạng stepper:
- **Giai đoạn 1 — Package:** chọn Package Template hoặc custom → Client/Manager qua lại đề xuất đổi (negotiation) → cả 2 bên Approve.
- **Giai đoạn 2 — Campaign:** sau Package ACTIVE, lên kế hoạch Campaign chi tiết → cả 2 bên Approve → auto-gen Task backlog.
- **Layout:** cột trái là stepper trạng thái (Package → Campaign → Backlog), cột phải là nội dung đang đàm phán + khung comment giữa Manager/Owner và Client.

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Workspace: Coca-Cola Q3 v] [Role: MANAGER]                                          [Avatar v]       |
+---------------+---------------------------------------------------------------------------------------+
| STEPPER:      | MEDIA PACKAGE — "Gói Truyền Thông Đa Kênh Cơ Bản"          [Trạng thái: NEGOTIATING]   |
| [1.Package]-> | +-----------------------------------------------------+-------------------------------+ |
|  2.Campaign   | | NỘI DUNG GÓI (đang đề xuất bởi Client)               | LỊCH SỬ ĐÀM PHÁN               | |
|  3.Backlog    | | - Số bài Facebook/tháng: 12                          | [10:00] Manager: Đề xuất gói cơ| |
|               | | - Số bài Instagram/tháng: 8                          | bản 12 bài/tháng                | |
|               | | - 1 Livestream/tháng                                  | [11:30] Client: Muốn thêm      | |
|               | | - Ngân sách dự kiến: 50,000,000đ                      | Livestream lên 2 lần/tháng      | |
|               | |                                                       | [Textarea: Nhập đề xuất mới...] | |
|               | +-----------------------------------------------------+-------------------------------+ |
|               | [Button: Đề xuất thay đổi]   [Button: APPROVE gói này]                                  |
|               | (*) Cần CẢ HAI bên Approve bản mới nhất mới chuyển ACTIVE — 1 bên sửa lại sẽ reset      |
|               |     approve của bên kia (xem docs/ba/13 mục 3)                                          |
+---------------+---------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Stepper trạng thái:** custom component dựng từ `Separator` + `Badge` (số bước, có thể dùng thư viện stepper ngoài nếu cần, style theo token shadcn).
- **Khung nội dung Package/Campaign:** `Card` + `Table` (liệt kê hạng mục) + `Input`/`Textarea` khi ở chế độ đề xuất sửa.
- **Lịch sử đàm phán:** `ScrollArea` + `Avatar` + timestamp, giống khung chat.
- **Nút Approve:** `Button` (`default`), disabled nếu bên còn lại chưa approve bản hiện tại (hiển thị tooltip lý do).
- **Cảnh báo 2-bên-approve:** `Alert` (variant `default`, icon info) đặt cố định dưới nút hành động.

#### 4. Giao diện biến thể theo Role
- **Owner/Manager:** Đề xuất/counter-offer nội dung Package và Campaign, bấm Approve đại diện Agency.
- **Client:** Đề xuất thay đổi, bấm Approve đại diện phía khách hàng — quyền ngang với Manager trong bước này (cả 2 đều cần approve).
- **Creator:** Không truy cập màn hình này (không tham gia đàm phán thương mại).
- Sau khi Campaign approved (2 bên) → tự chuyển sang bước 3 (Backlog) → **Campaign khoá immutable** — không còn nút sửa, chỉ còn link "Tạo Content Request" hoặc "Manager thêm Task thủ công" (xem `docs/ba/13` mục 6).

---

### MÀN HÌNH 5: TASK BOARD — KANBAN THEO APPROVAL SEQUENCE (THAY CONTENT EDITOR DUYỆT BÀI)

#### 1. Bố cục tổng quan (Desktop 1440px)
Kanban board — cột theo state machine Approval Sequence (`docs/ba/12-state-machines.md` mục 4), không theo ngày như Calendar.
- **Header bộ lọc:** loại Task (Post/Livestream/Survey), Creator phụ trách, Campaign nguồn.
- **Cột:** `Backlog` → `Assigned` → `In Progress` → `QC Review` (nếu có QC) → `Manager Review` → `Client Review` (nếu required) → `Completed`.
- Mỗi Task card có icon phân biệt loại (Post/Livestream/Survey).

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Workspace: Coca-Cola Q3 v]  Lọc: [Loại Task v] [Creator v] [Campaign v]              [Avatar v]       |
+-------------------------------------------------------------------------------------------------------+
| BACKLOG      | ASSIGNED      | IN PROGRESS   | MANAGER REVIEW | CLIENT REVIEW  | COMPLETED             |
| +----------+ | +-----------+ | +-----------+ | +------------+ | +------------+ | +------------+        |
| |[Post]    | | |[Post]     | | |[Livestream| | |[Post]      | | |[Post]      | | |[Survey]    |        |
| |Ra mắt SP | | |Tuấn - due | | | Kickoff   | | |Chờ Manager | | |Chờ Client  | | |Done         |        |
| |chưa giao | | |20/09      | | |Tuấn       | | |duyệt lại   | | |approve     | | |             |        |
| +----------+ | +-----------+ | +-----------+ | (badge: giữ QC| +------------+ | +------------+        |
| +----------+ |               |               | approve cũ)   |                |                       |
| |[Survey]  | |               |               | +------------+ |                |                       |
| |Khảo sát  | |               |               |                |                |                       |
+-------------------------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Kanban:** custom drag-drop dựng trên `dnd-kit`, cột bọc `Card`, mỗi Task card `Card` nhỏ với `Badge` loại Task + `Avatar` Creator.
- **Badge "giữ approval cũ":** `Badge` (variant `outline`, icon History) hiển thị khi Task quay về `ASSIGNED` nhưng có approval step trước đã pass — theo rule reject mới (`docs/ba/13` mục 4), tooltip giải thích "QC đã duyệt trước đó, không cần duyệt lại".
- **Kéo Task sang cột khác:** map thao tác kéo-thả với action approve/reject của Approval Sequence — kéo lùi 1 cột = reject, cảnh báo `AlertDialog` xác nhận trước khi kéo lùi nhiều hơn 1 cột (không hợp lệ).

#### 4. Giao diện biến thể theo Role
- **Manager:** Kéo-thả toàn quyền, xem toàn bộ cột. Nút "Assign" mở `Dialog` chọn Creator + optional QC assignee + toggle `requiresClientApproval`.
- **Creator:** Chỉ thao tác Task được giao cho mình (`Assigned`/`In Progress`), không kéo được Task người khác.
- **Client:** Chỉ thấy cột `Client Review` (Task cần họ duyệt) và `Completed` — không thấy Backlog/Assigned nội bộ Agency.

---

### MÀN HÌNH 6: TASK DETAIL (CONTENT EDITOR TÍCH HỢP AI)

#### 1. Bố cục tổng quan (Desktop 1440px)
3 cột như V1 nhưng cột phải thêm progress-stepper Approval Sequence, và preview bỏ Zalo OA.
- **Cột Trái (AI Panel 25%):** Prompt, Brand Guideline (RAG), Tone, Length.
- **Cột Giữa (Editor 45%):** soạn thảo, upload media, hashtag.
- **Cột Phải (Preview + Approval 30%):** preview theo platform (FB/IG/TikTok/Threads) + stepper Approval Sequence hiện tại.

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Workspace: Coca-Cola Q3 v] Task: 'Ra mắt SP mới' [Post]           [Stepper: Creator > QC > Manager]  |
+---------------+---------------------------------------------------------------------------------------+
| AI GENERATION | EDITOR AREA                       | PREVIEW + APPROVAL                                |
| [Select: RAG] | [Input: Tiêu đề]                  | [Tabs: FB | IG | TikTok | Threads]                |
| [Select:      |                                    | +----------------------------------+               |
|  Platform]    | [Textarea: Caption...]             | | Preview render đúng platform      |               |
| [Textarea:    |                                    | +----------------------------------+               |
|  Brief AI]    | [Card: Media Upload]               | Bước hiện tại: QC_REVIEW                          |
| [Slider:      |                                    | [Button: Approve] [Button: Reject + lý do]        |
|  Creativity]  | [Button: Gửi Manager duyệt]        | (approve trước đó của step khác vẫn giữ nguyên)   |
+---------------+---------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
Giữ bộ component V1 (`ResizablePanelGroup`, `Select`, `Slider`, `Textarea`, `Skeleton` khi AI generate). Đổi `Tabs` preview: bỏ Zalo, còn `FB | IG | TikTok | Threads`. Thêm stepper (`Separator`+`Badge`) ở Header hiển thị bước hiện tại trong Approval Sequence.

#### 4. Giao diện biến thể theo Role
- **Creator:** Full AI Panel + Editor. Nút hành động: "Gửi duyệt" (submit → vào bước kế tiếp theo state machine: QC nếu có, không thì Manager).
- **QC (Creator khác được gán)**: chỉ thấy Preview + nút Approve/Reject, không sửa nội dung trực tiếp — muốn sửa phải reject để trả về Creator gốc.
- **Manager:** Preview + Approve/Reject, có thể sửa nhẹ lỗi chính tả trực tiếp trước khi Approve.
- **Client:** Chỉ vào được màn này nếu `requiresClientApproval = true` và Task đang ở bước `CLIENT_REVIEW` — chỉ thấy Preview + Approve/Reject, không thấy AI Panel/Editor.

---

### MÀN HÌNH 7: CONTENT CALENDAR

Giữ nguyên cấu trúc lịch V1 (Calendar Grid + Drawer chi tiết + mobile weekly-slider) — không đổi vì Task vẫn có `dueDate`/`scheduledAt`. Chỉ đổi 2 điểm:
1. Badge trạng thái map theo Task status mới (`ASSIGNED`/`IN_PROGRESS`/`QC_REVIEW`/`MANAGER_REVIEW`/`CLIENT_REVIEW`/`COMPLETED`) thay vì `Draft/Pending/Scheduled/Published` của Post cũ.
2. Bỏ kênh Zalo khỏi bộ lọc Channel — còn FB/IG/TikTok/Threads.

*(Role behavior giữ nguyên tinh thần V1: Owner/Manager full control kéo-thả, Creator chỉ Task của mình ở trạng thái chưa duyệt, Client read-only chỉ thấy Task đã `COMPLETED`/lên lịch publish.)*

---

### MÀN HÌNH 8: CLIENT PORTAL (CỔNG THÔNG TIN KHÁCH HÀNG)

#### 1. Bố cục tổng quan (Desktop 1440px)
- **Branding:** Logo Client (white-label), không phải logo Agency.
- **Sidebar:** Package/Campaign (đàm phán — trỏ vào Màn hình 4 nhưng scope Client), Task cần duyệt (Client Review queue), Content Request (Client tự tạo — kênh bổ sung riêng biệt Campaign), Calendar (read-only).
- **Main Content:** Tập trung Task đang chờ Client duyệt, dạng Card.

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Client Logo: Coca-Cola] | [Breadcrumb: Portal / Chờ duyệt]                        [Avatar v]         |
+---------------+---------------------------------------------------------------------------------------+
|               | TASK CHỜ DUYỆT (3)                                        [Button: + Content Request] |
| - Package &   | +-----------------------------------------------------------------------------------+ |
|   Campaign    | | TASK #01 — [Post] 'Khuyến mãi cuối tháng' — Facebook — Lên lịch 18/06               | |
| - Chờ duyệt   | | +------------------------------------+------------------------------------------+ | |
| - Content     | | | PREVIEW                            | LỊCH SỬ DUYỆT                            | | |
|   Request     | | | [Hình ảnh + caption]                | [10:00] Creator: đã sửa ảnh theo brief    | | |
| - Calendar    | | |                                     | [11:15] Manager: đã check OK              | | |
|               | | +------------------------------------+------------------------------------------+ | |
|               | | [Button: PHÊ DUYỆT]      [Button: TỪ CHỐI (kèm lý do — Task về lại ASSIGNED)]      | |
|               | +-----------------------------------------------------------------------------------+ |
+---------------+---------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
Giữ bộ V1 (`Card`, `ScrollArea` chat, `Dialog` cho Content Request mới). Thêm: nút **"+ Content Request"** mở `Dialog` riêng — rõ ràng đây là kênh **bổ sung, độc lập** với Package/Campaign chính (theo `docs/ba/04-media-package-campaign.md` mục 4), không lẫn vào luồng đàm phán Package.

#### 4. Giao diện biến thể theo Role
- **Client [mặc định]:** Approve/Reject Task cần duyệt, tạo Content Request mới, đàm phán Package/Campaign.
- **Manager:** Có thể vào Portal ở chế độ xem hộ (impersonate) để hỗ trợ, không thay Client bấm Approve.
- **Content Request bị Manager denied** → hiển thị trạng thái **terminal**, không có nút sửa lại — chỉ nút "Tạo Content Request mới" (xem `docs/ba/13` mục 5).

---

### MÀN HÌNH 9: THIRD-PARTY COLLABORATOR (MỚI — DANH BẠ ĐỐI TÁC NGOÀI SOCIAL)

#### 1. Bố cục tổng quan (Desktop 1440px)
Module mới, không thuộc publish tự động (báo/banner/TV không có API). Layout dạng CRM đơn giản, danh bạ cấp Agency.
- **Bên trái:** danh sách `ThirdPartyCollaborator` (danh bạ chung, tái sử dụng qua nhiều Campaign — xem `docs/ba/13` mục 8).
- **Bên phải:** khi chọn 1 Campaign cụ thể, hiển thị `cooperationStatus` của từng Collaborator gắn với Campaign đó (`CONTACTED → NEGOTIATING → CONFIRMED → LIVE_ON_AIR`).

#### 2. Sơ đồ Wireframe (ASCII Art)
```
+-------------------------------------------------------------------------------------------------------+
| [Workspace: Coca-Cola Q3 v]  Campaign: [Q3 Launch v]                                  [Avatar v]       |
+---------------+---------------------------------------------------------------------------------------+
| DANH BẠ AGENCY (dùng chung nhiều Campaign) | COLLABORATOR TRONG CAMPAIGN "Q3 LAUNCH"                   |
| +-----------------------------------------+ +-----------------------------------------------------+  |
| | Báo Tuổi Trẻ (newspaper)   [+ Gắn vào]   | | Báo Tuổi Trẻ         [Badge: LIVE_ON_AIR]           |  |
| | Kênh 14 (banner)           [+ Gắn vào]   | | Kênh HTV7            [Badge: NEGOTIATING]           |  |
| | HTV7 (tv)                  [+ Gắn vào]   | |                                                       |  |
| +-----------------------------------------+ +-----------------------------------------------------+  |
| [Button: + Thêm Collaborator mới]           [Button: AI Gợi ý Collaborator]                          |
+-------------------------------------------------------------------------------------------------------+
```

#### 3. Bản đồ Component shadcn/ui
- **Danh bạ:** `Table` hoặc `Card` list, `Badge` phân loại `partnerType` (newspaper/banner/tv/other).
- **Trạng thái theo Campaign:** `Badge` màu theo `cooperationStatus` (xám `CONTACTED`, vàng `NEGOTIATING`, xanh dương `CONFIRMED`, xanh lá `LIVE_ON_AIR`).
- **AI Gợi ý:** `Button` mở `Sheet` hiển thị kết quả `Recommend Collaborator` (FR 3.7.12), mỗi gợi ý có nút "Thêm vào danh bạ" hoặc "Gắn vào Campaign" nếu đã có sẵn.

#### 4. Giao diện biến thể theo Role
- **Owner/Manager:** Full CRUD danh bạ + gắn/gỡ Collaborator khỏi Campaign, cập nhật `cooperationStatus` thủ công.
- **Creator:** Chỉ xem (đọc gợi ý AI để biết đối tác nào đang hợp tác, phục vụ tạo nội dung phù hợp).
- **Client:** Không truy cập màn hình này (nội bộ vận hành Agency).

---

### MÀN HÌNH 10: ANALYTICS DASHBOARD

Giữ cấu trúc V1 (KPI Grid → Charts → Top Performing Posts) nhưng đổi phạm vi dữ liệu:
- Bỏ kênh Zalo khỏi bộ lọc.
- Thêm KPI "Hiệu quả Third-party Collaborator" (ước tính reach từ báo/TV — nhập tay, không tự động như social).
- Owner xem thêm KPI theo Campaign (không phải theo Post rời rạc như V1) — vì đơn vị đo lường giờ là Campaign, không phải từng bài lẻ.

*(Role behavior giữ tinh thần V1: Owner xem tài chính+ROI, Manager xem theo Campaign phụ trách, Creator xem theo Task cá nhân, Client xem bản rút gọn ẩn nội bộ Agency.)*

---

### MÀN HÌNH 11: ADMIN CONSOLE (MỞ RỘNG)

Không có ở bản wireframe V1 (V1 chỉ có Admin ẩn trong role-matrix, chưa thiết kế màn hình riêng). V2 cần màn hình Admin đầy đủ theo `docs/ba/09-admin-management.md`:
- **Sidebar:** User Management, Agency/Workspace Oversight, Content Moderation, Audit Log, System Config.
- **User Management:** `Table` liệt kê User toàn hệ thống, nút Deactivate (có câu hỏi mở "Admin xoá Admin được không" — chưa chốt, UI tạm ẩn nút này khi target là Admin khác, xem `docs/feature/admin-management/3-10-9-deactive-user/spec.md`).
- Role duy nhất truy cập: `ADMIN`.

---

## III. THIẾT KẾ MOBILE CHUYÊN BIỆT (375PX)

Giữ nguyên 3 màn hình mobile core từ V1 (**Content Calendar**, **Notifications**, **Post Preview** — xem cấu trúc ASCII gốc, không đổi vì không phụ thuộc cấu trúc Agency/Package/Campaign), chỉ đổi:
- Notification card thêm loại thông báo mới: "Package/Campaign cần Approve", "Content Request bị denied", "Task quay về ASSIGNED (giữ approval cũ)".
- Post Preview bỏ tab Zalo, còn `FB | IG | TikTok | Threads`.

---

## IV. HƯỚNG DẪN MAPPING FIGMA & CƠ CẤU COMPONENT REACT (V2)

### 1. Cấu trúc thư mục Component khuyến nghị (React + Vite)
```bash
src/
└── app/
    ├── components/
    │   ├── ui/                      # shadcn/ui gốc
    │   └── custom/
    │       ├── agency-switcher.tsx        # Chọn Agency (mới)
    │       ├── workspace-switcher.tsx     # Chọn Workspace trong Agency
    │       ├── package-negotiation-panel.tsx  # Đàm phán Package/Campaign (mới)
    │       ├── task-kanban-board.tsx      # Kanban theo Approval Sequence (mới)
    │       ├── task-approval-stepper.tsx  # Stepper trạng thái duyệt (mới)
    │       ├── collaborator-directory.tsx # Danh bạ Third-party Collaborator (mới)
    │       ├── post-simulator.tsx         # Preview đa kênh (FB/IG/TikTok/Threads — bỏ Zalo)
    │       ├── ai-generation-panel.tsx
    │       └── notification-popover.tsx
    └── pages/
        ├── LoginPage.tsx
        ├── AgencyListPage.tsx          # mới
        ├── AgencyDashboardPage.tsx     # mới
        ├── WorkspaceDashboardPage.tsx
        ├── PackageCampaignPage.tsx     # mới
        ├── TaskBoardPage.tsx           # mới
        ├── TaskDetailPage.tsx
        ├── CalendarPage.tsx
        ├── ClientPortalPage.tsx
        ├── CollaboratorPage.tsx        # mới
        ├── AnalyticsPage.tsx
        └── AdminConsolePage.tsx        # mới
```

### 2. Check-list khi dựng giao diện
1. **Figma Setup:** dùng Figma UI Kit `shadcn/ui`, đặt tên layer theo tên component (`[Button] Approve Task`, `[Card] Package Summary`).
2. **Đồng bộ state machine:** mọi component hiển thị trạng thái Task/Package/Campaign phải map đúng enum trong `docs/ba/12-state-machines.md` — không tự đặt tên trạng thái mới ở FE.
3. **Role check ở component, không chỉ route:** vì role gán theo Workspace (không cố định), mọi component hiển thị hành động (nút Approve, nút Assign...) phải check role-trong-Workspace-hiện-tại từ context, không dùng role toàn cục lưu ở global store.
4. **Không hardcode Zalo** trong bất kỳ danh sách platform nào (select, tab, badge) — chỉ FB/IG/TikTok/Threads.

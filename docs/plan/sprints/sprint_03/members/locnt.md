# Sprint 3 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Thành Lộc |
| GitHub | [@Loc20904] |
| Role | Frontend Developer, Backend Developer |
| Sprint | Sprint 3 |
| Ngày nộp | 2026-06-29 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-192 | [DA-192](https://letritrung2605.atlassian.net/browse/DA-192) | DA-E08-01 Create wireframes for all main screens | 🔴 Critical | ✅ Done |
| DA-207 | [DA-207](https://letritrung2605.atlassian.net/browse/DA-207) | DA-E08-02 Design component system | 🔴 Critical | 🔄 In Review |
| DA-144 | [DA-144](https://letritrung2605.atlassian.net/browse/DA-144) | DA-E08-03 Draw user flow diagrams for 3 main flows | 🟡 High | ✅ Done |
| DA-157 | [DA-157](https://letritrung2605.atlassian.net/browse/DA-157) | DA-E08-04 Wireframe Client Portal | 🟡 High | ✅ Done |
| DA-405 | [DA-405](https://letritrung2605.atlassian.net/browse/DA-405) | DA-E08-05 Create local document website (VitePress) | 🟢 Medium | ✅ Done |
| DA-64 | [DA-64](https://letritrung2605.atlassian.net/browse/DA-64) | Write report about 3 model (produce + model) and analyze | 🟡 High | ✅ Done |

**Tổng:** 6 tasks | Done: 5 | In Review: 1 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

### [DA-192] — Create wireframes for all main screens

**Jira status:** Done  
**Branch:** `docs/DA-192-create-wireframe-main-screens`  
**Commit chính:** `8ac1704` — `docs(DA-192): create 7 main screens wireframe`  
**File tạo ra / thay đổi:**
- `docs/wireframe/DA-E08-01_Wireframe_Report.md` — Báo cáo chi tiết 7 màn hình kèm chú thích shadcn/ui.
- `docs/wireframe/brandhub_wireframe_blueprint.md` — Wireframe blueprint tổng quan cho các màn hình.
- `docs/wireframe/wireframe_to_code_checklist.md` — Checklist ánh xạ wireframe sang code component.

**Mô tả công việc đã làm:**
Thiết kế wireframe low-to-mid fidelity cho toàn bộ các màn hình chính của hệ thống bao gồm: Login/Register, Main Dashboard (phân biệt các biến thể role: Agency Owner vs Content Creator), Workspace Settings, Client list/detail, Content Request list, Content Editor (tích hợp AI generation panel), và Analytics Dashboard. Bổ sung khung hình mobile 375px cho các màn hình cốt lõi trên ứng dụng di động (Calendar, Notifications, Post Preview). Mỗi màn hình được chú thích rõ ràng bằng tên component tương ứng theo shadcn/ui (ví dụ: Card, Table, Dialog, Select...) để hỗ trợ nhà phát triển frontend lập bản đồ thành phần giao diện một cách nhanh chóng.

**Kết quả đạt được:**
- [x] Tạo thành công wireframe cho các phân hệ màn hình chính theo kích thước 1440px desktop.
- [x] Thiết kế frame 375px mobile cho các màn hình cốt lõi trên ứng dụng di động.
- [x] Ánh xạ thành phần wireframe tương ứng 100% với tên component trong hệ thống shadcn/ui.
- [x] Thiết kế layout phân quyền (RBAC) chi tiết cho các vai trò chính (Agency Owner, Content Creator).

**Khó khăn gặp phải:** Giao diện Content Editor tích hợp AI generation panel khá phức tạp, cần thiết kế 2 trạng thái (thu gọn/mở rộng panel) để tối ưu không gian làm việc chính cho người dùng.

**Thời gian thực tế:** ~10 giờ

---

### [DA-207] — Design component system

**Jira status:** In Review  
**Branch:** `docs/DA-207-create-components`  
**Commit chính:** `eb3f26e` — `docs(DA-207): Submit report task create components`  
**File tạo ra / thay đổi:**
- `docs/wireframe/brandhub_components_Report.md` — Báo cáo chi tiết về hệ thống component.

**Mô tả công việc đã làm:**
Xây dựng tài liệu hướng dẫn và đặc tả hệ thống component dựa trên shadcn/ui cho dự án BrandHub. Thiết kế chi tiết cho các thành phần cơ bản (Button, Input, Modal/Dialog, Table, Badge, Toast). Tích hợp cấu trúc các token thiết kế (màu sắc primary/secondary/destructive, typography scale, spacing scale, border radius, shadow) để đảm bảo tính đồng nhất về mặt giao diện. Thiết kế sơ đồ màu sắc của Badge tương ứng với từng trạng thái của `PostStatus` enum (DRAFT, PENDING_REVIEW, APPROVED, SCHEDULED, PUBLISHED, FAILED, REJECTED). Hiện tại đang trong quá trình cập nhật, hoàn thiện thêm các component từ các thư viện React có sẵn.

**Kết quả đạt được:**
- [x] Định nghĩa đầy đủ các component variants cho Button, Input, Modal, Table, Badge và Toast.
- [x] Ánh xạ màu sắc Badge tương ứng 100% với các trạng thái của `PostStatus`.
- [x] Thiết lập hệ thống biến CSS token đồng bộ trực tiếp với shadcn/ui.
- [ ] Cập nhật và tích hợp đầy đủ các component từ thư viện React có sẵn (đang thực hiện).

**Thời gian thực tế:** ~6 giờ

---

### [DA-144] — Draw user flow diagrams for 3 main flows

**Jira status:** Done  
**Branch:** `docs/DA-144-userflow-diagrams`  
**Commit chính:** `0ad72d9` — `docs(DA-144): Create 3 main user flows UX-layer`  
**File tạo ra / thay đổi:**
- `docs/wireframe/brandhub_flows_Report.md` — Sơ đồ luồng người dùng cho 3 quy trình chính.

**Mô tả công việc đã làm:**
Thiết kế sơ đồ luồng người dùng (User Flow Diagrams) ở tầng UX cho 3 quy trình nghiệp vụ cốt lõi: quy trình tạo nội dung (Content Creation Flow), quy trình phê duyệt (Approval Flow) và quy trình xuất bản (Publishing Flow). Sử dụng các mũi tên kết nối trực tiếp trong Figma để liên kết các màn hình wireframe nhằm đồng bộ hóa thiết kế khi có thay đổi. Mỗi bước của luồng đều được tham chiếu rõ ràng bằng tên frame wireframe tương ứng và phân định rõ vai trò của từng tác nhân trong hệ thống.

**Kết quả đạt được:**
- [x] Hoàn thành luồng tạo nội dung từ Dashboard đến AI prompt input, tạo bản nháp và submit review.
- [x] Hoàn thành luồng phê duyệt từ khi nhận thông báo, duyệt/yêu cầu thay đổi đến đặt lịch trên calendar.
- [x] Hoàn thành luồng xuất bản bài viết từ calendar, trigger đăng bài đến polling trạng thái thành công/thất bại.
- [x] Tích hợp xử lý các luồng rẽ nhánh lỗi (error paths) và đồng nhất với API specs.

**Thời gian thực tế:** ~5 giờ

---

### [DA-157] — Wireframe Client Portal

**Jira status:** Done  
**Branch:** Gộp chung trong branch `docs/DA-192-create-wireframe-main-screens`  
**Commit chính:** `8ac1704` — `docs(DA-192): create 7 main screens wireframe`  
**File tạo ra / thay đổi:**
- Nằm trong `docs/wireframe/DA-E08-01_Wireframe_Report.md` — Section Client Portal.

**Mô tả công việc đã làm:**
Thiết kế giao diện và luồng tương tác dành riêng cho khách hàng (role BRAND_CLIENT) với các chức năng độc lập so với dashboard của agency. Thiết kế bao gồm 3 màn hình cốt lõi: lịch đăng bài chỉ đọc (Read-only Content Calendar), luồng phê duyệt/từ chối bài đăng kèm lý do (Approve/Reject flow), và trang xem thống kê cơ bản (Analytics View). Bố cục giao diện được rút gọn tối đa (stripped navigation, không có workspace switcher hay AI tools) để củng cố quyền truy cập giới hạn của client.

**Kết quả đạt được:**
- [x] Thiết kế giao diện lịch đăng bài dạng tuần/tháng ở chế độ chỉ xem và xem chi tiết bài đăng.
- [x] Tích hợp nút Duyệt (Approve) và Từ chối (Reject) kèm hộp thoại nhập lý do bắt buộc khi từ chối bài viết.
- [x] Thiết lập giao diện Analytics hiển thị các chỉ số Reach/Impressions/Engagement trên từng nền tảng xã hội.
- [x] Đảm bảo hiển thị đúng trạng thái của bài đăng theo `PostStatus` enum.

**Thời gian thực tế:** ~2 giờ (gộp trong DA-192)

---

### [DA-405] — Create local document website (VitePress)

**Jira status:** Done  
**Branch:** `docs/DA-409-integrated-view-document-html` / `develop`  
**Commit chính:** `b48f28f` — `feat: setup doctree homepage, auto-deploy CI/CD`  
**File tạo ra / thay đổi:**
- `frontend/generate-tree.js` — Script tự động quét cấu trúc thư mục `docs/` để tạo menu điều hướng.
- `frontend/.vitepress/config.js` — Cấu hình chính của VitePress site với custom theme và đường dẫn.
- `frontend/.vitepress/theme/components/DocsTree.vue` — Component render cây tài liệu trực quan.
- `frontend/.vitepress/theme/components/DocsTreeItem.vue` — Component hiển thị item tài liệu con.
- `frontend/.vitepress/theme/components/HtmlViewer.vue` — Component dùng để xem tài liệu HTML cục bộ.
- `docs/index.md` — Trang chủ của doc site.
- `.github/workflows/deploy.yml` — Quy trình CI/CD tự động deploy lên GitHub Pages khi merge vào develop.

**Mô tả công việc đã làm:**
Thiết lập trang web tài liệu cục bộ sử dụng VitePress để tự động hóa việc hiển thị tài liệu của dự án. Viết script `generate-tree.js` giúp tự động quét và cập nhật cây tài liệu (navigation tree) từ thư mục `docs/` mà không cần cấu hình thủ công. Tùy chỉnh theme mặc định của VitePress và xây dựng các Vue components (`DocsTree.vue`, `HtmlViewer.vue`) để hiển thị trực quan các file HTML được xuất ra từ các công cụ thiết kế. Cấu hình CI/CD thông qua GitHub Actions để tự động deploy lên GitHub Pages.

**Kết quả đạt được:**
- [x] Thiết lập thành công VitePress site chạy trên local dev server.
- [x] Tự động hóa việc quét thư mục tài liệu và hiển thị lên thanh điều hướng.
- [x] Tích hợp bộ xem tài liệu HTML cục bộ ngay trên giao diện web.
- [x] Cấu hình và triển khai thành công hệ thống tự động deploy (CI/CD) qua GitHub Actions.

**Thời gian thực tế:** ~12 giờ

---

### [DA-64] — Write report about 3 model (produce + model) and analyze

**Jira status:** Done  
**Branch:** `docs/de180158-task-report` / `develop`  
**Commit chính:** `7ac0fe5` — `docs(DA-64): research models AI for content create` (hoặc `e85a662` — `[DE180158] docs: add ai model research report`)
**File tạo ra / thay đổi:**
- `docs/AI_Models/Research_Model_Generate_Advertise_Image.md` — Báo cáo nghiên cứu chi tiết các mô hình AI tạo ảnh quảng cáo.

**Mô tả công việc đã làm:**
Tiến hành nghiên cứu, đánh giá và viết báo cáo chuyên sâu về các mô hình trí tuệ nhân tạo (AI Models) phục vụ cho việc tạo hình ảnh quảng cáo và thử quần áo ảo (Virtual Try-On). Báo cáo phân tích chi tiết về 3 nhóm mô hình chính:
1. Base Model / Text-to-image: Đánh giá `FLUX.1-dev` và `FLUX.1-schnell` về chất lượng ảnh sinh ra, hiệu năng, lượng VRAM tiêu thụ và giấy phép sử dụng.
2. Virtual Try-On (Thử đồ ảo): So sánh hiệu quả giữ garment fidelity và pose của các mô hình `IDM-VTON`, `CatVTON`, `StableVITON`, `OOTDiffusion` và `Kolors VTON`.
3. Inpainting & Editing: Nghiên cứu khả năng chỉnh sửa vùng ảnh của `FLUX.1 Fill`.
Từ đó đưa ra các phân tích so sánh chi tiết và đề xuất mô hình tối ưu nhất cho giai đoạn MVP của dự án (khuyến nghị dùng `CatVTON` cho thử đồ nhẹ và kết hợp `FLUX.1` để nâng cao chất lượng).

**Kết quả đạt được:**
- [x] Nghiên cứu và phân tích sâu các ưu/nhược điểm, mức tiêu thụ VRAM và license của nhóm mô hình FLUX.1.
- [x] So sánh chi tiết 5 mô hình Virtual Try-On hàng đầu hiện nay.
- [x] Hoàn thành báo cáo dài 294 dòng phân tích kỹ thuật và sơ đồ quy trình kết hợp nâng cao.
- [x] Đưa ra khuyến nghị lựa chọn mô hình tối ưu phù hợp với hạ tầng phần cứng của dự án.

**Thời gian thực tế:** ~8 giờ

---

## 4. Tasks chưa hoàn thành

*Không có task nào chưa hoàn thành (chỉ có DA-207 đang ở trạng thái In Review để cập nhật thêm các component).*

---

## 5. Đóng góp ngoài tasks chính

- Hỗ trợ cấu hình deployment cho tài liệu dự án trên GitHub Pages, giải quyết lỗi đường dẫn tĩnh (base path) của VitePress (`fb32df0` và `63515f5`).
- Sửa lỗi sử dụng helper `withBase` của VitePress để đảm bảo hiển thị đúng liên kết tệp và kích hoạt highlight cho các mục tài liệu tương ứng (`bc9f6fb`).

---

## 6. Học được gì trong sprint này

1. **Tùy biến cấu hình VitePress:** Học cách tích hợp custom Vue components (`DocsTree.vue`, `HtmlViewer.vue`) vào cấu trúc mặc định của VitePress để xây dựng trình xem tài liệu HTML động một cách linh hoạt.
2. **Kiến trúc thành phần shadcn/ui:** Hiểu sâu hơn về các primitive Radix UI bên dưới shadcn/ui, giúp thiết kế wireframe khớp sát với khả năng hiện thực hóa giao diện khi lập trình React.
3. **Thiết kế quy trình tích hợp mô hình AI (AI pipeline):** Học cách tổ chức các mô hình khác nhau (Base model, Virtual Try-On, Inpainting) để tạo lập một workflow tự động sinh ảnh quảng cáo và phục vụ thử đồ thời trang tối ưu nhất.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc của team

- Cần tổ chức buổi bàn giao và làm khớp (handoff/sync) sớm hơn giữa bộ phận thiết kế UI/Wireframe và Backend API để đảm bảo cấu trúc dữ liệu mô phỏng trên giao diện và đặc tả Swagger trùng khớp hoàn toàn.

### 7.2 Về technical stack / tools

- Figma giới hạn tài khoản miễn phí khi có nhiều thành viên tham gia cộng tác đồng thời, khuyến nghị xuất định kỳ các phiên bản PDF/Image snapshot của wireframe và upload lên tài liệu chung để cả nhóm dễ dàng truy cập.

### 7.3 Đề xuất cho Sprint tiếp theo

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 5/5 | Tất cả các task đều đạt tiến độ cam kết |
| Chất lượng deliverable | 4/5 | Tài liệu wireframe và báo cáo phân tích AI rõ ràng, đầy đủ |
| Giao tiếp với team | 4/5 | Tích cực trao đổi để tích hợp tài liệu và đồng bộ giao diện |
| Chủ động xử lý blocker | 5/5 | Chủ động giải quyết lỗi cấu hình CI/CD deploy trang tài liệu |
| **Tổng** | **18/20** | |

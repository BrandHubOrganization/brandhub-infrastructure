# Sprint 3 — Individual Report

> **Ví dụ mẫu đã điền đầy đủ — Member thông thường (Lộc - Frontend).** Xem file này để hiểu cách viết khi không phải Leader.

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Văn Lộc |
| GitHub | [@Loc20904] |
| Role | Frontend Developer |
| Sprint | Sprint 3 |
| Ngày nộp | 2026-06-27 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-192 | [DA-192](https://letritrung2605.atlassian.net/browse/DA-192) | DA-E08-01 Create wireframes for all main screens | 🔴 Critical | 🔄 In Review |
| DA-207 | [DA-207](https://letritrung2605.atlassian.net/browse/DA-207) | DA-E08-02 Design component system | 🔴 Critical | 🔄 In Review |
| DA-144 | [DA-144](https://letritrung2605.atlassian.net/browse/DA-144) | DA-E08-03 Draw user flow diagrams for 3 main flows | 🟡 High | 🔄 In Review |
| DA-157 | [DA-157](https://letritrung2605.atlassian.net/browse/DA-157) | DA-E08-04 Wireframe Client Portal | 🟡 High | ✅ Done |
| DA-405 | [DA-405](https://letritrung2605.atlassian.net/browse/DA-405) | DA-E08-05 Create local document website | 🟢 Medium | ✅ Done |

**Tổng:** 5 tasks | Done: 2 | In Review: 3 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

---

### [DA-192] — Create wireframes for all main screens

**Jira status:** In Review  
**Branch:** `docs/DA-192-create-wireframe-main-screens`  
**Commit chính:** `8ac1704` — `docs(DA-192): create 7 main screens wireframe`  
**File tạo ra / thay đổi:**
- `docs/wireframe/DA-E08-01_Wireframe_Report.md` — 7 màn hình, annotated shadcn/ui
- `docs/wireframe/brandhub_wireframe_blueprint.md` — Blueprint tổng quan

**Mô tả công việc đã làm:**

Thiết kế wireframe low-to-mid fidelity cho 7 phân hệ màn hình chính: Login/Auth, Main Dashboard (3 role variants), Workspace Settings, Client Management, Content Request, Content Editor với AI panel, Content Calendar. Mỗi màn hình có component map gắn nhãn theo shadcn/ui (`[Card]`, `[Table]`, `[Dialog]`, `[DatePicker]`...) để Frontend có thể mapping thẳng vào code. Bổ sung Mobile 375px cho 3 màn hình bắt buộc (Calendar, Notifications, Post Preview). Tích hợp RBAC layout: mỗi màn hình có mô tả biến thể theo role.

**Kết quả đạt được:**
- [x] 7/7 phân hệ màn hình hoàn thành
- [x] RBAC variants cho ADMIN, AGENCY_OWNER, ACCOUNT_MANAGER documented
- [x] Annotation 100% theo shadcn/ui naming
- [x] Mobile 375px cho 3 màn hình core

**Khó khăn gặp phải:** Content Editor với AI panel phức tạp hơn dự kiến — phải thiết kế 2 state (collapsed panel vs expanded panel) để không làm chật workspace chính.

**Thời gian thực tế:** ~10 giờ

---

### [DA-207] — Design component system

**Jira status:** In Review  
**Branch:** `docs/DA-207-create-components`  
**Commit chính:** `eb3f26e` — `docs(DA-207): Submit report task create components`  
**File tạo ra / thay đổi:**
- `docs/wireframe/brandhub_components_Report.md` — Component catalogue

**Mô tả công việc đã làm:**

Xây dựng component system cho BrandHub dựa trên shadcn/ui. Định nghĩa atomic components (Button variants, Input states, Badge colors), molecule components (PostCard, ClientCard, NotificationItem), và organism components (Sidebar, Header, ContentEditor). Mỗi component có usage note, props list, variant list, và ví dụ code snippet.

**Kết quả đạt được:**
- [x] Atomic, Molecule, Organism components đầy đủ
- [x] Color token system nhất quán với design system
- [x] Dark mode variants documented

**Thời gian thực tế:** ~5 giờ

---

### [DA-144] — Draw user flow diagrams for 3 main flows

**Jira status:** In Review  
**Branch:** `docs/DA-144-userflow-diagrams`  
**Commit chính:** `0ad72d9` — `docs(DA-144): Create 3 main user flows UX-layer`  
**File tạo ra / thay đổi:**
- `docs/wireframe/brandhub_flows_Report.md` — 3 flows: content creation, approval, publishing

**Mô tả công việc đã làm:**

Vẽ 3 user flow diagrams: (1) Content Creation Flow (Creator tạo post → submit → approve → schedule → publish), (2) Content Request Flow (Client tạo request → Manager assign → Creator làm → Review → Approve), (3) Social Account Connection Flow (OAuth connect → callback → token store). Mỗi flow có happy path + error paths + role actor rõ ràng.

**Kết quả đạt được:**
- [x] 3/3 flows hoàn thành với error paths
- [x] Đồng nhất với endpoint definitions trong DA-E07-01

**Thời gian thực tế:** ~4 giờ

---

### [DA-157] — Wireframe Client Portal

**Jira status:** Done  
**Branch:** Included trong DA-192 branch  
**File tạo ra / thay đổi:**
- Nằm trong `docs/wireframe/DA-E08-01_Wireframe_Report.md` — Section Client Portal

**Mô tả công việc đã làm:**

Thiết kế Client Portal với 3 views: read-only Content Calendar (xem lịch đăng), Approval View (xem post, approve/reject với comment), Analytics View (basic stats cho client). Portal hoàn toàn isolated — không có sidebar workspace, chỉ có navigation cơ bản của client.

**Kết quả đạt được:**
- [x] Read-only calendar view
- [x] Approve/reject flow với comment box
- [x] Mobile-friendly layout

**Thời gian thực tế:** ~2 giờ (gộp trong DA-192)

---

### [DA-405] — Create local document website

**Jira status:** Done  
**Branch:** `docs/DA-409-integrated-view-document-html`  
**Commit chính:** `dc25f31` — tích hợp VitePress viewer  
**File tạo ra / thay đổi:**
- `frontend/` — VitePress site serving docs
- `frontend/docs-tree.json` — Tree structure for navigation
- `frontend/generate-tree.js` — Script tự động generate tree từ filesystem

**Mô tả công việc đã làm:**

Setup VitePress site để serve toàn bộ documentation của project tại `localhost:5173`. Viết `generate-tree.js` để auto-scan `docs/` và tạo navigation tree mà không cần manually update. Deploy lên Vercel với SPA routing (`vercel.json` rewrite rules).

**Kết quả đạt được:**
- [x] `npm run docs:dev` serve tất cả docs với hot-reload
- [x] Navigation tree tự động update khi thêm file mới
- [x] Deploy lên Vercel thành công

**Thời gian thực tế:** ~6 giờ

---

## 4. Tasks chưa hoàn thành

*Không có task nào chưa hoàn thành.*

---

## 5. Đóng góp ngoài tasks chính

- Hỗ trợ fix Vercel deployment config (`vercel.json` rewrite rules, base path issue với VitePress)
- Review DA-188 Database Strategy — xác nhận diagram HTML render đúng trong VitePress viewer

---

## 6. Học được gì trong sprint này

1. **VitePress customization:** Học cách override default theme, tạo custom Vue components (`DocsTree.vue`, `HtmlViewer.vue`) để render nested HTML files trong doc site.
2. **shadcn/ui component architecture:** Hiểu rõ hơn về Radix UI primitives bên dưới shadcn/ui — giúp thiết kế wireframe đúng với cách implement thực tế hơn.
3. **RBAC UI patterns:** Cách handle role-based UI không phải chỉ hide/show elements mà còn về navigation structure và data access pattern.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc

Cần có design handoff sớm hơn — Frontend viết wireframe đến cuối Sprint 3 nhưng implementation bắt đầu Sprint 5, khoảng cách 2 sprint khá tốt. Tuy nhiên nên có một buổi review wireframe với Trung để đảm bảo wireframe align với API capabilities.

### 7.2 Về tools

Figma free plan giới hạn số người xem đồng thời — nên export PDF snapshot để team members không có Figma account vẫn xem được.

### 7.3 Đề xuất cho Sprint tiếp theo

- Nên setup Storybook ngay trong Sprint 4 song song với infrastructure — có component docs từ sớm giúp implement nhanh hơn trong Sprint 5+

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 5/5 | Tất cả tasks done/in review trước deadline |
| Chất lượng deliverable | 4/5 | Wireframe đủ chi tiết, mobile views có thể chi tiết hơn |
| Giao tiếp với team | 4/5 | Cần chủ động hơn khi cần input từ Trung về API spec |
| Chủ động xử lý blocker | 4/5 | Fix Vercel deployment issue tự xử lý được |
| **Tổng** | **17/20** | |

---

*Nộp: 2026-06-27 | Sprint 3 ends: 2026-06-30*

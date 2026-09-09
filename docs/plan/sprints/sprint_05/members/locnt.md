# Sprint 5 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Thành Lộc |
| GitHub | [@locnt] |
| Role | Frontend / AI Infra |
| Sprint | Sprint 5 |
| Ngày nộp | 28/07/2026 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-E34-01 | [DA-367](https://letritrung2605.atlassian.net/browse/DA-367) | Setup shadcn/ui + Tailwind CSS + custom design tokens trong web-dashboard | 🔴 Critical | 🟢 Done |
| DA-E34-02 | [DA-303](https://letritrung2605.atlassian.net/browse/DA-303) | Build common components: Button, Input, Modal, Toast, Table, Badge, Spinner, Dropdown | 🔴 Critical | 🟢 Done |
| DA-E34-03 | [DA-319](https://letritrung2605.atlassian.net/browse/DA-319) | Build layout components: Sidebar, Navbar, PageWrapper, AuthGuard | 🔴 Critical | 🟢 Done |
| DA-E34-04 | [DA-336](https://letritrung2605.atlassian.net/browse/DA-336) | Setup API service layer (Axios instance + interceptors + token refresh) | 🔴 Critical | 🟢 Done |
| DA-E34-05 | [DA-353](https://letritrung2605.atlassian.net/browse/DA-353) | Setup Zustand stores (authStore, workspaceStore, notificationStore) | 🔴 Critical | 🟢 Done |
| DA-E47-23 | [DA-447](https://letritrung2605.atlassian.net/browse/DA-447) | Write individual sprint report for Sprint 4 — Lộc | 🟢 Medium | 🟢 Done |
| DA-E47-30 | [DA-454](https://letritrung2605.atlassian.net/browse/DA-454) | Write individual sprint report for Sprint 5 — Lộc | 🟢 Medium | 🟢 Done |
| DA-E48-04 | [DA-540](https://letritrung2605.atlassian.net/browse/DA-540) | Review all member reports + write team ITERATION_REPORT for Iteration 1 | 🟢 Medium | 🟢 Done |
| DA-E48-05 | [DA-541](https://letritrung2605.atlassian.net/browse/DA-541) | Finalize and commit Iteration 1 report to brandhub-infrastructure | 🟢 Medium | 🟢 Done |
| DA-AI04-99-05 | [DA-571](https://letritrung2605.atlassian.net/browse/DA-571) | Design hybrid database schema (ChromaDB + Neo4j NER Graph) | 🔴 Critical | 🟢 Done |
| DA-AI04-99-06 | [DA-572](https://letritrung2605.atlassian.net/browse/DA-572) | Design Redis cache & Neo4j upsert flow | 🟡 High | 🟢 Done |

**Tổng:** 11 tasks | Done: 11 | In Review: 0 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

### I. Frontend & Design System (Epic E34)

#### 1. DA-E34-01 — Setup shadcn/ui + Tailwind CSS + custom design tokens trong web-dashboard
- **Mục tiêu:** Thiết lập nền tảng Design System đồng bộ về màu sắc, kiểu chữ và khoảng cách trong ứng dụng Frontend.
- **Công việc đã làm:**
  - Khởi tạo thư viện `shadcn/ui` trong dự án React + Vite + TypeScript, cấu hình tệp `components.json`.
  - Cấu hình Tailwind CSS mở rộng với hệ màu của BrandHub: primary (`#3B82F6`), secondary (`#8B5CF6`), success (`#10B981`), warning (`#F59E0B`), danger (`#EF4444`).
  - Thiết lập font chữ chủ đạo `Inter` với đầy đủ thang kích thước chuẩn (`xs` đến `3xl`).
  - Hỗ trợ chế độ Dark Mode thông qua cấu hình `class` của Tailwind và tích hợp `ThemeProvider`.
- **Tệp tin ảnh hưởng:**
  - `web-dashboard/components.json`
  - `web-dashboard/tailwind.config.ts`
  - `web-dashboard/src/globals.css`
  - `web-dashboard/src/components/theme-provider.tsx`

#### 2. DA-E34-02 — Build common components
- **Mục tiêu:** Cung cấp bộ UI primitives tái sử dụng được gán kiểu TypeScript đầy đủ.
- **Công việc đã làm:**
  - Phát triển các component cốt lõi kế thừa từ primitives của `shadcn/ui`:
    - **Button:** Tích hợp các biến thể `primary`, `secondary`, `outline`, `ghost`, `danger`, hỗ trợ loading và disabled.
    - **Input:** Tích hợp label, placeholder, error, và icon hỗ trợ cả controlled & uncontrolled.
    - **Modal:** Quản lý đóng mở bằng callback, thiết lập backdrop, title, body/footer slots.
    - **Toast:** Hook `useToast()` hỗ trợ hiển thị alert với thời gian tự đóng.
    - **Table:** Hỗ trợ phân trang, sắp xếp và loading skeleton.
    - **Badge, Spinner, Dropdown:** Xây dựng đầy đủ kiểu props.
- **Tệp tin ảnh hưởng:** Các component nằm trong `web-dashboard/src/components/ui/`.

#### 3. DA-E34-03 — Build layout components
- **Mục tiêu:** Dựng app shell và hệ thống định tuyến phân quyền (Auth Guard) ở cấp Route.
- **Công việc đã làm:**
  - Xây dựng **Sidebar** collapsible, tự động thu nhỏ trên màn hình vừa, tích hợp bộ chọn workspace.
  - Xây dựng **Navbar** hiển thị breadcrumb, chuông thông báo và dropdown thông tin user/logout.
  - Xây dựng **AuthGuard** đọc phân quyền từ store để điều hướng chính xác các role (`AGENCY_OWNER`, `BRAND_CLIENT`, `ADMIN`) về dashboard tương ứng, chuyển tiếp user chưa đăng nhập về trang `/login`.
- **Tệp tin ảnh hưởng:**
  - `web-dashboard/src/components/layout/Sidebar.tsx`
  - `web-dashboard/src/components/layout/Navbar.tsx`
  - `web-dashboard/src/components/auth/AuthGuard.tsx`

#### 4. DA-E34-04 — Setup API service layer
- **Mục tiêu:** Cấu hình singleton Axios instance tự động xử lý Access Token và tự động refresh token khi gặp lỗi Authorization 401.
- **Công việc đã làm:**
  - Viết interceptor tự động đính kèm `Authorization: Bearer` vào mỗi request.
  - Xử lý refresh token thông qua endpoint `POST /api/v1/auth/refresh` và tự động thực hiện lại request lỗi.
  - Xử lý queue khi có nhiều request đồng thời bị lỗi 401 cùng lúc để tránh gửi lặp API refresh token.
- **Tệp tin ảnh hưởng:**
  - `web-dashboard/src/lib/axios.ts`

#### 5. DA-E34-05 — Setup Zustand stores
- **Mục tiêu:** Quản lý state toàn cục cho auth, workspace và notification.
- **Công việc đã làm:**
  - Thiết lập `authStore` lưu trữ user, tokens và đồng bộ với `localStorage` qua middleware `persist`.
  - Thiết lập `workspaceStore` lưu trữ danh sách và workspace hiện tại.
  - Thiết lập `notificationStore` lưu trữ danh sách thông báo và số lượng chưa đọc.
- **Tệp tin ảnh hưởng:** Các store nằm trong `web-dashboard/src/store/`.

---

### II. AI Database & Storage Flow (Epic AI-04)

#### 1. DA-AI04-99-05 — Thiết kế cấu trúc cơ sở dữ liệu lai (ChromaDB + Neo4j NER Graph Schema)
- **Mục tiêu:** Thiết kế sơ đồ dữ liệu (Schema) và cơ chế liên kết đồng bộ giữa Vector DB (ChromaDB) và Graph DB (Neo4j) đối với dữ liệu tri thức chi tiết của xu hướng.
- **Công việc đã làm:**
  - Thiết kế Schema lưu trữ trong ChromaDB: Cấu trúc ID, nội dung document, cấu hình mô hình embedding `all-MiniLM-L6-v2` và các trường metadata như `trendName` để hỗ trợ lọc nhanh.
  - Thiết kế Schema đồ thị tri thức trong Neo4j với các Nodes (`KOL`, `Dish`, `Location`, `Trend`) và Edges quan hệ (`PROMOTED`, `ASSOCIATED_WITH`, `LOCATED_IN`).
  - Thiết kế giải thuật chạy nền (Background Job) để xử lý trùng lặp thực thể (Entity Resolution) giúp gộp các node thực thể tương tự ngữ nghĩa trong Neo4j.
  - Khớp nối liên kết dữ liệu qua vector metadata và đồ thị giúp tối ưu hóa latency truy vấn của luồng GraphRAG dưới 100ms.

#### 2. DA-AI04-99-06 — Thiết kế luồng lưu trữ đệm Redis và Ghi đè kết quả Neo4j (Upsert Flow)
- **Mục tiêu:** Thiết kế cấu trúc dữ liệu lưu đệm trong Redis và viết các truy vấn Cypher ghi đè/tạo mới (Upsert) điểm số xu hướng vào Neo4j.
- **Công việc đã làm:**
  - Thiết kế cấu trúc lưu trữ bảng xếp hạng trend trong Redis dưới dạng Sorted Set (ZSET) với key `trends:vn:{date}:{category}`, sử dụng điểm số xu hướng `final_score` làm score để tự động sắp xếp trên Dashboard, cài đặt TTL 6 giờ.
  - Viết câu lệnh Cypher sử dụng mệnh đề `MERGE` kết hợp `ON CREATE SET` và `ON MATCH SET` để thực hiện upsert dữ liệu Top 10-20 xu hướng vào Neo4j, cập nhật điểm số mà không làm mất lịch sử ngày tạo.
  - Thiết kế luồng ghi ghi song song đồng bộ xuống Redis và Neo4j nhằm tránh bất đồng bộ hiển thị dữ liệu lên API `/ai/trends`.

---

### III. Báo cáo & Tài liệu (Epics E47 & E48)

#### 1. DA-E47-23 — Viết báo cáo cá nhân Sprint 4 — Lộc
- **Mục tiêu:** Hoàn thiện và lưu trữ báo cáo các công việc đã làm trong Sprint 4.
- **Công việc đã làm:**
  - Viết báo cáo cá nhân cho Sprint 4 tại `docs/plan/sprints/sprint_04/members/locnv.md` (hoặc `locnt.md`).
  - Tài liệu hóa chi tiết công việc liên quan đến cài đặt và cấu hình pipeline CI/CD cho `web-dashboard` (task `DA-E10-04`).

#### 2. DA-E47-30 — Viết báo cáo cá nhân Sprint 5 — Lộc
- **Mục tiêu:** Tổng hợp và viết báo cáo cá nhân cho Sprint 5.
- **Công việc đã làm:**
  - Tổng hợp toàn bộ quá trình thiết kế cơ sở dữ liệu lai, luồng cache Redis, và thiết lập hệ thống design tokens trong Sprint 5.
  - Hoàn thiện và lưu trữ báo cáo này tại `docs/plan/sprints/sprint_05/members/locnt.md`.

#### 3. DA-E48-04 — Review báo cáo thành viên + Viết báo cáo Iteration 1 cho team AI
- **Mục tiêu:** Kiểm tra và viết báo cáo tổng hợp chất lượng thực thi của Iteration 1 cho toàn bộ đội ngũ AI.
- **Công việc đã làm:**
  - Đọc và đối soát chéo báo cáo của các thành viên trong nhóm AI đối với Iteration 1, kiểm tra chéo commit log để xác thực tính chính xác.
  - Viết tệp báo cáo chung cho team `iterations/iteration_1/ITERATION_REPORT.md` bao gồm: đánh giá tiến độ (hoàn thành 15 tasks), retrospectives, phân bổ khối lượng công việc, bảng deliverables và kế hoạch hành động tiếp theo.
  - Tổng hợp và đưa ra quyết định kỹ thuật hạ tầng (Lựa chọn API LLM, đánh giá mô hình inpainting) cho các giai đoạn tiếp theo.

#### 4. DA-E48-05 — Đẩy báo cáo Iteration 1 lên nhánh và merge vào develop
- **Mục tiêu:** Thực hiện đẩy và sáp nhập các báo cáo của Iteration 1 vào nhánh phát triển chính.
- **Công việc đã làm:**
  - Khởi tạo branch `docs/ai-iteration-1-report` từ nhánh `develop`.
  - Commit toàn bộ các tệp báo cáo cá nhân và báo cáo team liên quan đến AI Iteration 1.
  - Tạo PR, kiểm tra loại bỏ các text giữ chỗ (placeholder) và sáp nhập thành công vào nhánh `develop`.

---

## 4. Tasks chưa hoàn thành

- Không có. Hoàn thành 100% các task được giao đúng tiến độ.

---

## 5. Đóng góp ngoài tasks chính

- Hỗ trợ các thành viên khác cấu hình môi trường chạy Docker cục bộ để tích hợp chung các dịch vụ.
- Hỗ trợ cài đặt và debug các thư viện Python, xử lý lỗi cài đặt dependency `moto` và `boto3` trên môi trường Windows.

---

## 6. Học được gì trong sprint này

- Nâng cao kinh nghiệm thiết kế cấu trữ lưu trữ và tối ưu hóa truy vấn kết hợp (Hybrid Search) giữa ChromaDB (Vector DB) và Neo4j (Graph DB) phục vụ GraphRAG.
- Hiểu sâu về thiết lập hệ thống lưu trữ đệm bằng Redis Sorted Sets để quản lý bảng xếp hạng hiệu quả và xử lý ghi song song đồng bộ.
- Cải thiện kỹ năng thiết kế UI/UX đồng bộ, kiến trúc phân quyền Auth Guard và singleton API client (Axios Interceptors) trong các dự án React + Vite.
- Quản lý quy trình tài liệu hóa dự án chuyên nghiệp bằng phương pháp đánh giá chéo.

---

## 7. Feedback & Đề xuất

- Cần thiết lập sớm chuẩn hóa Entity Resolution cho Graph DB để tránh phình to và trùng lặp dữ liệu thực thể khi lượng trend tăng lên.
- Nên tổ chức các buổi trao đổi chéo giữa AI team và Frontend team sớm hơn trước khi chốt spec API để việc tích hợp diễn ra trơn tru.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 5/5 | Hoàn thành toàn bộ các task đúng hạn |
| Chất lượng deliverable | 5/5 | Đảm bảo đầy đủ đặc tả thiết kế hệ thống, docker chạy ổn định, code frontend chuẩn hóa |
| Giao tiếp với team | 5/5 | Chủ động thảo luận, thống nhất cấu trúc dự án và hỗ trợ team |
| Chủ động xử lý blocker | 5/5 | Chủ động nghiên cứu giải quyết các bài toán tối ưu hóa latency truy vấn và Entity Resolution |
| **Tổng** | **20/20** | |

---

*Deadline nộp: 2026-07-28*

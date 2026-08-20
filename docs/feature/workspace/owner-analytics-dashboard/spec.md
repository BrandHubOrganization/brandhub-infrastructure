# Spec — Owner/Account Team Analytics Dashboard

## Objective
Sidebar hiện hiển thị "Sáng tạo" (Content Editor, Calendar) cho mọi role kể
cả OWNER — không hợp lý vì OWNER là chủ doanh nghiệp, không trực tiếp tạo nội
dung, chỉ quản lý team + xem hiệu suất. Cần: (1) ẩn mục sáng tạo nội dung
khỏi OWNER, (2) bổ sung nội dung quản lý team (thành viên, hoạt động, hiệu
suất) vào Analytics, (3) OWNER/ACCOUNT quản lý nhiều workspace cần 1 trang
tổng hợp xem toàn bộ workspace của họ cùng lúc.

## User Story
Là OWNER (chủ doanh nghiệp/agency) sở hữu nhiều workspace, tôi muốn:
- Sidebar không hiện các mục tạo nội dung tôi không trực tiếp dùng.
- Xem báo cáo team (thành viên, vai trò, hoạt động gần đây) ngay trong
  Analytics của từng workspace.
- Xem tổng quan tất cả workspace tôi sở hữu/quản lý ở 1 trang riêng, không
  phải chuyển qua lại từng workspace.

Là ACCOUNT (quản lý tài khoản/khách hàng) được giao quản lý nhiều workspace,
tôi cũng cần trang tổng hợp tương tự, nhưng chỉ thấy workspace tôi là thành
viên (không phải "sở hữu").

## Phạm vi (3 phần)

### Phần A — Sidebar: ẩn section Sáng tạo cho OWNER
- Role `OWNER` (MemberRole workspace, không phải business role) → ẩn hoàn
  toàn section "Sáng tạo" (Content Editor + Calendar), không điều kiện theo
  số lượng thành viên.
- Role khác (CREATOR/VIEWER/CLIENT/ACCOUNT) → giữ nguyên hành vi hiện tại,
  không đổi.

### Phần B — Analytics theo workspace (`/analytics`, đã tồn tại): mở rộng
Chỉ hiển thị section mới cho role `OWNER`/`ACCOUNT` (role khác thấy Analytics
như cũ, không đổi):
1. **Bảng thành viên** — email, họ tên, vai trò, ngày tham gia, trạng thái.
   Data thật, tái dùng `workspaceService.listMembers` đã có sẵn.
2. **Số liệu tổng theo role** — tổng số thành viên, đếm theo từng
   `MemberRole` (OWNER/CREATOR/VIEWER/CLIENT/ACCOUNT). Data thật, tính ở
   frontend từ data `listMembers` (không cần API mới).
3. **Hoạt động gần đây (audit log)** — danh sách N hoạt động gần nhất trong
   workspace (ai làm gì, khi nào). **Cần API mới** — xem API Contract.
4. **Hiệu suất/cống hiến nội dung** — số bài đăng, tương tác theo từng
   thành viên. **Mock data** — chưa có module Post/Content trong DB, không
   giả vờ có data thật.

### Phần C — Trang tổng hợp mới `/analytics/overview`
Chỉ role `OWNER`/`ACCOUNT` truy cập được (kiểm tra qua tư cách thành viên ở
ít nhất 1 workspace với role đó — không có "global role" riêng, suy ra từ
danh sách workspace user thuộc về).
1. **Danh sách workspace** user thuộc về với role OWNER/ACCOUNT — tên,
   slug, số thành viên mỗi workspace. Data thật.
2. **Tổng số liệu cộng dồn** — tổng số workspace, tổng thành viên cộng dồn
   (đếm trùng nếu user chung nhiều workspace không quan trọng — đếm theo
   membership record, không dedupe theo email). Data thật, tính ở frontend
   từ data đã fetch.
3. **Hiệu suất/cống hiến mỗi workspace** — mock data, cùng dữ liệu giả với
   Phần B mục 4.
4. **Audit log gộp** nhiều workspace, sắp mới nhất trước. **Cần API mới**
   phức tạp hơn Phần B (nhận list workspaceId).

### Sidebar bổ sung
Thêm mục "Tổng quan" (nav.overview) trỏ `/analytics/overview`, chỉ hiện với
role OWNER/ACCOUNT, đặt trong section "Tổng quan" hiện có (cạnh Dashboard).

## Acceptance Criteria
- OWNER không thấy Content Editor/Calendar trong Sidebar, mọi trường hợp.
- Role khác không bị ảnh hưởng bởi thay đổi Sidebar.
- OWNER/ACCOUNT vào `/analytics` thấy đủ 4 mục mới (bảng, số liệu, audit
  log thật, cống hiến mock). Role khác vào `/analytics` không thấy 4 mục
  này (giữ nguyên UI cũ).
- OWNER/ACCOUNT vào `/analytics/overview` thấy đủ list workspace + tổng số
  liệu + cống hiến mock + audit log gộp thật.
- Role không phải OWNER/ACCOUNT truy cập trực tiếp URL `/analytics/overview`
  → redirect hoặc thông báo không có quyền (không phải blank page/crash).
- User không thuộc workspace nào với role OWNER/ACCOUNT → trang overview
  hiển thị trạng thái rỗng, không lỗi.

## API Contract (mới)

`GET /api/v1/workspaces/{workspaceId}/audit-logs?page=&size=`
- Role required: `OWNER`, `ACCOUNT` (dùng `@RequireRole` có sẵn).
- Response: `ApiResponse<Page<AuditLogResponse>>` —
  `AuditLogResponse{id, userId, userFullName, action, resourceType,
  resourceId, createdAt}`.
- Sắp xếp `createdAt DESC`, phân trang (mặc định size 20).

`GET /api/v1/workspaces/my-managed`
- Trả về danh sách workspace mà current user là thành viên active với role
  `OWNER` hoặc `ACCOUNT`, kèm số lượng thành viên mỗi workspace.
- Response: `ApiResponse<List<ManagedWorkspaceResponse>>` —
  `ManagedWorkspaceResponse{id, name, slug, logoUrl, role, memberCount}`.
- Không cần role check đặc biệt — tự nhiên trả rỗng nếu user không quản lý
  workspace nào.

`GET /api/v1/workspaces/my-managed/audit-logs?page=&size=`
- Gộp audit log từ TẤT CẢ workspace mà current user có role OWNER/ACCOUNT
  (dùng lại danh sách từ endpoint `my-managed`), sắp mới nhất trước, phân
  trang.
- Response: `ApiResponse<Page<AuditLogResponse>>` (thêm field
  `workspaceId`, `workspaceName` so với bản per-workspace, dùng response
  type riêng `ManagedAuditLogResponse`).

## Error Handling
- Audit log query cho workspace user không phải OWNER/ACCOUNT → 403 (qua
  `@RequireRole` sẵn có, không cần code thêm).
- `my-managed`/`my-managed/audit-logs` không throw lỗi khi user không quản
  lý workspace nào — trả mảng rỗng/page rỗng, HTTP 200.
- Phân trang audit log: `page`/`size` không hợp lệ (âm, quá lớn) → dùng
  giá trị mặc định Spring Data `Pageable`, không throw.

## Edge Cases
- User có 0 workspace hoàn toàn (chưa tạo/join gì) → Sidebar không hiện
  mục "Tổng quan" (không phải OWNER/ACCOUNT ở workspace nào).
- User là OWNER 1 workspace, ACCOUNT ở workspace khác → cả 2 xuất hiện
  trong `my-managed`.
- Audit log rỗng (workspace mới tạo, chưa hoạt động gì ngoài tạo) → hiển
  thị "chưa có hoạt động", không lỗi.
- `AuditLog.workspaceId` có thể null (một số action không gắn workspace,
  ví dụ LOGIN) — query audit log theo workspace phải lọc `workspaceId`
  không null và khớp đúng, loại bỏ log không thuộc workspace nào.

## UI States
- Loading: skeleton/`null` return giống pattern các trang hiện có
  (`if (loading) return null;`).
- Audit log table: dùng lại `Table` component đã có (giống
  `WorkspaceMembersPage`).
- Card cống hiến mock: layout giống 4 thẻ stat hiện có trong
  `AnalyticsPage.tsx`, không nêu label "mock" lộ liễu trên UI (theo tinh
  thần landing page hiện có dùng data mẫu tự nhiên) — ghi rõ trong code
  comment là demo data, không phải trên UI.

## i18n
Namespace mới `analytics.team.*` (bảng member, số liệu, audit log) và
`analytics.overview.*` (trang tổng hợp) — thêm đồng thời `vi.json` +
`en.json`, key-parallel. Namespace `nav.overview` cho mục Sidebar mới.

## Light/Dark mode
Tái dùng token đã kiểm chứng trong session (`border-border`, `bg-card`,
`text-muted-foreground`, `bg-brand-orange-soft`, `text-brand-orange`) —
không cần token mới.

## Test Cases (sơ bộ)
1. Login OWNER → Sidebar không có Content Editor/Calendar.
2. Login CREATOR → Sidebar vẫn có Content Editor/Calendar (không đổi).
3. OWNER vào `/analytics` (workspace có 3 member) → bảng hiện đủ 3, số
   liệu tổng đúng.
4. OWNER vào `/analytics` → audit log hiện đúng hoạt động gần nhất
   (test bằng cách trigger 1 action ghi audit log trước, vd invite member).
5. CREATOR vào `/analytics` → không thấy 4 mục mới, giao diện y hệt hiện
   tại.
6. OWNER sở hữu 2 workspace → `/analytics/overview` liệt kê đủ 2, đúng số
   thành viên mỗi cái.
7. User chỉ có role CREATOR ở mọi workspace → `/analytics/overview` từ
   chối truy cập hoặc hiện rỗng đúng nghĩa (không lỗi).
8. Audit log gộp `/analytics/overview` hiện đúng thứ tự thời gian across
   nhiều workspace.
9. Đổi theme dark/light + ngôn ngữ vi/en trên cả 2 trang.

## Definition of Done
- Backend: 2 query method mới (`AuditLogRepository`), 3 endpoint mới
  (`audit-logs`, `my-managed`, `my-managed/audit-logs`), DTO response mới,
  unit test service layer pass.
- Frontend: Sidebar cập nhật, `AnalyticsPage.tsx` mở rộng, trang mới
  `AnalyticsOverviewPage.tsx`, route mới trong `App.tsx`, `tsc`/`eslint`
  sạch.
- i18n key-parallel đầy đủ.
- Verify qua Chrome DevTools theo test.md.

## Out of Scope
- Module Post/Content thật (số liệu cống hiến vẫn mock cho tới khi có
  module đó — ghi rõ trong code không giả vờ là data thật).
- Audit log filter theo action type/date range (chỉ list + phân trang cơ
  bản).
- Xuất báo cáo (export PDF/CSV) — không yêu cầu trong scope này.
- Thay đổi kiến trúc JWT/workspace-scoping hiện tại (route
  `/analytics/overview` tự query theo `userId` từ JWT `sub` claim, không
  cần đổi cách JWT mang `workspaceId`).

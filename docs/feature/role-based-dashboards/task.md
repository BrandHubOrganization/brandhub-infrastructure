# Role-based Dashboards — task

## Backend (brandhub-business-service)
- [x] T1 `TaskDocument.finishedAt`; ghi khi chuyển `FINISHED`, unset khi mở lại (grep mọi chỗ ghi `status`)
- [x] T2 Backfill mongosh `docs/database/migrations/2026-11-23-task-finished-at.js` (idempotent) + seeder set `finishedAt`
- [x] T3 Index Mongo `tasks(workspaceId, finishedAt)`, `tasks(workspaceId, dueDate)`, `posts(workspaceId, status, publishedAt)` nếu chưa có
- [x] T4 `DashboardRange` + unit test (biên kỳ, múi giờ VN, range sai → `VALIDATION_ERROR`)
- [x] T5 `EfficiencyScore` + unit test (đủ thành phần, thiếu thành phần chia lại trọng số, mẫu < 3, reach < 100, tất cả null)
- [x] T6 `DashboardScopeResolver` + unit test (Owner, Manager, Creator, Client, vừa Manager vừa Creator, không thành viên → 403)
- [x] T7 `TaskMetricsAggregator` (1 aggregation `$facet`: counters, trend tuần, workload, blocked, type)
- [x] T8 `PostMetricsAggregator` (theo workspace, theo platform, trend, top 5)
- [x] T9 `FinanceMetricsReader` (spent theo tháng/kind, contractValue, creditsUsed), chỉ gọi khi có OWNER
- [x] T10 `DashboardAnalyticsResponse` (`@JsonInclude(NON_NULL)`) + `DashboardAnalyticsService` (me / agency / workspace, `partialErrors`)
- [x] T11 `DashboardAnalyticsController` `/api/v1/analytics/{me, agencies/{id}, workspaces/{id}}`
- [x] T12 Integration test quyền: JSON Manager/Creator/Client không có `money`/`finance`/`team`; Creator không có `workload`
- [x] T13 Integration test số liệu trên dữ liệu dựng sẵn (onTime, firstPass, completion, published, reach, delta kỳ trước)
- [x] T14 Seed lớn (10 WS × 2.000 task), đo phản hồi ≤ 1,5 s
- [x] T14a `DrillCode` parse/format + unit test (mã sai → 400, workspace ngoài scope → 403)
- [x] T14b `DashboardCriteria`: một criteria cho mỗi metric, dùng chung cho đếm và liệt kê; test `items.total` = số đếm
- [x] T14c `DashboardOverviewService` + `GET .../overview` (kpis, attention, nextUp thứ tự ưu tiên, actionCounts)
- [x] T14d `DashboardItemsService` + `GET .../items` (nhóm theo workspace, phân trang, `allowedActions` từ policy có sẵn, ORDER cho `spent`)
- [x] T14f `DashboardExportService` + `GET .../export.xlsx` (POI, 3 sheet, Owner-only, vi/en) + test
- [x] T14e Task list: param `assignee=me|none|<id>`, `due=overdue|today|week` + test

## Web (brandhub-web)
- [x] T15 `types/dashboardAnalytics.ts`, `services/dashboardAnalyticsService.ts`, query hooks, `useDashboardTab`
- [x] T16 Component chung `components/dashboard/`: RangeSelect, KpiStrip, AttentionStrip, ComparisonTable, ChartCard, ScoreBadge
- [x] T17 Thêm biến thể biểu đồ trong `StatCharts.tsx` (cột chồng, cột ngang, đường nhiều series) theo token theme
- [x] T18 Khối `OwnerAnalytics` (9 khối, gồm Tài chính + Đội ngũ + In báo cáo)
- [x] T19 Khối `ManagerAnalytics` (xếp hạng không có tiền, workload, blocked, trend)
- [x] T20 Khối `CreatorAnalytics`
- [x] T21 Khối `ClientAnalytics`
- [x] T22 Trang agency: tab `RubberSegment`, Tổng quan theo `viewer.sections`, Phân tích ghép khối; xoá `AgencyAnalyticsSection.tsx`
- [x] T23 Tab Phân tích workspace gọi API mới, dùng lại khối vai trò; bỏ phần tính trên trình duyệt
- [x] T24 Trang cá nhân: tab Tổng quan (+KpiStrip) / Phân tích (`PersonalAnalytics.tsx`)
- [x] T25 CSS `@media print` cho tab Phân tích
- [x] T26 Xoá 9 component chết + `useDashboardData.ts` + `pages/analytics/` + `pages/reports/` + `pages/agency/stats.tsx` (grep import trước)
- [x] T27 Redirect `/analytics`, `/reports`, `/agency/:id/stats`; gỡ `reports` khỏi map `Navbar.tsx`
- [x] T28 Cập nhật tour `userHome`, `agencyDashboard`, `workspaceDashboard`
- [x] T29 i18n `dashboard.analytics.*` vi + en; xoá key chết
- [x] T30 Light/Dark + 375px + bàn phím (sort bảng, tab, range)
- [x] T30a `DetailDrawer` (`Sheet`, `?drill=`, Back đóng, nhóm workspace, phân trang) + `useDashboardDrill`
- [x] T30b `DrawerTaskRow` thao tác nhẹ: nhận việc, đổi người, Bắt đầu, dời hạn, Gửi duyệt; Duyệt → màn duyệt
- [x] T30c `QuickActions` theo bảng vai trò + `WorkspacePickerPopover` + quy tắc không lặp số
- [x] T30d `NextUpCard` (Manager/Creator/Owner khi có việc; Client: chờ bạn duyệt)
- [x] T30e Biểu đồ: `onPointClick`, legend bật/tắt, tooltip khi focus, bảng `sr-only`
- [x] T30f Mọi ô số/hàng bảng/dòng Cần chú ý bấm được theo "Bản đồ tương tác"
- [x] T30g `useDashboardLiveRefresh` (socket, debounce 3 s, throttle 10 s) + "Cập nhật lúc"
- [x] T30i Nút Xuất Excel (Owner) cạnh nút In; tải file qua blob, hiện trạng thái đang tải
- [x] T30j Trạng thái trống từng khối: lý do + nút hành động (Tạo việc / Đổi sang 90 ngày / Kết nối mạng xã hội)
- [x] T30k Nút "Tiếp tục ở…" lấy từ `agencyStore`, ẩn khi agency không còn trong danh sách
- [x] T30h Trang Việc: đọc/ghi URL `status`, `type`, `assignee`, `due`; thêm bộ lọc Người làm + Hạn

## Kiểm tra
- [x] T31 `mvn clean test`, `tsc --noEmit`, vitest (cwd `D:\` chữ hoa)
- [x] T32 Chạy backfill trên Mongo local; E2E trình duyệt theo test.md với 4 vai trò
- [x] T33 Mobile: gọi 3 endpoint cũ, so JSON trước/sau không đổi

Trạng thái 2026-11-24: xong. Commit (chưa push): business `07bbe0c3`, web `69dc20b2` trên branch
`feature/DA-1274-role-based-dashboards`. `mvn clean test` 2183 pass (0 fail); vitest 412 pass; `tsc` sạch.
- AC17: 10 WS × 2.000 task, 90 ngày → 224 ms (`DashboardPerformanceTest`, chạy với `DASHBOARD_PERF_MONGO`).
- E2E Playwright 4 vai trò (Owner/Manager/Creator/Client): ô số = tổng ngăn kéo, Back đóng ngăn kéo, 0 lỗi console/API,
  không tràn ngang ở 390px, chụp sáng + tối.
- Backfill chỉ chạy trên Mongo docker local (9 task, chạy lại = 0). **Atlas chưa chạy** (chủ dự án quyết định).
- T33: service/DTO của 3 endpoint mobile không đổi, không serialize `TaskDocument`.

# Role-based Dashboards — plan

## Nguồn dữ liệu
| Chỉ số | Nguồn | Trường |
|---|---|---|
| Task | Mongo `tasks` | `workspaceId, status, dueDate, finishedAt (mới), approvalRound, assigneeId, type, lastSubmission.submittedAt, createdAt` |
| Bài đăng | Mongo `posts` | `workspaceId, status, publishedAt, platform/platformData.*, reachCount, reactionCount, commentCount, shareCount, savedCount` |
| Đã chi | Postgres `billing_orders` | `agency_id, kind, status, amount, paid_at` |
| Giá trị hợp đồng | Postgres `workspace_media_packages` | `workspace_id, final_terms->>'budgetAmount', approved_by_client_at` |
| Credit đã dùng | Postgres `workspace_credit_usage` + `credit_usage_periods` | `agency_id, workspace_id, period_id, used` |
| Phạm vi vai trò | Postgres `agencies` (owner), `agency_members`, `workspace_members` | role, trạng thái active |
| Đội ngũ | `AgencyService.getStats` (tái dùng) | `membersByRole, memberGrowthByMonth` |

## DB / dữ liệu
- **Mongo `tasks.finishedAt`** (Instant, mới).
  - Ghi tại điểm chuyển sang `FINISHED`: `TaskApprovalService` (~dòng 181, `.set("status","FINISHED")`).
  - `unset` khi task bị mở lại từ `FINISHED` (nhánh `!approved && FINISHED`, ~dòng 286).
  - Thêm trường vào `TaskDocument`.
  - Builder grep lại mọi chỗ ghi `status` của collection `tasks` trước khi sửa. Nếu có đường khác ra `FINISHED`
    thì ghi luôn ở đó.
- **Backfill** (mongosh, chạy một lần, idempotent): task `FINISHED` chưa có `finishedAt` →
  `lastSubmission.closedAt`, không có thì `updatedAt`. Script: `docs/database/migrations/2026-11-23-task-finished-at.js`.
  Seeder `MongoDataSeeder` set `finishedAt` cho task demo `FINISHED`.
- **Index Mongo** (khai báo trong schema guard tương ứng; kiểm tra index đã có, không tạo trùng):
  - `tasks { workspaceId: 1, finishedAt: -1 }`
  - `tasks { workspaceId: 1, dueDate: 1 }`
  - `posts { workspaceId: 1, status: 1, publishedAt: -1 }`
- Postgres: **không đổi schema.**

## Business service
Package mới `service/analytics/dashboard/`. `AnalyticsOverviewService` cũ giữ nguyên cho mobile.

- `DashboardRange` (record): parse `7D|30D|90D` → `from, to, previousFrom, previousTo`, zone `Asia/Ho_Chi_Minh`.
- `DashboardScopeResolver`: `(user, agencyId)` → `Scope { sections, ownerWorkspaceIds, managerWorkspaceIds,
  creatorWorkspaceIds, clientWorkspaceIds }`.
  - Owner agency → mọi workspace active.
  - Dùng lại repository membership có sẵn, không viết logic quyền mới.
  - Không thuộc agency → `FORBIDDEN`.
  - Tầng workspace: resolve 1 workspace, dùng lại check quyền xem workspace hiện có.
- `TaskMetricsAggregator`: một Mongo aggregation `$facet` trên tập `workspaceIds` (+ `assigneeId` cho khối
  Creator), khoảng `R ∪ R'`. Trả counters thô, không tính tỷ lệ ở đây. Các facet:
  - counters theo workspace: finished, onTime, firstPass, dueInRange, dueFinished, overdue, theo trạng thái
  - trend tuần: `$dateTrunc` unit week, startOfWeek monday, timezone VN
  - workload theo `assigneeId`
  - blocked (limit 10)
  - breakdown theo `type`
- `PostMetricsAggregator`: `posts` `PUBLISHED`, `publishedAt ∈ R ∪ R'`. Trả: theo workspace (published, reach,
  interactions), theo platform, trend tuần, top 5. Bỏ reach của post có `engagementUpdatedAt = null`.
- `FinanceMetricsReader` (JdbcTemplate, chỉ gọi khi có section OWNER): spent theo tháng/kind, contractValue theo
  workspace, creditsUsed theo workspace. `budgetAmount` thiếu → 0.
- `EfficiencyScore` (hàm thuần): tỷ lệ, mẫu tối thiểu, chia lại trọng số. Trọng số là hằng số trong class. Mốc
  engagement đọc `brandhub.analytics.engagement-benchmark` (mặc định 0.05).
- `DashboardAnalyticsService`: `forMe`, `forAgency`, `forWorkspace`. Ghép scope → aggregators → response.
  - Mỗi nguồn phụ bọc try/catch: lỗi thì thêm tên vào `partialErrors`, log warn.
  - Tầng `me`: gom workspaceIds của mọi agency, gọi aggregator **một lần** rồi chia theo agency (không N+1).
- `DashboardAnalyticsResponse` (record lồng nhau, `@JsonInclude(NON_NULL)`) đúng contract spec. Khối không thuộc
  vai trò để `null` nên không ra JSON.
- `DashboardAnalyticsController` `/api/v1/analytics`: `GET /me`, `GET /agencies/{agencyId}`,
  `GET /workspaces/{workspaceId}`, param `range`.
- Cache: không cache server ở bản đầu, web dùng React Query `staleTime 60s`.
  `ponytail:` khi AC17 không đạt mới thêm Caffeine 60s theo key `(userId, scopeId, range)`.
- Giữ nguyên `/api/v1/analytics/overview`, `/api/v1/agencies/{id}/stats`, `/api/v1/workspaces/{id}/dashboard`
  (mobile dùng).

### Tổng quan, ngăn kéo, bộ lọc task (vòng 2)
- `DrillCode` (record + parse/format): `metric[:workspaceId][:dimension=value]`. Parse lỗi → `VALIDATION_ERROR`.
  - Server luôn giao `workspaceId` trong drill với scope của người gọi, ngoài phạm vi → `FORBIDDEN`.
  - Danh sách metric hợp lệ là enum trong code.
- **Một hàm đếm, hai cách dùng.** Mỗi metric có một `Criteria` Mongo (hoặc SQL với tiền) dùng chung cho đếm (trong
  aggregator) và liệt kê (`/items`), đảm bảo `total` = con số (AC20). Đặt trong `DashboardCriteria`.
- `DashboardOverviewService`: ô số theo vai trò, `attention`, `nextUp` (sort ưu tiên ở spec, limit 3),
  `actionCounts`. Agency gần nhất do web tự lấy từ `agencyStore` (không có trong API).
- `DashboardExportService` + `GET /analytics/agencies/{id}/export.xlsx` (chỉ section OWNER, còn lại `FORBIDDEN`).
  - Làm theo cách `TaskExportController` (Apache POI `poi-ooxml` đã có).
  - Dữ liệu lấy từ chính `forAgency(...)`, nên số khớp màn hình.
  - 3 sheet: Xếp hạng workspace / Tài chính / Đội ngũ.
  - Tiêu đề cột theo `lang`. `Content-Disposition` dùng tên file ở spec.
- `DashboardItemsService`: phân trang 20, nhóm theo workspace.
  - Dòng TASK tính `allowedActions` bằng các policy có sẵn: `TaskWorkflowPolicy`, `TaskApprovalPolicy`,
    `TaskWorkflowAccess`. Không viết luật quyền mới.
  - Dòng ORDER (Owner, metric `spent`): từ `billing_orders`.
- Controller: thêm `GET .../overview`, `GET .../items` vào `DashboardAnalyticsController`.
- **Task list** `GET /api/v1/workspaces/{id}/tasks`: thêm `assignee` (`me` → userId, `none` → chưa giao) và `due`
  (`overdue`, `today`, `week`, tính theo múi giờ VN, loại `FINISHED/CANCELLED`). Viết thêm điều kiện vào query
  builder hiện có, không tạo endpoint mới.

## Gateway
Không đổi. Route catch-all `Path=/api/v1/**` đã phủ `/api/v1/analytics/**`.

## Web (brandhub-web)
**Dùng chung** — `src/components/dashboard/`:
- `AnalyticsRangeSelect` (7/30/90, đọc/ghi `?range`), `KpiStrip` (≤4 ô, delta ↑↓)
- `AttentionStrip`
- `ComparisonTable` (sort cột, cột đầu sticky, click hàng → link, "—" khi null)
- `ChartCard` (tiêu đề câu hỏi, skeleton, empty, error + retry)
- `ScoreBadge`
- Biểu đồ: `recharts` (đã cài) qua `components/charts/StatCharts.tsx`. Thêm biến thể còn thiếu: cột chồng, cột
  ngang, đường nhiều series. Màu series lấy từ token theme. Khi code, đọc skill `dataviz` trước.
- `types/dashboardAnalytics.ts`, `services/dashboardAnalyticsService.ts`, query hooks (key gồm userId + scope +
  range).
- Hook `useDashboardTab()`: đọc/ghi `?tab=` và `?range=`.

**Tương tác (vòng 2)** — `src/components/dashboard/`:
- `QuickActions`: nhận `viewer.sections` + `actionCounts` + scope, render bộ nút theo bảng spec.
  `WorkspacePickerPopover` cho nút cần workspace. Cấu hình bộ nút là một mảng hằng trong file (không config hệ
  thống).
- `NextUpCard`: 3 dòng, nút chính gọi API có sẵn (`start`) hoặc điều hướng (Tiếp tục/Sửa → mở task;
  Duyệt → task-approvals).
- `DetailDrawer`: dùng `Sheet` có sẵn trong `components/ui`, đọc/ghi `?drill=`, gọi `/items`, nhóm theo
  workspace, phân trang. `DrawerTaskRow` render `allowedActions`:
  - Đổi người: `member-options` + popover
  - Dời hạn: `<input type="date">`
  - Thành công: invalidate query dashboard
  - Lỗi: `notifyError`
- `useDashboardDrill()`: mở ngăn kéo từ mọi nơi (ô số, bảng, biểu đồ) bằng mã `drill` server trả về.
- `useDashboardLiveRefresh()`: `useNotificationSocket` → debounce 3 s, throttle 10 s → invalidate key
  `["dashboard", ...]`. Kèm `refetchOnWindowFocus` và dòng "Cập nhật lúc".
- Biểu đồ trong `StatCharts.tsx`: thêm prop `onPointClick(drill)`, legend bấm để ẩn/hiện series (state cục bộ,
  không cho ẩn series cuối), tooltip khi focus bàn phím, bảng `sr-only` số liệu.
- `KpiStrip`/`ComparisonTable`: mỗi ô là `<button>` gọi `openDrill`. Ô điều hướng (Credit, Thành viên) là `<Link>`.

**Trang Việc của workspace** — `pages/tasks/hooks/useTasks.ts`:
- Khởi tạo `statusFilter`, `typeFilter`, `assignee`, `due` từ URL.
- Ghi ngược lên URL khi đổi (`replace: true`).
- Thêm 2 bộ lọc Người làm (Tôi / Chưa giao / Tất cả) và Hạn (Quá hạn / Hôm nay / 7 ngày) vào thanh lọc hiện có.
- Giữ `?task=` mở panel như cũ.

**Khối theo vai trò** (`src/components/dashboard/analytics/`): `OwnerAnalytics`, `ManagerAnalytics`,
`CreatorAnalytics`, `ClientAnalytics`. Mỗi khối nhận response + prop `level: "agency" | "workspace"`. Tầng
workspace tự ẩn bảng so sánh.

**Tầng cá nhân** — `pages/dashboard/index.tsx`:
- Thêm tab (`RubberSegment` như workspace).
- Tổng quan = nội dung hiện tại + `KpiStrip`.
- Phân tích = `pages/dashboard/components/PersonalAnalytics.tsx` (mới).

**Tầng agency** — `pages/agency/dashboard/index.tsx`:
- Thay 2 nút tab tự viết bằng `RubberSegment`.
- Tổng quan render theo `viewer.sections`.
- Phân tích render các khối vai trò; xoá `AgencyAnalyticsSection.tsx`.
- Khối Đội ngũ chuyển từ `pages/agency/stats.tsx`.
- Nút In báo cáo + CSS `@media print`: ẩn sidebar/topbar, mỗi `ChartCard` `break-inside: avoid`.

**Tầng workspace** — `WorkspaceAnalyticsTab.tsx` (1.692 dòng) thay bằng file mỏng: gọi
`/analytics/workspaces/{id}` và render khối vai trò. Tab Tổng quan và Xuất bản giữ.

**Xoá** (grep import trước khi xoá; xoá luôn key i18n chỉ các file này dùng):
- `pages/dashboard/components/`: `KpiCardsSection`, `DashboardAdvancedCharts`, `AgencyReportExportModal`,
  `ActivityFeedSection`, `DashboardScopeFilter`, `MyTasksSection`, `SmartPriorityRecommendation`,
  `TeamStatsSection`, `QuickTasksCard`
- `pages/dashboard/hooks/useDashboardData.ts` (chỉ file chết dùng)
- `pages/analytics/`, `pages/reports/`, `pages/agency/stats.tsx`

**Routes** (`routes/AppRoutes.tsx`):
- `/analytics`, `/reports`, `/agency/:id/stats` → `<Navigate>` theo AC11.
- Gỡ `reports` khỏi map trong `Navbar.tsx`.
- Sửa comment nhắc `/analytics` trong `sidebarNavConfig.ts`.

**Tour** (driver.js): cập nhật step `userHome`, `agencyDashboard`, `workspaceDashboard` theo `data-tour` mới. Xoá
step trỏ phần tử đã xoá.

**i18n**: `dashboard.analytics.*` trong `vi/dashboard.json` + `en/dashboard.json` (tiêu đề câu hỏi, tên chỉ số,
trạng thái trống, "Chưa đủ dữ liệu", "tính theo kỳ credit").

## Thứ tự làm
Phần web làm qua skill `/improve-ui` sau khi chủ dự án duyệt tài liệu.

1. Backend: `finishedAt` + backfill + index → `EfficiencyScore` + test → aggregators → scope resolver → service +
   controller + test quyền → `DrillCode` + `DashboardCriteria` + overview + items → lọc task `assignee`/`due`.
2. Web nền: types/service/hooks + component dùng chung + DetailDrawer + QuickActions + NextUpCard + live refresh.
3. Tầng agency: Owner trước (nhiều số liệu nhất để kiểm), rồi Manager → Creator → Client.
4. Tầng workspace (dùng lại khối).
5. Tầng cá nhân.
6. Xoá trang cũ + redirect + tour + i18n.
7. Kiểm tra theo test.md.

## Rủi ro
- Backfill `finishedAt` từ `updatedAt` có thể lệch với task cũ bị sửa sau khi xong, nên `onTimeRate` lịch sử hơi
  sai. Chấp nhận; số từ nay về sau đúng.
- Aggregation 90D×2 = 180 ngày với agency lớn dựa vào index mới. Đo AC17 trên seed lớn rồi mới tính chuyện cache.
- Prod phải chạy backfill Mongo **trước** khi deploy web mới, nếu không `finished` = 0 cho task cũ.

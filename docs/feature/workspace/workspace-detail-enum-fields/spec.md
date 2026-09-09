# Spec — Workspace Detail Fields → Enum Toggle

## Objective
Các trường "detail" của workspace hiện là text input tự gõ, dễ sai chính tả,
không đồng nhất giữa các workspace, không lọc/thống kê được. Chuyển các
trường này sang enum cố định, chọn bằng toggle/button-group thay vì gõ tay —
cùng tinh thần đã áp dụng cho `defaultPlatforms` (feature
`workspace-logo-platform-picker`).

## Phạm vi trường (rà toàn bộ "detail" của workspace)
Rà `CreateWorkspaceRequest`, `UpdateWorkspaceSettingsRequest`,
`WorkspaceSettings` — 2 trường đang là free-text hợp lý để enum hoá:

1. **`industry`** (CreateWorkspacePage, lúc đăng ký workspace) — hiện là
   `String industry` trong `CreateWorkspaceRequest`, **PHÁT HIỆN BUG**: field
   này được frontend gửi lên nhưng `WorkspaceServiceImpl.createWorkspace`
   KHÔNG đọc/lưu nó ở đâu cả — dữ liệu bị mất hoàn toàn. Phải sửa cùng lúc.
2. **`reportFrequency`** (WorkspaceSettingsPage, cài đặt workspace) — hiện
   là `String reportFrequency` tự gõ ("weekly"), nằm trong jsonb
   `workspaces.settings`.

Trường **không đổi** (đã enum-hoá ở feature trước, không lặp lại):
`defaultPlatforms` (đã xong ở `workspace-logo-platform-picker`).

Trường **giữ nguyên text** (không có tập giá trị cố định hợp lý):
`name` (tên workspace), `timezone` (IANA timezone string, danh sách quá dài
cho toggle, giữ input text).

## Enum Values

### Industry (10 giá trị, khớp bộ chuẩn ngành hàng VN)
```
FNB              → "F&B"
FASHION          → "Thời trang"
BEAUTY           → "Làm đẹp"
TECHNOLOGY       → "Công nghệ"
REAL_ESTATE      → "Bất động sản"
EDUCATION        → "Giáo dục"
HEALTHCARE       → "Sức khỏe"
SERVICES         → "Dịch vụ"
RETAIL           → "Bán lẻ"
OTHER            → "Khác"
```
Không bắt buộc (nullable) — giữ đúng hành vi hiện tại (`industry` optional).

### ReportFrequency (2 giá trị)
```
WEEKLY  → "Hàng tuần"
MONTHLY → "Hàng tháng"
```
Không bắt buộc (nullable) — giữ đúng hành vi hiện tại.

## Acceptance Criteria
- CreateWorkspacePage: "Ngành hàng" đổi từ `Input` text sang toggle chọn 1
  trong 10 giá trị `WorkspaceIndustry` (single-select, có thể bỏ chọn — click
  lại giá trị đang chọn để bỏ, gửi `null`).
- WorkspaceSettingsPage: "Tần suất báo cáo" đổi từ `Input` text sang toggle
  chọn 1 trong 2 giá trị `WEEKLY`/`MONTHLY` (single-select, có thể bỏ chọn).
- Backend: `industry` được lưu đúng vào `workspaces.settings` jsonb lúc tạo
  workspace (fix bug mất dữ liệu hiện tại) và đọc lại đúng khi
  `GET /workspaces/{id}`.
- Backend: `industry`/`reportFrequency` validate chỉ nhận giá trị nằm trong
  enum, giá trị khác → 400 `VALIDATION_ERROR`.
- Dữ liệu cũ (workspace đã tạo trước đây với `industry`/`reportFrequency` tự
  do, hoặc `null`) không bị lỗi khi hiển thị — nếu giá trị cũ không khớp
  enum, hiển thị "chưa chọn" (không toggle nào active), không crash UI.

## API Contract (thay đổi)
`POST /api/v1/workspaces` — `CreateWorkspaceRequest.industry` đổi type từ
`String` sang enum string, validate bằng `@Pattern` hoặc Jackson enum
deserialize (xem plan.md).

`PATCH /api/v1/workspaces/{id}/settings` — `UpdateWorkspaceSettingsRequest
.reportFrequency` đổi type tương tự.

Response `WorkspaceResponse`/`WorkspaceSettings` — `industry`,
`reportFrequency` trả về string enum name (`"FNB"`, `"WEEKLY"`), frontend tự
map sang label hiển thị qua i18n.

## Error Handling
- Gửi giá trị enum không hợp lệ (vd `"industry": "abc"`) → 400, message rõ
  ràng liệt kê giá trị hợp lệ.
- Giá trị cũ trong DB (nếu có, từ trước khi enum hoá) không parse được vào
  enum lúc đọc → không throw lỗi, trả về `null` cho field đó (an toàn ngược,
  không phá dữ liệu cũ).

## UI States
- Toggle button giống pattern platform picker: viền/nền `brand-orange` khi
  active, `border-border`/`text-muted-foreground` khi không active.
- Layout: `flex flex-wrap gap-2` (industry 10 mục cần wrap nhiều dòng).

## i18n
Namespace mới `workspace.industry.*` (10 key, 1 key/enum value) và
`workspace.reportFrequency.*` (2 key: `weekly`, `monthly`) — thêm đồng thời
`vi.json` + `en.json`, key-parallel.

Ví dụ:
```
workspace.industry.FNB = "F&B" (vi) / "F&B" (en)
workspace.industry.FASHION = "Thời trang" (vi) / "Fashion" (en)
...
workspace.reportFrequency.WEEKLY = "Hàng tuần" (vi) / "Weekly" (en)
workspace.reportFrequency.MONTHLY = "Hàng tháng" (vi) / "Monthly" (en)
```

## Light/Dark mode
Tái dùng đúng token đã kiểm chứng ở platform picker
(`border-brand-orange`, `bg-brand-orange-soft`, `text-brand-orange`,
`border-border`, `text-muted-foreground`) — không cần token mới.

## Test Cases (sơ bộ)
1. Tạo workspace mới, chọn industry "F&B" → `GET /workspaces/{id}` trả về
   `settings.industry: "FNB"`.
2. Tạo workspace không chọn industry → `settings.industry: null`, không lỗi.
3. Gửi trực tiếp API với `industry: "INVALID"` → 400.
4. WorkspaceSettingsPage: chọn "Hàng tháng", lưu → PATCH gửi
   `reportFrequency: "MONTHLY"`, load lại trang hiển thị đúng toggle active.
5. Click lại industry đang active → bỏ chọn, lưu → `industry: null`.
6. Workspace cũ có `settings.industry` không hợp lệ (giả lập set thẳng DB
   `"abc"`) → trang hiển thị không toggle nào active, không crash.
7. Đổi theme dark/light, đổi ngôn ngữ vi/en trên cả 2 trang.

## Definition of Done
- Backend: `WorkspaceIndustry`, `ReportFrequency` enum mới, DTO cập nhật,
  `createWorkspace` lưu đúng `industry` (fix bug), `mvn compile`/`test` pass.
- Frontend: 2 trang đổi input→toggle, `tsc`/`eslint` sạch.
- i18n key-parallel.
- `docs/feature/workspace/workspace-logo-platform-picker/` không đổi (đã
  xong, không thuộc scope này).

## Out of Scope
- `timezone`, `name` — giữ nguyên text input (lý do nêu ở mục Phạm vi).
- Cho phép multi-select industry (chỉ 1 workspace = 1 ngành hàng, theo đúng
  nghiệp vụ hiện tại `Client.industry` cũng là single string).
- Migration dữ liệu cũ trong DB (không có dữ liệu production thật ở giai
  đoạn dev này).

# Test — Workspace Detail Fields → Enum Toggle

## Backend
| Case | Input | Expected |
|---|---|---|
| createWorkspace fix bug | `industry: "FNB"` | `GET /workspaces/{id}` → `settings.industry: "FNB"` (trước đây luôn null do bug) |
| createWorkspace không chọn industry | `industry: null`/omit | `settings.industry: null`, không lỗi |
| createWorkspace industry sai | `industry: "INVALID"` | 400, không phải 500 |
| updateSettings reportFrequency hợp lệ | `reportFrequency: "MONTHLY"` | `settings.reportFrequency: "MONTHLY"` |
| updateSettings reportFrequency sai | `reportFrequency: "sometimes"` | 400 |
| Đọc settings jsonb cũ có giá trị lạ | DB set thẳng `{"industry":"abc"}` | `GET` trả `industry: null`, không 500 |

## Frontend Manual (Chrome DevTools)
1. Vào `/workspace/create`, thấy 10 toggle ngành hàng thay vì input text.
2. Click "F&B" → active (viền cam). Click lại → bỏ active.
3. Chọn "F&B", submit → Network tab: `POST /workspaces` body có
   `industry: "FNB"`.
4. Không chọn ngành hàng nào, submit → body `industry` là `undefined`/omit,
   không lỗi 400.
5. Vào lại `/workspace/:id/settings` của workspace vừa tạo với industry
   "F&B" — (nếu spec.md không yêu cầu hiển thị industry ở settings page thì
   bỏ qua bước này, xác nhận lại phạm vi UI trước khi test).
6. WorkspaceSettingsPage: thấy 2 toggle "Hàng tuần"/"Hàng tháng" thay input
   text. Chọn "Hàng tháng", lưu → Network tab: `PATCH .../settings` body có
   `reportFrequency: "MONTHLY"`.
7. F5 lại trang — toggle "Hàng tháng" vẫn hiển thị active (đọc đúng từ
   backend).
8. Đổi theme dark/light trên cả 2 trang — toggle đọc được, không vỡ màu.
9. Đổi ngôn ngữ vi/en — label enum đổi theo (VD "F&B"→"F&B", "Thời trang"→
   "Fashion").
10. `npx tsc --noEmit`, `npx eslint` trên file đã sửa: 0 lỗi.

## Pass Criteria
Tất cả case PASS. Case "createWorkspace fix bug" đặc biệt quan trọng — xác
nhận bug cũ (industry luôn mất) đã hết, không chỉ xác nhận enum hoạt động.

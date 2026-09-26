# Task — Save Workspace Template (FR 3.4.17)

> Checklist triển khai theo [plan.md](plan.md). ⚠ BA conflict phát hiện khi đọc code thật lần này: `WorkspaceTemplateServiceImpl` mọi method đều là stub `throw new UnsupportedOperationException`. Checklist dưới đây được sửa lại để phản ánh đúng — các dòng trước đó đánh `[x]` cho backend logic là sai so với code thật.

## Backend — `brandhub-business-service`

- [x] `WorkspaceTemplateController` — 4 route (`POST` / `GET` list / `GET` detail / `DELETE`) đã khai báo đúng contract
- [ ] `POST /api/v1/workspace-templates` — tạo Template — **chưa implement** (`saveTemplate` throw `UnsupportedOperationException`)
- [ ] `GET /api/v1/workspace-templates` — danh sách Template — **chưa implement**
- [ ] `GET /api/v1/workspace-templates/{templateId}` — chi tiết Template — **chưa implement**
- [ ] `DELETE /api/v1/workspace-templates/{templateId}` — xóa Template — **chưa implement**
- [ ] 400 `VALIDATION_ERROR` (name/configSnapshot trống), 404 `NOT_FOUND` (detail/delete) — chưa thể verify vì logic chưa tồn tại

## Frontend — `brandhub-web-dashboard`

- [x] "Save as Template" modal trong `detail.tsx` — gọi `workspaceTemplateService.save`
- [x] `templates.tsx` list page tại `/workspaces/templates` — inline expand xem `configSnapshot`, nút xóa
- [ ] Không có FE nào hoạt động được thật cho tới khi backend implement xong (mọi request sẽ lỗi 500 `UnsupportedOperationException`)

## Chưa xác nhận

- [ ] `@RequireRole` giới hạn quyền theo Agency/role — spec.md tự ghi nhận chưa double-check với BE, cần xác nhận lại (xem plan.md mục 6)
- [ ] Ai/khi nào sẽ implement `WorkspaceTemplateServiceImpl` — cần team xác nhận lịch

## Verify

- [ ] `mvn test` — **không xác nhận được là "pass"** với code hiện tại (stub throw exception); dòng "pass" trước đó trong tài liệu là sai so với code thật, đã sửa.

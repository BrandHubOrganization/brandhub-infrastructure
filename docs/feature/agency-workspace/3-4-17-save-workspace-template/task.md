# Task — Save Workspace Template (FR 3.4.17)

> Checklist triển khai theo [plan.md](plan.md). Không có thay đổi code trong lần đồng bộ này — chỉ đồng bộ spec.md/sequence-flow.md theo code thật đã có sẵn.

## Backend — `brandhub-business-service`

- [x] `POST /api/v1/workspace-templates` — tạo Template, `agencyId`/`createdBy` tự set theo currentUser
- [x] `GET /api/v1/workspace-templates` — danh sách Template
- [x] `GET /api/v1/workspace-templates/{templateId}` — chi tiết Template
- [x] `DELETE /api/v1/workspace-templates/{templateId}` — xóa cứng Template
- [x] 400 `VALIDATION_ERROR` (name/configSnapshot trống), 404 `NOT_FOUND` (detail/delete)

## Chưa xác nhận

- [ ] `@RequireRole` giới hạn quyền theo Agency/role — spec.md tự ghi nhận chưa double-check với BE, cần xác nhận lại (xem plan.md mục 6)

## Verify

- [x] `mvn test` pass (create/list/detail/delete happy path, validation, not-found)

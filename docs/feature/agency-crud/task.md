# Task Checklist — Agency Owner Client Management

## DA-E16-01 — POST /api/v1/clients
- [x] DTO Validation (`brandName`, `industry`, `contactEmail`, `allowedPlatforms`).
- [x] Xử lý lấy `workspaceId` từ JWT Security Context.
- [x] Logic query Subscription Plan limit của Workspace & đếm số Client hiện tại.
- [x] Check limit client + insert trong `@Transactional`.
- [x] Controller Endpoint `POST /api/v1/clients` (Return 201 / 403).

## DA-E16-02 — PUT /api/v1/clients/{id}/assign
- [x] Endpoint `PUT /api/v1/clients/{id}/assign` với RBAC `AGENCY_OWNER`.
- [x] Check target `accountManagerId` (exist in workspace & role = ACCOUNT_MANAGER).
- [x] Query Client theo `{id}` + `workspaceId` (tránh leak info, return 404 nếu không khớp).
- [x] Cập nhật AM & trigger Email Notification gửi cho AM.

## DA-E16-03 — PUT /api/v1/clients/{id}/service-package
- [x] Endpoint `PUT /api/v1/clients/{id}/service-package`.
- [x] Validate `monthlyPostLimit > 0` và `allowedPlatforms` subset enum hợp lệ.
- [x] Cập nhật thông tin gói dịch vụ client.

## DA-E16-04 — GET /api/v1/clients
- [x] Endpoint `GET /api/v1/clients` hỗ trợ pagination (`page`, `size`).
- [x] Query filter theo Role (`AGENCY_OWNER` vs `ACCOUNT_MANAGER`).
- [x] Filter động với JPA Specification / CriteriaBuilder (`search`, `platform`).
- [x] Chặn role `BRAND_CLIENT` (403).

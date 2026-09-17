# Test Cases — Agency Owner Client Management

| # | Feature | Scenario / Input | Expected Result | Pass |
|---|---|---|---|---|
| 1 | POST /api/v1/clients | AGENCY_OWNER tạo client hợp lệ, chưa quá limit | 201 Created + client document chứa workspaceId từ JWT | ☑ |
| 2 | POST /api/v1/clients | Role khác AGENCY_OWNER gửi request | 403 Forbidden | ☑ |
| 3 | POST /api/v1/clients | Đã đạt / vượt client limit của Subscription Plan | 403 Forbidden { error: "Client limit reached", upgradeUrl } | ☑ |
| 4 | PUT /clients/{id}/assign | Assign AM hợp lệ cùng workspace | 200 OK + updated client + email notification gửi đi | ☑ |
| 5 | PUT /clients/{id}/assign | `accountManagerId` thuộc workspace khác hoặc role sai | 400 Bad Request | ☑ |
| 6 | PUT /clients/{id}/assign | `{id}` client thuộc workspace khác | 404 Not Found | ☑ |
| 7 | PUT /clients/{id}/service-package | `monthlyPostLimit` <= 0 hoặc platform không hợp lệ | 400 Bad Request | ☑ |
| 8 | PUT /clients/{id}/service-package | Gửi dữ liệu hợp lệ bởi AGENCY_OWNER | 200 OK + updated record | ☑ |
| 9 | GET /api/v1/clients | AGENCY_OWNER call endpoint | 200 OK + danh sách tất cả clients trong workspace | ☑ |
| 10 | GET /api/v1/clients | ACCOUNT_MANAGER call endpoint | 200 OK + chỉ danh sách client được assign cho AM đó | ☑ |
| 11 | GET /api/v1/clients | BRAND_CLIENT call endpoint | 403 Forbidden | ☑ |

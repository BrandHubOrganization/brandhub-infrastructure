## 1. DA-E16-01: Create Client (`POST /api/v1/clients`)

- **Role**: `AGENCY_OWNER` (Khác role -> 403).
- **Request Body**: `{ brandName, industry, logoUrl, contactEmail, allowedPlatforms }`
- **Response**: `201 Created` kèm client document.
- **Logic**:
  - Inject `workspaceId` từ JWT.
  - Đếm client hiện tại trong Workspace vs `maxClients` của gói Subscription active. Nếu vượt giới hạn -> `403 Forbidden` (`{ error: "Client limit reached", upgradeUrl }`).
  - Transaction/Optimistic lock khi check count + insert client.

---

## 2. DA-E16-02: Assign Account Manager (`PUT /api/v1/clients/{id}/assign`)

- **Role**: `AGENCY_OWNER` (Khác role -> 403).
- **Request Body**: `{ accountManagerId }`
- **Response**: `200 OK` kèm updated client document.
- **Logic**:
  - `accountManagerId` phải thuộc cùng `workspaceId` và có role `ACCOUNT_MANAGER` (Sai -> 400 Bad Request).
  - Client `{id}` phải thuộc `workspaceId` của caller (Mismatched -> 404 Not Found).
  - Gửi email thông báo cho Account Manager được gán.

---

## 3. DA-E16-03: Update Service Package (`PUT /api/v1/clients/{id}/service-package`)

- **Role**: `AGENCY_OWNER` (Khác role -> 403).
- **Request Body**: `{ monthlyPostLimit, allowedPlatforms }`
- **Response**: `200 OK` kèm updated client document.
- **Logic**:
  - `monthlyPostLimit` phải là số nguyên dương (> 0, sai -> 400).
  - `allowedPlatforms` là danh sách không rỗng subset của `{FACEBOOK, INSTAGRAM, TIKTOK, THREADS, ZALO}` (sai -> 400).
  - Client `{id}` phải thuộc `workspaceId` của caller (khác -> 404).

---

## 4. DA-E16-04: Get Client List (`GET /api/v1/clients`)

- **Role**: `AGENCY_OWNER` và `ACCOUNT_MANAGER` (`BRAND_CLIENT` -> 403).
- **Query Params**: `page` (default 0), `size` (default 20, max 100), `search` (brandName partial match), `platform` (filter allowedPlatforms).
- **Response**: `200 OK` kèm paginated list.
- **Logic**:
  - `AGENCY_OWNER`: Xem toàn bộ client trong `workspaceId`.
  - `ACCOUNT_MANAGER`: Chỉ xem client có `assignedAccountManagerId == currentUserId`.

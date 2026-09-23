# Sequence Flow — View Client Profile

> Bổ sung cho `spec.md` (FR 3.3.3). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`ClientProfileController`, `ClientProfileServiceImpl`).

## Actors

- **User** — người dùng đang đóng vai trò Client ở 1 Workspace của 1 Agency.
- **FE** — brandhub-web-dashboard (React), trang `/client-profile`.
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (bảng `client_profiles`).

---

## Quan trọng — ClientProfile khoá theo (userId, agencyId), KHÔNG global

Khác với mô tả "1 Client Profile dùng chung xuyên mọi Agency" ở mức khái niệm nghiệp vụ, bản ghi DB thật được khoá theo **cặp (userId, agencyId)** (`ClientProfileRepository.findByUserIdAndAgencyId`). Nghĩa là:

- 1 User làm Client ở Agency A và Agency B → **2 bản ghi `ClientProfile` riêng biệt** (1 cho mỗi agency), không phải 1 bản ghi dùng chung toàn hệ thống.
- "Tái sử dụng" chỉ đúng trong phạm vi **cùng 1 Agency**: nếu User đã là Client ở 1 Workspace của Agency A, khi được mời vào Workspace khác **cùng Agency A**, hệ thống dùng lại đúng `ClientProfile(userId, agencyId=A)` đó (không tạo bản ghi mới).
- Nếu User được mời làm Client ở Agency B (khác Agency A) → phải có `ClientProfile(userId, agencyId=B)` riêng, độc lập hoàn toàn với bản ở Agency A (khác `displayName`, `company`... nếu User muốn).

## Flow A — Xem Client Profile (trong 1 Agency cụ thể)

1. User → FE: mở trang `/client-profile`, FE xác định `agencyId` hiện tại (theo Workspace/Agency đang chọn).
2. FE → BE: `GET /api/v1/client-profile/me?agencyId={agencyId}`.
3. BE (`ClientProfileController.getMyProfile` → `ClientProfileServiceImpl.getMyProfile`):
   a. Lấy `currentUser.getId()` từ token.
   b. BE → DB: `clientProfileRepository.findByUserIdAndAgencyId(userId, agencyId)` — không có bản ghi → `404 CLIENT_PROFILE_NOT_FOUND`.
4. BE → FE: `200 { id, userId, agencyId, displayName, company, phone, note, logoUrl, website, industry, location, description, socialLinks, createdAt, updatedAt }`.
5. FE: render Client Profile cho đúng ngữ cảnh Agency đang xem.

## Flow B — Agency xem danh sách Client Profile của mình (hỗ trợ chọn khi thêm Client vào Workspace)

1. Agency member (Owner/Manager) → FE: mở màn thêm Client vào Workspace, cần gợi ý Client Profile có sẵn.
2. FE → BE: `GET /api/v1/client-profile?agencyId={agencyId}`.
3. BE (`ClientProfileController.listByAgency` → `ClientProfileServiceImpl.listByAgency`):
   a. BE → DB: `clientProfileRepository.findByAgencyId(agencyId)` → danh sách tất cả Client Profile thuộc agency đó.
4. BE → FE: `200 [ { id, userId, agencyId, displayName, ... }, ... ]`.
5. FE: hiển thị danh sách để chọn tái sử dụng khi mời Client mới vào 1 Workspace khác cùng Agency.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Xem Client Profile (Flow A) | Chưa có `ClientProfile` cho cặp (userId, agencyId) này | 404 | `CLIENT_PROFILE_NOT_FOUND` |
| Xem Client Profile (Flow A) | Token hết hạn/không hợp lệ | 401 | `UNAUTHORIZED` |

## Ghi chú

- Việc tạo mới `ClientProfile` nằm ở luồng accept invitation (xem `sequence-flow.md` của agency-workspace) HOẶC ở lần đầu gọi update (FR 3.3.4, upsert) — không nằm ở FR 3.3.3 (GET). FR 3.3.3 luôn trả 404 `CLIENT_PROFILE_NOT_FOUND` nếu chưa có bản ghi cho cặp (userId, agencyId).

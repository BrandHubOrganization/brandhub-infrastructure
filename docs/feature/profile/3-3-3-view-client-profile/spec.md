# UC — View Client Profile

| | |
|---|---|
| FR Code | 3.3.3 |
| Feature | View Client Profile |
| Domain | Profile (FR 3.3) |
| Role | USER |
| Version | 2.1 (sync với code thật, 2026-09-23) |
| Trạng thái tài liệu | Đã code — spec khớp `ClientProfileController`/`ClientProfileServiceImpl` |

## 1. Objective

Hiển thị Client Profile riêng biệt khi User đóng vai trò Client tham gia Workspace của Agency khác — cho phép tái sử dụng thông tin trong phạm vi **cùng 1 Agency** mà không cần khai lại.

## 2. User Story

Là một User đang đóng vai trò Client ở 1 Workspace của Agency khác,
tôi muốn xem Client Profile của mình,
để xác nhận thông tin đang được Agency đó nhìn thấy khi làm việc với tôi.

## 3. Acceptance Criteria

- Hiển thị field của Client Profile: `id`, `userId`, `agencyId`, `displayName`, `company`, `phone`, `note`, `logoUrl`, `website`, `industry`, `location`, `description`, `socialLinks`, `createdAt`, `updatedAt` (xem [11-data-entities-glossary.md](../../../BA/11-data-entities-glossary.md) mục ClientProfile).
- Client Profile **độc lập với User Profile** thông thường (FR 3.3.1) — 1 User có cả 2 loại profile nếu họ vừa là Owner Agency của mình, vừa là Client ở Agency khác.
- ClientProfile được khoá theo cặp **(userId, agencyId)**, KHÔNG global: 1 User làm Client ở Agency A và Agency B → 2 bản ghi `ClientProfile` riêng biệt, độc lập hoàn toàn (khác `displayName`, `company`... nếu muốn).
- "Tái sử dụng" chỉ đúng trong phạm vi **cùng 1 Agency**: nếu User đã là Client ở 1 Workspace của Agency A, khi được mời vào Workspace khác cùng Agency A → dùng lại đúng `ClientProfile(userId, agencyId=A)` đó. Nếu được mời làm Client ở Agency B (khác Agency A) → hệ thống dùng `ClientProfile(userId, agencyId=B)` riêng, độc lập với bản ở Agency A.
- ClientProfile được tạo lần đầu qua accept-invitation, HOẶC qua lần đầu gọi update (upsert — xem FR 3.3.4).

## 4. UI / UX

- Trang `/client-profile` (tách biệt route với `/settings/profile`), FE lấy `agencyId` hiện tại từ URL query (`useSearchParams`), hoặc tab riêng trong Settings nếu User đang có vai trò Client ở bất kỳ Workspace nào.

## 5. API Contract

```
GET /api/v1/client-profile/me?agencyId={agencyId}
Authorization: Bearer <access-token>
→ 200 { "success": true, "data": {
    "id", "userId", "agencyId", "displayName", "company", "phone", "note",
    "logoUrl", "website", "industry", "location", "description", "socialLinks",
    "createdAt", "updatedAt"
  } }

GET /api/v1/client-profile?agencyId={agencyId}
→ 200 { "success": true, "data": [ { ...same shape... }, ... ] }
// Danh sách Client Profile của 1 Agency — dùng để Agency chọn khi thêm Client vào Workspace.
```

`agencyId` là query param **bắt buộc** ở cả 2 endpoint.

## 6. Error Handling

- Chưa có `ClientProfile` cho cặp (userId, agencyId) này → 404 `CLIENT_PROFILE_NOT_FOUND`.
- Thiếu query param `agencyId` → 400 `VALIDATION_ERROR` (Spring `@RequestParam` bắt buộc).
- Token hết hạn/không hợp lệ → 401 `UNAUTHORIZED`.

## 7. Edge Cases

- User đồng thời là Owner Agency A và Client ở Workspace của Agency B → 2 profile tồn tại độc lập, UI cần phân biệt rõ ngữ cảnh đang xem (User Profile vs Client Profile).
- User là Client ở cả Agency A và Agency B → 2 bản ghi `ClientProfile` độc lập, không lẫn dữ liệu giữa 2 agency.

## 8. Definition of Done

- Client Profile hiển thị đúng theo `agencyId` truyền vào; verify bằng test cùng 1 user, 2 `agencyId` khác nhau trả về 2 profile độc lập.

## Out of Scope

- Đổi vai trò Client thành Member nội bộ Agency (không có trong CSV).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)

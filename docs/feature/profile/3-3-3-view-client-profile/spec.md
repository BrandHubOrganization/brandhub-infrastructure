# UC — View Client Profile

| | |
|---|---|
| FR Code | 3.3.3 |
| Feature | View Client Profile |
| Domain | Profile (FR 3.3) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị Client Profile riêng biệt khi User đóng vai trò Client tham gia Workspace của Agency khác — cho phép tái sử dụng thông tin xuyên nhiều Agency/Workspace mà không cần khai lại.

## 2. User Story

Là một User đang đóng vai trò Client ở 1 Workspace của Agency khác,
tôi muốn xem Client Profile của mình,
để xác nhận thông tin đang được các Agency khác nhìn thấy khi làm việc với tôi.

## 3. Acceptance Criteria

- Hiển thị field riêng của Client Profile: `displayName`, `company`, `phone`, `note` (xem [11-data-entities-glossary.md](../../../BA/11-data-entities-glossary.md) mục ClientProfile).
- Client Profile **độc lập với User Profile** thông thường (FR 3.3.1) — 1 User có cả 2 loại profile nếu họ vừa là Owner Agency của mình, vừa là Client ở Agency khác.
- Khi User này được invite vào 1 Workspace mới (Agency khác) với vai trò Client → **tự động dùng lại Client Profile đã có**, không phải khai báo lại từ đầu.

## 4. UI / UX

- Trang `/client-profile` (tách biệt route với `/settings/profile`), hoặc tab riêng trong Settings nếu User đang có vai trò Client ở bất kỳ Workspace nào.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/client-profile/me
→ 200 { "success": true, "data": { "id", "userId", "displayName", "company", "phone", "note" } }
```

## 6. Error Handling

- User chưa từng được invite làm Client ở đâu → trả 404 `CLIENT_PROFILE_NOT_FOUND` (chỉ tạo Client Profile lần đầu khi họ accept lời mời Client đầu tiên).

## 7. Edge Cases

- User đồng thời là Owner Agency A và Client ở Workspace của Agency B → 2 profile tồn tại độc lập, UI cần phân biệt rõ ngữ cảnh đang xem (User Profile vs Client Profile).

## 8. Definition of Done

- Client Profile hiển thị đúng, tái sử dụng xuyên Agency được verify bằng test 2 Agency khác nhau cùng thấy 1 Client Profile.

## Out of Scope

- Đổi vai trò Client thành Member nội bộ Agency (không có trong CSV).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)

# UC — Deactivate Account

| | |
|---|---|
| FR Code | 3.2.9 |
| Feature | Deactivate Account |
| Domain | Authentication (FR 3.2) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Confirmed — đã code (chặn owner Agency active) |

## 1. Objective

Cho phép user tự vô hiệu hóa tài khoản của mình — soft delete, không xóa cứng dữ liệu.

## 2. User Story

Là một User không muốn dùng BrandHub nữa,
tôi muốn deactivate tài khoản của mình,
nhưng dữ liệu vẫn được giữ lại phòng trường hợp tôi quay lại.

## 3. Acceptance Criteria

- Bấm Deactivate (có confirm dialog, có thể yêu cầu nhập lại password để xác nhận).
- Set `User.status = DEACTIVATED` — **soft delete**, KHÔNG xóa cứng record User hay dữ liệu liên quan (Agency/Workspace họ đang tham gia).
- Sau deactivate, user không login được nữa; các Agency họ là Owner vẫn tồn tại nhưng cần xử lý riêng (xem câu hỏi mở bên dưới).

## 4. UI / UX

- Trang `/settings/account`, mục Deactivate ở cuối, có warning rõ ràng trước khi confirm.
- **[CHỐT 2026-09-20]** FE nút "Deactivate" trên trang Profile (`/profile`) phải gọi thật `POST /api/v1/auth/deactivate` (nhập password → confirm), sau thành công clear auth + redirect `/login`. Hiện trạng FE là stub (chỉ toast), cần wire.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/auth/deactivate
{ "password": "string" }
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Password xác nhận sai → 400 `WRONG_CURRENT_PASSWORD` (đã code, thay cho `INVALID_PASSWORD`).
- User là Owner duy nhất của 1+ Agency đang có Workspace hoạt động → cần cảnh báo rõ hậu quả trước khi cho deactivate (xem Edge Cases).

## 7. Edge Cases

- **ĐÃ CHỐT**: User là Owner của Agency `ACTIVE` → **chặn deactivate** (409 `AGENCY_OWNERSHIP_ACTIVE`), buộc transfer ownership trước khi được deactivate.

## 8. Definition of Done

- Deactivate thành công, user không login được sau đó, dữ liệu liên quan vẫn còn trong DB (verify bằng query trực tiếp).

## Out of Scope

- Xóa cứng tài khoản (hard delete) — không có trong CSV, chỉ soft delete.

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)

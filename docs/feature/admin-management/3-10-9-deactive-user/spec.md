# UC — Deactive User

| | |
|---|---|
| FR Code | 3.10.9 |
| Feature | Deactive User |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tạm khóa Account của người dùng.

## 2. User Story

Là một Admin,
tôi muốn tạm khóa 1 tài khoản User,
khi phát hiện vi phạm hoặc theo yêu cầu hỗ trợ.

## 3. Acceptance Criteria

- Set `User.status = DEACTIVATED` (giống hành động tự deactivate ở FR 3.2.9, nhưng do Admin thực hiện thay).
- **[CÂU HỎI MỞ — CHƯA CÓ CÂU TRẢ LỜI, ghi chú gốc từ CSV]**:
  1. Admin có xóa được Admin khác không (self-service hay cần Super Admin riêng)?
  2. Hệ thống giới hạn số lượng Admin tối đa, hay không giới hạn?
- Cần Trung trả lời 2 câu hỏi này trước khi thiết kế RBAC chính thức cho nhóm Admin.

## 4. UI / UX

- Nút 'Khóa tài khoản' trong `/admin/users/:id`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/admin/users/{userId}/deactivate
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Không phải Admin → 403 `FORBIDDEN`.

## 7. Edge Cases

- Deactivate 1 Admin khác → **CHƯA XÁC ĐỊNH** (xem câu hỏi mở AC) — tạm chặn hành động này (403) cho đến khi có câu trả lời chính thức, để tránh rủi ro tự khóa hết quyền quản trị hệ thống.

## 8. Definition of Done

- **[Chưa thể coi Done hoàn toàn — phần Admin-xóa-Admin cần làm rõ trước]**.

## Out of Scope

- Không có.

## Tham chiếu BA

[09-admin-management.md](../../../BA/09-admin-management.md)

# Plan — Deactivate Account

> [spec.md](./spec.md) — Soft-delete account, chặn nếu là Owner duy nhất Agency active.

## Quyết định câu hỏi mở (spec Edge Cases)

Spec để mở: "User là Owner Agency active → deactivate thì Agency xử lý sao?" — **Chốt với Trung: Chặn, bắt transfer trước.**

- User là Owner duy nhất của 1+ Agency `ACTIVE` → chặn deactivate, trả 409 `AGENCY_OWNERSHIP_ACTIVE` (buộc transfer ownership trước).
- Ngược lại → deactivate bình thường.

## Kỹ thuật

- `POST /api/v1/auth/deactivate { password }` (Bearer) → verify password (bcrypt) → sai → 400 `INVALID_PASSWORD`.
- `agencyRepository.findByOwnerId(userId)` → có Agency `EntityStatus.ACTIVE`? → 409 `AGENCY_OWNERSHIP_ACTIVE`.
- Không có → `setStatus(UserStatus.DEACTIVATED)` (soft delete), KHÔNG xóa cứng.
- Sau deactivate, login → `checkStatus` → 403 `ACCOUNT_DEACTIVATED`.

## Luồng

1. Auth → userId.
2. Verify password → sai → 400.
3. Check Agency active (owner) → có → 409.
4. `status=DEACTIVATED` → 200.

## Data Model

- `users.status` → `DEACTIVATED` (thêm enum value).
- `agencies.owner_id`, `agencies.status`.

## Rủi ro

- Không xóa cứng (giữ Agency/Workspace membership). User muốn khôi phục → nhờ Admin (ngoài scope).

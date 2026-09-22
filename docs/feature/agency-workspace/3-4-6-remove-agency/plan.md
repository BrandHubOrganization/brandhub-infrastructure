# Plan — Remove Agency (FR 3.4.6)

> Liên kết: [spec.md](spec.md) — cho Owner xóa mềm Agency, khôi phục được trong 30 ngày.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `AgencyServiceImpl.removeAgency()` |
| File đã có | `AgencyController` (`DELETE /api/v1/agencies/{agencyId}`) |

## 2. API Contract (final)

```
DELETE /api/v1/agencies/{agencyId}
Authorization: Bearer <access-token>
→ 200 ApiResponse<Void> (data = null)
```

Khác so với spec.md (đề xuất thêm `POST /{id}/restore`):

- **Chưa implement `restore`** — spec mục 5 ghi restore endpoint nhưng DoD/CSV chỉ yêu cầu soft-delete. Job xóa cứng sau 30 ngày + restore thuộc thiết kế kỹ thuật riêng (ngoài phạm vi FR). Để TODO rõ, không mở rộng scope.
- **Chưa chuyển Workspace con sang `inactive`** — `Workspace` chưa có FK `agency_id` (DA-E16-10 chưa làm). Khi FK xong sẽ bổ sung cascade soft-delete.

## 3. Data Model

- Cập nhật `agencies`: `status = SOFT_DELETED`, `deletedAt = now`. Không migration.

## 4. Luồng xử lý

1. `findAgencyOrThrow(agencyId)` → 404 nếu không có.
2. Check `ownerId == currentUser.id` → nếu không, `NOT_AGENCY_OWNER` (403).
3. Set `status = SOFT_DELETED`, `deletedAt = now`, save.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Agency` entity + repository (đã có) |
| Bị chặn | Job xóa cứng định kỳ (thiết kế riêng) |

## 6. Rủi ro kỹ thuật

- **Thiếu restore/cascade Workspace:** nếu Owner xóa nhầm, chưa có đường khôi phục trong code. Đã ghi nhận là gap, chờ DA-E16-10 (FK Workspace) + task restore riêng.

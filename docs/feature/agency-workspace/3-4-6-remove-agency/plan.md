# Plan — Remove Agency (FR 3.4.6)

> Liên kết: [spec.md](spec.md) — cho Owner xóa mềm Agency (cascade Workspace con), khôi phục được trong 30 ngày.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `AgencyServiceImpl.removeAgency()` + `AgencyServiceImpl.restoreAgency()` |
| File đã có | `AgencyController` (`DELETE /api/v1/agencies/{agencyId}`, `POST /api/v1/agencies/{agencyId}/restore`), `WorkspaceRepository.findByAgencyId` |

## 2. API Contract (final)

```
DELETE /api/v1/agencies/{agencyId}
Authorization: Bearer <access-token>
→ 200 ApiResponse<Void> (data = null)

POST /api/v1/agencies/{agencyId}/restore
Authorization: Bearer <access-token>
→ 200 ApiResponse<AgencyResponse>
```

Luồng xóa chỉ đổi `status`/`deletedAt` (soft delete) — không xóa cứng. Job xóa cứng sau 30 ngày thuộc thiết kế kỹ thuật riêng, ngoài phạm vi FR.

## 3. Data Model

- Cập nhật `agencies`: `status = SOFT_DELETED`, `deletedAt = now`.
- Cập nhật `workspaces` (cascade): mọi Workspace có `agency_id = agencyId` → `status = SOFT_DELETED`, `deletedAt = now`.
- Restore: `agencies` → `ACTIVE`/`deletedAt = null`; các Workspace con → `ACTIVE`/`deletedAt = null`/`updatedAt = now`.
- Không migration (Workspace đã có FK `agency_id` + `status`/`deleted_at`).

## 4. Luồng xử lý

### removeAgency

1. `findAgencyOrThrow(agencyId)` → 404 nếu không có.
2. Check `ownerId == currentUser.id` → nếu không, `NOT_AGENCY_OWNER` (403).
3. Set Agency `status = SOFT_DELETED`, `deletedAt = now`, save.
4. `workspaceRepository.findByAgencyId(agencyId)` → mỗi Workspace set `SOFT_DELETED` + `deletedAt = now`, save (cascade).

### restoreAgency

1. `findAgencyOrThrow` → 404; owner-check → 403.
2. `status != SOFT_DELETED` → `AGENCY_NOT_DELETED` (400).
3. `deletedAt == null` hoặc quá `RESTORE_WINDOW_DAYS` (30) → `RESTORE_WINDOW_EXPIRED` (410).
4. Set Agency `ACTIVE`, `deletedAt = null`, `updatedAt = now`.
5. `workspaceRepository.findByAgencyId(agencyId)` → mỗi Workspace con set `ACTIVE`, `deletedAt = null`, `updatedAt = now` (cascade).

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Agency` + `Workspace` entity/repository (đã có) |
| Bị chặn | Job xóa cứng định kỳ (thiết kế riêng) |

## 6. Rủi ro kỹ thuật

- **Cascade restore quá rộng:** `restoreAgency` set mọi Workspace con về `ACTIVE`, kể cả Workspace đã bị soft-delete độc lập trước đó (FR 3.4.15) → hồi sinh ngoài ý muốn. Cần cờ phân biệt (ví dụ `deleted_with_agency`) nếu BA muốn chính xác — xem spec.md mục "Cần xác nhận".
- **Job xóa cứng sau 30 ngày:** chưa có scheduler, ngoài phạm vi FR.

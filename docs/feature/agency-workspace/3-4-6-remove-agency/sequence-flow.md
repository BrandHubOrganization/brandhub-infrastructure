# Sequence Flow — Remove Agency

> Bổ sung cho `spec.md` (FR 3.4.6). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AgencyController.removeAgency`/`restoreAgency`, `AgencyServiceImpl.removeAgency`/`restoreAgency`).

## Actors

- **Owner**
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`agencies`, `workspaces`).

---

## Flow A — Soft-delete Agency (cascade Workspace con)

1. Owner → FE: bấm Remove ở Agency Settings → dialog confirm 2 lớp (nhập lại tên Agency, liệt kê hệ quả Workspace con).
2. FE → BE: `DELETE /api/v1/agencies/{agencyId}`.
3. BE (`AgencyServiceImpl.removeAgency`):
   a. `findAgencyOrThrow(agencyId)` — không tồn tại → `404 AGENCY_NOT_FOUND`.
   b. Check `agency.getOwnerId().equals(currentUser.getId())` — sai → `403 NOT_AGENCY_OWNER`.
   c. `UPDATE agencies SET status = SOFT_DELETED, deletedAt = now()`.
   d. Cascade: `workspaceRepository.findByAgencyId(agencyId)` → mỗi Workspace `UPDATE workspaces SET status = SOFT_DELETED, deletedAt = now()`.
4. BE → FE: `200 { data: null }`.
5. FE: hiện toast, redirect về `/agencies`.

## Flow B — Restore Agency (trong 30 ngày, cascade Workspace con)

1. Owner → FE: vào danh sách Agency đã xóa (hoặc link trực tiếp), bấm Restore.
2. FE → BE: `POST /api/v1/agencies/{agencyId}/restore`.
3. BE (`AgencyServiceImpl.restoreAgency`):
   a. `findAgencyOrThrow` — không tồn tại → `404 AGENCY_NOT_FOUND`.
   b. Check Owner — sai → `403 NOT_AGENCY_OWNER`.
   c. Check `status == SOFT_DELETED` — không phải (chưa từng bị xóa) → `400 AGENCY_NOT_DELETED`.
   d. Check `deletedAt != null` và `now() <= deletedAt + 30 ngày` — quá hạn/null → `410 RESTORE_WINDOW_EXPIRED`.
   e. `UPDATE agencies SET status = ACTIVE, deletedAt = null, updatedAt = now()`.
   f. Cascade: `workspaceRepository.findByAgencyId(agencyId)` → mỗi Workspace `UPDATE workspaces SET status = ACTIVE, deletedAt = null, updatedAt = now()`.
4. BE → FE: `200 { data: AgencyResponse }` (status = ACTIVE).
5. FE: hiện toast thành công, cập nhật UI.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Remove | Agency không tồn tại | 404 | `AGENCY_NOT_FOUND` |
| Remove | Không phải Owner | 403 | `NOT_AGENCY_OWNER` |
| Restore | Agency không tồn tại | 404 | `AGENCY_NOT_FOUND` |
| Restore | Không phải Owner | 403 | `NOT_AGENCY_OWNER` |
| Restore | Chưa từng bị xóa | 400 | `AGENCY_NOT_DELETED` |
| Restore | Quá 30 ngày kể từ `deletedAt` | 410 | `RESTORE_WINDOW_EXPIRED` |

## Ghi chú drift đã fix

- Bản trước đánh dấu **[GAP]** "cascade Workspace con chưa code — `removeAgency`/`restoreAgency` chỉ thao tác trên bảng `agencies`". **Không còn đúng**: code hiện tại đã cascade hai chiều qua `workspaceRepository.findByAgencyId(agencyId)` — xóa Agency set Workspace con `SOFT_DELETED`/`deletedAt`, restore set Workspace con `ACTIVE`/`deletedAt = null`/`updatedAt`. GAP đã đóng.
- Rủi ro còn lại (không phải GAP): cascade restore khôi phục **mọi** Workspace con, kể cả Workspace đã bị soft-delete độc lập trước đó → "hồi sinh" ngoài ý muốn. Xem spec.md mục "Cần xác nhận".

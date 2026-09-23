# UC — Remove Agency

| | |
|---|---|
| FR Code | 3.4.6 |
| Feature | Remove Agency |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.2 — Cập nhật 2026-09-23 — cascade Workspace con đã code |
| Trạng thái tài liệu | Confirmed — đã code soft-delete + restore + **cascade Workspace con** (xác nhận 2026-09-23, `AgencyServiceImpl.removeAgency`/`restoreAgency`). GAP cascade trước đây đã được hiện thực. |

## 1. Objective

Cho phép Owner xóa (mềm) Agency, có confirm, khôi phục được trong 30 ngày.

## 2. User Story

Là một Owner,
tôi muốn xóa Agency không còn dùng nữa,
nhưng vẫn có thể khôi phục nếu tôi đổi ý trong 30 ngày.

## 3. Acceptance Criteria

- Bấm Remove → dialog confirm rõ ràng (liệt kê hệ quả: toàn bộ Workspace con cũng bị ảnh hưởng).
- Set `Agency.status = SOFT_DELETED`, `deletedAt = now()` — khớp code thật (`removeAgency`), chỉ Owner mới thực hiện được (else `NOT_AGENCY_OWNER`).
- **Cascade Workspace con:** soft-delete toàn bộ Workspace thuộc Agency — `workspaceRepository.findByAgencyId(agencyId)` → mỗi Workspace set `status = SOFT_DELETED`, `deletedAt = now()`.
- Restore: `POST /{agencyId}/restore` — chỉ Owner, chỉ khi `status == SOFT_DELETED` (else `AGENCY_NOT_DELETED`), chỉ trong vòng 30 ngày kể từ `deletedAt` (else 410 `RESTORE_WINDOW_EXPIRED`). Restore set lại `status = ACTIVE`, `deletedAt = null` cho Agency, và cho **chỉ các Workspace con có `deletedAt` khớp đúng đợt xóa Agency** (cùng một `OffsetDateTime` được ghi lúc `removeAgency` cascade — Workspace đã soft-delete độc lập trước đó giữ nguyên trạng thái deleted).
- Sau 30 ngày không khôi phục → có thể bị xóa cứng bởi job dọn dẹp định kỳ (thiết kế kỹ thuật riêng, không thuộc phạm vi FR này — job này **chưa có trong code**).

## 4. UI / UX

- Nút Remove ở Agency Settings, confirm dialog 2 lớp (nhập tên Agency để xác nhận, giống pattern xóa nguy hiểm).

## 5. API Contract (khớp code thật)

```
DELETE /api/v1/agencies/{agencyId}
→ 200 { "success": true, "data": null }

POST /api/v1/agencies/{agencyId}/restore
→ 200 { "success": true, "data": AgencyResponse }
```

## 6. Error Handling

- Không phải Owner → 403 `NOT_AGENCY_OWNER`.
- Agency chưa từng bị xóa mà gọi restore → 400 `AGENCY_NOT_DELETED`.
- Đã bị soft-delete quá 30 ngày → 410 `RESTORE_WINDOW_EXPIRED`.

## 7. Edge Cases

- Owner xóa nhầm rồi khôi phục ngay trong 30 ngày → Workspace con bị xóa cùng đợt cũng được khôi phục lại `ACTIVE`. **Đã code** — `restoreAgency` lặp `workspaceRepository.findByAgencyId(agencyId)` và chỉ set `ACTIVE` + `deletedAt = null` cho Workspace có `deletedAt` khớp đúng đợt cascade.
- Workspace đã bị soft-delete độc lập trước đó (FR 3.4.15) → **không bị hồi sinh** khi restore Agency, vì `deletedAt` của nó khác với `deletedAt` của đợt cascade.

## 8. Definition of Done

- Soft delete + restore Agency hoạt động đúng.
- Cascade soft-delete/restore Workspace con hoạt động đúng (`removeAgency` → Workspace con `SOFT_DELETED` cùng `deletedAt`; `restoreAgency` → chỉ Workspace con cùng đợt `ACTIVE`, `deletedAt = null`; Workspace xóa độc lập giữ nguyên deleted).

## Out of Scope

- Xóa cứng ngay lập tức (không có trong CSV — chỉ soft delete).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

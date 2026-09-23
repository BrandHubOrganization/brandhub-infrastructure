# Sequence Flow — Delete Workspace

> FR 3.4.15 — **chưa implement, không có sequence thật.**
>
> Cập nhật: 2026-09-23.

## Tình trạng code thật

- `WorkspaceController` **không có** `DELETE /api/v1/workspaces/{id}` hay `POST /api/v1/workspaces/{id}/restore`.
- `WorkspaceServiceImpl` không có method `deleteWorkspace`/`restoreWorkspace` nào.
- `Workspace` entity có sẵn field `status` (`EntityStatus`) và `deletedAt`, nhưng **chưa có service/API nào dùng các field này cho soft-delete** — hiện tại các field này không được set bởi bất kỳ flow nào trong `WorkspaceServiceImpl`.
- Không có sequence flow thật để mô tả — toàn bộ nội dung dưới đây là luồng dự kiến theo `spec.md`, chưa xác nhận kỹ thuật.

## Actors (dự kiến)

- **Owner** — Agency Owner (chưa xác nhận cấp quyền chính xác — xem ghi chú spec.md).
- **FE** — brandhub-web-dashboard.
- **BE** — brandhub-business-service (chưa có endpoint).
- **DB** — PostgreSQL (`workspaces.status`, `workspaces.deletedAt`).

## Flow dự kiến (DRAFT — chưa code)

1. Owner → FE: mở Workspace Settings, bấm "Delete", nhập tên Workspace để xác nhận (confirm dialog).
2. FE → BE: `DELETE /api/v1/workspaces/{id}` *(endpoint chưa tồn tại)*.
3. BE (dự kiến): check `currentUser` là Owner (cấp Agency) — không phải, kể cả là MANAGER của Workspace → `403 FORBIDDEN`.
4. BE (dự kiến): set `Workspace.status = SOFT_DELETED`, `deletedAt = now()`.
5. BE (dự kiến): toàn bộ Member/Client mất quyền truy cập Workspace ngay; dữ liệu liên quan (Task, Campaign, Material...) chuyển `inactive`.
6. BE → FE: `200 { data: null }`.

### Nhánh phụ — Restore (dự kiến, chưa code)

1. Owner → FE: bấm "Restore" trong danh sách Workspace đã xóa (trong 30 ngày).
2. FE → BE: `POST /api/v1/workspaces/{id}/restore` *(endpoint chưa tồn tại)*.
3. BE (dự kiến): check còn trong hạn 30 ngày kể từ `deletedAt` — quá hạn → `410 RESTORE_WINDOW_EXPIRED`.
4. BE (dự kiến): khôi phục `status`, khôi phục đúng trạng thái Task/Campaign trước khi xóa (không reset về backlog).
5. BE → FE: `200 { data: WorkspaceResponse }`.

## Error paths tổng hợp (dự kiến, chưa code)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Delete | Không phải Owner | 403 | `FORBIDDEN` (đề xuất) |
| Restore | Quá 30 ngày | 410 | `RESTORE_WINDOW_EXPIRED` (đề xuất) |

## Ghi chú khác biệt so với spec.md gốc

- `spec.md` đã tự đánh dấu "Draft — chưa code" và mô tả rõ "Role: Agency OWNER (đề xuất — chưa xác nhận)" — sequence-flow này xác nhận thêm: `Workspace` entity đã có sẵn `status`/`deletedAt` (chuẩn bị hạ tầng cho soft-delete) nhưng chưa có code nghiệp vụ nào ghi vào 2 field đó, nên không có sequence thật để mô tả thêm ngoài phần DRAFT.

# Plan — Delete Workspace (FR 3.4.15)

> Liên kết: [spec.md](spec.md) — Trạng thái tài liệu: **Draft — chưa code**. Plan này ở dạng đề xuất/dự kiến, cần xác nhận khi thiết kế kỹ thuật thật.

## 1. Phạm vi kỹ thuật (dự kiến)

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File cần thêm | `WorkspaceServiceImpl.deleteWorkspace()`, `WorkspaceServiceImpl.restoreWorkspace()` (chưa tồn tại) |
| File đã có, dự kiến tái sử dụng | `Workspace` entity (đã có sẵn field `status` kiểu `EntityStatus`, `deletedAt` — chưa được service/API nào dùng cho soft-delete), `WorkspaceController` |

## 2. API Contract (đề xuất, chưa code)

```
DELETE /api/v1/workspaces/{id}
→ 200 { "success": true, "data": null }

POST /api/v1/workspaces/{id}/restore
→ 200 { "success": true, "data": { ...restored workspace... } }
```

Cần xác nhận path param thật khớp `{workspaceId}` như các endpoint khác (pattern hiện tại của `WorkspaceController`).

## 3. Data Model (dự kiến)

- `Workspace.status = SOFT_DELETED`, `deletedAt = now()` — field đã tồn tại sẵn trên entity, chưa từng được ghi bởi service nào (xác nhận cần review `Workspace` entity trước khi code).
- Cần xác nhận cơ chế "toàn bộ dữ liệu trong Workspace (Task, Campaign, Material...) chuyển `inactive`" — đây là cascade sang domain khác (Task/Campaign), **chưa rõ có sẵn cột trạng thái tương ứng hay không**, cần thiết kế kỹ thuật riêng, có thể cần transaction lớn hoặc batch job.
- Không migration schema (field đã có sẵn), nhưng cần xác nhận cascade update có cần migration ở domain Task/Campaign hay không.

## 4. Luồng xử lý (dự kiến)

1. Check role: chỉ Agency OWNER (không phải Workspace MANAGER) — theo spec.md mục 3 "chỉ OWNER" — cần xác nhận cách resolve OWNER ở cấp Workspace (không có `AgencyMember` trực tiếp trong path `/workspaces/{id}`, cần lấy `agencyId` từ Workspace rồi so `agency.ownerId`).
2. Confirm dialog ở FE (nhập tên Workspace xác nhận) — không phải trách nhiệm BE.
3. `findWorkspaceOrThrow(id)` → 404.
4. Check owner → 403 `FORBIDDEN` nếu không phải Owner (kể cả Manager của Workspace đó).
5. Set `status = SOFT_DELETED`, `deletedAt = now()`.
6. Cascade set toàn bộ Task/Campaign/Material liên quan sang `inactive` — cần thiết kế riêng.
7. Restore: check trong 30 ngày kể từ `deletedAt`, nếu quá hạn → 410 `RESTORE_WINDOW_EXPIRED`; nếu hợp lệ, khôi phục đúng trạng thái dữ liệu trước đó (không reset).

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Cần xác nhận domain Task/Campaign đã có cột trạng thái tương thích cascade "inactive" chưa |
| Bị chặn | Không |

## 6. Rủi ro kỹ thuật

- **Chưa có endpoint, chưa có service** — rủi ro lớn nhất, cần thiết kế kỹ thuật riêng trước khi ước lượng effort.
- **Cascade "toàn bộ dữ liệu chuyển inactive"** là thay đổi xuyên domain (Task, Campaign, Material), không chỉ nằm trong Workspace domain — cần phối hợp với owner của các domain đó.
- **Restore đúng trạng thái trước đó (không reset về backlog)** — đòi hỏi lưu snapshot trạng thái tại thời điểm xóa, không đơn giản chỉ lật cờ `inactive` → `active`.
- **Vai trò "Owner cấp Workspace" chưa tồn tại trong code thật** (Owner chỉ tồn tại ở cấp Agency theo mọi FR khác đã code — 3.4.16/18/19/20/21 đều dùng MANAGER, không có OWNER) — spec.md tự ghi "đề xuất — chưa xác nhận" cho Role; đây là điểm mâu thuẫn tiềm tàng cần BA làm rõ trước khi code (có thể ý là Agency OWNER của Agency chứa Workspace đó, không phải role riêng ở cấp Workspace).

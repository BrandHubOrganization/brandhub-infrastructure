# Sequence Flow — View Workspace Dashboard

> FR 3.4.11 — **chưa implement, không có sequence thật.**
>
> Cập nhật: 2026-09-23.

## Tình trạng code thật

- `WorkspaceController` (`brandhub-business-service/src/main/java/com/brandhub/business/controller/WorkspaceController.java`) **không có** endpoint `GET /api/v1/workspaces/{id}/dashboard` hay bất kỳ route `.../dashboard` nào.
- `WorkspaceServiceImpl` không có method tổng hợp `taskStats`/`activeClientCount`/`activeCampaignCount` nào liên quan Workspace dashboard.
- Do đó **không có sequence flow thật để mô tả** — mọi bước dưới đây chỉ là luồng dự kiến theo `spec.md` mục 5 (API Contract "đề xuất, cần xác nhận"), chưa được xác nhận kỹ thuật, chưa code.

## Actors (dự kiến)

- **User** — thành viên Workspace (MANAGER/CREATOR/CLIENT).
- **FE** — brandhub-web-dashboard.
- **BE** — brandhub-business-service (chưa có controller/service tương ứng).
- **DB** — PostgreSQL (bảng Task/Campaign/Client — chưa xác định rõ query tổng hợp).

## Flow dự kiến (DRAFT — chưa code)

1. User → FE: mở `/workspaces/:id/dashboard`.
2. FE → BE: `GET /api/v1/workspaces/{id}/dashboard` *(endpoint chưa tồn tại)*.
3. BE (dự kiến): check `WorkspaceMember` của `currentUser` tại workspace này còn active — không có → `403 FORBIDDEN`.
4. BE (dự kiến): tổng hợp số Task theo trạng thái (backlog/in progress/completed), số Client active, số Campaign active.
5. BE → FE: `200 { taskStats, activeClientCount, activeCampaignCount }` *(response shape đề xuất, chưa có DTO thật)*.
6. FE: render dashboard; Workspace mới tạo chưa có dữ liệu → hiển thị toàn 0.

## Error paths tổng hợp (dự kiến, chưa code)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Dashboard | Không có quyền truy cập Workspace | 403 | `FORBIDDEN` (đề xuất) |

## Ghi chú khác biệt so với spec.md gốc

- `spec.md` đã tự đánh dấu "Trạng thái tài liệu: Draft — chưa code" và API Contract ghi rõ "đề xuất, cần xác nhận khi thiết kế kỹ thuật" — sequence-flow này chỉ tái khẳng định bằng cách xác minh trực tiếp `WorkspaceController` không có route dashboard, không phát sinh drift mới.

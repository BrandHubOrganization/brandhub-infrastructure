# Plan — View Workspace Profile (FR 3.4.13)

> Liên kết: [spec.md](spec.md) — cho member xem chi tiết 1 Workspace, bao gồm timezone/branding.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `WorkspaceServiceImpl.getWorkspace()` |
| File đã có | `WorkspaceController` (`GET /api/v1/workspaces/{workspaceId}`), `WorkspaceRepository`, `WorkspaceMemberRepository`, `WorkspaceResponse` |

## 2. API Contract (final)

```
GET /api/v1/workspaces/{workspaceId}
Authorization: Bearer <access-token>
→ 200 ApiResponse<WorkspaceResponse>
```

Không lệch spec.md.

## 3. Data Model

- Đọc `workspaces` theo `id`. Parse `settings` JSON (`timezone`, `defaultPlatforms`) qua `ObjectMapper` — lỗi parse fallback `WorkspaceSettings(null, null)`, không throw.
- Check membership qua `workspace_members` (`workspaceId + userId + isActive=true`), không ghi gì.
- Không migration.

## 4. Luồng xử lý

1. `findWorkspaceOrThrow(workspaceId)` → 404 `WORKSPACE_NOT_FOUND`.
2. `assertMember(workspaceId, currentUser.id)` — check thủ công trong service, không dùng `@RequireRole` (aspect không resolve đúng workspace theo path variable) → 403 `WORKSPACE_ACCESS_DENIED`.
3. `toResponse(workspace)` — parse `settings`, fallback an toàn nếu JSON lỗi.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Workspace` entity + repository (đã có) |
| Bị chặn | `Update Workspace Profile` (3.4.14) — cùng entity |

## 6. Rủi ro kỹ thuật

- **Check quyền thủ công thay vì `@RequireRole`:** vì aspect không resolve đúng workspace theo path variable ở route này — nếu sau này có refactor aspect để support path-based resolve, cần đồng bộ lại cách check ở đây tránh duplicate logic.
- **Parse `settings` JSON fallback im lặng khi lỗi** (không throw, trả `null`/`null`) — có thể che giấu dữ liệu `settings` bị corrupt; chấp nhận vì ưu tiên không làm sập trang profile chỉ vì 1 field phụ.
- **`mediaPackageTemplate`/danh sách Client active** không có trong response thật dù có thể được kỳ vọng bởi UI — ghi nhận Out of Scope tạm thời theo spec.md, cần BA xác nhận nếu vẫn cần.

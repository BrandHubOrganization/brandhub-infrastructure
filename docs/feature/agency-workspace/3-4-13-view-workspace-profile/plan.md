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

1. `@RequireRole({MANAGER, CREATOR, CLIENT})` ở tầng controller — chặn caller không có bất kỳ role nào trong 3 role trên → 403 `FORBIDDEN`.
2. `findWorkspaceOrThrow(workspaceId)` → 404 `WORKSPACE_NOT_FOUND`.
3. `assertMember(workspaceId, currentUser.id)` — check thủ công trong service (bổ sung, vì `@RequireRole` chỉ check role tồn tại, không resolve đúng theo `{workspaceId}` path variable) → 403 `WORKSPACE_ACCESS_DENIED`.
4. `toResponse(workspace)` — parse `settings`, fallback an toàn nếu JSON lỗi.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Workspace` entity + repository (đã có) |
| Bị chặn | `Update Workspace Profile` (3.4.14) — cùng entity |

## 6. Rủi ro kỹ thuật

- **Double-check quyền (`@RequireRole` + `assertMember` thủ công):** `@RequireRole` chỉ xác nhận caller có role đó ở đâu đó, không resolve đúng theo `{workspaceId}` path variable, nên service vẫn cần tự check membership đúng workspace này — nếu sau này aspect được refactor để support path-based resolve, cần đồng bộ lại tránh duplicate logic.
- **Parse `settings` JSON fallback im lặng khi lỗi** (không throw, trả `null`/`null`) — có thể che giấu dữ liệu `settings` bị corrupt; chấp nhận vì ưu tiên không làm sập trang profile chỉ vì 1 field phụ.
- **`mediaPackageTemplate`/danh sách Client active** không có trong response thật dù có thể được kỳ vọng bởi UI — ghi nhận Out of Scope tạm thời theo spec.md, cần BA xác nhận nếu vẫn cần.

# Sequence Flow — View Workspace Profile

> Bổ sung cho `spec.md` (FR 3.4.13). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`WorkspaceController.getWorkspace`, `WorkspaceServiceImpl.getWorkspace`).

## Actors

- **User** — thành viên Workspace (MANAGER/CREATOR/CLIENT).
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`workspaces`).

---

## Flow A — Xem chi tiết Workspace

1. User → FE: mở `/workspaces/:id/profile`.
2. FE → BE: `GET /api/v1/workspaces/{workspaceId}`.
3. BE (`WorkspaceServiceImpl.getWorkspace`):
   a. `findWorkspaceOrThrow(workspaceId)` — không tồn tại → `404 WORKSPACE_NOT_FOUND`.
   b. `assertMember(workspaceId, currentUser.id)`: query `workspace_members` theo `workspaceId + userId + isActive=true` — không có bản ghi → `403 WORKSPACE_ACCESS_DENIED` (check thủ công trong service method, không dùng `@RequireRole` vì aspect đó không resolve đúng workspace theo path variable).
   c. `toResponse(workspace)`: parse `settings` JSON (`timezone`, `defaultPlatforms`) qua `ObjectMapper` — parse lỗi thì fallback `WorkspaceSettings(null, null)` (không throw).
4. BE → DB: 2 SELECT (workspace, membership check).
5. BE → FE: `200 { data: WorkspaceResponse }` (đầy đủ field: id, name, agencyId, settings, industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, createdAt).
6. FE: hiển thị trang profile Workspace, bao gồm `settings.timezone`.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| View | Workspace không tồn tại | 404 | `WORKSPACE_NOT_FOUND` |
| View | Caller không phải active member của workspace này | 403 | `WORKSPACE_ACCESS_DENIED` |

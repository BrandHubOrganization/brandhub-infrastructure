# Sequence Flow — Delete Workspace

> Companion to `spec.md` (FR 3.4.15). Reflects the implemented code
> (`WorkspaceController`, `WorkspaceServiceImpl`, `AgencyRepository`,
> `WorkspaceRepository`) and the real FE (`detail.tsx` danger zone).
>
> Updated: 2026-09-25.

## Actors / Lifelines

- **Owner** — the Agency owner, acting from the Workspace settings danger zone (`detail.tsx`).
- **WorkspaceController** — `deleteWorkspace` / `restoreWorkspace` endpoints.
- **WorkspaceServiceImpl** — `deleteWorkspace` / `restoreWorkspace` business logic.
- **AgencyRepository** — resolves the parent Agency to check ownership.
- **WorkspaceRepository** — loads/saves the Workspace row.

⚠ There is no FE actor for Restore — the flow below documents the backend capability only; no screen currently triggers it.

---

## Flow A — Delete Workspace

1. Owner → WorkspaceController: types the Workspace name to confirm in the danger-zone dialog, then `DELETE /api/v1/workspaces/{workspaceId}`.
2. WorkspaceController → WorkspaceServiceImpl: `deleteWorkspace(workspaceId, currentUser)`.
3. WorkspaceServiceImpl → WorkspaceRepository: `findWorkspaceOrThrow(workspaceId)`; missing → 404 `WORKSPACE_NOT_FOUND`.
4. WorkspaceServiceImpl → AgencyRepository: `findById(workspace.getAgencyId())`; missing → 404 `WORKSPACE_NOT_FOUND`.
5. WorkspaceServiceImpl: compares `agency.getOwnerId()` to `currentUser.getId()`; mismatch → 403 `FORBIDDEN`.
6. WorkspaceServiceImpl: sets `status = SOFT_DELETED`, `deletedAt = now()`, `updatedAt = now()`.
7. WorkspaceServiceImpl → WorkspaceRepository: `save(workspace)`.
8. WorkspaceController → Owner: 200 `ApiResponse.ok(null)`.
9. Owner (FE): success toast, navigate to `/workspace`.

## Flow B — Restore Workspace (backend capability; no FE trigger today)

1. Caller → WorkspaceController: `POST /api/v1/workspaces/{workspaceId}/restore`.
2. WorkspaceController → WorkspaceServiceImpl: `restoreWorkspace(workspaceId, currentUser)`.
3. WorkspaceServiceImpl → WorkspaceRepository: `findWorkspaceOrThrow(workspaceId)`; missing → 404 `WORKSPACE_NOT_FOUND`.
4. WorkspaceServiceImpl → AgencyRepository: `findById(workspace.getAgencyId())`; missing → 404 `WORKSPACE_NOT_FOUND`.
5. WorkspaceServiceImpl: compares `agency.getOwnerId()` to `currentUser.getId()`; mismatch → 403 `FORBIDDEN`.
6. WorkspaceServiceImpl: checks `workspace.getStatus() == SOFT_DELETED`; otherwise → 400 `WORKSPACE_NOT_DELETED`.
7. WorkspaceServiceImpl: checks `deletedAt != null && now().isBefore(deletedAt.plusDays(30))`; otherwise → 410 `RESTORE_WINDOW_EXPIRED`.
8. WorkspaceServiceImpl: sets `status = ACTIVE`, `deletedAt = null`, `updatedAt = now()`.
9. WorkspaceServiceImpl → WorkspaceRepository: `save(workspace)` → returns `WorkspaceResponse`.
10. WorkspaceController → Caller: 200 with the restored `WorkspaceResponse`.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Delete/Restore | Workspace does not exist | 404 | `WORKSPACE_NOT_FOUND` |
| Delete/Restore | Caller is not the Agency OWNER (⚠ role gate not formally confirmed) | 403 | `FORBIDDEN` |
| Restore | Workspace status is not `SOFT_DELETED` | 400 | `WORKSPACE_NOT_DELETED` |
| Restore | More than 30 days since `deletedAt` | 410 | `RESTORE_WINDOW_EXPIRED` |

## Notes

- The role gate is implemented against Agency `ownerId`, not via `@RequireRole` (that annotation only understands WorkspaceMember roles) — see the code comment in `WorkspaceServiceImpl` citing the `AgencyServiceImpl.removeAgency` precedent.
- ⚠ Cascade effects on Task/Campaign/Material data described in `spec.md`'s Business Rules are not performed inside `deleteWorkspace` itself — flagged there as an open BA conflict, not modeled as steps here since they are not confirmed to exist in code.
- No FE screen currently calls the restore endpoint; Flow B is backend-only today.

# Test — Remove Workspace Member (FR 3.4.21)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | MANAGER xóa member CREATOR active | AC | 200; `isActive=false`, không đụng `agency_members` | Happy path | Pass |
| TC-02 | MANAGER xóa member CLIENT active | AC | 200; `isActive=false` | Happy path | Pass |
| TC-03 | Non-MANAGER (CREATOR/CLIENT) gọi endpoint | AC | 403 `FORBIDDEN` (qua `@RequireRole`) | Error case | Pass |
| TC-04 | `memberId` không tồn tại | Error (mục 6) | 404 `NOT_FOUND` | Error case | Pass |
| TC-05 | `memberId` thuộc workspace khác (không khớp `workspaceId`) | Error (mục 6) | 404 `NOT_FOUND` | Error case | Pass |
| TC-06 | `memberId` đã inactive | Error (mục 6) | 404 `NOT_FOUND` | Error case | Pass |
| TC-07 | Xóa MANAGER active duy nhất của workspace | AC (guard last-MANAGER) | 409 `LAST_MANAGER_CANNOT_BE_REMOVED` | Error case | Pass |
| TC-08 | Xóa MANAGER khi còn ≥2 MANAGER active | AC (guard last-MANAGER) | 200; thành công, workspace vẫn còn MANAGER | Edge case | Pass |
| TC-09 | Xóa member bị soft-delete, verify vẫn còn trong Agency | AC | `agency_members` record không đổi; member vẫn join được workspace khác | Edge case | Pass |

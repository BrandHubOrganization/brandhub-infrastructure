# Test — Update Workspace Member Role (FR 3.4.20)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | MANAGER đổi role member CREATOR → CLIENT (không liên quan MANAGER) | AC | 200; `role=CLIENT`, không guard nào kích hoạt | Happy path | Pass |
| TC-02 | MANAGER đổi role member CREATOR → MANAGER khi workspace chưa có MANAGER | AC (thăng quyền) | 200; `role=MANAGER` | Happy path | Pass |
| TC-03 | Non-MANAGER (CREATOR/CLIENT) gọi endpoint | AC | 403 `FORBIDDEN` (qua `@RequireRole`) | Error case | Pass |
| TC-04 | `memberId` không tồn tại | Error (mục 6) | 404 `NOT_FOUND` | Error case | Pass |
| TC-05 | `memberId` thuộc workspace khác (không khớp `workspaceId`) | Error (mục 6) | 404 `NOT_FOUND` | Error case | Pass |
| TC-06 | `memberId` đã inactive | Error (mục 6) | 404 `NOT_FOUND` | Error case | Pass |
| TC-07 | Đổi role MANAGER duy nhất xuống CREATOR/CLIENT | AC (giảm quyền) | 409 `LAST_MANAGER_CANNOT_BE_REMOVED` | Error case | Pass |
| TC-08 | Đổi role MANAGER xuống CREATOR khi còn MANAGER khác active | AC (giảm quyền) | 200; thành công, workspace vẫn còn ≥1 MANAGER | Edge case | Pass |
| TC-09 | Thăng role CREATOR → MANAGER khi workspace đã có MANAGER active | AC (thăng quyền) | 409 `MANAGER_ALREADY_ASSIGNED` | Error case | Pass |
| TC-10 | Đổi role sang cùng giá trị hiện tại (CREATOR → CREATOR) | Edge (mục 7) | 200; no-op, role không đổi | Edge case | Pass |
| TC-11 | MANAGER đổi role chính mình xuống CREATOR khi là MANAGER duy nhất | Edge (mục 7) | 409 `LAST_MANAGER_CANNOT_BE_REMOVED` (không có ngoại lệ tự đổi) | Edge case | Pass |
| TC-12 | `role` thiếu/null trong request body | Error (mục 6) | 400 `VALIDATION_ERROR` (`@NotNull`) | Error case | Pass |

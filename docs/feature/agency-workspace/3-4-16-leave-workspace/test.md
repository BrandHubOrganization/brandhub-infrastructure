# Test — Leave Workspace (FR 3.4.16)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | CREATOR active gọi `DELETE /{workspaceId}/leave` | AC3 | 200; `WorkspaceMember.isActive = false`, `AgencyMember` không đổi | Happy path | Pass |
| TC-02 | CLIENT active gọi leave, workspace còn nhiều member khác | AC3, Edge (mục 7) | 200; leave thành công | Happy path | Pass |
| TC-03 | User không phải active member của workspace gọi leave | AC4 | 403 `WORKSPACE_ACCESS_DENIED` | Error case | Pass |
| TC-04 | MANAGER duy nhất của workspace gọi leave | AC5 | 409 `LAST_OWNER_CANNOT_BE_REMOVED` | Error case | Pass |
| TC-05 | MANAGER (có >=2 MANAGER active) gọi leave | AC5, Edge (mục 7) | 200; leave thành công vì không phải MANAGER cuối | Edge case | Pass |
| TC-06 | Gọi leave 2 lần liên tiếp (đã leave rồi gọi lại) | Edge (mục 7) | Lần 2: 403 `WORKSPACE_ACCESS_DENIED` | Edge case | Pass |

## Ghi chú

- AC5 = guard last-MANAGER: MANAGER duy nhất phải chuyển giao role (qua FR 3.4.20) trước khi leave được.
- **Chưa xác nhận:** spec.md/sequence-flow.md không ghi rõ đã có test tự động (unit/integration) tương ứng 6 case trên hay chỉ mới test thủ công — đề nghị Trung xác nhận coverage thật trước khi đóng FR.

# Test — G4 Media Package/Campaign: View + Approve (Mobile)

> [plan.md](./plan.md) | [task.md](./task.md)

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Package List hiện đúng package khả dụng | Mục 4 flow | List khớp Workspace đang chọn | Chưa test |
| TC-02 | Package Detail hiện negotiation state | Mục 3 | `negotiationStatus`, `finalTerms`, `approvedByAgencyAt`/`approvedByClientAt` đúng | Chưa test |
| TC-03 | Approve Package — nút ẩn khi phía mình đã duyệt | Mục 4 | `approvedBy{Side}At != null` → ẩn nút, hiện trạng thái đã duyệt | Chưa test |
| TC-04 | Campaign List dùng đúng route | Mục 3, dùng WorkspaceCampaignController | Gọi `/workspaces/{id}/campaigns`, không gọi `/media-campaigns/...` | Chưa test |
| TC-05 | Campaign Detail hiện đủ section | Mục 4 | Strategy/BrandGuideline/Timeline/Deliverables/WorkItems render đúng | Chưa test |
| TC-06 | Approve Campaign — OWNER/MANAGER thấy nút Agency duyệt | Mục 4, role-gated | Hiện nếu `approvedByAgencyAt==null`, ẩn nếu đã duyệt | Chưa test |
| TC-07 | Approve Campaign — CLIENT thấy nút Client duyệt | Mục 4, role-gated | Hiện nếu `approvedByClientAt==null`, ẩn nếu đã duyệt | Chưa test |
| TC-08 | Approve thành công — chỉ 1 phía đã duyệt | Mục 6, dual approval độc lập | Status vẫn `DRAFT`, không chuyển `APPROVED` cho tới khi đủ 2 phía | Chưa test |
| TC-09 | Approve thành công — cả 2 phía đã duyệt | Mục 6 | Status chuyển `APPROVED` | Chưa test |
| TC-10 | Approve với `expectedVersion` lệch (409) | Mục 5, optimistic lock | `CAMPAIGN_VERSION_CONFLICT`, refetch detail, yêu cầu bấm Approve lại, KHÔNG tự động retry | Chưa test |
| TC-11 | Double-tap Approve cùng phía | Mục 5, server idempotent | Không lỗi, trả lại campaign hiện tại, không tạo duplicate approval | Chưa test |
| TC-12 | Approve Campaign đã ở IN_PROGRESS/COMPLETED | Mục 6, CAMPAIGN_IMMUTABLE | Nút Approve không hiện (hoặc disable), không gọi được API | Chưa test |
| TC-13 | 2 Client cùng bấm approve gần như đồng thời | Mục 6 edge case | 1 trong 2 nhận lỗi 409 do `expectedVersion`/`expectedApprovalRound` lệch, UI xử lý rõ ràng không phải lỗi hệ thống chung | Chưa test |
| TC-14 | Sau approve thành công, list Campaign cập nhật | Mục 5, invalidate cache | `invalidateQueries` cả campaign detail và campaigns list | Chưa test |

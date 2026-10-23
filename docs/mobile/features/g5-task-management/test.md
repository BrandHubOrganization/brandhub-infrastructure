# Test — G5 Task Management (Mobile)

> [plan.md](./plan.md) | [task.md](./task.md)

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Task List filter theo status/type/search/campaignId | FR 3.6.4 | Filter đúng, kết hợp được nhiều điều kiện | Chưa test |
| TC-02 | Client xem Task List | Q13, Client thấy toàn bộ | Client thấy TOÀN BỘ Task trong Workspace, không bị filter ẩn | Chưa test |
| TC-03 | Task Detail hiện đúng nút theo allowedActions | Mục 4.2 | Nút Start/Submit/Approve/Reject/Withdraw khớp `allowedActions` response, không tự suy luận | Chưa test |
| TC-04 | Creator bấm Start (TODO→IN_PROGRESS) | Approval Sequence | `POST /start` với `expectedRevision` đúng → chuyển IN_PROGRESS | Chưa test |
| TC-05 | Creator bấm Submit (IN_PROGRESS→IN_REVIEW) | Approval Sequence | reviewStep=MANAGER | Chưa test |
| TC-06 | Manager Approve, không cần Client | requiresClientApproval=false | Chuyển thẳng FINISHED | Chưa test |
| TC-07 | Manager Approve, cần Client | requiresClientApproval=true | Chuyển IN_REVIEW/CLIENT | Chưa test |
| TC-08 | Client Approve | Flow cuối | Chuyển FINISHED | Chưa test |
| TC-09 | Manager/Client Reject thiếu comment | Mục 6, bắt buộc comment ở UI | Client-side chặn submit nếu comment rỗng | Chưa test |
| TC-10 | Reject thành công | Approval Sequence | Chuyển IN_PROGRESS | Chưa test |
| TC-11 | Creator Withdraw trước Manager decision | Mục 6 | Chuyển IN_PROGRESS, hợp lệ | Chưa test |
| TC-12 | Creator Withdraw sau khi đã ở reviewStep=CLIENT | Mục 6, edge case | Nút Withdraw không hiện/disable — đã qua Manager decision | Chưa test |
| TC-13 | expectedRevision lệch (409 conflict) | Mục 5 | Thông báo thân thiện, refetch workflow+review, không chỉ revert giá trị cũ | Chưa test |
| TC-14 | Kanban kéo card đúng transition | Mục 4.3 | TODO→IN_PROGRESS/IN_PROGRESS→IN_REVIEW/IN_REVIEW→FINISHED/IN_REVIEW→IN_PROGRESS hoạt động đúng role | Chưa test |
| TC-15 | Kanban kéo card sai transition | Mục 4.3 edge case | Card bật lại vị trí cũ + toast lỗi, không gọi API | Chưa test |
| TC-16 | Kanban kéo reject phải mở dialog comment | Mục 4.3 | Không chuyển cột im lặng, bắt buộc nhập comment trước khi commit | Chưa test |
| TC-17 | Comment Thread gửi text đơn giản | FR 3.6.3 | Hiện ngay trong thread (optimistic), lưu thành công | Chưa test |
| TC-18 | Comment đính kèm ảnh (≤5 ảnh, ≤5MB/ảnh) | Mục 4.4 | Upload qua `comment-uploads` lấy `attachmentIds` trước, rồi gửi comment | Chưa test |
| TC-19 | Comment đính kèm vượt quá 5 ảnh hoặc ảnh >5MB | Validate client-side | Chặn trước khi gọi API, không để user chờ rồi bị reject | Chưa test |
| TC-20 | Comment mention autocomplete | Mục 4.4 | Gõ `@` gọi `comment-members`, hiện gợi ý đúng | Chưa test |
| TC-21 | Comment trên Task FINISHED/CANCELLED | Mục 4.4, vẫn khả dụng | Tab comment không bị ẩn, vẫn gửi được | Chưa test |
| TC-22 | Mất mạng giữa khi gửi comment | Mục 4.4, clientRequestId idempotent | Retry không tạo comment trùng | Chưa test |
| TC-23 | Polling realtime khi Task Detail mở | Mục 5 | Status/comment mới cập nhật trong 15-30s, không cần refresh tay | Chưa test |
| TC-24 | App vào background rồi foreground lại | Mục 5 | Polling resume đúng, không duplicate request | Chưa test |

> **SUPERSEDED for new implementation — 2026-10-18:** tài liệu này giữ lịch sử đề xuất ngày 16/10, không dùng làm checklist hiện hành hoặc lệnh APPLY. Xem [spec FR3.6.9 v3](../3-6-9-approval-sequence-creator-manager-client/spec.md), [plan](../3-6-9-approval-sequence-creator-manager-client/plan.md), [task](../3-6-9-approval-sequence-creator-manager-client/task.md), [test](../3-6-9-approval-sequence-creator-manager-client/test.md). Đã chốt /editor, một bản hiện tại không review snapshots, withdraw trước Manager decision và một Client bất kỳ. Task structure đã triển khai riêng; Approval mới hoàn thành tài liệu giai đoạn 1.

> Checkpoint 2026-10-17 (historical): Task structure removal of QC/plannedPublishAt and Atlas metadata APPLY were implemented separately; earlier inventory/results below are dated history, not current-state evidence.

# Test plan — Task/Approval simplification

Ngày: 2026-10-16. **Kịch bản dự kiến, chưa phải kết quả đã chạy.**

| Nhóm | Kịch bản / kết quả mong đợi |
|---|---|
| Inventory | DRY_RUN không sửa document/schema/index; phát hiện QC, thiếu reviewStep, duplicate quyết định, metadata conflict |
| Compatibility | Code hiện tại còn plannedPublishAt vẫn qua TaskWorkflowSchema.ready; old reader/writer không hỏng khi schema mở rộng |
| Data preservation | Task/content/approval history cũ không đổi; không tự link Post–Task hoặc suy first-start evidence |
| Unique decision | Một Task/lượt/bước chỉ có một quyết định; 2 request đồng thời không tạo approve/reject trùng hoặc chuyển bước hai lần |
| Scope/role | Chỉ active member đúng bước được duyệt; Creator chỉ submit Task được giao; Client không duyệt bước Manager; ID khác Workspace bị từ chối |
| Round | Manager reject: 1 quyết định; Manager+Client: tối đa 2; resubmit tạo lượt mới, không tái sử dụng approval cũ |
| Review note | Reject thiếu lý do bị chặn; comment Task không thành approval; legacy comment được đọc đúng nếu đổi reviewNote, conflict không tự ghi đè |
| Task–Post | Unique task_id cho link mới, Post độc lập không bị ép có Task; type/Workspace sai bị từ chối; không chặn Post cũ chỉ vì validator legacy |
| QC removal | Writer mới không gán/chuyển QC; legacy record/history giữ nguyên cho đến migration allowlist được duyệt |
| Dates/CAS | Giữ dueDate/date bounds; nhiều tab hoặc start/cancel đồng thời dùng revision để chặn ghi đè; không parse deadline từ description |
| Notification | Chuyển bước báo người duyệt tiếp theo; reject báo Creator; không gửi nhầm role, không trùng và không làm hỏng notification giao việc |
| Transaction | Task + quyết định + outbox cùng Mongo transaction; lỗi rollback không để lịch sử/trạng thái nửa chừng |
| Operational | Rehearsal cô lập, script rerun an toàn; conflict dừng trước ghi; DDL áp một phần có hướng recovery được review |
| Regression | Campaign deployment/closure, Content Request acceptance, Task assignment/start/detail, Post/editor/publishing hợp đồng cũ không đổi |
| Deferred | Không coi snapshot/thu hồi đã làm; integration test content locking/version chỉ bổ sung sau khi chủ Content Writing chốt contract |

Không gửi bài thật lên social hoặc chạy seed/init Atlas trong test tự động. Không tuyên bố toàn FR hoàn tất chỉ dựa vào test schema.

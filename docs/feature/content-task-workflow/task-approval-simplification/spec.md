> **SUPERSEDED for new implementation — 2026-10-18:** tài liệu này giữ lịch sử đề xuất ngày 16/10, không dùng làm checklist hiện hành hoặc lệnh APPLY. Xem [spec FR3.6.9 v3](../3-6-9-approval-sequence-creator-manager-client/spec.md), [plan](../3-6-9-approval-sequence-creator-manager-client/plan.md), [task](../3-6-9-approval-sequence-creator-manager-client/task.md), [test](../3-6-9-approval-sequence-creator-manager-client/test.md). Đã chốt /editor, một bản hiện tại không review snapshots, withdraw trước Manager decision và một Client bất kỳ. Task structure đã triển khai riêng; Approval mới hoàn thành tài liệu giai đoạn 1.

> Checkpoint 2026-10-17 (historical): Task structure removal of QC/plannedPublishAt and Atlas metadata APPLY were implemented separately; earlier inventory/results below are dated history, not current-state evidence.

# Task và Approval — phương án đơn giản hóa

Ngày: 2026-10-16. Trạng thái: **DRAFT — chờ team review, chưa triển khai thay đổi này**.

Phạm vi: FR 3.6.1/3.6.2 (DA-978), FR 3.6.9 (DA-E51-03). Người dùng xác nhận tiếp nhận FR 3.6.9 từ Phước; cần đồng bộ phân công trên Jira/master plan với team. Không tự tuyên bố Jira đã cập nhật.

## 1. Nguồn và thứ tự ưu tiên

- Quyết định người dùng trong trao đổi ngày 2026-10-16 được ghi lại bên dưới để team review.
- [BA Task](../../../ba/05-content-task-workflow.md), [state machines](../../../ba/12-state-machines.md), [spec Approval cũ](../3-6-9-approval-sequence-creator-manager-client/spec.md), [contract hiện có](../task-workflow-contract.md).
- [Team guide](../../../team_guide.md), [quy trình feature](../../../rule/feature-workflow.md).
- Tài liệu cũ còn QC/ngày đăng dự kiến; KHÔNG tự sửa tài liệu chung hoặc coi code hiện tại đã đáp ứng phương án này. Sau review phải đồng bộ nguồn BA/spec chung trước implement.

## 2. Quyết định đã chốt

- Giữ một workflow Task chung cho POST, LIVESTREAM, SURVEY, EVENT_PLAN, PRESS_RECOMMENDATION; tích hợp nội dung POST trước, các loại khác phối hợp chủ module.
- Giữ 5 trạng thái: TODO / IN_PROGRESS / IN_REVIEW / FINISHED / CANCELLED. reviewStep tách riêng, luồng mới chỉ MANAGER → CLIENT nếu requiresClientApproval=true.
- Bỏ review chéo/QC trong luồng mới. Không đổi role hệ thống, không xóa lịch sử QC cũ.
- Chỉ Creator được giao bấm bắt đầu. Sau lần bắt đầu đầu tiên Manager không sửa brief/deadline/giao lại; reject không mở khóa các quyền này.
- Reject bắt buộc lý do, Task về IN_PROGRESS; gửi lại duyệt từ Manager. Bước cuối approve mới FINISHED; chưa hỗ trợ mở lại FINISHED.
- Giữ dueDate dạng dữ liệu có cấu trúc và workflowRevision chống xung đột. Bỏ plannedPublishAt khỏi nghiệp vụ mới; description chứa yêu cầu chi tiết, kể cả hướng dẫn thời điểm đăng nếu cần. Không suy dueDate bằng cách parse description.
- Task POST liên kết tối đa một Post; chưa tạo nội dung thì có thể chưa có Post. Post độc lập vẫn được giữ. Các loại content khác liên kết Task ở module tương ứng, không ép tất cả thành Post.
- task_approvals lưu từng quyết định APPROVE/REJECT, nhóm theo taskId + approvalRound. Không tạo sẵn quyết định cho người chưa duyệt. Một lượt có tối đa 2 quyết định trong luồng hiện tại.
- Nhận xét về nội dung khi duyệt khác bình luận công việc: quyết định duyệt lưu ở task_approvals; trao đổi Task thuộc task_comments/FR 3.6.3, không thay thế lẫn nhau.
- Thông báo trong ứng dụng: chuyển bước gửi người duyệt tiếp theo; reject gửi Creator. Không thêm email.
- FINISHED không tự publish. Không thay Editor/Content Writing, AI, publishing Facebook/RabbitMQ của thành viên khác.

## 3. Entity Task đích

| Nhóm | Field giữ lại |
|---|---|
| Định danh/phạm vi | _id, workspaceId, campaignId, campaignWorkItemId |
| Yêu cầu | type, name, description, dueDate, inputReferences |
| Giao việc | assigneeId, requiresClientApproval, assignedBy, assignedAt |
| Workflow | status, reviewStep, approvalRound, workflowRevision |
| Nguồn | sourceType, sourceRefId, typeMetadata |
| Audit | firstStartedBy, firstStartedAt, cancellation, createdBy, createdAt, updatedAt |

plannedPublishAt, qcAssigneeId, detailIdentifiedAt/By là field legacy/deprecated, không dùng trong UI/luồng mới. Deprecate không đồng nghĩa xóa vật lý ngay. reviewStep phải trống ngoài IN_REVIEW ở writer mới; legacy thiếu dữ liệu được kiểm kê riêng.

task_approvals giữ _id, taskId, approvalRound, step, action, actorId, nhận xét duyệt, createdAt. Tên nhận xét hiện là comment; đề xuất reviewNote để rõ nghĩa nhưng cần team chốt tên contract trước migration rename. Không đổi tên collection.

## 4. Những điểm CHƯA chốt / hoãn

- Snapshot: Q2 trước đó đã chọn duyệt snapshot. Sau đó người dùng yêu cầu TẠM HOÃN quyết định/triển khai snapshot vì Content Writing do thành viên khác phụ trách. Không coi đây là quyết định bỏ snapshot hoặc đổi sang duyệt live content.
- Không thêm snapshotId/reviewContentVersion vào Task/Approval trong đợt chuẩn bị DB này; không chạy migration post_versions chỉ vì kế hoạch này. Cơ chế đóng băng/phiên bản nội dung phải được phối hợp trước nghiệm thu Approval end-to-end.
- Thu hồi: đã nêu nhu cầu ở Q3 nhưng quyền, thời điểm và điều kiện chưa chốt. Chưa bổ sung action SUBMIT/WITHDRAW vào task_approvals trong thiết kế đợt này. Submit API tương lai có thể tăng lượt/cập nhật Task mà không tạo row quyết định.
- Legacy: chưa có phê duyệt chuyển Task đang QC hoặc thiếu reviewStep về IN_PROGRESS hay sang MANAGER. Cần allowlist/đề xuất riêng, không tự backfill lịch sử bắt đầu.
- Định dạng content/snapshot của Livestream/Survey/Event do module phụ trách thống nhất; EVENT_PLAN chỉ bàn giao kế hoạch, không thêm vận hành sự kiện.

## 5. Điều kiện review

Team xác nhận phạm vi/contract với Phước và chủ Content Writing; rà soát nguồn BA chung; chốt reviewNote hay giữ comment; chốt xử lý dữ liệu cũ. Chưa đóng FR hoặc coi DB migration là hoàn thành chức năng duyệt.

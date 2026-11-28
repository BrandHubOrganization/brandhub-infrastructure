> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md) · [BA Governance →](../../../../ba/13-task-status-and-approval-governance.md)

# Technical Implementation Plan — FR 3.6.9: Approval Sequence & Multi-Role Task Status Governance (v4.0)

> Triển khai kỹ thuật dựa trên [spec.md (v4.0)](./spec.md) và [BA 13 — Quản trị Trạng thái & Phê duyệt Đa tầng](../../../../ba/13-task-status-and-approval-governance.md).

---

## 1. Thành phần Hệ thống & Danh mục File Chạm tới

| Tầng / Repository | File & Class Chạm tới | Trách nhiệm Thay đổi Kỹ thuật |
| :--- | :--- | :--- |
| **Backend — Task Status & Creation (`brandhub-business-service`)** | `service/impl/task/TaskServiceImpl.java`<br/>`exception/ErrorCode.java` | 1. Khóa `updateStatus()`: chặn `IN_REVIEW` và `FINISHED` (`409 TASK_WORKFLOW_REQUIRED`) đối với mọi Task thuộc quy trình duyệt; chặn `Creator` chuyển sang `CANCELLED` (`403 FORBIDDEN`), khi `Owner`/`Manager` hủy thì ghi `Cancellation`, dọn `reviewStep` và hủy lịch đăng.<br/>2. Sửa `createTask()` & `createStandaloneTask()`: khi người tạo là `Creator` và không truyền `supervisorId` hợp lệ khác `assigneeId`, gán `supervisorId = defaultManager` thay vì `currentUser.getId()`. |
| **Backend — Workflow & Platform Policy (`brandhub-business-service`)** | `service/impl/task/TaskWorkflowService.java`<br/>`service/impl/task/TaskPlatformPolicy.java`<br/>`service/impl/media/CampaignSubtaskService.java` | 1. Bổ sung `MemberRole.OWNER` vào `TaskWorkflowService.start()`, `TaskPlatformPolicy.requireManager()`, và `CampaignSubtaskService.canManage()` / `allowed()` trên task mạng xã hội độc lập.<br/>2. Chặn gán `supervisorId == assigneeId` khi `assignee` là `Creator` trong `TaskWorkflowService.field()` & `assign()`.<br/>3. Giới hạn `TaskWorkflowService.partners()` chỉ cho `Owner`, `Manager` và người tham gia trực tiếp vào Task (`participant`).<br/>4. Sửa `CampaignSubtaskService.supervisor()` kế thừa `task.getSupervisorId()` trước khi fallback. |
| **Backend — Section & Auto-Settlement (`brandhub-business-service`)** | `service/impl/workspace/SectionPolicy.java`<br/>`service/impl/workspace/SectionService.java`<br/>`service/impl/workspace/SectionNotifier.java` | 1. Bổ sung đầy đủ quyền `MemberRole.OWNER` ngang `MemberRole.MANAGER` trong `SectionPolicy` (`EDIT`, `RESTORE`, `SUBMIT` qua `coordinator`, `APPROVE`, `RETURN`, `REOPEN`).<br/>2. Kế thừa `task.getSupervisorId()` trong `SectionPolicy.supervisor()` & `SectionNotifier.reviewers()`, đảm bảo `Task Supervisor` (kể cả `Creator` cấp cao `≠ assignee`) duyệt được các `Section` của Task.<br/>3. Cho phép `Owner`/`Manager` thực hiện `REOPEN` phần trên cả Task `IN_REVIEW` và `FINISHED` (khi bài đăng chưa `PUBLISHING`/`PUBLISHED`), gọi `settle(scope, false, note)` + `cancelSchedule(task)` giống `Client Return`.<br/>4. Tự động chuyển `TODO → IN_PROGRESS` khi `Section Owner` / `Coordinator` lưu nháp phần trên Task hợp lệ.<br/>5. Gọi `approvals.settleSections(scope, true, null)` ngay sau **cả** duyệt nội bộ (`APPROVE`) lẫn duyệt khách hàng (`CLIENT_APPROVE`) tại `SectionService.approve()`. |
| **Backend — Task Approval & Post Guard (`brandhub-business-service`)** | `service/impl/task/TaskApprovalPolicy.java`<br/>`service/impl/task/TaskApprovalService.java`<br/>`service/impl/task/TaskPostService.java`<br/>`service/impl/social/PostPublishServiceImpl.java` | 1. `TaskApprovalPolicy.agencyReviewer()`: cho phép `Owner`, mọi `Manager` active (khác `Creator` nộp) VÀ `task.supervisorId` (khác `assigneeId`) duyệt ở bước `MANAGER`.<br/>2. `TaskApprovalPolicy.skipsAgencyReview()`: chỉ trả `true` khi `assignee` có vai trò `Owner` hoặc `Manager` và `supervisorId.equals(assigneeId)`.<br/>3. `TaskApprovalService.selfApprove()`: chặn hoàn toàn khi `!isPersonal` (`403 TASK_SELF_APPROVE_NOT_ALLOWED`).<br/>4. Mở rộng `TaskApprovalService.settleSections()`: tự động chốt Task cha từ `IN_PROGRESS` → `FINISHED` (khi `!requiresClientApproval` & đủ 100% phần), từ `IN_PROGRESS` → `IN_REVIEW (CLIENT)` (khi `requiresClientApproval` & tất cả phần đạt tối thiểu `INTERNAL_APPROVED`), và từ `IN_PROGRESS` / `IN_REVIEW` → `FINISHED` (khi 100% phần đạt `finalState`).<br/>5. `TaskPostService`: hỗ trợ auto-start `TODO → IN_PROGRESS` khi người có quyền lưu bài nháp hợp lệ.<br/>6. `PostPublishServiceImpl.publishPost()`: kiểm tra người gọi phải là `Owner`, `Manager`, `Coordinator` (trên task đơn) hoặc chủ vai trò `POST_PUBLISHING` / `VIDEO_PUBLISH`. |
| **Web Frontend — Task Detail, Board & List (`brandhub-web`)** | `src/pages/tasks/components/TaskStatusControl.tsx`<br/>`src/pages/tasks/components/TaskWorkflowContent.tsx`<br/>`src/pages/tasks/components/views/hooks/useBoardDragAndDrop.ts`<br/>`src/pages/tasks/components/TaskBulkActionBar.tsx`<br/>`src/hooks/useTaskSections.ts`<br/>`src/components/task-sections/SectionReview.tsx` | 1. `TaskStatusControl.tsx`: render Badge trạng thái tĩnh (bỏ mũi tên `⌄` & menu rỗng) khi `FINISHED` / `CANCELLED` hoặc `available.length === 0`; hiển thị nhãn phụ tiến độ phần (`X/Y phần đã duyệt` / bước chờ duyệt); mở rộng `reviewable` cho mọi `sourceType` (`MANUAL`, `CAMPAIGN_OUT_OF_SCOPE`, `CAMPAIGN`, `CONTENT_REQUEST`) và 8 `TaskType`.<br/>2. `TaskWorkflowContent.tsx`: sửa `canSelfApprove` chỉ bật khi `isPersonalMode === true`.<br/>3. `useBoardDragAndDrop.ts` & `TaskBulkActionBar.tsx`: chặn kéo-thả / đổi hàng loạt sang `IN_REVIEW` và `FINISHED` (hiển thị toast hướng dẫn rõ ràng); ẩn `CANCELLED` đối với `Creator`.<br/>4. `useTaskSections.ts` & `SectionReview.tsx`: kích hoạt callback `onUpdated()` và invalidate `["tasks"]`, `["task-workflow"]`, `["task-review"]`, `["campaign-subtasks"]` sau mọi thao tác Section để danh sách bên ngoài đồng bộ tức thì. |
| **Web Frontend — Editor & Approval Queue (`brandhub-web`)** | `src/pages/editor/index.tsx`<br/>`src/pages/task-approvals/hooks/useApprovalList.ts`<br/>`src/pages/task-approvals/components/ApprovalFilters.tsx` | 1. `editor/index.tsx`: cho phép cả `OWNER` và `MANAGER` chỉnh sửa nền tảng đích (`destinationsReadOnly = Boolean(taskId) && !isPersonalMode && role !== "MANAGER" && role !== "OWNER"`).<br/>2. `useApprovalList.ts` & `ApprovalFilters.tsx`: gỡ bỏ hardcode `type: "POST"`, hỗ trợ truy vấn và lọc đủ **8 loại `TaskType`**. |
| **Đa ngôn ngữ (i18n) & Theme (`brandhub-web`)** | `src/i18n/locales/vi/tasks.json`<br/>`src/i18n/locales/en/tasks.json`<br/>`src/i18n/locales/vi/editor.json`<br/>`src/i18n/locales/en/editor.json` | Bổ sung đồng bộ song song (`key-parallel`) các khóa dịch cho nhãn tiến độ trạng thái, thông báo chặn nhảy cóc Kanban/Bulk, bộ lọc loại công việc trên `/task-approvals` và thông báo lỗi phân quyền. |

---

## 2. Thiết kế Chi tiết Thuật toán Tự động Chốt Trạng thái (`settleSections` v4.0)

Không thay đổi schema vật lý của MongoDB hay PostgreSQL (giữ tương thích ngược 100% với toàn bộ dữ liệu hiện có). Thuật toán `TaskApprovalService.settleSections(Scope scope, boolean approved, String note)` được nâng cấp để xử lý nguyên tử trong Mongo Transaction:

1. **Khi một phần bị trả lại hoặc mở lại (`approved == false`)**:
   - Nếu Task đang ở `FINISHED` (và `PostDocument` chưa `PUBLISHING`/`PUBLISHED`) hoặc đang ở `IN_REVIEW`:
     - Ghi nhận sự kiện mở lại/từ chối vào `task_approvals` để bảo toàn bất biến `closedSubmission` của `TaskApprovalPolicy`.
     - Chuyển `task.status = "IN_PROGRESS"`, `task.reviewStep = null`, `task.finishedAt = null`, tăng `workflowRevision + 1`.
     - Chuyển `PostDocument` liên kết về `"DRAFT"` và hủy lịch hẹn giờ (`cancelSchedule`).
2. **Khi một phần được duyệt nội bộ hoặc duyệt bởi `Client` (`approved == true`)**:
   - Kiểm tra điều kiện tiên quyết của Task (`roleTask(task) == true`, không còn công việc con tự do mở `!hasOpenSubtasks`, và nếu là `POST`/`SHORT_VIDEO` thì `PostDocument` đã có `caption` không trống).
   - Tự động đóng nội bộ (`approveUnowned`) đối với các phần không có `Subtask` vai trò sở hữu riêng khi toàn bộ các phần có chủ sở hữu đã đạt `INTERNAL_APPROVED` / `CLIENT_APPROVED`.
   - Tính 2 cờ trạng thái tổng hợp trên toàn bộ `TaskCatalog.sectionsOf(task.getType())`:
     - `allInternallyApproved`: Mọi phần đều đạt `INTERNAL_APPROVED` hoặc `CLIENT_APPROVED`.
     - `allFinal`: Mọi phần đều thỏa `SectionPolicy.isFinal(section, task.isRequiresClientApproval(), status)`.
   - **Nhánh 1 (`allFinal == true` và `task.status` đang là `IN_PROGRESS` hoặc `IN_REVIEW`)**:
     - Chốt nguyên tử `task.status = "FINISHED"`, `task.reviewStep = null`, `task.finishedAt = now`, cập nhật `lastSubmission` với `outcome = "APPROVED"`, ghi bản ghi quyết định vào `task_approvals`, chuyển `PostDocument.status` sang `"SCHEDULED"` (nếu `publishDate != null`) hoặc `"APPROVED"`, và phát thông báo outbox.
   - **Nhánh 2 (`allInternallyApproved == true && !allFinal` — tức `requiresClientApproval == true` và còn phần `OUTPUT` đang chờ `Client`)**:
     - Nếu `task.status` đang là `"IN_PROGRESS"`, chuyển nguyên tử `task.status = "IN_REVIEW"`, `task.reviewStep = "CLIENT"`, cập nhật `lastSubmission` mở vòng hiện tại, và chuyển `PostDocument.status` sang `"PENDING_APPROVAL"`.

---

## 3. Kế hoạch Đa ngôn ngữ (i18n) & Giao diện Light/Dark

- **Các file i18n cập nhật đồng thời (`vi` ↔ `en`)**:
  - `brandhub-web/src/i18n/locales/vi/tasks.json` & `brandhub-web/src/i18n/locales/en/tasks.json`:
    - `tasks.workflow.progressApproved`: `"{{done}}/{{total}} phần đã duyệt"` / `"{{done}}/{{total}} sections approved"`
    - `tasks.workflow.waitingManager`: `"Chờ Quản lý duyệt"` / `"Waiting for Manager"`
    - `tasks.workflow.waitingClient`: `"Chờ Khách hàng duyệt"` / `"Waiting for Client"`
    - `tasks.workflow.approvedReady`: `"Đã hoàn tất phê duyệt"` / `"Approval completed"`
    - `tasks.board.cannotBypassApproval`: `"Không thể chuyển thẳng sang trạng thái này. Vui lòng gửi duyệt và phê duyệt trong chi tiết công việc."` / `"Cannot jump directly to this status. Please submit and approve via the task workflow."`
    - `tasks.approvalPage.allTypes`: `"Tất cả loại công việc"` / `"All task types"`
  - `brandhub-web/src/i18n/locales/vi/editor.json` & `brandhub-web/src/i18n/locales/en/editor.json`: đồng bộ thông báo khóa/mở lại phần.
- **Chuẩn Light / Dark Mode**:
  - Badge trạng thái tĩnh và nhãn phụ tiến độ trong `TaskStatusControl.tsx` sử dụng hệ màu semantic hiện có của `STATUS_CONFIG` (`emerald-500/10`, `amber-500/10`, `blue-500/10`, `border-border`, `text-muted-foreground` kèm `dark:text-*`), không dùng bất kỳ mã màu hex cứng nào.

---

## 4. Thứ tự Triển khai & Kiểm soát Rủi ro

1. **Bước 1 — Backend Policy & Guards (`brandhub-business-service`)**: Cập nhật `ErrorCode`, `SectionPolicy`, `TaskApprovalPolicy`, `TaskPlatformPolicy`, `TaskServiceImpl`, `TaskWorkflowService`, `CampaignSubtaskService`.
2. **Bước 2 — Backend Auto-Settlement & Publish Guard (`brandhub-business-service`)**: Cập nhật `SectionService`, `TaskApprovalService`, `TaskPostService`, `PostPublishServiceImpl` và viết/chạy bộ JUnit 5 kiểm chứng toàn bộ ma trận vai trò & chuyển trạng thái.
3. **Bước 3 — Frontend Controls, Kanban/Bulk Guards, Approval Queue & Cache Sync (`brandhub-web`)**: Cập nhật `TaskStatusControl`, `TaskWorkflowContent`, `useBoardDragAndDrop`, `TaskBulkActionBar`, `useTaskSections`, `SectionReview`, `editor/index.tsx`, `useApprovalList`, `ApprovalFilters`.
4. **Bước 4 — Đồng bộ i18n (`vi`/`en`) & Kiểm định Light/Dark + Build/Test**: Cập nhật locale JSON song ngữ, chạy Vitest, `npx tsc -b`, `npx vite build` và kiểm tra trực quan.

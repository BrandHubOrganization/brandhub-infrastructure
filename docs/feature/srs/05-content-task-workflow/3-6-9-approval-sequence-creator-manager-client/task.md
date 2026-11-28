> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · **Task** · [Test](./test.md) · [BA Governance →](../../../../ba/13-task-status-and-approval-governance.md)

# Task Checklist — FR 3.6.9: Approval Sequence & Multi-Role Task Status Governance (v4.0)

> Phân rã công việc tuần tự ánh xạ trực tiếp từ [spec.md (v4.0)](./spec.md) và [plan.md (v4.0)](./plan.md). Thực thi tuần tự sau khi đặc tả BA & Spec được chốt.

---

## Giai đoạn 1–5 — Nền tảng Phê duyệt Cốt lõi (Đã hoàn thành ở các đợt trước)

- [x] Khởi tạo schema, index và CAS cho `tasks`, `posts`, `task_approvals`, `task_sections`, `task_section_versions`, `task_section_events`, `task_notification_outbox`.
- [x] Xây dựng cụm API `TaskApprovalController`, `TaskSectionController`, `TaskPostController` và trang `/workspaces/:id/task-approvals` ban đầu.

---

## Giai đoạn 6 — Chuẩn hóa Phân quyền Đa Vai trò, Tự động Chốt Trạng thái & Chống Nhảy cóc (v4.0 — Đợt hiện tại)

### 6.1. Backend — Phân quyền `Owner`, `Người giám sát` (`Supervisor`) & Chống Tự Giám Sát (`Plan §1`)
- [x] **T6.01 — Đồng bộ toàn quyền `Owner` ngang `Manager`:** Cập nhật `SectionPolicy.java`, `TaskWorkflowService.start()`, `TaskPlatformPolicy.requireManager()`, và `CampaignSubtaskService.java` để `MemberRole.OWNER` thực hiện đầy đủ các quyền điều hành, chọn nền tảng, quản lý việc con, sửa/nộp/duyệt/trả lại/mở lại `TaskSection` và bắt đầu `Task`.
- [x] **T6.02 — Chuẩn hóa kế thừa `task.supervisorId` & Chống tự giám sát (`BR-34a`):**
  - Sửa `TaskServiceImpl.createTask()` & `createStandaloneTask()` gán `supervisorId = defaultManager` khi `Creator` tạo việc (không gán ID của chính `Creator`).
  - Sửa `TaskWorkflowService.field()` / `assign()` chặn gán `supervisorId == assigneeId` khi `assignee` là `Creator`.
  - Sửa `SectionPolicy.supervisor()`, `SectionNotifier.reviewers()` và `CampaignSubtaskService.supervisor()` kế thừa `task.getSupervisorId()` trước khi fallback.
  - Sửa `TaskApprovalPolicy.agencyReviewer()` và `skipsAgencyReview()` để mọi `Owner`/`Manager` active (khác `Creator` nộp) cùng `task.supervisorId` đều duyệt được, và chỉ `Owner`/`Manager` tự làm mới được skip bước duyệt nội bộ.
- [x] **T6.03 — Khóa quyền `Creator` ngoài luồng trên `Partners` & `Publish`:** Cập nhật `TaskWorkflowService.partners()` và `PostPublishServiceImpl.publishPost()` chỉ cho phép `Owner`, `Manager` và nhân sự tham gia trực tiếp / giữ vai trò xuất bản của Task.

### 6.2. Backend — Tự động Chốt Trạng thái (`Auto-Settlement`), Auto-Start & Chống Nhảy Cóc (`Plan §1–§2`)
- [x] **T6.04 — Khóa API `PATCH /tasks/{taskId}/status` (`TaskServiceImpl.updateStatus`):** Chặn chuyển trực tiếp sang `IN_REVIEW` hoặc `FINISHED` (`409 TASK_WORKFLOW_REQUIRED`); giới hạn `CANCELLED` chỉ cho `Owner` và `Manager` kèm dọn `reviewStep` và hủy lịch đăng.
- [x] **T6.05 — Giới hạn `selfApprove` chỉ cho chế độ `PERSONAL`:** Cập nhật `TaskApprovalService.selfApprove()` trả `403 TASK_SELF_APPROVE_NOT_ALLOWED` đối với mọi Workspace chế độ `AGENCY`.
- [x] **T6.06 — Tự động chuyển trạng thái Task cha (`SectionService` & `TaskApprovalService.settleSections`):**
  - Khi 100% phần đạt `INTERNAL_APPROVED` trên Task `requiresClientApproval = false` → tự động chốt Task cha sang `FINISHED` và đồng bộ `PostDocument` (`SCHEDULED` / `APPROVED`).
  - Khi 100% phần đạt tối thiểu `INTERNAL_APPROVED` trên Task `requiresClientApproval = true` (còn phần `OUTPUT` chờ `Client`) → tự động chuyển Task cha sang `IN_REVIEW` (`reviewStep = "CLIENT"`).
  - Khi 100% phần đạt `finalState = true` → tự động chốt Task cha sang `FINISHED` (kể cả khi `Client` duyệt sớm trước phần `INTERNAL` cuối cùng).
- [x] **T6.07 — Mở rộng `REOPEN` cho `Owner`/`Manager` & Auto-Start khi lưu phần ở `TODO`:** Cho phép `Owner`/`Manager` mở lại phần trên Task `IN_REVIEW` / `FINISHED` chưa xuất bản (tự đưa Task về `IN_PROGRESS` và hủy lịch đăng); đồng bộ auto-start `TODO → IN_PROGRESS` khi `Section Owner` / `Coordinator` lưu nháp hợp lệ trong `SectionService` và `TaskPostService`.

### 6.3. Web Frontend — UX Trạng thái, Chống Nhảy Cóc Kanban/Bulk, Hàng đợi 8 `TaskType` & Đồng bộ Danh sách (`Plan §1`)
- [x] **T6.08 — Nâng cấp `TaskStatusControl.tsx` & `TaskWorkflowContent.tsx`:**
  - Hiển thị Badge trạng thái tĩnh (ẩn mũi tên `⌄` và bỏ menu rỗng) khi đã `FINISHED` / `CANCELLED` hoặc không có hành động hợp lệ.
  - Hiển thị nhãn ngữ cảnh tiến độ (`X/Y phần đã duyệt` / bước chờ duyệt) ngay trên thanh tiêu đề Task Detail.
  - Mở rộng `reviewable` cho mọi `sourceType` được hỗ trợ; thu hẹp `canSelfApprove` trong `TaskWorkflowContent.tsx` chỉ còn `isPersonalMode`.
- [x] **T6.09 — Khóa kéo-thả Kanban (`useBoardDragAndDrop.ts`) & Thanh thao tác hàng loạt (`TaskBulkActionBar.tsx`):** Chặn thả thẻ / đổi hàng loạt nhảy cóc sang `IN_REVIEW` và `FINISHED`; ẩn tùy chọn `CANCELLED` đối với `Creator`.
- [x] **T6.10 — Mở rộng `/task-approvals` đủ 8 loại `TaskType` & mở khóa chọn kênh cho `Owner` trong `Editor`:** Cập nhật `useApprovalList.ts`, `ApprovalFilters.tsx` và `src/pages/editor/index.tsx`.
- [x] **T6.11 — Đồng bộ tức thì danh sách bên ngoài:** Kết nối `onUpdated()` và invalidate queries đồng bộ trong `useTaskSections.ts`, `SectionReview.tsx`, `TaskEditorControls.tsx` và `TaskExportButton.tsx`.

### 6.4. Đa ngôn ngữ (`vi.json` + `en.json`), Light/Dark Mode & Kiểm thử Tổng thể (`Plan §3–§4`)
- [x] **T6.12 — Cập nhật `vi` + `en` song song (`key-parallel`):** Bổ sung đầy đủ khóa dịch mới trong `src/i18n/locales/{vi,en}/tasks.json` và `src/i18n/locales/{vi,en}/editor.json`, xác nhận không có chuỗi hardcode.
- [x] **T6.13 — Kiểm tra Light/Dark mode & Responsive:** Đối chiếu hiển thị semantic tokens của `TaskStatusControl`, `TaskBulkActionBar`, `TaskBoardView` và `/task-approvals` ở cả Light mode và Dark mode (`375px`, `768px`, `1440px`).
- [x] **T6.14 — Chạy bộ kiểm thử tự động Backend & Frontend:** Thực thi JUnit 5 trên `brandhub-business-service` và Vitest + `tsc -b` + `vite build` trên `brandhub-web`, đối chiếu toàn bộ kịch bản trong [test.md](./test.md).

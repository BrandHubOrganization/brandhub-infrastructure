> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test** · [BA Governance →](../../../../ba/13-task-status-and-approval-governance.md)

# Test Specification — FR 3.6.9: Approval Sequence (Creator -> Manager -> Client)

## 1. Traceability & Execution Summary (Baseline Report 5 Unit Suite)

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.9` |
| **Function Name** | Approval Sequence (Creator -> Manager -> Client) |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `TaskApprovalService.approve()`, `SectionService.approve()`, `SectionPolicy.check()`, `TaskServiceImpl.updateStatus()` |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/TaskApprovalServiceTest.java` |
| **Test Requirement** | Enforce multi-stage approval workflow (`Creator -> Owner/Manager/Supervisor -> Client`), automatic parent task settlement, anti-self-supervision, and anti-bypass guards |
| **Preconditions** | Can connect with server; Task exists in workspace |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID21` — Synchronized with `Report5_Unit Test.xls`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR of workspace; Task status is ASSIGNED, no QC, no client approval | `action` = `submit` | 200 OK - status=MANAGER_REVIEW | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR of workspace; Task status is ASSIGNED, QC assigned | `action` = `submit` | 200 OK - status=QC_REVIEW | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR of workspace; Task status is ASSIGNED, QC approval already passed | `action` = `submit` | 200 OK - status=MANAGER_REVIEW (skip QC) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR of workspace; Task status is ASSIGNED, QC and Manager approvals passed | `action` = `submit` | 200 OK - status=CLIENT_REVIEW (skip QC, Manager) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is QC assignee; Task status is QC_REVIEW | `action` = `approve`, `step` = `qc` | 200 OK - status=MANAGER_REVIEW | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is MANAGER of workspace; Task status is MANAGER_REVIEW, no client approval | `action` = `approve`, `step` = `manager` | 200 OK - status=COMPLETED | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MANAGER of workspace; Task status is MANAGER_REVIEW, requiresClientApproval=true | `action` = `approve`, `step` = `manager` | 200 OK - status=CLIENT_REVIEW | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is CLIENT of workspace; Task status is CLIENT_REVIEW | `action` = `approve`, `step` = `client` | 200 OK - status=COMPLETED | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; User is QC assignee; Task status is QC_REVIEW | `action` = `reject`, `step` = `qc`, `reason` = `needs fix` | 200 OK - status=ASSIGNED | — | **Passed** |
| `UTCID10` | `N` | Can connect with server; User is MANAGER of workspace; Task status is MANAGER_REVIEW, QC approved | `action` = `reject`, `step` = `manager`, `reason` = `needs fix` | 200 OK - status=ASSIGNED, QC approval kept | — | **Passed** |
| `UTCID11` | `N` | Can connect with server; User is CLIENT of workspace; Task status is CLIENT_REVIEW, Manager approved | `action` = `reject`, `step` = `client`, `reason` = `needs fix` | 200 OK - status=ASSIGNED, Manager approval kept | — | **Passed** |
| `UTCID12` | `N` | Can connect with server; User is MANAGER of workspace; Task has 3 approval records | `action` = `list approvals` | 200 OK - list(step, action, actorId, comment, createdAt) | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is CREATOR of workspace; Task status is ASSIGNED, no QC, no client approval | `action` = `submit`, `path` = `shortest chain` | 200 OK - submit then manager approve gives COMPLETED (2 steps) | — | **Passed** |
| `UTCID14` | `B` | Can connect with server; User is MANAGER of workspace; Task status is MANAGER_REVIEW | `action` = `reject`, `step` = `manager`, `reason` = `1 char` | 200 OK - status=ASSIGNED | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Task status is QC_REVIEW; User is CLIENT of workspace | `action` = `approve`, `step` = `client` | 403 WRONG_APPROVAL_STEP | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Task status is QC_REVIEW; User is MANAGER of workspace | `action` = `approve`, `step` = `manager` | 403 WRONG_APPROVAL_STEP | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Task status is QC_REVIEW; User is another creator (not QC) | `action` = `approve`, `step` = `qc` | 403 WRONG_APPROVAL_STEP | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is MANAGER of workspace; Task status is ASSIGNED (not submitted) | `action` = `approve`, `step` = `manager` | 409 TASK_NOT_SUBMITTED | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; User is MANAGER of workspace; Task status is MANAGER_REVIEW | `action` = `reject`, `step` = `manager`, `reason` = `null` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; User is CREATOR of workspace; User is not the assignee | `action` = `submit` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; User is MANAGER of workspace; Task does not exist | `action` = `approve`, `step` = `manager` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |

---

## 3. Multi-Role & Auto-Settlement Acceptance Test Matrix (v4.0 — `TA-44` to `TA-62`)

Bộ kịch bản kiểm chứng toàn diện cho các tiêu chí nghiệm thu `AC-01` – `AC-16` trong [spec.md (v4.0)](./spec.md):

| ID | AC | Loại | Vai trò & Điều kiện Đầu vào | Hành động Thực thi | Kết quả Mong đợi |
| :--- | :-: | :-: | :--- | :--- | :--- |
| `TA-44` | `AC-01` | Normal | `Owner` trong Workspace `AGENCY`; Task có `Section` đang `SUBMITTED` | `Owner` bấm `Duyệt` phần, chọn kênh đăng (`targetPlatforms`) và thêm `Subtask` | `200 OK`; phần chuyển `INTERNAL_APPROVED`, kênh đăng được cập nhật, không bị chặn bởi lỗi chỉ cho `Manager`. |
| `TA-45` | `AC-01` | Normal | `Owner` tự nhận `assigneeId` trên Task đang `TODO` | `Owner` bấm `Bắt đầu làm` (`POST /tasks/{id}/start`) | `200 OK`; Task chuyển `IN_PROGRESS` (không còn lỗi `403 FORBIDDEN`). |
| `TA-46` | `AC-02` | Normal | Senior `Creator` được gán làm `task.supervisorId` (khác `assigneeId`), `Subtask` không có `supervisorOverrideId` | Senior `Creator` bấm `Approve` / `Return` trên `Section` đang `SUBMITTED` | `200 OK`; kế thừa đúng `task.supervisorId`, cho phép duyệt/trả lại nội bộ. |
| `TA-47` | `AC-03` | Normal | Task đã gán `task.supervisorId = User A`, nhưng `Manager B` khác trong Workspace đang trực | `Manager B` bấm `Approve` trên `Section` hoặc `Task` ở bước `MANAGER` | `200 OK`; `Manager B` duyệt hỗ trợ thành công, không gây kẹt khi `User A` vắng mặt. |
| `TA-48` | `AC-04` | Security | `Creator` tạo mới `Standalone Task` (để trống `supervisorId` hoặc truyền chính ID của mình), sau đó bấm `Submit` | Tạo Task → Lưu bài → `POST /submit` | `task.supervisorId` tự động gán về `defaultManager`; `skipsAgencyReview == false`; Task bắt buộc vào `IN_REVIEW / MANAGER`, **không** tự nhảy lên `FINISHED`. |
| `TA-49` | `AC-04` | Security | `Manager` gọi `PATCH /tasks/{id}/field` gán `supervisorId` trùng với `assigneeId` là `Creator` | `PATCH /field` (`supervisorId = creatorId`) | Bị từ chối `400 INVALID_TASK_SUPERVISOR`; giữ nguyên người giám sát hợp lệ. |
| `TA-50` | `AC-05` | Security | `Creator` khác trong Workspace (không tham gia Task hay Subtask) | Gọi `PATCH /partners` hoặc `POST /posts/{postId}/publish` hoặc đọc `Section INTERNAL` | Bị từ chối `403 FORBIDDEN`; phần `INTERNAL` không xuất hiện trong `GET /sections`. |
| `TA-51` | `AC-06` | Security | `Client` truy cập Task có cả phần `INTERNAL` (`POST.BRIEF`) và phần `OUTPUT` (`POST.CAPTION`) | `GET /sections` & xem lịch sử phiên bản (`GET /versions`) | Chỉ nhận phần `OUTPUT` đã `INTERNAL_APPROVED`/`CLIENT_APPROVED`; phần `INTERNAL` ẩn 100%; `GET /versions` trả `403 FORBIDDEN`. |
| `TA-52` | `AC-07` | Normal | Task `POST` đang ở `TODO` (đã đủ Brief & Chiến dịch hợp lệ); `Creator` giữ vai trò `POST_CAPTION` (không phải `task.assigneeId`) mở Editor lưu caption | `POST /tasks/{id}/post` | Hệ thống tự chuyển Task cha `TODO → IN_PROGRESS` và lưu nháp thành công, không báo lỗi khóa nội dung. |
| `TA-53` | `AC-08` | Normal | Task có 5 `Section`, `requiresClientApproval = false`; `Manager` bấm duyệt phần cuối cùng (`5/5`) | `POST /sections/{lastKey}/approve` | Toàn bộ 5 `Subtask` chuyển `FINISHED`, **Task cha tự động chuyển ngay từ `IN_PROGRESS` sang `FINISHED`**, `Post` chuyển `SCHEDULED` / `APPROVED`. |
| `TA-54` | `AC-08` | Normal | Task có 4 `Section`, `requiresClientApproval = true`; `Manager` duyệt đủ 4/4 phần nội bộ | `POST /sections/{lastKey}/approve` (bởi `Manager`), sau đó `Client` duyệt phần `OUTPUT` cuối cùng | Sau bước `Manager`: Task cha tự chuyển `IN_PROGRESS → IN_REVIEW (CLIENT)`. Sau bước `Client` cuối cùng: **Task cha tự chuyển sang `FINISHED`**. |
| `TA-55` | `AC-08` | Edge | `requiresClientApproval = true`; `Client` đã duyệt xong 3 phần `OUTPUT` trước khi `Manager` duyệt xong phần `POST.BRIEF` (`INTERNAL`) | `Manager` bấm `Approve` phần `POST.BRIEF` cuối cùng | Ngay khi `POST.BRIEF` đạt `INTERNAL_APPROVED`, 4/4 phần đều `finalState = true` → **Task cha tự chuyển ngay sang `FINISHED`**. |
| `TA-56` | `AC-09` | Normal | Task vừa sang `FINISHED` và có lịch hẹn đăng ngày mai (chưa đăng); `Owner` / `Manager` phát hiện lỗi và bấm `Reopen` phần `POST.CAPTION` | `POST /sections/POST.CAPTION/reopen` | Phần `POST.CAPTION` về `RETURNED` (các phần khác giữ nguyên đã duyệt), **Task cha tự quay về `IN_PROGRESS`**, lịch hẹn đăng trên `PostDocument` tự động bị hủy (`DRAFT`). |
| `TA-57` | `AC-10` | Security | `Creator` (hoặc `Manager`) kéo thẻ Kanban hoặc dùng Bulk Action / gọi `PATCH /tasks/{id}/status` với `status = "FINISHED"` hoặc `"IN_REVIEW"` | Kéo thẻ sang cột `Hoàn thành` / gọi `PATCH /status` | Backend từ chối `409 TASK_WORKFLOW_REQUIRED`; Frontend chặn thả thẻ và hiển thị thông báo hướng dẫn đi qua quy trình duyệt. |
| `TA-58` | `AC-10` | Security | `Creator` gọi `PATCH /tasks/{id}/status` với `status = "CANCELLED"` | `PATCH /status` (`CANCELLED`) | Bị từ chối `403 FORBIDDEN`; chỉ `Owner` và `Manager` mới được hủy Task. |
| `TA-59` | `AC-11` | Security | Workspace ở chế độ `AGENCY`, Task có `requiresClientApproval = false` (`TASK-B2A7`) | Mở `TaskDetailPanel` với quyền `Manager`/`Owner` hoặc gọi `POST /self-approve` | Nút `Hoàn tất & Tự duyệt` **không xuất hiện** trên giao diện; gọi trực tiếp API nhận `403 TASK_SELF_APPROVE_NOT_ALLOWED`. Trong chế độ `PERSONAL` vẫn hoạt động bình thường. |
| `TA-60` | `AC-12,14` | UX | Mở `TaskDetailPanel` trên Task `FINISHED` và trên Task `IN_PROGRESS` (`3/5` phần đã duyệt); duyệt nốt phần trong panel | Quan sát `TaskStatusControl` và bảng `TaskTable` phía sau | Khi `FINISHED`: hiện huy hiệu `• Hoàn thành` tĩnh (không có mũi tên `⌄`, không mở menu trống). Khi duyệt xong phần cuối trong panel: dòng bên ngoài bảng `TaskTable` tự nhảy sang `Hoàn thành` ngay tức thì. |
| `TA-61` | `AC-13` | Normal | Workspace có các Task `SHORT_VIDEO`, `KOL_BOOKING`, `EVENT_PLAN` đang chờ duyệt | Mở trang `/workspaces/:id/task-approvals` | Hiển thị đầy đủ cả 8 loại `TaskType` và lọc chính xác theo loại công việc (không chỉ riêng `POST`). |
| `TA-62` | `AC-15,16` | i18n & Theme | Chuyển đổi ngôn ngữ `VI ↔ EN` và giao diện `Light ↔ Dark` ở khung nhìn `375px`, `768px`, `1440px` | Kiểm tra `TaskStatusControl`, `TaskBoardView`, `TaskBulkActionBar`, `/task-approvals` | 100% nhãn dịch khớp ngữ cảnh không lộ raw key; màu sắc tương phản rõ ràng trên cả nền Sáng và Tối, không tràn khung nhìn. |

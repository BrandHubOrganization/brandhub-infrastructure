> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md) · [BA Governance →](../../../../ba/13-task-status-and-approval-governance.md)

# FR 3.6.9 — Approval Sequence (Creator -> Manager -> Client)

| Thuộc tính | Giá trị |
| :--- | :--- |
| **FR / Use Case** | `3.6.9` / `UC-061` |
| **Miền chức năng** | `3.6 Content & Workflow` |
| **Canonical Actors / Roles** | `Owner`, `Manager`, `Creator`, `Client` *(chặn `Guest` `401`; `Admin` vận hành `3.10.4` độc lập)* |
| **Vai trò tham gia trên Task** | `Coordinator` (`task.assigneeId`), `Task Supervisor` (`task.supervisorId`), `Section Owner` (`subtask.assigneeId`), `Subtask Supervisor` (`subtask.supervisorOverrideId`) |
| **Phạm vi loại công việc** | Đầy đủ **8 `TaskType`**: `POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER` |
| **Quy tắc nghiệp vụ liên quan** | `BR-33`, `BR-34`, `BR-34a` *(Anti-Self-Supervision)*, `BR-35`, `BR-42`, `BR-54` |
| **Phiên bản đặc tả** | **v4.0 — Hợp nhất Phân quyền Đa Vai trò, Tự động Chốt Trạng thái & Chống Nhảy cóc (27/11/2026)** |

---

## 1. Objective (Mục tiêu Nghiệp vụ)

Đảm bảo mọi công việc sản xuất nội dung trên cả **8 loại `TaskType`** đều đi qua luồng kiểm duyệt phân cấp chặt chẽ, minh bạch theo đúng vai trò trong Workspace (`Owner`, `Manager`, `Creator`, `Client`) và vai trò gắn trực tiếp trên từng Công việc / Công việc con (`Người thực hiện`, `Người giám sát`), đồng thời:
1. **Tự động chuyển trạng thái Task cha (`IN_PROGRESS → IN_REVIEW → FINISHED`)** ngay khi các phần nội dung (`TaskSection`) hoàn tất phê duyệt tương ứng, loại bỏ tình trạng duyệt xong 100% nhưng trạng thái bên ngoài vẫn kẹt ở `Đang làm`.
2. **Đóng kín mọi lỗ hổng nhảy cóc trạng thái** qua API đổi status thô, kéo-thả Kanban, Thanh thao tác hàng loạt hoặc nút `Self-Approve` sai chế độ.
3. **Đồng bộ quyền đầy đủ cho `Owner` và `Người giám sát` (`supervisorId`)**, ngăn chặn tuyệt đối việc `Creator` tự làm Người giám sát để bỏ qua bước duyệt nội bộ.

---

## 2. User Stories theo Vai trò Chuẩn

- **Là một `Creator` (Chủ phần `Section Owner` hoặc Điều phối viên `Coordinator`)**: Tôi muốn biên soạn, lưu nháp (tự động kích hoạt Task từ `TODO` sang `IN_PROGRESS` nếu đủ điều kiện) và nộp duyệt từng phần việc được giao mà không thể vô tình hay cố ý tự chuyển Task cha sang `FINISHED` khi chưa được cấp trên nghiệm thu.
- **Là một `Task Supervisor` (`task.supervisorId`) hoặc `Subtask Supervisor` (`subtask.supervisorOverrideId`)**: Tôi muốn có quyền kiểm duyệt nội bộ (`Approve` / `Return` kèm lý do) đối với các phần nội dung và công việc mình được phân công giám sát (miễn tôi không phải là người trực tiếp làm phần đó).
- **Là một `Manager` hoặc `Owner` của Workspace `AGENCY`**: Tôi muốn có toàn quyền điều hành, chọn nền tảng xuất bản (`Facebook`, `Instagram`, `TikTok`, `Threads`), phân công công việc con, phê duyệt / trả lại / mở lại (`Reopen`) bất kỳ phần nội dung nào (kể cả mở lại gấp trước giờ xuất bản), và theo dõi toàn bộ **8 loại `TaskType`** tập trung tại trang `/workspaces/:id/task-approvals`.
- **Là một `Client` trong Workspace `AGENCY`**: Tôi muốn chỉ nhìn thấy các phần sản phẩm đầu ra (`OUTPUT`) đã qua kiểm duyệt nội bộ của Agency (ẩn hoàn toàn các phần nội bộ `INTERNAL` và lịch sử nháp), và ngay khi tôi bấm `Duyệt` phần đầu ra cuối cùng thì công việc tự động chốt sang `Hoàn thành` (`FINISHED`).
- **Là Chủ không gian chế độ `PERSONAL` (`Owner` / `Manager`)**: Tôi muốn sử dụng nút **`Hoàn tất & Tự duyệt` (`Self-Approve` 1 chạm)** để chốt nhanh công việc cá nhân sang `FINISHED` mà không ảnh hưởng tới quy trình kiểm soát nhiều người của chế độ `AGENCY`.

---

## 3. Acceptance Criteria (Tiêu chí Nghiệm thu Chi tiết)

### 3.1. Phân quyền Đa Vai trò (`Owner`, `Manager`, `Creator`, `Client` × `Supervisor`, `Assignee`)

- **AC-01 — Đồng quyền điều hành của `Owner` với `Manager`:** Trong mọi Workspace thuộc `Agency` của mình, `Owner` có đầy đủ quyền hạn như `Manager` trên toàn bộ vòng đời công việc: giao việc (`assign`), chọn và thay đổi nền tảng đích (`targetPlatforms`), thêm/sửa/sắp xếp công việc con (`Subtasks` cho cả task Chiến dịch và task Độc lập), bấm bắt đầu (`start`), sửa/nộp/khôi phục phần nội dung (`Section`), duyệt nội bộ (`APPROVE`), trả lại (`RETURN`), mở lại (`REOPEN`), và duyệt/từ chối Task cha ở bước `MANAGER`.
- **AC-02 — Kế thừa Người giám sát (`Supervisor Inheritance`):** Quy tắc xác định người giám sát hiệu lực của một công việc con / phần nội dung là: `subtask.supervisorOverrideId ?? task.supervisorId ?? defaultManager(workspaceId)`. Một thành viên là `Creator` được chỉ định làm `task.supervisorId` hoặc `subtask.supervisorOverrideId` (và không đồng thời là chủ sở hữu phần đó hay `Coordinator` tự duyệt bài mình) có quyền `APPROVE` / `RETURN` cấp nội bộ đối với phần/task đó.
- **AC-03 — Duyệt hỗ trợ của `Owner` & `Manager`:** Kể cả khi Task đã gán `task.supervisorId` cụ thể, mọi `Owner` và `Manager` đang hoạt động trong Workspace (khác `Creator` nộp bài) đều có quyền thực hiện duyệt nội bộ hoặc trả lại để không gây tắc nghẽn dây chuyền khi Người giám sát vắng mặt.
- **AC-04 — Chống tự giám sát (`BR-34a — Anti-Self-Supervision`):**
  - Nếu người thực hiện (`task.assigneeId` hoặc `subtask.assigneeId`) có vai trò `Creator`, hệ thống **cấm tuyệt đối** gán người giám sát trùng với người thực hiện đó (`supervisorId != assigneeId`).
  - Khi `Creator` tạo mới công việc (`POST /tasks` hoặc `POST /tasks/standalone`) mà để trống `supervisorId` (hoặc gửi ID của chính mình), hệ thống bắt buộc gán `task.supervisorId = defaultManager` của Workspace.
  - Quy tắc bỏ qua bước duyệt nội bộ (`skipsAgencyReview`) **chỉ** kích hoạt khi người thực hiện chính (`task.assigneeId`) mang vai trò `Owner` hoặc `Manager` và tự giám sát chính mình (hoặc trong chế độ `PERSONAL`).
- **AC-05 — Cô lập `Creator` không tham gia Task:** Một `Creator` trong Workspace nhưng không phải `task.assigneeId`, `task.supervisorId`, `subtask.assigneeId` hay `subtask.supervisorOverrideId` của Task thì:
  - Không nhìn thấy các phần `INTERNAL` và không sửa được bất kỳ phần nào.
  - Không được sửa danh sách đối tác (`PATCH /tasks/{taskId}/partners` → `403 FORBIDDEN`).
  - Không được bấm xuất bản bài đăng của Task đó (`POST /posts/{postId}/publish` → `403 FORBIDDEN`).
- **AC-06 — Cô lập tầm nhìn và quyền của `Client`:**
  - `Client` chỉ nhìn thấy các `TaskSection` có `visibility = OUTPUT` đã đạt `INTERNAL_APPROVED` hoặc `CLIENT_APPROVED`; toàn bộ phần `INTERNAL` (`POST.BRIEF`, `VIDEO.SHOOT`, `KOL.DEAL`, `EVENT.LOGISTICS`, `EVENT.RUNSHEET`, `PRESS.MEDIA_LIST`, `PRESS.CONTACT_LOG`, `WORKSHOP.LOGISTICS`) và lịch sử phiên bản (`TaskSectionVersion`) bị lọc bỏ hoàn toàn từ Backend.
  - Một `Client` đang hoạt động bất kỳ trong Workspace được quyền quyết định (`CLIENT_APPROVE` / `CLIENT_RETURN`) khi `task.requiresClientApproval = true`.

### 3.2. Gỡ kẹt Khởi động, Tự động Chốt Trạng thái (`Auto-Settlement`) & Chống Nhảy Cóc

- **AC-07 — Tự mở phiên làm việc cho Chủ phần (`Auto-Start on Subtask Edit`):** Khi Task cha đang ở trạng thái `TODO` (đã có đủ mô tả Brief, hạn chót hợp lệ và Chiến dịch cho phép bắt đầu), nếu `Coordinator` hoặc bất kỳ `Section Owner` (`subtask.assigneeId`) hợp lệ nào lưu bản nháp phần nội dung (`PATCH /sections/{key}` hoặc `POST /tasks/{id}/post`), hệ thống tự động chuyển Task cha sang `IN_PROGRESS` (ghi nhận `firstStartedAt`, `firstStartedBy`), xóa bỏ sự bất nhất giữa phần `Brief` và phần `Caption`/`Media`.
- **AC-08 — Tự động chốt Task cha khi làm theo từng phần (`Section → Subtask → Task Auto-Settlement`):** Với mọi Task có `Subtask` gắn vai trò (`roleTask = true` trên cả 8 loại `TaskType`):
  1. Mỗi lần một phần được `APPROVE` (cấp nội bộ hoặc cấp `Client`), hệ thống đồng bộ trạng thái `Subtask` vai trò (`syncRoleSubtasks`) và kiểm tra toàn cục các phần của Task:
  2. Các phần không có `Subtask` sở hữu riêng (`unowned sections`) được coi là sẵn sàng đóng nội bộ khi thỏa điều kiện nội dung tối thiểu (với `POST` / `SHORT_VIDEO`: `caption` không trống).
  3. **Khi `requiresClientApproval = false`**: Ngay khi 100% phần của Task đạt `INTERNAL_APPROVED` và không còn công việc con tự do (`subtaskRole = null`) chưa hoàn thành → Hệ thống **tự động chuyển Task cha sang `FINISHED`**, ghi nhận `finishedAt`, đóng `lastSubmission` với `outcome = "APPROVED"`, ghi bản ghi `task_approvals`, và đồng bộ `PostDocument` sang `SCHEDULED` (nếu có `publishDate`) hoặc `APPROVED`.
  4. **Khi `requiresClientApproval = true`**:
     - Ngay khi tất cả các phần đạt tối thiểu `INTERNAL_APPROVED` (trong đó còn ít nhất 1 phần `OUTPUT` đang chờ `Client` duyệt): Nếu Task cha đang ở `IN_PROGRESS`, hệ thống **tự động chuyển Task cha sang `IN_REVIEW` với `reviewStep = "CLIENT"`** (và `PostDocument` sang `PENDING_APPROVAL`).
     - Ngay khi 100% các phần đạt `finalState = true` (mọi phần `INTERNAL` đạt `INTERNAL_APPROVED` và mọi phần `OUTPUT` đạt `CLIENT_APPROVED`) và không còn công việc con tự do mở → Hệ thống **tự động chuyển Task cha sang `FINISHED`** (kể cả trong trường hợp `Client` đã duyệt sớm các phần `OUTPUT` trước khi `Manager` duyệt xong phần `INTERNAL` cuối cùng).
- **AC-09 — Trả lại (`Return`) và Mở lại (`Reopen`) an toàn trước giờ xuất bản:**
  - `Owner` / `Manager` / `Supervisor` trả lại phần đang `SUBMITTED` (`RETURN`), hoặc `Client` trả lại phần `OUTPUT` đã duyệt (`CLIENT_RETURN`) đều **bắt buộc nhập lý do không rỗng** (tối đa `2.000` ký tự cho Section, `5.000` ký tự cho Task đơn).
  - `Owner` và `Manager` được phép bấm `Mở lại` (`REOPEN`) một phần đã duyệt ngay cả khi Task cha đang ở `IN_PROGRESS`, `IN_REVIEW`, hoặc vừa chuyển sang `FINISHED` (miễn bài đăng/bản tin chưa bước vào `PUBLISHING` / `PUBLISHED` / `PROCESSING`).
  - Khi một phần trên Task đang `IN_REVIEW` hoặc `FINISHED` bị `CLIENT_RETURN` hoặc `REOPEN`: chỉ phần đó quay về `RETURNED` (giữ nguyên kết quả đã duyệt của các phần anh em khác), `Subtask` tương ứng quay về `IN_PROGRESS`, **Task cha tự động quay về `IN_PROGRESS`** (`finishedAt = null`, `reviewStep = null`), và hệ thống tự động thu hồi lịch xuất bản (`PostService.cancelTaskSchedule` / `MailBatchService.cancelForTask`).
- **AC-10 — Khóa cứng chống nhảy cóc trạng thái (`Anti-Bypass Guard`):**
  - Endpoint `PATCH /api/v1/workspaces/{workspaceId}/tasks/{taskId}/status` **từ chối (`409 TASK_WORKFLOW_REQUIRED`)** mọi yêu cầu đổi trực tiếp sang `IN_REVIEW` hoặc `FINISHED` đối với các Task thuộc phạm vi quy trình duyệt.
  - Thao tác đổi sang `CANCELLED` qua `PATCH /status` chỉ cho phép `Owner` và `Manager` (`Creator` bị từ chối `403 FORBIDDEN`).
  - Bảng Kanban (`useBoardDragAndDrop`) và Thanh thao tác hàng loạt (`TaskBulkActionBar`) tuân thủ cùng quy tắc: chặn thả thẻ / chọn hàng loạt sang `Chờ duyệt` hoặc `Hoàn thành`.
- **AC-11 — Giới hạn nghiêm ngặt `Hoàn tất & Tự duyệt` (`Self-Approve`):**
  - Endpoint `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/self-approve` và nút `Hoàn tất & Tự duyệt` trên giao diện (`TaskWorkflowContent`, `TaskEditorControls`, `TaskExportButton`) **chỉ được phép hoạt động khi `workspaceMode = "PERSONAL"`** đối với `Owner` / `Manager`.
  - Trong chế độ `AGENCY` (kể cả khi `requiresClientApproval = false`), gọi `self-approve` bị chặn với mã lỗi `403 TASK_SELF_APPROVE_NOT_ALLOWED` và nút bị ẩn hoàn toàn trên mọi màn hình.

### 3.3. Trải nghiệm Giao diện (UI/UX), Đa ngôn ngữ (i18n) & Giao diện Sáng/Tối (Light/Dark)

- **AC-12 — Chuẩn hóa `TaskStatusControl` ở góc trên Task Detail:**
  - Khi Task ở trạng thái kết thúc (`FINISHED` hoặc `CANCELLED`) hoặc người dùng hiện tại không có bất kỳ thao tác chuyển trạng thái hợp lệ nào (`availableActions.length === 0`): hiển thị **Badge trạng thái tĩnh** (không hiển thị icon mũi tên `⌄` và không mở menu trống *"Không có thao tác chuyển trạng thái"*).
  - Hiển thị nhãn ngữ cảnh tiến độ rõ ràng ngay cạnh trạng thái: ví dụ `3/5 phần đã duyệt` (khi `IN_PROGRESS` trên Task chia phần), `Bước Quản lý` / `Bước Khách hàng` (khi `IN_REVIEW`), `Đã hoàn tất phê duyệt` (khi `FINISHED`).
  - Hỗ trợ đầy đủ cả các Task tạo thủ công (`sourceType = "MANUAL"` hoặc `"CAMPAIGN_OUT_OF_SCOPE"`) trên cả 8 loại `TaskType`.
- **AC-13 — Trang Phê duyệt tập trung (`/workspaces/:id/task-approvals`) hỗ trợ đủ 8 `TaskType`:**
  - Danh sách chờ duyệt hiển thị toàn bộ 8 loại công việc (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`), hỗ trợ lọc theo Loại công việc (`type`), Trạng thái (`status`) và từ khóa tìm kiếm.
- **AC-14 — Đồng bộ tức thì danh sách bên ngoài (`List`, `Kanban`, `Calendar`, `Gantt`):**
  - Khi người dùng nộp phần, duyệt phần, trả lại phần, mở lại phần hoặc duyệt Task ngay trong `TaskDetailPanel` (Side Peek / Center Modal) hoặc quay về từ `Editor`, trạng thái dòng/thẻ công việc ở danh sách bên ngoài cập nhật ngay lập tức sang `Chờ duyệt` / `Hoàn thành` / `Đang làm` mà không cần tải lại trang trình duyệt.
- **AC-15 — Đa ngôn ngữ (`vi.json` + `en.json` key-parallel):**
  - Toàn bộ nhãn trạng thái ngữ cảnh, thông báo chặn kéo-thả Kanban, bộ lọc loại công việc trên `/task-approvals`, và thông báo lỗi phân quyền dùng khóa dịch song song trong `src/i18n/locales/vi/tasks.json`, `src/i18n/locales/en/tasks.json`, `src/i18n/locales/vi/editor.json`, `src/i18n/locales/en/editor.json` — tuyệt đối không hardcode chuỗi tiếng Việt hay tiếng Anh trong JSX/TSX.
- **AC-16 — Tương thích Light / Dark Mode & Responsive:**
  - Mọi huy hiệu trạng thái tĩnh/động, tiến độ phần, thẻ phê duyệt và thông báo cảnh báo dùng semantic CSS variables (`bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) và cặp biến thể `dark:*` chuẩn mực, đảm bảo độ tương phản WCAG AA trên cả Light mode và Dark mode ở các khung nhìn `375px`, `768px`, `1440px`.

---

## 4. State Machine Tổng hợp

### 4.1. Task Có Chia Phần & Vai trò (`roleTask = true`)

| Trạng thái Trước | Actor & Sự kiện Nghiệp vụ | Trạng thái Sau (`TaskDocument` & `PostDocument`) |
| :--- | :--- | :--- |
| `TODO` | `Coordinator` bấm `Start` **HOẶC** `Section Owner` / `Coordinator` lưu bản nháp phần đầu tiên | `IN_PROGRESS` (`firstStartedAt` được ghi nhận) |
| `IN_PROGRESS` | `Section Owner` nộp phần (`SUBMIT`); `Owner` / `Manager` / `Supervisor` duyệt từng phần (`INTERNAL_APPROVED`), còn phần chưa xong | Giữ `IN_PROGRESS` (cập nhật tiến độ `X/Y` phần đã duyệt; các `Subtask` xong phần của mình tự chuyển `FINISHED`) |
| `IN_PROGRESS` | Phần bắt buộc cuối cùng đạt `INTERNAL_APPROVED`, `requiresClientApproval = false`, không còn Free Subtask mở | **Tự động chuyển `FINISHED`**, `reviewStep = null`, `Post` → `SCHEDULED` / `APPROVED` |
| `IN_PROGRESS` | Tất cả phần đạt tối thiểu `INTERNAL_APPROVED`, `requiresClientApproval = true`, còn phần `OUTPUT` chờ `Client` | **Tự động chuyển `IN_REVIEW` (`reviewStep = "CLIENT"`)**, `Post` → `PENDING_APPROVAL` |
| `IN_PROGRESS` / `IN_REVIEW (CLIENT)` | `Client` duyệt phần `OUTPUT` cuối cùng (hoặc `Manager` duyệt phần `INTERNAL` cuối cùng sau khi `Client` đã duyệt xong các phần `OUTPUT`) | **Tự động chuyển `FINISHED`**, `reviewStep = null`, `Post` → `SCHEDULED` / `APPROVED` |
| `IN_REVIEW (CLIENT)` / `FINISHED` *(chưa đăng)* | `Client` bấm `Return` (kèm lý do) **HOẶC** `Owner` / `Manager` bấm `Reopen` 1 phần | Phần đó → `RETURNED`, `Subtask` đó → `IN_PROGRESS`, **Task cha → `IN_PROGRESS`**, hủy lịch đăng tự động |

### 4.2. Task Đơn Không Chia Subtask Vai trò (`roleTask = false`)

| Trạng thái Trước | Actor & Sự kiện Nghiệp vụ | Trạng thái Sau |
| :--- | :--- | :--- |
| `TODO` | `Coordinator` (`Owner` / `Manager` / `Creator` được giao) bấm `Start` | `IN_PROGRESS` |
| `IN_PROGRESS` | `Coordinator` là `Creator` (hoặc có `Supervisor` khác) bấm `Submit` | `IN_REVIEW` / `MANAGER` (`Post` → `PENDING_APPROVAL`) |
| `IN_PROGRESS` | `Coordinator` là `Owner` / `Manager` tự giám sát bấm `Submit` | `IN_REVIEW` / `CLIENT` *(nếu cần `Client`)* hoặc `FINISHED` *(nếu không cần `Client`)* |
| `IN_REVIEW` / `MANAGER` | `Owner` / `Manager` / `Task Supervisor` (khác `Creator` nộp) bấm `Approve` | `FINISHED` *(nếu không cần `Client`)* hoặc `IN_REVIEW` / `CLIENT` *(nếu cần `Client`)* |
| `IN_REVIEW` / `CLIENT` | Một `Client` active bất kỳ bấm `Approve` | `FINISHED` (`Post` → `SCHEDULED` / `APPROVED`) |
| `IN_REVIEW` / `MANAGER` hoặc `CLIENT` | Người duyệt hợp lệ bấm `Reject` (có lý do bắt buộc) | `IN_PROGRESS`, `reviewStep = null` (`Post` → `DRAFT`; lần gửi sau `approvalRound + 1`) |
| `IN_REVIEW` / `MANAGER` *(chưa có decision)* | `Coordinator` bấm `Withdraw` | `IN_PROGRESS`, `reviewStep = null` (`Post` → `DRAFT`) |

---

## 5. API Contract & Quy tắc Kiểm tra Quyền

Prefix chuẩn: `/api/v1/workspaces/{workspaceId}/tasks/{taskId}`

| Method & Endpoint | Vai trò Được Phép | Ràng buộc Nghiệp vụ Cốt lõi |
| :--- | :--- | :--- |
| `GET /review` | `Owner`, `Manager`, `Creator`, `Client` | Trả về `status`, `reviewStep`, `approvalRound`, `workflowRevision`, `allowedActions`, `blockedReason`. |
| `POST /submit` | `Coordinator` (`task.assigneeId`) | Chuyển Task đơn sang `IN_REVIEW` (hoặc chốt các phần không chủ sở hữu). Bắt buộc `caption` không rỗng với `POST`/`SHORT_VIDEO`. |
| `POST /withdraw` | `Coordinator` (`task.assigneeId`) | Thu hồi khi đang `IN_REVIEW / MANAGER` và chưa có quyết định. |
| `POST /approve` | `Owner`, `Manager`, `Task Supervisor` *(bước `MANAGER`)*; `Client` *(bước `CLIENT`)* | Chặn tự duyệt đối với `Creator`; cập nhật CAS nguyên tử Task + Post + `task_approvals`. |
| `POST /reject` | `Owner`, `Manager`, `Task Supervisor` *(bước `MANAGER`)*; `Client` *(bước `CLIENT`)* | Bắt buộc `comment` không trắng (≤ `5.000` ký tự); đưa Task về `IN_PROGRESS`. |
| `POST /self-approve` | `Owner`, `Manager` (**CHỈ khi `workspaceMode = "PERSONAL"`**) | Trả `403 TASK_SELF_APPROVE_NOT_ALLOWED` nếu gọi trên Workspace chế độ `AGENCY`. |
| `GET /sections` | `Owner`, `Manager`, `Creator`, `Client` | Lọc ẩn toàn bộ phần `INTERNAL` đối với `Client` và `Creator` ngoài Task. |
| `PATCH /sections/{sectionKey}` | `Owner`, `Manager`, `Coordinator`, `Section Owner` | Lưu nháp theo CAS `expectedRevision`; tự mở `TODO → IN_PROGRESS` nếu đủ điều kiện. |
| `POST /sections/{sectionKey}/submit` | `Owner`, `Manager`, `Coordinator`, `Section Owner` | Chụp `TaskSectionVersion` bất biến, chuyển phần sang `SUBMITTED`. |
| `POST /sections/{sectionKey}/approve` | `Owner`, `Manager`, `Supervisor` *(nội bộ)*; `Client` *(phần `OUTPUT`)* | Duyệt phần; kích hoạt **Auto-Settlement** chuyển Task cha sang `IN_REVIEW (CLIENT)` hoặc `FINISHED` khi đủ 100% điều kiện. |
| `POST /sections/{sectionKey}/return` | `Owner`, `Manager`, `Supervisor` *(nội bộ)*; `Client` *(phần `OUTPUT`)* | Bắt buộc `note` (≤ `2.000` ký tự); nếu Task đang `IN_REVIEW`/`FINISHED` thì mở lại `IN_PROGRESS` và hủy lịch đăng. |
| `POST /sections/{sectionKey}/reopen` | `Owner`, `Manager` | Mở lại phần đã duyệt (kể cả khi Task vừa `FINISHED` mà bài chưa đăng), tự đưa Task về `IN_PROGRESS` và hủy lịch đăng. |
| `PATCH /status` | `Owner`, `Manager`, `Coordinator` *(giới hạn)* | **Cấm** `IN_REVIEW` và `FINISHED` (`409 TASK_WORKFLOW_REQUIRED`); `CANCELLED` chỉ cho `Owner`/`Manager`. |

---

## 6. Error Handling & Edge Cases

- **`400 VALIDATION_ERROR` / `INVALID_TASK_SUPERVISOR`**: Thiếu lý do trả bài/từ chối, `caption` rỗng khi nộp bài `POST`/`SHORT_VIDEO`, hoặc gán `supervisorId` trùng với `assigneeId` của `Creator`.
- **`403 FORBIDDEN` / `WRONG_APPROVAL_STEP` / `TASK_SELF_APPROVE_NOT_ALLOWED`**: Sai vai trò duyệt, `Creator` tự duyệt bài mình, `Creator` ngoài Task bấm `Publish` hoặc sửa `partners`, hoặc gọi `self-approve` trong Workspace `AGENCY`.
- **`409 TASK_WORKFLOW_REQUIRED` / `TASK_REVISION_CONFLICT` / `POST_CONTENT_CONFLICT`**: Cố tình đổi thẳng sang `FINISHED` / `IN_REVIEW` qua `PATCH /status` (Kanban/Bulk), hoặc dữ liệu màn hình đã cũ khi hai người thao tác đồng thời (giữ nguyên nháp/nhận xét đang nhập để người dùng tải lại).
- **Bài đã xuất bản thật (`PUBLISHING` / `PUBLISHED`)**: Khi `PostDocument` đã đi vào hàng đợi xuất bản hoặc đã đăng lên mạng xã hội, mọi thao tác `REOPEN` / `CLIENT_RETURN` trên phần nội dung của bài đăng đó bị khóa để bảo toàn tính toàn vẹn lịch sử xuất bản.

---

## 7. Definition of Done & Out of Scope

- **Definition of Done:**
  1. Toàn bộ 16 tiêu chí nghiệm thu (`AC-01` – `AC-16`) được triển khai đồng bộ trên `brandhub-business-service` và `brandhub-web`.
  2. Bộ khóa dịch `vi` / `en` song song 100%, không hardcode chuỗi văn bản; giao diện đạt chuẩn Light/Dark mode trên Mobile/Tablet/Desktop.
  3. Toàn bộ kiểm thử đơn vị và tích hợp trong [test.md](./test.md) đạt `Pass` 100%.
- **Out of Scope:** Các tính năng đã loại khỏi phạm vi dự án theo `AGENTS.md` (không có Livestream, không hạ cấp gói cước, không quét đạo văn/bản quyền, chỉ hỗ trợ đúng 4 nền tảng `Facebook`, `Instagram`, `TikTok`, `Threads`).
- **Tham chiếu BA:** [13-task-status-and-approval-governance.md](../../../../ba/13-task-status-and-approval-governance.md) · [05-content-task-workflow.md](../../../../ba/05-content-task-workflow.md) · [10-roles-permissions-matrix.md](../../../../ba/10-roles-permissions-matrix.md) · [12-state-machines.md](../../../../ba/12-state-machines.md).

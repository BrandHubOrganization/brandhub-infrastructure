# 04 — Gói Truyền thông, Chiến dịch & Yêu cầu Nội dung (Media Package, Media Campaign & Content Request)

> [<< 03 - Agency & Workspace](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/03-agency-workspace-management.md) | [Overview](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/00-overview.md) | [Tiếp: 05 - Content & Task Workflow >>](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/05-content-task-workflow.md)
>
> **Phạm vi FR chuẩn**: **Mục `3.5 Media Package & Media Campaign` — 13 FR (`3.5.1` – `3.5.13`)** | `UC-040` – `UC-052`.
> Đã đồng bộ với **8 loại Dịch vụ / Công việc chuẩn (`PackageServiceType` ↔ `TaskType`)**, luồng `Manager-led Package & Campaign Approval`, và luồng **Chiến dịch Cá nhân không cần Gói dịch vụ (`workspaceMode = "PERSONAL"`)**.

---

## 1. Bảng Tổng hợp 13 Yêu cầu Chức năng Chuẩn (`3.5.1` – `3.5.13`)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (Atomic CRUD FR) | Actors / Roles Chuẩn | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :--- |
| **`3.5.1`** | `UC-040` | **Create Media Package** | `Owner` | Tạo mới hoặc tùy chỉnh Gói truyền thông mẫu (`MediaPackage`) ở cấp `Agency` với danh mục các hạng mục dịch vụ, số lượng, đơn vị chuẩn, đơn giá và điều khoản. |
| **`3.5.2`** | `UC-041` | **View Template Media Package** | `Owner`, `Manager`, `Client` | Xem danh sách và chi tiết các Gói truyền thông mẫu của `Agency` hoặc bảng đề xuất gói gắn với `Workspace` (hỗ trợ xuất PDF đề xuất đa ngôn ngữ & chia sẻ link công khai cho `Guest`). |
| **`3.5.3`** | `UC-042` | **Request Media Package** | `Manager`, `Client` | Chọn hoặc đề xuất áp dụng một Gói truyền thông cho `Workspace` (`WorkspaceMediaPackage`), tùy chỉnh hạng mục/số lượng theo nhu cầu dự án. |
| **`3.5.4`** | `UC-043` | **Approve Media Package** | `Owner`, `Manager` | Xác nhận chốt Gói truyền thông cho `Workspace` (`status = APPROVED`) để mở khóa bước lập Chiến dịch truyền thông trong chế độ `AGENCY`. |
| **`3.5.5`** | `UC-044` | **Create Media Campaign** | `Manager` | Khởi tạo Kế hoạch Chiến dịch truyền thông (`MediaCampaign`): đặt tên, mục tiêu, thời gian bắt đầu/kết thúc, thông điệp chủ đạo và danh sách các hạng mục công việc (`workItems`). |
| **`3.5.6`** | `UC-045` | **View Media Campaign** | `Owner`, `Manager`, `Creator`, `Client` | Xem chi tiết kế hoạch chiến dịch, tiến độ tổng thể và **Lịch trình Chiến dịch (`CampaignTimelineGrid`)** kèm trạng thái từng Subtask, cờ trễ hạn và cờ chờ `Client` duyệt. |
| **`3.5.7`** | `UC-046` | **Update Media Campaign** | `Manager` | Cập nhật thông tin chiến dịch, điều chỉnh danh sách hạng mục công việc, thời hạn hoặc phân bổ lại nhân sự trong quá trình thực hiện. |
| **`3.5.8`** | `UC-047` | **Approve Media Campaign** | `Manager`, `Client` | Chốt kế hoạch chiến dịch và triển khai (`Deploy Campaign`): tự động sinh hàng loạt Công việc cha (`TaskDocument`) kèm đầy đủ bộ **Subtask theo vai trò chuẩn (`TaskCatalog`)**. |
| **`3.5.9`** | `UC-048` | **Complete Media Campaign** | `Manager` | Đánh dấu hoàn tất Chiến dịch truyền thông (`status = COMPLETED`) sau khi các hạng mục công việc cốt lõi đã hoàn thành và nghiệm thu. |
| **`3.5.10`** | `UC-049` | **Create Content Request** | `Client` | Khách hàng (`Client`) tạo Yêu cầu nội dung phát sinh (`ContentRequest`) từ `Client Portal` gửi cho đội ngũ `Workspace`. |
| **`3.5.11`** | `UC-050` | **Track Request Status** | `Manager`, `Client` | Theo dõi trạng thái xử lý của `ContentRequest` (`PENDING` → `APPROVED` / `IN_PROGRESS` / `COMPLETED` / `REJECTED` / `CANCELLED`) và công việc (`Task`) được sinh ra từ yêu cầu đó. |
| **`3.5.12`** | `UC-051` | **Update Request** | `Manager`, `Client` | `Client` chỉnh sửa nội dung yêu cầu khi còn ở trạng thái `PENDING`; `Manager` tiếp nhận, phản hồi, duyệt chuyển thành `Task` hoặc từ chối kèm lý do. |
| **`3.5.13`** | `UC-052` | **Cancel Request** | `Client` | `Client` hủy một `ContentRequest` do mình tạo khi yêu cầu đang ở trạng thái `PENDING` (chưa được `Manager` triển khai thành `Task`). |

---

## 2. Ánh xạ 8 Loại Hạng mục Dịch vụ (`PackageServiceType`) sang 8 Loại Công việc (`TaskType`)

Hệ thống chuẩn hóa 8 loại dịch vụ truyền thông trong Gói dịch vụ (`PackageOfferingValidator` & `CampaignPlanValidator`), ánh xạ 1-đối-1 sang 8 loại Công việc (`TaskType`) khi triển khai chiến dịch:

| STT | `PackageServiceType` | `TaskType` sinh ra khi Deploy | Đơn vị chuẩn (`Standard Unit`) | Số lượng Subtask vai trò tự động sinh (`TaskCatalog`) |
| :-: | :--- | :--- | :-: | :--- |
| 1 | **`CONTENT_POST`** | `POST` | `"bài"` | 5 vai trò (`POST_RESEARCH`, `POST_CONTENT`, `POST_MEDIA`, `POST_EDITING`, `POST_PUBLISHING`) |
| 2 | **`SHORT_VIDEO`** | `SHORT_VIDEO` | `"video"` | 4 vai trò (`VIDEO_SCRIPT`, `VIDEO_SHOOT`, `VIDEO_EDIT`, `VIDEO_PUBLISH`) |
| 3 | **`SURVEY`** | `SURVEY` | `"khảo sát"` | 3 vai trò (`SURVEY_DESIGN`, `SURVEY_DISTRIBUTE`, `SURVEY_ANALYSIS`) |
| 4 | **`EVENT_PLAN`** | `EVENT_PLAN` | `"sự kiện"` | 5 vai trò (`EVENT_AGENDA`, `EVENT_LOGISTICS`, `EVENT_PROMOTION`, `EVENT_ONSITE`, `EVENT_REPORT`) |
| 5 | **`PRESS_RECOMMENDATION`** | `PRESS_RECOMMENDATION` | `"thông cáo"` | 4 vai trò (`PRESS_MEDIA_LIST`, `PRESS_RELEASE`, `PRESS_PITCHING`, `PRESS_TRACKING`) |
| 6 | **`KOL_BOOKING`** | `KOL_BOOKING` | `"KOL"` | 5 vai trò (`KOL_SOURCING`, `KOL_NEGOTIATION`, `KOL_BRIEF`, `KOL_CONTENT_REVIEW`, `KOL_TRACKING`) |
| 7 | **`WORKSHOP_SUPPORT`** | `WORKSHOP` | `"buổi"` | 5 vai trò (`WORKSHOP_PROGRAM`, `WORKSHOP_SPEAKER`, `WORKSHOP_LOGISTICS`, `WORKSHOP_REGISTRATION`, `WORKSHOP_REPORT`) |
| 8 | **`EMAIL_NEWSLETTER`** | `EMAIL_NEWSLETTER` | `"bản tin"` | 4 vai trò (`EMAIL_CONTENT`, `EMAIL_DESIGN`, `EMAIL_SEND`, `EMAIL_REPORT`) |

> **Lưu ý tuân thủ `AGENTS.md`**: Hạng mục `LIVESTREAM` đã bị loại bỏ hoàn toàn khỏi phạm vi dự án.

---

## 3. Đặc tả Luồng Gói Dịch vụ & Chiến dịch theo 2 Chế độ (`AGENCY` vs `PERSONAL`)

### 3.1. Trong Chế độ `AGENCY` (`workspaceMode = "AGENCY"`)
1. **Giai đoạn 1 — Chốt Gói Truyền thông (`3.5.1` – `3.5.4`)**:
   - `Owner` thiết lập danh mục Gói truyền thông mẫu (`MediaPackage`) tại cấp Agency (`3.5.1`).
   - Tại Workspace của khách hàng, `Manager` (hoặc `Client` đề xuất) chọn gói mẫu hoặc tùy chỉnh thành `WorkspaceMediaPackage` (`3.5.3`).
   - Hỗ trợ xuất bảng báo giá/đề xuất gói ra file **PDF đa ngôn ngữ** (`PackageExportRenderer`) hoặc tạo link chia sẻ công khai (`/s/:token`) gửi cho khách hàng xem trước.
   - Sau khi thống nhất với khách hàng, `Owner`/`Manager` bấm xác nhận chốt gói (`3.5.4 Approve Media Package` → `status = APPROVED`), mở khóa bước 2 trên thanh Tiến trình Sidebar.
2. **Giai đoạn 2 — Lập & Triển khai Chiến dịch (`3.5.5` – `3.5.9`)**:
   - `Manager` tạo bản nháp Chiến dịch (`3.5.5`), nhập mục tiêu, ý tưởng và lên danh sách các hạng mục công việc (`CampaignWorkItem`).
   - `CampaignPlanValidator` kiểm tra tổng số lượng từng loại hạng mục không vượt quá hạn mức của `WorkspaceMediaPackage` đã chốt.
   - Khi `Manager` bấm **Chốt & Triển khai Chiến dịch (`3.5.8` / `deploy`)**:
     - Chiến dịch chuyển sang `ACTIVE`.
     - `CampaignTaskStore.draftTask` tự động sinh các `TaskDocument` cha trong MongoDB, đồng thời **sinh sẵn bộ Subtask theo vai trò chuẩn (`TaskCatalog`)** cho từng Task (mặc định `status = TODO`, `dueDate` = hạn của Task cha, chờ `Manager` gán người phụ trách).
   - Trong suốt chiến dịch, tất cả các bên theo dõi tiến độ trên `CampaignTimelineGrid` (`3.5.6`), nơi hiển thị trực quan từng Task, các Subtask con, cờ **Trễ hạn (`Overdue`)** và cờ **Chờ Client duyệt (`Awaiting Client`)**.

### 3.2. Trong Chế độ `PERSONAL` (`workspaceMode = "PERSONAL"`)
Khi người dùng làm việc trong Không gian Cá nhân hoặc Nhóm bài tập (`workspaceMode = "PERSONAL"`):
1. **Không bắt buộc Gói dịch vụ (`Package-less Workflow`)**:
   - Bước `1. Gói dịch vụ` được ẩn khỏi thanh Tiến trình Sidebar.
   - Nếu người dùng vào trang **Chiến dịch (`/workspaces/:id/campaigns`)** để lập kế hoạch dài hạn (`3.5.5` – `3.5.8`), Backend tự động khởi tạo ngầm một `WorkspaceMediaPackage` khung nội bộ không giới hạn trần số lượng, cho phép người dùng cá nhân tự do thêm bất kỳ số lượng hạng mục nào trong 8 loại `TaskType` và bấm `Deploy` ngay lập tức.
   - Mọi Task sinh ra từ chiến dịch cá nhân mặc định có `requiresClientApproval = false` và tự gán cho chủ không gian nếu chưa chọn người khác.
2. **Làm việc không cần Chiến dịch (`Standalone Task Bypass`)**:
   - Người dùng cá nhân thậm chí không cần vào trang Chiến dịch mà có thể bấm **"+ Tạo công việc mới"** ngay tại trang Công việc (`/workspaces/:id/tasks`) hoặc từ **Bệ phóng Sáng tạo Cá nhân (`Personal Quick Launchpad`)** trên Dashboard để tạo trực tiếp 1 công việc lẻ (hệ thống tự gắn vào chiến dịch cá nhân mặc định chạy ngầm).

---

## 4. Đặc tả Luồng Yêu cầu Nội dung của Khách hàng (`3.5.10` – `3.5.13`)

Luồng `Content Request` phục vụ riêng cho tương tác giữa `Client` và `Manager` trong các Workspace có `workspaceMode = "AGENCY"`:
1. **`3.5.10 Create Content Request` (`Client`)**:
   - Từ `Client Portal` (`/workspaces/:id/portal`), `Client` gửi yêu cầu làm thêm hoặc điều chỉnh nội dung (nhập tiêu đề, loại nội dung mong muốn, mô tả yêu cầu, hạn mong muốn và tệp đính kèm). Bản ghi mới có `status = PENDING`.
2. **`3.5.11 Track Request Status` (`Manager`, `Client`)**:
   - Cả `Client` và `Manager` xem danh sách và trạng thái thời gian thực của từng yêu cầu, kèm liên kết tới `Task` thực thi sau khi yêu cầu được duyệt.
3. **`3.5.12 Update Request` (`Manager`, `Client`)**:
   - Khi yêu cầu đang ở `PENDING`, `Client` có thể sửa nội dung mô tả; `Manager` có thể bấm **Chấp nhận** (tự động chuyển hóa yêu cầu thành một `TaskDocument` trong Workspace để giao cho `Creator`) hoặc **Từ chối** kèm ghi chú phản hồi.
4. **`3.5.13 Cancel Request` (`Client`)**:
   - Khi yêu cầu đang ở `PENDING`, `Client` có quyền rút lại / hủy yêu cầu (`status = CANCELLED`).
- **Hành vi ở chế độ `PERSONAL`**: Vì không có `Client`, mục `Yêu cầu Nội dung (/requests)` được ẩn khỏi Sidebar để tránh dư thừa; người dùng cá nhân tạo trực tiếp Task tại `/tasks`.

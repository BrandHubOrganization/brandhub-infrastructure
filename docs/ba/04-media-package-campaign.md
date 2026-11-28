# 04 — Gói Truyền thông, Chiến dịch & Yêu cầu Nội dung (Media Package, Media Campaign & Content Request)

> Navigation: [← BA Overview & Hub](./README.md) · [← 03 - Agency & Workspace](./03-agency-workspace.md) · [Tiếp: 05 - Content & Task Workflow →](./05-content-task-workflow.md)
>
> **Phạm vi FR chuẩn**: **Mục `3.5 Media Package & Media Campaign` — 13 FR (`3.5.1` – `3.5.13`)** | `UC-040` – `UC-052` · Use Cases chi tiết: [use-cases/03-media-package-campaign.md](./use-cases/03-media-package-campaign.md) · Đặc tả SRS: [04-media-package-campaign](../feature/srs/04-media-package-campaign/README.md).
> Đã đồng bộ với **8 loại Dịch vụ / Công việc chuẩn (`PackageServiceType` ↔ `TaskType`)**, luồng `Manager-led Package & Campaign Approval`, và luồng **Chiến dịch Cá nhân không cần Gói dịch vụ (`workspaceMode = "PERSONAL"`)**.

---

## 1. Bảng Tổng hợp 13 Yêu cầu Chức năng Chuẩn (`3.5.1` – `3.5.13`)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (Atomic CRUD FR) | Actors / Roles Chuẩn | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :--- |
| **`3.5.1`** | `UC-040` | **Create Media Package** | `Owner` | Tạo mới hoặc tùy chỉnh Gói truyền thông mẫu (`MediaPackage`) ở cấp `Agency` với danh mục các hạng mục dịch vụ, số lượng, đơn vị chuẩn, đơn giá và điều khoản. |
| **`3.5.2`** | `UC-041` | **View Template Media Package** | `Owner`, `Manager`, `Client` | Xem danh sách và chi tiết các Gói truyền thông mẫu của `Agency` hoặc bảng đề xuất gói gắn với `Workspace` (hỗ trợ xuất PDF đề xuất đa ngôn ngữ & chia sẻ link công khai cho `Guest`). |
| **`3.5.3`** | `UC-042` | **Request Media Package** | `Owner`, `Manager`, `Client` | Đề xuất và đàm phán điều chỉnh gói truyền thông (`WorkspaceMediaPackage` — giá, thời lượng, số lượng hạng mục) qua từng vòng cho đến khi thống nhất (`BR-25`, `BR-26`). |
| **`3.5.4`** | `UC-043` | **Approve Media Package** | `Owner`, `Manager`, `Client` | Phê duyệt chốt gói truyền thông khi cả hai bên (`Agency` và `Client`) đồng thuận (`status = APPROVED`, `BR-26`, `BR-27`) để mở khóa bước lập Chiến dịch truyền thông. |
| **`3.5.5`** | `UC-044` | **Create Media Campaign** | `Owner`, `Manager` | Khởi tạo Kế hoạch Chiến dịch truyền thông (`MediaCampaign`): đặt tên, mục tiêu, lộ trình `Start`/`End Date` và danh sách các hạng mục bài viết dự kiến (`workItems`, `BR-27`). |
| **`3.5.6`** | `UC-045` | **View Media Campaign** | `Owner`, `Manager`, `Creator`, `Client` | Xem chi tiết kế hoạch chiến dịch, lịch sử phiên bản, luồng phản hồi và **Lịch trình Chiến dịch (`CampaignTimelineGrid`)** kèm trạng thái từng Subtask (`BR-27`, `BR-28`). |
| **`3.5.7`** | `UC-046` | **Update Media Campaign** | `Owner`, `Manager`, `Client` | Cập nhật nội dung Kế hoạch Chiến dịch truyền thông và gửi phản hồi điều chỉnh khi chiến dịch đang ở trạng thái nháp / chờ duyệt (`BR-27`–`BR-30`). |
| **`3.5.8`** | `UC-047` | **Approve Media Campaign** | `Owner`, `Manager`, `Client` | Phê duyệt và kích hoạt triển khai Chiến dịch (`ACTIVE`): tự động đẩy toàn bộ hạng mục công việc vào Task Backlog kèm bộ **Subtask theo vai trò chuẩn (`TaskCatalog`, `BR-29`)**. |
| **`3.5.9`** | `UC-048` | **Complete Media Campaign** | `Owner`, `Manager` | Nghiệm thu và hoàn tất Chiến dịch truyền thông (`status = COMPLETED`), đồng thời tự động hủy (`CANCELLED`) các yêu cầu phát sinh còn treo `PENDING` thuộc chiến dịch đó (`BR-30`). |
| **`3.5.10`** | `UC-049` | **Create Content Request** | `Owner`, `Manager`, `Client` | Tạo yêu cầu nội dung bổ sung/phát sinh ngoài kế hoạch ban đầu (`status = PENDING`, `BR-31`). |
| **`3.5.11`** | `UC-050` | **Track Request Status** | `Owner`, `Manager`, `Client` | Theo dõi và điều phối trạng thái Yêu cầu nội dung (`PENDING → IN_PROGRESS → ACCEPTED / DENIED`); khi chuyển sang `ACCEPTED`, tự động sinh `Task` đẩy vào Backlog (`BR-31`, `BR-33`). |
| **`3.5.12`** | `UC-051` | **Update Request** | `Owner`, `Manager`, `Client` | Chỉnh sửa nội dung của Yêu cầu phát sinh khi còn ở trạng thái `PENDING`; khóa chỉnh sửa ngay khi đã chuyển sang `IN_PROGRESS`, `ACCEPTED` hoặc `DENIED` (`BR-32`). |
| **`3.5.13`** | `UC-052` | **Cancel Request** | `Owner`, `Manager`, `Client` | Hủy yêu cầu nội dung phát sinh khi đang ở trạng thái `PENDING` (`status = CANCELLED`, `BR-32`). |

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
2. **`3.5.11 Track Request Status` (`Owner`, `Manager`, `Client`)**:
   - Theo dõi và điều phối trạng thái của từng yêu cầu qua 4 trạng thái chuẩn: `PENDING -> IN_PROGRESS -> ACCEPTED` (hoặc `DENIED`). Khi phía Agency (`Owner`/`Manager`) chuyển sang `ACCEPTED`, hệ thống tự động sinh một `TaskDocument` đẩy vào Task Backlog của Workspace.
3. **`3.5.12 Update Request` (`Owner`, `Manager`, `Client`)**:
   - Người tạo chỉnh sửa tiêu đề, mô tả, hạn mong muốn hoặc tệp tham khảo khi yêu cầu đang ở trạng thái `PENDING`; ngay khi đã chuyển sang `IN_PROGRESS`, `ACCEPTED` hoặc `DENIED` thì nội dung yêu cầu bị khóa không cho sửa (`BR-32`).
4. **`3.5.13 Cancel Request` (`Owner`, `Manager`, `Client`)**:
   - Khi yêu cầu đang ở `PENDING`, người tạo có quyền hủy yêu cầu (`status = CANCELLED`, `BR-32`).
- **Hành vi ở chế độ `PERSONAL`**: Vì không có `Client`, mục `Yêu cầu Nội dung (/requests)` được ẩn khỏi Sidebar để tránh dư thừa; người dùng cá nhân tạo trực tiếp Task tại `/tasks`.

---

## 5. Bảng Tham chiếu Quy tắc Nghiệp vụ (`BR-25` – `BR-33`)

| Mã BR | Tên Quy tắc | Quy định Ràng buộc Cụ thể | FR Áp dụng |
| :-: | :--- | :--- | :--- |
| `BR-25` | **Sao chép Độc lập Gói Truyền thông** | Tùy chỉnh Gói dịch vụ trong một `Workspace` tạo bản sao điều khoản riêng trên `workspace_media_packages`, không bao giờ làm thay đổi `MediaPackage` mẫu gốc của `Agency`. | `3.5.1`–`3.5.3` |
| `BR-26` | **Đồng thuận Nguyên tử 2 Bên (`Two-Party ACID Approval`)** | Ở chế độ `AGENCY`, gói dịch vụ chỉ đạt `APPROVED` khi cả `approved_by_agency_at` và `approved_by_client_at` đều khác `NULL`; bất kỳ chỉnh sửa nào lên điều khoản/số lượng sẽ tự động đặt lại chữ ký của bên đối diện về `NULL` trong cùng giao dịch PostgreSQL. | `3.5.3`, `3.5.4` |
| `BR-27` | **Mở khóa Chiến dịch từ Gói Đã Duyệt** | Trong chế độ `AGENCY`, chỉ được khởi tạo và phê duyệt `MediaCampaign` khi `Workspace` đã có `WorkspaceMediaPackage` ở trạng thái `APPROVED` và tổng hạng mục chiến dịch không vượt trần gói. | `3.5.4`–`3.5.8` |
| `BR-28` | **Lịch sử Phiên bản Chiến dịch (`CampaignVersion`)** | Mỗi lần cập nhật kế hoạch chiến dịch hoặc gửi phản hồi đàm phán đều lưu lại snapshot `campaign_versions` và sự kiện `campaign_review_events` để đối chiếu. | `3.5.6`, `3.5.7` |
| `BR-29` | **Sinh Công việc Chống Trùng lặp (`Idempotent Deploy`)** | Khi phê duyệt triển khai chiến dịch (`3.5.8`), `campaign_deployments` sinh nguyên tử các `TaskDocument` và `Subtask` vai trò chuẩn trong MongoDB kèm khóa chống sinh trùng hạng mục. | `3.5.8` |
| `BR-30` | **Nghiệm thu Chiến dịch & Dọn Yêu cầu Treo** | Khi chiến dịch chuyển sang `COMPLETED` (`3.5.9`), hệ thống khóa tạo mới hạng mục trong chiến dịch đó và tự động chuyển các `Content Request` đang treo `PENDING` thuộc chiến dịch sang `CANCELLED`. | `3.5.7`, `3.5.9` |
| `BR-31` | **Máy Trạng thái Yêu cầu Nội dung 1 Chiều** | `Content Request` tuân thủ chu trình `PENDING → IN_PROGRESS → ACCEPTED / DENIED` (hoặc `CANCELLED` từ `PENDING`); `DENIED` và `CANCELLED` là trạng thái kết thúc không thể mở lại. | `3.5.10`, `3.5.11` |
| `BR-32` | **Khóa Sửa / Hủy Yêu cầu sau Tiếp nhận** | Người tạo chỉ được chỉnh sửa (`3.5.12`) hoặc hủy (`3.5.13`) khi yêu cầu còn ở `PENDING`; ngay khi `Manager`/`Owner` chuyển sang `IN_PROGRESS` thì nội dung yêu cầu gốc được khóa cố định. | `3.5.12`, `3.5.13` |
| `BR-33` | **Tự động Khởi tạo Task khi Chấp thuận Yêu cầu** | Khi `Content Request` chuyển sang `ACCEPTED`, hệ thống tự động khởi tạo một `TaskDocument` liên kết mã yêu cầu và đồng bộ ngược trạng thái hoàn tất qua `content_request_completion_jobs`. | `3.5.11`, `3.6.1`, `3.6.2` |

---

## 6. Ánh xạ Thực thể Cơ sở Dữ liệu (`PostgreSQL` ↔ `MongoDB`)

- **PostgreSQL (`brandhub-business-service`)**: `media_packages`, `workspace_media_packages`, `package_negotiation_events`, `media_campaigns`, `campaign_versions`, `campaign_review_events`, `campaign_deployments`, `content_request_completion_jobs` (xem [ERD Entity Descriptions](../database/schema/erd-entity-descriptions.md)).
- **MongoDB (`brandhub-business-service`)**: `content_requests`, `tasks`, `task_sections` (liên kết mềm về `media_campaigns.id` và `workspaces.id`).

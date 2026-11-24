# 05 — Công việc, Nội dung Đa định dạng, Tư liệu & Cộng tác (Content & Workflow)

> Navigation: [← BA Overview & Hub](./README.md) · [← 04 - Media Package & Campaign](./04-media-package-campaign.md) · [Tiếp: 06 - AI Features →](./06-ai-features.md)
>
> **Phạm vi FR chuẩn** (đồng bộ 100% với `Các FR của hệ thống  - Feature_Function Requirement.csv`):
> - **Mục `3.6 Content & Workflow`**: **35 FR (`3.6.1` – `3.6.35`)** | `UC-053` – `UC-087`
> - Use Cases chi tiết: [use-cases/04-content-task-workflow.md](./use-cases/04-content-task-workflow.md) · Đặc tả SRS: [05-content-task-workflow](../feature/srs/05-content-task-workflow/README.md)

---

## 1. Bảng Tổng hợp 35 Yêu cầu Chức năng Chuẩn (`3.6.1` – `3.6.35`)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (141-FR Baseline) | Actors / Roles Chuẩn | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :--- |
| **`3.6.1`** | `UC-053` | **Identify Task Detail** | `Owner`, `Manager`, `Creator`, `Client` | Đặc tả chi tiết thông tin công việc từ Backlog (`/workspaces/:id/tasks/:taskId`): Loại công việc (`8 TaskTypes`), Nền tảng đăng tải, Hạn hoàn thành (`Due Date`), Giờ lên lịch, Mức độ ưu tiên, Yêu cầu đầu ra (`Brief`) và tài liệu tham khảo (`BR-22`, `BR-33`). |
| **`3.6.2`** | `UC-054` | **Assign Task to Creator** | `Owner`, `Manager` | Phân công `Task` (và các `Subtask` theo vai trò) cho `Creator` phụ trách thực hiện chính và tùy chọn người kiểm tra nội bộ trong cùng Workspace, gửi thông báo thời gian thực (`BR-20`, `BR-33`, `BR-34`). |
| **`3.6.3`** | `UC-055` | **Add Comments on Task** | `Owner`, `Manager`, `Creator`, `Client` | Thêm bình luận theo chuỗi (`threaded comments`), đính kèm hình ảnh/tệp minh họa và gắn thẻ `@mention` thành viên ngay trên từng `Task` (`BR-12`, `BR-20`). |
| **`3.6.4`** | `UC-056` | **List Task View** | `Owner`, `Manager`, `Creator`, `Client` | Xem và thao tác danh sách công việc dạng bảng chi tiết (`?view=list`) hỗ trợ sắp xếp theo cột, kéo thả thứ tự ưu tiên và mở nhanh 3 chế độ Notion Peek (`Side Peek`, `Center Modal`, `Full Page`). |
| **`3.6.5`** | `UC-057` | **Calendar Task View** | `Owner`, `Manager`, `Creator`, `Client` | Xem lịch công việc và lịch đăng bài trực quan theo Ngày / Tuần / Tháng (`?view=calendar`), chuẩn hóa theo Timezone của Workspace (`BR-22`) và hỗ trợ kéo thả đổi lịch nhanh. |
| **`3.6.6`** | `UC-058` | **Gantt Timeline Task View** | `Owner`, `Manager`, `Creator`, `Client` | Xem tiến độ công việc dạng biểu đồ thác nước theo trục thời gian (`?view=gantt`), thể hiện mốc bắt đầu – kết thúc và phần trăm hoàn thành của từng giai đoạn (`BR-22`, `BR-44`). |
| **`3.6.7`** | `UC-059` | **Kanban Board Task View** | `Owner`, `Manager`, `Creator`, `Client` | Xem và kéo thả thẻ công việc trên bảng Kanban (`?view=kanban`) với 3 chế độ nhóm cột (`Group by Status`, `Group by Assignee`, `Group by Platform`) tuân thủ quy trình duyệt (`BR-33`, `BR-34`). |
| **`3.6.8`** | `UC-060` | **View Task Filter** | `Owner`, `Manager`, `Creator`, `Client` | Tìm kiếm từ khóa và lọc đa tiêu chí (Trạng thái, `Assignee`, `Campaign`, Nền tảng, Độ ưu tiên, `Tag`, Khoảng thời gian) đồng bộ xuyên suốt cả 4 chế độ xem List, Calendar, Gantt và Kanban (`BR-44`). |
| **`3.6.9`** | `UC-061` | **Approval Sequence (Creator -> Manager -> Client)** | `Owner`, `Manager`, `Creator`, `Client` | Quy trình phê duyệt nội dung phân cấp 3 tầng nghiêm ngặt (`Creator -> [QC nội bộ] -> Manager -> Client`): chỉ khi qua đủ các cấp mới đạt `APPROVED`; bất kỳ cấp nào nhấn `Reject` (kèm lý do bắt buộc) đều đưa về bước `Creator` đầu tiên nhưng giữ nguyên toàn bộ nhật ký duyệt trước đó (`BR-34`, `BR-54`). Hỗ trợ `Self-Approve` 1 chạm trong chế độ `PERSONAL`. |
| **`3.6.10`** | `UC-062` | **Content Writing View** | `Owner`, `Manager`, `Creator` | Soạn thảo bài đăng đa phương tiện tích hợp bộ chuyển đổi kiểu chữ **Unicode** trực tiếp (in đậm, in nghiêng, chữ nghệ thuật dán/đăng thẳng lên **Facebook, Instagram, TikTok, Threads** không mất định dạng) và lưu lịch sử phiên bản (`BR-35`). |
| **`3.6.11`** | `UC-063` | **View Material Repository** | `Owner`, `Manager`, `Creator`, `Client` | Xem kho tư liệu sáng tạo của Workspace (`/workspaces/:id/library`) phân tách rõ: (1) Ảnh/Video gốc `RAW` kèm nhãn cảnh báo không đăng trực tiếp (`BR-36`), (2) Ấn phẩm hoàn chỉnh `Retouched`, và (3) `Brand Reference Assets` do `Client` cung cấp. |
| **`3.6.12`** | `UC-064` | **Add Material Repository** | `Owner`, `Manager`, `Creator`, `Client` | Tải lên tư liệu hình ảnh, video hoặc tài liệu thương hiệu mới vào kho S3 của Workspace kèm phân loại bắt buộc (`RAW`, `Retouched`, `Brand Reference Asset`, `BR-36`, `BR-58`). |
| **`3.6.13`** | `UC-065` | **Update Material Repository** | `Owner`, `Manager`, `Creator` | Cập nhật tên, mô tả, thẻ tìm kiếm, tải lên phiên bản tệp mới đã hậu kỳ và chuyển phân loại từ `RAW` sang `Retouched` (`BR-36`). |
| **`3.6.14`** | `UC-066` | **Remove Material Repository** | `Owner`, `Manager`, `Creator` | Xóa mềm (`Soft Delete`) tư liệu khỏi danh sách chọn mới nhưng bảo toàn liên kết media trong các bài viết và lịch sử công việc cũ (`BR-36`). |
| **`3.6.15`** | `UC-067` | **Connect Google Drive Storage** | `Owner`, `Manager`, `Client` | Liên kết tài khoản Google Drive với Workspace qua OAuth 2.0 (`/workspaces/:id/library/drive`), mã hóa **AES-256** đối với Refresh Token (`BR-37`). |
| **`3.6.16`** | `UC-068` | **Sync Material from Google Drive** | `Owner`, `Manager`, `Client` | Đồng bộ các tệp hình ảnh/video từ thư mục Google Drive đã kết nối vào `Material Repository`, chống nhập trùng lặp theo mã tệp (`BR-36`, `BR-37`, `BR-58`). |
| **`3.6.17`** | `UC-069` | **Disconnect Google Drive Storage** | `Owner`, `Manager`, `Client` | Ngắt kết nối Google Drive khỏi Workspace, thu hồi OAuth token đã lưu nhưng giữ nguyên toàn bộ tư liệu đã đồng bộ trước đó (`BR-37`). |
| **`3.6.18`** | `UC-070` | **Apply Watermark** | `Owner`, `Manager`, `Creator` | Đóng dấu bản quyền thương hiệu (logo `Client` hoặc chữ, tùy chỉnh 9 vị trí, tỷ lệ, góc xoay, độ mờ `10%–100%`) xuất ra bản ảnh mới trong kho mà vẫn giữ nguyên ảnh gốc (`BR-38`). |
| **`3.6.19`** | `UC-071` | **Download Material** | `Owner`, `Manager`, `Creator`, `Client` | Tải tệp tư liệu từ `Material Repository` (hoặc bản xuất PDF/DOCX của công việc) về thiết bị cá nhân qua liên kết tốc độ cao (`BR-20`, `BR-36`). |
| **`3.6.20`** | `UC-072` | **Apply Hashtag** | `Owner`, `Manager`, `Creator` | Chọn và chèn nhanh bộ thẻ Hashtag của Workspace vào nội dung đang soạn thảo, tự động chuẩn hóa tiền tố `#`, khử trùng lặp và kiểm tra giới hạn từng nền tảng MXH (`BR-35`, `BR-39`). |
| **`3.6.21`** | `UC-073` | **View Hashtag Collection** | `Owner`, `Manager`, `Creator` | Xem danh sách các bộ sưu tập Hashtag của Workspace (do `Creator` tổng hợp, bộ bắt buộc từ `Client` và gợi ý xu hướng AI, `BR-39`). |
| **`3.6.22`** | `UC-074` | **Add Hashtag Collection** | `Owner`, `Manager`, `Creator`, `Client` | Tạo mới bộ sưu tập Hashtag hoặc thêm thẻ hashtag kèm phân loại mục đích (`Brand Core`, `Campaign Event`, `Seasonal Trend`, `Mandatory Client Tag`, `BR-39`). |
| **`3.6.23`** | `UC-075` | **Update Hashtag Collection** | `Owner`, `Manager`, `Creator` | Cập nhật tên bộ sưu tập, phân loại và danh sách thẻ hashtag bên trong bộ sưu tập của Workspace (`BR-39`). |
| **`3.6.24`** | `UC-076` | **Remove Hashtag Collection** | `Owner`, `Manager`, `Creator` | Xóa mềm (`Soft Delete`) bộ sưu tập Hashtag khỏi danh sách hoạt động mà không ảnh hưởng các bài viết đã chèn trước đó (`BR-39`). |
| **`3.6.25`** | `UC-077` | **Create Survey** | `Owner`, `Manager`, `Creator` | Tạo biểu mẫu khảo sát tương tác phục vụ sự kiện/workshop/chiến dịch (`/workspaces/:id/surveys/new` — câu hỏi 1 lựa chọn, nhiều lựa chọn, thang điểm, tự luận) kèm link chia sẻ công khai (`BR-40`). |
| **`3.6.26`** | `UC-078` | **View Survey Analysis** | `Owner`, `Manager`, `Client` | Xem báo cáo thống kê số lượt phản hồi, tỷ lệ hoàn thành và biểu đồ phân bổ câu trả lời của biểu mẫu khảo sát (`/workspaces/:id/surveys/:surveyId/analytics`, `BR-40`). |
| **`3.6.27`** | `UC-079` | **Generate Meeting Link** | `Owner`, `Manager`, `Creator` | Tự động khởi tạo đường dẫn phòng họp trực tuyến (Google Meet / Jitsi) ngay trong Workspace hoặc trên `Task` và gửi thông báo kèm link họp cho các thành viên (`BR-22`, `BR-40`). |
| **`3.6.28`** | `UC-080` | **View Mail Template** | `Owner`, `Manager`, `Creator` | Xem danh sách và nội dung chi tiết các mẫu Email mặc định của hệ thống và mẫu tùy chỉnh của Workspace kèm biến động (`{{client_name}}`, `{{campaign_name}}`, `{{task_title}}`, `BR-41`). |
| **`3.6.29`** | `UC-081` | **Create Mail Template** | `Owner`, `Manager`, `Creator` | Tạo mới mẫu Email thông báo định dạng HTML / BlockBuilder hoặc nhân bản từ mẫu có sẵn chèn các biến giữ chỗ (`BR-41`). |
| **`3.6.30`** | `UC-082` | **Update Mail Template** | `Owner`, `Manager`, `Creator` | Chỉnh sửa tiêu đề, nội dung HTML và kiểm tra cú pháp biến động `{{variable}}` của mẫu Email trong Workspace (`BR-41`). |
| **`3.6.31`** | `UC-083` | **Delete Mail Template** | `Owner`, `Manager`, `Creator` | Xóa mẫu Email tùy chỉnh khỏi thư viện mẫu (chặn xóa mẫu hệ thống mặc định bắt buộc và giữ nguyên nhật ký email đã gửi, `BR-41`). |
| **`3.6.32`** | `UC-084` | **Send Email via Template** | `Owner`, `Manager`, `Creator` | Gửi email hoặc bản tin `EMAIL_NEWSLETTER` tới `Client` / nhóm người nhận qua mẫu đã chọn, tự động điền biến giữ chỗ và đẩy qua hàng đợi SMTP bất đồng bộ (`BR-22`, `BR-41`). |
| **`3.6.33`** | `UC-085` | **Check Compliance Content** | `Owner`, `Manager`, `Creator` | Kiểm tra an toàn nội dung bài đăng trước khi xuất bản: rà soát ngôn từ bạo lực, nhạy cảm, từ khóa cấm trên MXH và hình ảnh dung tục kèm gợi ý chỉnh sửa (`BR-42`, `BR-54`). |
| **`3.6.34`** | `UC-086` | **View Content History** | `Owner`, `Manager`, `Creator` | Xem lịch sử các phiên bản nội dung (`TaskSectionVersion`) và tài nguyên AI đã khởi tạo trước đó để khôi phục/tái sử dụng mà **không bị trừ lại AI Credit** (`BR-35`, `BR-60`). |
| **`3.6.35`** | `UC-087` | **Chat Realtime** | `Owner`, `Manager`, `Creator`, `Client` | Nhắn tin cộng tác trực tuyến thời gian thực qua WebSocket (STOMP) theo từng kênh Workspace độc lập: văn bản giàu định dạng, luồng trả lời (`Thread`), đính kèm tệp, trạng thái đã xem, hẹn giờ gửi và gọi thoại (`BR-20`, `BR-43`). |

---

## 2. Danh mục 8 Loại Công việc (`TaskType`), Subtask theo Vai trò & Trình soạn Chia phần (`TaskCatalog`)

Mỗi `TaskDocument` thuộc **1 trong 8 loại `TaskType` chuẩn**, trong đó các phần sản phẩm đầu ra (**`O` — Output**) hiển thị cho `Client` phê duyệt, còn các phần nghiệp vụ nội bộ (**`I` — Internal**) được ẩn hoàn toàn khỏi `Client`:

| Loại Công việc (`TaskType`) | Các Vai trò Subtask (`subtaskRole`) | Các Phần Soạn thảo (`sectionKey`) & Phân loại (`O` / `I`) | Định dạng Xuất File |
| :--- | :--- | :--- | :-: |
| **1. `POST`** *(Bài đăng MXH)* | `POST_RESEARCH`, `POST_CONTENT`, `POST_MEDIA`, `POST_EDITING`, `POST_PUBLISHING` | `POST.BRIEF` (**I**), `POST.CAPTION` (**O**), `POST.MEDIA` (**O**), `POST.CHANNELS` (**O** — FB, IG, TikTok, Threads) | **PDF** |
| **2. `SHORT_VIDEO`** *(Video ngắn)* | `VIDEO_SCRIPT`, `VIDEO_SHOOT`, `VIDEO_EDIT`, `VIDEO_PUBLISH` | `VIDEO.SCRIPT` (**O**), `VIDEO.SHOOT` (**I**), `VIDEO.EDIT` (**O**), `VIDEO.CAPTION` (**O**), `VIDEO.CHANNELS` (**O**) | **PDF** |
| **3. `SURVEY`** *(Khảo sát)* | `SURVEY_DESIGN`, `SURVEY_DISTRIBUTE`, `SURVEY_ANALYSIS` | `SURVEY.FORM` (**O**), `SURVEY.DISTRIBUTION` (**O**), `SURVEY.REPORT` (**O**) | **PDF** |
| **4. `EVENT_PLAN`** *(Kế hoạch sự kiện)* | `EVENT_AGENDA`, `EVENT_LOGISTICS`, `EVENT_PROMOTION`, `EVENT_ONSITE`, `EVENT_REPORT` | `EVENT.AGENDA` (**O**), `EVENT.LOGISTICS` (**I**), `EVENT.PROMOTION` (**O**), `EVENT.RUNSHEET` (**I**), `EVENT.REPORT` (**O**) | **PDF** |
| **5. `PRESS_RECOMMENDATION`** *(Thông cáo báo chí)* | `PRESS_MEDIA_LIST`, `PRESS_RELEASE`, `PRESS_PITCHING`, `PRESS_TRACKING` | `PRESS.MEDIA_LIST` (**I**), `PRESS.RELEASE` (**O**), `PRESS.CONTACT_LOG` (**I**), `PRESS.COVERAGE` (**O**) | **DOCX** |
| **6. `KOL_BOOKING`** *(Hợp tác KOL)* | `KOL_SOURCING`, `KOL_NEGOTIATION`, `KOL_BRIEF`, `KOL_CONTENT_REVIEW`, `KOL_TRACKING` | `KOL.SHORTLIST` (**O**), `KOL.DEAL` (**I**), `KOL.BRIEF` (**O**), `KOL.DRAFT` (**O**), `KOL.REPORT` (**O**) | **PDF** |
| **7. `WORKSHOP`** *(Hội thảo / Workshop)* | `WORKSHOP_PROGRAM`, `WORKSHOP_SPEAKER`, `WORKSHOP_LOGISTICS`, `WORKSHOP_REGISTRATION`, `WORKSHOP_REPORT` | `WORKSHOP.PROGRAM` (**O**), `WORKSHOP.SPEAKERS` (**O**), `WORKSHOP.LOGISTICS` (**I**), `WORKSHOP.REGISTRATION` (**O**), `WORKSHOP.REPORT` (**O**) | **PDF** |
| **8. `EMAIL_NEWSLETTER`** *(Bản tin Email)* | `EMAIL_CONTENT`, `EMAIL_DESIGN`, `EMAIL_SEND`, `EMAIL_REPORT` | `EMAIL.CONTENT` (**O**), `EMAIL.DESIGN` (**O**), `EMAIL.AUDIENCE` (**O**), `EMAIL.REPORT` (**O**) | **PDF** |

---

## 3. Quy trình Phê duyệt 3 Tầng (`3.6.9`) vs. Tự duyệt 1 Chạm (`PERSONAL`)

- **Chế độ `AGENCY` (`Creator -> [QC] -> Manager -> Client`)**:
  - `Creator` hoàn thành phần nội dung và nhấn `Submit` → chụp bản ghi `TaskSectionVersion` bất biến.
  - Nếu có gán kiểm tra chéo nội bộ (`QC`), qua bước QC trước khi trình `Manager` duyệt nội bộ (`INTERNAL_APPROVED`).
  - Với các phần đầu ra (**`O`**) trên Task có `requiresClientApproval = true`, trình tiếp lên `Client` phê duyệt cuối cùng (`CLIENT_APPROVED`).
  - Nếu bất kỳ cấp nào nhấn `Reject` / `Return` (bắt buộc nhập lý do), tiến trình quay về bước `Creator` đầu tiên để chỉnh sửa, đồng thời tự động hủy lịch đăng (`PostService.cancelTaskSchedule`) nếu bài đã hẹn giờ và bảo toàn toàn bộ nhật ký duyệt của các vòng trước.
- **Chế độ `PERSONAL` (`Self-Approve` 1 chạm)**:
  - Chủ không gian (`Owner`/`Manager`) có thể tạo trực tiếp `Standalone Task` cho cả 8 loại công việc và nhấn **"Hoàn tất & Duyệt ngay"** để chuyển nguyên tử toàn bộ các phần sang `APPROVED`, mở khóa xuất bản ngay lập tức.

---

## 4. Bảng Tham chiếu Quy tắc Nghiệp vụ (`BR-34` – `BR-44`, `BR-54`)

| Mã BR | Tên Quy tắc | Quy định Ràng buộc Cụ thể | FR Áp dụng |
| :-: | :--- | :--- | :--- |
| `BR-34` | **Thứ tự Phê duyệt 3 Tầng & Bảo toàn Lịch sử** | Nội dung phải đi tuần tự `Creator → [QC] → Manager → Client`; khi bị trả lại (`Reject`/`Return` kèm lý do bắt buộc), vòng duyệt tăng `approvalRound + 1` nhưng giữ nguyên 100% nhật ký `task_approvals` và `task_section_events` của các vòng trước. | `3.6.2`, `3.6.7`, `3.6.9` |
| `BR-35` | **Tương thích Unicode & Lịch sử Phiên bản** | Mọi lần nộp bài đều lưu bản chụp `task_section_versions` bất biến; trình soạn thảo chuyển đổi ký tự Unicode chuẩn toán học giúp giữ nguyên định dạng in đậm/nghiêng trên Facebook, Instagram, TikTok và Threads. | `3.6.10`, `3.6.20`, `3.6.34` |
| `BR-36` | **Phân loại Kho Tư liệu & Chặn Đăng File `RAW`** | Tư liệu bắt buộc gắn nhãn `RAW`, `Retouched` hoặc `Brand Reference Asset`; tệp `RAW` bị chặn chọn trực tiếp vào kênh xuất bản MXH, và thao tác xóa tư liệu kiểm tra `material_references` để không làm gãy bài đăng cũ. | `3.6.11`–`3.6.14`, `3.6.19` |
| `BR-37` | **Bảo mật OAuth & Chống Trùng Đồng bộ Google Drive** | Khóa kết nối Google Drive được mã hóa `AES-256-GCM`; tiến trình đồng bộ đối chiếu `driveFileId` và `generation` trên `repository_drive_objects` để chống nhân bản tệp và bảo toàn tư liệu sau khi ngắt kết nối. | `3.6.15`–`3.6.17` |
| `BR-38` | **Đóng dấu Watermark Không Phá hủy Ảnh Gốc** | `Apply Watermark` (`3.6.18`) luôn kết xuất ra phiên bản ảnh dẫn xuất mới trên S3, giữ nguyên tệp gốc ban đầu. | `3.6.18` |
| `BR-39` | **Chuẩn hóa Tiền tố `#` & Khử Trùng Hashtag** | Hệ thống tự động gắn tiền tố `#`, loại bỏ khoảng trắng và khử trùng lặp thẻ khi chèn bộ sưu tập Hashtag vào bài viết. | `3.6.20`–`3.6.24` |
| `BR-40` | **Khảo sát Công khai & Phòng Họp Nhúng Ngữ cảnh** | Biểu mẫu khảo sát (`3.6.25`) cho phép `Guest` gửi phản hồi qua đường dẫn chia sẻ mà không cần tài khoản; link phòng họp (`3.6.27`) đồng bộ theo múi giờ Workspace. | `3.6.25`–`3.6.27` |
| `BR-41` | **Kiểm định Biến Giữ chỗ & Bảo vệ Mẫu Email Hệ thống** | Cú pháp `{{variable}}` được kiểm tra hợp lệ trước khi lưu/gửi qua hàng đợi `mail_batches`; không cho phép xóa các mẫu thông báo hệ thống mặc định. | `3.6.28`–`3.6.32` |
| `BR-42` | **Rà soát An toàn Cộng đồng (`Compliance Check`)** | Quét từ khóa vi phạm tiêu chuẩn cộng đồng, ngôn từ kích động/nhạy cảm (không kiểm tra đạo văn/bản quyền); các trường hợp vượt ngưỡng rủi ro được đẩy sang `Content Moderation Queue` (`3.10.4`). | `3.6.33`, `3.10.4` |
| `BR-43` | **Cô lập Kênh Chat Thời gian thực theo Workspace** | Kênh nhắn tin STOMP WebSocket, tin nhắn hẹn giờ (`chat_scheduled_messages`) và cuộc gọi thoại/video Agora (`chat_calls`) được cô lập nghiêm ngặt theo thành viên của từng `Workspace`. | `3.6.35` |
| `BR-44` | **Đồng bộ Bộ lọc Xuyên suốt 4 Chế độ Xem Task** | Trạng thái lọc/tìm kiếm (`3.6.8`) giữ đồng nhất khi chuyển đổi qua lại giữa `List`, `Calendar`, `Gantt` và `Kanban`. | `3.6.4`–`3.6.8` |

---

## 5. Bảo mật Kho Tư liệu (`Client Vault` & `RepositoryEnvelopeCrypto`) và Cộng tác Thời gian thực

- **Mã hóa Phong bì S3 & Kho Riêng Khách hàng (`Client Vault`)**: Các thư mục/tệp nhạy cảm trong `materials` và `material_folders` được bảo vệ bằng cơ chế mã hóa phong bì KMS `RepositoryEnvelopeCrypto` (`ALG_AES_256_GCM_HKDF_SHA512_COMMIT_KEY`), đồng bộ hạn mức dung lượng bất đồng bộ qua `material_audit_outbox` (MongoDB) → `material_audit_receipts` / `agency_storage_usage` / `client_vault_storage_usage` (PostgreSQL).
- **Đồng bộ Tài liệu Cộng tác (CRDT/OT & WebSocket)**: Chỉnh sửa đồng thời trên nội dung công việc được đồng bộ qua **TipTap + Yjs** (`task_content_operations`, `task_content_snapshots`) cùng kênh thông báo đẩy tức thì qua WebSocket STOMP.

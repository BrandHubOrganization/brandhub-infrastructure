# UC 04 — Content & Workflow (`UC-053` – `UC-087`)

> [<< 03-media-package-campaign.md](./03-media-package-campaign.md) | [UC Index](./README.md) | [Domain BA Spec: 05-content-task-workflow.md](../05-content-task-workflow.md) | [05-ai-features.md >>](./05-ai-features.md)
>
> Đồng bộ chuẩn xác 1-đối-1 với `Các FR của hệ thống - Feature_Function Requirement.csv` và `AGENTS.md`. Chỉ sử dụng **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)**.

---

## 1. Bảng Tổng Hợp Use Cases (35 UCs)

| UC ID | Use Case Title | Canonical Actor(s) | Related FR | Business Rules |
| :-: | :--- | :--- | :-: | :--- |
| `UC-053` | Identify Task Detail | `Owner`, `Manager`, `Creator`, `Client` | `3.6.1` | `BR-22, BR-33` |
| `UC-054` | Assign Task to Creator | `Owner`, `Manager` | `3.6.2` | `BR-20, BR-33, BR-34` |
| `UC-055` | Add Comments on Task | `Owner`, `Manager`, `Creator`, `Client` | `3.6.3` | `BR-12, BR-20` |
| `UC-056` | List Task View | `Owner`, `Manager`, `Creator`, `Client` | `3.6.4` | `BR-20, BR-22, BR-33, BR-44` |
| `UC-057` | Calendar Task View | `Owner`, `Manager`, `Creator`, `Client` | `3.6.5` | `BR-20, BR-22, BR-33, BR-44` |
| `UC-058` | Gantt Timeline Task View | `Owner`, `Manager`, `Creator`, `Client` | `3.6.6` | `BR-20, BR-22, BR-44` |
| `UC-059` | Kanban Board Task View | `Owner`, `Manager`, `Creator`, `Client` | `3.6.7` | `BR-22, BR-33, BR-34, BR-44` |
| `UC-060` | View Task Filter | `Owner`, `Manager`, `Creator`, `Client` | `3.6.8` | `BR-20, BR-22, BR-44` |
| `UC-061` | Approval Sequence (Creator -> Manager -> Client) | `Owner`, `Manager`, `Creator`, `Client` | `3.6.9` | `BR-33, BR-34, BR-42, BR-54` |
| `UC-062` | Content Writing View | `Owner`, `Manager`, `Creator` | `3.6.10` | `BR-35, BR-46, BR-49` |
| `UC-063` | View Material Repository | `Owner`, `Manager`, `Creator`, `Client` | `3.6.11` | `BR-20, BR-36` |
| `UC-064` | Add Material Repository | `Owner`, `Manager`, `Creator`, `Client` | `3.6.12` | `BR-20, BR-36, BR-58` |
| `UC-065` | Update Material Repository | `Owner`, `Manager`, `Creator` | `3.6.13` | `BR-20, BR-36` |
| `UC-066` | Remove Material Repository | `Owner`, `Manager`, `Creator` | `3.6.14` | `BR-20, BR-36` |
| `UC-067` | Connect Google Drive Storage | `Owner`, `Manager`, `Client` | `3.6.15` | `BR-20, BR-37` |
| `UC-068` | Sync Material from Google Drive | `Owner`, `Manager`, `Client` | `3.6.16` | `BR-36, BR-37, BR-58` |
| `UC-069` | Disconnect Google Drive Storage | `Owner`, `Manager`, `Client` | `3.6.17` | `BR-20, BR-37` |
| `UC-070` | Apply Watermark | `Owner`, `Manager`, `Creator` | `3.6.18` | `BR-36, BR-38` |
| `UC-071` | Download Material | `Owner`, `Manager`, `Creator`, `Client` | `3.6.19` | `BR-20, BR-36` |
| `UC-072` | Apply Hashtag | `Owner`, `Manager`, `Creator` | `3.6.20` | `BR-35, BR-39` |
| `UC-073` | View Hashtag Collection | `Owner`, `Manager`, `Creator` | `3.6.21` | `BR-20, BR-39` |
| `UC-074` | Add Hashtag Collection | `Owner`, `Manager`, `Creator`, `Client` | `3.6.22` | `BR-20, BR-39` |
| `UC-075` | Update Hashtag Collection | `Owner`, `Manager`, `Creator` | `3.6.23` | `BR-20, BR-39` |
| `UC-076` | Remove Hashtag Collection | `Owner`, `Manager`, `Creator` | `3.6.24` | `BR-20, BR-39` |
| `UC-077` | Create Survey | `Owner`, `Manager`, `Creator` | `3.6.25` | `BR-20, BR-40` |
| `UC-078` | View Survey Analysis | `Owner`, `Manager`, `Client` | `3.6.26` | `BR-20, BR-40` |
| `UC-079` | Generate Meeting Link | `Owner`, `Manager`, `Creator` | `3.6.27` | `BR-20, BR-22, BR-40` |
| `UC-080` | View Mail Template | `Owner`, `Manager`, `Creator` | `3.6.28` | `BR-20, BR-41` |
| `UC-081` | Create Mail Template | `Owner`, `Manager`, `Creator` | `3.6.29` | `BR-20, BR-41` |
| `UC-082` | Update Mail Template | `Owner`, `Manager`, `Creator` | `3.6.30` | `BR-20, BR-41` |
| `UC-083` | Delete Mail Template | `Owner`, `Manager`, `Creator` | `3.6.31` | `BR-20, BR-41` |
| `UC-084` | Send Email via Template | `Owner`, `Manager`, `Creator` | `3.6.32` | `BR-22, BR-41` |
| `UC-085` | Check Compliance Content | `Owner`, `Manager`, `Creator` | `3.6.33` | `BR-34, BR-42, BR-54` |
| `UC-086` | View Content History | `Owner`, `Manager`, `Creator` | `3.6.34` | `BR-35, BR-60` |
| `UC-087` | Chat Realtime | `Owner`, `Manager`, `Creator`, `Client` | `3.6.35` | `BR-20, BR-43` |

---

## UC-053 — Identify Task Detail

- **Related FR:** `3.6.1` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-22, BR-33`
- **System Messages:** `MSG02, MSG03, MSG07, MSG37`
- **Specification & Flow:** Đặc tả chi tiết thông tin công việc từ Backlog (Identify Task Detail — /workspaces/:id/tasks/:taskId). Khi các công việc được đẩy tự động từ Media Campaign (3.5.8) hoặc Content Request (3.5.11) vào Backlog thì mới chỉ có tiêu đề và khung thời gian sơ bộ; tại bước này, Manager bổ sung đầy đủ Loại công việc (Post Task / Survey Task), Nền tảng đăng tải, Hạn hoàn thành (Due Date), Ngày giờ lên lịch đăng, Mức độ ưu tiên (Priority), Yêu cầu đầu ra chi tiết (Brief) và tài liệu tham khảo (BR-33).

---

## UC-054 — Assign Task to Creator

- **Related FR:** `3.6.2` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-20, BR-33, BR-34`
- **System Messages:** `MSG02, MSG03, MSG07, MSG36, MSG37`
- **Specification & Flow:** Phân công công việc cho người thực hiện và người kiểm tra (Assign Task to Creator — /workspaces/:id/tasks/:taskId). Manager gán Task cho một Creator phụ trách sản xuất nội dung chính và (tùy chọn) gán thêm người phụ trách kiểm tra chất lượng nội bộ trong cùng Workspace, đồng thời gửi thông báo thời gian thực cho người nhận việc (BR-33).

---

## UC-055 — Add Comments on Task

- **Related FR:** `3.6.3` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-12, BR-20`
- **System Messages:** `MSG02, MSG03, MSG07, MSG22, MSG37`
- **Specification & Flow:** Thêm bình luận, nhận xét và yêu cầu chỉnh sửa trực tiếp trên từng Task (Add Comments on Task — /workspaces/:id/tasks/:taskId). Hỗ trợ phản hồi theo chuỗi (threaded comments), đính kèm hình ảnh/tệp minh họa và gắn thẻ (@mention) thành viên trong Workspace để trao đổi tập trung ngay trên đầu việc (BR-20).

---

## UC-056 — List Task View

- **Related FR:** `3.6.4` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-22, BR-33, BR-44`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem và thao tác danh sách công việc dạng bảng chi tiết (List Task View — /workspaces/:id/tasks?view=list). Hiển thị đầy đủ các cột Mã Task, Tiêu đề, Trạng thái, Người thực hiện, Nền tảng, Mức độ ưu tiên, Hạn chót; hỗ trợ sắp xếp theo cột và kéo thả thay đổi thứ tự ưu tiên trong Backlog (BR-33).

---

## UC-057 — Calendar Task View

- **Related FR:** `3.6.5` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-22, BR-33, BR-44`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36, MSG37`
- **Specification & Flow:** Xem lịch công việc và lịch đăng bài trực quan theo Ngày / Tuần / Tháng giống Google Calendar (Calendar Task View — /workspaces/:id/tasks?view=calendar). Hiển thị các Task theo mốc hạn chót hoặc giờ đăng bài (đã chuẩn hóa theo Timezone của Workspace BR-22), hỗ trợ kéo thả (drag-and-drop) thẻ công việc giữa các ngày để đổi lịch nhanh.

---

## UC-058 — Gantt Timeline Task View

- **Related FR:** `3.6.6` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-22, BR-44`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem tiến độ công việc dạng biểu đồ thác nước theo trục thời gian (Gantt Timeline Task View — /workspaces/:id/tasks?view=gantt). Hiển thị thanh thời gian bắt đầu – kết thúc của từng Task trong chiến dịch, tiến độ phần trăm hoàn thành và sự phụ thuộc giữa các giai đoạn sản xuất nội dung.

---

## UC-059 — Kanban Board Task View

- **Related FR:** `3.6.7` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-22, BR-33, BR-34, BR-44`
- **System Messages:** `MSG02, MSG03, MSG07, MSG36, MSG37`
- **Specification & Flow:** Xem và kéo thả trạng thái công việc trên bảng Kanban kiểu Jira (Kanban Board Task View — /workspaces/:id/tasks?view=kanban). Hỗ trợ chuyển đổi linh hoạt theo 3 chế độ nhóm cột (Group by Status: `TODO` / `IN_PROGRESS` / `IN_REVIEW` / `FINISHED` / `CANCELLED`; Group by Assignee; Group by Platform). Hệ thống cưỡng chế nghiêm ngặt rào chắn quy trình duyệt (`BR-33`, `BR-34`): chặn tuyệt đối `Creator` (và mọi thao tác kéo-thả / đổi trạng thái hàng loạt) nhảy cóc trực tiếp sang cột `IN_REVIEW` hoặc `FINISHED` khi chưa qua quy trình nộp và phê duyệt hợp lệ; thao tác chuyển sang `CANCELLED` chỉ dành cho `Owner` và `Manager`.

---

## UC-060 — View Task Filter

- **Related FR:** `3.6.8` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-22, BR-44`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Tìm kiếm, lọc đa tiêu chí và sắp xếp dữ liệu công việc xuyên suốt cả 4 chế độ xem List, Calendar, Gantt và Kanban (View Task Filter — /workspaces/:id/tasks). Tham khảo cơ chế lọc chi tiết của Jira: hỗ trợ tìm theo từ khóa tiêu đề/mô tả và lọc kết hợp theo Trạng thái, Người phụ trách (Assignee), Chiến dịch (Campaign), Nền tảng, Mức độ ưu tiên, Nhãn (Tag) và Khoảng thời gian.

---

## UC-061 — Approval Sequence (Creator -> Manager -> Client)

- **Related FR:** `3.6.9` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-33, BR-34, BR-42, BR-54`
- **System Messages:** `MSG02, MSG07, MSG36, MSG38`
- **Specification & Flow:** Quy trình phê duyệt nội dung phân cấp nghiêm ngặt trên cả 8 loại công việc (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`) tại `/workspaces/:id/tasks/:taskId`, `/workspaces/:id/task-approvals` và các trình soạn thảo chuyên biệt:
  1. `Creator` (hoặc chủ phần `Subtask`) hoàn thiện nội dung và gửi duyệt (`Submit`), cấm `Creator` tự gán mình làm Người giám sát (`supervisorId != assigneeId`).
  2. `Owner`, `Manager` hoặc `Người giám sát` hợp lệ (`supervisorId` / `supervisorOverrideId`) kiểm duyệt cấp nội bộ (`INTERNAL_APPROVED`).
  3. Khi 100% các phần của công việc đạt duyệt nội bộ: nếu không yêu cầu khách hàng duyệt (`requiresClientApproval = false`), hệ thống **tự động chốt công việc sang `FINISHED`**; nếu yêu cầu khách hàng duyệt (`requiresClientApproval = true`), công việc chuyển sang chờ `Client` duyệt các phần đầu ra (`OUTPUT`) và **tự động chốt sang `FINISHED`** ngay khi `Client` duyệt phần cuối cùng.
  4. Nếu bất kỳ cấp nào nhấn `Reject` / `Return` (bắt buộc nhập lý do) hoặc `Owner`/`Manager` mở lại (`Reopen`) phần trên công việc chưa xuất bản, công việc quay về `IN_PROGRESS`, tự động hủy lịch đăng hẹn giờ (nếu có) và bảo toàn nguyên vẹn toàn bộ nhật ký duyệt trước đó (`BR-34`). Nút `Self-Approve` 1 chạm chỉ được mở trong chế độ `PERSONAL`.

---

## UC-062 — Content Writing View

- **Related FR:** `3.6.10` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-35, BR-46, BR-49`
- **System Messages:** `MSG02, MSG03, MSG07, MSG39`
- **Specification & Flow:** Soạn thảo nội dung bài đăng đa phương tiện tích hợp công cụ chuyển đổi phông chữ Unicode và quản lý lịch sử phiên bản (Content Writing View — /workspaces/:id/tasks/:taskId/editor). Giải quyết nỗi đau của người làm nội dung mạng xã hội bằng cách tích hợp bộ chuyển đổi kiểu chữ Unicode trực tiếp trong trình soạn thảo (in đậm, in nghiêng, chữ nghệ thuật tương tự YayText để dán/đăng trực tiếp lên Facebook, TikTok, Instagram, Threads mà không bị mất định dạng), đồng thời tự động lưu lịch sử phiên bản (Version History) ghi nhận ai chỉnh sửa phần nào và cho phép khôi phục (Restore) về phiên bản trước đó bất kỳ lúc nào (BR-35).

---

## UC-063 — View Material Repository

- **Related FR:** `3.6.11` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-36`
- **System Messages:** `MSG01, MSG07, MSG41`
- **Specification & Flow:** Xem kho lưu trữ tư liệu sáng tạo của Workspace (View Material Repository — /workspaces/:id/library). Phân loại rõ ràng các nhóm tư liệu: (1) Ảnh/Video gốc chưa qua chỉnh sửa (RAW) kèm nhãn cảnh báo không được đăng trực tiếp (BR-36), (2) Ấn phẩm đã hậu kỳ hoàn chỉnh (Retouched/Final), và (3) Tài liệu nhận diện thương hiệu tham khảo do Client tải lên (Brand Assets for Reference). Hỗ trợ tìm kiếm và lọc theo phân loại, định dạng, người tải lên.

---

## UC-064 — Add Material Repository

- **Related FR:** `3.6.12` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-36, BR-58`
- **System Messages:** `MSG02, MSG07, MSG22, MSG40, MSG48`
- **Specification & Flow:** Tải lên tư liệu hình ảnh, video hoặc tài liệu thương hiệu mới vào kho của Workspace (Add Material Repository — /workspaces/:id/library). Người dùng chọn tệp từ máy tính, gắn phân loại bắt buộc (RAW, Retouched hoặc Brand Reference Asset), nhập tiêu đề, thẻ phân loại (tags) và ghi chú sử dụng. Hệ thống kiểm tra định dạng/dung lượng tệp hợp lệ và lưu trữ an toàn trên kho đối tượng S3 (BR-36).

---

## UC-065 — Update Material Repository

- **Related FR:** `3.6.13` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-36`
- **System Messages:** `MSG02, MSG03, MSG07, MSG40`
- **Specification & Flow:** Cập nhật thông tin siêu dữ liệu và trạng thái xử lý của tư liệu trong kho (Update Material Repository — /workspaces/:id/library/:materialId). Cho phép đổi tên tư liệu, cập nhật mô tả/nhãn tìm kiếm, tải lên tệp phiên bản mới đã qua chỉnh sửa và chuyển trạng thái phân loại từ RAW sang Retouched để gỡ bỏ cảnh báo hạn chế đăng bài (BR-36).

---

## UC-066 — Remove Material Repository

- **Related FR:** `3.6.14` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-36`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36, MSG40`
- **Specification & Flow:** Xóa mềm tư liệu khỏi kho lưu trữ của Workspace (Remove Material Repository — /workspaces/:id/library/:materialId). Thực hiện xóa mềm (Soft Delete) để ẩn tư liệu khỏi danh sách chọn mới nhưng không làm mất liên kết hình ảnh/video trong các bài viết hoặc lịch sử công việc đã sử dụng tư liệu đó trước đây (BR-36).

---

## UC-067 — Connect Google Drive Storage

- **Related FR:** `3.6.15` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-20, BR-37`
- **System Messages:** `MSG02, MSG03, MSG07, MSG13, MSG42`
- **Specification & Flow:** Liên kết tài khoản Google Drive với Workspace thông qua giao thức OAuth 2.0 (Connect Google Drive Storage — /workspaces/:id/library/drive). Cho phép Client hoặc Agency kết nối thư mục Google Drive dùng chung để đồng bộ trực tiếp kho ảnh chụp/video dung lượng lớn vào Workspace; hệ thống mã hóa AES-256 và lưu trữ an toàn OAuth Refresh Token (BR-37).

---

## UC-068 — Sync Material from Google Drive

- **Related FR:** `3.6.16` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-36, BR-37, BR-58`
- **System Messages:** `MSG07, MSG22, MSG36, MSG42, MSG48`
- **Specification & Flow:** Đồng bộ và nhập các tệp hình ảnh/video từ thư mục Google Drive đã kết nối vào Material Repository của Workspace (Sync Material from Google Drive — /workspaces/:id/library/drive). Hệ thống kiểm tra phiên kết nối Google Drive hợp lệ, đối chiếu mã định danh tệp để tránh nhập trùng lặp và tự động gắn phân loại tư liệu tương ứng trong kho (BR-36, BR-37).

---

## UC-069 — Disconnect Google Drive Storage

- **Related FR:** `3.6.17` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-20, BR-37`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG42`
- **Specification & Flow:** Ngắt kết nối tài khoản Google Drive khỏi Workspace (Disconnect Google Drive Storage — /workspaces/:id/library/drive). Hệ thống thu hồi OAuth token đã lưu và dừng đồng bộ tự động, nhưng vẫn bảo toàn nguyên vẹn toàn bộ các tư liệu đã được đồng bộ vào Material Repository trước thời điểm ngắt kết nối (BR-37, BR-37).

---

## UC-070 — Apply Watermark

- **Related FR:** `3.6.18` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-36, BR-38`
- **System Messages:** `MSG02, MSG07, MSG22, MSG40, MSG41`
- **Specification & Flow:** Đóng dấu bản quyền thương hiệu lên hình ảnh/ấn phẩm (Apply Watermark — /workspaces/:id/library/:materialId/watermark). Hoạt động tương tự công cụ đóng dấu ảnh chuyên nghiệp (như Img2Go Watermark): sau khi ảnh đã qua chỉnh sửa, Creator chọn logo thương hiệu do Client cung cấp hoặc nhập chữ bản quyền, tùy chỉnh vị trí (9 góc/tâm), tỷ lệ kích thước, góc xoay và độ mờ (opacity 10%–100%). Hệ thống xuất ra bản ảnh mới đã gắn watermark trong kho mà vẫn giữ nguyên tệp ảnh gốc không đóng dấu (BR-38).

---

## UC-071 — Download Material

- **Related FR:** `3.6.19` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-36`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Tải tệp tư liệu từ Material Repository của Workspace về máy tính cá nhân (Download Material — /workspaces/:id/library/:materialId). Hệ thống kiểm tra quyền truy cập thành viên trong Workspace và cấp liên kết tải xuống trực tiếp tốc độ cao từ kho lưu trữ để phục vụ chỉnh sửa hậu kỳ hoặc lưu trữ cục bộ (BR-20).

---

## UC-072 — Apply Hashtag

- **Related FR:** `3.6.20` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-35, BR-39`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG43`
- **Specification & Flow:** Chọn và chèn nhanh một hoặc nhiều thẻ Hashtag từ bộ sưu tập của Workspace vào nội dung bài đăng đang soạn thảo (Apply Hashtag — /workspaces/:id/tasks/:taskId/editor). Tự động chuẩn hóa định dạng tiền tố '#', loại bỏ các hashtag bị trùng lặp trong cùng bài viết và kiểm tra giới hạn số lượng hashtag theo quy định của từng mạng xã hội (BR-39).

---

## UC-073 — View Hashtag Collection

- **Related FR:** `3.6.21` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-39`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem danh sách các bộ sưu tập Hashtag dành riêng cho Workspace (View Hashtag Collection — /workspaces/:id/hashtags). Hiển thị các nhóm hashtag do Creator tự tổng hợp, bộ hashtag bắt buộc mang tính đặc thù chiến dịch do Client quy định, cùng các hashtag xu hướng do AI gợi ý; hỗ trợ lọc theo mục đích/chiến dịch và tìm kiếm từ khóa (BR-39).

---

## UC-074 — Add Hashtag Collection

- **Related FR:** `3.6.22` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-39`
- **System Messages:** `MSG02, MSG03, MSG07, MSG43`
- **Specification & Flow:** Tạo mới bộ sưu tập Hashtag hoặc thêm các thẻ hashtag vào kho của Workspace (Add Hashtag Collection — /workspaces/:id/hashtags). Cho phép nhập một hoặc nhiều hashtag cùng lúc và bắt buộc phân loại rõ mục đích sử dụng (Brand Core, Campaign Event, Seasonal Trend, Mandatory Client Tag) để đội ngũ sáng tạo áp dụng thống nhất (BR-39).

---

## UC-075 — Update Hashtag Collection

- **Related FR:** `3.6.23` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-39`
- **System Messages:** `MSG02, MSG03, MSG07, MSG43`
- **Specification & Flow:** Cập nhật tên bộ sưu tập, mục đích phân loại và danh sách các thẻ hashtag bên trong bộ sưu tập của Workspace (Update Hashtag Collection — /workspaces/:id/hashtags/:collectionId). Hệ thống tự động chuẩn hóa các thẻ hashtag mới cập nhật và kiểm tra không trùng tên bộ sưu tập trong cùng Workspace (BR-39).

---

## UC-076 — Remove Hashtag Collection

- **Related FR:** `3.6.24` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-39`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36, MSG43`
- **Specification & Flow:** Xóa mềm bộ sưu tập Hashtag khỏi danh sách hoạt động của Workspace (Remove Hashtag Collection — /workspaces/:id/hashtags/:collectionId). Áp dụng cơ chế xóa mềm (Soft Delete): ẩn bộ sưu tập khỏi danh sách chọn mới nhưng giữ nguyên toàn bộ các hashtag đã được chèn vào các bài viết trước đó (BR-39).

---

## UC-077 — Create Survey

- **Related FR:** `3.6.25` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-40`
- **System Messages:** `MSG02, MSG03, MSG07, MSG44`
- **Specification & Flow:** Tạo biểu mẫu khảo sát tương tác phục vụ sự kiện, workshop hoặc thu thập ý kiến khách hàng trong chiến dịch (Create Survey — /workspaces/:id/surveys/new). Hỗ trợ thiết kế tiêu đề khảo sát, mô tả, thời hạn đóng biểu mẫu và danh sách câu hỏi đa dạng (Trắc nghiệm 1 lựa chọn, Nhiều lựa chọn, Thang điểm đánh giá, Câu trả lời văn bản tự do) kèm đường dẫn công khai để chia sẻ (BR-40).

---

## UC-078 — View Survey Analysis

- **Related FR:** `3.6.26` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-20, BR-40`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem báo cáo thống kê và phân tích kết quả phản hồi của biểu mẫu khảo sát (View Survey Analysis — /workspaces/:id/surveys/:surveyId/analytics). Hiển thị tổng số lượt phản hồi, tỷ lệ hoàn thành, biểu đồ phân bổ câu trả lời cho từng câu hỏi trắc nghiệm và danh sách chi tiết các ý kiến đóng góp để đánh giá hiệu quả sự kiện/workshop (BR-40).

---

## UC-079 — Generate Meeting Link

- **Related FR:** `3.6.27` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-22, BR-40`
- **System Messages:** `MSG02, MSG03, MSG07, MSG44`
- **Specification & Flow:** Tự động khởi tạo đường dẫn phòng họp trực tuyến (Google Meet / Jitsi Meeting Link) ngay trong Workspace hoặc trên Task (Generate Meeting Link — /workspaces/:id/meetings). Giúp đội ngũ Agency và Client mở nhanh cuộc họp trao đổi kịch bản, duyệt ấn phẩm và tự động gửi thông báo kèm link họp cho các thành viên tham gia (BR-40).

---

## UC-080 — View Mail Template

- **Related FR:** `3.6.28` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-41`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem danh sách và nội dung chi tiết các mẫu Email thông báo trong Workspace (View Mail Template — /workspaces/:id/mail-templates). Hiển thị cả các mẫu email mặc định của hệ thống và các mẫu tùy chỉnh của Workspace (mời họp, gửi báo cáo chiến dịch, thông báo duyệt bài) kèm danh sách các biến động ({{client_name}}, {{campaign_name}}, {{task_title}}) (BR-41).

---

## UC-081 — Create Mail Template

- **Related FR:** `3.6.29` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-41`
- **System Messages:** `MSG02, MSG03, MSG07, MSG44`
- **Specification & Flow:** Tạo mới mẫu Email thông báo cho Workspace hoặc nhân bản từ mẫu có sẵn (Create Mail Template — /workspaces/:id/mail-templates/new). Cho phép thiết lập Tên mẫu, Tiêu đề Email (Subject), Nội dung định dạng HTML/Rich-text và chèn các biến giữ chỗ (placeholder variables) để tái sử dụng khi gửi email tự động hoặc thủ công (BR-41).

---

## UC-082 — Update Mail Template

- **Related FR:** `3.6.30` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-41`
- **System Messages:** `MSG02, MSG03, MSG07, MSG44`
- **Specification & Flow:** Chỉnh sửa tiêu đề, nội dung HTML và danh sách biến động của mẫu Email đã tạo trong Workspace (Update Mail Template — /workspaces/:id/mail-templates/:templateId). Hệ thống kiểm tra cú pháp các thẻ biến {{variable}} hợp lệ trước khi lưu phiên bản mới (BR-41).

---

## UC-083 — Delete Mail Template

- **Related FR:** `3.6.31` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-41`
- **System Messages:** `MSG02, MSG03, MSG07, MSG36, MSG44`
- **Specification & Flow:** Xóa mẫu Email tùy chỉnh khỏi thư viện mẫu của Workspace (Delete Mail Template — /workspaces/:id/mail-templates/:templateId). Không cho phép xóa các mẫu email hệ thống mặc định bắt buộc; việc xóa mẫu tùy chỉnh không ảnh hưởng đến nhật ký các email đã gửi trước đó (BR-41).

---

## UC-084 — Send Email via Template

- **Related FR:** `3.6.32` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-22, BR-41`
- **System Messages:** `MSG02, MSG04, MSG07, MSG44, MSG48`
- **Specification & Flow:** Gửi email đến Client hoặc thành viên dự án thông qua mẫu Email đã chọn (Send Email via Template — /workspaces/:id/mail-templates/:templateId/send). Hệ thống tự động điền giá trị thực tế vào các biến giữ chỗ ({{client_name}}, {{campaign_name}}...), đẩy tác vụ gửi mail vào hàng đợi bất đồng bộ qua SMTP/SendGrid và lưu vết vào lịch sử gửi email của Workspace (BR-41).

---

## UC-085 — Check Compliance Content

- **Related FR:** `3.6.33` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-34, BR-42, BR-54`
- **System Messages:** `MSG02, MSG07, MSG37, MSG45`
- **Specification & Flow:** Kiểm tra mức độ tuân thủ tiêu chuẩn cộng đồng của nội dung bài đăng trước khi xuất bản (Check Compliance Content — /workspaces/:id/tasks/:taskId/compliance). Gọi API kiểm duyệt an toàn nội dung để rà soát ngôn từ bạo lực, nhạy cảm, từ khóa bị cấm trên các nền tảng mạng xã hội và hình ảnh dung tục; trả về bảng phân tích chi tiết các đoạn vi phạm kèm gợi ý chỉnh sửa giúp Creator khắc phục ngay để bài viết không bị bóp tương tác hoặc từ chối đăng (BR-42).

---

## UC-086 — View Content History

- **Related FR:** `3.6.34` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-35, BR-60`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG39`
- **Specification & Flow:** Xem lịch sử các phiên bản nội dung và tài nguyên AI đã khởi tạo trước đó của Task/Workspace (View Content History — /workspaces/:id/tasks/:taskId/history). Cho phép người dùng tra cứu, xem lại và tái sử dụng các đoạn caption, hình ảnh, video đã được tạo trước đó mà hoàn toàn không bị trừ lại AI Credit (BR-35, BR-35).

---

## UC-087 — Chat Realtime

- **Related FR:** `3.6.35` (3.6 Content & Workflow)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-43`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Nhắn tin trao đổi trực tuyến thời gian thực giữa các thành viên trong từng kênh Workspace (Chat Realtime — /workspaces/:id/chat). Sử dụng kết nối WebSocket (STOMP) để gửi/nhận tin nhắn văn bản, tệp đính kèm, trạng thái đã xem và lịch sử trò chuyện được cô lập bảo mật tuyệt đối theo từng Workspace (BR-20, BR-43).

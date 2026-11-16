# 05 — Quản trị Công việc, Nội dung Đa định dạng, Tư liệu & Cộng tác (Content & Task Workflow)

> [<< 04 - Media Package & Campaign](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/04-media-package-campaign.md) | [Overview](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/00-overview.md) | [Tiếp: 06 - AI Features >>](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/06-ai-features.md)
>
> **Phạm vi FR chuẩn**: **Mục `3.6 Content & Workflow` — 35 FR (`3.6.1` – `3.6.35`)** | `UC-053` – `UC-087`.
> Tích hợp đầy đủ kiến trúc **8 loại Task & Subtask theo vai trò (`subtask-role-workspaces`)**, **Tạo Task Độc lập & Tự duyệt 1 chạm (`personal-workspace-mode`)**, **Trình xem 3 chế độ Notion Peek (`Side Peek | Center Modal | Full Page`)**, **Google Drive Sync**, **Newsletter gửi thật**, và **Workspace Chat đa năng**.

---

## 1. Bảng Tổng hợp 35 Yêu cầu Chức năng Chuẩn (`3.6.1` – `3.6.35`)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (Atomic CRUD FR) | Actors / Roles Chuẩn | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :--- |
| **`3.6.1`** | `UC-053` | **View Post List** | `Owner`, `Manager`, `Creator`, `Client` | Xem danh sách Công việc & Bài viết trong Workspace theo 4 dạng hiển thị (*Danh sách, Lịch, Bảng trạng thái Kanban, Dòng thời gian*) và lọc theo 8 loại `TaskType`. |
| **`3.6.2`** | `UC-054` | **View Post Detail** | `Owner`, `Manager`, `Creator`, `Client` | Xem chi tiết Công việc, các phần nội dung (`TaskSection`), Subtask con và bình luận với **3 chế độ mở (`Side Peek`, `Center Modal`, `Full Page`)**. |
| **`3.6.3`** | `UC-055` | **Create Post** | `Creator`, `Manager` | Tạo mới nội dung bài viết hoặc tạo trực tiếp Công việc độc lập (`Standalone Task` cho cả 8 loại `TaskType`). |
| **`3.6.4`** | `UC-056` | **Update Post** | `Creator`, `Manager` | Soạn thảo và lưu nội dung theo từng phần (`TaskSection`: Caption, Media, Kịch bản, Agenda, Thông cáo, KOL, Workshop, Newsletter) kèm kiểm soát chống ghi đè (`expectedRevision`). |
| **`3.6.5`** | `UC-057` | **Delete Post** | `Manager`, `Owner` | Xóa hoặc hủy (`CANCELLED`) một công việc/bài viết nháp chưa xuất bản. |
| **`3.6.6`** | `UC-058` | **Submit Post for Approval** | `Creator` | Nộp duyệt từng phần chuyên môn (`POST /sections/{key}/submit`) hoặc nộp toàn bộ công việc cha (`POST /tasks/{id}/submit`) sau khi các phần đã đạt điều kiện. |
| **`3.6.7`** | `UC-059` | **Approve Post** | `Manager`, `Client` | Duyệt từng phần (`INTERNAL_APPROVED` bởi `Manager`/`Supervisor`; `CLIENT_APPROVED` bởi `Client` cho các phần đầu ra `O`), hoặc **Tự duyệt 1 chạm (`Self-Approve`)** trong chế độ `PERSONAL`. |
| **`3.6.8`** | `UC-060` | **Reject Post** | `Manager`, `Client` | Trả lại (`Return` / `Reject`) một phần hoặc công việc kèm ghi chú bắt buộc (`returnNote`); tự động mở khóa phần đó cho chủ phần sửa lại và hủy lịch đăng nếu đã đặt lịch. |
| **`3.6.9`** | `UC-061` | **Approval Sequence** | `Manager`, `Client` | Thực thi chuỗi phê duyệt chuẩn (`DRAFT → SUBMITTED → INTERNAL_APPROVED → CLIENT_APPROVED`) hoặc chuỗi rút gọn 1 chạm khi `requiresClientApproval = false`. |
| **`3.6.10`** | `UC-062` | **View Content Calendar** | `Owner`, `Manager`, `Creator`, `Client` | Xem Lịch Nội dung (`Calendar View` theo Tháng/Tuần/Ngày) hiển thị hạn hoàn thành công việc và lịch xuất bản bài đăng trên 4 nền tảng MXH. |
| **`3.6.11`** | `UC-063` | **View Material Library** | `Owner`, `Manager`, `Creator`, `Client` | Duyệt kho Thư viện Tư liệu số (`Material Library`) theo cấu trúc cây thư mục, lọc theo loại tệp (Ảnh, Video, Tài liệu, Âm thanh) và quyền chia sẻ với `Client`. |
| **`3.6.12`** | `UC-064` | **Upload Material** | `Owner`, `Manager`, `Creator`, `Client` | Tải tệp tư liệu lên kho lưu trữ đám mây của Workspace (kiểm tra định dạng MIME, dung lượng và quét an toàn). |
| **`3.6.13`** | `UC-065` | **Update Material** | `Owner`, `Manager`, `Creator` | Đổi tên tệp/thư mục, di chuyển thư mục, gắn thẻ (`tags`), mô tả và bật/tắt quyền chia sẻ thư mục cho `Client` (`clientVisible`). |
| **`3.6.14`** | `UC-066` | **Delete Material** | `Owner`, `Manager` | Xóa tệp hoặc thư mục tư liệu khỏi Thư viện của Workspace. |
| **`3.6.15`** | `UC-067` | **Connect Google Drive** | `Owner`, `Manager` | Kết nối tài khoản Google Drive với Workspace qua OAuth 2.0 để đồng bộ tư liệu đám mây. |
| **`3.6.16`** | `UC-068` | **Sync Google Drive Folder** | `Owner`, `Manager` | Chọn thư mục Google Drive và đồng bộ hai chiều/một chiều các tệp tư liệu về `Material Library` của Workspace. |
| **`3.6.17`** | `UC-069` | **Disconnect Google Drive** | `Owner`, `Manager` | Ngắt kết nối tích hợp Google Drive khỏi Workspace (giữ lại các tư liệu đã nhập về kho). |
| **`3.6.18`** | `UC-070` | **Apply Watermark** | `Manager`, `Creator` | Đóng dấu bản quyền/thương hiệu (`Watermark` bằng logo hoặc chữ, tùy chỉnh vị trí, độ mờ, kích thước) lên hình ảnh trong trình soạn thảo và thư viện. |
| **`3.6.19`** | `UC-071` | **Download Material** | `Owner`, `Manager`, `Creator`, `Client` | Tải tệp tư liệu gốc hoặc bản xuất PDF/DOCX của công việc về thiết bị cá nhân. |
| **`3.6.20`** | `UC-072` | **Create Hashtag Collection** | `Manager`, `Creator` | Tạo bộ sưu tập Hashtag theo chủ đề/chiến dịch trong Workspace. |
| **`3.6.21`** | `UC-073` | **View Hashtag Collection** | `Owner`, `Manager`, `Creator`, `Client` | Xem danh sách các bộ sưu tập Hashtag đã lưu cùng thống kê tần suất sử dụng. |
| **`3.6.22`** | `UC-074` | **Update Hashtag Collection** | `Manager`, `Creator` | Thêm/bớt hashtag hoặc đổi tên bộ sưu tập Hashtag. |
| **`3.6.23`** | `UC-075` | **Delete Hashtag Collection** | `Manager`, `Creator` | Xóa bộ sưu tập Hashtag không còn sử dụng. |
| **`3.6.24`** | `UC-076` | **Apply Hashtags to Post** | `Manager`, `Creator` | Chèn nhanh một bộ sưu tập Hashtag (hoặc hashtag gợi ý theo ngữ cảnh AI) vào phần `POST.CAPTION` / `VIDEO.CAPTION` của bài đăng. |
| **`3.6.25`** | `UC-077` | **Create Survey Form** | `Manager`, `Creator` | Thiết kế biểu mẫu khảo sát trực tuyến (`SURVEY.FORM` hoặc `WORKSHOP.REGISTRATION` với các loại câu hỏi trắc nghiệm, tự luận, thang điểm) và phát hành link công khai `/public/surveys/:token`. |
| **`3.6.26`** | `UC-078` | **View Survey Responses** | `Owner`, `Manager`, `Creator`, `Client` | Xem danh sách câu trả lời khảo sát thu thập được, biểu đồ thống kê tự động và báo cáo phân tích (`SURVEY.REPORT`). |
| **`3.6.27`** | `UC-079` | **Create Online Meeting Link** | `Manager`, `Creator` | Tạo phòng họp/hội thảo trực tuyến (`meetingUrl` cho công việc `EVENT_PLAN`, `WORKSHOP` hoặc cuộc gọi trong Workspace). |
| **`3.6.28`** | `UC-080` | **Create Mail Template** | `Owner`, `Manager`, `Creator` | Tạo mẫu email chuyên nghiệp bằng trình dựng khối trực quan (`BlockBuilder` — tiêu đề, đoạn văn, ảnh, nút CTA, cột, chân trang) ở cấp Agency hoặc Workspace. |
| **`3.6.29`** | `UC-081` | **View Mail Templates** | `Owner`, `Manager`, `Creator` | Xem danh sách mẫu email, bản xem trước (`MailPreview`) trên Desktop/Mobile và lịch sử các đợt gửi (`MailBatch`). |
| **`3.6.30`** | `UC-082` | **Update Mail Template** | `Owner`, `Manager`, `Creator` | Chỉnh sửa bố cục, nội dung, biến cá nhân hóa (`{{name}}`, `{{company}}`) của mẫu email. |
| **`3.6.31`** | `UC-083` | **Delete Mail Template** | `Owner`, `Manager` | Xóa mẫu email khỏi kho mẫu. |
| **`3.6.32`** | `UC-084` | **Send Mail from Template** | `Owner`, `Manager` | Gửi email hàng loạt từ mẫu hoặc gửi bản tin `EMAIL_NEWSLETTER` tới nhóm người nhận đã đồng ý (`consent = true`), hỗ trợ gửi thử (`send-test`), lên lịch gửi, tự động chèn link hủy đăng ký (`unsubscribe`) và theo dõi báo cáo gửi. |
| **`3.6.33`** | `UC-085` | **Check Compliance Content** | `Owner`, `Manager`, `Creator` | Kiểm tra tự động nội dung bài viết đối với các quy chuẩn an toàn cộng đồng, từ ngữ nhạy cảm/cấm hoặc bạo lực trước khi nộp duyệt/xuất bản. |
| **`3.6.34`** | `UC-086` | **View Content History** | `Owner`, `Manager`, `Creator`, `Client` | Xem lịch sử phiên bản của từng phần (`TaskSectionVersion`: chụp snapshot mỗi lần nộp, so sánh diff từng dòng giữa 2 phiên bản, khôi phục bản cũ) và nhật ký sự kiện (`TaskSectionEvent`). |
| **`3.6.35`** | `UC-087` | **Chat Realtime** | `Owner`, `Manager`, `Creator`, `Client` | Nhắn tin cộng tác thời gian thực trong Workspace qua WebSocket: hỗ trợ kênh hội thoại, trả lời theo luồng (`Thread`), soạn thảo giàu định dạng (`Rich Composer`), đính kèm tệp, nhắc tên `@mention`, hẹn giờ gửi tin nhắn và gọi thoại (`Voice Call`). |

---

## 2. Danh mục 8 Loại Công việc (`TaskType`), Subtask theo Vai trò & Trình soạn Chia phần (`TaskCatalog`)

Mỗi `TaskDocument` thuộc **1 trong 8 loại `TaskType` chuẩn**. Mỗi loại có một danh mục vai trò (`subtaskRole`) cố định trong `TaskCatalog.java`, trong đó mỗi vai trò sở hữu một hoặc nhiều **phần nội dung (`TaskSection`)**.
- **Hiển thị `O` (Output)**: Phần sản phẩm đầu ra — `Client` được xem, nhận thông báo duyệt (`CLIENT_APPROVED`) và được đưa vào file xuất PDF/DOCX.
- **Hiển thị `I` (Internal)**: Phần nghiệp vụ nội bộ (brief phỏng vấn, chi phí hậu cần, giá deal KOL, nhật ký liên hệ nhà báo) — **ẩn hoàn toàn đối với `Client`** và không bao giờ in ra file xuất.

| Loại Công việc (`TaskType`) | Các Vai trò Subtask (`subtaskRole`) | Các Phần Soạn thảo (`sectionKey`) & Phân loại (`O` / `I`) | Định dạng Xuất File (`GET /tasks/:id/export`) |
| :--- | :--- | :--- | :-: |
| **1. `POST`** *(Bài đăng MXH)* | `POST_RESEARCH`, `POST_CONTENT`, `POST_MEDIA`, `POST_EDITING`, `POST_PUBLISHING` | • `POST.BRIEF` (**I**)<br>• `POST.CAPTION` (**O** — Luật chồng phần: `POST_EDITING` sửa sau khi `POST_CONTENT` đã nộp)<br>• `POST.MEDIA` (**O**)<br>• `POST.CHANNELS` (**O** — FB, IG, TikTok, Threads) | **PDF** |
| **2. `SHORT_VIDEO`** *(Video ngắn)* | `VIDEO_SCRIPT`, `VIDEO_SHOOT`, `VIDEO_EDIT`, `VIDEO_PUBLISH` | • `VIDEO.SCRIPT` (**O** — Kịch bản phân cảnh)<br>• `VIDEO.SHOOT` (**I** — Quay)<br>• `VIDEO.EDIT` (**O** — Media video hậu kỳ)<br>• `VIDEO.CAPTION` (**O**)<br>• `VIDEO.CHANNELS` (**O** — TikTok, IG Reels, FB Reels) | **PDF** |
| **3. `SURVEY`** *(Khảo sát)* | `SURVEY_DESIGN`, `SURVEY_DISTRIBUTE`, `SURVEY_ANALYSIS` | • `SURVEY.FORM` (**O** — Bảng hỏi)<br>• `SURVEY.DISTRIBUTION` (**O** — Link `/public/surveys/:token`, hạn đóng, chỉ tiêu)<br>• `SURVEY.REPORT` (**O** — Kết luận & số liệu phân tích) | **PDF** |
| **4. `EVENT_PLAN`** *(Kế hoạch sự kiện)* | `EVENT_AGENDA`, `EVENT_LOGISTICS`, `EVENT_PROMOTION`, `EVENT_ONSITE`, `EVENT_REPORT` | • `EVENT.AGENDA` (**O** — Concept & Khung chương trình)<br>• `EVENT.LOGISTICS` (**I** — Địa điểm, nhà cung cấp, chi phí VND)<br>• `EVENT.PROMOTION` (**O** — Truyền thông & Danh sách khách mời)<br>• `EVENT.RUNSHEET` (**I** — Run-sheet điều phối tại chỗ)<br>• `EVENT.REPORT` (**O** — Kết quả & hình ảnh sau sự kiện) | **PDF** |
| **5. `PRESS_RECOMMENDATION`** *(Thông cáo báo chí)* | `PRESS_MEDIA_LIST`, `PRESS_RELEASE`, `PRESS_PITCHING`, `PRESS_TRACKING` | • `PRESS.MEDIA_LIST` (**I** — Danh sách đầu báo & nhà báo)<br>• `PRESS.RELEASE` (**O** — Tiêu đề, Sapo, Nội dung thông cáo)<br>• `PRESS.CONTACT_LOG` (**I** — Nhật ký liên hệ báo chí)<br>• `PRESS.COVERAGE` (**O** — Danh sách link bài báo đã đăng) | **DOCX** (`poi-ooxml`) |
| **6. `KOL_BOOKING`** *(Quản lý KOL)* | `KOL_SOURCING`, `KOL_NEGOTIATION`, `KOL_BRIEF`, `KOL_CONTENT_REVIEW`, `KOL_TRACKING` | • `KOL.SHORTLIST` (**O** — Danh sách đề xuất KOL)<br>• `KOL.DEAL` (**I** — Giá thỏa thuận VND & điều khoản)<br>• `KOL.BRIEF` (**O** — Thông điệp, Do/Don't, Hashtag)<br>• `KOL.DRAFT` (**O** — Bản nháp KOL gửi)<br>• `KOL.REPORT` (**O** — Link bài đăng & chỉ số tương tác) | **PDF** |
| **7. `WORKSHOP`** *(Hội thảo / Workshop)* | `WORKSHOP_PROGRAM`, `WORKSHOP_SPEAKER`, `WORKSHOP_LOGISTICS`, `WORKSHOP_REGISTRATION`, `WORKSHOP_REPORT` | • `WORKSHOP.PROGRAM` (**O** — Chủ đề, Agenda, Tài liệu)<br>• `WORKSHOP.SPEAKERS` (**O** — Danh sách diễn giả)<br>• `WORKSHOP.LOGISTICS` (**I** — Địa điểm / Link phòng họp online, chi phí)<br>• `WORKSHOP.REGISTRATION` (**O** — Form đăng ký tích hợp Survey Builder)<br>• `WORKSHOP.REPORT` (**O** — Tổng kết số người tham dự & feedback) | **PDF** |
| **8. `EMAIL_NEWSLETTER`** *(Bản tin Email)* | `EMAIL_CONTENT`, `EMAIL_DESIGN`, `EMAIL_SEND`, `EMAIL_REPORT` | • `EMAIL.CONTENT` (**O** — Subject, Preheader, Nội dung khối)<br>• `EMAIL.DESIGN` (**O** — Bố cục & nhận diện thương hiệu)<br>• `EMAIL.AUDIENCE` (**O** — Nhóm người nhận có `consent`, lịch gửi)<br>• `EMAIL.REPORT` (**O** — Thống kê gửi thật: Đã gửi, Thành công, Lỗi, Hủy đăng ký) | **PDF** |

---

## 3. Quy trình Phê duyệt 2 Cấp (`AGENCY`) vs. Tự duyệt 1 Chạm (`PERSONAL`)

### 3.1. Vòng đời Phần Soạn thảo (`TaskSection`) trong Chế độ `AGENCY`
1. **`DRAFT` / `RETURNED`**: Chủ phần (người nhận Subtask có `subtaskRole` tương ứng) hoặc Điều phối viên (`assigneeId` của Task cha) chỉnh sửa nội dung. Mỗi lần lưu kiểm tra CAS theo `expectedRevision` của riêng phần đó để nhiều người làm các phần khác nhau cùng lúc không chặn nhau.
2. **`SUBMITTED`**: Chủ phần bấm **Nộp phần (`Submit`)** → hệ thống chụp ngay 1 bản `TaskSectionVersion` (`versionNo` tăng dần), khóa quyền sửa của chủ phần và gửi thông báo cho `Supervisor` / `Manager`.
3. **`INTERNAL_APPROVED`**: `Manager` hoặc `Supervisor` bấm **Duyệt nội bộ (`Approve`)**:
   - Với phần nội bộ (**I**): `INTERNAL_APPROVED` là trạng thái hoàn tất cuối cùng (`finalState = true`).
   - Với phần đầu ra (**O**) khi `requiresClientApproval = true`: hệ thống đặt mốc `clientPendingSince = now()` và gửi thông báo + email mời `Client` vào duyệt (nếu quá 48h chưa duyệt, `SectionReminderJob` gửi email nhắc tự động, không tự duyệt thay `Client`).
4. **`CLIENT_APPROVED`**: `Client` vào `Client Portal` bấm **Duyệt phần (`Approve`)**:
   - Khi một Subtask có mọi phần thuộc quyền sở hữu của nó đạt trạng thái cuối (`finalState = true`), Subtask đó **tự động chuyển sang `FINISHED`**.
   - Khi toàn bộ các phần của Task đều đạt trạng thái cuối, Task cha tự động chuyển sang **`FINISHED` (`lastSubmission.outcome = APPROVED`)**, mở khóa tính năng Xuất bản MXH hoặc Gửi Newsletter.
5. **Trả lại (`Return`) & Hủy lịch tự động**:
   - Nếu `Manager` hoặc `Client` trả lại một phần (bắt buộc nhập `note`), phần đó quay về `RETURNED`, mở khóa cho chủ phần sửa lại.
   - Nếu `Client` trả lại một phần sau khi Task đã lên lịch đăng bài (`POST`/`SHORT_VIDEO`) hoặc lên lịch gửi `EMAIL_NEWSLETTER`, hệ thống tự động đưa Task về `IN_PROGRESS` và hủy lịch đăng (`PostService.cancelTaskSchedule` / `MailBatchService.cancelForTask`) để đảm bảo không bao giờ phát hành nội dung mà `Client` đã từ chối.

### 3.2. Luồng Tạo Việc Nhanh & Tự Duyệt 1 Chạm (`Self-Approve`) trong Chế độ `PERSONAL`
Trong Workspace có `workspaceMode = "PERSONAL"` (hoặc trên các Task có `requiresClientApproval = false`):
- **Tạo Công việc Độc lập (`POST /api/v1/workspaces/{id}/tasks/standalone`)**:
  - Người dùng bấm **"+ Tạo công việc mới"**, chọn 1 trong 8 loại `TaskType` và vào thẳng trình soạn thảo mà không cần qua `MediaPackage` hay `ContentRequest`.
- **Tự duyệt 1 chạm (`POST /api/v1/workspaces/{id}/tasks/{taskId}/self-approve`)**:
  - Chủ không gian (`Owner`/`Manager`) bấm nút **"Hoàn tất & Duyệt ngay"**.
  - Hệ thống chuyển nguyên tử toàn bộ các phần (`TaskSection`) sang `INTERNAL_APPROVED` (`finalState = true`), toàn bộ `Subtask` sang `FINISHED` và đóng `Task` ở trạng thái `FINISHED` (`APPROVED`), mở khóa ngay nút **Đăng bài / Lên lịch / Gửi bản tin / Xuất file PDF-DOCX chính thức**.

---

## 4. Trải nghiệm Mở Chi tiết 3 Chế độ Notion Peek (`Side Peek | Center Modal | Full Page`)

Trên toàn bộ các danh sách Công việc (`/workspaces/:id/tasks`), Subtask và bảng dữ liệu trong hệ thống (cả phía User và Admin), người dùng có thể chọn 1 trong 3 chế độ mở nội dung con thông qua `PeekModeSwitcher`:
1. **`Side Peek` (Trượt từ bên phải)**: Mở panel chi tiết ở góc phải màn hình với chuyển động mượt mà (không bị giật double-bounce), đồng thời phủ lớp làm mờ nhẹ (`backdrop-blur-[2px]`) lên danh sách phía dưới để tăng sự tập trung.
2. **`Center Modal` (Hộp thoại giữa màn hình)**: Mở chi tiết công việc trong cửa sổ lớn giữa màn hình với nền mờ.
3. **`Full Page` (Mở toàn trang)**: Điều hướng sang trang chi tiết/trình soạn thảo toàn màn hình.

# Spec — Chế độ Không gian Cá nhân & Tác giả Độc lập (Hybrid Personal Studio + Solo Workspace Mode)

> Bước ① theo `docs/rule/feature-workflow.md`.
> Kiến trúc đã chốt: **Phương án 4 — Hybrid (Auto-Provisioned Shadow Personal Hub `Agency` + Workspace-Level Mode `workspaceMode: "PERSONAL" | "AGENCY"`)**.
> Tuân thủ tuyệt đối 6 Role hệ thống chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`) và bảo toàn 100% baseline **141 Functional Requirements (`3.2.1`–`3.10.14`)** theo `AGENTS.md`.

---

## 1. Objective (Bối cảnh & Mục tiêu)

Hiện tại BrandHub được thiết kế xoay quanh mô hình B2B Agency 3 tầng (`User → Agency → Workspace`) và quy trình hợp đồng 3 bước cứng (`1. Gói dịch vụ → 2. Chiến dịch → 3. Công việc`) kèm luồng phê duyệt đa cấp (`Creator → Manager → Client`). Khi mở rộng sang tệp **người làm truyền thông cá nhân (Solo Creator, Freelancer, Sinh viên làm đồ án/bài tập truyền thông, Chủ shop/thương hiệu cá nhân)**, kiến trúc hiện hữu gây ra 4 rào cản lớn:

1. **Rào cản khởi tạo (Onboarding Friction)**: Người dùng cá nhân chỉ muốn vào viết bài, tạo kịch bản video ngắn, lập kế hoạch sự kiện hoặc dùng AI Studio, nhưng hệ thống bắt buộc phải khai báo thành lập Công ty (`Agency` — FR `3.4.1`), tạo `Workspace` (FR `3.4.13`) và chỉ định `Manager` từ danh sách nhân sự.
2. **Rào cản hợp đồng (`Media Package` Gatekeeper)**: Trang Chiến dịch (`/workspaces/:id/campaigns`) và tiến trình làm việc đang kiểm tra bắt buộc `workspaceMediaPackageId != null` (phải tạo gói truyền thông và chờ `Client` duyệt gói — FR `3.5.1`–`3.5.4`). Người dùng cá nhân làm dự án tự thân không có khách hàng (`Client`) để ký gói dịch vụ nên bị chặn ngay từ bước đầu.
3. **Rào cản phê duyệt đa cấp (`Creator → Manager → Client` Approval Gate)**: Một công việc (`Task` / `TaskSection`) muốn hoàn tất hoặc xuất bản lên mạng xã hội (`PostSchedulePublishJob`) phải đi qua bước nộp duyệt nội bộ và chờ `Client` duyệt (`CLIENT_APPROVED`). Người làm truyền thông cá nhân vừa là người sáng tạo vừa là người quyết định cuối cùng, cần cơ chế **Tự hoàn tất & Xuất bản 1 chạm (1-Click Self-Approve)**.
4. **Rào cản nhận thức trên giao diện (B2B Cognitive Overload)**: Thanh điều hướng (`Sidebar`), thanh Tiến trình (`SidebarProgressSection`) và Bảng điều khiển (`WorkspaceDashboard`) hiển thị nhiều mục chỉ dành cho mô hình Agency–Client (*1. Gói dịch vụ, Hồ sơ Khách hàng, Cổng Khách hàng, Yêu cầu nội dung từ khách hàng, Duyệt gói truyền thông*), gây bối rối cho cá nhân hoặc nhóm bài tập nhỏ.

### Mục tiêu của giải pháp Hybrid:
1. **Khởi tạo 1 chạm Không gian Cá nhân (Zero-Friction Personal Studio Bootstrap)**:
   - Cung cấp lối vào trực tiếp **"Không gian Cá nhân (Personal Studio)"** trên trang chào mừng, trang `/agency` và menu chuyển đổi nhanh.
   - Chỉ với 1 cú nhấp chuột (`POST /api/v1/workspaces/personal/bootstrap`), hệ thống tự động tạo ngầm (hoặc lấy lại) một `Agency` cá nhân (`isPersonalHub = true`) và một `Workspace` cá nhân (`workspaceMode = "PERSONAL"`), gán người dùng giữ đồng thời vai trò `Owner` (cấp Agency) và `Manager` (cấp Workspace).
2. **Phân nhánh linh hoạt ở cấp Workspace (`workspaceMode = "PERSONAL" | "AGENCY"`)**:
   - Một tài khoản người dùng có thể vừa tham gia các Workspace công ty (`workspaceMode = "AGENCY"`), vừa sở hữu một hoặc nhiều Workspace cá nhân (`workspaceMode = "PERSONAL"`) cho kênh cá nhân, dự án freelance hoặc đồ án môn học.
   - Toàn bộ bảng biểu, khóa ngoại `agency_id` và `workspace_id` của 141 FR hiện tại được giữ nguyên 100% (Zero-Breaking Schema).
3. **Mở khóa 2 luồng làm việc không cần Gói dịch vụ trong chế độ `PERSONAL`**:
   - **Luồng Chiến dịch cá nhân (Package-less Personal Campaign)**: Lập kế hoạch chiến dịch truyền thông (Mục tiêu, Thông điệp, Timeline, 8 loại hạng mục công việc) mà không cần `MediaPackage` và không bị chặn bởi hạn mức số lượng của gói.
   - **Luồng Công việc độc lập (Standalone / Quick Task)**: Tạo trực tiếp bất kỳ công việc nào trong **8 loại Task chuẩn** (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`) ngay tại bảng Công việc hoặc từ Bệ phóng Sáng tạo Cá nhân (Quick Launchpad) mà không cần tạo Chiến dịch trước.
4. **Cơ chế Tự duyệt 1 chạm (`Solo Self-Approval`) & Cộng tác nhóm nhỏ (`Study Group / Small Team`)**:
   - Mọi Task tạo trong Workspace `PERSONAL` mặc định có `requiresClientApproval = false`.
   - Cung cấp thao tác **Tự hoàn tất & Duyệt ngay (`self-approve`)** ở cả cấp `Task` và cấp `TaskSection`, đưa nội dung thẳng sang trạng thái hoàn tất (`FINISHED` / `INTERNAL_APPROVED`) để mở khóa **Đăng bài ngay / Lên lịch đăng / Gửi bản tin** tức thì.
   - Vẫn cho phép mời thêm bạn cùng nhóm hoặc cộng tác viên với vai trò `Creator` vào Workspace `PERSONAL` để phân công Subtask theo vai trò (`TaskCatalog`) mà không cần có `Client`.
5. **Giao diện Thích ứng (Adaptive UI) & Nâng cấp mượt lên Agency (`Seamless Scale-Up`)**:
   - Tự động tinh gọn `Sidebar`, `ProgressStepper` (còn 2 bước mở sẵn: `1. Kế hoạch / Chiến dịch` và `2. Công việc & Sáng tạo`) và `WorkspaceDashboard` (hiển thị **Personal Quick Launchpad**).
   - Bất kỳ lúc nào khi dự án cá nhân phát triển thành dự án có khách hàng, `Owner` có thể chuyển `workspaceMode` từ `"PERSONAL"` sang `"AGENCY"` ngay trong Cài đặt Workspace mà **bảo toàn 100% bài viết, tư liệu, lịch sử AI và cấu hình mạng xã hội**.

---

## 2. Thuật ngữ & Quy tắc Bảo toàn Chuẩn Hệ Thống

| Thuật ngữ | Định nghĩa | Quy tắc bảo toàn bắt buộc |
| :--- | :--- | :--- |
| **Role hệ thống** | 6 tên chuẩn cố định: `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`. | **Giữ nguyên tuyệt đối 6 Role chuẩn theo `AGENTS.md`.** Tuyệt đối không sinh thêm enum role mới như `PersonalUser`, `SoloCreator` hay `Freelancer`. Trong Workspace `PERSONAL`, người sở hữu giữ role `Owner` (ở `Agency` cá nhân) và `Manager` (ở `Workspace` cá nhân). |
| **Personal Hub (`isPersonalHub`)** | Bản ghi `Agency` đại diện cho không gian tài khoản cá nhân của người dùng (`logoIcon = "personal-studio"` / cờ `isPersonalHub = true` trong metadata). | Bảo toàn khóa ngoại `agency_id` cho Ví AI Credit (`agency_credit_wallets`), Gói cước (`subscriptions`), Hóa đơn (`invoices`) và Định mức Newsletter (`newsletter_usage`). |
| **Chế độ Không gian (`workspaceMode`)** | Trường cấu hình lưu trong cột JSONB `workspaces.settings` (`"workspaceMode": "AGENCY" \| "PERSONAL"`), ánh xạ thành enum `WorkspaceMode` ở Backend và Frontend. | Mọi Workspace hiện hữu trong DB có `settings = "{}"` hoặc chưa có khóa `workspaceMode` mặc định trả về `"AGENCY"` (tương thích ngược 100%). |
| **Chiến dịch Cá nhân (`Personal Campaign`)** | Bản ghi `MediaCampaign` được khởi tạo và triển khai trong Workspace có `workspaceMode = "PERSONAL"` mà không cần chốt hợp đồng `MediaPackage` với `Client`. | Tái sử dụng 100% cấu trúc `MediaCampaign`, `CampaignTimelineGrid` và `CampaignTaskStore.draftTask`. |
| **Công việc Độc lập (`Standalone Task`)** | Bản ghi `TaskDocument` được tạo trực tiếp trong Workspace với `sourceType = "manual"`, `campaignId = null` (hoặc gắn vào chiến dịch cá nhân tùy chọn) và `requiresClientApproval = false`. | Hỗ trợ đầy đủ cả **8 loại `TaskType` chuẩn**, trình soạn chia phần (`TaskSectionDocument`) và 3 chế độ mở chi tiết (`Side Peek`, `Center Modal`, `Full Page`). |
| **Tự duyệt 1 chạm (`Self-Approve`)** | Hành động của `Owner` / `Manager` trong Workspace `PERSONAL` (hoặc trên Task có `requiresClientApproval = false`) nhằm xác nhận hoàn tất tức thì toàn bộ các phần (`INTERNAL_APPROVED`) và đóng Task ở trạng thái đã duyệt (`FINISHED` + `lastSubmission.outcome = APPROVED`). | Tương thích hoàn toàn với điều kiện kiểm tra của `PostSchedulePublishJob` và `NewsletterService.send`. |

---

## 3. Hành vi của 8 Loại Công việc (`TaskType`) trong Chế độ `PERSONAL`

Không giống mô hình cắt giảm tính năng, người dùng ở chế độ `PERSONAL` được sử dụng **toàn bộ 8 loại công việc chuẩn** và bộ công cụ AI của hệ thống, nhưng quy trình được tối ưu hóa không rào cản:

| Loại Task (`TaskType`) | Ứng dụng thực tế cho Cá nhân / Nhóm nhỏ | Hành vi Subtask & Phần soạn thảo (`TaskSection`) ở chế độ `PERSONAL` | Hành vi Xuất bản / Đầu ra sau khi `Self-Approve` |
| :--- | :--- | :--- | :--- |
| **`POST`** *(Bài đăng MXH)* | Viết bài xây kênh cá nhân, fanpage shop nhỏ, bài truyền thông CLB/đồ án. | Có sẵn 4 phần (`POST.BRIEF`, `POST.CAPTION`, `POST.MEDIA`, `POST.CHANNELS`). Khi làm 1 mình, `Owner`/`Manager` sửa trực tiếp mọi phần trên 1 màn hình và bấm **Hoàn tất & Duyệt ngay**. Khi làm nhóm, có thể giao từng vai trò (`POST_CONTENT`, `POST_MEDIA`...) cho `Creator`. | Mở khóa ngay nút **Đăng ngay** hoặc **Lên lịch đăng** lên 4 nền tảng: **Facebook, Instagram, TikTok, Threads**. |
| **`SHORT_VIDEO`** *(Video ngắn / Reels / TikTok)* | Lên kịch bản phân cảnh, tạo video ngắn AI hoặc dựng Reels/TikTok cá nhân. | Sửa trực tiếp `VIDEO.SCRIPT`, `VIDEO.EDIT`, `VIDEO.CAPTION`, `VIDEO.CHANNELS` hoặc dùng AI Video Studio / Product Video / Video Space. | Mở khóa đăng/lên lịch lên **TikTok, Instagram (Reels), Facebook (Reels)** hoặc xuất file video. |
| **`SURVEY`** *(Khảo sát)* | Tạo biểu mẫu khảo sát nghiên cứu thị trường, khảo sát bài tập môn học, lấy ý kiến độc giả. | Thiết kế câu hỏi tại `SURVEY.FORM`, cấu hình link public tại `SURVEY.DISTRIBUTION` và tổng hợp kết quả tại `SURVEY.REPORT`. | Phát hành link khảo sát công khai `/public/surveys/{token}` và xem thống kê/AI phân tích ngay. |
| **`EVENT_PLAN`** *(Kế hoạch sự kiện)* | Lập kế hoạch tổ chức sự kiện CLB, buổi ra mắt sản phẩm cá nhân, đồ án môn Tổ chức sự kiện. | Soạn thảo `EVENT.AGENDA`, `EVENT.LOGISTICS`, `EVENT.PROMOTION`, `EVENT.RUNSHEET`, `EVENT.REPORT` trên bảng động (`SectionListField`). | Xuất file hồ sơ kế hoạch sự kiện chuẩn **PDF** chỉ với 1 chạm (không đóng dấu "Bản nháp" sau khi đã `Self-Approve`). |
| **`PRESS_RECOMMENDATION`** *(Thông cáo báo chí)* | Soạn thông cáo báo chí, bài PR truyền thông hoặc bài tập môn Quan hệ công chúng (PR). | Soạn thảo `PRESS.MEDIA_LIST`, `PRESS.RELEASE`, `PRESS.CONTACT_LOG`, `PRESS.COVERAGE`. | Xuất file thông cáo báo chí chuẩn **DOCX** (`poi-ooxml`). |
| **`KOL_BOOKING`** *(Quản lý KOL/Influencer)* | Lập danh sách micro-KOL cho shop nhỏ, soạn brief và theo dõi hiệu quả bài đăng review. | Quản lý `KOL.SHORTLIST`, `KOL.DEAL`, `KOL.BRIEF`, `KOL.DRAFT`, `KOL.REPORT` kết hợp tra cứu `Collaborator Directory` (FR `3.7.15`–`3.7.19`). | Xuất báo cáo kế hoạch KOL chuẩn **PDF**. |
| **`WORKSHOP`** *(Hội thảo / Workshop)* | Tổ chức buổi chia sẻ cá nhân, webinar, workshop học thuật kèm form đăng ký tham dự. | Soạn chương trình (`WORKSHOP.PROGRAM`), diễn giả (`WORKSHOP.SPEAKERS`), hậu cần (`WORKSHOP.LOGISTICS`), mở form đăng ký (`WORKSHOP.REGISTRATION`) và báo cáo (`WORKSHOP.REPORT`). | Mở form đăng ký online + phòng họp trực tuyến + xuất báo cáo **PDF**. |
| **`EMAIL_NEWSLETTER`** *(Bản tin Email)* | Gửi bản tin cá nhân (Substack-style newsletter), thư mời sự kiện hoặc cập nhật cho danh sách người đăng ký. | Thiết kế `EMAIL.CONTENT` & `EMAIL.DESIGN` bằng `BlockBuilder`, chọn nhóm người nhận tại `EMAIL.AUDIENCE` và xem thống kê tại `EMAIL.REPORT`. | Sau khi `Self-Approve` (`INTERNAL_APPROVED`), gửi thật hoặc lên lịch gửi qua `NewsletterService` theo hạn mức gói của Personal Hub. |

---

## 4. Ma trận Phân quyền trong Chế độ `PERSONAL` vs `AGENCY`

| Hành động / Quyền hạn | `Owner` / `Manager` (Chủ Workspace `PERSONAL`) | `Creator` (Bạn cùng nhóm / Cộng tác viên được mời vào Workspace `PERSONAL`) | `Client` (Không tồn tại trong `PERSONAL`, chỉ kích hoạt khi chuyển sang `AGENCY`) | `Guest` (Người xem link chia sẻ công khai) |
| :--- | :---: | :---: | :---: | :---: |
| Khởi tạo 1 chạm Personal Studio (`/workspaces/personal/bootstrap`) | ✔ | ✔ (Tạo không gian riêng của họ) | ✖ | ✖ |
| Chuyển đổi chế độ `PERSONAL ↔ AGENCY` | ✔ | ✖ | ✖ | ✖ |
| Tạo Chiến dịch không cần `MediaPackage` | ✔ | ✖ (Xem kế hoạch & nhận việc) | ✖ | ✖ |
| Tạo Công việc độc lập (`Standalone Task` — 8 loại) | ✔ | ✔ (Nếu được gán quyền tạo việc hoặc làm điều phối) | ✖ | ✖ |
| Chỉnh sửa mọi phần (`TaskSection`) trong trình soạn thảo | ✔ (Mọi phần, mọi trạng thái trước khi đóng) | ✔ (Phần được giao theo `subtaskRole` hoặc toàn bộ nếu là Điều phối `assigneeId`) | ✖ | ✖ |
| Tự duyệt 1 chạm (`Self-Approve` Task & Section) | ✔ | ✖ (Nộp `Submit` để Chủ Workspace duyệt) | ✖ | ✖ |
| Kết nối tài khoản MXH (Facebook, Instagram, TikTok, Threads) | ✔ | ✖ | ✖ (Ở chế độ `AGENCY`, cả `Client` và `Manager` đều kết nối được) | ✖ |
| Đăng bài ngay / Lên lịch đăng / Gửi Newsletter | ✔ | ✔ (Nếu được giao `POST_PUBLISHING` / `VIDEO_PUBLISH` / `EMAIL_SEND` sau khi Task đã duyệt) | ✖ | ✖ |
| Sử dụng AI Studio (Caption, Image, Video, Ambassador, Trend) | ✔ (Trừ vào ví AI Credit của Personal Hub) | ✔ (Trừ vào ngân sách cấp cho Workspace) | ✖ | ✖ |
| Xem tài liệu/bài viết qua Link chia sẻ công khai (`ShareLink`) | ✔ (Tạo/Thu hồi link) | ✖ | ✖ | ✔ (Chỉ đọc theo phạm vi token) |

---

## 5. Vòng đời Trạng thái Task & Section trong Chế độ `PERSONAL`

### 5.1. Vòng đời khi làm việc Độc lập (Solo 1 người — Luồng nhanh 1 chạm)

```
[Tạo Task (Standalone hoặc từ Personal Campaign)]
       │ (requiresClientApproval = false, assigneeId = currentUser)
       ▼
  TODO / IN_PROGRESS  (Chủ không gian soạn thảo trực tiếp trên Editor)
       │
       ├──(Bấm "Hoàn tất & Duyệt ngay" / POST /self-approve)──▶ Task: FINISHED (lastSubmission = APPROVED)
       │                                                        Mọi TaskSection: INTERNAL_APPROVED (finalState = true)
       │                                                        Mọi Subtask: FINISHED
       ▼
  [Mở khóa ngay: Đăng bài MXH / Lên lịch đăng / Gửi Newsletter / Xuất PDF-DOCX chính thức]
```

### 5.2. Vòng đời khi làm việc Nhóm nhỏ / Nhóm bài tập (`Owner`/`Manager` + các thành viên `Creator`)

```
[Chủ không gian tạo Task & gán Subtask vai trò cho các thành viên Creator]
       │
       ▼
  TaskSection: DRAFT ──(Creator bấm Nộp phần)──▶ SUBMITTED
       ▲                                            │
       │◀──(Chủ không gian Trả lại kèm ghi chú)─────┤
                                                    │ (Chủ không gian bấm Duyệt phần
                                                    │  hoặc bấm "Duyệt & Hoàn tất tất cả")
                                                    ▼
                                            INTERNAL_APPROVED (Trạng thái cuối cùng vì requiresClientApproval = false)
                                                    │
                                                    ▼
                                      Task cha tự động chuyển sang FINISHED (APPROVED)
```

---

## 6. User Stories

1. **US1 (Solo Creator — Khởi tạo 1 chạm)**: Là một **nhà sáng tạo nội dung cá nhân**, sau khi đăng ký tài khoản BrandHub, tôi muốn bấm vào **"Bắt đầu với Không gian Cá nhân (Personal Studio)"** và được đưa thẳng vào bàn làm việc trong 1 giây mà không phải điền hồ sơ thành lập công ty hay chọn người quản lý.
2. **US2 (Solo Creator — Tạo bài đăng & Tự duyệt 1 chạm)**: Là một **Owner/Manager trong Workspace `PERSONAL`**, tôi muốn tạo trực tiếp một công việc `POST` hoặc `SHORT_VIDEO` tại trang Công việc, dùng AI gợi ý caption/hình ảnh, bấm **"Hoàn tất & Duyệt ngay"** và đăng thẳng lên kênh Facebook/Instagram/TikTok/Threads của mình mà không phải chờ `Client` nào phê duyệt.
3. **US3 (Sinh viên / Cá nhân — Lập kế hoạch Sự kiện, PR, Khảo sát, Workshop)**: Là một **sinh viên ngành Truyền thông / Marketing**, tôi muốn tạo nhanh một công việc `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `SURVEY` hoặc `WORKSHOP` trong không gian cá nhân để làm đồ án môn học và xuất ra file PDF/DOCX chuyên nghiệp mà không bị hệ thống đòi phải tạo Gói dịch vụ (`Media Package`).
4. **US4 (Nhóm bài tập / Nhóm nhỏ — Phân công Subtask không cần Client)**: Là **trưởng nhóm đồ án (`Owner`/`Manager` của Workspace `PERSONAL`)**, tôi muốn mời 3 bạn cùng nhóm vào Workspace với vai trò `Creator`, chia các phần `EVENT.AGENDA`, `EVENT.LOGISTICS`, `EVENT.PROMOTION` cho từng bạn làm song song, và tự mình duyệt chốt bài của nhóm mà không cần tạo tài khoản `Client` giả.
5. **US5 (Freelancer — Chiến dịch cá nhân không ràng buộc gói)**: Là một **Freelancer quản lý kênh cá nhân**, tôi muốn lập một Chiến dịch truyền thông tháng 12 gồm 10 bài đăng, 4 video ngắn và 2 bản tin email tại trang Chiến dịch mà không bị chặn bởi màn hình *"Chưa có gói dịch vụ khách hàng"*.
6. **US6 (Chủ shop nhỏ — Kết nối MXH & Gửi Newsletter cá nhân)**: Là **chủ một thương hiệu cá nhân**, tôi muốn tự kết nối tài khoản Facebook, Instagram, TikTok, Threads và gửi bản tin `EMAIL_NEWSLETTER` cho tệp độc giả đã đăng ký ngay trong Workspace `PERSONAL`.
7. **US7 (Đa ngữ cảnh — Vừa làm ở Agency vừa có Không gian riêng)**: Là một **Creator hoặc Manager đang làm việc tại một Agency lớn**, tôi vẫn muốn có một nút chuyển sang **Personal Studio** của riêng mình để làm dự án cá nhân buổi tối, hoàn toàn tách biệt với dữ liệu và ví credit của công ty.
8. **US8 (Nâng cấp quy mô — Scale-up từ `PERSONAL` lên `AGENCY`)**: Là một **Freelancer**, khi dự án cá nhân của tôi có khách hàng tài trợ chính thức và họ muốn vào duyệt bài qua Cổng Khách hàng (`Client Portal`), tôi muốn chuyển chế độ Workspace từ `"PERSONAL"` sang `"AGENCY"` trong phần Cài đặt mà giữ nguyên 100% các bài viết, chiến dịch và tư liệu đã làm.
9. **US9 (Trải nghiệm xem 3 chế độ Notion Peek)**: Là **người dùng trên Desktop và Mobile**, khi bấm vào bất kỳ công việc hay hạng mục nào trong Workspace `PERSONAL` hoặc `AGENCY`, tôi có thể chọn mở theo 3 chế độ: **Trượt bên phải (`Side Peek`)**, **Hộp thoại giữa màn hình (`Center Modal`)**, hoặc **Mở toàn trang (`Full Page`)** với nền làm mờ nhẹ tập trung.
10. **US10 (Quản lý trên Mobile)**: Là **Owner/Manager dùng ứng dụng di động (`brandhub-mobile-app`)**, tôi nhận diện được đâu là Workspace `PERSONAL`, xem tiến độ các phần và duyệt nhanh công việc ngay trên điện thoại.

---

## 7. Đặc tả Nghiệp vụ Chi tiết (Detailed Functional Specifications)

### 7.1. Khởi tạo 1 chạm Không gian Cá nhân (`POST /api/v1/workspaces/personal/bootstrap`)
1. **Điểm chạm Giao diện (UI Entry Points)**:
   - **Tại trang `/agency` (Agency & Workspace Hub)**:
     - Trên thanh công cụ đầu trang (cạnh nút *"Tạo Agency mới"*) và trong màn hình Empty State khi tài khoản mới chưa có Agency/Workspace nào: hiển thị thẻ/nút nổi bật **"Không gian Cá nhân (Personal Studio)"** với mô tả *"Dành cho nhà sáng tạo độc lập, freelancer, đồ án sinh viên & dự án tự thân — vào làm việc ngay không cần tạo công ty"*.
   - **Tại trình chuyển đổi nhanh ở Sidebar (`SidebarHeader`)**:
     - Hiển thị lối tắt chuyển nhanh về **Personal Studio** hoặc tạo thêm Workspace cá nhân mới.
2. **Thuật toán xử lý Idempotent tại Backend**:
   - Khi người dùng đã đăng nhập gọi `POST /api/v1/workspaces/personal/bootstrap` (body tùy chọn `{ "name": "..." }`):
     1. Tìm kiếm trong các `Agency` mà `ownerId == currentUser.id` và `status == ACTIVE` xem đã có `Workspace` nào đang `ACTIVE` và có `settings.workspaceMode == "PERSONAL"` chưa.
     2. **Trường hợp 1 (Đã tồn tại)**:
        - Trả về ngay `WorkspaceResponse` của Workspace cá nhân đó (ưu tiên Workspace có cờ `isPersonalDefault: true` trong `settings`). Không tạo thêm bản ghi nào (đảm bảo **Idempotent 100%** ngay cả khi người dùng bấm đúp chuột).
     3. **Trường hợp 2 (Chưa tồn tại)**:
        - Kiểm tra xem `currentUser` đã có `Agency` cá nhân (`logoIcon == "personal-studio"`) chưa.
        - Nếu chưa có `Agency` cá nhân:
          - Khởi tạo bản ghi `Agency` mới:
            - `ownerId = currentUser.id`
            - `name = "Personal Studio — " + currentUser.displayName` (cắt gọn an toàn ≤ 120 ký tự)
            - `logoIcon = "personal-studio"`
            - `companySize = "1-10"` (hoặc giá trị hợp lệ nhỏ nhất trong validator hiện hành)
            - `category = "Personal / Creator"`
            - `status = AgencyStatus.ACTIVE`
          - Thêm bản ghi `AgencyMember` (`userId = currentUser.id`, `status = ACTIVE`).
          - Khởi tạo gói cước mặc định (`Basic`) và ví AI Credit (`agency_credit_wallets`) cho `Agency` theo đúng quy trình chuẩn khi tạo Agency mới.
        - Khởi tạo bản ghi `Workspace` mới thuộc `Agency` cá nhân đó:
          - `name = (req != null && hasText(req.name)) ? req.name.trim() : "Không gian cá nhân của tôi"`
          - `brandName = currentUser.displayName`
          - `timezoneConfig = "Asia/Ho_Chi_Minh"`
          - `status = WorkspaceStatus.ACTIVE`
          - `settings = {"workspaceMode": "PERSONAL", "isPersonalDefault": true}`
        - Thêm bản ghi `WorkspaceMember` cho `currentUser` với `workspaceRole = WorkspaceRole.MANAGER`, `status = WorkspaceMemberStatus.ACTIVE`.
        - Trả về `WorkspaceResponse` kèm `workspaceMode = WorkspaceMode.PERSONAL`.

### 7.2. Phân loại `workspaceMode` khi Tạo mới & Chuyển đổi Chế độ (`PERSONAL ↔ AGENCY`)
1. **Khi tạo Workspace mới (`POST /api/v1/agencies/{agencyId}/workspaces`)**:
   - `CreateWorkspaceRequest` bổ sung trường `workspaceMode` (`AGENCY` | `PERSONAL`, mặc định `AGENCY`).
   - Khi `workspaceMode == WorkspaceMode.PERSONAL`:
     - Trường `managerId` trong `CreateWorkspaceRequest` trở thành **tùy chọn (nullable)**: nếu người gọi không truyền `managerId`, Backend tự động gán `managerId = currentUser.id` (người tạo tự làm `Manager` của không gian cá nhân đó).
     - Trường `brandName` nếu bỏ trống sẽ tự động lấy bằng `name` của Workspace.
     - Ghi `"workspaceMode": "PERSONAL"` vào JSONB `workspaces.settings`.
2. **Khi chuyển đổi chế độ (`PUT /api/v1/workspaces/{workspaceId}` hoặc `PATCH /api/v1/workspaces/{workspaceId}/mode`)**:
   - Chỉ `Owner` của Agency hoặc `Manager` của Workspace đó mới được phép đổi `workspaceMode`.
   - **Chuyển từ `PERSONAL` → `AGENCY` (Scale-Up)**:
     - Luôn cho phép.
     - Cập nhật `settings.workspaceMode = "AGENCY"`.
     - Toàn bộ `MediaCampaign`, `TaskDocument`, `TaskSectionDocument`, `PostDocument`, `Material`, `BrandKnowledge`, `SocialAccount` giữ nguyên 100%.
     - Các Task đã tạo trước đó vẫn giữ nguyên `requiresClientApproval = false` trừ khi `Manager` bật thủ công; các quy trình `1. Gói dịch vụ`, `Cổng Khách hàng`, `Yêu cầu nội dung` lập tức xuất hiện trên Sidebar.
   - **Chuyển từ `AGENCY` → `PERSONAL` (Simplify)**:
     - Kiểm tra điều kiện an toàn: Nếu Workspace đang có thành viên giữ vai trò `Client` đang hoạt động (`WorkspaceMember.workspaceRole == CLIENT && status == ACTIVE`) hoặc đang có Task ở trạng thái chờ `Client` duyệt (`reviewStep == CLIENT` hoặc có `TaskSection` đang chờ `Client` duyệt), hệ thống trả lỗi `WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT` (`409 Conflict`) kèm thông báo yêu cầu hoàn tất/gỡ `Client` trước khi chuyển về chế độ Cá nhân.
     - Nếu không có `Client` đang hoạt động: cập nhật `settings.workspaceMode = "PERSONAL"` thành công.

### 7.3. Luồng Chiến dịch Cá nhân Không cần Gói dịch vụ (`Package-less Personal Campaign`)
1. **Gỡ bỏ điều kiện chặn `MediaPackage` ở chế độ `PERSONAL`**:
   - Ở chế độ `AGENCY`, để khởi tạo và triển khai chiến dịch, Workspace phải có một `WorkspaceMediaPackage` đã được duyệt.
   - Ở chế độ `PERSONAL`:
     - Tại Frontend (`/workspaces/:id/campaigns`), bỏ cổng chặn *"Chưa có gói dịch vụ"* khi `isPersonalMode === true`.
     - Tại Backend (`MediaCampaignService` / `CampaignPlanValidator`), khi Workspace có `workspaceMode == PERSONAL`:
       - Nếu bảng SQL `media_campaigns` yêu cầu khóa ngoại `workspace_media_package_id`, hệ thống tự động tạo ngầm (hoặc tái sử dụng) một bản ghi `WorkspaceMediaPackage` nội bộ tự do (`name = "Kế hoạch Cá nhân Tự do"`, `status = APPROVED`, không giới hạn trần hạng mục) gắn với Workspace đó để thỏa mãn ràng buộc khóa ngoại SQL mà người dùng không bao giờ phải thao tác với Gói dịch vụ.
       - Khi gọi `deploy` chiến dịch cá nhân, `CampaignPlanValidator` bỏ qua kiểm tra vượt trần số lượng hạng mục theo gói (`exceedsPackageQuota`), cho phép người dùng thêm bất kỳ số lượng công việc nào thuộc 8 loại `TaskType`.
       - Mọi Task sinh ra khi deploy chiến dịch trong Workspace `PERSONAL` mặc định có `requiresClientApproval = false` và nếu chưa chọn người phụ trách thì tự động gán `assigneeId = currentUser.id`.

### 7.4. Luồng Tạo Công việc Độc lập (`Standalone / Quick Task Creation`)
1. **API Tạo Công việc Độc lập (`POST /api/v1/workspaces/{workspaceId}/tasks/standalone`)**:
   - Cho phép `Owner`, `Manager` hoặc `Creator` trong Workspace tạo nhanh một Task độc lập mà không cần đi qua `ContentRequest` của `Client` hay phải `deploy` cả một `MediaCampaign`:
     - Input:
       - `title` (bắt buộc, 1–255 ký tự)
       - `type` (bắt buộc, 1 trong 8 loại `TaskType`: `POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`)
       - `description` (tùy chọn, ≤ 5000 ký tự)
       - `dueDate` (tùy chọn, mặc định `now + 7 ngày` nếu bỏ trống)
       - `assigneeId` (tùy chọn, mặc định `currentUser.id`)
       - `priority` (tùy chọn: `LOW` | `MEDIUM` | `HIGH` | `URGENT`, mặc định `MEDIUM`)
       - `campaignId` (tùy chọn: nếu truyền thì gắn vào chiến dịch đó; nếu `null` thì hệ thống gắn vào chiến dịch cá nhân mặc định của Workspace hoặc tạo `sourceType = "manual"`)
       - `initRoleSubtasks` (boolean, mặc định `true`: tự động sinh bộ Subtask chuẩn theo `TaskCatalog` và gán cho `assigneeId` để mở khóa đầy đủ các phần soạn thảo `TaskSection`).
     - Output: Trả về `TaskWorkflowSnapshot` / `TaskDetailsResponse` chứa `taskId` vừa tạo để Frontend có thể mở ngay chi tiết công việc hoặc chuyển thẳng vào trình soạn thảo (`/editor`).
2. **Giao diện Tạo Công việc Nhanh (`QuickCreateTaskDialog`)**:
   - Đặt tại:
     1. Thanh công cụ trang **Danh sách công việc (`/workspaces/:id/tasks`)** — nút CTA chính **"+ Tạo công việc mới"**.
     2. Cụm **Bệ phóng Sáng tạo Cá nhân (`Personal Quick Launchpad`)** trên trang **Bảng điều khiển (`/workspaces/:id/dashboard`)**.
   - Cho phép chọn trực quan 1 trong 8 loại công việc (kèm icon & mô tả ngắn), nhập tiêu đề, hạn hoàn thành và chọn:
     - **"Tạo & Xem chi tiết"** (mở ngay trong bảng xem hiện tại: `Side Peek` / `Center Modal` / `Full Page`).
     - **"Tạo & Mở trình soạn thảo"** (đi thẳng vào `/workspaces/:id/tasks/:taskId/editor`).

### 7.5. Cơ chế Tự duyệt 1 chạm (`Solo Self-Approval`)
1. **API Tự duyệt & Hoàn tất 1 chạm (`POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/self-approve`)**:
   - **Điều kiện cho phép**:
     - Người gọi là `Owner` hoặc `Manager` của Workspace (hoặc là Điều phối viên `assigneeId` trong Workspace có `workspaceMode == PERSONAL`), **VÀ**
     - Workspace có `workspaceMode == PERSONAL` hoặc Task có `requiresClientApproval == false`.
   - **Hành vi thực thi nguyên tử**:
     1. Với mọi phần (`TaskSection`) thuộc `TaskCatalog.sectionsOf(task.type)`:
        - Nếu phần chưa có bản ghi trong `task_sections`, khởi tạo bản ghi với nội dung hiện tại.
        - Chuyển trạng thái phần sang `INTERNAL_APPROVED` (`finalState = true`), tăng `revision`, ghi bản chụp vào `task_section_versions` và ghi sự kiện `SELF_APPROVE` vào `task_section_events`.
     2. Với mọi `Subtask` của Task (cả subtask có `subtaskRole` và subtask tự do đang mở):
        - Chuyển `status` sang `FINISHED`.
     3. Với `TaskDocument` cha:
        - Chuyển `status = TaskStatus.FINISHED`, `reviewStep = null`, cập nhật `lastSubmission` với `outcome = APPROVED` và ghi bản ghi phê duyệt vào `task_approvals` (`step = MANAGER`, `action = APPROVE`, `note = req.note || "Self-approved in Personal Mode"`).
     4. Nếu Task thuộc loại `POST` hoặc `SHORT_VIDEO` và đã có `PostDocument` ở trạng thái `DRAFT`, đồng bộ trạng thái bài viết sẵn sàng xuất bản (`APPROVED` hoặc giữ `SCHEDULED` nếu đã đặt lịch).
   - **Kết quả**: Chỉ sau 1 cú click, người dùng cá nhân có thể bấm **"Đăng ngay (Publish Now)"**, **"Lên lịch đăng (Schedule)"**, **"Gửi bản tin (Send Newsletter)"** hoặc **"Xuất file chính thức (Export PDF/DOCX)"**.

### 7.6. Cộng tác Nhóm nhỏ / Nhóm Bài tập (`Small Team / Study Group Collaboration`)
- Trong một Workspace có `workspaceMode == PERSONAL`, chủ không gian (`Owner`/`Manager`) vẫn truy cập được mục **Thành viên (`/workspaces/:id/members`)**:
  - Có thể mời bạn học, đồng nghiệp hoặc cộng tác viên thiết kế/dựng phim vào Workspace với vai trò **`Creator`**.
  - Các thành viên `Creator` này có thể được giao `Task` hoặc `Subtask` theo vai trò (`POST_CONTENT`, `POST_MEDIA`, `EVENT_LOGISTICS`, `WORKSHOP_SPEAKER`...), trao đổi trong **Phòng Chat (`/workspaces/:id/chat`)** và sử dụng AI Studio trong phạm vi hạn mức AI Credit của Workspace.
  - Điểm khác biệt duy nhất so với `AGENCY` là **không có vai trò `Client`** và quy trình duyệt kết thúc ngay khi Chủ không gian (`Owner`/`Manager`) bấm duyệt nội bộ (`INTERNAL_APPROVED`).

### 7.7. Giao diện Thích ứng (`Adaptive Sidebar, Stepper, Quick Launchpad & 3-Mode Peek`)
1. **Thanh Tiến trình trên Sidebar (`SidebarProgressSection.tsx`)**:
   - Khi `workspaceMode === "AGENCY"`: Giữ nguyên 3 bước (`1. Gói dịch vụ → 2. Chiến dịch → 3. Công việc`).
   - Khi `workspaceMode === "PERSONAL"`:
     - Ẩn hoàn toàn bước `1. Gói dịch vụ`.
     - Hiển thị **2 bước luôn mở khóa (Unlocked)**:
       - `1. Kế hoạch & Chiến dịch` (`/workspaces/:id/campaigns`)
       - `2. Công việc & Sáng tạo` (`/workspaces/:id/tasks`)
     - Hiển thị badge nhỏ **`Cá nhân (Personal)`** thay cho trạng thái chờ duyệt gói.
2. **Menu Điều hướng bên trái (`sidebarNavConfig.ts` & `SidebarNavSections.tsx`)**:
   - Khi `workspaceMode === "PERSONAL"`, tự động ẩn các mục chỉ dành cho tương tác B2B với `Client`:
     - `/workspaces/:id/clients` (Danh sách khách hàng)
     - `/workspaces/:id/client-profile` (Hồ sơ khách hàng)
     - `/workspaces/:id/portal` (Cổng khách hàng)
     - `/workspaces/:id/requests` (Yêu cầu nội dung từ khách hàng)
   - Giữ đầy đủ các công cụ sáng tạo và vận hành:
     - *Tổng quan*: Bảng điều khiển (`/dashboard`), Chiến dịch (`/campaigns`), Trao đổi (`/chat`).
     - *Sáng tạo*: Danh sách công việc (`/tasks`), Duyệt bài nhóm (`/task-approvals`), Khám phá xu hướng (`/trends`), Lịch nội dung (`/calendar`), AI Video / Product Video / Video Space.
     - *Nội dung*: Mẫu Email (`/mail-templates`), Thư viện nội dung (`/library`).
     - *Cài đặt*: Cài đặt Không gian (`/settings`), Thành viên (`/members`), Tài khoản Mạng xã hội (`/social-accounts`).
3. **Bảng điều khiển Cá nhân (`WorkspaceDashboard` — `PersonalQuickLaunchpad`)**:
   - Khi `workspaceMode === "PERSONAL"`:
     - Ẩn `PackageStatusBanner` (banner cảnh báo chưa có gói dịch vụ khách hàng).
     - Hiển thị khối **Bệ phóng Sáng tạo Cá nhân (`Personal Quick Launchpad`)** ở đầu trang với 5 thẻ hành động 1 chạm:
       1. **Viết bài đăng MXH (`POST`)** → Mở tạo nhanh Task `POST` & vào trình soạn thảo.
       2. **Tạo kịch bản & Video ngắn (`SHORT_VIDEO`)** → Mở tạo nhanh Task `SHORT_VIDEO`.
       3. **Kế hoạch Sự kiện / Workshop / PR (`EVENT_PLAN` / `WORKSHOP` / `PRESS`)** → Mở hộp thoại tạo công việc chuyên đề.
       4. **Khám phá Xu hướng AI (`Trend Explorer`)** → Điều hướng tới `/workspaces/:id/trends`.
       5. **Kết nối Kênh MXH (`Social Accounts`)** → Điều hướng tới `/workspaces/:id/social-accounts` (Facebook, Instagram, TikTok, Threads).
4. **Đồng bộ Trình xem 3 chế độ (`Side Peek` | `Center Modal` | `Full Page`)**:
   - Mọi danh sách Công việc, Subtask và Hạng mục trong cả `PERSONAL` và `AGENCY` đều tích hợp `PeekModeSwitcher` (`Side Peek` trượt mượt từ phải có làm mờ nền `backdrop-blur-[2px]`, `Center Modal` giữa màn hình, `Full Page` toàn trang).

### 7.8. Ví AI Credit, Hạn mức Workspace & Thanh toán (`Subscription & Billing`)
- Tuân thủ tuyệt đối kiến trúc **Unified Agency Wallet + Workspace Credit Cap** (`docs/feature/workspace-credit-unification/spec.md`):
  - Mỗi `Personal Hub` (vốn là 1 bản ghi `Agency`) có sẵn 1 ví `agency_credit_wallets` và gói `Basic` mặc định.
  - Khi người dùng cá nhân sử dụng 4 nhóm tính năng AI tính phí (`CONTENT_GENERATE`, `AMBASSADOR_GENERATE`, `COMMERCIAL_IMAGE`, `VIDEO_GENERATE`), hệ thống trừ credit từ ví của `Personal Hub` theo đúng bảng giá cố định do `Admin` cấu hình; các tác vụ miễn phí (`CAPTION_VARIANTS`, `HASHTAG_GENERATE`, `CHARACTER_SHEET`) giữ nguyên miễn phí (`unit_credits = 0`).
  - Nếu người dùng mời thêm bạn bè (`Creator`) vào Workspace `PERSONAL`, chủ không gian (`Owner`) có thể đặt trần hạn mức AI Credit (`workspaceLimit`) cho Workspace đó thông qua `PUT /api/v1/agencies/{agencyId}/credit/workspaces/{workspaceId}/limit` để kiểm soát chi tiêu của nhóm.
  - Khi muốn mua thêm Credit hoặc nâng cấp gói (`Upgrade Plan` — FR `3.9.1`), người dùng thanh toán qua **SePay / PayOS (VietQR)** (FR `3.9.2`) trên cùng luồng hiện có.

---

## 8. Acceptance Criteria (Tiêu chí Nghiệm thu — AC1..AC18)

### Khởi tạo & Chế độ Workspace (`Backend + Web`)
- **AC1 (Bootstrap 1 chạm & Idempotent)**: Gọi `POST /api/v1/workspaces/personal/bootstrap` lần đầu tiên tự động tạo `Agency` cá nhân (`logoIcon = "personal-studio"`) + ví/gói mặc định + `Workspace` (`workspaceMode = "PERSONAL"`), gán người gọi làm `Owner` kiêm `Manager` và trả về `200 OK` kèm `WorkspaceResponse`. Gọi lại lần thứ 2 trở đi trả về chính `Workspace` đó, không sinh thêm bản ghi trùng.
- **AC2 (Tương thích ngược 100%)**: Mọi `Workspace` hiện có trong DB chưa có khóa `"workspaceMode"` trong `workspaces.settings` đều được ánh xạ thành `workspaceMode = "AGENCY"`. Không có bất kỳ thay đổi hay lỗi hồi quy nào đối với các Workspace Agency hiện hữu.
- **AC3 (Tạo Workspace `PERSONAL` tự gán Manager)**: Khi `Owner` gọi `POST /api/v1/agencies/{agencyId}/workspaces` với `workspaceMode = "PERSONAL"` và `managerId = null`, Backend tự động gán `managerId = currentUser.id` và lưu `settings.workspaceMode = "PERSONAL"`.
- **AC4 (Chuyển đổi `PERSONAL → AGENCY` bảo toàn dữ liệu)**: Khi `Owner` hoặc `Manager` đổi `workspaceMode` từ `"PERSONAL"` sang `"AGENCY"`, toàn bộ Chiến dịch, Task, Section, Bài viết, Tư liệu và cấu hình MXH được giữ nguyên 100%, đồng thời giao diện mở khóa lại đầy đủ các mục của Agency.
- **AC5 (Chặn chuyển `AGENCY → PERSONAL` khi đang có Client hoạt động)**: Nếu một Workspace `AGENCY` đang có thành viên giữ role `Client` (`ACTIVE`) hoặc có Task/Section đang chờ `Client` duyệt, yêu cầu đổi sang `"PERSONAL"` bị từ chối với mã lỗi `WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT` (`409 Conflict`).

### Chiến dịch Cá nhân, Công việc Độc lập & Tự duyệt 1 chạm
- **AC6 (Chiến dịch cá nhân không cần `MediaPackage`)**: Trong Workspace `PERSONAL`, người dùng có thể khởi tạo và triển khai (`deploy`) `MediaCampaign` mà không cần tạo hay duyệt `MediaPackage` trước, và không bị chặn bởi giới hạn số lượng hạng mục của gói.
- **AC7 (Tạo Công việc độc lập đủ 8 loại Task)**: Endpoint `POST /api/v1/workspaces/{workspaceId}/tasks/standalone` (và nút **"+ Tạo công việc mới"** trên UI) cho phép tạo trực tiếp bất kỳ loại nào trong 8 loại `TaskType` (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`) với `requiresClientApproval = false` và tự động khởi tạo danh mục Subtask chuẩn (`TaskCatalog`).
- **AC8 (Tự duyệt 1 chạm — `self-approve`)**: Endpoint `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/self-approve` cho phép `Owner`/`Manager` trong Workspace `PERSONAL` (hoặc trên Task có `requiresClientApproval = false`) chuyển nguyên tử toàn bộ `TaskSection` sang `INTERNAL_APPROVED`, toàn bộ `Subtask` sang `FINISHED`, và `Task` cha sang `FINISHED` (`lastSubmission.outcome = APPROVED`).
- **AC9 (Chặn `self-approve` trái phép)**: Nếu `Creator` (không phải `Owner`/`Manager` và không phải chủ không gian cá nhân) gọi `self-approve`, hoặc gọi `self-approve` trên Task của Workspace `AGENCY` có `requiresClientApproval = true`, Backend trả lỗi `FORBIDDEN` hoặc `TASK_SELF_APPROVE_NOT_ALLOWED`.
- **AC10 (Mở khóa Xuất bản / Gửi Newsletter / Xuất File sau `self-approve`)**: Ngay sau khi gọi `self-approve`, bài đăng `POST`/`SHORT_VIDEO` có thể đăng ngay hoặc lên lịch đăng (`PostSchedulePublishJob`), bản tin `EMAIL_NEWSLETTER` có thể gửi thật (`NewsletterService.send`), và các loại Task khác có thể xuất file PDF/DOCX chính thức (không bị đóng dấu "Bản nháp").

### Giao diện Thích ứng, Cộng tác Nhóm nhỏ & Đa nền tảng
- **AC11 (Sidebar & Tiến trình rút gọn ở chế độ `PERSONAL`)**: Khi đang ở Workspace `PERSONAL`, thanh Tiến trình (`SidebarProgressSection`) ẩn bước `1. Gói dịch vụ` và chỉ hiển thị 2 bước mở sẵn (`1. Kế hoạch & Chiến dịch`, `2. Công việc & Sáng tạo`); menu Sidebar ẩn các mục `/clients`, `/client-profile`, `/portal`, `/requests`.
- **AC12 (Dashboard Bệ phóng Sáng tạo Cá nhân)**: Khi đang ở Workspace `PERSONAL`, trang `/workspaces/:id/dashboard` ẩn `PackageStatusBanner` và hiển thị cụm **Personal Quick Launchpad** gồm 5 lối tắt hành động nhanh hoạt động chính xác.
- **AC13 (Kết nối MXH trực tiếp ở chế độ `PERSONAL`)**: Trong Workspace `PERSONAL`, `Owner`/`Manager` kết nối trực tiếp được tài khoản **Facebook, Instagram, TikTok, Threads** tại `/workspaces/:id/social-accounts` mà không cần thông qua tài khoản `Client`.
- **AC14 (Cộng tác nhóm nhỏ với `Creator`)**: Trong Workspace `PERSONAL`, `Owner` mời được thành viên khác vào làm `Creator`, giao `Subtask` có `subtaskRole`, và duyệt các phần do `Creator` nộp mà không cần `Client`.
- **AC15 (Trình xem 3 chế độ Notion Peek & Không giật Animation)**: Mở công việc từ danh sách tại `/workspaces/:id/tasks` hoạt động mượt mà ở cả 3 chế độ (`Side Peek`, `Center Modal`, `Full Page`), không bị hiện tượng phóng ra – thu vào – phóng ra lại (double-bounce), và có lớp nền mờ tập trung (`backdrop-blur-[2px]`).
- **AC16 (Hiển thị trên Mobile)**: Ứng dụng di động (`brandhub-mobile-app`) nhận diện đúng `workspaceMode = "PERSONAL"`, hiển thị badge Cá nhân và cho phép xem/duyệt nhanh công việc.

### Đa ngôn ngữ (`i18n`) & Giao diện Sáng/Tối (`Light/Dark Mode`)
- **AC17 (Song ngữ `vi` / `en` Key-Parallel 100%)**: Toàn bộ nhãn, mô tả, nút bấm, hộp thoại, thông báo thành công và mã lỗi mới đều dùng khóa i18n theo bảng tại **§13**, có mặt đồng thời trong cả `vi` và `en`, tuyệt đối không có chuỗi hardcode trong JSX/TSX.
- **AC18 (Chuẩn màu Light/Dark & Responsive Mobile/Tablet/Desktop)**: Toàn bộ thành phần giao diện mới sử dụng semantic token (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`, `brand-orange`) kèm biến thể `dark:`, đảm bảo độ tương phản chuẩn WCAG AA trên cả Light Mode và Dark Mode, và không bị tràn ngang ở màn hình Mobile (`375px`), Tablet (`768px`) và Desktop (`1440px`).

---

## 9. API Contract

Mọi response đều bọc trong `ApiResponse<T>`. Đường dẫn gốc `/api/v1`.

### 9.1. Mở rộng các Endpoint hiện có

| Endpoint hiện có | Thay đổi chi tiết | Quyền hạn |
| :--- | :--- | :--- |
| `POST /api/v1/agencies/{agencyId}/workspaces` (`WorkspaceController.createWorkspace`) | `CreateWorkspaceRequest` thêm `workspaceMode?: "AGENCY" \| "PERSONAL"` (mặc định `"AGENCY"`). Khi `workspaceMode == "PERSONAL"`, `managerId` và `brandName` trở thành tùy chọn (tự gán `managerId = currentUser.id` và `brandName = name` nếu null). | `Owner` |
| `GET /api/v1/agencies/{agencyId}/workspaces` & `GET /api/v1/workspaces/{workspaceId}` | `WorkspaceResponse` thêm trường `workspaceMode: "AGENCY" \| "PERSONAL"` và `isPersonalDefault: boolean` (đọc từ `workspaces.settings`). | Thành viên có quyền xem Workspace |
| `PUT /api/v1/workspaces/{workspaceId}` (`WorkspaceController.updateWorkspace`) | `UpdateWorkspaceRequest` thêm `workspaceMode?: "AGENCY" \| "PERSONAL"`. Kiểm tra chặn nếu chuyển `AGENCY → PERSONAL` khi đang có `Client` hoạt động (AC5). | `Owner`, `Manager` |
| `POST /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/deploy` (`MediaCampaignController`) | Khi Workspace có `workspaceMode == "PERSONAL"`, cho phép deploy mà không cần `Client` duyệt gói `MediaPackage`, bỏ kiểm tra trần hạng mục gói và mặc định gán `requiresClientApproval = false` cho các Task sinh ra. | `Owner`, `Manager` |

### 9.2. Các Endpoint Mới

| Method & Path | Mô tả chức năng | Quyền hạn |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/personal/bootstrap` | Khởi tạo 1 chạm (hoặc lấy lại) `Personal Hub` (`Agency`) + `Workspace` cá nhân mặc định (`workspaceMode = "PERSONAL"`). Hoàn toàn idempotent. | Mọi người dùng đã đăng nhập (`Owner`, `Manager`, `Creator`) |
| `POST /api/v1/workspaces/{workspaceId}/tasks/standalone` | Tạo trực tiếp một Công việc độc lập (`Standalone Task`) thuộc bất kỳ loại nào trong 8 loại `TaskType`, tự động sinh Subtask vai trò chuẩn (`TaskCatalog`) nếu `initRoleSubtasks = true`. | `Owner`, `Manager`, `Creator` trong Workspace |
| `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/self-approve` | Tự duyệt & hoàn tất 1 chạm: chuyển toàn bộ `TaskSection` sang `INTERNAL_APPROVED`, toàn bộ `Subtask` sang `FINISHED`, và đóng `Task` ở trạng thái `FINISHED` (`APPROVED`). | `Owner`, `Manager` (trong Workspace `PERSONAL` hoặc khi `requiresClientApproval == false`) |

### 9.3. Đặc tả Schema Request / Response JSON

#### 9.3.1. `POST /api/v1/workspaces/personal/bootstrap`
- **Request Body (`PersonalBootstrapRequest` — tùy chọn)**:
  ```json
  {
    "name": "Kênh TikTok & Blog Cá Nhân",
    "brandName": "Trí Trung Creator"
  }
  ```
- **Response (`200 OK` — `ApiResponse<WorkspaceResponse>`)**:
  ```json
  {
    "code": 1000,
    "message": "Success",
    "data": {
      "id": "9f8c6d12-4a11-4b23-9e70-123456789abc",
      "agencyId": "3a1b2c3d-0000-4111-8222-abcdef123456",
      "name": "Kênh TikTok & Blog Cá Nhân",
      "brandName": "Trí Trung Creator",
      "workspaceMode": "PERSONAL",
      "isPersonalDefault": true,
      "status": "ACTIVE",
      "timezoneConfig": "Asia/Ho_Chi_Minh",
      "managerId": "11111111-2222-3333-4444-555555555555"
    }
  }
  ```

#### 9.3.2. `POST /api/v1/workspaces/{workspaceId}/tasks/standalone`
- **Request Body (`CreateStandaloneTaskRequest`)**:
  ```json
  {
    "title": "Video ngắn giới thiệu đồ án truyền thông số",
    "type": "SHORT_VIDEO",
    "description": "Quay và dựng clip 60s đăng TikTok & Reels",
    "dueDate": "2026-11-25T17:00:00Z",
    "priority": "HIGH",
    "assigneeId": "11111111-2222-3333-4444-555555555555",
    "campaignId": null,
    "initRoleSubtasks": true
  }
  ```
- **Response (`201 Created` / `200 OK` — `ApiResponse<StandaloneTaskResponse>`)**:
  ```json
  {
    "code": 1000,
    "message": "Task created successfully",
    "data": {
      "id": "task-uuid-001",
      "workspaceId": "9f8c6d12-4a11-4b23-9e70-123456789abc",
      "campaignId": "personal-campaign-uuid",
      "title": "Video ngắn giới thiệu đồ án truyền thông số",
      "type": "SHORT_VIDEO",
      "status": "TODO",
      "priority": "HIGH",
      "requiresClientApproval": false,
      "assigneeId": "11111111-2222-3333-4444-555555555555",
      "subtaskCount": 4
    }
  }
  ```

#### 9.3.3. `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/self-approve`
- **Request Body (`SelfApproveTaskRequest` — tùy chọn)**:
  ```json
  {
    "note": "Đã kiểm tra nội dung cá nhân và sẵn sàng đăng bài"
  }
  ```
- **Response (`200 OK` — `ApiResponse<TaskWorkflowSnapshot>`)**:
  - Trả về snapshot công việc đã ở trạng thái `status = "FINISHED"`, `lastSubmission.outcome = "APPROVED"`, toàn bộ `sections` ở trạng thái `INTERNAL_APPROVED`.

---

## 10. Error Handling (Xử lý Mã lỗi)

| Tình huống lỗi | HTTP Status | `ErrorCode` | Khóa thông báo (`i18n key`) |
| :--- | :---: | :--- | :--- |
| Chuyển `workspaceMode` từ `AGENCY` sang `PERSONAL` khi đang có `Client` hoạt động hoặc có Task đang chờ `Client` duyệt | `409 Conflict` | `WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT` | `workspace.mode.errors.blockedByActiveClient` |
| Gọi `self-approve` trên một Task bắt buộc cần `Client` duyệt (`requiresClientApproval = true` trong Workspace `AGENCY`) | `400 Bad Request` | `TASK_SELF_APPROVE_NOT_ALLOWED` | `tasks.selfApprove.errors.notAllowedInClientFlow` |
| Người dùng chỉ có role `Creator` (không phải `Owner`/`Manager`) gọi `self-approve` hoặc đổi `workspaceMode` | `403 Forbidden` | `FORBIDDEN` / `ACCESS_DENIED` | `tasks.selfApprove.errors.forbidden` |
| Gọi tạo `Standalone Task` với `type` không nằm trong 8 loại `TaskType` chuẩn hoặc `title` rỗng | `400 Bad Request` | `VALIDATION_ERROR` | `tasks.quickCreate.errors.invalidInput` |
| Gọi `self-approve` trên một Task đã bị hủy (`CANCELLED`) | `400 Bad Request` | `TASK_INVALID_STATUS_TRANSITION` | `tasks.selfApprove.errors.cancelledTask` |

---

## 11. Edge Cases (Các Trường hợp Biên & Xử lý)

1. **Bấm đúp chuột / Gọi đồng thời `POST /workspaces/personal/bootstrap` (Concurrent Bootstrap Race Condition)**:
   - Xử lý: Khóa theo `userId` (hoặc kiểm tra lại trong transaction) và định danh `logoIcon = "personal-studio"`. Nếu request thứ 2 vào ngay sau khi request thứ 1 vừa commit, hệ thống phát hiện Workspace `PERSONAL` đã tồn tại và trả về đúng bản ghi đó thay vì tạo 2 Personal Studio trùng nhau.
2. **Dữ liệu Workspace cũ trong DB có `settings = null`, `settings = ""` hoặc JSON không hợp lệ**:
   - Xử lý: Helper `WorkspaceSettingsHelper.extractWorkspaceMode(settings)` bọc `try/catch` an toàn: bất kỳ chuỗi rỗng, `null` hay JSON lỗi nào đều trả về mặc định `WorkspaceMode.AGENCY`, tuyệt đối không bao giờ ném `NullPointerException` hay `JsonProcessingException`.
3. **Cập nhật `workspaces.settings` khi đổi `workspaceMode` không làm mất các khóa cài đặt khác**:
   - Xử lý: `WorkspaceSettingsHelper.mergeWorkspaceMode(existingJson, mode)` parse `ObjectNode` từ `existingJson`, chỉ ghi đè trường `"workspaceMode"` và bảo toàn mọi khóa cấu hình khác có sẵn trong JSONB.
4. **Chuyển đổi `PERSONAL → AGENCY` khi đang có các Task đã `Self-Approve` hoặc đang `IN_PROGRESS`**:
   - Xử lý: Các Task đã `FINISHED` giữ nguyên trạng thái đã duyệt. Các Task đang `TODO`/`IN_PROGRESS` giữ nguyên `requiresClientApproval = false` cho đến khi `Manager` chủ động bật cờ yêu cầu `Client` duyệt hoặc mời `Client` mới vào Workspace.
5. **Chuyển đổi `AGENCY → PERSONAL` khi đã có `Client` trong Workspace**:
   - Xử lý: Backend chặn bằng mã lỗi `WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT` và hướng dẫn `Owner`/`Manager` gỡ quyền `Client` hoặc tạo một Workspace `PERSONAL` mới để tránh làm ẩn mất quyền truy cập của khách hàng đang hợp tác.
6. **Xóa hoặc Lưu trữ (Archive) Workspace `PERSONAL` mặc định**:
   - Xử lý: Nếu người dùng xóa/archive Workspace `PERSONAL` cũ rồi sau đó bấm lại nút **"Không gian Cá nhân (Personal Studio)"**, hàm `bootstrap` chỉ tìm các Workspace có `status == ACTIVE`; vì vậy hệ thống sẽ tự động tạo một Workspace `PERSONAL` mới bên trong cùng `Personal Hub Agency` sẵn có của người dùng (không tạo lại `Agency` mới, giữ nguyên ví AI Credit).
7. **Tạo `Standalone Task` khi Workspace `PERSONAL` chưa có bất kỳ `MediaCampaign` nào**:
   - Xử lý: Nếu các truy vấn thống kê/timeline yêu cầu `campaignId`, `StandaloneTaskService` tự động khởi tạo ngầm (lazy-init) một chiến dịch khung mang tên `"Kế hoạch Công việc Cá nhân"` (`status = ACTIVE`) cho Workspace `PERSONAL` đó và gắn Task vào, giúp Task hiển thị đầy đủ trên cả `TaskList`, `Calendar`, `Kanban` và `CampaignTimelineGrid`.
8. **Gọi `Self-Approve` trên Task có một số `TaskSection` chưa từng được lưu nháp (chưa có document trong `task_sections`)**:
   - Xử lý: `SectionService.selfApproveAllSections(task)` tự động khởi tạo document cho các phần còn thiếu với trạng thái `INTERNAL_APPROVED` (`revision = 1`) để mọi truy vấn kiểm tra `allSectionsApproved` đều thỏa mãn 100%.
9. **Gọi `Self-Approve` nhiều lần liên tiếp trên cùng một Task đã `FINISHED`**:
   - Xử lý: Idempotent — nếu Task đã `FINISHED` và `lastSubmission.outcome == APPROVED`, trả về ngay snapshot hiện tại (`200 OK`) mà không tạo bản ghi lịch sử dư thừa.
10. **Sử dụng AI Studio trong Workspace `PERSONAL` khi hết AI Credit miễn phí**:
    - Xử lý: Áp dụng đúng cơ chế `CreditReservationService` của `Personal Hub Agency`. Người dùng có thể bấm mua thêm Credit hoặc nâng cấp gói qua SePay (VietQR) ngay từ Personal Hub.
11. **Kết nối Tài khoản Mạng xã hội (`SocialAccount`) trong Workspace `PERSONAL`**:
    - Xử lý: Trong Workspace `PERSONAL`, `Owner` và `Manager` được cấp toàn quyền thực hiện OAuth kết nối/ngắt kết nối cho cả 4 nền tảng (**Facebook, Instagram, TikTok, Threads**).
12. **Người dùng vừa là thành viên (`Creator`/`Manager`) ở một Agency công ty, vừa bấm mở `Personal Studio`**:
    - Xử lý: Khi chuyển sang `Personal Studio`, Frontend tự động đồng bộ `currentAgencyId` sang `agencyId` của `Personal Hub` để số dư AI Credit trên thanh Sidebar và quyền `Owner` hiển thị đúng theo không gian cá nhân của họ.

---

## 12. UI States & Chuẩn Hiển thị (Loading, Empty, Error, Theme, Responsive)

1. **Trạng thái Nút Khởi tạo `Personal Studio` (`Bootstrap State`)**:
   - **Idle**: Nút/thẻ nổi bật có icon `Sparkles` / `UserCheck`, viền `border-brand-orange/30`, nền nhẹ `bg-brand-orange/5 dark:bg-brand-orange/10`.
   - **Loading**: Khi đang gọi `bootstrapPersonal()`, hiển thị spinner kèm chữ *"Đang chuẩn bị không gian cá nhân..."* và khóa nút để tránh bấm đúp.
   - **Error**: Nếu mất mạng, hiển thị toast lỗi kèm nút *"Thử lại"*.
2. **Trạng thái `Personal Quick Launchpad` trên Dashboard**:
   - Hiển thị 5 thẻ hành động nhanh trên lưới responsive: `grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3`.
   - Khi bấm vào thẻ tạo bài đăng / video / sự kiện: mở ngay `QuickCreateTaskDialog` với loại `TaskType` tương ứng đã được chọn sẵn.
3. **Trạng thái Hộp thoại Tạo Công việc Nhanh (`QuickCreateTaskDialog`)**:
   - Bộ chọn 8 loại công việc dạng lưới trực quan (`grid-cols-2 sm:grid-cols-4 gap-2`), mỗi ô có icon, tên loại công việc và viền sáng lên khi được chọn.
   - Hỗ trợ валиdation tại chỗ khi tiêu đề trống; khi đang lưu hiển thị trạng thái loading trên nút submit.
4. **Trạng thái Nút Tự duyệt 1 chạm (`Self-Approve Button`)**:
   - Chỉ hiển thị khi `isPersonalMode === true` (hoặc `task.requiresClientApproval === false`) và người dùng là `Owner`/`Manager`, khi Task chưa ở trạng thái `FINISHED`.
   - Sau khi bấm: hiển thị hiệu ứng loading ngắn, cập nhật badge trạng thái Task sang **`Hoàn tất (Finished)`** màu xanh ngọc (`emerald`) và hiển thị ngay nút **Đăng bài / Lên lịch / Xuất file**.
5. **Chuẩn Light/Dark Mode & Responsive**:
   - Tuyệt đối không dùng mã màu hex cứng gây chói hoặc mất chữ khi đổi theme; sử dụng hệ thống biến CSS chuẩn của dự án (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`, `bg-primary`, `text-primary-foreground`).

---

## 13. Danh mục Khóa Đa ngôn ngữ Song ngữ (`vi` / `en` Key-Parallel Inventory)

Mọi khóa dưới đây phải được khai báo đồng thời trong `src/i18n/locales/vi/*.json` và `src/i18n/locales/en/*.json`:

| Namespace & Key | Giá trị Tiếng Việt (`vi`) | Giá trị Tiếng Anh (`en`) |
| :--- | :--- | :--- |
| `workspace.mode.label` | `Chế độ vận hành` | `Workspace Mode` |
| `workspace.mode.personal.title` | `Cá nhân / Dự án độc lập` | `Personal / Solo Project` |
| `workspace.mode.personal.badge` | `Cá nhân` | `Personal` |
| `workspace.mode.personal.description` | `Tối ưu cho nhà sáng tạo cá nhân, freelancer, đồ án sinh viên & nhóm nhỏ. Không cần gói dịch vụ hay bước chờ khách hàng duyệt.` | `Optimized for solo creators, freelancers, student projects & small teams. No media package or client approval gates required.` |
| `workspace.mode.agency.title` | `Khách hàng Agency (B2B)` | `Agency Client (B2B)` |
| `workspace.mode.agency.badge` | `Agency` | `Agency` |
| `workspace.mode.agency.description` | `Quy trình chuẩn 3 bước (Gói dịch vụ → Chiến dịch → Công việc) kèm Cổng Khách hàng và phê duyệt 2 cấp.` | `Full 3-step workflow (Media Package → Campaign → Tasks) with Client Portal and two-stage approval.` |
| `workspace.mode.switchToAgency.cta` | `Nâng cấp sang chế độ Agency` | `Switch to Agency Mode` |
| `workspace.mode.switchToPersonal.cta` | `Chuyển sang chế độ Cá nhân` | `Switch to Personal Mode` |
| `workspace.mode.switchSuccess` | `Đã cập nhật chế độ không gian làm việc thành công.` | `Workspace mode updated successfully.` |
| `workspace.mode.errors.blockedByActiveClient` | `Không thể chuyển về chế độ Cá nhân khi đang có Khách hàng (Client) hoạt động hoặc công việc chờ Khách hàng duyệt.` | `Cannot switch to Personal mode while there is an active Client or tasks awaiting Client approval.` |
| `agency.personalStudio.cta` | `Không gian Cá nhân (Personal Studio)` | `Personal Studio` |
| `agency.personalStudio.subtitle` | `Vào thẳng bàn làm việc sáng tạo cá nhân chỉ với 1 chạm — không cần thiết lập công ty.` | `Jump straight into your personal creative studio in 1 click — no company setup needed.` |
| `agency.personalStudio.bootstrapping` | `Đang khởi tạo không gian cá nhân...` | `Setting up your personal studio...` |
| `workspace.launchpad.title` | `Bệ phóng Sáng tạo Cá nhân` | `Personal Creative Launchpad` |
| `workspace.launchpad.subtitle` | `Bắt đầu nhanh bài viết, video ngắn, kế hoạch sự kiện hoặc khám phá xu hướng mà không cần qua thủ tục hợp đồng.` | `Quickly start a social post, short video, event plan, or explore trends without contract formalities.` |
| `workspace.launchpad.actions.newPost` | `Viết bài đăng MXH` | `New Social Post` |
| `workspace.launchpad.actions.newVideo` | `Kịch bản & Video ngắn` | `Short Video & Script` |
| `workspace.launchpad.actions.newPlan` | `Sự kiện / PR / Workshop` | `Event / PR / Workshop` |
| `workspace.launchpad.actions.exploreTrends` | `Khám phá Xu hướng AI` | `Explore AI Trends` |
| `workspace.launchpad.actions.connectSocial` | `Kết nối Kênh MXH` | `Connect Social Channels` |
| `tasks.quickCreate.cta` | `Tạo công việc mới` | `Create New Task` |
| `tasks.quickCreate.dialogTitle` | `Tạo nhanh công việc & nội dung` | `Quick Create Task & Content` |
| `tasks.quickCreate.dialogSubtitle` | `Chọn loại nội dung bạn muốn thực hiện. Hệ thống sẽ chuẩn bị sẵn khung soạn thảo tương ứng.` | `Choose the content type you want to create. We will prepare the matching editor sections automatically.` |
| `tasks.quickCreate.fields.title` | `Tiêu đề công việc` | `Task Title` |
| `tasks.quickCreate.fields.titlePlaceholder` | `VD: Bài đăng ra mắt bộ sưu tập mùa thu...` | `e.g., Launch post for Autumn collection...` |
| `tasks.quickCreate.fields.type` | `Loại nội dung (8 định dạng)` | `Content Type (8 formats)` |
| `tasks.quickCreate.fields.dueDate` | `Hạn hoàn thành` | `Due Date` |
| `tasks.quickCreate.fields.priority` | `Mức độ ưu tiên` | `Priority` |
| `tasks.quickCreate.fields.description` | `Ghi chú / Mục tiêu ngắn` | `Notes / Brief Objective` |
| `tasks.quickCreate.submitAndView` | `Tạo công việc` | `Create Task` |
| `tasks.quickCreate.submitAndEdit` | `Tạo & Mở trình soạn thảo` | `Create & Open Editor` |
| `tasks.selfApprove.cta` | `Hoàn tất & Duyệt ngay` | `Complete & Approve Now` |
| `tasks.selfApprove.confirmTitle` | `Hoàn tất và duyệt công việc này?` | `Complete and approve this task now?` |
| `tasks.selfApprove.confirmDesc` | `Toàn bộ các phần nội dung sẽ được đánh dấu hoàn tất để bạn có thể đăng bài, gửi bản tin hoặc xuất file ngay lập tức.` | `All content sections will be marked as approved so you can publish, send newsletters, or export files immediately.` |
| `tasks.selfApprove.success` | `Đã hoàn tất và duyệt công việc! Bạn có thể xuất bản nội dung ngay.` | `Task completed and approved! You can now publish or export your content.` |
| `nav.progress.personalCampaign` | `1. Kế hoạch & Chiến dịch` | `1. Plan & Campaign` |
| `nav.progress.personalTasks` | `2. Công việc & Sáng tạo` | `2. Tasks & Creation` |

---

## 14. Definition of Done (Tiêu chuẩn Hoàn thành)

1. Backend hỗ trợ đầy đủ enum `WorkspaceMode` (`AGENCY`, `PERSONAL`), đọc/ghi an toàn trong JSONB `workspaces.settings`, và cung cấp 3 API mới/mở rộng: `POST /api/v1/workspaces/personal/bootstrap`, `POST /api/v1/workspaces/{id}/tasks/standalone`, `POST /api/v1/workspaces/{id}/tasks/{taskId}/self-approve`.
2. Tạo Chiến dịch và Công việc trong chế độ `PERSONAL` hoạt động trơn tru cho cả 8 loại `TaskType` mà không bị chặn bởi `MediaPackage` hay `Client`.
3. Giao diện Web (`brandhub-web`) hiển thị nút khởi tạo `Personal Studio`, bộ chọn `workspaceMode` khi tạo/cấu hình Workspace, `Sidebar` & `ProgressStepper` thích ứng, `Personal Quick Launchpad` trên Dashboard, `QuickCreateTaskDialog` tại trang Công việc, và nút `Hoàn tất & Duyệt ngay (Self-Approve)`.
4. Trình xem 3 chế độ (`Side Peek`, `Center Modal`, `Full Page`) hoạt động mượt mà, không bị giật animation khi mở, có làm mờ nền.
5. Đầy đủ khóa ngôn ngữ `vi` và `en` theo §13, hiển thị chuẩn trên cả Light/Dark mode và Mobile/Tablet/Desktop.
6. Toàn bộ Unit Test, Integration Test (`mvn test`) và Frontend Type-check / Vitest / Vite Build (`npm run type-check`, `npm test -- --run`, `npx vite build`) đều PASS 100%.
7. Tài liệu BA trong `docs/ba/` được cập nhật đồng bộ với kiến trúc Hybrid và 141 FR của hệ thống.

---

## 15. Out of Scope (Ngoài Phạm vi)

- Không tạo thêm Role hệ thống thứ 7 ngoài 6 Role chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
- Không đưa lại các tính năng đã loại bỏ theo `AGENTS.md` (Livestream tasks/scripts, Downgrade Plan, Copyright/Plagiarism check, Zalo OA, VNPay/Stripe).
- Không thay đổi bảng giá AI Credit hay cơ chế cổng thanh toán SePay / PayOS hiện có.

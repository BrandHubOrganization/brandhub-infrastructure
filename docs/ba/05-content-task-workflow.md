# 05 — Content & Task Workflow

> **BA hiện hành 2026-11-10 — Subtask theo vai trò & duyệt từng phần (9 loại task):** Mỗi loại task (trừ LIVESTREAM) có danh mục subtask chuẩn cố định trong code; mỗi vai trò sở hữu một hoặc nhiều phần (section) của trình soạn riêng loại đó. Phần có 2 loại hiển thị: **O** (output — Client thấy & duyệt) và **I** (internal — chỉ agency thấy). Duyệt diễn ra **theo từng phần**, không còn theo cả task: `DRAFT/RETURNED → SUBMITTED → INTERNAL_APPROVED (Manager/supervisor) → CLIENT_APPROVED (Client, chỉ phần O, chỉ khi task requiresClientApproval=true)`. Khi mọi phần O đã `CLIENT_APPROVED`, task cha coi như đã duyệt — bước `reviewStep=CLIENT` task-level cũ (mục 4 bên dưới) được **thay thế hẳn** cho task có subtask theo vai trò; task cũ (subtask không vai trò, tạo trước tính năng này) vẫn giữ nguyên luồng duyệt cũ ở mục 4. Chi tiết đầy đủ 9 danh mục subtask, ma trận quyền, vòng đời phần, API, quota Newsletter: [spec.md](../feature/subtask-role-workspaces/spec.md). Xem mục 3 bên dưới cho toàn bộ 9 loại task cập nhật.

> **TODO chưa làm (kiểm tra 2026-11-13):** báo cáo SRS 141 FR chính thức (`brandhub-final_report/report3/Report3_Software Requirement Specification.docx`, mục 3.6) **chưa có FR nào** cho 6 loại task mới hay mô hình duyệt theo phần — đúng kế hoạch đã ghi ở [spec.md §15](../feature/subtask-role-workspaces/spec.md), làm sau khi code nghiệm thu. Checklist chi tiết ở đó.

> **BA hiện hành 2026-10-18 — FR 3.6.9:** Creator được giao → Manager → một Client active bất kỳ nếu requiresClientApproval. Không QC. Giữ TODO/IN_PROGRESS/IN_REVIEW/FINISHED/CANCELLED và reviewStep riêng. POST dùng `/editor`, một bản nội dung hiện tại được khóa sửa khi IN_REVIEW; không snapshot/diff nội dung lượt cũ. Reject về IN_PROGRESS; gửi lại lượt mới từ Manager. Creator chỉ thu hồi trước Manager decision. Thiếu Client active thì chặn submit và báo Manager bổ sung, không tự bỏ bước. FINISHED không tự publish. Quy tắc này thay thế phần Approval/QC/ngày đăng dự kiến trong các ghi chú lịch sử bên dưới. [Spec v3 và kế hoạch giai đoạn](../feature/content-task-workflow/3-6-9-approval-sequence-creator-manager-client/spec.md). Code/API và UI giai đoạn 3–5 đã kiểm thử cô lập; feature gate vẫn tắt, Atlas chưa APPLY và chưa nghiệm thu end-to-end/rollout.

> **BA mới đã chốt 2026-10-15:** Task chỉ còn TODO / IN_PROGRESS / IN_REVIEW / CANCELLED / FINISHED. Giao việc là metadata, không còn bước DETAIL_IDENTIFIED/ASSIGNED. Phải có mô tả + deadline hợp lệ trước giao; Creator được giao bấm bắt đầu mới IN_PROGRESS; sau đó Manager khóa sửa/giao lại. IN_REVIEW giữ QC → Manager → Client khi được cấu hình; reject về IN_PROGRESS, duyệt lại từ QC nếu có. Approval do thành viên khác triển khai. Autosave on-blur và action list chỉ assignment/deadline/start. Ghi chú mới này thay thế vòng đời Task lịch sử bên dưới; xem [spec mới](../feature/content-task-workflow/task-five-state-inline-edit/spec.md).

> [<< Về Overview](00-overview.md)

> **Xác nhận mới nhất 2026-10-14 — FR 3.6.1/2/3 và tích hợp Approval:** tách hạn hoàn thành mọi Task khỏi ngày đăng dự kiến POST; Manager chỉ sửa yêu cầu/giao lại trước lần Creator bắt đầu đầu tiên; đợt này làm khung đầu vào cho 5 loại Task, không làm thay nội dung chuyên biệt. Vẫn cho comment trên COMPLETED/CANCELLED; mention và ảnh JPEG/PNG/WebP, tối đa 5 ảnh × 5 MB/comment. Q13 mới nhất: Client active xem/bình luận mọi Task cùng Workspace, kể cả Task thủ công và cũ; không phân biệt nội bộ/thường. Comment không phụ thuộc requiresClientApproval, cờ này chỉ cấu hình bước Client duyệt kết quả. Resubmit sau reject duyệt lại từ QC nếu có (không có thì Manager), giữ nguyên lịch sử audit. Các đoạn cũ về 3 loại/nhân sự ở bước Identify chỉ là nền lịch sử; chi tiết và câu hỏi còn mở ở [roadmap](../feature/content-task-workflow/task-detail-assignment-comments-roadmap.md). Người dùng/lead cần thông báo các chủ module liên quan; không tự sửa code của họ.

## 1. Nguồn gốc Task trong backlog

**Q13 confirmed 2026-10-14 — thay phần phân quyền Q6/Q9 và quy tắc Q12:** Client active được xem
và bình luận mọi Task trong đúng Workspace, kể cả Task Manager tạo thủ công và Task cũ.
Không có phân biệt nội bộ/thường hoặc field/default/bộ chọn visibility; Q12 cũ không còn áp dụng.
requiresClientApproval=true/false chỉ quyết định chuỗi duyệt kết quả, không quyết định quyền xem/bình luận.
Giữ quyền sửa/giao việc/editor theo vai trò; membership/scope và quyền riêng của upload DRAFT vẫn kiểm tra.
Không tự sửa dữ liệu legacy; marker start chỉ ảnh hưởng mutation quản lý, không chặn đọc/bình luận.

**Bổ sung Q9–Q11 confirmed 2026-10-14:** Phần phân quyền/default Task Q9 đã được Q13 thay thế; mọi nguồn Task cùng Workspace cho Client active xem/bình luận. Task Campaign đặt hạn trong max(today,start)..end theo múi giờ Workspace; ngày đăng POST không trước dueDate và trong Campaign. Task thủ công không Campaign có hạn từ hôm nay. Notification comment chỉ in-app cho mentions, assignee, QC, Manager; bỏ trùng/tác giả/người không còn quyền, Client chỉ nhận khi mention. Q8 confirmed: Creator bấm Bắt đầu làm mới chuyển ASSIGNED → IN_PROGRESS; mở trang/editor không tính. Dấu mốc lần đầu giữ nguyên sau reject.

Backlog KHÔNG đóng — có 3 nguồn tạo Task:

1. **Từ Media Campaign approve** — xem [04-media-package-campaign.md](04-media-package-campaign.md) mục 3.
2. **Từ Content Request được accept** — xem [04-media-package-campaign.md](04-media-package-campaign.md) mục 4.
3. **[CONFIRMED 2026-09-14]** Manager tự do thêm Task thủ công vào backlog bất cứ lúc nào — không bắt buộc phải có nguồn gốc từ Campaign hay Content Request (ví dụ sửa bài cũ, họp chuẩn bị, v.v.; theo Q13 Client cùng Workspace vẫn xem/bình luận được)

## 2. Vòng đời 1 Task

### 3.6.1 — Identify Task Detail
- Khi Task còn ở backlog (vừa sinh ra từ Campaign), nó chỉ có: tên công việc, tiêu đề, yêu cầu đầu ra — **chưa cụ thể ai làm, làm gì**.
- Manager thêm đầy đủ: người thực hiện, ngày đăng, yêu cầu chi tiết, và **các field khác tùy theo loại công việc** (Post/Livestream/Survey — xem mục 3).
- Role: MANAGER.

### 3.6.2 — Assign Task To Creator
- Gắn công việc cho Creator active; cần mô tả và dueDate hợp lệ, Task vẫn TODO. Không giao QC. Manager chỉ sửa/giao lại trước lần Creator bắt đầu đầu tiên; reject/withdraw không mở lại quyền này.
- Role: MANAGER.

### 3.6.3 — Add Comments On Task
- Đưa ra nhận xét, yêu cầu chỉnh sửa trên task.
- Role: CREATOR, CLIENT, MANAGER.

## 3. Các loại Task — dùng chung khung workflow

**BA hiện hành 2026-11-10 — 9 loại task, danh mục subtask & duyệt theo phần:** thay thế hoàn toàn mô tả "3 loại nội dung" lịch sử bên dưới (giữ Loại 1–3 cũ ở cuối mục này chỉ để tra cứu lịch sử publishing/AI, không còn là danh sách đầy đủ). Nguồn sự thật: [spec.md](../feature/subtask-role-workspaces/spec.md) — mọi field/role đã chốt với user 2026-11-10, khớp code `TaskCatalog.java`.

Mỗi loại task (trừ LIVESTREAM — ngoài phạm vi theo AGENTS.md) có **danh mục subtask chuẩn cố định trong code**: mỗi vai trò (`subtaskRole`) sở hữu một hoặc nhiều **phần (section)** của trình soạn riêng loại đó. Cột "Hiển thị": **O** = output (Client thấy & duyệt sau khi Manager duyệt nội bộ), **I** = internal (chỉ agency thấy, Client không bao giờ thấy). Quy trình duyệt từng phần: xem mục 4a.

### 3.1 POST — Bài đăng mạng xã hội (5 vai trò, trình soạn `/editor`)

| subtaskRole | Tên vai trò | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `POST_RESEARCH` | Nghiên cứu / Phỏng vấn | `POST.BRIEF` | ghi chú phỏng vấn, trích dẫn nguồn, file tư liệu (Material) | I |
| `POST_CONTENT` | Viết content | `POST.CAPTION` | caption, hashtag, CTA | O |
| `POST_MEDIA` | Media (quay/chụp/thiết kế) | `POST.MEDIA` | danh sách media, watermark | O |
| `POST_EDITING` | Biên tập | `POST.CAPTION` (chung với Content) | sửa caption/hashtag — chỉ sau khi Content đã nộp (phần ở `SUBMITTED` trở lên) | O |
| `POST_PUBLISHING` | Đăng bài | `POST.CHANNELS` | kênh đăng (Facebook/Instagram/TikTok/Threads), lịch đăng, nút publish | O |

Viết content/tạo ảnh-video AI/watermark/hashtag: xem thêm mục 6, 7.

### 3.2 SHORT_VIDEO — Video ngắn (mới; dùng lại trình soạn POST + phần Kịch bản)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `VIDEO_SCRIPT` | Ý tưởng & Kịch bản | `VIDEO.SCRIPT` | ý tưởng, kịch bản theo cảnh (cảnh, lời thoại, ghi chú hình ảnh, thời lượng) | O |
| `VIDEO_SHOOT` | Quay | `VIDEO.SHOOT` | slot tự do, chưa có schema — chờ module quay/dựng video riêng | I |
| `VIDEO_EDIT` | Dựng / hậu kỳ | `VIDEO.EDIT` | slot tự do, chưa có schema | O |
| `VIDEO_PUBLISH` | Caption & Đăng | `VIDEO.CAPTION`, `VIDEO.CHANNELS` | như POST.CAPTION + POST.CHANNELS; kênh giới hạn TikTok, Instagram Reels, Facebook Reels | O |

Quay/dựng video và mọi chức năng sửa video trong app: **ngoài phạm vi** (module riêng, spec chỉ chừa key `VIDEO.SHOOT`/`VIDEO.EDIT`).

### 3.3 SURVEY — Khảo sát (trình soạn hiện có: form builder)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `SURVEY_DESIGN` | Thiết kế bảng hỏi | `SURVEY.FORM` | câu hỏi (dùng form builder hiện có) | O |
| `SURVEY_DISTRIBUTE` | Phân phối & thu thập | `SURVEY.DISTRIBUTION` | link public, kênh phát, hạn đóng, chỉ tiêu số phản hồi | O |
| `SURVEY_ANALYSIS` | Phân tích & báo cáo | `SURVEY.REPORT` | insight, kết luận, đề xuất + số liệu từ phân tích khảo sát | O |

### 3.4 EVENT_PLAN — Kế hoạch sự kiện (trình soạn mới, 5 vai trò)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `EVENT_AGENDA` | Concept & Agenda | `EVENT.AGENDA` | concept, mục tiêu, thời gian/địa điểm dự kiến, agenda (giờ, hạng mục, phụ trách) | O |
| `EVENT_LOGISTICS` | Hậu cần & Địa điểm | `EVENT.LOGISTICS` | venue, vendor (tên, hạng mục, chi phí VND, liên hệ), ngân sách tổng, checklist vật tư | I |
| `EVENT_PROMOTION` | Truyền thông sự kiện | `EVENT.PROMOTION` | kế hoạch truyền thông, danh sách khách mời (tên, đơn vị, trạng thái mời) | O |
| `EVENT_ONSITE` | Điều phối tại chỗ | `EVENT.RUNSHEET` | run-sheet (giờ, việc, người phụ trách), phân công nhân sự | I |
| `EVENT_REPORT` | Báo cáo sau sự kiện | `EVENT.REPORT` | kết quả, số khách tham dự, ảnh (Material), bài học | O |

### 3.5 PRESS_RECOMMENDATION — Báo chí (trình soạn mới, **chỉ ghi nhận, không gửi mail**)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `PRESS_MEDIA_LIST` | Lập danh sách báo | `PRESS.MEDIA_LIST` | tên báo, chuyên mục, nhà báo, email/điện thoại, ghi chú | I |
| `PRESS_RELEASE` | Viết thông cáo | `PRESS.RELEASE` | tiêu đề, sapo, nội dung, file đính kèm (Material) | O |
| `PRESS_PITCHING` | Liên hệ & pitching | `PRESS.CONTACT_LOG` | nhật ký liên hệ (ngày, báo, người liên hệ, kênh, kết quả) | I |
| `PRESS_TRACKING` | Theo dõi đưa tin | `PRESS.COVERAGE` | báo, link bài, ngày đăng, ảnh chụp bài (Material) | O |

Xuất file: thông cáo báo chí xuất **DOCX**, chỉ gồm phần output, đóng dấu "Bản nháp" nếu chưa Client duyệt.

### 3.6 KOL_BOOKING — KOL/Influencer (mới, **chỉ ghi nhận, KOL không có tài khoản, không thanh toán**)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `KOL_SOURCING` | Tìm & đề xuất KOL | `KOL.SHORTLIST` | tên, kênh (4 nền tảng), link, follower, tỉ lệ tương tác, lý do chọn | O |
| `KOL_NEGOTIATION` | Đàm phán | `KOL.DEAL` | KOL đã chọn, giá thỏa thuận (VND, **chỉ ghi nhận tham khảo, không tích hợp billing/invoice**), hạng mục deliverable, điều khoản | I |
| `KOL_BRIEF` | Brief cho KOL | `KOL.BRIEF` | key message, do/don't, hashtag bắt buộc, deadline đăng | O |
| `KOL_CONTENT_REVIEW` | Duyệt nội dung KOL | `KOL.DRAFT` | bản nháp KOL gửi (agency tự tải lên: caption + media Material), ghi chú duyệt | O |
| `KOL_TRACKING` | Theo dõi & báo cáo | `KOL.REPORT` | link bài KOL, ngày đăng, view/like/comment/share nhập tay | O |

### 3.7 WORKSHOP (mới; khớp `PackageServiceType.WORKSHOP_SUPPORT`)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `WORKSHOP_PROGRAM` | Nội dung chương trình | `WORKSHOP.PROGRAM` | chủ đề, agenda, slide/tài liệu (Material) | O |
| `WORKSHOP_SPEAKER` | Diễn giả | `WORKSHOP.SPEAKERS` | tên, chức danh, chủ đề, trạng thái mời (INVITED/CONFIRMED/DECLINED) | O |
| `WORKSHOP_LOGISTICS` | Hậu cần | `WORKSHOP.LOGISTICS` | hình thức (offline/online), địa điểm hoặc phòng online (dùng lại phòng họp Google Meet hiện có), chi phí | I |
| `WORKSHOP_REGISTRATION` | Đăng ký & truyền thông | `WORKSHOP.REGISTRATION` | form đăng ký (dùng lại form builder Survey) + link public, kế hoạch truyền thông | O |
| `WORKSHOP_REPORT` | Tổng kết | `WORKSHOP.REPORT` | số đăng ký/tham dự, feedback, ảnh, bài học | O |

### 3.8 EMAIL_NEWSLETTER (mới, **gửi thật** qua hạ tầng Mail Template sẵn có — xem mục 9)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `EMAIL_CONTENT` | Viết nội dung | `EMAIL.CONTENT` | subject, preheader, nội dung khối (dùng block builder Mail Template) | O |
| `EMAIL_DESIGN` | Thiết kế template | `EMAIL.DESIGN` | layout, màu/logo thương hiệu Client | O |
| `EMAIL_SEND` | Danh sách & lịch gửi | `EMAIL.AUDIENCE` | nhóm người nhận (recipient group của Client), lịch gửi, nút gửi/test. **Client xác nhận gửi cho ai, khi nào** | O |
| `EMAIL_REPORT` | Báo cáo | `EMAIL.REPORT` | số đã gửi/thành công/lỗi-bounce/huỷ đăng ký lấy từ mail batch thật; ô nhận xét. **Không làm tracking open/click.** | O |

**Quy tắc riêng EMAIL_NEWSLETTER (chốt 2026-11-10):**
- Gửi chỉ khi `EMAIL.CONTENT` và `EMAIL.DESIGN` đã `CLIENT_APPROVED` (hoặc `INTERNAL_APPROVED` nếu task không yêu cầu Client duyệt).
- Quota Newsletter **tách riêng hoàn toàn khỏi quota mail hệ thống** (OTP, thông báo...): quota tháng theo gói — BASIC 1.000 / PRO 10.000 / ENTERPRISE 50.000 email/tháng, tính theo **agency** (mọi workspace/Client của agency dùng chung). Vượt quota → chặn gửi, báo số còn lại.
- Import CSV danh sách người nhận bắt buộc cột `email, name, consent`; dòng không `consent=true/yes/1` bị loại; email trong suppression bị loại.
- Mỗi mail có link unsubscribe; **huỷ đăng ký theo Client** — người nhận huỷ ở 1 workspace thì bị chặn mọi Newsletter của Client đó ở **mọi workspace** của agency (khác suppression mail hệ thống vốn theo workspace).
- Gửi từ domain BrandHub, tên hiển thị = tên thương hiệu Client (không hỗ trợ domain riêng của Client/SPF-DKIM).
- Không gửi mail pitching tới nhà báo (đó là `PRESS_PITCHING`, chỉ ghi nhật ký nội bộ).

### 3.9 Lịch sử tham khảo (trước 2026-11-10, không còn đầy đủ)

> Giữ lại các mô tả cũ dưới đây chỉ để tra cứu chi tiết Livestream (ngoài phạm vi từ 2026-11-10) và các FR module chuyên biệt (AI, publishing) được tham chiếu từ các mục này — **không dùng làm danh sách loại task**, dùng mục 3.1–3.8 ở trên.

#### Livestream (FR 3.6.22 – 3.6.24, ngoài phạm vi từ 2026-11-10)
- **Write Livestream Idea** (3.6.22): điền ý tưởng và mục tiêu hướng tới. Role: MANAGER, CREATOR.
- **Write Livestream Script** (3.6.23): viết kịch bản đầy đủ cho 1 phiên livestream. Role: CREATOR.
- **Track Livestream Status** (3.6.24): hiển thị tiến độ Live Stream — theo sơ đồ gồm các trạng thái **Pre-live → Live → Post-live → Done/Cancel**. Role: CREATOR.
- Ghi chú bổ sung từ sơ đồ (khu vực "Live Stream" trong Flow diagram — checklist thực tế khi triển khai):
  - Ý tưởng, chiến lược target.
  - Kịch bản.
  - Tính toán rủi ro, những cái không lường trước được.
  - Quay phim, chụp, setup chuẩn bị.
  - Quay Livestream, quay máy ảnh → BTS (behind the scenes) có source đẹp trên livestream được quay bằng camera.
  - Có người đảm sát, người diễn viên.
  - Trong livestream sẽ có retouch lại các source cắt cam và từ video edit để chạy hook (dùng để đưa lên mới các bạn sắp tiếp).

#### Survey/Form — FR gốc (FR 3.6.25 – 3.6.27, nội dung field đã cập nhật ở 3.3)
- **Create Survey** (3.6.25): tạo khảo sát cho workshop. Role: CREATOR.
- **View Survey Analysis** (3.6.26): coi kết quả tổng quát của khảo sát. Role: MANAGER, CREATOR.
- **Generate Meeting Link** (3.6.27): tự động tạo link Google Meet. Role: CREATOR.
- Form Creator (theo sơ đồ): công cụ tạo câu hỏi (Questions) với time slot (0:10, 15:20, 21:30...), có preview.

## 4. Approval Sequence (FR 3.6.9) — task cũ, không có subtask theo vai trò

> **Phạm vi từ 2026-11-10:** mục 4 này chỉ còn áp dụng cho task **không có subtask theo vai trò** (tạo trước tính năng 2026-11-10, hoặc task Manager chủ động bỏ hết vai trò khỏi danh mục). Task có subtask theo vai trò (9 loại ở mục 3) dùng luồng duyệt theo phần ở mục 4a — bước `reviewStep=CLIENT` dưới đây bị thay thế hẳn cho nhóm task đó.

BA được người dùng xác nhận 2026-10-18, thay thế quy tắc QC và các vòng duyệt lịch sử:

```text
TODO --Creator được giao bấm Bắt đầu--> IN_PROGRESS
IN_PROGRESS --lưu bài và Gửi duyệt--> IN_REVIEW / MANAGER
  Manager approve:
    requiresClientApproval=false --> FINISHED
    requiresClientApproval=true  --> IN_REVIEW / CLIENT
  Client active bất kỳ approve --> FINISHED
  Manager hoặc Client reject có lý do --> IN_PROGRESS
  Creator withdraw trước Manager decision --> IN_PROGRESS
```

- POST tích hợp trước qua /editor, liên kết tối đa một Post cùng Workspace. Một bản nội dung hiện tại; khóa sửa khi review, không snapshot/diff các lượt cũ. Giữ content_version của Admin, không xây kho phiên bản mới.
- Client cần duyệt nhưng chưa có Client có User active thì chặn gửi, báo Manager bổ sung. Nếu hết Client trong lúc chờ thì giữ bước, không tự skip. Client mới được thêm có thể duyệt.
- Chỉ một Client bất kỳ quyết định; decision hợp lệ đầu tiên thắng. Không yêu cầu toàn bộ Client hoặc gán đại diện.
- Thu hồi chỉ cho assignee Creator trước Manager decision; không thu hồi khi chờ Client. Reject/withdraw không mở quyền sửa brief/deadline/giao lại cho Manager.
- Submit lại sau reject/withdraw tạo lượt mới từ Manager; approval cũ chỉ là audit, không còn hiệu lực cho nội dung mới.
- task_approvals giữ APPROVE/REJECT theo từng lượt/bước, tối đa hai decision/lượt; nhận xét duyệt khác task_comments. Không tạo sẵn dòng decision hoặc collection round riêng.
- IN_REVIEW giữ bước MANAGER/CLIENT riêng; ngoài IN_REVIEW reviewStep=null. Cancel đóng lượt chờ; FINISHED không mở lại, không tự publish.
- In-app báo người duyệt tiếp theo và Creator khi reject, không email. Quyền kiểm theo Workspace và User active; Owner Agency không tự có quyền Manager.
- Các loại Task khác chỉ chuẩn bị contract, tích hợp nội dung theo chủ module sau. Không thay Yjs/editor chuyên biệt, publishing hoặc Admin moderation của thành viên khác.

Chi tiết AC, API, chống xung đột và kế hoạch 6 giai đoạn: [FR3.6.9](../feature/content-task-workflow/3-6-9-approval-sequence-creator-manager-client/spec.md). API/POST integration/UI đã kiểm thử cô lập; rollout vẫn tắt, Atlas APPLY và SQL/inbox/Gateway end-to-end còn chờ giai đoạn 6/phối hợp chủ publish.

## 4a. Duyệt từng phần (section-level) — task có subtask theo vai trò

**BA hiện hành 2026-11-10**, nguồn: [spec.md](../feature/subtask-role-workspaces/spec.md) §4, §5. Áp dụng cho mọi task ở mục 3.1–3.8 có subtask gán theo danh mục vai trò.

### Vòng đời 1 phần

```text
DRAFT ──submit──▶ SUBMITTED ──Manager/supervisor approve──▶ INTERNAL_APPROVED
  ▲                   │                                            │
  │◀──return (ghi chú)┘                                            │ (chỉ phần O)
  │                                                                 ▼
RETURNED ◀──────── Client return (ghi chú) ─────────────── CLIENT_APPROVED
```

- Phần **I** (internal) dừng ở `INTERNAL_APPROVED` — là trạng thái cuối, Client không tham gia.
- Phần **O** (output) cần thêm `CLIENT_APPROVED` nếu task có `requiresClientApproval=true`; nếu `false` thì `INTERNAL_APPROVED` là cuối, Client không thấy luồng duyệt.
- `RETURNED` = như `DRAFT` kèm ghi chú người trả; chủ phần sửa lại, phần đi lại `SUBMITTED → INTERNAL_APPROVED → CLIENT_APPROVED`. Các phần khác đã duyệt không bị ảnh hưởng.
- Manager mở lại được phần đã duyệt (về `RETURNED`) khi task cha chưa nộp.
- Sửa một phần đã duyệt (nội bộ hoặc Client) đưa phần đó về `SUBMITTED`, cần duyệt lại — để không đăng/gửi nội dung Client chưa thấy phiên bản mới nhất.

### Ma trận quyền (tóm tắt, chi tiết xem spec.md §4)

| Đối tượng | Sửa phần mình | Sửa phần khác | Xem phần internal | Duyệt/trả phần |
|---|---|---|---|---|
| Điều phối (assignee task cha) | ✔ | ✔ (mọi phần) | ✔ | ✖ |
| Chủ phần (assignee subtask có vai trò) | ✔ khi DRAFT/RETURNED | ✖ chỉ đọc | ✔ | ✖ |
| Manager workspace | ✔ mọi phần | ✔ | ✔ | ✔ cấp nội bộ |
| Supervisor của subtask | theo vai trò khác của họ | — | ✔ | ✔ cấp nội bộ, chỉ phần subtask đó |
| Client | ✖ | ✖ | ✖ ẩn hoàn toàn | ✔ cấp Client, chỉ phần O, chỉ sau khi Manager duyệt |
| Người tham gia task khác (không có subtask vai trò/supervisor) | ✖ | ✖ chỉ đọc | ✖ (chỉ Manager/Owner/người tham gia task xem được internal) | ✖ |

- Một người giữ nhiều subtask có vai trò trong cùng task → quyền là **hợp** các phần.
- Subtask có vai trò tự động chuyển `FINISHED` khi mọi phần nó sở hữu đạt trạng thái cuối — chủ subtask không tự đánh dấu FINISHED.
- Nộp task cha bị chặn nếu còn phần chưa `INTERNAL_APPROVED` (`TASK_SECTIONS_UNAPPROVED`). Khi mọi phần O đã `CLIENT_APPROVED`, task cha coi như đã duyệt.

### Xuất file & phiên bản

- Xuất file chỉ gồm phần **output**, có logo thương hiệu Client; phần internal không bao giờ vào file. Thông cáo báo chí (PRESS_RECOMMENDATION) xuất **DOCX**; các loại khác xuất **PDF**.
- Agency (người tham gia task, Manager) xuất ở mọi trạng thái, phần chưa Client duyệt đóng dấu "Bản nháp". Client chỉ xuất được phần đã `CLIENT_APPROVED`.
- Mỗi lần nộp phần lưu một bản chụp (snapshot) nội dung, xem/so sánh được giữa các bản, không xoá. Kèm nhật ký ai nộp/duyệt/trả/mở lại, ghi chú, thời điểm. Client không xem lịch sử phiên bản, chỉ thấy bản hiện tại.
- Khôi phục bản cũ: chủ phần (khi DRAFT/RETURNED), điều phối, Manager — chép nội dung bản cũ vào bản nháp hiện tại, phần phải nộp và duyệt lại.

### Thông báo

In-app cho mọi sự kiện nộp/duyệt/trả/mở lại phần. Email cho Client khi có phần chờ Client duyệt, và cho chủ phần khi phần bị trả. Phần chờ Client quá 48h nhắc lại bằng email — **không tự động duyệt**.

## 5. Các View hỗ trợ Task (FR 3.6.4 – 3.6.8)

Dùng chung cho tất cả loại Task, tham khảo cách làm của Jira để đảm bảo chi tiết:

| FR | View | Mô tả |
|---|---|---|
| 3.6.4 | List Task View | Coi list task kiểu Jira |
| 3.6.5 | Calendar Task View | Kiểu Google Calendar, kéo thả được |
| 3.6.6 | Gantt Timeline Task View | Kiểu waterfall tiến trình công việc |
| 3.6.7 | Kanban Board Task View | Board kéo thả trạng thái (làm thêm 3 kiểu board khác nhau) |
| 3.6.8 | View Task Filter | Filter/sort/search theo toàn bộ field dữ liệu, tham khảo Jira |

Role toàn bộ: CREATOR, CLIENT, MANAGER.

## 6. Content Writing (FR 3.6.10)

- Dựa trên công nghệ viết chữ vector giống Google Docs.
- **Tự động chuyển font chữ đúng chuẩn khi đăng bài** — giải quyết pain point hiện tại của người làm content phải copy phần font chữ muốn đổi qua công cụ ngoài (ví dụ Unikey/Yantext) trước khi đăng.
- Có **Content History/Version**: xem ai chỉnh sửa phần nào, khôi phục lại các version trước đó nếu cần.
- **[CONFIRMED 2026-09-17]** Role sửa nội dung trực tiếp: **CREATOR và MANAGER** đều sửa được field content trực tiếp (không chỉ Creator) — Manager có thể cần override sửa gấp khi Creator không online hoặc chỉnh nhỏ không cần giao lại việc. Content History (trên) ghi rõ ai sửa phần nào để không mất minh bạch khi có nhiều người cùng sửa. Client vẫn chỉ dừng ở mức Add Comment (mục 2) — không sửa trực tiếp nội dung.
- Role: CREATOR, MANAGER.

## 7. Material & Brand Resources (FR 3.6.11 – 3.6.17)

### Material Repository (3.6.11 – 3.6.14)
- Kho ảnh của người chụp ảnh/editor.
- Phân loại theo dạng **raw** hoặc **đã retouched**.
- Cảnh báo nếu dùng ảnh raw (chưa xử lý) khi đăng.
- **Brand Asset Upload for Reference**: tài liệu do CLIENT cung cấp để Creator tham khảo khi sáng tạo — khác biệt với Material Repository (Material là sản phẩm do Creator/photographer tạo ra; Brand Collection là input Client cung cấp).
- Add/Update/Remove Material Repository (3.6.12 – 3.6.14): CRUD chuẩn.
- Role: CREATOR, CLIENT.

### Watermark & Download (3.6.15 – 3.6.16)
- **Apply Watermark** (3.6.15): tương tự công cụ img2go watermark — sau khi ảnh/ấn phẩm đã qua chỉnh sửa, Creator thêm watermark thương hiệu (logo do Client cung cấp) để đánh dấu bản quyền ấn phẩm. Role: CREATOR.
- **Download Material** (3.6.16): mọi role download tài liệu từ workspace về máy local để lưu trữ hoặc chỉnh sửa. Role: CREATOR, CLIENT, MANAGER.

### Hashtag Collection (3.6.17 – 3.6.21)
- **Apply Hashtag** (3.6.17): thêm 1 hoặc nhiều hashtag cho bài đăng/sự kiện/chiến dịch. Role: CREATOR, CLIENT.
- **View Hashtag Collection** (3.6.18): kho hashtag riêng cho từng Workspace. Creator tự thêm tự do; Client thêm mang tính đặc thù, bắt buộc dùng cho sự kiện của họ; AI recommend thêm hashtag phù hợp. Role: CREATOR, CLIENT.
- **Add Hashtag Collection** (3.6.19): thêm hashtag, có phân loại rõ mục đích sử dụng. Role: CREATOR, CLIENT.
- **Update Hashtag Collection** (3.6.20): cập nhật hashtag. Role: CREATOR, CLIENT.
- **Remove Hashtag Collection** (3.6.21): xóa hashtag cũ — **soft delete**, hashtag đã áp dụng vào bài cũ không bị xóa theo. Role: CREATOR, CLIENT.

## 8. Compliance & Copyright (FR 3.6.33 – 3.6.35)

- **Check Compliance Content** (3.6.33): check đạo văn, bạo lực, hình ảnh dung tục. Dùng API kéo về để có kết quả chuẩn nhất, trả về bảng phân tích từ ngữ + đoạn không đúng chuẩn — giúp Creator hiểu và tự fix trước khi vi phạm chính sách nền tảng hoặc mất khả năng lên trending. Role: CREATOR, CLIENT.
- **Check Copyright Infringement** (3.6.34): check bản quyền hình ảnh, thương hiệu. **[CONFIRMED 2026-09-17]** Dùng API bên thứ 3 (reverse image search — ví dụ Google Vision API / TinEye hoặc tương đương) để đối chiếu ảnh đầu ra với nguồn ảnh có sẵn trên Internet, giống cách Check Compliance Content (3.6.33) đã dùng API ngoài để có kết quả chuẩn. Trả về cảnh báo nếu phát hiện ảnh trùng khớp nguồn có bản quyền, để Creator tự thay ảnh trước khi đăng. Role: CREATOR, CLIENT.
- **View Content History** (3.6.35): không trừ credit AI khi user tái sử dụng tài nguyên đã tạo trước đó. Role: CREATOR, CLIENT, MANAGER.

## 9. Mail Template (FR 3.6.28 – 3.6.32)

- View/Create/Update/Delete Mail Template, Send Email via Template — CRUD chuẩn cho mẫu email + gửi email thực tế.
- **[CẬP NHẬT 2026-10-12 — thay thế quyết định 2026-09-17]** Mail Template **thuộc Workspace** (không phải mẫu cá nhân của mọi user). Role dùng: OWNER, MANAGER, CREATOR; CLIENT không. Gửi nhiều người (dán/CSV), async qua hàng đợi, giới hạn theo chuẩn Gmail (450/ngày hệ thống, 100/ngày/Workspace, 200/lần), hẹn giờ, tệp đính kèm, unsubscribe + suppression theo Workspace. Admin quản trị thư viện mẫu hệ thống và dùng làm mẫu cho Broadcast 3.10.1. Chi tiết: `feature/content-task-workflow/3-6-32-send-email-via-template/plan.md` (cùng bộ với các FR `3-6-28` đến `3-6-31`, mỗi FR có đủ spec, plan, task, test).
- **[BA hiện hành 2026-11-10]** Task **EMAIL_NEWSLETTER** (mục 3.8) dùng **chung hạ tầng gửi mail/suppression** ở trên (mail batch, unsubscribe) nhưng **quota tách riêng hoàn toàn**: giới hạn Gmail 100/ngày/Workspace, 450/ngày hệ thống ở trên chỉ áp dụng mail hệ thống (thông báo, OTP…); Newsletter có bộ đếm quota tháng riêng theo gói (BASIC 1.000 / PRO 10.000 / ENTERPRISE 50.000 email/tháng/agency) + giới hạn tốc độ gửi/ngày cấu hình được, không đụng tới giới hạn ngày của mail hệ thống. Suppression mail hệ thống theo Workspace; suppression Newsletter mở rộng theo **Client** (chặn ở mọi Workspace của agency khi Client đó unsubscribe 1 lần). Chi tiết: [spec.md §3.8, §16.1, §16.6](../feature/subtask-role-workspaces/spec.md).

## 10. Tham chiếu Media Platform Post (chi tiết trong sơ đồ)

Theo sơ đồ Flow diagram, khu vực "Media Platform Post" gồm các module con: Create Form, Export File, Apply Watermark, Content Writing View, Preview Post, content, hashtag — đây chính là workspace/editor tổng hợp để tạo ra 1 đơn vị content hoàn chỉnh (loại Post ở mục 3) trước khi đưa vào Approval Sequence (mục 4) rồi Publish (xem [07-publishing-social-collaborator.md](07-publishing-social-collaborator.md)).

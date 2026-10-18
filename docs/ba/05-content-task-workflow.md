# 05 — Content & Task Workflow

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

**Cập nhật 2026-10-18:** ngoài POST/LIVESTREAM/SURVEY, nền Task hiện có EVENT_PLAN và PRESS_RECOMMENDATION. Đợt FR 3.6.9 chỉ tích hợp nội dung POST qua /editor; các loại khác phối hợp chủ module sau, không tự submit/duyệt giả. Mô tả module chuyên biệt bên dưới giữ phạm vi của người phụ trách.

**[CONFIRMED 2026-09-14]** Task có 3 loại nội dung khác nhau, nhưng đều đi qua chung quy trình duyệt (mục 4).

### Loại 1 — Post (Media Platform Post)
- Viết content, tạo ảnh/video AI, watermark, hashtag — xem chi tiết mục 6, 7.

### Loại 2 — Livestream (FR 3.6.22 – 3.6.24)
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

### Loại 3 — Survey/Form (FR 3.6.25 – 3.6.27)
- **Create Survey** (3.6.25): tạo khảo sát cho workshop. Role: CREATOR.
- **View Survey Analysis** (3.6.26): coi kết quả tổng quát của khảo sát. Role: MANAGER, CREATOR.
- **Generate Meeting Link** (3.6.27): tự động tạo link Google Meet. Role: CREATOR.
- Form Creator (theo sơ đồ): công cụ tạo câu hỏi (Questions) với time slot (0:10, 15:20, 21:30...), có preview.

## 4. Approval Sequence (FR 3.6.9)

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

## 10. Tham chiếu Media Platform Post (chi tiết trong sơ đồ)

Theo sơ đồ Flow diagram, khu vực "Media Platform Post" gồm các module con: Create Form, Export File, Apply Watermark, Content Writing View, Preview Post, content, hashtag — đây chính là workspace/editor tổng hợp để tạo ra 1 đơn vị content hoàn chỉnh (loại Post ở mục 3) trước khi đưa vào Approval Sequence (mục 4) rồi Publish (xem [07-publishing-social-collaborator.md](07-publishing-social-collaborator.md)).

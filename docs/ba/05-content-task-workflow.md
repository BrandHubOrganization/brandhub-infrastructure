# 05 — Content & Task Workflow

> [<< Về Overview](00-overview.md)

## 1. Nguồn gốc Task trong backlog

Backlog KHÔNG đóng — có 3 nguồn tạo Task:

1. **Từ Media Campaign approve** — xem [04-media-package-campaign.md](04-media-package-campaign.md) mục 3.
2. **Từ Content Request được accept** — xem [04-media-package-campaign.md](04-media-package-campaign.md) mục 4.
3. **[CONFIRMED 2026-09-14]** Manager tự do thêm Task thủ công vào backlog bất cứ lúc nào — không bắt buộc phải có nguồn gốc từ Campaign hay Content Request (việc nội bộ: sửa bài cũ, họp nội bộ, v.v.)

## 2. Vòng đời 1 Task

### 3.6.1 — Identify Task Detail
- Khi Task còn ở backlog (vừa sinh ra từ Campaign), nó chỉ có: tên công việc, tiêu đề, yêu cầu đầu ra — **chưa cụ thể ai làm, làm gì**.
- Manager thêm đầy đủ: người thực hiện, ngày đăng, yêu cầu chi tiết, và **các field khác tùy theo loại công việc** (Post/Livestream/Survey — xem mục 3).
- Role: MANAGER.

### 3.6.2 — Assign Task To Creator
- Gắn công việc cho người làm (Creator), và **người chịu trách nhiệm check lại công việc đó** (QC — tùy chọn, xem mục 4).
- Role: MANAGER.

### 3.6.3 — Add Comments On Task
- Đưa ra nhận xét, yêu cầu chỉnh sửa trên task.
- Role: CREATOR, CLIENT, MANAGER.

## 3. Ba loại Task — dùng chung 1 khung Approval Sequence

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

```
Creator làm
  → [QC bởi 1 Creator khác được gán quyền quản lý chất lượng — TÙY CHỌN]
  → Manager duyệt
  → Client duyệt (chỉ nếu task đó có yêu cầu cần duyệt qua khách hàng)
  → Hoàn thành
```

- **[CONFIRMED 2026-09-14]** Bước QC bởi Creator khác là **tùy chọn**, có hoặc không tùy Manager quyết định có giao trách nhiệm QC hay không lúc Assign Task (3.6.2).
- Nếu bị trả về (reject) ở bất kỳ bước nào trong chuỗi → **quay lại từ đầu**: Creator (người làm ban đầu ở bước đầu tiên) phải làm lại từ đầu, không phải từ bước vừa bị reject.
- Đi hết chuỗi không bị reject → Task chính thức tính là hoàn thành.
- Role: CREATOR, CLIENT, MANAGER.

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
- **[CONFIRMED 2026-09-17]** Đây là tính năng chung cho **toàn bộ user đã đăng nhập** — không giới hạn theo role Workspace cụ thể (khác với đa số FR nhóm 3.6 vốn giới hạn theo CREATOR/MANAGER/CLIENT). Role: USER (bất kỳ ai có tài khoản, không cần thuộc Workspace nào để dùng Mail Template cá nhân).

## 10. Tham chiếu Media Platform Post (chi tiết trong sơ đồ)

Theo sơ đồ Flow diagram, khu vực "Media Platform Post" gồm các module con: Create Form, Export File, Apply Watermark, Content Writing View, Preview Post, content, hashtag — đây chính là workspace/editor tổng hợp để tạo ra 1 đơn vị content hoàn chỉnh (loại Post ở mục 3) trước khi đưa vào Approval Sequence (mục 4) rồi Publish (xem [07-publishing-social-collaborator.md](07-publishing-social-collaborator.md)).

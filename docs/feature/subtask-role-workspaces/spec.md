# Spec — Subtask theo vai trò & Trình soạn chia phần theo loại task

> **Thay thế** `docs/specs/2026-11-09-post-content-media-split-spec.md` (chỉ chia Content/Media cho POST). Spec cũ giữ nguyên để tra cứu, không còn hiệu lực.
>
> Bước ① trong `docs/rule/feature-workflow.md`. Chưa có plan/task/test, chưa code.
>
> Lỗi DB `media_packages.share_enabled` (thiếu migration 2026-11-06) **không thuộc** spec này.
>
> Mọi trường và quyết định trong spec đã được user chốt ngày 2026-11-10.

## 1. Objective

Một task lớn trong chiến dịch (bài đăng, sự kiện, thông cáo…) cần nhiều người với vai trò khác nhau. Hiện tại:

- `TaskDocument.Subtask` chỉ có `name` tự do + assignee/supervisor/hạn/status — không biết subtask đó là việc gì.
- Chỉ assignee của task cha được sửa nội dung (`TaskApprovalPolicy.assignee`). Người nhận subtask không vào được trình soạn.
- Chỉ POST (trình soạn bài) và SURVEY (form builder) có trình soạn; EVENT_PLAN chỉ có phòng họp, PRESS_RECOMMENDATION chỉ có mô tả.

Mục tiêu:

1. Mỗi loại task có **danh mục subtask chuẩn** (cố định trong code), mỗi vai trò sở hữu một hoặc nhiều **phần (section)** của trình soạn.
2. Mỗi loại task có **trình soạn riêng chia phần**; người làm subtask chỉ sửa phần của mình, xem chỉ-đọc phần khác.
3. **Duyệt từng phần** hai cấp: Manager/supervisor → Client (chỉ phần sản phẩm).
4. Thêm 4 loại task mới: **SHORT_VIDEO, KOL_BOOKING, WORKSHOP, EMAIL_NEWSLETTER**.
5. EMAIL_NEWSLETTER **gửi thật** qua hạ tầng mail sẵn có, quota theo gói.

Làm trong **một đợt** cho cả 8 loại (LIVESTREAM vẫn bị loại khỏi scope theo AGENTS.md).

## 2. Thuật ngữ

| Thuật ngữ | Nghĩa |
|---|---|
| Role hệ thống | 6 tên cố định: Guest, Owner, Manager, Creator, Client, Admin. **Không thay đổi.** |
| Vai trò công việc (`subtaskRole`) | Loại việc của một subtask (vd `POST_CONTENT`). Không phải role hệ thống; quyền sửa phần xét theo subtask được giao. |
| Phần (section) | Một vùng nội dung trong trình soạn, có key `TYPE.SECTION` (vd `POST.CAPTION`), có vòng đời duyệt riêng. |
| Phần sản phẩm (output) | Phần Client nhìn thấy và duyệt. |
| Phần nội bộ (internal) | Phần chỉ agency thấy; Client không thấy, không duyệt. |
| Chủ phần | Assignee của subtask có `subtaskRole` sở hữu phần đó. |
| Điều phối | Assignee của task cha (`TaskDocument.assigneeId`). |
| Supervisor | `Subtask.supervisorOverrideId`, mặc định là assignee task cha (logic `CampaignSubtaskService.supervisor`). |

## 3. Danh mục subtask chuẩn & phần soạn

Cột "Hiển thị": **O** = output (Client thấy & duyệt), **I** = internal.

### 3.1 POST — Bài đăng mạng xã hội (5 vai trò, trình soạn hiện có `/editor`)

| subtaskRole | Tên vai trò | Phần sở hữu | Trường | Hiển thị |
|---|---|---|---|---|
| `POST_RESEARCH` | Nghiên cứu / Phỏng vấn | `POST.BRIEF` (mới) | ghi chú phỏng vấn (rich text), trích dẫn nguồn (list text+link), file tư liệu (tham chiếu Material, gồm ghi âm) | I |
| `POST_CONTENT` | Viết content | `POST.CAPTION` | caption, hashtag, CTA (= `SavePostRequest.caption/hashtags`) | O |
| `POST_MEDIA` | Media (quay/chụp/thiết kế) | `POST.MEDIA` | media list (`PostMedia`), watermark (luồng watermark đã có trong `MediaDropzone`) | O |
| `POST_EDITING` | Biên tập | `POST.CAPTION` (chung với Content) | sửa caption/hashtag | O |
| `POST_PUBLISHING` | Đăng bài | `POST.CHANNELS` | targetPlatforms (Facebook/Instagram/TikTok/Threads), scheduledAt, nút publish | O |

**Luật chồng phần:** `POST_EDITING` chỉ sửa `POST.CAPTION` khi phần đã ở trạng thái `SUBMITTED` trở lên (Content đã nộp); khi Editing sửa, Content mất quyền sửa cho tới khi phần bị RETURNED. `POST_PUBLISHING` sửa kênh/lịch bất cứ lúc nào phần còn mở, nhưng **publish/schedule thật** chỉ sau khi task cha được duyệt xong (luồng publish hiện có).

### 3.2 SHORT_VIDEO — Video ngắn (mới; dùng lại trình soạn POST + phần Kịch bản)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `VIDEO_SCRIPT` | Ý tưởng & Kịch bản | `VIDEO.SCRIPT` (mới) | ý tưởng (text), kịch bản theo cảnh (list: cảnh, lời thoại, ghi chú hình ảnh, thời lượng) | O |
| `VIDEO_SHOOT` | Quay | `VIDEO.SHOOT` | **chừa slot cho code của Ân** — spec này chỉ đặt key + quyền, không định nghĩa UI | I |
| `VIDEO_EDIT` | Dựng / hậu kỳ | `VIDEO.EDIT` | **chừa slot cho code của Ân** | O |
| `VIDEO_PUBLISH` | Caption & Đăng | `VIDEO.CAPTION`, `VIDEO.CHANNELS` | như `POST.CAPTION` + `POST.CHANNELS`; kênh giới hạn TikTok, Instagram (Reels), Facebook (Reels) | O |

### 3.3 SURVEY — Khảo sát (trình soạn hiện có: form builder `SurveyOverviewCard`)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `SURVEY_DESIGN` | Thiết kế bảng hỏi | `SURVEY.FORM` | câu hỏi (dữ liệu `POST /survey` hiện có) | O |
| `SURVEY_DISTRIBUTE` | Phân phối & thu thập | `SURVEY.DISTRIBUTION` | link public (token `/public/surveys/{token}` có sẵn), kênh phát (text), hạn đóng, chỉ tiêu số phản hồi | O |
| `SURVEY_ANALYSIS` | Phân tích & báo cáo | `SURVEY.REPORT` | insight, kết luận, đề xuất (rich text) + số liệu từ `/survey/analysis` | O |

### 3.4 EVENT_PLAN — Kế hoạch sự kiện (trình soạn mới)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `EVENT_AGENDA` | Concept & Agenda | `EVENT.AGENDA` | concept, mục tiêu, thời gian/địa điểm dự kiến, agenda (list: giờ, hạng mục, phụ trách) | O |
| `EVENT_LOGISTICS` | Hậu cần & Địa điểm | `EVENT.LOGISTICS` | venue, vendor (list: tên, hạng mục, chi phí VND, liên hệ), ngân sách tổng, checklist vật tư | I |
| `EVENT_PROMOTION` | Truyền thông sự kiện | `EVENT.PROMOTION` | kế hoạch truyền thông (rich text), danh sách khách mời (list: tên, đơn vị, trạng thái mời) | O |
| `EVENT_ONSITE` | Điều phối tại chỗ | `EVENT.RUNSHEET` | run-sheet (list: giờ, việc, người phụ trách), phân công nhân sự | I |
| `EVENT_REPORT` | Báo cáo sau sự kiện | `EVENT.REPORT` | kết quả, số khách tham dự, ảnh (Material), bài học | O |

### 3.5 PRESS_RECOMMENDATION — Báo chí (trình soạn mới, **chỉ ghi nhận**)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `PRESS_MEDIA_LIST` | Lập danh sách báo | `PRESS.MEDIA_LIST` | list: tên báo, chuyên mục, nhà báo, email/điện thoại, ghi chú | I |
| `PRESS_RELEASE` | Viết thông cáo | `PRESS.RELEASE` | tiêu đề, sapo, nội dung (rich text), file đính kèm (Material) | O |
| `PRESS_PITCHING` | Liên hệ & pitching | `PRESS.CONTACT_LOG` | nhật ký (list: ngày, báo, người liên hệ, kênh, kết quả). **Hệ thống không gửi mail cho nhà báo.** | I |
| `PRESS_TRACKING` | Theo dõi đưa tin | `PRESS.COVERAGE` | list: báo, link bài, ngày đăng, ảnh chụp bài (Material) | O |

### 3.6 KOL_BOOKING — KOL/Influencer (mới, **chỉ ghi nhận**, KOL không có tài khoản)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `KOL_SOURCING` | Tìm & đề xuất KOL | `KOL.SHORTLIST` | list: tên, kênh (4 nền tảng), link, follower, tỉ lệ tương tác, lý do chọn | O |
| `KOL_NEGOTIATION` | Đàm phán | `KOL.DEAL` | KOL đã chọn, giá thỏa thuận (VND), hạng mục deliverable, điều khoản (text). **Không thanh toán.** | I |
| `KOL_BRIEF` | Brief cho KOL | `KOL.BRIEF` | key message, do/don't, hashtag bắt buộc, deadline đăng | O |
| `KOL_CONTENT_REVIEW` | Duyệt nội dung KOL | `KOL.DRAFT` | bản nháp KOL gửi (agency tải lên: caption + media Material), ghi chú duyệt | O |
| `KOL_TRACKING` | Theo dõi & báo cáo | `KOL.REPORT` | link bài KOL, ngày đăng, view/like/comment/share nhập tay | O |

### 3.7 WORKSHOP (mới; khớp `PackageServiceType.WORKSHOP_SUPPORT`)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `WORKSHOP_PROGRAM` | Nội dung chương trình | `WORKSHOP.PROGRAM` | chủ đề, agenda (list), slide/tài liệu (Material) | O |
| `WORKSHOP_SPEAKER` | Diễn giả | `WORKSHOP.SPEAKERS` | list: tên, chức danh, chủ đề, trạng thái mời (INVITED/CONFIRMED/DECLINED) | O |
| `WORKSHOP_LOGISTICS` | Hậu cần | `WORKSHOP.LOGISTICS` | hình thức (offline/online), địa điểm hoặc phòng online (dùng lại phòng họp `meetingUrl` hiện có), chi phí | I |
| `WORKSHOP_REGISTRATION` | Đăng ký & truyền thông | `WORKSHOP.REGISTRATION` | form đăng ký — **dùng lại form builder SURVEY** + link public; kế hoạch truyền thông | O |
| `WORKSHOP_REPORT` | Tổng kết | `WORKSHOP.REPORT` | số đăng ký/tham dự, feedback, ảnh, bài học | O |

### 3.8 EMAIL_NEWSLETTER (mới, **gửi thật**)

| subtaskRole | Tên | Phần | Trường | Hiển thị |
|---|---|---|---|---|
| `EMAIL_CONTENT` | Viết nội dung | `EMAIL.CONTENT` | subject, preheader, nội dung khối (dùng `BlockBuilder` / `MailBlockType` của mail-templates) | O |
| `EMAIL_DESIGN` | Thiết kế template | `EMAIL.DESIGN` | layout, màu/logo thương hiệu Client (block builder) | O |
| `EMAIL_SEND` | Danh sách & lịch gửi | `EMAIL.AUDIENCE` | nhóm người nhận (recipient group của Client), lịch gửi, nút gửi/test | O (Client xác nhận gửi cho ai, khi nào) |
| `EMAIL_REPORT` | Báo cáo | `EMAIL.REPORT` | số đã gửi/thành công/lỗi-bounce/huỷ đăng ký từ mail batch; ô nhận xét. Không có open/click (§16.3) | O |

## 4. Ma trận quyền

| Đối tượng | Sửa phần của mình | Sửa phần khác | Xem phần internal | Duyệt/trả phần | Nộp task cha |
|---|---|---|---|---|---|
| Điều phối (assignee task cha; Creator hoặc Manager) | ✔ | ✔ (mọi phần) | ✔ | ✖ | ✔ (khi mọi phần đủ điều kiện) |
| Chủ phần (assignee subtask có `subtaskRole`) | ✔ khi phần ở `DRAFT`/`RETURNED` | ✖ (chỉ đọc) | ✔ | ✖ | ✖ |
| Manager của workspace | ✔ (mọi phần) | ✔ | ✔ | ✔ cấp nội bộ | như hiện tại |
| Supervisor của subtask | theo vai trò khác của họ | — | ✔ | ✔ cấp nội bộ cho phần của subtask đó | — |
| Client | ✖ | ✖ | ✖ (ẩn hoàn toàn) | ✔ cấp Client, chỉ phần **O**, chỉ sau khi Manager duyệt | ✖ |
| Assignee subtask tự do (không `subtaskRole`) | ✖ | ✖ (chỉ đọc) | ✔ | ✖ | ✖ |
| Subtask cũ (tạo trước tính năng, `subtaskRole = null`) | xử lý như subtask tự do | | | | |
| Owner, Admin | giữ nguyên quyền hiện có, không thêm | | | | |

- Một người nhận nhiều subtask có vai trò trong cùng task → quyền là **hợp** các phần.
- Một vai trò có thể được giao cho nhiều subtask (vd 2 người `POST_CONTENT`) → cùng sửa phần đó, xung đột xử lý bằng revision (§5.4).
- Phần không có chủ (Manager bỏ vai trò đó khỏi danh mục khi tạo) → chỉ Điều phối/Manager sửa; không cần duyệt nội bộ riêng, duyệt cùng lúc khi nộp task cha.

## 5. Vòng đời phần & luật khoá

### 5.1 Trạng thái phần

```
DRAFT ──submit──▶ SUBMITTED ──Manager/supervisor approve──▶ INTERNAL_APPROVED
  ▲                   │                                            │
  │◀──return (ghi chú)┘                                            │ (phần O)
  │                                                                ▼
RETURNED ◀──────── Client return (ghi chú) ─────────────── CLIENT_APPROVED
```

- Phần **I** dừng ở `INTERNAL_APPROVED` (trạng thái cuối).
- Phần **O** cần thêm `CLIENT_APPROVED` nếu task có `requiresClientApproval = true`; nếu `false` thì `INTERNAL_APPROVED` là cuối.
- `RETURNED` = như `DRAFT`, kèm ghi chú của người trả. Client trả → mở khoá cho chủ phần, sửa xong đi lại `SUBMITTED → INTERNAL_APPROVED → CLIENT_APPROVED`. Các phần Client đã duyệt giữ nguyên.
- Manager có thể **mở lại** phần đã duyệt (về `RETURNED`) khi task cha chưa nộp.

### 5.2 Khoá

- Chủ phần chỉ sửa khi phần ở `DRAFT`/`RETURNED`. Từ `SUBMITTED` trở đi khoá với chủ phần.
- Điều phối và Manager sửa được ở mọi trạng thái trước khi task cha nộp; sửa một phần đã `INTERNAL_APPROVED`/`CLIENT_APPROVED` đưa phần đó về `SUBMITTED` (cần duyệt lại). Phần O đã `CLIENT_APPROVED` mà bị sửa thì Client phải duyệt lại, để không đăng/gửi nội dung Client chưa thấy.
- Luật chồng phần `POST.CAPTION` / `VIDEO.CAPTION`: §3.1.

### 5.3 Liên kết với subtask và task cha

- Subtask có `subtaskRole` chuyển `FINISHED` **tự động** khi mọi phần nó sở hữu đạt trạng thái cuối; chủ subtask không tự đánh dấu FINISHED được.
- Nộp task cha (`POST /tasks/{taskId}/submit`, `TaskApprovalService`) giữ luật hiện tại `TASK_SUBTASKS_UNFINISHED`, thêm luật: mọi phần đã `INTERNAL_APPROVED` trở lên. Với Client per-section, sau khi mọi phần O đã `CLIENT_APPROVED` thì task cha tự sang trạng thái đã duyệt; bước duyệt Client cấp task (`reviewStep = CLIENT`) được thay bằng duyệt từng phần.
- Chỉ subtask đến từ danh mục mới có `subtaskRole`; Manager vẫn thêm được subtask tự do.

### 5.4 Chạy song song & đồng thời

- Mọi subtask làm song song; không có thứ tự bắt buộc ngoài luật chồng phần.
- Không sửa cùng một phần đồng thời: mỗi lần lưu gửi `expectedRevision`; lệch → `TASK_REVISION_CONFLICT` (đã có, dùng `workflowRevision`). Revision **theo từng phần** để hai người sửa hai phần khác nhau không chặn nhau (quyết định kỹ thuật).

## 6. User Stories

1. Là **Manager**, khi tạo subtask cho một task POST, tôi thấy sẵn 5 vai trò chuẩn, bỏ bớt vai trò không cần, gán người và hạn cho từng vai trò, và vẫn thêm được subtask tự do.
2. Là **Creator** được giao subtask "Viết content", tôi mở trình soạn của task, chỉ sửa được caption/hashtag; media, kênh, brief hiển thị chỉ-đọc.
3. Là **Creator** làm "Biên tập", tôi chỉ sửa được caption sau khi người viết đã nộp phần.
4. Là **Manager/supervisor**, tôi duyệt hoặc trả lại từng phần kèm ghi chú, trên web hoặc mobile.
5. Là **Client**, tôi chỉ thấy các phần sản phẩm đã được Manager duyệt, duyệt hoặc trả lại từng phần; tôi không thấy brief, giá KOL, ngân sách, nhật ký liên hệ báo chí.
6. Là **Creator** điều phối (assignee task cha), tôi sửa được mọi phần và nộp task khi mọi phần đủ điều kiện.
7. Là **Creator** làm "Danh sách & lịch gửi" của EMAIL_NEWSLETTER, tôi chọn nhóm người nhận đã có đồng ý nhận mail và gửi/lên lịch sau khi Client duyệt nội dung, trong giới hạn quota gói.
8. Là **Manager**, tôi import CSV danh sách liên hệ của Client, bắt buộc cột xác nhận đồng ý; dòng không đồng ý bị loại.
9. Là **Creator** làm KOL/Press, tôi ghi nhận shortlist, giá, nhật ký liên hệ, link bài — hệ thống không gửi mail, không thanh toán.
10. Là **Manager** dùng mobile, tôi xem subtask được giao, xem nội dung từng phần, duyệt/trả phần.

## 7. Acceptance Criteria

**Danh mục & subtask**
- AC1: `GET` danh mục theo `TaskType` trả đúng các vai trò ở §3, cố định trong code (không có UI cấu hình).
- AC2: Tạo subtask từ danh mục lưu `subtaskRole`; tạo subtask tự do lưu `subtaskRole = null`. Subtask cũ đọc ra `subtaskRole = null`, không lỗi.
- AC3: Một `subtaskRole` hợp lệ chỉ khi thuộc đúng `TaskType` của task cha; sai → `VALIDATION_ERROR`.

**Quyền sửa** (kiểm ở backend, frontend chỉ phản ánh)
- AC4: Chủ phần sửa phần mình khi `DRAFT`/`RETURNED`; sửa phần khác → `FORBIDDEN`.
- AC5: Assignee subtask tự do không sửa được phần nào.
- AC6: Điều phối và Manager sửa mọi phần trước khi task cha nộp.
- AC7: `POST_EDITING` sửa `POST.CAPTION` khi phần đang `DRAFT` (Content chưa nộp) → `FORBIDDEN`.
- AC8: Endpoint lưu bài hiện có `POST /tasks/{taskId}/post` áp quyền theo phần: chỉ chấp nhận thay đổi trường thuộc phần người gọi được sửa; trường khác thay đổi → `FORBIDDEN` (không lặng lẽ bỏ qua).

**Duyệt**
- AC9: Chỉ Manager hoặc supervisor của subtask duyệt/trả phần ở cấp nội bộ.
- AC10: Client chỉ thấy phần O ở trạng thái `INTERNAL_APPROVED` trở lên; phần I không có trong response cho Client (lọc ở backend).
- AC11: Client trả phần → phần về `RETURNED` kèm ghi chú, chủ phần nhận thông báo; các phần đã `CLIENT_APPROVED` không đổi.
- AC12: Nộp task cha bị chặn nếu còn phần chưa `INTERNAL_APPROVED`.

**Email**
- AC13: Import CSV cần cột `email`, `name`, `consent`; dòng `consent` khác `true/yes/1` bị loại và báo số dòng loại; email nằm trong suppression list bị loại.
- AC14: Gửi chỉ khi `EMAIL.CONTENT` và `EMAIL.DESIGN` đã `CLIENT_APPROVED` (hoặc `INTERNAL_APPROVED` nếu task không cần Client duyệt), và người gọi là chủ `EMAIL_SEND` (hoặc điều phối/Manager).
- AC15: Quota tháng theo gói: BASIC 1.000, PRO 10.000, ENTERPRISE 50.000 email/tháng/agency; vượt → chặn gửi, báo số còn lại. Newsletter dùng bộ đếm riêng + giới hạn tốc độ gửi/ngày cấu hình được; giới hạn ngày của mail hệ thống (`MailQuotaService`, `mail.quota.*`) không bị Newsletter tiêu tốn (§16.1).
- AC16: Mỗi mail có link unsubscribe (dùng `/public/mail/unsubscribe` có sẵn); người hủy vào suppression của workspace.
- AC17: Mail gửi từ domain BrandHub, tên người gửi hiển thị = tên thương hiệu Client.

**Mobile**
- AC18: Mobile hiển thị subtask được giao, nội dung từng phần chỉ-đọc, nút duyệt/trả cho Manager/supervisor/Client theo đúng quyền. Không có trình soạn trên mobile.

**i18n (bắt buộc)**
- AC19: Mọi text mới dùng key, thêm đồng thời `vi` + `en` (key-parallel), không hardcode:
  - `tasks.subtaskRoles.<ROLE>` — tên vai trò (VD `tasks.subtaskRoles.POST_CONTENT`)
  - `tasks.sections.<TYPE>.<SECTION>.title|fields.*` — tiêu đề & nhãn trường từng phần
  - `tasks.sectionStatus.<STATUS>` — DRAFT/SUBMITTED/INTERNAL_APPROVED/CLIENT_APPROVED/RETURNED
  - `tasks.sectionActions.*` — submit/approve/return/reopen, thông báo khoá, lỗi quyền
  - `tasks.types.<TYPE>` — 4 loại mới
  - `campaign.timeline.catalog.*` — gợi ý danh mục khi tạo subtask
  - `editor.sections.*` — banner chỉ-đọc, tên chủ phần
  - `mailTemplate.contactImport.*`, `mailTemplate.quota.monthly*` — import CSV & quota tháng
  - mobile: cùng namespace trong locale của `brandhub-mobile-app`

**Light/Dark (bắt buộc)**
- AC20: Badge trạng thái phần, viền phần bị khoá, banner chỉ-đọc dùng token theme/`dark:` variant sẵn có (`bg-muted`, `text-muted-foreground`, `brand-orange`, màu trạng thái như `TaskStatusControl`), không hex cứng. Kiểm tra cả hai theme.

## 8. UI/UX

- **Tạo subtask (timeline & task detail):** `TimelineSubtaskCreator` / `CampaignSubtasks` thêm bước "Gợi ý theo danh mục": danh sách vai trò của loại task, mỗi dòng tick/bỏ, chọn assignee, hạn; nút "Thêm subtask tự do" giữ như cũ. Subtask có vai trò hiện badge tên vai trò.
- **Trình soạn chia phần:** mỗi phần là một khối có tiêu đề, tên chủ phần, badge trạng thái, nút theo quyền (Nộp / Duyệt / Trả lại / Mở lại). Phần không được sửa: nội dung hiển thị bình thường nhưng input disabled + biểu tượng khoá + tooltip "Phần của {tên}".
  - POST & SHORT_VIDEO: mở rộng `/workspaces/:id/tasks/:taskId/editor` (`pages/editor`), thêm khối Brief (POST) / Kịch bản (VIDEO), khối Shoot/Edit của VIDEO là slot rỗng cho code của Ân.
  - SURVEY: gắn khung phần quanh form builder hiện có (`SurveyOverviewCard`), thêm khối Phân phối, Báo cáo.
  - EVENT_PLAN, PRESS_RECOMMENDATION, KOL_BOOKING, WORKSHOP, EMAIL_NEWSLETTER: trình soạn mới cùng một bộ khung phần (layout dùng chung, nội dung khối theo loại). EMAIL dùng lại `BlockBuilder`, `MailPreview`, `RecipientPicker`.
- **Task detail (`TaskWorkflowContent`):** nút mở trình soạn hiển thị cho mọi loại (hiện chỉ POST/SURVEY), kèm tóm tắt tiến độ phần (vd 3/5 phần đã duyệt).
- **Client portal:** danh sách phần chờ duyệt theo task; mỗi phần xem + Duyệt / Trả lại (bắt buộc ghi chú khi trả).
- **Mobile:** màn task detail thêm tab "Phần", chỉ đọc + nút duyệt/trả.

## 9. API Contract

Mở rộng endpoint hiện có, không nhân bản. Mọi response bọc `ApiResponse`. Path gốc `/api/v1/workspaces/{workspaceId}`.

### 9.1 Mở rộng hiện có

| Endpoint (hiện có) | Thay đổi |
|---|---|
| `GET/POST/PATCH /tasks/{taskId}/subtasks…` (`CampaignSubtaskController`) | `Details` thêm `subtaskRole` (nullable). `Row` trả thêm `subtaskRole`. `PATCH /{id}/status` không cho đặt `FINISHED` với subtask có vai trò (tự động theo §5.3). |
| `TaskDocument.Subtask` | thêm trường `subtaskRole` (String, nullable). |
| `TaskType` enum (BE `model/enums/TaskType.java`, FE `types/task.ts`, `pages/campaign/types.ts`) | thêm `SHORT_VIDEO, KOL_BOOKING, WORKSHOP, EMAIL_NEWSLETTER`. |
| `GET/POST /tasks/{taskId}/post` (`TaskPostController`) | quyền ghi theo phần (AC8) thay cho chỉ `TaskApprovalPolicy.assignee`. Response thêm `sections` (trạng thái + quyền người gọi). |
| `POST /tasks/{taskId}/survey` (`SurveyController`) | quyền ghi theo phần `SURVEY.FORM`. |
| `POST /tasks/{taskId}/submit` (`TaskApprovalController`) | thêm điều kiện §5.3. |
| `GET /mail-quota` (`MailSendController`) | thêm `monthlyUsed`, `monthlyLimit`, `planName`. |
| `POST /mail-recipient-groups` (`MailRecipientController`) | `Entry` thêm `consent` (boolean), `consentSource`, `importedAt`. |

### 9.2 Mới

| Method & path | Mô tả | Quyền |
|---|---|---|
| `GET /api/v1/task-catalog/{taskType}` | danh mục vai trò → phần, cờ O/I | mọi thành viên đã đăng nhập |
| `GET /tasks/{taskId}/sections` | mọi phần: key, ownerSubtaskIds, ownerNames, status, revision, returnNote, `canEdit`, `canSubmit`, `canApprove`, `canReturn`, nội dung. Client chỉ nhận phần O đủ điều kiện. | thành viên task, Client |
| `PATCH /tasks/{taskId}/sections/{sectionKey}` | body `{content, expectedRevision}`; content là JSON theo schema phần (§3). POST/SURVEY ghi xuống `PostDocument`/survey hiện có; loại khác ghi vào `TaskDocument.typeMetadata.sections` hoặc collection riêng — chốt ở plan.md | §4 |
| `POST /tasks/{taskId}/sections/{sectionKey}/submit` | `DRAFT/RETURNED → SUBMITTED` | chủ phần, điều phối |
| `POST /tasks/{taskId}/sections/{sectionKey}/approve` | `SUBMITTED → INTERNAL_APPROVED` (Manager/supervisor) hoặc `INTERNAL_APPROVED → CLIENT_APPROVED` (Client) | §4 |
| `POST /tasks/{taskId}/sections/{sectionKey}/return` | body `{note}` bắt buộc; → `RETURNED` | Manager/supervisor, Client (phần O) |
| `POST /tasks/{taskId}/sections/{sectionKey}/reopen` | phần đã duyệt → `RETURNED` | Manager |
| `POST /mail-recipient-groups/import` | multipart CSV (`email,name,consent`), trả `{imported, skippedNoConsent, skippedSuppressed, skippedInvalid}` | Manager, Owner |
| `POST /tasks/{taskId}/newsletter/send` | body `{recipientGroupIds, scheduledAt?}`; tạo mail batch qua `MailDeliveryService`/batch có sẵn; trả batchId | chủ `EMAIL_SEND`, điều phối, Manager |
| `POST /tasks/{taskId}/newsletter/send-test` | gửi bản test tới email người gọi | như trên |

Theo dõi batch: dùng lại `GET /mail-batches/{batchId}`, `/export.csv`, `/cancel`, `/resend-failed`.

## 10. Error Handling

| Tình huống | ErrorCode (có sẵn hoặc mới) | Thông báo (i18n key) |
|---|---|---|
| Sửa phần không có quyền / phần đã khoá | `FORBIDDEN` | `tasks.sectionActions.forbidden` / `.locked` |
| Lệch revision | `TASK_REVISION_CONFLICT` (có sẵn) | `tasks.sectionActions.conflict` + nút tải lại |
| `subtaskRole` sai loại task | `VALIDATION_ERROR` | `tasks.subtask.invalidRole` |
| Chuyển trạng thái phần không hợp lệ | `SECTION_INVALID_TRANSITION` (mới) | `tasks.sectionActions.invalidTransition` |
| Trả phần thiếu ghi chú | `VALIDATION_ERROR` | `tasks.sectionActions.noteRequired` |
| Nộp task cha khi còn phần chưa duyệt | `TASK_SECTIONS_UNAPPROVED` (mới) | `tasks.sectionActions.sectionsPending` |
| Gửi email khi nội dung chưa duyệt | `NEWSLETTER_NOT_APPROVED` (mới) | `mailTemplate.newsletter.notApproved` |
| Vượt quota tháng | `MAIL_MONTHLY_QUOTA_EXCEEDED` (mới) | `mailTemplate.quota.monthlyExceeded` |
| CSV thiếu cột/sai định dạng | `VALIDATION_ERROR` | `mailTemplate.contactImport.invalidFile` |

## 11. Edge Cases

- Subtask bị xoá/huỷ (`CANCELLED`) khi phần đang `SUBMITTED`: phần giữ nội dung, mất chủ → về quyền của điều phối/Manager.
- Đổi assignee subtask giữa chừng: giữ nguyên nội dung và trạng thái phần (quyết định 2026-11-09).
- Manager bỏ hết vai trò → task hoạt động như hiện tại (chỉ điều phối sửa).
- Task cũ trước tính năng (không có trạng thái phần): coi mọi phần `DRAFT`, chủ = điều phối; luồng duyệt task cha giữ nguyên cho task đã ở `IN_REVIEW` trước khi deploy.
- `requiresClientApproval = false`: phần O kết thúc ở `INTERNAL_APPROVED`, Client không thấy luồng duyệt.
- Hai người cùng vai trò sửa cùng phần: người lưu sau nhận `TASK_REVISION_CONFLICT`.
- Client trả phần sau khi task đã lên lịch publish/gửi mail: tự huỷ lịch ngay, thông báo người phụ trách Đăng bài / Gửi; phải duyệt lại rồi đặt lịch lại.
- CSV trùng email: giữ một dòng; email đã unsubscribe ở bất kỳ workspace nào của cùng Client: chặn mọi Newsletter của Client đó (§16.6).
- Hết quota giữa batch: phần đã gửi giữ nguyên, phần còn lại `DEFERRED` theo cơ chế `MailDeliveryService` hiện có.
- SHORT_VIDEO khi code của Ân chưa merge: khối Shoot/Edit hiển thị placeholder, phần vẫn duyệt được với media tải lên qua `POST.MEDIA`-tương đương.

## 12. UI States

Mỗi khối phần: loading (skeleton), empty (chưa có nội dung — gợi ý theo vai trò), editing, saving, saved, locked (chỉ đọc + lý do), conflict (banner tải lại), returned (banner ghi chú trả màu cảnh báo), approved (badge xanh), error (toast + giữ nội dung chưa lưu). Danh sách phần cho Client: empty state "Chưa có phần nào chờ duyệt".

## 13. Test Cases (sơ bộ)

1. Tạo task POST → gợi ý 5 vai trò; bỏ `POST_RESEARCH`, tạo 4 subtask có vai trò + 1 tự do.
2. Creator `POST_CONTENT` lưu caption ✔; lưu media ✖ `FORBIDDEN`.
3. Creator `POST_EDITING` sửa caption khi DRAFT ✖; sau khi Content nộp ✔.
4. Assignee subtask tự do sửa bất kỳ phần ✖.
5. Manager duyệt `POST.CAPTION` → Client thấy phần; Client không thấy `POST.BRIEF`.
6. Client trả `POST.MEDIA` → chủ phần sửa được lại; `POST.CAPTION` đã duyệt không đổi.
7. Nộp task cha khi còn phần SUBMITTED ✖ `TASK_SECTIONS_UNAPPROVED`.
8. Hai phiên cùng lưu một phần → phiên sau `TASK_REVISION_CONFLICT`.
9. Import CSV 10 dòng, 2 không consent, 1 trong suppression → imported 7.
10. Gửi newsletter trước khi Client duyệt ✖; sau duyệt ✔, batch tạo, mail có link unsubscribe.
11. Gói BASIC đã gửi 1.000 trong tháng → gửi tiếp ✖ `MAIL_MONTHLY_QUOTA_EXCEEDED`.
12. Mobile: Manager duyệt/trả phần ✔, không có nút sửa nội dung.
13. Đổi ngôn ngữ vi↔en trên mọi trình soạn mới không vỡ layout, không lộ key.
14. Light/dark: badge trạng thái, khối khoá, banner trả lại đủ tương phản.
15. Task cũ (subtask không vai trò) mở trình soạn, sửa, nộp như trước.

## 14. Definition of Done

- 8 loại task có danh mục, trình soạn chia phần, quyền theo §4 enforce ở backend.
- Duyệt từng phần 2 cấp + gating nộp task cha hoạt động; subtask tự động FINISHED.
- EMAIL_NEWSLETTER gửi thật với consent, suppression, unsubscribe, quota tháng.
- Mobile xem + duyệt/trả phần.
- i18n vi/en key-parallel, light/dark đạt.
- Unit/integration test backend cho quyền & chuyển trạng thái; E2E web cho luồng POST đầy đủ; test.md pass.
- Không regression luồng task cũ.

## 15. Out of Scope

- Quay/dựng video và mọi chức năng sửa video trong app (phần của Ân; spec chỉ chừa slot `VIDEO.SHOOT`, `VIDEO.EDIT`).
- Thanh toán cho KOL; KOL đăng nhập/nộp bài qua link.
- Gửi mail pitching tới nhà báo.
- Agency tự cấu hình danh mục vai trò/phần.
- Trình soạn đầy đủ trên mobile.
- Đồng soạn real-time nhiều người trên cùng một phần.
- Gửi email từ domain riêng của Client (SPF/DKIM).
- **Cập nhật baseline 141 FR, CSV FR và SRS — làm sau khi code chạy thật.** Kiểm tra 2026-11-13 (`brandhub-final_report/report3/Report3_Software Requirement Specification.docx`): mục 3.6 Content & Workflow hiện có đúng 35 FR (`3.6.1`–`3.6.35`), **0 lần** nhắc tới Event Plan / Press Recommendation / Short Video / KOL Booking / Workshop / Email Newsletter hay mô hình duyệt theo phần — baseline hoàn toàn chưa cập nhật theo spec này. TODO khi code nghiệm thu xong:
  - Thêm FR mới cho mỗi subtask role của 6 loại task mới (mẫu: cách `3.6.1`–`3.6.9` mô tả Post hiện tại) — ước ~20–30 FR mới, numbering tiếp nối `3.6.35` hoặc chèn xen kẽ theo nhóm loại task (cần bàn cách đánh số để không vỡ numbering các mục sau).
  - Viết lại `3.6.9 Approval Sequence` theo mô hình duyệt từng phần (`DRAFT → SUBMITTED → INTERNAL_APPROVED → CLIENT_APPROVED`, §5 spec này) thay vì chuỗi task-level cũ, đồng thời giữ rõ: mô hình cũ vẫn áp dụng cho task không có subtask theo vai trò.
  - Mục `2.2 Use Cases`: thêm Use Case tương ứng từng FR mới (UC-142 trở lên, hoặc chèn lại numbering — bàn cách làm).
  - ERD / mục `3.1.5 Entities Description`: thêm `Subtask.subtaskRole`, `TaskSection` (key, content, status, visibility, revision, versions) theo §9 spec này.
  - Đồng bộ lại CSV FR gốc (`docs/Các FR của hệ thống - Feature_Function Requirement.csv`) và CSV Use Case nếu còn dùng làm nguồn 141 FR.
  - Giữ nguyên exclusion rule AGENTS.md: Livestream vẫn ngoài phạm vi 141 FR, không thêm FR cho nó dù code có sẵn.
- Lỗi migration `media_packages.share_enabled`.

## 16. Quyết định đã chốt (user, 2026-11-10)

1. **Quota Newsletter tách riêng khỏi mail hệ thống.** Mail hệ thống (thông báo, OTP…) giữ nguyên giới hạn `mail.quota.*` hiện có (100/ngày/workspace, 450/ngày toàn hệ thống) để Newsletter không chiếm hết. Newsletter có bộ đếm riêng: quota tháng theo gói (BASIC 1.000 / PRO 10.000 / ENTERPRISE 50.000) + giới hạn tốc độ gửi theo ngày cấu hình được.
2. **Quota tính theo agency.** Mọi workspace/Client của một agency dùng chung quota tháng.
3. **Không làm tracking open/click.** Báo cáo email gồm: đã gửi, thành công, lỗi/bounce, huỷ đăng ký, cùng ô nhận xét.
4. **Thêm `PackageServiceType`:** `SHORT_VIDEO`, `KOL_BOOKING`, `EMAIL_NEWSLETTER` (Workshop đã có `WORKSHOP_SUPPORT`).
5. **Client duyệt từng phần thay hẳn bước `reviewStep = CLIENT`** với task có subtask theo vai trò. Client duyệt đủ các phần đầu ra thì task được coi là đã duyệt. Task cũ (không có subtask theo vai trò) giữ luồng duyệt cũ.
6. **Huỷ đăng ký theo Client.** Người nhận huỷ đăng ký Newsletter ở một workspace thì bị chặn mọi Newsletter của Client đó, ở mọi workspace. Suppression hiện có (theo workspace + agency) giữ cho mail hệ thống; Newsletter thêm phạm vi Client.
7. **Thông báo:** in-app cho mọi sự kiện nộp/duyệt/trả/mở lại phần. Email cho Client khi có phần chờ Client duyệt, và cho chủ phần khi phần bị trả. Phần chờ Client quá 48h thì nhắc lại bằng email; **không tự duyệt**.
8. **Hạn subtask:** subtask sinh theo danh mục mặc định lấy hạn của task cha; Manager sửa được từng subtask.
9. **Sinh subtask khi triển khai chiến dịch.** Code hiện tại đã tự sinh task cha từ hạng mục gói lúc triển khai chiến dịch (`CampaignTaskStore.draftTask`) nhưng chưa sinh subtask. Bổ sung: mỗi task cha sinh ra kèm đủ bộ subtask theo danh mục của loại đó, chưa gán người, hạn = hạn task cha. Manager gán người, sửa hạn, huỷ subtask không cần. Task tạo tay ngoài gói vẫn dùng bước "Gợi ý theo danh mục" như §8.
10. **Ai xem phần nội bộ:** chỉ người tham gia task (điều phối, người có subtask trong task, supervisor), Manager và Owner. Creator khác trong workspace không thấy phần nội bộ. Ghi đè cột "Xem phần internal" ở §4 cho người không tham gia task.
11. **Xuất file:** thông cáo báo chí xuất DOCX; các loại khác xuất PDF. File chỉ gồm phần đầu ra (O), có logo thương hiệu Client; phần nội bộ không bao giờ vào file. Agency (người tham gia task, Manager) xuất ở mọi trạng thái, phần chưa Client duyệt đóng dấu "Bản nháp". Client chỉ xuất được phần đã `CLIENT_APPROVED`. Dùng lại hạ tầng xuất đề xuất đa ngôn ngữ hiện có nếu phù hợp.
12. **Phiên bản:** mỗi lần nộp phần lưu một bản chụp nội dung; xem và so sánh được giữa các bản. Không xoá phiên bản. Kèm nhật ký sự kiện (ai nộp/duyệt/trả/mở lại, ghi chú, thời điểm).
13. **Khôi phục bản cũ:** chủ phần (khi phần đang `DRAFT`/`RETURNED`), người điều phối, Manager. Khôi phục = chép nội dung bản cũ vào bản nháp hiện tại; phần phải nộp và duyệt lại.
14. **Client không xem lịch sử phiên bản**, chỉ thấy bản hiện tại đang chờ duyệt hoặc đã duyệt.
15. **Theo dõi tiến độ:** không làm màn hình workload riêng. Timeline chiến dịch có sẵn hiện subtask kèm trạng thái phần và cờ trễ hạn / chờ Client.

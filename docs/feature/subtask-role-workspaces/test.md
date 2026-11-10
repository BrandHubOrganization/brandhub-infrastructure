# Test — Subtask theo vai trò & Trình soạn chia phần (DA-1274)

> Bước ④ theo `docs/rule/feature-workflow.md`. Dựa trên `spec.md` (AC1–AC20, §11, §13, §16), `plan.md`, `task.md`.
> Cột **Map** chỉ AC / mục spec / task tương ứng. Cột **KQ** ghi `PASS` / `FAIL` / `N/A` khi chạy T10.5.
> Tầng: **U** = unit, **I** = integration (MockMvc + Mongo/Postgres test), **E** = E2E web (Playwright), **M** = mobile (Jest/RNTL), **T** = thủ công.

## Dữ liệu chuẩn bị

- Workspace W1 thuộc agency A1 (gói BASIC), Client C1 (`displayName = "Brand X"`, có logo). Workspace W2 cùng agency A1, cùng Client C1.
- Người dùng: `mgr` (Manager W1), `owner` (Owner A1), `coord` (Creator, assignee task cha), `res`, `content`, `content2`, `media`, `edit`, `pub` (Creator, mỗi người 1 subtask vai trò POST tương ứng), `free` (Creator, subtask tự do), `outsider` (Creator W1, không tham gia task), `sup` (supervisor subtask `POST_MEDIA`), `client` (tài khoản Client C1).
- Task P1: POST, `requiresClientApproval = true`, có 5 subtask vai trò + 1 subtask tự do (seed T3.7).
- Task P2: POST cũ, chỉ có subtask `subtaskRole = null`.
- Task N1: EMAIL_NEWSLETTER, đủ 4 subtask vai trò; nhóm người nhận G1 của C1.
- File CSV mẫu: `contacts-10.csv` (10 dòng: 7 hợp lệ, 2 `consent = no`, 1 email nằm trong suppression).

---

## A. Danh mục & subtask

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| A1 | AC1, T1.3, T1.6 | U+I | `GET /api/v1/task-catalog/{type}` cho 8 loại | Số vai trò/phần đúng spec §3: POST 5 vai trò/4 phần, SHORT_VIDEO 4/5, SURVEY 3/3, EVENT_PLAN 5/5, PRESS 4/4, KOL 5/5, WORKSHOP 5/5, EMAIL 4/4. Cờ O/I khớp bảng. | ☐ |
| A2 | AC1, T1.6 | I | `GET /task-catalog/ABC` | `VALIDATION_ERROR` | ☐ |
| A3 | AC2, T1.7 | I | Tạo subtask `subtaskRole = POST_CONTENT` trên P1; tạo subtask không có `subtaskRole` | Lần 1 lưu `POST_CONTENT`; lần 2 lưu `null`. `GET` subtask trả `subtaskRole` ở `Details` và `Row`. | ☐ |
| A4 | AC2, T1.5 | I | Đọc subtask cũ của P2 (document không có field `subtaskRole`) | Trả `subtaskRole = null`, không lỗi deserialize. | ☐ |
| A5 | AC3, T1.7 | I | Tạo subtask `subtaskRole = KOL_BRIEF` trên P1 (POST) | `VALIDATION_ERROR` (`tasks.subtask.invalidRole`). | ☐ |
| A6 | §5.3, T1.7 | I | `PATCH /subtasks/{id}/status` → `FINISHED` cho subtask có vai trò | Bị từ chối. Subtask tự do vẫn đặt `FINISHED` được. | ☐ |
| A7 | §16.9, T3.6 | I | Triển khai chiến dịch có hạng mục POST ×1, KOL_BOOKING ×1, WORKSHOP_SUPPORT ×1 | Sinh 3 task cha: POST, KOL_BOOKING, **WORKSHOP**; mỗi task có đủ subtask theo danh mục, assignee null, `dueDate` = hạn task cha, TODO. | ☐ |
| A8 | T1.2 | U | `PackageOfferingValidator` với service type mới | `SHORT_VIDEO → "video"`, `KOL_BOOKING → "KOL"`, `EMAIL_NEWSLETTER → "bản tin"`; đơn vị khác → lỗi. | ☐ |
| A9 | Spec 13.1, T8.7 | E | Manager tạo task POST tay → mở "Gợi ý theo danh mục", bỏ `POST_RESEARCH`, gán 4 người, thêm 1 subtask tự do | Tạo 4 subtask có badge vai trò + 1 subtask tự do không badge; subtask có vai trò không có tuỳ chọn FINISHED thủ công. | ☐ |

## B. Quyền sửa phần (backend)

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| B1 | AC4, spec 13.2 | I | `content` lưu caption P1 qua `POST /tasks/P1/post` | 200; revision `POST.CAPTION` +1. | ☐ |
| B2 | AC4, AC8, spec 13.2 | I | `content` gửi `SavePostRequest` đổi cả caption và media | `FORBIDDEN`; không trường nào được lưu (không lưu một phần). | ☐ |
| B3 | AC8 | I | `content` gửi request giữ nguyên media/kênh, chỉ đổi caption | 200 (trường không đổi không bị tính là sửa). | ☐ |
| B4 | AC4, §5.2 | I | `POST.CAPTION` ở `SUBMITTED`; `content` lưu caption | `FORBIDDEN` (`tasks.sectionActions.locked`). | ☐ |
| B5 | AC5, spec 13.4 | I | `free` sửa lần lượt BRIEF, CAPTION, MEDIA, CHANNELS | Đều `FORBIDDEN`. | ☐ |
| B6 | AC6 | I | `coord` và `mgr` sửa mọi phần khi phần `DRAFT` và khi phần `INTERNAL_APPROVED` | 200; phần đang `INTERNAL_APPROVED` về `SUBMITTED`. | ☐ |
| B7 | §5.2 | I | `mgr` sửa phần O đã `CLIENT_APPROVED` | 200; phần về `SUBMITTED`, phải qua lại nội bộ + Client. | ☐ |
| B8 | AC7, spec 13.3 | I | `edit` sửa `POST.CAPTION` khi `DRAFT` | `FORBIDDEN`. | ☐ |
| B9 | AC7, spec 13.3, §3.1 | I | `content` nộp `POST.CAPTION`; `edit` sửa | 200. Sau đó `content` sửa → `FORBIDDEN` cho tới khi phần `RETURNED`. | ☐ |
| B10 | §4 hợp quyền | U | Một người giữ subtask `POST_CONTENT` + `POST_MEDIA` | Sửa được cả CAPTION và MEDIA. | ☐ |
| B11 | §4, spec 11 | I | `content` và `content2` cùng vai trò `POST_CONTENT` | Cả hai sửa được CAPTION. | ☐ |
| B12 | §4 phần không chủ | U | Task không có subtask `POST_RESEARCH`; `content` sửa BRIEF; `coord` sửa BRIEF | `content` → `FORBIDDEN`; `coord` → 200. | ☐ |
| B13 | §11 subtask huỷ | I | Huỷ (`CANCELLED`) subtask `POST_MEDIA` khi MEDIA đang `SUBMITTED`; `media` sửa; `coord` sửa | Nội dung giữ nguyên. `media` → `FORBIDDEN`; `coord` → 200. | ☐ |
| B14 | §11 đổi assignee | I | Đổi assignee subtask `POST_MEDIA` từ `media` sang `content2` | Nội dung + trạng thái MEDIA giữ nguyên; `content2` có quyền, `media` mất quyền. | ☐ |
| B15 | T3.2 | I | `VIDEO_PUBLISH` lưu `targetPlatforms = [THREADS]` cho SHORT_VIDEO | `VALIDATION_ERROR`; `[TIKTOK, INSTAGRAM, FACEBOOK]` → 200. | ☐ |
| B16 | T3.3 | I | `SURVEY_DISTRIBUTE` gọi `POST /tasks/{id}/survey`; `SURVEY_DESIGN` gọi | Lần 1 `FORBIDDEN`; lần 2 200. WORKSHOP: chỉ chủ `WORKSHOP.REGISTRATION` lưu form được. | ☐ |
| B17 | T2.6 | I | `PATCH /sections/EVENT.AGENDA` với content sai schema (vd `agenda` không phải list) | `VALIDATION_ERROR`; không tạo document. | ☐ |
| B18 | Spec 13.8, §5.4 | I | Hai phiên cùng đọc revision 3 của CAPTION; cả hai `PATCH` với `expectedRevision = 3` | Phiên đầu 200 (revision 4); phiên sau `TASK_REVISION_CONFLICT`. | ☐ |
| B19 | §5.4 | I | Hai phiên sửa hai phần khác nhau (CAPTION, MEDIA) cùng lúc, qua `PATCH /sections` hoặc `POST /tasks/{id}/post` có `sectionRevisions` | Cả hai 200, không chặn nhau; lưu bài chỉ ghi trường của phần đã khai báo. | ☐ |
| B20 | T2.6 lazy create | I | Hai request đầu tiên đồng thời tạo document cho cùng `{taskId, sectionKey}` | Một 200, một `TASK_REVISION_CONFLICT`; collection chỉ có 1 document. | ☐ |

## C. Xem phần & lọc theo người xem

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| C1 | T2.5 | I | `GET /tasks/P1/sections` khi chưa có document phần nào | Trả đủ 4 phần ảo `DRAFT`, `revision = 0`; không ghi gì vào DB. | ☐ |
| C2 | §16.10 | I | `outsider` gọi `GET /sections` | Không có phần I (BRIEF); vẫn thấy phần O. | ☐ |
| C3 | §16.10 | I | `res`, `sup`, `free`, `owner` gọi `GET /sections` | Đều thấy phần I. | ☐ |
| C4 | AC10, spec 13.5 | I | `client` gọi `GET /sections` khi CAPTION `SUBMITTED`, MEDIA `INTERNAL_APPROVED`, BRIEF `INTERNAL_APPROVED` | Chỉ trả MEDIA. Không có BRIEF, không có CAPTION. Không lộ trường của phần I trong JSON (kiểm cả nested). | ☐ |
| C5 | AC10 | I | `client` gọi `GET /sections` cho task KOL, PRESS, EVENT_PLAN | KOL: không có `KOL.DEAL` (giá). PRESS: không có `MEDIA_LIST`, `CONTACT_LOG`. EVENT: không có `LOGISTICS`, `RUNSHEET`. | ☐ |
| C6 | T2.5 | I | Response cho `content` | Có `canEdit/canSubmit/canApprove/canReturn`, `ownerSubtaskIds`, `ownerNames` đúng. | ☐ |
| C7 | §11, `requiresClientApproval=false` | I | Task không cần Client duyệt; `client` gọi `GET /sections` | Không có phần nào ở trạng thái chờ Client; phần O dừng ở `INTERNAL_APPROVED`. | ☐ |

## D. Vòng đời phần & duyệt

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| D1 | §5.1, T2.9 | I | Đủ vòng CAPTION: `content` submit → `mgr` approve → `client` approve | `DRAFT → SUBMITTED → INTERNAL_APPROVED → CLIENT_APPROVED`; mỗi bước ghi 1 event. | ☐ |
| D2 | AC9 | I | `content`, `coord`, `free` gọi approve CAPTION `SUBMITTED` | Đều `FORBIDDEN`. | ☐ |
| D3 | AC9 | I | `sup` approve MEDIA; `sup` approve CAPTION | MEDIA → 200; CAPTION (không thuộc subtask của sup) → `FORBIDDEN`. | ☐ |
| D4 | §5.1 | I | `client` approve phần đang `SUBMITTED` | `FORBIDDEN` hoặc `SECTION_INVALID_TRANSITION` (Client chỉ duyệt sau Manager). | ☐ |
| D5 | §5.1 | I | `client` approve/return phần I (`BRIEF` `INTERNAL_APPROVED`) | `FORBIDDEN`. | ☐ |
| D6 | §5.1 | I | `content` submit phần đang `SUBMITTED`; `mgr` approve phần `DRAFT` | `SECTION_INVALID_TRANSITION`. | ☐ |
| D7 | §10 | I | `mgr` return không có `note` / note rỗng | `VALIDATION_ERROR` (`tasks.sectionActions.noteRequired`). | ☐ |
| D8 | AC11, spec 13.6 | I | CAPTION `CLIENT_APPROVED`, MEDIA `INTERNAL_APPROVED`; `client` return MEDIA với note | MEDIA → `RETURNED`, `returnNote` lưu; `media` sửa được lại; CAPTION vẫn `CLIENT_APPROVED`; `media` nhận thông báo. | ☐ |
| D9 | §5.1 reopen | I | `mgr` reopen CAPTION `INTERNAL_APPROVED` khi task cha chưa nộp | → `RETURNED`. `coord` reopen → `FORBIDDEN`. Reopen sau khi task cha đã nộp → `SECTION_INVALID_TRANSITION`. | ☐ |
| D10 | §5.1 phần I | U | BRIEF `INTERNAL_APPROVED` | Được tính là trạng thái cuối. | ☐ |
| D11 | §5.1, `requiresClientApproval=false` | U | Phần O `INTERNAL_APPROVED` | Trạng thái cuối; không set `clientPendingSince`. | ☐ |

## E. Subtask tự động & nộp task cha

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| E1 | §5.3, T3.5 | I | Phần duy nhất của `POST_MEDIA` đạt cuối | Subtask `POST_MEDIA` tự `FINISHED`. | ☐ |
| E2 | §5.3, T3.5 | I | Client trả MEDIA (tiếp E1) | Subtask về `IN_PROGRESS`. | ☐ |
| E3 | §5.3, T3.5 | I | `VIDEO_PUBLISH` sở hữu CAPTION + CHANNELS; chỉ CAPTION đạt cuối | Subtask chưa `FINISHED`; đủ cả hai mới `FINISHED`. | ☐ |
| E4 | AC12, spec 13.7 | I | `coord` nộp P1 khi CAPTION còn `SUBMITTED` | `TASK_SECTIONS_UNAPPROVED`. | ☐ |
| E5 | AC12, §5.3 | I | Mọi phần `INTERNAL_APPROVED`+ nhưng còn subtask tự do chưa xong | `TASK_SUBTASKS_UNFINISHED` (luật cũ vẫn chạy). | ☐ |
| E6 | §16.5 | I | Mọi phần O `CLIENT_APPROVED`, phần I `INTERNAL_APPROVED` | Task cha tự sang trạng thái đã duyệt. Không có duyệt Client cấp task: lúc chờ, task ở `IN_REVIEW`/`reviewStep = CLIENT` nhưng Client duyệt/trả cấp task → `WRONG_APPROVAL_STEP`, chỉ duyệt từng phần. | ☐ |
| E7 | §5.3 | I | `content` (chủ phần, không phải điều phối) nộp task cha | `FORBIDDEN`. | ☐ |
| E8 | §11 bỏ hết vai trò | I | Task POST chỉ có subtask tự do | Nộp task cha theo luồng cũ, không kiểm phần. | ☐ |

## F. Phiên bản & nhật ký

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| F1 | §16.12, T2.7 | I | Submit CAPTION 3 lần (có trả lại giữa các lần) | `task_section_versions` có `versionNo` 1, 2, 3 với snapshot caption thật (lấy từ `PostDocument`). | ☐ |
| F2 | §16.12 | I | Submit `SURVEY.FORM` | Version chứa câu hỏi survey thật. | ☐ |
| F3 | §16.12 | I | Mọi hành động submit/approve/return/reopen | Ghi `task_section_events` gồm actor, action, note, thời điểm. Không có endpoint xoá version/event. | ☐ |
| F4 | §16.13 | I | `content` restore v1 khi CAPTION `RETURNED` | Caption nháp = v1; phần vẫn chưa nộp, phải nộp lại. | ☐ |
| F5 | §16.13 | I | `content` restore khi CAPTION `SUBMITTED`; `free` restore | Đều `FORBIDDEN`. `coord`, `mgr` restore ở mọi trạng thái → 200, phần đã duyệt về `SUBMITTED`. | ☐ |
| F6 | §16.14 | I | `client` gọi `GET /sections/{key}/versions` và `/versions/1` | `FORBIDDEN`. | ☐ |
| F7 | T7.3 | E | Mở `SectionVersionDrawer`, chọn 2 bản so sánh, khôi phục | Hiển thị khác biệt; khôi phục cập nhật nội dung và trạng thái phần. | ☐ |

## G. Thông báo, nhắc, huỷ lịch

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| G1 | §16.7, T4.1 | I | Submit / approve / return / reopen | Mỗi sự kiện tạo in-app notification cho đúng người; `actionUrl` mở trình soạn. | ☐ |
| G2 | §16.7, T4.2 | I | Manager approve phần O (task cần Client duyệt) | Gửi email "Có phần chờ Client duyệt" tới Client, đúng ngôn ngữ vi/en. | ☐ |
| G3 | §16.7, T4.2 | I | Phần bị trả | Email "Phần của bạn bị trả lại" tới chủ phần, kèm note. | ☐ |
| G4 | §16.7, T4.3 | U | Job chạy với: phần A chờ 47h; B chờ 49h chưa nhắc; C chờ 100h, nhắc 20h trước; D chờ 100h, nhắc 50h trước | Chỉ nhắc B và D; cập nhật `clientReminderSentAt`. Không phần nào tự đổi trạng thái. | ☐ |
| G5 | §11, T4.4, T4.5 | I | P1 đã duyệt, post `SCHEDULED`, `scheduledAt` sau 1h; `client` return CAPTION | Task cha về `IN_PROGRESS`; post → `DRAFT`, `scheduledAt = null`; `pub` nhận thông báo. Chạy `PostSchedulePublishJob` với `now` sau giờ cũ → không đăng. | ☐ |
| G6 | T4.4 | I | Post đã `PUBLISHED`, Client trả phần | Post không đổi; thông báo `pub` kèm danh sách post không huỷ được. | ☐ |
| G7 | T4.5 | I | N1 đã lên lịch batch (`SCHEDULED`); `client` return `EMAIL.CONTENT` | `MailBatchService.cancelSystem(batchId)` được gọi; batch bị huỷ; chủ `EMAIL_SEND` nhận thông báo. | ☐ |
| G8 | T4.5 | I | Batch đã gửi xong, Client trả phần | Batch không đổi, không lỗi. | ☐ |

## H. Newsletter

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| H1 | AC13, spec 13.9 | I | `mgr` import `contacts-10.csv` vào G1 | `{imported: 7, skippedNoConsent: 2, skippedSuppressed: 1, skippedInvalid: 0}`; entry có `consent`, `consentSource`, `importedAt`. | ☐ |
| H2 | AC13 | I | CSV có `consent` = `TRUE`, `Yes`, `1`, `y`, rỗng | 3 giá trị đầu nhận; `y` và rỗng bị loại. | ☐ |
| H3 | AC13, §11 | I | CSV có cùng email 2 lần, 1 email sai định dạng | Giữ 1 dòng; dòng sai vào `skippedInvalid`. | ☐ |
| H4 | §10 | I | CSV thiếu cột `consent`; file không phải CSV | `VALIDATION_ERROR` (`mailTemplate.contactImport.invalidFile`). | ☐ |
| H5 | §9.2 | I | `content` (Creator) gọi import | `FORBIDDEN`. `owner` → 200. | ☐ |
| H6 | AC14, spec 13.10 | I | `EMAIL.CONTENT` `CLIENT_APPROVED`, `EMAIL.DESIGN` `INTERNAL_APPROVED`; chủ `EMAIL_SEND` gọi send | `NEWSLETTER_NOT_APPROVED`. | ☐ |
| H7 | AC14 | I | Cả hai `CLIENT_APPROVED`; `content` (không phải chủ `EMAIL_SEND`) gọi send | `FORBIDDEN`. | ☐ |
| H8 | AC14, AC16, AC17, spec 13.10 | I | Cả hai `CLIENT_APPROVED`; chủ `EMAIL_SEND` gửi tới G1 | Tạo batch `kind = NEWSLETTER`; `batchId` lưu trong content `EMAIL.AUDIENCE`; mỗi mail có link `/public/mail/unsubscribe`; From domain BrandHub, tên hiển thị "Brand X". | ☐ |
| H9 | AC14 | I | N1 với `requiresClientApproval = false`, CONTENT và DESIGN `INTERNAL_APPROVED` | Gửi được. | ☐ |
| H10 | T5.7 | I | `send-test` | Chỉ gửi tới email người gọi; không tăng quota tháng. | ☐ |
| H11 | AC15, spec 13.11 | U+I | A1 gói BASIC đã dùng 1.000 trong tháng; gửi tiếp | `MAIL_MONTHLY_QUOTA_EXCEEDED`, response có số còn lại = 0. | ☐ |
| H12 | §16.2 | I | W1 dùng 600, W2 (cùng A1) gửi 500 | Chặn (còn 400); quota tính chung theo agency. | ☐ |
| H13 | AC15 | U | Sang tháng mới theo `Asia/Ho_Chi_Minh` (23:59 ngày cuối → 00:00 ngày 1) | Bộ đếm reset đúng mốc giờ VN. | ☐ |
| H14 | AC15, §11 | I | Còn 50 quota, batch 80 người | 50 gửi, 30 `DEFERRED`; mail đã gửi giữ nguyên. | ☐ |
| H15 | AC15, §16.1 | I | Gửi newsletter 500 mail trong ngày | `MailQuotaService` (100/ngày/workspace) không bị tiêu; mail hệ thống (OTP) vẫn gửi được. Vượt `newsletter.rate.per-day` → phần dư `DEFERRED`. | ☐ |
| H16 | T5.5 | I | Hàng đợi có batch newsletter và mail hệ thống | `deliverNext` ưu tiên mail hệ thống. | ☐ |
| H17 | AC16, §16.6 | I | Người nhận unsubscribe từ newsletter W1; gửi newsletter W2 (cùng C1) | Người đó bị loại ở W2. Mail hệ thống tới người đó không bị suppression theo Client chặn. | ☐ |
| H18 | T5.8 | I | `GET /mail-quota` | Có `monthlyUsed`, `monthlyLimit = 1000`, `planName = BASIC`. | ☐ |
| H19 | §16.3, T5.9 | I | `GET /sections` của N1 sau khi gửi | `EMAIL.REPORT` có đã gửi / thành công / lỗi-bounce / huỷ đăng ký từ batch; không có open/click; chỉ ô nhận xét được lưu. | ☐ |

## I. Xuất file

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| I1 | §16.11, T6.2 | I | `mgr` xuất task PRESS | File DOCX; có `PRESS.RELEASE`, `PRESS.COVERAGE`; **không** có nội dung `MEDIA_LIST`, `CONTACT_LOG`. | ☐ |
| I2 | §16.11 | I | `mgr` xuất task KOL | PDF; không chứa giá trong `KOL.DEAL` (grep text PDF). | ☐ |
| I3 | §16.11 | I | Agency xuất khi có phần chưa `CLIENT_APPROVED` | Phần đó có dấu "Bản nháp"; file có logo Client. | ☐ |
| I4 | §16.11 | I | `client` xuất | Chỉ phần `CLIENT_APPROVED`; không có dấu "Bản nháp". | ☐ |
| I5 | §16.11 | I | `outsider` xuất | `FORBIDDEN`. | ☐ |

## J. Web UI

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| J1 | Spec 13.1–8, T7.5 | E | Luồng POST đầy đủ: Manager tạo subtask → Research/Content/Media/Publishing sửa đúng phần → Editing sửa caption sau khi Content nộp → Manager duyệt từng phần → Client duyệt 1 phần, trả 1 phần → chủ phần sửa, nộp lại → Client duyệt → task cha đã duyệt | Mỗi bước đúng trạng thái; nút hiện theo `can*`. | ☐ |
| J2 | §8, T7.4 | E | `content` mở trình soạn P1 | CAPTION sửa được; MEDIA, CHANNELS, BRIEF hiện nội dung nhưng input disabled + icon khoá + tooltip "Phần của {tên}". | ☐ |
| J3 | §12 | E | Lần lượt tạo các trạng thái khối phần | Đủ: loading skeleton, empty (gợi ý theo vai trò), saving, saved, locked, returned (banner note), approved (badge), error (toast, giữ nội dung chưa lưu). | ☐ |
| J4 | §12, T7.2 | E | Mở trình soạn ở 2 tab, sửa cùng phần, lưu cả hai | Tab sau hiện banner xung đột + nút tải lại; nội dung đang gõ không mất trước khi tải lại. | ☐ |
| J5 | T7.4, §11 | E | Mở SHORT_VIDEO | Có khối `VIDEO.SCRIPT`; `VIDEO.SHOOT`, `VIDEO.EDIT` hiện placeholder; phần vẫn nộp/duyệt được. | ☐ |
| J6 | T8.1 | E | Mở trình soạn từng loại: SURVEY, EVENT_PLAN, PRESS, KOL, WORKSHOP, EMAIL | Route `/workspaces/:id/tasks/:taskId/editor` mở đúng editor; đủ khối phần theo spec §3. | ☐ |
| J7 | T8.4 (chốt 2026-11-10) | E | Mở task EVENT_PLAN / PRESS cũ có `planContent` / `recommendations` | Khối chỉ-đọc "Nội dung cũ" ở trên; không sửa được; dữ liệu cũ không bị đổi. | ☐ |
| J8 | T8.2 | E | Thêm/xoá/sắp xếp dòng trong bảng agenda, vendor, shortlist | Lưu đúng thứ tự; validate trường bắt buộc. | ☐ |
| J9 | T8.6 | E | NewsletterEditor: soạn khối, xem preview, chọn nhóm, gửi test, gửi | Nút gửi disabled khi chưa đủ duyệt (tooltip lý do); preview khớp nội dung. | ☐ |
| J10 | T8.8 | E | Task detail P1 khi 3/4 phần đã duyệt | Hiện "3/4 phần đã duyệt" + nút mở trình soạn (mọi loại, không chỉ POST/SURVEY). | ☐ |
| J11 | §16.15, T8.9 | E | Timeline chiến dịch: 1 subtask quá hạn, 1 phần chờ Client | Hiện trạng thái phần + cờ trễ hạn và cờ chờ Client. | ☐ |
| J12 | T8.10 | E | Client portal: có 2 phần chờ; trả không note; trả có note; duyệt | Trả không note bị chặn ở form; danh sách cập nhật sau thao tác; hết phần → empty state "Chưa có phần nào chờ duyệt". Không thấy phần I. | ☐ |
| J13 | T8.11 | E | Mail templates: import CSV, xem quota | Dialog hiện 4 con số; khu quota hiện `monthlyUsed/monthlyLimit` + tên gói. | ☐ |
| J14 | T8.12 | E | Nút xuất ở trình soạn và portal | Tải file đúng định dạng (DOCX/PDF). | ☐ |
| J15 | T7.1 | E | Lọc task theo 4 loại mới ở `TaskFilterBar`, `MyTasksSection`; tạo offering 3 service type mới | Nhãn đúng, lọc đúng; đơn vị hiển thị video / KOL / bản tin. | ☐ |

## K. Mobile

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| K1 | AC18, spec 13.12, T9.3 | M | `mgr` mở task P1 → tab "Phần" | Thấy nội dung từng phần chỉ-đọc; nút Duyệt / Trả lại theo `canApprove/canReturn`; không có nút sửa. | ☐ |
| K2 | AC18 | M | `mgr` trả phần không note | Bị chặn; có note → gọi API, phần về `RETURNED`. | ☐ |
| K3 | AC18 | M | `client` mở task | Chỉ thấy phần O đủ điều kiện; có nút Duyệt/Trả. | ☐ |
| K4 | AC18 | M | `content` (Creator) mở task | Thấy subtask được giao + phần chỉ-đọc; không có nút duyệt. | ☐ |
| K5 | T9.1 | M | Danh sách task có 4 loại mới; ngôn ngữ EN | Nhãn đúng (không hiện "Chiến dịch" hay mã thô); `EVENT_PLAN` EN = "Event plan", `WORKSHOP` EN = "Workshop". Bộ lọc có 4 loại mới. | ☐ |
| K6 | T9.4 | M | `npm test` mobile | Pass, gồm `TaskDetailScreen.test.tsx`. | ☐ |

## L. i18n & Light/Dark

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| L1 | AC19, T10.1, T10.2 | U | Script so khoá `vi` vs `en` cho `tasks`, `editor`, `campaign`, `mailTemplate`, `client` (web) và locale mobile | Không lệch khoá; đủ namespace AC19 (`tasks.subtaskRoles.*`, `tasks.sections.*`, `tasks.sectionStatus.*`, `tasks.sectionActions.*`, `tasks.types.*`, `campaign.timeline.catalog.*`, `editor.sections.*`, `mailTemplate.contactImport.*`, `mailTemplate.quota.monthly*`). | ☐ |
| L2 | AC19, T10.3 | T | Grep chuỗi tiếng Việt/Anh trong JSX/TSX mới | Không có chuỗi hardcode. | ☐ |
| L3 | AC19, spec 13.13 | E | Đổi vi ↔ en trên mọi trình soạn mới, portal, dialog import, timeline | Không lộ key thô, không tràn/vỡ layout (nhãn EN dài hơn). | ☐ |
| L4 | AC20, spec 13.14, T10.4 | E+T | Chụp light & dark: badge 5 trạng thái, khối khoá, banner chỉ-đọc, banner trả lại, banner xung đột, editor mới, portal | Đủ tương phản (WCAG AA cho chữ); không màu lạc theme. | ☐ |
| L5 | AC20 | T | Grep hex/rgb trong file mới | Không có; chỉ token / `dark:`. | ☐ |

## M. Regression & migration

| ID | Map | Tầng | Bước / Input | Mong đợi | KQ |
|---|---|---|---|---|---|
| M1 | Spec 13.15, §5.3 | I+E | P2 (task cũ): `coord` mở trình soạn, sửa caption/media/kênh, nộp | Như trước: quyền theo `TaskApprovalPolicy.assignee`; luồng duyệt `reviewStep = CLIENT` giữ nguyên. | ☐ |
| M2 | §11 | I | Task cũ đang `IN_REVIEW` trước deploy | Duyệt/trả theo luồng cũ, không bị chặn bởi luật phần. | ☐ |
| M3 | T1.2 | I | Task SURVEY cũ sinh từ `WORKSHOP_SUPPORT` trước đây | Giữ loại SURVEY, mở và sửa bình thường. | ☐ |
| M4 | T1.4 | I | Chạy migration mongosh trên DB test có dữ liệu cũ | Insert task 4 loại mới thành công; `subtaskRole` null/string hợp lệ; 3 collection mới đủ index (unique `{taskId,sectionKey}`, unique `{taskId,sectionKey,versionNo}`); task cũ không đổi. Chạy lại lần 2 không lỗi. | ☐ |
| M5 | T1.4 | T | So `init-mongo.js` với DB sau migration | Validator và index khớp (parity). | ☐ |
| M6 | T5.1 | I | Chạy migration SQL trên Postgres test có dữ liệu cũ | `mail_batches.kind = 'TEMPLATE'` cho bản ghi cũ; cột/bảng mới có; chạy lại không lỗi. | ☐ |
| M7 | T1.9, T6.3 | I | `mvn test` + `mvn package` business-service | Pass. | ☐ |
| M8 | T8.13 | I | `npm run build` + `npm test` web | Pass, không lỗi TS. | ☐ |
| M9 | Luồng cũ | E | Chạy lại E2E sẵn có của task / editor / survey / mail-templates / client portal | Không fail mới. | ☐ |
| M10 | T4.4 | I | `PostSchedulePublishJob` với post của task không có subtask vai trò | Hành vi đăng lịch không đổi. | ☐ |

---

## Kết quả chạy

_Ghi ở T10.5: ngày, lệnh đã chạy, số test pass/fail, ảnh chụp light/dark, việc còn lại._

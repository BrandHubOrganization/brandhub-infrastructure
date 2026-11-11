# Tasks — Subtask theo vai trò & Trình soạn chia phần (DA-1274)

> Bước ③ theo `docs/rule/feature-workflow.md`. Dựa trên `spec.md` + `plan.md` (đã duyệt 2026-11-10).
> Mỗi task ghi `→ plan §x` để đối chiếu. Làm đúng thứ tự; hết mỗi nhóm (T1…T10) phải build + test pass mới sang nhóm sau.

## Kết quả kiểm tra kỹ thuật trước khi tách task (2026-11-10)

**A. Thêm 4 TaskType mới có làm hỏng code khác không**

| Repo | Kết quả | Việc cần làm |
|---|---|---|
| `brandhub-ai-service` | Không tham chiếu `TaskType` / tên loại task nào. | Không đụng. |
| `brandhub-publisher-service` | Không tham chiếu `TaskType`, không đọc collection `tasks`. Chỉ nhận `PublishJobMessage` qua RabbitMQ. | Không đụng. |
| `brandhub-mobile-app` | Không crash: `formatTaskTypePill` có `default`, `TASK_TYPE_LABEL[...] ?? type`, `enumLabel` có `humanize`. Nhưng loại mới hiện thành "Chiến dịch" hoặc mã thô. `taskListHelpers.ts:130` đang dịch `EVENT_PLAN` sang EN là "Workshop" (sai sẵn, sẽ trùng với loại WORKSHOP mới). | T9.1. |
| `brandhub-business-service` | **Hỏng build:** `PackageOfferingValidator.java:19` là `switch` expression không có `default` trên `PackageServiceType` → thêm enum là lỗi compile. **Hỏng runtime:** `CampaignPlanValidator.TASK_TYPES` không có service type mới → `TaskType.valueOf(null)` trong `CampaignTaskStore.draftTask:56`. `WORKSHOP_SUPPORT` hiện map sang `SURVEY`. | T1.1, T1.2. |
| `brandhub-web` | **Hỏng build TS:** `serviceUnits.ts` là `Record<PackageServiceType, string>`. `OfferingEditor.tsx`, `OfferingSummary.tsx`, `mediaPackage.ts` liệt kê cứng service type. `MyTasksSection.tsx`, `TaskFilterBar.tsx`, `TaskWorkflowContent.tsx` switch/list theo TaskType. | T7.1. |
| Mongo validator | `init-mongo.js:241` ràng buộc `tasks.type` bằng enum 5 giá trị → insert task loại mới bị từ chối. | T1.4. |

**B. Huỷ lịch đăng khi Client trả phần**

- Không có hàm huỷ lịch. Lịch đăng chạy bằng `scheduled/PostSchedulePublishJob` (business-service, poll 30s): lấy post `status ∈ {SCHEDULED, APPROVED}` và `scheduledAt <= now`, **chỉ đăng khi task cha `status = FINISHED` và `lastSubmission.outcome = APPROVED`**.
- Vì vậy chỉ cần làm ở business-service, không đụng publisher-service: (1) đưa task cha ra khỏi trạng thái đã duyệt → job tự bỏ qua; (2) đưa post `SCHEDULED/APPROVED` của task về `DRAFT`, xoá `scheduledAt` để phải đặt lịch lại (spec §11). Post đã `IN_PROGRESS/PUBLISHING/PUBLISHED` thì không huỷ được — báo lại cho người phụ trách Đăng bài.
- Email: `MailBatchService.cancelSystem(batchId)` có sẵn. Batch Newsletter được lưu `batchId` trong `content` của phần `EMAIL.AUDIENCE` (không thêm cột `task_id`).

---

## T1. Backend nền — loại task, danh mục, `subtaskRole` (→ plan §1.1, §1.2, §2)

- [x] T1.1 `TaskType.java`: thêm `SHORT_VIDEO, KOL_BOOKING, WORKSHOP, EMAIL_NEWSLETTER`. `PackageServiceType.java`: thêm `SHORT_VIDEO, KOL_BOOKING, EMAIL_NEWSLETTER`.
- [x] T1.2 `PackageOfferingValidator.validateStandardUnits`: thêm đơn vị cho 3 service type mới (đã chốt 2026-11-10: `SHORT_VIDEO → "video"`, `KOL_BOOKING → "KOL"`, `EMAIL_NEWSLETTER → "bản tin"`). `CampaignPlanValidator.TASK_TYPES`: thêm 3 ánh xạ mới và đổi `WORKSHOP_SUPPORT → WORKSHOP` (chỉ ảnh hưởng chiến dịch triển khai sau này; task SURVEY cũ giữ nguyên).
- [x] T1.3 Mới `service/impl/TaskCatalog.java` (repo không có package con `task`, đặt phẳng như các service khác): map tĩnh `TaskType → List<RoleDef(role, List<SectionDef(key, visibility)>)>` đúng bảng spec §3 (8 loại). Hàm `roles(type)`, `sectionsOf(type)`, `owns(role, sectionKey)`, `isValidRole(type, role)`. Unit test: đếm vai trò/phần từng loại, `POST_EDITING` sở hữu `POST.CAPTION`, `VIDEO_PUBLISH` sở hữu 2 phần.
- [x] T1.4 Migration mongosh `docs/database/migrations/2026-11-1x-subtask-role-sections.js`: `collMod tasks` thêm 4 giá trị vào enum `type` + `subtasks.items.subtaskRole: ['string','null']`; tạo `task_sections` (unique `{taskId,sectionKey}`, `{workspaceId,status}`, `{status,clientPendingSince}`), `task_section_versions` (unique `{taskId,sectionKey,versionNo}`), `task_section_events` (`{taskId,at}`). Sửa `init-mongo.js` cho khớp (parity).
- [x] T1.5 `TaskDocument.Subtask`: thêm `String subtaskRole` cuối record + constructor cũ ủy quyền (`subtaskRole = null`). Build xanh, không đổi chỗ gọi cũ.
- [x] T1.6 Mới `controller/TaskCatalogController.java`: `GET /api/v1/task-catalog/{taskType}` (đăng nhập là đủ). Test controller: loại hợp lệ trả đúng; loại sai → `VALIDATION_ERROR`.
- [x] T1.7 `CampaignSubtaskService` / `CampaignSubtaskController`: `Details`/`Row` thêm `subtaskRole`; tạo subtask validate bằng `TaskCatalog.isValidRole` (AC3); `PATCH /{id}/status` từ chối `FINISHED` khi `subtaskRole != null`. Test AC2, AC3.
- [x] T1.8 `ErrorCode.java`: thêm `SECTION_INVALID_TRANSITION, TASK_SECTIONS_UNAPPROVED, NEWSLETTER_NOT_APPROVED, MAIL_MONTHLY_QUOTA_EXCEEDED`.
- [x] T1.7b (phát sinh) `dto/campaign/CampaignWorkItem.type` có `@Pattern` cứng 5 loại → thêm 4 loại mới, nếu không task WORKSHOP sinh từ chiến dịch bị từ chối.
- [x] T1.9 Chạy `mvn test` business-service — pass (2026-11-10: 1706 test, 0 fail, 91 skip).

## T2. Backend phần (section) (→ plan §1.3)

- [x] T2.1 Mới `document/TaskSectionDocument.java` + repository (field theo plan §1.3; `revision` long, `status` enum `SectionStatus {DRAFT, SUBMITTED, INTERNAL_APPROVED, CLIENT_APPROVED, RETURNED}`).
- [x] T2.2 Mới `TaskSectionVersionDocument.java` (`task_section_versions`) + `TaskSectionEventDocument.java` (`task_section_events`). Không có hàm xoá.
- [x] T2.3 Mới `SectionPolicy.java`: `canView/canEdit/canSubmit/canApprove/canReturn/canReopen/canRestore` theo spec §4, §5.2, §16.10, §16.13; luật chồng phần `POST.CAPTION`/`VIDEO.CAPTION`; phần không chủ → điều phối/Manager; hợp quyền nhiều subtask; subtask `CANCELLED` mất chủ. Dùng lại `TaskApprovalPolicy.Context/Snapshot`, `CampaignSubtaskService.supervisor`.
- [x] T2.4 Unit test `SectionPolicyTest`: mỗi dòng ma trận §4 một case; AC4, AC5, AC6, AC7, AC9; Creator không tham gia task không thấy phần I (§16.10); Client không thấy phần I và phần O dưới `INTERNAL_APPROVED` (AC10).
- [x] T2.5 Mới `SectionService.list(taskId, viewer)`: phần chưa có document → ảo `DRAFT`, chủ = điều phối (không backfill); lọc theo `canView`; kèm `can*`, `ownerSubtaskIds`, `ownerNames`.
- [x] T2.6 `SectionService.patch(key, content, expectedRevision)`: CAS `findAndModify {taskId, sectionKey, revision}`; lệch → `TASK_REVISION_CONFLICT`; tạo document lười ở lần ghi đầu (upsert, bắt duplicate key → conflict); sửa phần đã duyệt → `SUBMITTED`; validate `content` theo schema phần (spec §3). Với POST/SURVEY: chỉ trạng thái/revision, nội dung đi qua T3.
- [x] T2.7 `submit / approve / return / reopen`: máy trạng thái §5.1 (sai → `SECTION_INVALID_TRANSITION`); `return` bắt buộc note (`VALIDATION_ERROR`); `submit` ghi `task_section_versions` (snapshot nội dung thật, gồm POST/SURVEY); mọi hành động ghi `task_section_events`; `approve` nội bộ phần O → set `clientPendingSince`; `requiresClientApproval=false` → `INTERNAL_APPROVED` là cuối.
- [x] T2.8 `versions / version(no) / restore(no)`: Client bị chặn (§16.14); restore chép vào nháp, phần phải nộp và duyệt lại (§16.13).
- [x] T2.9 Mới `TaskSectionController.java`: endpoint spec §9.2 + versions/restore. Integration test chuyển trạng thái đủ vòng `DRAFT → SUBMITTED → INTERNAL_APPROVED → CLIENT_APPROVED → RETURNED` và test case spec 8 (2 phiên cùng lưu).
- [x] T2.10 Chạy `mvn clean test -Dapi.version=1.44` business-service — pass (2026-11-10: 1737 test, 0 fail, 91 skip; `SectionServiceMongoTest` 11/11 pass trên Mongo thật). `SectionServiceMongoTest` (Testcontainers `mongo:7`) tự skip khi Testcontainers không nói chuyện được với Docker: Docker 29 từ chối API mặc định của Testcontainers 1.20.4, nên thiếu cờ `-Dapi.version=1.44` thì 11 test này skip (102 skip).
  - Khớp validator migration 2026-11-10: note trả/mở lại ≤ 2000 ký tự; event Client ghi `CLIENT_APPROVE` / `CLIENT_RETURN`.
- Ghi chú T2 (lệch nhỏ so với plan, đã chốt khi code):
  - Không tạo Spring Data repository: mọi truy cập Mongo nằm trong `SectionStore` (MongoTemplate, như `CampaignSubtaskService`), vì CAS/upsert cần `findAndModify`.
  - `_id` phần = `taskId|sectionKey`, phiên bản = `taskId|sectionKey|versionNo` → lần ghi đầu đồng thời không thể sinh 2 document (B20) dù chưa chạy migration index.
  - Bỏ `lastEditorRole` (không ai đọc). Luật chồng phần nằm ở `SectionPolicy.EDITING_ROLES` (`POST.CAPTION → POST_EDITING`); VIDEO không có vai trò biên tập nên không áp.
  - Schema trường từng phần: `TaskCatalog.fields(key)` (TEXT/NUMBER/LIST; `VIDEO.SHOOT`/`VIDEO.EDIT` tự do). Web (T7/T8) dùng đúng tên trường này.
  - Phần POST/SURVEY: `PATCH` chỉ nhận content `{}` (bump revision + luật khoá); nội dung thật ghi qua T3. Snapshot version và restore đọc/ghi `posts` (`content_text, hashtags, media, target_platforms, scheduled_at`) / `surveys` (`title, description, questions`).
  - Client trả phần được cả khi phần đã `CLIENT_APPROVED` (cần cho G5); đưa task cha về `IN_PROGRESS` để T4.5.
  - Phần không chủ: chỉ Manager duyệt nội bộ; việc "duyệt cùng lúc khi nộp task cha" để T3.4.

## T3. Backend gắn luồng cũ (→ plan §1.2, §1.4)

- [x] T3.1 `TaskPostController` / service lưu bài: diff `SavePostRequest` với `PostDocument` → tập phần bị đổi (`caption/hashtags`→CAPTION, media→MEDIA, `targetPlatforms/scheduledAt`→CHANNELS); trường thuộc phần không có quyền → `FORBIDDEN` (AC8); bump revision từng phần đổi; response thêm `sections`. Chỉ bật khi task có subtask vai trò; không có → giữ `TaskApprovalPolicy.assignee`.
- [x] T3.2 SHORT_VIDEO dùng chung endpoint post với key `VIDEO.CAPTION/VIDEO.CHANNELS`; `targetPlatforms` giới hạn TikTok/Instagram/Facebook.
- [x] T3.3 `SurveyController POST /survey`: kiểm `SURVEY.FORM` khi task có subtask vai trò. WORKSHOP dùng cùng form builder: kiểm phần `WORKSHOP.REGISTRATION`.
- [x] T3.4 `TaskApprovalService.submit`: thêm `TASK_SECTIONS_UNAPPROVED` (AC12); task có subtask vai trò bỏ bước `reviewStep = CLIENT`; khi mọi phần O đạt trạng thái cuối → gọi luồng chuyển task cha sang đã duyệt hiện có (§16.5). Test regression case spec 15 (task cũ).
- [x] T3.5 `CampaignSubtaskService.syncRoleSubtasks(taskId)`: gọi sau mỗi chuyển trạng thái phần; FINISHED khi đủ phần cuối, về `IN_PROGRESS` khi bị trả/mở lại (§5.3).
- [x] T3.6 `CampaignTaskStore.draftTask`: sau khi tạo task cha, sinh subtask theo `TaskCatalog` (assignee null, `dueDate` = hạn task cha, TODO) (§16.9). Test deploy chiến dịch sinh đúng số subtask.
- [x] T3.7 `TaskSampleSeeder`: thêm 1 task POST có đủ 5 subtask vai trò để demo.
- [x] T3.8 Chạy `mvn clean test -Dapi.version=1.44` business-service — pass (2026-11-10: 1757 test, 0 fail, 91 skip). Test mới: `TaskApprovalSectionsTest` (E4–E8, chốt task theo phần), `TaskPostSectionsTest` (B1–B3, B15, B19 merge, map video), `SectionServiceMongoTest` +3 (E1–E3, chặn/bump phần khi lưu bài), `CampaignTaskStoreTest` +1 (A7).
- Ghi chú T3 (lệch nhỏ so với plan, đã chốt khi code):
  - "Task có subtask vai trò" = còn ít nhất một subtask có `subtaskRole` chưa `CANCELLED` (`SectionPolicy.roleTask`). Huỷ hết vai trò → luồng cũ (spec §11).
  - Lưu bài khi có vai trò: bỏ kiểm `assignee`, thay bằng quyền EDIT từng phần bị đổi; lưu không đổi trường nào vẫn cần quyền sửa ít nhất một phần của bài. Bump revision phần chạy trong cùng transaction với bài (`SectionService.editSections`). Lưu theo phần (§5.4, chốt 2026-11-10): request gửi thêm `sectionRevisions {sectionKey: revision đã đọc}` cho các phần người đó sửa → BE chỉ ghi trường của các phần đó (phần còn lại giữ giá trị đang lưu), CAS theo revision từng phần, không kiểm `expectedRevision`/`expectedPostContentVersion` → hai người sửa hai phần khác nhau không chặn nhau. Không gửi `sectionRevisions` → luồng cũ (kiểm `workflowRevision`, ghi cả bài). Survey/Workshop chỉ có 1 phần form nên không cần.
  - SHORT_VIDEO dùng chung luồng post ở mọi chỗ trước đây chỉ POST (`TaskApprovalPolicy.postLinked`). Media của video thuộc `VIDEO.EDIT`. Giới hạn kênh TikTok/Instagram/Facebook áp cho mọi task SHORT_VIDEO.
  - Nộp task có vai trò: bỏ bước Manager cấp task (phần đã duyệt từng phần). Subtask vai trò không tính vào `TASK_SUBTASKS_UNFINISHED` (chúng chỉ FINISHED sau khi Client duyệt); subtask tự do vẫn tính. Phần không chủ được duyệt nội bộ luôn khi nộp (spec §4, event `APPROVE` note `submit`).
  - Nếu mọi phần đã cuối lúc nộp → task `FINISHED`/`APPROVED` ngay. Nếu còn phần O chờ Client → task `IN_REVIEW`, `reviewStep = CLIENT` (giữ enum validator) làm trạng thái chờ; Client không duyệt/trả cấp task (`WRONG_APPROVAL_STEP`). Client duyệt phần cuối cùng → task đóng `APPROVED` qua luồng cũ (ghi decision CLIENT APPROVE). Client trả một phần khi task đang chờ → task về `IN_PROGRESS` (decision CLIENT REJECT, note = ghi chú trả). Trả sau khi task đã `FINISHED` (huỷ lịch) vẫn để T4.5.
  - Tên subtask sinh từ danh mục = tên vai trò tiếng Việt của spec §3 (`TaskCatalog.RoleDef.name`, cũng trả qua `TaskCatalogController`). Id subtask ổn định theo `taskId + role`.
  - Seeder: task POST đang làm đầu tiên chưa vào duyệt giữ 5 subtask vai trò (gán Creator) + 1 subtask tự do.
- Chốt với user khi rà T1–T3 (2026-11-10):
  - Lưu bài theo revision từng phần: làm ngay trong T3 (ghi chú trên).
  - Trạng thái chờ Client giữ `IN_REVIEW` + `reviewStep = CLIENT`; Client chỉ duyệt/trả từng phần (test E6 sửa câu chữ cho khớp).
  - Bỏ bước Manager duyệt cấp task với task có vai trò; phần không chủ duyệt cùng lúc khi điều phối nộp.
  - Tên subtask sinh từ danh mục giữ tiếng Việt trong DB; web/mobile hiển thị nhãn i18n theo `subtaskRole` (T7/T9/T10).

## T4. Backend thông báo, nhắc, huỷ lịch (→ plan §1.6, §1.7)

- [x] T4.1 `UserNotificationService.sectionEvent(...)`: in-app cho submit/approve/return/reopen (`actionUrl` = trình soạn).
- [x] T4.2 Email qua `MailSendService.sendSystem` + 2 template hệ thống mới (vi/en): "Có phần chờ Client duyệt", "Phần của bạn bị trả lại".
- [x] T4.3 Mới `scheduled/SectionReminderJob` (mỗi giờ): phần `INTERNAL_APPROVED`, `clientPendingSince < now-48h`, `clientReminderSentAt` null hoặc > 48h → email nhắc, cập nhật `clientReminderSentAt`. Không tự duyệt. Unit test chọn đúng phần.
- [x] T4.4 Mới `PostService.cancelTaskSchedule(workspaceId, taskId)` (business-service): post của task có `status ∈ {SCHEDULED, APPROVED}` → `DRAFT`, `scheduledAt = null`; trả danh sách post không huỷ được (`IN_PROGRESS/PUBLISHING/PUBLISHED`). **Không đụng publisher-service.**
- [x] T4.5 `SectionService.return` khi người trả là Client: nếu task cha đang ở trạng thái đã duyệt → đưa về `IN_PROGRESS` (để `PostSchedulePublishJob` tự bỏ qua); gọi T4.4 với POST/SHORT_VIDEO; với EMAIL_NEWSLETTER gọi `MailBatchService.cancelSystem(batchId)` nếu batch còn `QUEUED/SCHEDULED`; thông báo chủ `POST_PUBLISHING`/`VIDEO_PUBLISH`/`EMAIL_SEND`. Test: post SCHEDULED về DRAFT, job không đăng.

- Ghi chú T4 (2026-11-10):
  - T4.2: `MailSendService.sendSystem` là đường broadcast của Admin (template `ADMIN_SYSTEM_BROADCAST`), không gửi được cho từng người. Mail phần đi qua `MailService` (cùng đường với OTP, lời mời; tự chọn vi/en theo `workingLanguage`). Hai mail mới: `sendSectionAwaitingClientEmail` và `sendSectionReturnedEmail`, có escape note.
  - Thông báo do `SectionNotifier` gửi; lỗi chỉ ghi log, không làm hỏng thao tác trên phần. Người nhận:
    - nộp: supervisor của chủ phần (không phải điều phối); nếu không có thì Manager;
    - duyệt: chủ phần, và Client nếu phần là O;
    - Client duyệt: chủ phần và điều phối;
    - trả: chủ phần (email kèm note), cộng điều phối khi Client trả;
    - mở lại: chủ phần.
  - Phần không chủ được duyệt lúc nộp task cũng gửi mail cho Client.
  - T4.3: `SectionReminderJob` chạy theo `app.section-reminders.cron` (mặc định mỗi giờ). Job ghi `clientReminderSentAt` trước rồi mới gửi, nên không nhắc trùng khi chạy nhiều instance.
  - T4.5: `settleSections` trả `true` khi Client trả phần của task `FINISHED`/`APPROVED`.
    - Task về `IN_PROGRESS` với `lastSubmission.outcome = REJECTED`. Nếu chiến dịch đã `COMPLETED` thì bỏ qua bước này.
    - Sau đó `SectionService` huỷ lịch: post qua `PostService.cancelTaskSchedule`; newsletter qua `MailBatchService.cancelForTask`, huỷ batch `SCHEDULED`/`QUEUED`. Không dùng `cancelSystem` vì hàm đó chỉ nhận batch hệ thống không có workspace.
    - `batchId` của newsletter chỉ có sau T5.7.
  - Test: G1–G3 `SectionNotifierTest`; G4, G5, G6 `SectionServiceMongoTest` (Mongo thật, có chạy `PostSchedulePublishJob`); reopen ở `TaskApprovalSectionsTest`.
  - G7/G8: đã chạy trên bản sao schema Postgres local (`mailtest_tmp`, xoá sau khi chạy), pass. Test chuyển sang `NewsletterPostgresTest` ở T5 vì huỷ batch nay giới hạn theo workspace.
  - `mvn test`: 1768 test, 0 fail, 92 skip.

## T5. Backend Newsletter (→ plan §0.4, §1.5, §2)

- [x] T5.1 Migration SQL `docs/database/migrations/2026-11-1x-newsletter.sql` (additive như mẫu 11-06): `mail_batches.kind VARCHAR(16) NOT NULL DEFAULT 'TEMPLATE'`; `mail_suppressions.client_profile_id UUID` + index; bảng `newsletter_monthly_usage(agency_id, month, used, PK(agency_id, month))`. Báo user tự chạy trước khi merge.
- [x] T5.2 `MailRecipientGroupDocument.Entry`: thêm `consent, consentSource, importedAt`.
- [x] T5.3 `MailRecipientController POST /mail-recipient-groups/import` (multipart): `commons-csv`, cần cột `email,name,consent`, dedupe, loại không consent / suppressed / sai định dạng, trả 4 con số (AC13). Test case spec 9.
- [x] T5.4 Mới `NewsletterQuotaService`: đếm theo `agency_id` + tháng (`Asia/Ho_Chi_Minh`); limit từ gói (`newsletter.quota.basic|pro|enterprise` = 1000/10000/50000); `newsletter.rate.per-day`. Thêm config vào `application.yml`. Unit test hết quota (case spec 11).
- [x] T5.5 `MailDeliveryService`: batch `kind = NEWSLETTER` dùng `NewsletterQuotaService` thay `MailQuotaService`; hết quota giữa batch → `DEFERRED`; `deliverNext` ưu tiên batch hệ thống.
- [x] T5.6 Suppression theo Client: `MailSuppressionStore.isSuppressedForClient`; unsubscribe từ mail Newsletter ghi `client_profile_id`. Mail hệ thống giữ logic cũ.
- [x] T5.7 Mới `NewsletterService`: `send` (AC14 → `NEWSLETTER_NOT_APPROVED`, quyền, quota → `MAIL_MONTHLY_QUOTA_EXCEEDED`), render blocks `EMAIL.CONTENT`/`EMAIL.DESIGN` bằng renderer mail-templates, tạo batch `kind=NEWSLETTER`, sender name = `ClientProfile.displayName` (AC17), link unsubscribe (AC16), lưu `batchId` vào content `EMAIL.AUDIENCE`. `send-test` dùng `MailSendService.sendTest`. Endpoint `POST /tasks/{taskId}/newsletter/send|send-test`. Test case spec 10.
- [x] T5.8 `MailSendController GET /mail-quota`: thêm `monthlyUsed, monthlyLimit, planName`.
- [x] T5.9 `EMAIL.REPORT`: `SectionService.list` gắn số liệu từ `MailBatchService.detail(batchId)`; chỉ lưu ô nhận xét.

- Ghi chú T5 (2026-11-10):
  - T5.1: migration `2026-11-10-newsletter.sql`. Khác plan:
    - `mail_batches.kind` đã có sẵn (`SEND`/`TEST`, mặc định `SEND`), nên chỉ mở rộng CHECK thêm `NEWSLETTER`, không thêm cột `DEFAULT 'TEMPLATE'`.
    - Một bảng `newsletter_usage(agency_id, period, used)` thay cho `newsletter_monthly_usage`: `period` là `YYYY-MM` cho quota tháng và `YYYY-MM-DD` cho giới hạn ngày.
    - Đã chạy 2 lần trên bản sao có dữ liệu của DB local: không lỗi, 9 batch cũ vẫn `SEND` (M6). **User tự chạy trên DB thật trước khi merge.**
  - T5.3: `POST /mail-recipient-groups/import` nhận `file` và `name` (tạo nhóm mới) hoặc `groupId` (thêm vào nhóm có sẵn). Chỉ Owner/Manager. Tối đa 2 MB, nhóm import tối đa `newsletter.max-recipients` (5000). Trùng email giữ một dòng, không tính vào 4 con số. Email bị chặn (của workspace hoặc của Client) vào `skippedSuppressed`.
  - Nhóm tạo tay: entry có thêm `consent` (tuỳ chọn). Newsletter chỉ gửi cho entry `consent = true`; nhóm cũ không có consent sẽ không nhận Newsletter.
  - T5.4: gói lấy theo chủ agency (`agencies.owner_id` → `user_subscriptions` → `subscription_plans`). Agency không có gói tính là BASIC. `newsletter.rate.per-day` mặc định 2000/agency/ngày.
  - T5.5: hết quota tháng thì delivery chờ đến ngày 1 tháng sau; hết giới hạn ngày thì chờ đến 0h hôm sau (giờ VN). `claimNext` lấy mail không phải Newsletter trước. Batch Newsletter không tính vào giới hạn mail đang chờ (`mail.max-pending-per-workspace`) của mail thường.
  - T5.6: unsubscribe từ Newsletter dùng token riêng (`newsletter:<workspaceId>`), ghi vào danh sách chặn của workspace kèm `client_profile_id` của Client trong workspace. Kiểm tra Newsletter: danh sách của workspace hoặc cùng Client ở bất kỳ workspace nào. Mail hệ thống và mail workspace giữ logic cũ.
  - T5.7: `NewsletterService` (`service/impl`), endpoint `POST /api/v1/workspaces/{ws}/tasks/{taskId}/newsletter/send|send-test`.
    - Nội dung lấy từ `blocks` của `EMAIL.DESIGN`; nếu trống thì lấy của `EMAIL.CONTENT`. Tiêu đề lấy `EMAIL.CONTENT.subject`. Dựng bằng `MailBlockRenderer`.
    - From vẫn là địa chỉ BrandHub (`app.mail-from`), chỉ đổi tên hiển thị thành `ClientProfile.displayName` (thêm `OutgoingMail.fromName`). Reply-To là email người gửi.
    - Mỗi mail có link unsubscribe riêng ở footer và header `List-Unsubscribe`.
    - `batchId` ghi vào `EMAIL.AUDIENCE` trước khi tạo batch (CAS theo revision), nên hai lần gửi cùng lúc chỉ một lần qua. Đã có batch chưa huỷ thì không gửi lại.
    - `batchId` do server giữ: PATCH hay restore phần `EMAIL.AUDIENCE` không xoá, không đổi được nó.
    - `send-test`: không dùng `MailSendService.sendTest` như plan, vì hàm đó cần id của mail template, còn Newsletter dựng nội dung từ các phần. Gửi ngay cho người gọi, không tạo batch, không tính quota. Giới hạn 10 lần mỗi giờ cho mỗi task, đếm bằng Redis. Lần vượt trả `RATE_LIMIT_EXCEEDED`. Nếu Redis lỗi thì vẫn cho gửi, giống `ChatRateLimiter`. Thêm ngày 2026-11-10 theo xác nhận của user.
  - T4.5 sửa thêm: `MailBatchService.cancelForTask(workspaceId, batchId)` chỉ huỷ batch của đúng workspace.
  - T5.8: `GET /mail-quota` thêm `monthlyUsed`, `monthlyLimit`, `planName`.
  - T5.9: `EMAIL.REPORT` có thêm `content.stats` (`total, sent, failed, suppressed, unsubscribed, status`), đọc thẳng từ batch. `unsubscribed` = người đã nhận rồi huỷ đăng ký sau thời điểm gửi. Không có open/click. Chỉ lưu `comment`.
  - Test:
    - H1–H5 `MailRecipientServiceTest`; H6–H11 `NewsletterServiceTest`; H14, H15, H17 (nhánh worker) `MailDeliveryServiceTest`; H19 và giữ `batchId` `SectionServiceMongoTest`.
    - H11–H13, H15–H17, H19, G7, G8 trên Postgres thật: `NewsletterPostgresTest` (cần `BRANDHUB_MAIL_ISOLATED_TEST=true`). Đã chạy trên bản sao schema local, 6/6 pass.
    - H18: `MailSendControllerTest.quotaAddsTheNewsletterMonth_H18`.
  - `mvn test`: 1791 test, 0 fail, 97 skip (gồm 6 test Postgres Newsletter khi chạy không có DB riêng).

## T6. Backend xuất file (→ plan §0.2, §1.8)

- [x] T6.1 `pom.xml` business-service: thêm `org.apache.poi:poi-ooxml` (đã được duyệt).
- [x] T6.2 Mới `SectionExportService` + `GET /tasks/{taskId}/export`: PRESS → DOCX (poi), loại khác → PDF (openpdf theo mẫu `PackageExportRenderer`); chỉ phần O; logo `ClientProfile.logoUrl`; agency xuất mọi trạng thái, phần chưa `CLIENT_APPROVED` đóng dấu "Bản nháp"; Client chỉ phần `CLIENT_APPROVED`. Test: file không chứa nội dung phần I.
- [x] T6.3 `mvn test` + `mvn package` business-service — pass.
- Ghi chú T6 (2026-11-10):
  - T6.1: `poi-ooxml` 5.3.0.
  - T6.2: `SectionService.exportable` lấy phần O. `SectionExportService` dựng file. Endpoint `GET /api/v1/workspaces/{ws}/tasks/{taskId}/export` nằm trong `TaskExportController`.
  - Quyền xuất (`SectionPolicy.mayExport`): Client, Owner, Manager, người tham gia task. Creator không tham gia → `FORBIDDEN`. Người ngoài workspace bị chặn ở bước kiểm tra thành viên (mã lỗi có sẵn).
  - Khác task: "đã duyệt xong" dùng `isFinal`. Task có Client duyệt thì đúng là `CLIENT_APPROVED`. Task bỏ bước Client duyệt thì `INTERNAL_APPROVED` cũng tính là xong.
  - Logo: chỉ đọc từ bucket (`image/client-logos/<profileId>/…`), đổi WebP sang PNG. `logoUrl` dán từ ngoài không được tải, để tránh SSRF; khi đó file không có logo.
  - Nội dung mỗi phần in dạng `Nhãn: giá trị`, HTML được bỏ thẻ.
    - Tiêu đề phần và tên trường dùng nhãn tiếng Việt; user chốt ngày 2026-11-10.
    - Ẩn `batchId` và `recipientGroupIds`.
    - Có test bắt buộc mọi section trong catalog đều có nhãn.
  - User đã xác nhận ngày 2026-11-10:
    - Task bỏ bước Client duyệt: phần `INTERNAL_APPROVED` tính là đã xong.
    - Logo dán từ link ngoài: bỏ qua, không tải.
    - Nhóm người nhận cũ chưa có cờ đồng ý: không nhận Newsletter, phải import lại.
  - Test:
    - `SectionServiceMongoTest`: I1–I5 ở tầng chọn phần.
    - `SectionExportServiceTest`: DOCX/PDF, dấu "Bản nháp", logo, URL ngoài không bị gọi.
    - `mvn clean package`: 1800 test, 0 fail, 97 skip; BUILD SUCCESS.

## T7. Web nền + trình soạn POST (→ plan §3)

- [x] T7.1 Types: `src/types/task.ts`, `src/pages/campaign/types.ts` (4 TaskType, `subtaskRole`, `TaskSection`); `media-package/types/mediaPackage.ts`, `serviceUnits.ts`, `OfferingEditor.tsx`, `OfferingSummary.tsx` (3 service type mới); `MyTasksSection.tsx`, `TaskFilterBar.tsx`, `TaskWorkflowContent.tsx` (nhãn + lọc loại mới). `npm run build` không lỗi TS.
  - Ghi chú T7.1 (2026-11-10): web làm ở worktree `brandhub-web-T7`, branch `feat/DA-1274-subtask-role-workspaces` (từ `origin/develop`). `TaskType` chỉ còn một nguồn (`src/types/task.ts`; `pages/campaign/types.ts` re-export). Thêm `POST_EDITOR_TYPES` (POST, SHORT_VIDEO) để dùng ở T7.4. Thêm luôn nhãn vi/en cho 4 loại task và 3 service type (tên, đơn vị, số lượng, gợi ý hạng mục), nếu không form gói hiện mã thô. `mediaPackage.editor.selected` đổi `/4` cứng thành `{{total}}`. Type `TaskSection`, `TaskSectionVersion`, `SectionStatus` ở `src/types/task.ts`; `subtaskRole` thêm vào `SubtaskDetails` và `TimelineSubtask`.
  - API khác prompt: khôi phục là `POST /sections/{key}/restore/{n}` (body `{expectedRevision}`), không phải `/versions/{n}/restore`.
- [x] T7.2 Mới `src/services/taskSectionService.ts`, `src/hooks/useTaskSections.ts` (React Query; gửi `expectedRevision`; `TASK_REVISION_CONFLICT` → banner tải lại).
  - Ghi chú T7.2 (2026-11-10, chốt UI với user): lưu = tự lưu 30 giây + nút Lưu từng phần; xung đột = dừng tự lưu phần đó, giữ bản đang gõ, banner "Tải lại" (bấm mới lấy bản server). `expectedRevision` = revision lúc bắt đầu sửa (không phải revision mới nhất trong cache), để không đè lặng lẽ thay đổi của người khác. Nộp = lưu trước rồi nộp. Logic nháp tách ra `src/hooks/sectionDrafts.ts` (test `tests/unit/sectionDrafts.test.ts`; web không có jsdom nên chỉ test hàm thuần). Thêm `errorCode()` vào `src/utils/error.ts`.
- [x] T7.3 Mới `src/components/task-sections/`: `SectionFrame`, `SectionStatusBadge`, `SectionReturnDialog`, `SectionVersionDrawer` (list, so sánh, khôi phục). Đủ UI states spec §12.
  - Ghi chú T7.3 (2026-11-10): web b160d58. Khoá input bằng `<fieldset disabled>` (không tự tính quyền, chỉ theo `canEdit`). Lý do khoá hiện ở header + `title` (repo không có component tooltip). So sánh phiên bản = diff từng dòng tự viết (`lineDiff.ts`, LCS, có test), chọn 2 bản bất kỳ hoặc "Bản hiện tại". Khôi phục có hộp xác nhận. `SectionFrame` nhận `saveBinding` để phần POST/VIDEO lưu qua trình soạn bài (T7.4). Màu trạng thái dùng thang Tailwind có `dark:` như `STATUS_CONFIG`, không hex.
- [x] T7.4 `pages/editor`: bọc vùng Caption/Media/Channels bằng `SectionFrame`, disable theo `can*`; thêm khối `POST.BRIEF`; SHORT_VIDEO thêm `VIDEO.SCRIPT` + placeholder `VIDEO.SHOOT`, `VIDEO.EDIT` (props `section`, cho Ân gắn code).
  - Ghi chú T7.4 (2026-11-10): web adbfc6d. Lưu bài của task có subtask vai trò gửi `sectionRevisions` chỉ cho phần đã sửa (so với bản đã lưu, khớp `changedSections` backend), rồi lấy `TaskPostResponse.sections` cập nhật danh sách phần. Xung đột → banner trên phần đó, giữ chữ đang gõ, "Tải lại" đọc lại cả bài. Hashtag dời lên trong khung CAPTION. Khác plan: media của SHORT_VIDEO là `VIDEO.EDIT` (theo backend `postKeys`) nên `VIDEO.EDIT` bọc vùng media, chỉ `VIDEO.SHOOT` là khung giữ chỗ (`SectionSlot`, nhận `children` cho Ân). Mở trình soạn cho SHORT_VIDEO qua `opensPostEditor()` ở TaskRowActions/TaskStartAction/TaskApprovalSection/TaskInlineDetails/TaskWorkflowContent/TaskStatusControl/useTaskApproval/CampaignTaskGroups/MyTasksSection. Cần xem ở T7.5: người chỉ có quyền BRIEF thì `canEdit` bài = false nên trình soạn hiện thông báo khoá (khối BRIEF vẫn sửa được).
- [x] T7.5 E2E web luồng POST đầy đủ (test case spec 1–8): Manager tạo subtask → Content/Editing/Media/Publishing sửa đúng phần → duyệt nội bộ → Client duyệt/trả → nộp task.
  - Ghi chú T7.5 (2026-11-11): web a6f6b7e, business f2497b5 (merge điểm thêm 3846432). Dữ liệu test trên Atlas `brandhub`, workspace "Sabeco x Yeah1 Network" (`3d34f7f0-06ad-4b10-8db1-16b73e7e4967`), task `[E2E] Bài đăng ra mắt Bia Saigon Special` (`3d8ac139-50e2-3eeb-b58e-d7f3186d5953`) — giữ lại cho demo.
  - Chạy đủ test case spec §13.1–8 qua trình duyệt (nhiều phiên song song theo vai trò) + gọi API trực tiếp để kiểm chứng response: tạo subtask từ danh mục (AC1–2), Content chỉ sửa CAPTION được (AC4, AC8 — lưu MEDIA qua API trả `FORBIDDEN`), Biên tập khoá đến khi Content nộp (§3.1), subtask tự do không sửa được phần nào (AC5), xung đột `TASK_REVISION_CONFLICT` giữ bản đang gõ (§5.4), Manager duyệt/trả có ghi chú bắt buộc (AC9), Client chỉ thấy phần O đã duyệt — phần BRIEF không có trong response (AC10, vá thêm `TaskPostService.clientView` để field bài viết cũng lọc theo phần, không chỉ danh sách `sections`), nộp task cha bị chặn khi còn phần chưa duyệt (AC12) với thông báo đúng mã lỗi (trước đó web thiếu khoá i18n cho `TASK_SUBTASKS_UNFINISHED`/`TASK_SECTIONS_UNAPPROVED`, đã bổ sung vi+en), khôi phục phiên bản cũ đưa phần về `SUBMITTED` (§16.13), subtask tự FINISHED khi mọi phần final (§5.3).
  - **Lỗi tìm thấy & đã sửa**: Client trả lại 1 phần sau khi task đã `FINISHED` (mọi phần `CLIENT_APPROVED`) gọi `TaskApprovalService.reopen()` → `TaskApprovalStore.reopen` đổi `lastSubmission.outcome` thành `REJECTED` nhưng không ghi dòng quyết định tương ứng vào `task_approvals`; `TaskApprovalPolicy.closedSubmission()` sau đó thấy `decisions` rỗng cho một `REJECTED` nên trả `false`, khoá cứng mọi thao tác sau đó (nộp lại, duyệt/trả phần khác) bằng lỗi `TASK_START_HISTORY_UNVERIFIED`. Sửa: `TaskApprovalStore.recordSectionReopenDecision` ghi dòng `step=CLIENT, action=REJECT` tường minh (reviewStep đã bị xoá lúc này, không đọc lại từ task được), gọi trong cùng transaction trước `store.reopen`. Có 2 test hồi quy trong `TaskApprovalSectionsTest` (xác nhận lặp lại lỗi khi revert fix, qua khi khôi phục). Task demo `3d8ac139-50e2-3eeb-b58e-d7f3186d5953` hiện vẫn kẹt ở trạng thái lỗi cũ (dữ liệu đã hỏng từ trước khi vá) — cần workspace/task mới để demo trọn luồng Client-trả-lại-sau-khi-xong, hoặc sửa tay `task_approvals` cho task này (chưa làm, tránh ghi đè mù vào Atlas).
  - Thêm ngoài kế hoạch (chuẩn bị cho T8.8/T8.10, chưa tick hẳn hai mục đó vì chưa đụng đúng file `ApprovalQueueList.tsx`/`TaskWorkflowContent.tsx` nêu trong T8): `SectionContentView.tsx` (hiển thị chỉ-đọc nội dung phần cho người duyệt), `SectionReview.tsx` — `SectionApprovalQueue` (hàng đợi phần chờ Client, endpoint mới `GET /workspaces/{id}/sections/client-pending` + `SectionService.clientPending`/`SectionStore.clientPendingTaskIds`) gắn vào `pages/portal`, và `TaskSectionsReview` (duyệt/trả từng phần ngay trên `pages/task-approvals`) gắn vào `ApprovalDetail.tsx`. Cả hai dùng chung `TaskSection[]` nên chạy được cho mọi `TaskType` ngay khi T8.1–T8.6 có trình soạn.
  - `npx tsc -b` sạch, `mvn test` toàn bộ backend sạch (sau khi merge `origin/develop` — không conflict, auto-merge).

## T8. Web các trình soạn còn lại & màn liên quan (→ plan §3)

- [x] T8.1 Mới `src/pages/task-editor/index.tsx`: chọn editor theo `task.type` trên route `/workspaces/:id/tasks/:taskId/editor` (POST/SHORT_VIDEO giữ `pages/editor`).
  - Ghi chú T8.1 (2026-11-11): web 3bfba81. Đọc `task.type` qua `taskWorkflowService.read` (không cần `TaskWorkflowProvider`, chỉ đọc). POST/SHORT_VIDEO → redirect `pages/editor?taskId=`; SURVEY → redirect route sẵn có `/survey`; EVENT_PLAN/PRESS/KOL_BOOKING/WORKSHOP/EMAIL_NEWSLETTER (chưa có editor, chờ T8.3–T8.6) → redirect tạm về `/detail`. Chưa sửa các nơi gọi (`TaskRowActions`, `TaskStartAction`, `TaskWorkflowContent`, `TaskApprovalSection` vẫn chỉ link thẳng `pages/editor` cho POST/SHORT_VIDEO) — nối các nơi đó vào route mới là T8.8. `npx tsc -b` sạch.
- [x] T8.2 `SectionListField` dùng chung cho trường dạng bảng (agenda, vendor, media list, shortlist…).
  - Ghi chú T8.2 (2026-11-11): web 81222e5. Component nhận `columns` từ nơi gọi (không đọc `TaskCatalog.fields` vì BE chỉ khai `List<?>`, không có schema cột); dùng `Table`/`Input` có sẵn trong `components/ui`. Thêm khoá i18n `editor.sections.addRow`/`removeRow` (vi+en). Dùng ở T8.4–T8.6.
- [ ] T8.3 `SurveyEditor` (bọc `SurveyOverviewCard` + Phân phối, Báo cáo).
- [ ] T8.4 `EventEditor`, `PressEditor`. Task EVENT_PLAN/PRESS cũ có dữ liệu trong `event_plans`/`press_recommendations` (`planContent`, `recommendations`): hiển thị khối chỉ-đọc "Nội dung cũ" phía trên, không migrate.
- [ ] T8.5 `KolEditor`, `WorkshopEditor` (Registration dùng form builder survey).
- [ ] T8.6 `NewsletterEditor`: dùng `BlockBuilder`, `MailPreview`, `RecipientPicker`; nút gửi/test; khối Báo cáo đọc số liệu batch.
- [ ] T8.7 Subtask: `TimelineSubtaskCreator.tsx`, `CampaignSubtasks.tsx`, `WorkItemSubtasksList.tsx` — bước "Gợi ý theo danh mục", badge vai trò, ẩn FINISHED thủ công cho subtask có vai trò.
- [ ] T8.8 `TaskWorkflowContent.tsx`: nút mở trình soạn cho mọi loại + "x/y phần đã duyệt".
- [ ] T8.9 `CampaignTimelineGrid.tsx`: trạng thái phần + cờ trễ hạn / chờ Client (§16.15).
- [ ] T8.10 Client portal `ApprovalQueueList.tsx`: danh sách phần chờ duyệt, Duyệt / Trả lại (note bắt buộc), empty state.
- [ ] T8.11 `pages/mail-templates`: dialog import CSV (hiển thị 4 con số), quota tháng.
- [ ] T8.12 Nút xuất file ở trình soạn và portal.
- [ ] T8.13 `npm run build` + `npm test` web — pass.

## T9. Mobile (→ plan §4)

- [ ] T9.1 Nhãn 4 loại mới ở `src/theme/tokens.ts` (`TASK_TYPE_LABEL`), `src/i18n/enumLabel.ts`, `formatTaskTypePill` (`taskListHelpers.ts` và bản trùng ở `ApprovalScreen.tsx`), bộ lọc `TaskListScreen.tsx`. Sửa EN của `EVENT_PLAN` từ "Workshop" thành "Event plan".
- [ ] T9.2 Service gọi `GET /sections` + approve/return.
- [ ] T9.3 `TaskDetailScreen.tsx`: tab "Phần" chỉ đọc + Duyệt/Trả theo `can*` (AC18). Test case spec 12.
- [ ] T9.4 `npm test` mobile — pass (gồm `TaskDetailScreen.test.tsx`).

## T10. i18n, theme, nghiệm thu (→ plan §3, §4, §6 bước 10)

- [ ] T10.1 **Cập nhật vi.json + en.json (web)**: `src/i18n/locales/{vi,en}/tasks.json`, `editor.json`, `campaign.json`, `mailTemplate.json`, `client.json` — mọi key spec AC19, key-parallel; so sánh khoá hai locale không lệch.
- [ ] T10.2 **Cập nhật locale mobile**: `src/i18n/locales/vi/*`, `en.json` — cùng namespace.
- [ ] T10.3 Rà hardcode: grep chuỗi tiếng Việt/Anh trong JSX/TSX mới — không còn.
- [ ] T10.4 **Kiểm tra light/dark mode**: badge trạng thái, khối khoá, banner trả lại/xung đột, editor mới, portal — chỉ token/`dark:` có sẵn, không hex cứng (AC20); chụp cả hai theme.
- [ ] T10.5 Chạy toàn bộ `test.md`, ghi pass/fail.
- [ ] T10.6 Nhắc user chạy 2 migration (T1.4, T5.1) trên môi trường thật trước khi merge. Cập nhật FR/SRS để sau (ngoài scope code).

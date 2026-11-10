# Plan — Subtask theo vai trò & Trình soạn chia phần

> Bước ② theo `docs/rule/feature-workflow.md`. Dựa trên `spec.md` (đã chốt 2026-11-10).
> Mục **0**: user đã duyệt cả 4 phương án đề xuất ngày 2026-11-10 (0.1 A, 0.2 poi-ooxml, 0.3 một route, 0.4 batch `kind=NEWSLETTER`).

## 0. Phương án đã duyệt

### 0.1 Lưu phần (section) ở đâu — **đề xuất A**

| | A. Collection riêng `task_sections` (đề xuất) | B. Nhúng vào `TaskDocument.typeMetadata.sections` |
|---|---|---|
| Revision theo phần (§5.4) | Mỗi phần một document, `revision` riêng, CAS bằng `findAndModify` theo `{taskId, sectionKey, revision}` | Phải CAS cả TaskDocument → hai người sửa hai phần khác nhau chặn nhau, trái §5.4 |
| Phiên bản (§16.12) | Collection `task_section_versions` riêng, không phình task | Nhúng phiên bản làm task phình, chạm giới hạn 16MB với EVENT/KOL dài |
| Lọc phần I cho Client (AC10) | Query lọc `visibility` ở DB | Lọc trong code sau khi đọc hết |
| Tác động code cũ | Không đụng schema `tasks` (chỉ thêm `subtaskRole`) | Mọi chỗ ghi TaskDocument phải giữ nguyên map |

POST và SURVEY: **nội dung vẫn nằm ở `PostDocument` / survey hiện có** (publisher và luồng publish đọc từ đó). Document `task_sections` của các phần này chỉ giữ trạng thái, revision, ghi chú, con trỏ; snapshot phiên bản vẫn chụp nội dung thật. Các loại khác (EVENT, PRESS, KOL, WORKSHOP, EMAIL, VIDEO.SCRIPT) giữ nội dung trong `task_sections.content`.

### 0.2 Xuất DOCX — **đề xuất thêm `org.apache.poi:poi-ooxml` vào business-service**

PDF dùng lại `openpdf` + mẫu `PackageExportRenderer` / `PackageProposalLayout` có sẵn (đã có font tiếng Việt `openpdf-fonts-extra`). DOCX chưa có thư viện nào trong repo. Phương án khác là sinh DOCX ở web bằng npm `docx`, nhưng như vậy phần lọc O/I và "chỉ phần đã duyệt cho Client" phải tin frontend; nên làm ở backend. **Dependency mới cần user đồng ý.**

### 0.3 Route trình soạn — **đề xuất một route, chia theo loại**

Giữ `/workspaces/:id/tasks/:taskId/editor`. POST & SHORT_VIDEO dùng `pages/editor` hiện có (thêm khối). SURVEY và 5 loại mới render qua `pages/task-editor/` (mới) với `SectionFrame` dùng chung; trang chọn editor theo `task.type`. Không tạo route riêng cho từng loại.

### 0.4 Gửi Newsletter — **đề xuất đi qua đường batch có sẵn, gắn `kind = NEWSLETTER`**

Dùng lại `MailSendService` → `MailDeliveryStore` (`mail_batches`, `mail_deliveries`) → `MailDeliveryService.deliverNext`. Thêm cột `kind` vào `mail_batches`; `MailDeliveryService` khi gặp batch `NEWSLETTER` bỏ qua `MailQuotaService` (giới hạn ngày mail hệ thống) và dùng bộ đếm Newsletter riêng (§16.1). Không viết hàng đợi thứ hai.

---

## 1. Thành phần backend (`brandhub-business-service`)

### 1.1 Danh mục cố định trong code
- `model/enums/TaskType.java`: thêm `SHORT_VIDEO, KOL_BOOKING, WORKSHOP, EMAIL_NEWSLETTER`.
- `model/enums/PackageServiceType.java`: thêm `SHORT_VIDEO, KOL_BOOKING, EMAIL_NEWSLETTER` + ánh xạ sang TaskType trong chỗ `CampaignTaskStore` đang map service type → task type.
- **Mới** `service/impl/task/TaskCatalog.java`: map tĩnh `TaskType → List<RoleDef(role, List<SectionDef(key, visibility O|I)>)>` đúng bảng spec §3. Một class, không interface, không cấu hình.
- **Mới** `controller/TaskCatalogController.java`: `GET /api/v1/task-catalog/{taskType}`.

### 1.2 Subtask
- `document/TaskDocument.java` record `Subtask`: thêm `String subtaskRole` (cuối record). Thêm constructor tương thích cũ để mọi chỗ gọi hiện tại không đổi.
- `CampaignSubtaskService` / `CampaignSubtaskController`: `Details`/`Row` thêm `subtaskRole`; validate thuộc `TaskCatalog` của task cha (AC3); `PATCH /status` từ chối `FINISHED` khi `subtaskRole != null`.
- `CampaignTaskStore.draftTask`: sau khi tạo task cha, sinh subtask theo `TaskCatalog` (assignee null, `dueDate` = hạn task cha, status TODO) (§16.9).
- Tự FINISHED (§5.3): `SectionService` sau mỗi chuyển trạng thái gọi `CampaignSubtaskService.syncRoleSubtasks(taskId)` — subtask có vai trò chuyển FINISHED khi mọi phần nó sở hữu ở trạng thái cuối, và quay về IN_PROGRESS nếu phần bị trả/mở lại.

### 1.3 Phần
- **Mới** `document/TaskSectionDocument.java` (`task_sections`): `id, workspaceId, taskId, sectionKey, visibility, status, revision, content (Map), returnNote, returnedBy, lastEditorRole (POST.CAPTION: CONTENT|EDITING), clientPendingSince, clientReminderSentAt, updatedAt`. Unique index `{taskId, sectionKey}`.
- **Mới** `document/TaskSectionVersionDocument.java` (`task_section_versions`): `taskId, sectionKey, versionNo, content snapshot, submittedBy, submittedAt` + nhật ký sự kiện `task_section_events` (`action, actorId, note, at`). Hai collection, không xoá (§16.12).
- **Mới** `service/impl/task/SectionPolicy.java`: tính `canView/canEdit/canSubmit/canApprove/canReturn/canReopen/canRestore` theo §4, §5.2, §16.10, §16.13. Dùng lại `TaskApprovalPolicy.Context/Snapshot` và `CampaignSubtaskService.supervisor`. Luật chồng phần POST/VIDEO.CAPTION nằm ở đây.
- **Mới** `service/impl/task/SectionService.java`: list (lọc theo người xem — Client chỉ O & `INTERNAL_APPROVED+`), patch (CAS revision; sửa phần đã duyệt → `SUBMITTED`), submit (ghi version), approve, return (note bắt buộc), reopen, restore, versions/compare. Phát thông báo (§1.6), huỷ lịch khi Client trả (§1.7).
- **Mới** `controller/TaskSectionController.java`: các endpoint §9.2 + `GET /sections/{key}/versions`, `GET /sections/{key}/versions/{no}`, `POST /sections/{key}/restore/{no}`.
- Task cũ / phần chưa có document: `SectionService` coi như `DRAFT`, chủ = điều phối, tạo document lười ở lần ghi đầu (spec §11). **Không backfill.**

### 1.4 Áp quyền vào endpoint cũ
- `TaskPostController` / service lưu bài: so sánh `SavePostRequest` với `PostDocument` hiện tại, xác định trường thay đổi → phần (`caption/hashtags`→CAPTION, media→MEDIA, platforms/scheduledAt→CHANNELS); trường thuộc phần không có quyền mà thay đổi → `FORBIDDEN` (AC8). Bump revision phần tương ứng. Response thêm `sections`.
- `SurveyController` `POST /survey`: kiểm `SURVEY.FORM`.
- Thay chỗ gọi `TaskApprovalPolicy.assignee` cho ghi nội dung bằng `SectionPolicy` khi task có subtask theo vai trò; task không có → giữ nguyên (không regression).
- `TaskApprovalService` submit: thêm `TASK_SECTIONS_UNAPPROVED`. Với task có subtask vai trò: bỏ bước `reviewStep = CLIENT`; khi mọi phần O đạt `CLIENT_APPROVED` (hoặc `INTERNAL_APPROVED` nếu không cần Client) → gọi luồng chuyển task cha sang đã duyệt hiện có (§16.5).
- `exception/ErrorCode.java`: thêm `SECTION_INVALID_TRANSITION, TASK_SECTIONS_UNAPPROVED, NEWSLETTER_NOT_APPROVED, MAIL_MONTHLY_QUOTA_EXCEEDED`.

### 1.5 Newsletter
- `document/MailRecipientGroupDocument.Entry`: thêm `consent, consentSource, importedAt`.
- `MailRecipientController`: `POST /mail-recipient-groups/import` (multipart) — parse bằng `commons-csv` (đã có), dedupe email, loại không consent / suppressed / sai định dạng, trả 4 con số (AC13).
- **Mới** `service/NewsletterService.java`: kiểm AC14 (phần CONTENT + DESIGN đạt trạng thái cuối, quyền người gọi), kiểm quota tháng, render từ blocks phần CONTENT/DESIGN bằng renderer mail-templates hiện có, gọi `MailSendService` tạo batch `kind=NEWSLETTER`, sender name = `ClientProfile.displayName`, domain BrandHub (AC17). `send-test` dùng lại `MailSendService.sendTest`.
- **Mới** `service/NewsletterQuotaService.java`: đếm theo `agency_id` + tháng (giờ `Asia/Ho_Chi_Minh` như `MailQuotaService.ZONE`); limit lấy từ gói của agency (`SubscriptionPlanName` → 1.000/10.000/50.000, cấu hình `newsletter.quota.basic|pro|enterprise`); giới hạn tốc độ `newsletter.rate.per-day`. Hết giữa batch → `DEFERRED` như cơ chế hiện có.
- `MailDeliveryService`: nhánh `NEWSLETTER` dùng `NewsletterQuotaService` thay `MailQuotaService`.
- Suppression theo Client (§16.6): `mail_suppressions` thêm `client_profile_id`; unsubscribe từ mail Newsletter ghi kèm client của workspace (`WorkspaceMember.clientProfileId` của Client trong workspace). `MailSuppressionStore` thêm `isSuppressedForClient`. Mail hệ thống giữ logic cũ.
- `MailSendController GET /mail-quota`: thêm `monthlyUsed, monthlyLimit, planName`.
- Phần `EMAIL.REPORT`: số liệu đọc trực tiếp từ batch (`MailBatchService.detail`), chỉ lưu ô nhận xét.

### 1.6 Thông báo (§16.7)
- `UserNotificationService`: thêm `sectionEvent(recipient, workspaceId, taskId, sectionKey, action)` (in-app, `actionUrl` = trình soạn).
- Email: Client khi có phần chờ duyệt; chủ phần khi bị trả — qua `MailSendService.sendSystem` với template hệ thống mới.
- **Mới** `@Scheduled` `SectionReminderJob` (mỗi giờ): phần `INTERNAL_APPROVED` có `clientPendingSince < now-48h` và `clientReminderSentAt` null hoặc cũ hơn 48h → gửi nhắc. Không tự duyệt.

### 1.7 Huỷ lịch khi Client trả (§11)
- POST/VIDEO: gọi luồng huỷ lịch publish hiện có của task (xác định chính xác hàm khi làm task; nếu chưa có hàm huỷ lịch thì thêm vào service publish của business-service, không đụng publisher-service).
- EMAIL: `MailBatchService.cancel` với batch đang chờ.

### 1.8 Xuất file (§16.11)
- **Mới** `service/impl/task/SectionExportService.java` + endpoint `GET /tasks/{taskId}/export` (`?format` suy ra theo loại: PRESS → DOCX, khác → PDF).
- PDF: theo mẫu `PackageExportRenderer` (openpdf). DOCX: poi-ooxml (0.2). Chỉ phần O; logo `ClientProfile.logoUrl`; agency xuất mọi trạng thái, phần chưa `CLIENT_APPROVED` đóng dấu "Bản nháp"; Client chỉ phần `CLIENT_APPROVED`.

## 2. DB thay đổi (`brandhub-infrastructure/docs/database/migrations/`)

| File | Nội dung |
|---|---|
| `2026-11-1x-subtask-role-sections.js` (mongosh) | tạo `task_sections`, `task_section_versions`, `task_section_events` + index (`{taskId,sectionKey}` unique, `{workspaceId,status}`, `{status,clientPendingSince}`); cập nhật validator `tasks` nếu đang ràng buộc enum `type` / field subtask; thêm `subtaskRole` optional. |
| `2026-11-1x-newsletter.sql` (Postgres, additive như mẫu 11-06) | `mail_batches.kind VARCHAR(16) NOT NULL DEFAULT 'TEMPLATE'`; `mail_suppressions.client_profile_id UUID` + index; bảng `newsletter_monthly_usage(agency_id, month, used, PK(agency_id,month))`. |

Không seed, không backfill dữ liệu cũ. `TaskSampleSeeder` thêm một task POST có subtask vai trò để demo. User tự chạy migration (như 11-06).

## 3. Web (`brandhub-web`)

- Type: `src/types/task.ts`, `src/pages/campaign/types.ts` — 4 TaskType mới, `subtaskRole`, type `TaskSection`.
- **Mới** `src/services/taskSectionService.ts`, `src/hooks/useTaskSections.ts` (React Query; mutation gửi `expectedRevision`, xử lý `TASK_REVISION_CONFLICT` → banner tải lại).
- **Mới** `src/components/task-sections/`: `SectionFrame` (tiêu đề, chủ phần, badge trạng thái, nút theo `can*`, banner returned/locked/conflict), `SectionStatusBadge`, `SectionReturnDialog`, `SectionVersionDrawer` (list + so sánh + khôi phục).
- POST/VIDEO: `src/pages/editor/index.tsx` + `TaskEditorControls`, `MediaDropzone`, `DocsCaptionEditor`, `ScheduleModal` — bọc từng vùng bằng `SectionFrame`, disable theo quyền; thêm khối Brief (POST) / Kịch bản (VIDEO); slot rỗng `VIDEO.SHOOT`, `VIDEO.EDIT` (component placeholder có props `section`, để Ân gắn code).
- **Mới** `src/pages/task-editor/`: `index.tsx` (chọn editor theo type), `SurveyEditor` (bọc `SurveyOverviewCard` + khối Phân phối, Báo cáo), `EventEditor`, `PressEditor`, `KolEditor`, `WorkshopEditor` (Registration dùng lại form builder survey), `NewsletterEditor` (dùng lại `BlockBuilder`, `MailPreview`, `RecipientPicker` từ `pages/mail-templates`). Một component `SectionListField` dùng chung cho các trường dạng bảng (agenda, vendor, media list…).
- Subtask: `TimelineSubtaskCreator.tsx`, `tasks/components/CampaignSubtasks.tsx`, `WorkItemSubtasksList.tsx` — bước "Gợi ý theo danh mục", badge vai trò, ẩn FINISHED thủ công với subtask có vai trò.
- `tasks/components/TaskWorkflowContent.tsx`: nút mở trình soạn cho mọi loại + tóm tắt "x/y phần đã duyệt".
- Timeline (§16.15): `CampaignTimelineGrid.tsx` hiện trạng thái phần của subtask + cờ trễ hạn / chờ Client.
- Client portal: `pages/portal/components/ApprovalQueueList.tsx` thêm danh sách phần chờ duyệt (Duyệt / Trả lại bắt buộc ghi chú).
- Mail: `pages/mail-templates` — dialog import CSV, hiển thị quota tháng.
- Export: nút xuất ở trình soạn và portal.
- **i18n**: `src/i18n/locales/{vi,en}/tasks.json`, `editor.json`, `campaign.json`, `mailTemplate.json`, `client.json` (key theo spec AC19, key-parallel).
- **Theme**: chỉ dùng token/`dark:` có sẵn (AC20); không thêm màu mới.

## 4. Mobile (`brandhub-mobile-app`)
- `src/screens/content/TaskDetailScreen.tsx`: tab "Phần" — danh sách phần chỉ đọc + Duyệt/Trả theo `can*` từ API. Service gọi `/sections`.
- `src/types`: 4 TaskType mới (tránh crash enum label — `src/i18n/enumLabel.ts`).
- Locale: `src/i18n/locales/vi/*`, `en.json`.

## 5. Luồng dữ liệu chính

```
Deploy campaign → CampaignTaskStore.draftTask → task cha + subtask theo TaskCatalog (chưa gán)
Chủ phần PATCH /sections/{key} (expectedRevision) → SectionPolicy → CAS task_sections
  POST/SURVEY: ghi PostDocument/survey + bump revision phần
submit → version snapshot + event → notify supervisor/Manager
approve (nội bộ) → INTERNAL_APPROVED → phần O: clientPendingSince, notify + email Client
Client approve → CLIENT_APPROVED → syncRoleSubtasks → (đủ phần O) task cha APPROVED
Client return → RETURNED + note → huỷ lịch publish/mail → notify chủ phần
EMAIL_SEND send → NewsletterService (AC14, quota) → mail_batches(kind=NEWSLETTER) → MailDeliveryService
```

## 6. Thứ tự build

1. BE nền: TaskType/PackageServiceType, `TaskCatalog`, `subtaskRole`, catalog endpoint, migration Mongo.
2. BE phần: `TaskSectionDocument` + versions/events, `SectionPolicy`, `SectionService`, controller, ErrorCode. Unit test policy + chuyển trạng thái.
3. BE gắn luồng cũ: lưu bài/survey theo phần, submit gating, Client per-section thay `reviewStep=CLIENT`, auto FINISHED, sinh subtask khi deploy.
4. BE thông báo + reminder job + huỷ lịch.
5. BE Newsletter: migration SQL, import CSV, quota tháng, kind NEWSLETTER, suppression Client, send/test.
6. BE export PDF/DOCX.
7. Web nền: types, service/hook, `SectionFrame`; POST editor chia phần → test E2E luồng POST đầy đủ.
8. Web các editor còn lại + subtask creator + timeline + portal + mail import/quota + export.
9. Mobile tab Phần.
10. i18n/theme rà soát, chạy test.md. Sau khi chạy thật: cập nhật FR/SRS (ngoài scope code).

Bàn giao trong một đợt như user chốt; thứ tự trên chỉ là thứ tự làm.

## 7. Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Thêm TaskType làm vỡ `switch`/map ở web, mobile, ai-service, publisher | Grep toàn bộ repo trước bước 1; fallback label cho type lạ |
| Endpoint lưu bài cũ áp quyền theo phần gây regression task cũ | Chỉ bật khi task có subtask vai trò; test case 15 trong spec |
| Validator Mongo `tasks` từ chối field/enum mới | Migration bước 1 cập nhật validator trước khi deploy code |
| Newsletter làm tắc hàng đợi mail hệ thống | Quota/tốc độ riêng; `deliverNext` ưu tiên batch hệ thống |
| Code video của Ân chưa push | Chỉ chừa slot + key quyền; không định nghĩa UI; Ân gắn sau |
| Dependency mới poi-ooxml tăng kích thước jar | Chấp nhận nếu user duyệt 0.2; nếu không, PRESS cũng xuất PDF |
| Phạm vi lớn, một đợt | Mỗi bước 1–9 kết thúc bằng test pass trước khi sang bước sau |

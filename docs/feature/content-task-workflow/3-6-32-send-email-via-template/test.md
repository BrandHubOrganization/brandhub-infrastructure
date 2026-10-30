# Test — Send Email via Template (FR 3.6.32)

- **FR:** 3.6.32 · **Jira:** DA-1002
- **Mục tiêu:** Gửi email theo mẫu tới danh sách người nhận: hàng đợi, hạn mức, hẹn giờ/hủy, hủy đăng ký, lịch sử, Admin.

## 1. Cách chạy 

```bash
# Backend (cần Postgres + Mongo thật cho phần worker/quota)
cd brandhub-business-service && mvn clean test -Dtest='MailTemplate*Test,MailSend*Test,MailDelivery*Test,Quota*Test,Unsubscribe*Test'

# Frontend
cd brandhub-web-dashboard && npm test                     # Vitest
npx playwright test tests/e2e/mail-templates              # E2E (mock REST)

# Live integration (backend thật + SMTP giả)
# Chạy backend thật (profile dev) + SMTP giả cổng 2525, rồi gọi API bằng curl; các bước và kết quả
# ở mục 7 (không có script commit sẵn).
```
Ghi chú môi trường: nếu Maven báo `source level 25`, chạy `mvn clean` (class của IDE trong `target/`). Playwright cần `npx playwright install chromium`.

## 2. Ma trận kiểm thử

| Tầng | Công cụ | Phạm vi |
|---|---|---|
| Đơn vị service | JUnit 5 + Mockito | CRUD, quyền, sanitize, render biến, phân loại người nhận, hẹn giờ |
| Tích hợp DB | JUnit + Postgres/Mongo thật | `SKIP LOCKED`, quota đồng thời, idempotent, retention |
| Frontend logic | Vitest | Parse biến, parse CSV, validate form |
| UI | Playwright (mock REST) | Luồng người dùng, trạng thái UI, i18n, light/dark |
| Live | Node script + SMTP giả | Header, tệp đính kèm, unsubscribe thật, quota, hẹn giờ |

## 3. Test case của FR này

| ID | Case | Input | Mong đợi |
|---|---|---|---|
| TC-SEND-01 | Gửi 1 Client trong Workspace | `contact_email` | 202, batch `QUEUED`, 1 delivery; không footer |
| TC-SEND-02 | Gửi nhiều người ngoài Workspace | 3 email | 202; có footer + `List-Unsubscribe` |
| TC-SEND-03 | recipients rỗng | `[]` | 400 `VALIDATION_ERROR` |
| TC-SEND-04 | Quá 200 người | 201 | 400 |
| TC-SEND-05 | Email sai định dạng | `abc` | Vào `rejected`, các dòng khác vẫn gửi |
| TC-SEND-06 | Trùng không phân biệt hoa thường | `A@x.test`, `a@x.test` | 1 delivery, 1 `rejected` |
| TC-SEND-07 | Tất cả dòng bị loại | toàn lỗi | 400 |
| TC-SEND-08 | Vượt quota Workspace còn lại hôm nay | còn 5, gửi 10 | 429 `MAIL_QUOTA_EXCEEDED`, `remainingToday=5` |
| TC-SEND-09 | Quota hệ thống hết | 450 đã dùng | 429 |
| TC-SEND-10 | Gửi thử | — | Đồng bộ tới email người dùng; không tăng quota |
| TC-SEND-11 | Gửi thử khi SMTP lỗi | SMTP down | 502 `EMAIL_SERVICE_UNAVAILABLE` |
| TC-SEND-12 | Gửi thử quá 10 lần/giờ | lần 11 | 429 |
| TC-SEND-13 | Đính kèm mặc định | không chỉ định | Mail có tệp của template |
| TC-SEND-14 | `attachmentIds: []` | — | Mail không có tệp |
| TC-SEND-15 | Reply-To / From | — | From=`MAIL_FROM`, Reply-To=email người gửi |
| TC-SEND-16 | CLIENT gọi send | role CLIENT | 403 |
| TC-SEND-17 | Template đã xóa | id đã xóa | 404 |
| TC-SEND-18 | Một người lỗi SMTP trong lô | 1/5 lỗi | 4 `SENT`, 1 retry rồi `FAILED`; lô `COMPLETED` |
| TC-SEND-19 | Toàn bộ thất bại | SMTP down | Lô `FAILED`, sau 5 lần thử |
| TC-SEND-20 | Lô gửi từ trang Client | `clientName` | Biến tự điền |
| TC-SCH-01 | Hẹn giờ hợp lệ | now+10 phút | 202, `SCHEDULED`, chưa gửi, chưa trừ quota |
| TC-SCH-02 | Hẹn < 5 phút | now+2 phút | 400 `MAIL_SCHEDULE_OUT_OF_RANGE` |
| TC-SCH-03 | Hẹn > 30 ngày | now+31 ngày | 400 |
| TC-SCH-04 | Snapshot | sửa template sau khi hẹn | Mail gửi đúng bản lúc hẹn |
| TC-SCH-05 | Xóa template sau khi hẹn | — | Lô vẫn gửi đúng |
| TC-SCH-06 | Hủy lịch | batch `SCHEDULED` | `CANCELLED`, deliveries không gửi |
| TC-SCH-07 | Hủy lô đã chạy | batch `SENDING` | 409 `MAIL_BATCH_NOT_CANCELLABLE` |
| TC-SCH-08 | Đến giờ | giờ chạy | `SCHEDULED → QUEUED → SENDING → COMPLETED` |
| TC-SCH-09 | Đến giờ nhưng hết quota | quota đủ 1 phần | Phần gửi được `SENT`, phần còn `PENDING`, `next_attempt_at` = 00:00 ngày kế |
| TC-SCH-10 | Múi giờ Workspace | `+07:00` vs UTC | Giờ chạy đúng |
| TC-SCH-11 | Người không phải tác giả hủy | CREATOR khác | 403; OWNER/MANAGER 200 |

| ID | Case | Mong đợi |
|---|---|---|
| TC-WK-01 | 2 worker cùng lấy delivery | `SKIP LOCKED`: mỗi delivery chỉ một worker |
| TC-WK-02 | 20 luồng cùng gửi gần cap | Tổng `sent_count` ≤ cap, không vượt |
| TC-WK-03 | Enqueue cùng `event_key` hai lần | 1 delivery |
| TC-WK-04 | 100 delivery | Không quá 20/phút |
| TC-WK-05 | SMTP lỗi 4 lần rồi thành công | `attempts=5`, `SENT`; khoảng cách các lần tăng 1/5/15/60 phút |
| TC-WK-06 | Lỗi 5 lần | `FAILED` kèm `last_error` |
| TC-WK-07 | Guard dev: recipient ngoài `allowed-recipients` | `FAILED` `DEV_RECIPIENT_BLOCKED`, không chạm SMTP |
| TC-WK-08 | Quota reset 00:00 `Asia/Ho_Chi_Minh` | Delivery `PENDING` gửi tiếp |
| TC-WK-09 | Crash giữa gửi và commit | Tối đa gửi trùng một lần; ghi nhận hành vi |

| ID | Case | Mong đợi |
|---|---|---|
| TC-UNS-01 | Mở link hợp lệ (GET) | Trang xác nhận vi/en, không đổi dữ liệu |
| TC-UNS-02 | Xác nhận (POST) | Thêm `mail_suppressions`; idempotent khi bấm lại |
| TC-UNS-03 | One-click (`List-Unsubscribe-Post`) | POST không cần UI vẫn hủy được |
| TC-UNS-04 | Token giả/sửa | 400, không lộ thông tin |
| TC-UNS-05 | Gửi lại sau khi hủy | Delivery `SUPPRESSED`, không gọi SMTP |
| TC-UNS-06 | Phạm vi Workspace | Hủy ở A; gửi từ B vẫn tới |
| TC-UNS-07 | Broadcast Admin | Không bị ảnh hưởng bởi suppression |
| TC-UNS-08 | Người nhận là Client trong suppression | Vẫn gửi (coi là trong Workspace) |
| TC-UNS-09 | Rate limit theo IP | Spam endpoint → 429 |

| ID | Case | Mong đợi |
|---|---|---|
| TC-HIS-01 | Danh sách lô | Đúng Workspace, mới nhất trước |
| TC-HIS-02 | Chi tiết lô | Phân trang + lọc trạng thái |
| TC-HIS-03 | Quyền xem | OWNER/MANAGER/CREATOR xem; CLIENT 403 |
| TC-HIS-04 | Quota | `GET mail-quota` khớp số đã dùng |
| TC-HIS-05 | Notification | Lô xong/lỗi → người tạo nhận 1 thông báo |
| TC-HIS-06 | Retention | Lô >12 tháng: deliveries và `body_html` xóa, counters còn |
| TC-ADM-01 | Admin CRUD mẫu hệ thống | `type=SYSTEM_DEFAULT`, `workspaceId=null` |
| TC-ADM-02 | User thường gọi Admin API | 403 |
| TC-ADM-03 | Seed 4 mẫu | Có đủ 4, chạy lại không nhân đôi |
| TC-ADM-04 | Broadcast "Chọn mẫu" | Sao chép subject/body vào form; worker 3.10.1 không đổi |
| TC-ADM-05 | Workspace clone mẫu hệ thống | Có bản `CUSTOM` mới, mẫu gốc không đổi |

| TC | Case | Where | Result |
|---|---|---|---|
| TC-ENH-04 | Members/Clients picked and a saved group are merged without duplicates | Playwright + vitest | pass |
| TC-ENH-05 | Finished batch with failures: Resend queues only failed rows, Export CSV downloads | Playwright + JUnit | pass |
| TC-ENH-06 | Resend refused while sending / when nothing failed / by a non-owner creator | JUnit | pass |
| TC-ENH-07 | CSV cells starting with `= + - @` are prefixed with `'` | JUnit | pass |
| TC-ENH-08 | Unsubscribed list pages, re-subscribe needs OWNER/MANAGER | Playwright + JUnit | pass |
| TC-ENH-09 | Group create keeps only valid distinct emails, capped per Workspace, owner-only delete | JUnit | pass |
| TC-ENH-10 | `RequireRoleAspect` stops CLIENT (403) and non-members on send, send-test and mail-quota; OWNER/MANAGER/CREATOR pass (TC-SEND-16) | JUnit `MailSendRoleEnforcementTest` | pass |
| TC-ENH-11 | `POST send` answers 202, forwards `Idempotency-Key`, rejects malformed JSON with 400 | JUnit `MailSendControllerTest` | pass |
| TC-ENH-12 | One-click unsubscribe POST works with the token in the query only; 31st call per IP in a minute is rate limited; IP key is the last `X-Forwarded-For` entry (TC-UNS-03, TC-UNS-09) | JUnit `PublicMailControllerTest` | pass |
| TC-ENH-13 | Unsubscribe link has no `//` when `FRONTEND_URL` ends with `/` | JUnit `MailSendServiceTest` | pass |
| TC-ENH-14 | `send` with a null body still sends when the scope resolves recipients (no NPE) | JUnit `MailSendServiceTest` | pass |
| TC-ENH-15 | Suppression list: CREATOR can list but gets 403 on re-subscribe, MANAGER can re-subscribe, CLIENT gets 403; every batch-history endpoint excludes CLIENT (TC-HIS-03) | JUnit `MailHistoryRoleEnforcementTest` | pass |
| TC-ENH-16 | Admin mail endpoints: 401 without token, 403 when the token's user is no longer ADMIN (services never run), 200 for a current ADMIN (TC-ADM-02) | `@WebMvcTest` `AdminMailSecurityTest` | pass |
| TC-ENH-17 | Agency suppression endpoints forward agency, caller and paging to the service; missing `email` is 400; a service refusal propagates | JUnit `AgencyMailControllerTest` | pass |
| TC-DATA-01 | Dev mail dataset (`MailSampleSeeder`, profile `seed`/`seed-postgres`): batches in all 6 statuses, deliveries in all 4, workspace/agency/system suppressions, near-cap quota workspace; idempotent; refuses `prod` | JUnit `MailSampleSeederTest` (SQL not yet run against a live DB) | pass |

## 4. Bảo mật

| ID | Case | Mong đợi |
|---|---|---|
| SEC-MT-02 | Header injection (`\r\n` trong subject/email) | Bị loại/từ chối |
| SEC-MT-03 | Token unsubscribe giả/lặp lại/của Workspace khác | Từ chối hoặc idempotent, không ảnh hưởng dữ liệu khác |
| SEC-MT-04 | IDOR template/batch/attachment | 403/404 |
| SEC-MT-07 | Rò rỉ email trên trang unsubscribe | Chỉ hiển thị email đã che |

## 5. Tiêu chí đạt

- 100% case mục 3–11 đạt hoặc có ghi chú giới hạn rõ ràng.
- Không còn lỗi lint/type-check mới; vi/en song song; light/dark kiểm tra.
- Mọi AC trong spec §4 có ít nhất một case tương ứng đạt.

## 6. Giới hạn đã biết (dự kiến)

- Không quét virus (chỉ allow-list + magic bytes).
- Giao hàng at-least-once: crash đúng khoảnh khắc giữa gửi và commit có thể gửi trùng một mail.
- Worker đơn instance được kiểm cho `SKIP LOCKED`; scale đa instance chưa được xác nhận ở môi trường thật.
- Hiển thị email phụ thuộc client thư (Gmail/Outlook/Apple Mail) — kiểm tra bằng mắt.
- Gmail có thể vẫn đánh dấu spam dù đã cap; cần theo dõi thực tế.

## 7. Kết quả thực thi

### 14.2 Bước 3–8 (đủ backend + frontend) — 2026-10-12
Nhánh `feat/DA-998-mail-template-crud` (business-service, 6 commit), `feat/DA-998-mail-template-ui` (web-dashboard, 2 commit), `feat/DA-1257-mail-public-route` (api-gateway, 1 commit).

| Nhóm | Cách chạy | Kết quả |
|---|---|---|
| JUnit mail (sanitizer, renderer, template, attachment, send, delivery, batch, unsubscribe, seeder, MailService) | `mvn test -Dtest='Mail*Test,...'` | 107+ test pass |
| Toàn bộ business-service | `mvn clean test` | **675/675**, không hồi quy |
| Vitest web-dashboard | `npm test` | **59/59** (12 test mới: biến, CSV, người nhận, HTML→text) |
| Playwright mail templates (REST mock) | `npx playwright test tests/e2e/mail-templates` | **16/16**: list, tìm kiếm, lỗi/retry, xóa, tạo, chèn biến, gửi CSV, đính kèm, quota, hẹn giờ, preview/test, >200, lô + hủy, unsubscribe |
| Type-check, ESLint (file mới) | `tsc --noEmit`, `eslint` | 0 lỗi (5 cảnh báo `set-state-in-effect` theo mẫu nạp dữ liệu có sẵn) |
| Live: backend thật + Postgres + Mongo + SMTP sink | curl + sink script | gửi 3 người (1 nội bộ, 2 ngoài) đúng 3 mail; Reply-To = người gửi; footer + `List-Unsubscribe` chỉ cho người ngoài; footer vi/en; unsubscribe công khai (GET/POST, idempotent, token giả bị 400); gửi lại thì người đã hủy `SUPPRESSED`; quota 429 kèm số còn lại; hẹn giờ, quá gần bị 400, hủy 403/200/409; gửi thử vào hộp thư người dùng; lịch sử 2 lô đúng; notification trong app; retention SQL chạy đúng |

**Lỗi tìm thấy nhờ test live và đã sửa:** thông báo cuối lô được ghi trong cùng giao dịch với việc gửi; khi bảng `user_notifications` thiếu, câu lệnh lỗi làm hỏng giao dịch, trạng thái `SENT` bị rollback và **cùng một mail bị gửi lặp mỗi tick** (người nhận nhận 12+ bản). Đã tách thông báo ra ngoài giao dịch (commit `8c9f0e8`) và thêm test hồi quy.

**Chưa kiểm chứng:** upload tệp đính kèm/ảnh lên S3 thật (chỉ test đơn vị với storage giả); Mongo validator với tệp đính kèm; light/dark mode và responsive bằng mắt; screen reader; hiển thị trên Gmail/Outlook; hai instance worker; quota đồng thời nhiều luồng trên DB thật; trang Client (nút Gửi email) chưa có E2E vì trang dùng mock service; gateway route chưa chạy trên gateway thật.

### 15. Independent review (2026-10-12)

Reviewer: java-reviewer agent over `git diff origin/develop...HEAD` of business-service. No cross-workspace IDOR, header injection or HMAC timing issue found.

**Fixed in code**
- Unsubscribe secret / public base URL dev defaults now fail startup on `prod`/`production`/`staging` (`MailConfigGuard`).
- Attachment type detection uses the bytes only (not the file name); OOXML must contain its own part folder.
- Recipient addresses containing `,` or `;` are rejected up front (they used to burn 5 attempts).

**Fixed in a second pass (same day)**
| # | Item | Fix |
|---|---|---|
| 3 | Unsubscribe rate limit | Key = last `X-Forwarded-For` entry (proxy-appended), idle keys evicted above 10k |
| 5 | Upload abuse | `mail.attachment.max-uploads-per-day` (60) per Workspace, size pre-check before reading bytes |
| 6 | Pending backlog | `mail.max-pending-per-workspace` (1000) checked on every send, scheduled included |
| 7 | Double send | Optional `Idempotency-Key` header; deterministic batch id, `on conflict do nothing`; web sends one key per payload |
| 8 | SMTP inside the DB tx | Claim + 10 min lease in a short tx, SMTP and S3 outside, status write in a second short tx |
| 9 | Quota day / 5xx | Release hits the day it consumed; a 5xx SMTP reply fails immediately |
| 10 | Variable size | max 30 variables, name 64, value 1000 chars |
| 11 | Send-test map | idle entries pruned above 1000 keys |
| 12 | Bind before save | Template create/update mark attachments bound only after the Mongo save |

**Still open (low risk, documented)**
- Replacing or removing a template attachment does not unbind it: clones share the same attachment id and S3 key, so unbinding needs reference counting first.
- IMAGE uploads are never orphan-cleaned (their URL lives in template bodies); growth is bounded by the daily upload cap.
- Send-test limiter and unsubscribe limiter are per instance.
- An idempotent replay returns `rejected: []` because the per-row rejection list is not stored.

### 16. Enhancements (Addendum A)

| TC | Case | Where | Result |
|---|---|---|---|
| TC-ENH-01 | Preview renders the typed body; mobile toggle limits width to 375px | Playwright | pass |
| TC-ENH-02 | `{{nmae}}` shows a "Did you mean {{name}}" hint, saving is not blocked | Playwright + vitest | pass |
| TC-ENH-03 | New template draft survives close/reopen and can be discarded | Playwright | pass |
| TC-ENH-04 | Members/Clients picked and a saved group are merged without duplicates | Playwright + vitest | pass |
| TC-ENH-05 | Finished batch with failures: Resend queues only failed rows, Export CSV downloads | Playwright + JUnit | pass |
| TC-ENH-06 | Resend refused while sending / when nothing failed / by a non-owner creator | JUnit | pass |
| TC-ENH-07 | CSV cells starting with `= + - @` are prefixed with `'` | JUnit | pass |
| TC-ENH-08 | Unsubscribed list pages, re-subscribe needs OWNER/MANAGER | Playwright + JUnit | pass |
| TC-ENH-09 | Group create keeps only valid distinct emails, capped per Workspace, owner-only delete | JUnit | pass |
| TC-ENH-10 | Removed attachment is released through the reference check; delete releases all | JUnit | pass |

Totals after this pass: business-service 704, vitest 64, Playwright mail 25.
Known limit: the first Playwright run after a cold dev server start can time out once (re-run passes).

### 17. Addendum B (2026-10-29)

| ID | Nội dung | Tầng | Kết quả |
|---|---|---|---|
| TC-B-01 | Agency OWNER gửi được mẫu Agency từ Workspace của Agency đó; không phải Owner hoặc Workspace ngoài Agency → `TEMPLATE_NOT_FOUND` | JUnit | pass |
| TC-B-02 | Owner agency preview được mẫu Agency; người khác không | JUnit | pass |
| TC-B-03 | Admin gửi `ADMIN_SYSTEM_BROADCAST` không cần member Workspace, batch `workspace_id` null; mẫu scope khác → `INVALID_SCOPE` | JUnit | pass |
| TC-B-04 | Admin gửi thử không cần Workspace, từ chối scope khác | JUnit | pass |
| TC-B-05 | `recipient-preview`: Admin đếm đủ user active và lấy mẫu 10; Agency chỉ Owner, đúng agencyId | JUnit | pass |
| TC-B-06 | Member Workspace gửi mẫu admin với recipients rỗng → `VALIDATION_ERROR`, không truy vấn toàn bộ user, không tạo batch | JUnit | pass |
| TC-B-07 | Mẫu admin trong Workspace vẫn bị cap 200/lần | JUnit | pass |
| TC-B-08 | `TRANSACTIONAL_AUTO` không gửi được từ Workspace (`TEMPLATE_NOT_FOUND`) | JUnit | pass |
| TC-B-09 | Token unsubscribe `system` round-trip với workspace null; huỷ đăng ký ghi vào danh sách chặn hệ thống | JUnit | pass |
| TC-B-10 | Thông báo batch xong: có link Workspace khi có Workspace, không link khi null | JUnit | pass |
| TC-B-11 | Block builder: thêm/di chuyển/xoá, validate từng khối, render preview escape mọi giá trị | Vitest | pass |
| TC-B-12 | Bảng quyền mobile khớp `access.ts`; màn bị chặn khi role không đủ quyền | Jest | pass |
| TC-B-13 | Mobile: lọc nhóm mẫu theo scope (gồm Agency), `isAgencyScope`, `agencyRecipientPreview` | Jest | pass |

Tổng sau lượt này: backend 170 (nhóm Mail, token, thông báo, material), web vitest 70, mobile jest 140.
**Chưa kiểm**: Playwright/E2E cho block builder và luồng gửi Agency/Admin; thử trên thiết bị thật; migration trên staging.

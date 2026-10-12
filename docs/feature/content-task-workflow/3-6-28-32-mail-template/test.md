# Test — Mail Template (FR 3.6.28 – 3.6.32)

> Bước ④ của [feature-workflow](../../../rule/feature-workflow.md). Test case bám theo Acceptance Criteria trong [spec.md](spec.md); công việc ở [task.md](task.md); thiết kế ở [plan.md](plan.md).
> Trạng thái: **Kịch bản đã viết, chưa thực thi** (chưa có code). Mục 14 cập nhật khi chạy.
> Dữ liệu test dùng email giả (`@example.test`) và thời gian ISO-8601. Không gửi mail thật: dùng SMTP giả (GreenMail/MailHog).

## 1. Cách chạy (dự kiến)

```bash
# Backend (cần Postgres + Mongo thật cho phần worker/quota)
cd brandhub-business-service && mvn clean test -Dtest='MailTemplate*Test,MailSend*Test,MailDelivery*Test,Quota*Test,Unsubscribe*Test'

# Frontend
cd brandhub-web-dashboard && npm test                     # Vitest
npx playwright test tests/e2e/mail-template/              # E2E (mock REST)

# Live integration (backend thật + SMTP giả)
node brandhub-infrastructure/docs/feature/content-task-workflow/3-6-28-32-mail-template/integration-test.cjs
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

## 3. CRUD template (AC-V, AC-C, AC-U, AC-D)

| ID | Case | Input | Mong đợi |
|---|---|---|---|
| TC-MT-01 | List chỉ lấy template của Workspace và hệ thống khi `includeSystem=true` | 2 template Workspace + 1 hệ thống | 3 mục; khi `false` còn 2 |
| TC-MT-02 | List bỏ template đã xóa mềm | 1 template `deletedAt != null` | Không xuất hiện |
| TC-MT-03 | List có tìm kiếm và phân trang | `q=sale`, `size=1` | Chỉ mục khớp; `page` đúng |
| TC-MT-04 | CLIENT/không thành viên gọi list | role CLIENT | 403 `FORBIDDEN` |
| TC-MT-05 | Tạo hợp lệ | `name`, `subject`, `bodyHtml` | 201, `type=CUSTOM`, `createdBy` đúng |
| TC-MT-06 | Tạo thiếu `subject` hoặc `bodyHtml` | rỗng/khoảng trắng | 400 `VALIDATION_ERROR` |
| TC-MT-07 | Clone từ template hệ thống | `cloneFromId` | Có `clonedFromId`, nội dung kế thừa, sửa được |
| TC-MT-08 | Clone từ template Workspace khác | `cloneFromId` thuộc Workspace khác | 404 (không lộ tồn tại) |
| TC-MT-09 | PATCH một phần | chỉ `name` | Chỉ `name` đổi, `updatedAt` mới |
| TC-MT-10 | PATCH template hệ thống từ Workspace | — | 403 `SYSTEM_TEMPLATE_READ_ONLY` |
| TC-MT-11 | CREATOR sửa template của người khác | — | 403; OWNER/MANAGER thì 200 |
| TC-MT-12 | PATCH/DELETE template không tồn tại | id lạ | 404 `TEMPLATE_NOT_FOUND` |
| TC-MT-13 | Xóa mềm | DELETE | `deletedAt` set; không còn trong list; GET trả 404 |
| TC-MT-14 | Xóa không ảnh hưởng lô cũ | batch đã có | Batch và deliveries nguyên vẹn |
| TC-MT-15 | Truy cập chéo Workspace | token Workspace A, template của B | 404/403, không lộ dữ liệu |

## 4. Sanitize và biến (AC-C3, AC-S3, AC-S4, AC-S7)

| ID | Case | Input | Mong đợi |
|---|---|---|---|
| TC-SAN-01 | Loại `<script>` | `<p>a</p><script>x</script>` | Chỉ còn `<p>a</p>` |
| TC-SAN-02 | Loại event handler | `<a onclick="x()">` | Không còn `onclick` |
| TC-SAN-03 | Loại `javascript:` | `<a href="javascript:...">` | `href` bị bỏ |
| TC-SAN-04 | Giữ thẻ cho phép | `b,i,u,a,ul,ol,li,h1-h3,blockquote,img` | Giữ nguyên |
| TC-SAN-05 | `img` ngoài bucket hệ thống | `src="https://evil.test/x.png"` | Bị loại/từ chối |
| TC-SAN-06 | Body quá 100KB | 101KB | 400 `VALIDATION_ERROR` |
| TC-VAR-01 | Render biến đầy đủ | `Hi {{name}}` + `name=An` | `Hi An` |
| TC-VAR-02 | Escape giá trị | `name=<b>x</b>` | `&lt;b&gt;x&lt;/b&gt;` |
| TC-VAR-03 | Biến thiếu | không có `name` | Dòng vào `rejected`, `MISSING_VARIABLE:name` |
| TC-VAR-04 | Biến built-in | `{{workspaceName}}`, `{{senderName}}` | Tự điền |
| TC-VAR-05 | Biến trong subject | `Hello {{name}}` | Subject đã render |
| TC-VAR-06 | Tên biến sai cú pháp | `{{ten bien}}` | Không coi là biến; giữ nguyên text, cảnh báo ở preview |
| TC-VAR-07 | CSV cố ghi đè built-in | cột `workspaceName` | Giá trị hệ thống thắng |
| TC-PRE-01 | Preview trả biến còn thiếu | thiếu `x` | `missingVariables=["x"]` |

## 5. Gửi (AC-S, AC-H)

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

## 6. Quota, worker (AC-S9, AC-H4)

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

## 7. Unsubscribe (AC-X)

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

## 8. Tệp đính kèm, lịch sử, Admin

| ID | Case | Mong đợi |
|---|---|---|
| TC-ATT-01 | Upload PDF hợp lệ ≤5MB | 200 + `attachmentId` |
| TC-ATT-02 | Đuôi `.pdf` nhưng nội dung là exe | 400 `MAIL_ATTACHMENT_INVALID` |
| TC-ATT-03 | Loại không cho phép (`.exe`, `.zip`, `.html`) | 400 |
| TC-ATT-04 | Tệp >5MB | 413/400 |
| TC-ATT-05 | Quá 3 tệp / tổng >10MB | 400 |
| TC-ATT-06 | Tệp chưa gắn quá 24h | Job dọn xóa |
| TC-ATT-07 | Tệp thuộc Workspace khác | Từ chối gắn |
| TC-ATT-08 | Tệp S3 mất trước giờ gửi | Delivery `FAILED` rõ lý do, không gửi thiếu tệp |
| TC-ATT-09 | Ảnh trong nội dung | URL công khai chèn được; sanitize chấp nhận |
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

## 9. UI (Playwright, mock REST)

| ID | Case | Mong đợi |
|---|---|---|
| E2E-MT-01 | Mở trang list | Hiển thị bảng, chip "Hệ thống", loading → dữ liệu |
| E2E-MT-02 | Trạng thái rỗng và lỗi | Thông điệp rỗng; lỗi có nút thử lại |
| E2E-MT-03 | Tạo template (TipTap, chèn biến, ảnh) | Gọi POST đúng payload `bodyHtml`; hiện trong list |
| E2E-MT-04 | Lỗi tạo | Form giữ nguyên dữ liệu, hiển thị lỗi |
| E2E-MT-05 | Sửa và xóa có xác nhận | PATCH/DELETE đúng; hủy xác nhận không gọi API |
| E2E-MT-06 | Modal Gửi: dán CSV | Parse đúng, hiển thị dòng lỗi, map cột |
| E2E-MT-07 | CSV có BOM/ngoặc kép/dòng trống | Parse đúng |
| E2E-MT-08 | Biến tự phát hiện | Hiển thị ô nhập cho biến chưa có trong CSV |
| E2E-MT-09 | Preview | Hiển thị subject/body đã render và cảnh báo biến thiếu |
| E2E-MT-10 | Gửi thử | Gọi `send-test`; toast thành công/lỗi 502 |
| E2E-MT-11 | Gửi ngay | 202 → chuyển sang trang lô |
| E2E-MT-12 | Hết quota | Nút gửi ngay khóa; vẫn hẹn giờ được; hiện số còn lại |
| E2E-MT-13 | Hẹn giờ | Chọn giờ hợp lệ; ngoài khoảng bị chặn tại form |
| E2E-MT-14 | Bấm đúp | Chỉ một request gửi |
| E2E-MT-15 | Trang lô và hủy lịch | Hủy gọi POST cancel; trạng thái cập nhật |
| E2E-MT-16 | Nút gửi từ trang Client | Modal có `contact_email` và `clientName` điền sẵn |
| E2E-MT-17 | Trang unsubscribe công khai | Xác nhận và kết quả, không cần đăng nhập, vi/en |
| E2E-MT-18 | Admin: trang mẫu hệ thống | CRUD hoạt động; user thường không thấy |
| E2E-MT-19 | Broadcast: Chọn mẫu | Điền subject/body vào form |
| E2E-MT-20 | i18n | Đổi vi ↔ en không vỡ layout, không còn key thô |
| E2E-MT-21 | Light/Dark | Chuyển theme không vỡ contrast; chip và trạng thái dùng token |
| E2E-MT-22 | Responsive | Modal gửi, list và trang lô dùng được ở 375px |
| E2E-MT-23 | Route guard | CLIENT không vào được `/mail-templates` |

## 10. Live integration (backend thật + SMTP giả)

| ID | Case | Mong đợi |
|---|---|---|
| IT-MT-01 | Gửi 1 Client | Hộp thư giả nhận; subject/body đúng; `Reply-To`/`From` đúng |
| IT-MT-02 | Gửi nhiều người ngoài | Có footer và header `List-Unsubscribe` + `List-Unsubscribe-Post` |
| IT-MT-03 | Tệp đính kèm | Mail có đúng tệp, nội dung khớp |
| IT-MT-04 | Unsubscribe thật qua link trong mail | Lần gửi sau bị `SUPPRESSED` |
| IT-MT-05 | Quota nhỏ (cap=3) | 3 gửi, phần còn `PENDING`, dời ngày kế |
| IT-MT-06 | Hẹn giờ ngắn (chỉnh cấu hình) | Mail đến đúng giờ |
| IT-MT-07 | Hủy lịch | Không có mail |
| IT-MT-08 | 2 instance worker | Không gửi trùng |
| IT-MT-09 | Quyền chéo Workspace | 403/404 ở mọi endpoint |
| IT-MT-10 | Retention giả lập | Dữ liệu cũ bị xóa, counters giữ |

## 11. Bảo mật

| ID | Case | Mong đợi |
|---|---|---|
| SEC-MT-01 | XSS qua body/biến/subject | Không thực thi trong preview và mail |
| SEC-MT-02 | Header injection (`\r\n` trong subject/email) | Bị loại/từ chối |
| SEC-MT-03 | Token unsubscribe giả/lặp lại/của Workspace khác | Từ chối hoặc idempotent, không ảnh hưởng dữ liệu khác |
| SEC-MT-04 | IDOR template/batch/attachment | 403/404 |
| SEC-MT-05 | Upload tệp giả mạo | Bị magic bytes chặn |
| SEC-MT-06 | Mass assignment (`type`, `workspaceId`, `createdBy` trong body) | Bị bỏ qua |
| SEC-MT-07 | Rò rỉ email trên trang unsubscribe | Chỉ hiển thị email đã che |

## 12. Tiêu chí đạt

- 100% case mục 3–11 đạt hoặc có ghi chú giới hạn rõ ràng.
- Không còn lỗi lint/type-check mới; vi/en song song; light/dark kiểm tra.
- Mọi AC trong spec §4 có ít nhất một case tương ứng đạt.

## 13. Giới hạn đã biết (dự kiến)

- Không quét virus (chỉ allow-list + magic bytes).
- Giao hàng at-least-once: crash đúng khoảnh khắc giữa gửi và commit có thể gửi trùng một mail.
- Worker đơn instance được kiểm cho `SKIP LOCKED`; scale đa instance chưa được xác nhận ở môi trường thật.
- Hiển thị email phụ thuộc client thư (Gmail/Outlook/Apple Mail) — kiểm tra bằng mắt.
- Gmail có thể vẫn đánh dấu spam dù đã cap; cần theo dõi thực tế.

## 14. Kết quả thực thi

### 14.1 Bước 1–2 (CRUD, sanitize, render, preview) — 2026-10-12
Nhánh `feat/DA-998-mail-template-crud` (business-service), commit `23503e3`.

| Nhóm | Cách chạy | Kết quả |
|---|---|---|
| JUnit: `HtmlSanitizerTest` | `mvn test` | 11/11 (TC-SAN-01..05 và biến thể) |
| JUnit: `TemplateRendererTest` | `mvn test` | 8/8 (TC-VAR-01..07) |
| JUnit: `MailTemplateServiceImplTest` | `mvn test` | 28/28 (TC-MT-01..15 mức service, TC-PRE-01) |
| Toàn bộ business-service | `mvn clean test` | 587/587, không hồi quy |
| Live (backend thật + Postgres + Mongo local) | curl, DB scratch | pass: tạo (script bị loại), 401/403/404, PATCH khác người tạo 403, PATCH subject trống 400, preview escape, tìm kiếm, soft delete (`deletedAt` set, GET 404, list loại) |
| Migration Mongo `2026-10-12-create-mail-templates-collection.js` | mongosh trên DB tạm | validator nhận bản ghi hợp lệ, từ chối `subject` rỗng và `type` sai; chạy lại idempotent; 3 index |

Chưa chạy: gửi (DA-1002), tệp đính kèm (DA-1256), hẹn giờ/unsubscribe (DA-1257), lịch sử (DA-1258), Admin (DA-1259), toàn bộ frontend và E2E.

Ghi chú triển khai: ảnh trong nội dung bị loại hết cho đến khi cấu hình `mail.allowed-image-hosts` (bước tệp đính kèm); subject không HTML-escape (là header văn bản thuần), chỉ bỏ xuống dòng.

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

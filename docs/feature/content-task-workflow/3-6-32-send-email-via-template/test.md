# Test — Send Email via Template (FR 3.6.32)

> Nguồn chuẩn dùng chung cho cả 5 FR: [../3-6-28-32-mail-template/](../3-6-28-32-mail-template/) (spec, plan, task, test gộp). File này lấy đúng phần của FR 3.6.32 để mỗi FR có đủ bộ 4 tài liệu (`spec.md`, `plan.md`, `task.md`, `test.md`) theo `docs/rule/feature-workflow.md`. Khi có khác biệt, bản gộp là bản đúng.

- **Jira:** DA-1002
- **Mục tiêu:** Gửi email theo mẫu tới danh sách người nhận: hàng đợi, hạn mức, hẹn giờ/hủy, hủy đăng ký, lịch sử, Admin.

## 1. Cách chạy

```bash
# Backend (JUnit): mail template, gửi, worker
cd brandhub-business-service && mvn test -Dtest='Mail*Test'
# Frontend
cd brandhub-web-dashboard && npx vitest run src/pages/mail-templates
cd brandhub-web-dashboard && npx playwright test tests/e2e/mail-templates
```

## 2. Test case của FR này

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

## 3. Kết quả

- Toàn bộ test case ở trên đã chạy và đạt; chi tiết số liệu từng đợt ở mục 14–16 của [bản gộp](../3-6-28-32-mail-template/test.md).
- Tổng sau đợt cuối: business-service 704 test, vitest 64, Playwright mail 25, kèm chạy live với Postgres + Mongo + SMTP giả.
- Giới hạn đã biết và việc chưa kiểm (Gmail/Outlook, S3 thật, staging): xem mục 13 và 14.2 của bản gộp.

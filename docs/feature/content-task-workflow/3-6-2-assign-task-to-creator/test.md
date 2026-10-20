# Test — FR 3.6.2 / DA-978

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](../task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

Baseline giai đoạn 1 chưa test ứng dụng; các dòng dưới giữ checklist nghiệm thu đầy đủ. Đợt 2026-10-15 đã chạy unit/MockMvc, Mongo cô lập và browser mock; không tuyên bố đã test Atlas/PostgreSQL inbox/Approval integration. Evidence/giới hạn: [bàn giao đợt 2/3](../task-workflow-phase-2-3.md). AC theo [spec](spec.md) §3/6/7.

| ID | Input/điều kiện | AC | Mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| A01 | Manager, DETAIL_IDENTIFIED, Creator active | Giao lần đầu | ASSIGNED + assignment audit + notification | Happy | Chưa test |
| A02 | Creator khác làm QC hoặc null, Client approval true/false | QC/Client tùy chọn | Lưu đúng cấu hình duyệt, Client vẫn đọc/bình luận ở cả hai giá trị | Happy | Chưa test |
| A03 | QC=assignee; wrong WS/role/inactive; dùng membership ID | Ràng buộc identity | 400 theo field, không ghi/outbox | Error | Chưa test |
| A04 | BACKLOG chưa xác định chi tiết | Error §6 | 409 TASK_DETAIL_NOT_IDENTIFIED | Error | Chưa test |
| A05 | ASSIGNED chưa start đổi Creator/QC | Giao lại | Giữ ASSIGNED, revision tăng | Edge | Chưa test |
| A06 | IN_PROGRESS/review/terminal/reject ASSIGNED có marker | Khóa sau start | 409, không đổi người/lịch sử approval | Error | Chưa test |
| A07 | Assignee bấm Start lần đầu | Q8 | IN_PROGRESS, firstStartedAt/By server, revision tăng | Happy | Chưa test |
| A08 | Không phải assignee bấm Start hoặc chỉ mở trang/editor | Q8/quyền | Không start; 403 nếu mutation trái quyền | Error | Chưa test |
| A09 | Retry/concurrent assign/start/cancel/complete | Audit/state | Chỉ một mutation, không phục hồi CANCELLED | Edge | Chưa test |
| A10 | Membership bị gỡ giữa options và submit | Active same WS | API từ chối, không dùng options cached làm quyền | Error | Chưa test |
| A11 | Legacy thiếu first-start evidence | Không mở khóa reject | Yêu cầu review, không gán null tự động | Edge | Chưa test |
| A12 | Outbox retry hoặc SQL insert thành công rồi worker crash | Notification | Một inbox delivery, có retry không mất | Edge | Chưa test |
| A13 | Owner Agency không là Manager WS | Quyền Manager | 403; Owner là Manager WS thì hợp lệ | Error | Chưa test |
| A14 | vi/en, light/dark, mobile/keyboard, empty Creator list | i18n/theme | Nhãn/quyền đúng, không submit selection giả | Happy | Chưa test |
| A15 | Resubmit sau reject với QC có/không | Giữ history/Q7 | Phối hợp E51-03 duyệt lại QC/Manager, marker không reset | Edge | Chưa test |
| A16 | Assign/reassign Task thủ công với requiresClientApproval=true | Q13 | Hợp lệ khi đủ guard, không có lỗi Q12; Client xem/bình luận được | Happy | Chưa test |
| A17 | Task manual/Campaign/Request với requiresClientApproval=false | Q13 | Vẫn giao được và Client xem/bình luận được, không thêm bước Client duyệt | Happy | Chưa test |
| A18 | Form Assign cho cả ba nguồn Task | Q13/UI | Không có bộ chọn nội bộ/thường, checkbox Client duyệt không khóa theo nguồn | Edge | Chưa test |

Slice bổ sung: duplicate/outdated worker lease không đổi event mới; SQL delivery retry cùng UUID không nhân đôi inbox; schema chưa migration không tạo collection; notification chỉ giao việc, không gửi mail; form lưu thất bại giữ Creator/QC và cờ duyệt.

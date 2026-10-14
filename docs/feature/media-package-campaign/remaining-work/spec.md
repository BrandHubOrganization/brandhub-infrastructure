# Phần 3.5 còn lại — giai đoạn 1: chốt nghiệp vụ

Ngày: 2026-10-13. Giai đoạn này chỉ chỉnh tài liệu, không code, chạy migration hoặc sửa dữ liệu. Không phải `phase-1-design` của đợt Campaign trước.

> **Quyết định sau này 2026-10-14 thay thế các dòng lịch sử bên dưới về campaignId=null và xử lý Request sau hoàn thành:** xem ../campaign-closure/spec.md. Task Request mới gắn Campaign; mọi Task chưa kết thúc và Request IN_PROGRESS chặn hoàn thành. PENDING tự hủy sau hoàn thành thành công. Manager có bulk cancel Task với lý do chung, không xóa lịch sử.

## Nguồn và quyết định đã được người dùng xác nhận

- DA-951 / E50-10 / FR 3.5.7–3.5.10: Client tạo yêu cầu bổ sung chỉ khi Campaign IN_PROGRESS và deployment SUCCEEDED; Campaign COMPLETED không cho tạo mới. Request đã có tiếp tục được xử lý theo trạng thái hiện tại, không tự hủy/khóa khi Campaign hoàn thành. Task sinh ra vẫn có `campaignId=null`.
- Client sửa tiêu đề, mô tả, loại và hạn hoàn thành khi `PENDING`; người tạo được hủy bằng `CANCELLED`, không hard delete.
- Manager bấm **Tiếp nhận yêu cầu**: `PENDING -> IN_PROGRESS` (**Đang xem xét**). Xem trang không kích hoạt chuyển trạng thái. Sau tiếp nhận, Client không được sửa/hủy.
- Manager chấp nhận/từ chối từ `IN_PROGRESS`. Chấp nhận sinh đúng một Task BACKLOG; trạng thái cuối không mở lại.
- DA-943: bỏ scheduled reminder chọn Package; giữ gate Package hiện có. Không thêm scheduler/notification cho yêu cầu cũ này.
- DA-949: đối tác chưa từng được Campaign sử dụng được xóa; đối tác đã được sử dụng chỉ ngừng sử dụng. Không cho gán mới nhưng các Campaign đang liên kết vẫn xem/cập nhật hợp tác.
- DA-950: không làm lại module hợp tác; tích hợp cờ khả dụng và kiểm thử hồi quy.
- Chỉ Owner quản lý danh bạ cấp Agency; Manager/Creator chỉ chọn/gán đối tác theo quyền Workspace DA-950. Người dùng đã chốt cả ba câu hỏi bổ sung trong phiên 2026-10-13.

## Ranh giới

Giữ một Campaign/Workspace, Campaign đã duyệt bất biến, Task Mongo V2. Không init Atlas, tạo account mới, sửa module editor/social/AI của thành viên khác hoặc xây billing/booking. EVENT_PLAN/PRESS_RECOMMENDATION tiếp tục thuộc luồng Task đã chốt; Request giữ ba loại POST/LIVESTREAM/SURVEY theo spec hiện hành. Giới hạn đề xuất Client của Package hiện có không đổi.

## Câu hỏi đã chốt — 2026-10-13

| ID | Quyết định |
|---|---|
| Q1 | Chỉ tạo mới khi Campaign IN_PROGRESS, deployment SUCCEEDED; COMPLETED không tạo mới. |
| Q2 | Chỉ Owner quản lý danh bạ; Manager/Creator chọn/gán theo quyền DA-950. |
| Q3 | Request đã có tiếp tục được xử lý sau khi Campaign hoàn thành; không tự hủy/đổi trạng thái. |

Các quyết định ở đây là xác nhận trong phiên làm việc; khi cập nhật BA dùng chung cần người dùng/lead thông báo team theo team guide. Không xem nhánh docs là thay thế việc review chung.

## Hợp đồng và tiêu chí hoàn tất

- Các spec FR 3.5.7–3.5.10 và [partner-directory/spec.md](../partner-directory/spec.md) là nguồn hành vi chi tiết; master-plan phải không mâu thuẫn với chúng.
- UI Request dùng trạng thái yêu cầu riêng, không dùng SUBMITTED/ASSIGNED/PENDING_REVIEW của mock cũ. Task assignment/approval không thuộc DA-951.
- Mọi UI mới dùng parallel vi/en và semantic light/dark; không nâng cấp lại toàn bộ UI chung.
- Tài liệu đủ bốn file, nêu migration/preflight, rollback, chống trùng, test quyền/concurrency và checkpoint. Không còn câu hỏi BA chặn giai đoạn 2; mapping dữ liệu legacy phải inventory/review riêng trước migrate.

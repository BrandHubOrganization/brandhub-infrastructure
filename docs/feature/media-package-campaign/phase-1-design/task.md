# Giai đoạn 1 — checklist

- [x] Đối chiếu BA một Workspace/một Campaign và roadmap 6 giai đoạn.
- [x] Rà soát Campaign entity/DTO, Task JPA, Mongo validator và editor REST/WS.
- [x] Đề xuất field Campaign, work item, version/approval và API có scope Workspace.
- [x] Thiết kế Task Mongo + PostgreSQL editor soft refs, migration/cutover và regression.
- [x] Phân biệt sản lượng bàn giao, Task workflow và collection nội dung chuyên biệt.
- [x] Gửi A1–A3 cho người dùng; không tự chọn câu trả lời.
- [x] Viết test matrix để giai đoạn tiếp theo có tiêu chí kiểm chứng.
- [x] A1: tổng sản lượng cả gói; không có monthly allowance; không tự chuyển snapshot cũ.
- [x] A2: EVENT_PLAN/PRESS_RECOMMENDATION; Task chung và collection nội dung riêng.
- [x] A3: cho Manager complete còn Task dang dở với lý do, không đổi trạng thái Task con.
- [x] Finalize contract và đồng bộ FR 3.5.5/3.5.6/master-plan sau câu trả lời.
- [x] Ghi phạm vi phối hợp Task/editor và task mở rộng cần phân công trước implementation.
- [x] Cập nhật roadmap hoàn thành thiết kế giai đoạn 1; bước tiếp theo là giai đoạn 2.

Bàn giao còn lại cho giai đoạn implementation: review adapter Workshop/Meet và
schema chuyên biệt với chủ E51; cấp task Jira cho phần phát sinh; inventory dữ liệu
legacy trước migration. Chưa có trao đổi bên ngoài hoặc xác nhận của thành viên khác.

Chưa code, migrate, seed hay chạy test ứng dụng cho giai đoạn mới. Audit nguồn code
không thay thế kiểm tra dữ liệu DB hiện hữu hoặc integration test.

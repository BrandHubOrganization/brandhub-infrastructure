# Test matrix từ thiết kế giai đoạn 1

Đây là test case dự kiến, tất cả **chưa chạy** cho implementation mới.

| ID | AC | Tình huống | Mong đợi |
|---|---|---|---|
| C01 | AC1 | Hai request tạo cùng Workspace | Tối đa một Campaign; request còn lại nhận conflict hoặc cùng tài nguyên |
| C02 | AC1 | Campaign COMPLETED, tạo thêm | Bị chặn; chiến dịch mới cần Workspace mới |
| C03 | AC2 | Package chưa approved hoặc đổi catalogue sau chốt | Create bị chặn khi chưa chốt; snapshot đã chốt không bị catalogue thay đổi |
| C04 | AC3 | Client góp ý | Không thay contentVersion hoặc nội dung của Campaign |
| C05 | AC3 | Manager sửa sau một phía duyệt | Version tăng, cả hai approval mất hiệu lực, lịch sử còn |
| C06 | AC3 | No-op update / stale expectedVersion | No-op không tăng contentVersion; stale update/approve bị từ chối |
| C07 | AC4 | Deploy thiếu approval hoặc khác version | Bị chặn; không sinh Task |
| C08 | AC4 | Fully approved content edit | Bị chặn; tiến độ vận hành vẫn quản lý riêng |
| C09 | AC5 | Task từ Campaign | Đúng Workspace/campaignWorkItemId, BACKLOG, chưa assignee/QC |
| C10 | AC7 | Double deploy, crash giữa chừng, retry sau Creator edit | Không trùng Task; không reset nội dung/trạng thái/assignee |
| C11 | AC8 | Đổi campaignId/workspaceId hoặc user bị gỡ khỏi WS | Không đọc/ghi/approve/deploy hoặc nhận nội dung WS trái quyền |
| C12 | AC5 | Migrate một PG Task đã có Yjs | Giữ UUID, nội dung/snapshot/URL cũ; editor đọc/ghi được qua Mongo lookup |
| C13 | AC5 | Mongo trùng UUID nhưng khác Workspace | Preflight/cutover dừng báo conflict; không overwrite |
| C14 | AC5/8 | WS SEND/SUBSCRIBE Task khác Workspace | Từ chối dù token hợp lệ |
| C15 | AC5 | Mongo mất kết nối khi editor save | Báo lỗi; không fallback tạo PG Task hoặc ghi nội dung không xác minh |
| C16 | AC6 | Task list rỗng/tất cả complete | Campaign không tự complete; Manager action mới quyết định |
| C17 | AC6 | Complete khi Task còn dang dở | Lý do trống bị chặn; có lý do lưu actor/time/summary và giữ nguyên Task con |
| C18 | AC1 | DB hiện hữu có nhiều Campaign/Workspace | Audit báo ID; migration không tự xóa hoặc relink |
| C19 | UI | vi/en, light/dark, mobile, lỗi/version conflict | Đúng text, không tràn layout, action state phản ánh API |
| C20 | A1 | Legacy monthly snapshot thiếu thời hạn | Không âm thầm chuyển thành total; báo cần xử lý trước planning |
| C21 | A2 | Task mới Event/press | EVENT_PLAN/PRESS_RECOMMENDATION đi đúng workflow; specialist content theo taskId; không vào publisher POST |
| C22 | AC5 | Editor mở bằng taskId đã deploy | Không tự tạo thêm Untitled post; content/version history đúng Task |
| C23 | A1 | Gói mới 12 bài, thời hạn 3 tháng | Tổng 12 bài, không tự nhân thành 36 hoặc reset mỗi tháng |
| C24 | A1 | API tạo mới kèm period monthly | Báo validation; không âm thầm nhận quy tắc đã bỏ |
| C25 | AC6 | Complete lặp / Task tiếp tục sau Campaign complete | Không ghi đè lần complete; Task vẫn theo workflow và quyền hiện tại |
| C26 | AC6 | Mongo lỗi khi đếm Task để complete | Không đánh đồng lỗi với zero Task; không mark completed |

Kiểm tra tài liệu giai đoạn 1: link nội bộ tồn tại, quyết định đã chốt khác đề xuất,
schema/API có version và quyền, mỗi AC có test, roadmap không đánh dấu hoàn thành sớm.

A1–A3 đã được người dùng xác nhận; kiểm tra tĩnh tài liệu không được tính là test
ứng dụng pass. Editor/DB inventory và migration chỉ chạy ở giai đoạn implementation.

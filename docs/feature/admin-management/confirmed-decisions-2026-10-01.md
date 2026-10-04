# Admin Management — quyết định xác nhận ngày 2026-10-01

Nguồn chuẩn là file Word `khongpush_gihub_MCP/Report/FR_3.10_Admin_Management.docx` cùng các quyết định người dùng đã xác nhận trong cuộc trao đổi. Bản này cập nhật nghiệp vụ và checklist, chưa chứng nhận code đã triển khai.

## FR được sửa

| FR | Chức năng | Thay đổi |
|---|---|---|
| 3.10.1 | Thông báo | EMAIL trước; audience lúc gửi; sửa/hủy DRAFT/SCHEDULED; CANCELLED; ADMIN/USER và catalog gói. |
| 3.10.2 | Thống kê | Active = đăng nhập thành công; ba tiêu chí xếp hạng Agency; UTC/VN; strike hiệu lực và tiền thu. |
| 3.10.4 | Kiểm duyệt | Content bài theo phiên bản; ADMIN duyệt; giữ bài đã lên lịch; chặn bản cũ cho gửi bản sửa. |
| 3.10.5 | Trạng thái và strike | Ba Vàng quy đổi một Cam, đánh dấu nguồn; tái phạm reset 30 ngày; ba Cam chờ Admin; unflag có điều kiện; xác thực email. |
| 3.10.6 | Danh sách user | System role riêng với Agency; catalog gói; bộ đếm x/3, trạng thái hiệu lực/lịch sử và hạn khóa. |
| 3.10.7 | Tạo user | PENDING_VERIFICATION, email bắt buộc và requirePasswordReset; chỉ mở quyền sau cả hai điều kiện. |
| 3.10.8 | Sửa user | Email bất biến; sửa hồ sơ Owner được phép; đổi gói kỳ sau, vẫn trả tiền, không tự ghi doanh thu. |
| 3.10.9 | Khóa tài khoản | Admin xác nhận; khóa Owner duy nhất vẫn giữ hoạt động thành viên; đủ 30 ngày tự ACTIVE + email. |
| 3.10.11 | Doanh thu | MRR/ARR chuẩn hóa thuê bao; tách thu gộp/hoàn/ròng; AI Credit không vào MRR; UTC/VN. |
| 3.10.12 | PDF | Đồng bộ strike, trạng thái, công thức tiền và múi giờ; giữ A4, link 24 giờ và audit. |

FR **3.10.3 System Health Monitoring** thuộc Tuấn, không sửa Word section, ba file feature hay `docs/feature/system-health`. FR 3.10.10 vốn không có trong tài liệu, không thêm hoặc đánh lại số. Giữ cấu trúc 8 phần của Report 3, mẫu UC của spec và checklist của task.md.

## Quyết định dùng chung

- System role chỉ ADMIN/USER; quyền Agency/Workspace quản lý riêng; plan đọc từ subscription catalog hiện có (BASIC/PRO/ENTERPRISE tại thời điểm đối chiếu).
- Strike thay cho Trust Score: ba Vàng còn hiệu lực và chưa quy đổi tạo một Cam độc lập, bất kỳ category; ba thẻ nguồn được đánh dấu, không tái dùng. Vàng thứ tư bắt đầu nhóm mới; gỡ nguồn không gỡ Cam.
- Mỗi vi phạm mới bắt đầu lại 30 ngày sạch. Hết hạn/gỡ giữ audit; không hồi sinh thẻ cũ. Ba Cam hoặc Đỏ tạo yêu cầu xét, chỉ Admin xác nhận mới DEACTIVATED. Không unflag khi chưa xử lý thẻ còn hiệu lực.
- Owner duy nhất vẫn sửa hồ sơ, ghi thẻ, gắn cờ và bị khóa; thành viên khác làm việc trong quyền hiện có, thao tác chỉ Owner tạm dừng; không tự chuyển Owner/khóa Agency.
- DEACTIVATED khóa cả tài khoản, thu hồi mọi session/token. Đủ 30 ngày tự ACTIVE và gửi email; quyết định này thay thế câu trả lời trước về Admin mở thủ công.
- PENDING_VERIFICATION là chưa xác thực email, không phải mất Authenticator. Tài khoản Admin tạo phải xác thực email và thay mật khẩu; trước đó chỉ kích hoạt/đổi mật khẩu/đăng xuất/hỗ trợ. Không yêu cầu thiết lập lại 2FA.
- Chỉ EMAIL trong đợt này. Người nhận xác định lúc gửi; sửa/hủy DRAFT/SCHEDULED; CANCELLED không gửi, SENT không thu hồi.
- Báo cáo hỗ trợ UTC và Asia/Ho_Chi_Minh; lưu UTC. MRR = thuê bao trả phí hiệu lực sau giảm giá quy về tháng, gói năm /12; ARR = MRR×12. Thu gộp, hoàn và thu ròng tách riêng; AI Credit chỉ vào tiền thu. Đổi gói bởi Admin có hiệu lực kỳ sau, vẫn thanh toán, thao tác không tự ghi doanh thu.

## Quy ước kỹ thuật được ghi rõ để triển khai

Các chi tiết dưới đây là cách cụ thể hóa yêu cầu, không phải tính năng sản phẩm mới: gắn quyết định kiểm duyệt với `contentVersionId`; xử lý lặp an toàn và liên kết nguồn quy đổi; không coi quy đổi là tái phạm; giữ lịch sử khi hết hạn; job bù khi gián đoạn; gửi email lỗi không hoàn tác mở khóa. Mặc định timezone báo cáo Việt Nam và chọn ba bảng xếp hạng riêng để không tự đặt trọng số.

## Việc cần đối chiếu code trong bước thiết kế kỹ thuật

- Xác định service hiện sở hữu post, version, scheduler/publisher và sự kiện moderation; không mặc định tồn tại một admin-service độc lập.
- Ánh xạ chính xác nguồn sự kiện hoạt động Agency, cách đếm bài và quy thuộc doanh thu; ba tiêu chí đã chốt, chưa có công thức điểm tổng hợp.
- Tận dụng auth/email/password policy, subscription billing và response/error envelope hiện có. Xác định migration SUSPENDED sang trạng thái mới mà không nhầm DELETED hoặc mở sai tài khoản.
- Các endpoint/DTO trong spec là đề xuất; phải có plan.md, task.md và test.md theo feature-workflow trước code. Không coi checklist đã hoàn thành.

## File đồng bộ

- Word được chỉnh tại đường dẫn gốc, giữ format; 10 FR tương ứng trong `spec.md`, `report3_spec.md`, `report3_spec_en.md`.
- [BA Admin Management](../../BA/09-admin-management.md) được sửa cùng các quyết định mới, giữ nguyên dòng Monitoring.
- `data_fr_310_group_a.py`, `data_fr_310_group_b.py` và bản `_vi.py` được cập nhật để lần build sau không khôi phục nghiệp vụ cũ.
- `F:/LEARN/DA/task.md` cập nhật checklist; bản sao trước sửa ở `.tmp/fr310-before-20261001` trong workspace.

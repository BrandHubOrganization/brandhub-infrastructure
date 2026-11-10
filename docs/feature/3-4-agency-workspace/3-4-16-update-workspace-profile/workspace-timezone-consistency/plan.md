# Plan — timezone consistency

Theo [spec](spec.md). Đây là bugfix tương thích API, không phải thay BA deadline/duplicate.

1. WorkspaceServiceImpl thêm projection WorkspaceSettings dùng timezone_config. toResponse dùng projection,
   không persist khi GET; parse JSON thiếu/invalid/null an toàn, giữ known settings fields nếu hợp lệ.
2. updateSettings validate timezone yêu cầu trước mọi setter; ZoneId.of kiểm hợp lệ, lỗi dùng
   VALIDATION_ERROR + fields.timezone. Ghi cột chuẩn và JSON mirror trong transaction hiện có;
   không có timezone trong payload thì giữ cột chuẩn. Không thay quyền/controller/global auth.
3. WorkspaceDuplicationServiceImpl effectiveTimezone dùng timezone_config thay ưu tiên JSON cũ;
   giữ copyTimezone=false và các chính sách clone còn lại. Document amendment trong 4 file duplicate.
4. Test mock service GET/create/list/partial-update/invalid-zone và clone; boundary test chứng minh
   timezone API trùng ContentRequestDeadline. Không mở Spring context/seeders/live data writers.
5. Chạy regression WorkspaceServiceTest, WorkspaceDuplicationServiceImplTest, ContentRequestDeadlineTest
   và test mới. Frontend chỉ kiểm helper deadline hiện có; không cần sửa API Gateway/Web.

Rủi ro: database khác có JSON/cột lệch nhau. Projection chỉ hiển thị cột chuẩn, không tự backfill/xóa JSON.
Operator phải review cấu hình trước rollout nếu đã cấu hình timezone chỉ trong JSON ở môi trường khác.
Không downgrade/sửa migration cũ, không thêm schema mới; init PostgreSQL đã có cột/default này.

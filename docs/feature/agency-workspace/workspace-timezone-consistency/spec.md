# Workspace timezone consistency — sửa lỗi Content Request deadline

2026-10-14. User yêu cầu fix sau inventory Workspace 864f1df2-d0c9-4b74-8c3a-29ab63cccb97.
Phạm vi: sửa contract đọc/ghi timezone, không thay quy tắc deadline hoặc quyền Workspace.

## Nguồn và nguyên nhân

[Content Request deadline](../../media-package-campaign/request-completion-validation/spec.md),
[Duplicate Workspace](../duplicate-workspace/spec.md). Campaign hợp lệ nhưng UI đọc settings.timezone=null,
trong khi ContentRequestDeadline kiểm timezone_config=Asia/Ho_Chi_Minh. Inventory chỉ đọc local:
124 Workspace active, 124 thiếu settings.timezone, không có cặp timezone khác nhau tại snapshot.

## Acceptance criteria

- timezone_config là nguồn chuẩn đã được Backend dùng cho deadline. Mọi WorkspaceResponse vẫn trả
  settings.timezone (không đổi API shape) nhưng lấy giá trị từ timezone_config, cả GET/list/create/update.
- Đọc Workspace không sửa JSON/data cũ; giữ defaultPlatforms và industryFields hiện có.
- Đổi timezone trong Settings phải validate ZoneId, rồi ghi timezone_config và settings.timezone cùng
  transaction. Payload sai/blank trả 400 VALIDATION_ERROR với fields.timezone, không ghi/name change.
- Partial update không có timezone giữ nguyên cột chuẩn, không lấy JSON cũ ghi đè timezone_config.
- Workspace mới giữ default hiện có Asia/Ho_Chi_Minh; không tự chọn theo máy/người dùng.
- Nhân bản copyTimezone=true sao chép cột chuẩn — timezone API hiển thị và Backend kiểm deadline;
  false giữ default hiện có. Không đổi member/resource/package/campaign copy policy.
- Giữ xác thực/phân quyền và deadline max(today,start)..end; không hardcode timezone ở frontend.
- Không chạy migration, seed hoặc backfill DB trong đợt sửa này. Metadata dư không bị xóa.

## UI/UX và out of scope

Không sửa JSX/layout/i18n/theme; useRequestDeadline tiếp tục đọc settings.timezone như hiện tại.
Request date picker min/max và vi/en messages giữ nguyên. Không đổi auth, Campaign timeline hoặc Task workflow.
Không đổi JDK/Lombok hay khởi động service có seeders trong quá trình test.

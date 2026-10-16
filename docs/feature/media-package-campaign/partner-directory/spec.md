# DA-949 / E50-08 — Danh bạ đối tác Agency

Ngày: 2026-10-13. Thiết kế trước code; Q2 đã chốt: chỉ Agency Owner quản lý danh bạ.

## Mục đích và phạm vi

Agency lưu đối tác báo/banner/TV/khác để sử dụng trong nhiều Campaign. Danh bạ lưu thông tin đối tác; campaign_collaborators lưu trạng thái hợp tác riêng từng Campaign. Không gọi bên thứ ba, booking, thanh toán, AI recommendation hoặc tự publish.

## Acceptance criteria

- Confirmed 2026-10-14: optional phone supports Vietnam and international formats (7–15 digits; optional leading + and formatting spaces/hyphens/parentheses). Validate phone/email/HTTP(S) website on UI and server, preserve unknown contact keys. Format validation does not prove ownership or reachability. See ../request-completion-validation/spec.md.

- CRUD luôn scope theo Agency: tên, loại NEWSPAPER/BANNER/TV/OTHER, contactInfo, notes và audit fields; không chuyển đối tác sang Agency khác qua update.
- Thêm `isActive` (mặc định true cho dữ liệu cũ). Danh bạ quản lý thấy cả active/inactive; lựa chọn gán mới chỉ thấy active.
- Đối tác chưa từng được Campaign sử dụng: được xóa hẳn. Đối tác đã được sử dụng: chỉ chuyển inactive; xóa trả 409, không xóa/cascade liên kết hay thông tin lịch sử.
- Liên kết đã tồn tại vẫn hiển thị đối tác inactive và cho cập nhật hợp tác theo quyền DA-950. Gán lặp lại một liên kết tồn tại không tạo mới hoặc reset trạng thái.
- Inactive không được tạo liên kết mới, kể cả qua API legacy. Không làm tính năng kích hoạt lại trong đợt này nếu chưa có xác nhận BA.
- Delete/deactivate và assign đồng thời được xử lý nguyên tử, không tạo tham chiếu mồ côi hoặc link mới tới đối tác đã inactive.
- Chỉ Agency Owner tạo/sửa/xóa/ngừng sử dụng và xem danh bạ quản lý. Manager/Creator chỉ đọc/chọn active và gán theo Workspace scope/quyền DA-950; Client đọc đối tác đã liên kết, không quản lý danh bạ. Không suy ra quyền quản lý từ Agency MEMBER.

## API dự kiến

`/api/v1/agencies/{agencyId}/collaborators`: GET phân trang/lọc, POST tạo; `/{collaboratorId}`: GET, PATCH sửa và DELETE; `/{collaboratorId}/deactivate`: POST. DTO write dùng version hoặc expectedUpdatedAt chống ghi đè. Đây là contract dự kiến cần đối chiếu OpenAPI/consumer trước code, không phá endpoint legacy `/api/v1/collaborators`.

## UI

Danh bạ cấp Agency tách khỏi trang đối tác Campaign, route dự kiến `/agency/:agencyId/collaborators`, sidebar chỉ Owner. Có trạng thái loading/empty/error, tìm kiếm/phân trang, form tạo/sửa, xác nhận xóa/ngừng sử dụng và badge inactive. Namespace mới `collaborators`: `title`, `fields.*`, `status.active`, `status.inactive`, `actions.*`, `confirm.*`, `errors.*`, `empty`, `loading`; thêm song song locale vi/en. Semantic theme tokens, keyboard/focus, mobile và light/dark bắt buộc; không thay menu module khác.

## Lịch sử sử dụng

Xác nhận 2026-10-13: dữ liệu cũ chưa xác minh lịch sử **khóa xóa**, vẫn sửa/ngừng
sử dụng được. Thêm `usageHistoryVerified` (legacy=false; API create mới=true).
Không cung cấp API tự xác nhận lại lịch sử hoặc reactivate trong đợt này.
Chỉ xóa khi flag=true, firstUsedAt=null và không có link. UI hiển thị lý do khóa.

Schema hiện tại có FK ON DELETE RESTRICT nhưng chưa có dấu vết "đã từng dùng" nếu Campaign/link sau này bị xóa. Cần lưu marker sử dụng bền vững (đề xuất `firstUsedAt`), backfill từ liên kết đang có, và cập nhật atomically khi gán lần đầu. Không đoán được lịch sử đã mất; inventory và báo team trước migration. Đổi tên/liên hệ không tạo snapshot lịch sử mới trong scope này.

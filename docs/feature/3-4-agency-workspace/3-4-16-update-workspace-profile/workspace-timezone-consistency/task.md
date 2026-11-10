# Tasks — timezone consistency

- [x] Inventory chỉ đọc và đối chiếu nguyên nhân; thống nhất source chuẩn theo yêu cầu fix.
- [x] Chuẩn bị spec → plan → task → test; không mở lại stash Task phase1.
- [x] Projection settings.timezone từ timezone_config, giữ API shape và metadata hợp lệ.
- [x] Validate Settings timezone trước mutation; đồng bộ hai giá trị khi lưu.
- [x] Clone timezone theo cột chuẩn, giữ copy policy khác và cập nhật tài liệu duplicate.
- [x] Thêm regression legacy missing/conflicting JSON, partial update, invalid zone và boundary deadline.
- [x] Chạy selected Maven tests + Node deadline tests, kiểm diff và hướng dẫn restart/test.
- [ ] Smoke test account thật sau restart (không tự đăng nhập/khởi động seeders).

Không commit/push, migration hoặc ghi data thật nếu chưa được yêu cầu.

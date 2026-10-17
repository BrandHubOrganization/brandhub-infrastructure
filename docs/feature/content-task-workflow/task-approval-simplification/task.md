> Checkpoint 2026-10-17: restored from reviewed stash. Task structure removal of QC/plannedPublishAt and Atlas metadata APPLY are now implemented; see ../task-structure-simplification/. Approval endpoints, Post linkage, review notifications and snapshot/withdrawal decisions below remain pending. Earlier inventory/results are dated history, not current-state evidence.

# Checklist review và triển khai

Ngày: 2026-10-16. Các mục implementation dưới đây đều **chưa thực hiện** trong yêu cầu lưu kế hoạch.

## Review

- [x] Ghi lại BA đã chốt và các điểm hoãn/mở trong spec.md.
- [x] Lưu kế hoạch DB-first, tương thích code cũ và ranh giới với thành viên khác.
- [ ] Team review spec/plan; đồng bộ nguồn BA chung và phân công FR 3.6.9 trên Jira/master plan.
- [ ] Chốt tên nhận xét duyệt: giữ comment hay reviewNote.
- [ ] Chốt xử lý legacy QC/IN_REVIEW thiếu bước; duyệt allowlist trước mutation.
- [ ] Phối hợp Content Writing về nội dung được duyệt/khóa sửa; snapshot vẫn hoãn, không tự thay Q2.
- [ ] Chốt thu hồi nếu đưa vào scope sau này.

## DB-first

- [ ] Inventory lại Atlas, field/index conflicts và mọi writer đang hoạt động.
- [ ] Viết migrations mới DRY_RUN/APPLY theo phạm vi được duyệt; không sửa migration cũ.
- [ ] Đồng bộ init Mongo + checker + tests; không siết Post validator ngoài scope.
- [ ] Chạy rehearsal, legacy/new writer compatibility, uniqueness và rerun tests.
- [ ] Operator duyệt/freeze writers/backup trước APPLY; verify fingerprint và readiness sau APPLY.

## Ứng dụng — triển khai sau

- [ ] Bỏ QC/ngày đăng dự kiến khỏi luồng mới, giữ deadline/CAS và audit.
- [ ] Nối 1 Task POST → tối đa 1 Post; các loại khác phối hợp chủ module.
- [ ] Submit/approve/reject/history + notification; giữ publishing độc lập.
- [ ] Nghiệm thu integration với Content Writing; không duyệt live content chưa kiểm soát chỉ để demo.
- [ ] Test hồi quy Campaign/Request/Task/Post và tài khoản theo role.
- [ ] Chỉ cleanup legacy khi code đã chuyển đổi và dữ liệu được duyệt.

> **SUPERSEDED for new implementation — 2026-10-18:** tài liệu này giữ lịch sử đề xuất ngày 16/10, không dùng làm checklist hiện hành hoặc lệnh APPLY. Xem [spec FR3.6.9 v3](../3-6-9-approval-sequence-creator-manager-client/spec.md), [plan](../3-6-9-approval-sequence-creator-manager-client/plan.md), [task](../3-6-9-approval-sequence-creator-manager-client/task.md), [test](../3-6-9-approval-sequence-creator-manager-client/test.md). Đã chốt /editor, một bản hiện tại không review snapshots, withdraw trước Manager decision và một Client bất kỳ. Task structure đã triển khai riêng; Approval mới hoàn thành tài liệu giai đoạn 1.

> Checkpoint 2026-10-17 (historical): Task structure removal of QC/plannedPublishAt and Atlas metadata APPLY were implemented separately; earlier inventory/results below are dated history, not current-state evidence.

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

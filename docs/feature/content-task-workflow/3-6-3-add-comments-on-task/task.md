# Task — FR 3.6.3 / DA-1236

Theo [plan](plan.md).

Execution 2026-10-17 uses no QC and no new test files under src. Preserve editor/content/approval contracts and existing Task identity/status.

- [x] Chốt terminal comment, mentions/images, recipient Q11 và Q13 quyền Client trên mọi Task cùng WS.
- [x] Chuẩn bị spec/plan/task/test và contract private upload/outbox.
- [x] Migration foundation collections/indexes + fresh init/checker/tests.
- [x] Scoped comment ACL/mention-options với ClientProfile → User ID.
- [x] GET cursor createdAt/id và POST idempotent plain-text comment.
- [x] Upload MIME/decode/size; private download ACL; CAS bind đúng owner/task một lần.
- [x] Cleanup DRAFT lease/CAS, không xóa object đã ATTACHED.
- [x] Per-user Mongo outbox + reuse SQL inbox worker; recheck quyền khi delivery, không QC.
- [x] Timeline/composer/mentions keyboard/preview ảnh/giữ draft khi lỗi.
- [x] Locale vi/en song song; kiểm tra layout light/dark tại 375/768/1440 và lint phần mới.
- [x] 46 test Task hiện có; smoke Mongo replica set riêng 38 assertions; browser API-mock kiểm retry/mention/ảnh/layout.
- [x] Tài liệu setup, giới hạn đã xác minh/chưa xác minh; không thêm file test trong src.
- [x] Gợi ý @ khi gõ trong bình luận, tìm thành viên/caret/IME/keyboard, không email/không gửi nhầm.
- [x] Locale hướng dẫn @ vi/en, light/dark/mobile; 17 assertions helper local và browser API mock, không test trong src.
- [x] Dropdown nổi bám dấu @, collision/flip/scroll, initials và keyboard/IME.
- [x] Mention inline highlight, xóa/cắt/Undo đồng bộ User IDs; plain-text paste, không thay API/DB/editor khác.
- [x] Browser API-mock: rich input/retry/upload/giới hạn 10.000 ký tự; cắt/Undo; popup vị trí light/dark/375/768/1440, locale en. Không thêm test trong src. Dirty guard đầy đủ chờ thêm kiểm tra tích hợp.
- [ ] Kiểm thử ứng dụng thật qua Gateway: S3 private policy, upload/download, inbox PostgreSQL, nhiều tài khoản và locale en.
- [ ] Team review/Report 3-4/Jira: chưa tự đánh Done hoặc sửa module thành viên khác.

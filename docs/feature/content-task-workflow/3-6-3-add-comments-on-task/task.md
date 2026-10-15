# Task — FR 3.6.3 / DA-1236

Theo [plan](plan.md).

- [x] Chốt terminal comment, mentions/images, recipient Q11 và Q13 quyền Client trên mọi Task cùng WS.
- [x] Chuẩn bị spec/plan/task/test và contract private upload/outbox.
- [x] Migration foundation collections/indexes + fresh init/checker/tests.
- [ ] Scoped comment ACL/mention-options với ClientProfile → User ID.
- [ ] GET cursor createdAt/id và POST idempotent plain-text comment.
- [ ] Upload MIME/decode/size; private download ACL; CAS bind đúng owner/task một lần.
- [ ] Cleanup DRAFT lease/CAS, không xóa object đã ATTACHED.
- [ ] Per-user Mongo outbox + SQL inbox worker idempotent/recheck access.
- [ ] Timeline/composer/mentions keyboard/preview ảnh/giữ draft khi lỗi.
- [ ] Locale vi/en song song, light/dark/keyboard/mobile.
- [ ] Unit/API/Mongo transaction/S3 adapter/security/race regression theo test.md.

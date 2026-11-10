# Task — FR 3.6.2 / DA-978

Theo [plan](plan.md).

- [x] Chốt Creator/QC User IDs và Q8 trigger bấm Bắt đầu làm.
- [x] Chuẩn bị spec/plan/task/test và contract không phá Approval/editor.
- [x] Foundation schema marker/assignment/outbox + init/checker tests.
- [x] Q13 thay Q12: bỏ phân biệt nội bộ/thường, mọi Task cùng WS cho Client xem/bình luận.
- [x] Checkbox requiresClientApproval độc lập nguồn Task; unit test true/false trên Task manual/Campaign/Request.
- [ ] Review E51-03 first-start marker, round và CAS writer contract.
- [x] API member-options kiểm tra active/CREATOR/scope và resolve identity.
- [x] Assign/reassign targeted CAS + lock + transaction/outbox.
- [x] Start endpoint lần đầu chỉ assignee; không tự start khi mở trang. Resubmit/reject module chưa thay đổi.
- [x] Worker notification inbox SQL idempotent/retry/recheck active Creator và scope Task; chưa test inbox trên PostgreSQL thật.
- [x] Form Assign và action Start theo allowedActions; conflict giữ draft, reload mới reset rõ ràng.
- [x] Locale vi/en song song; light/dark/keyboard/mobile.
- [ ] Unit/API/concurrency và regression Approval/editor/Campaign theo test.md.

- [x] Slice 2026-10-15: notification worker chỉ TASK_ASSIGNED, không auto-create schema, SQL inbox idempotent.

Các checkbox test toàn bộ nguồn true/false và phối hợp Approval vẫn mở; không dùng mock browser hay schema tests thay nghiệm thu Atlas. Xem [evidence/setup](../task-workflow-phase-2-3.md).

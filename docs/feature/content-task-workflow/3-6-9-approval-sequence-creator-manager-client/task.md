# Checklist — FR 3.6.9 / DA-E51-03

Theo [spec](spec.md) → [plan](plan.md). Ngày 2026-10-18. Tick phản ánh tài liệu/code đã làm, không đồng nghĩa Jira Done.

## Giai đoạn 1 — BA và contract

- [x] Đọc team guide, feature-workflow và template bốn tài liệu.
- [x] Đối chiếu code local Task/Workflow/Post/Editor/Yjs/notification/Admin và init Mongo.
- [x] Ghi BA Manager→Client tùy chọn, không QC, năm trạng thái, reject về IN_PROGRESS, không mở lại FINISHED.
- [x] Ghi quyết định /editor trước; một bản hiện tại, không kho snapshot; giữ content_version Admin hiện có.
- [x] Ghi quyền withdraw trước Manager decision; gửi lại lượt mới.
- [x] Ghi một Client active bất kỳ quyết định; thiếu Client chặn submit, không tự skip khi Client rời Workspace.
- [x] Chốt field comment dùng cho nhận xét duyệt, tách bình luận Task; không rename DB không cần thiết.
- [x] Viết spec v3 → plan kỹ thuật → checklist → test cases trước code.
- [x] Đồng bộ BA Task, UC-43/47, state machine, glossary, master plan; đánh dấu kế hoạch cũ là lịch sử.
- [x] Ghi API/DTO/CAS, metadata lượt gần nhất, link POST, outbox và giới hạn không snapshot.
- [x] Ghi checkpoint bảo vệ module khác: Editor/Admin/publisher/Yjs; rollout không tự publish.
- [x] Hoàn tất kiểm tra diff/whitespace, 49 local links hợp lệ, 17/17 AC được map vào 34 test cases; chỉ 15 file Markdown Infrastructure thay đổi, code/DB giữ nguyên.

## Giai đoạn 2 — Database (code/schema chuẩn bị xong, Atlas rollout pending)

- [x] Kiểm nhánh/baseline local; inventory Atlas read-only thực tế, không dùng số liệu cũ; chưa tự merge develop vào worktree dirty.
- [x] Kiểm Task review legacy/metadata thiếu, Post link trùng, decision trùng; phát hiện hai active review chưa xác minh, không sửa.
- [x] Tạo migration forward-only metadata lượt/link/unique decisions/review outbox, default DRY_RUN và xác nhận pause writers khi APPLY.
- [x] Đồng bộ init-mongo.js/checker, không thay SQL/Yjs; giữ Post warn policy và field legacy/QC history.
- [x] Sửa đường dẫn archived của checker tests; 48 offline tests Pass, 79 assertions Mongo replica set riêng Pass, fresh/upgrade/rerun/legacy/transaction rollback.
- [x] Viết setup/inventory/results, ghi rõ schema ready không phải API ready; không thêm test trong src.
- [x] Operator duyệt và freeze writers; Atlas APPLY ngày 18/10 sau reset đúng 5 Task theo quyết định riêng. Checker Approval/Task structure=true; DDL không đổi document. Không init/seed; gate vẫn false, E2E/rollout chưa hoàn tất.

## Giai đoạn 3 — Backend (code và kiểm thử cô lập đã xong; chưa rollout)

- [x] Rollout gate default false cho POST integration; đọc/lịch sử vẫn hoạt động, không mở mutation trên bản demo khi stage 4 chưa xong.
- [x] Tạo review read/history DTO/controller, tái dùng ACL active member/User/scope và chặn loại Task chưa hỗ trợ.
- [x] Tạo policy submit/approve/reject/withdraw riêng, không bỏ khóa brief/giao lại sau start.
- [x] Store CAS cho Task đã bắt đầu, round/step/revision/updatedAt, unique quyết định.
- [x] Tạo lastSubmission metadata, lượt đầu 1, gửi lại +1, không tăng do retry/lỗi.
- [x] Viết submit/withdraw/decision trong Mongo transaction; expected Post content_version theo contract.
- [x] Phối hợp CampaignClosureStore để cancel xóa bước chờ/đóng metadata; giữ audit; kiểm race Mongo cancel↔decision.
- [x] Mở rộng outbox/worker cho Manager/Client/Creator theo event; dedup/ACL/lượt/step suppression; chưa kiểm end-to-end SQL inbox mới.
- [x] Review route Gateway business-protected /api/v1/** đã bao phủ endpoint mới; không đổi code/global authentication. Chưa smoke HTTP qua Gateway đang chạy.
- [x] Compile, 91 tests hồi quy và 187 kiểm tra smoke Pass; harness/classes dưới target (ignored), không thêm test trong src.
- [ ] Kiểm môi trường thật SQL ACL/Campaign lock + inbox và tích hợp POST ở giai đoạn 4–6 trước bật cờ; không coi các mock là end-to-end.

## Giai đoạn 4 — POST integration (core đã kiểm thử; rollout/publisher pending)

- [x] Ghi chốt Admin DRAFT vẫn cho thu hồi/từ chối đúng quyền; không tự Task reject/approve.
- [x] Chọn API Task riêng cho linked save/submit; giữ DTO và đường Post độc lập, bổ sung durable Admin handoff ngoài Mongo retry callback.

- [x] Tạo tìm/tạo bài theo Task, unique task_id và validation Workspace/type/assignee; không auto-link cũ. GET chưa tạo trả post=null, không tự ghi.
- [x] Linked Post updates dùng expectedRevision/expectedPostContentVersion và touch Task trong cùng Mongo transaction; giữ nguyên field ngoài Editor.
- [x] Chặn bypass PATCH/submit Post cũ bằng TASK_POST_WORKFLOW_REQUIRED; DTO và flow bài độc lập giữ nguyên, test hiện có Pass.
- [x] Editor mở đúng bài, không prefill brief/mock thành kết quả; không fallback tạo bài mới khi save thất bại.
- [x] Lưu xong mới submit, giữ link và nội dung, hỗ trợ reopen đúng bài sau reject/withdraw; read-only chặn Tiptap/AI/media khi không được sửa.
- [x] Durable TASK_POST_SUBMITTED handoff + worker riêng, dùng hook Admin idempotent hiện có ngoài Mongo callback; kiểm retry/stale version bằng Mongo + mock Admin. Admin SQL thực tế chưa kiểm.
- [ ] Bàn giao publisher boundary; không sửa publish queue/callback hoặc Yjs/content history.
- [ ] Kiểm mọi writer liên quan trước bật feature, không công bố E2E chỉ dựa vào UI disabled.
- [x] Đồng bộ optional postId/postContentVersion + TASK_POST_SUBMITTED trong foundation chưa merge + init/checker; 48 offline tests và 84 Mongo assertions Pass, không APPLY Atlas.
- [x] Cập nhật locale Editor vi/en; browser fixture kiểm blank→save/error→recovery→submit→read-only và 375/768/1440px light/dark, sửa toolbar Task bị cắt tại tablet mà không sửa PageWrapper dùng chung.
- [x] 94 hồi quy, tổng 231 kiểm tra smoke backend; ESLint file thay đổi và Vite bundle Pass. Không thêm test dưới src; type-check toàn Web chưa Pass vì baseline ngoài scope.
- [x] Ghi quyết định ngày 2026-10-18: giữ nguyên publish, chờ thành viên phụ trách; không thêm guard tại Business publish API. Writer này vẫn replace toàn Post; giữ cờ tắt đến khi phối hợp và kiểm chứng an toàn.

## Giai đoạn 5 — UI/notification (UI đã kiểm thử cô lập; inbox thật chờ giai đoạn 6)

- [x] Bổ sung section duyệt trong popup hiện có, nội dung hiện tại, current step/round và allowedActions.
- [x] Nút submit/withdraw/approve/reject theo quyền API, Dialog lý do, loading/error/recovery; không tự suy quyền từ role header hoặc khóa brief.
- [x] Lịch sử cursor nhóm lượt, giữ QC legacy chỉ ở lịch sử; label rõ không lưu phiên bản nội dung cũ; tách task_comments.
- [x] Refresh review/history/workflow và list background sau commit; không mất draft bình luận/lý do. Campaign dùng state local và tải khi vào trang theo module hiện có, không tạo cache key giả hoặc sửa Campaign.
- [x] Cập nhật vi/tasks.json + en/tasks.json song song (81 keys review); Editor locale giai đoạn 4 giữ nguyên trong giai đoạn 5.
- [x] Kiểm light/dark, keyboard/focus/Escape/discard, aria alert/labels và 375/768/1440px; không tuyên bố audit screen-reader/contrast toàn ứng dụng.
- [x] Kiểm khớp Post version/revision trước action và khi reload; giữ lý do sau conflict, không tự gửi lại; ảnh/link chỉ dùng URL web hợp lệ.
- [x] ESLint, Vite bundle, 71 guard/locale checks và 30 kiểm tra browser trên fixtures Pass; test artifacts ignored ngoài src. Type-check chỉ còn lỗi baseline ngoài scope.
- [ ] Kiểm in-app inbox thật/Gateway/SQL và rollout cùng giai đoạn 6; giữ feature gate false, không APPLY Atlas.

## Giai đoạn 6 — Verification/bàn giao (chưa triển khai)

- [ ] Chạy test.md trên DB cô lập; cập nhật từng kết quả thực tế, không thêm/commit test trong src.
- [ ] Flow thật Creator→Manager→Client, reject/resubmit/withdraw; không post lên social thật trong test.
- [ ] Kiểm nhiều Client, tab cũ, save↔submit, withdraw↔decision, cancel↔decision, rollback/storage lỗi.
- [ ] Hồi quy Task 3.6.1/2/3, Campaign deployment/closure, Request, Post độc lập, Admin, notification cũ.
- [ ] Hướng dẫn setup/migration/operator/known limitations; kiểm Git không có log/ảnh/test artifact.
- [ ] Team review, draft Report 3/4 đối chiếu implementation; cập nhật tài liệu report chính thức có kiểm soát.
- [ ] Xác minh mã Jira số/phân công với team trước commit; In Review/Done và push chỉ theo yêu cầu.

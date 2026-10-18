# Task Approval — Atlas preflight 2026-10-18

## Quyết định thay thế: reset đúng 5 Task (2026-10-18)

Người dùng đã chọn đưa đúng năm Task trong bảng dưới về TODO, chấp nhận đặt lại lịch sử bắt đầu/lượt duyệt. Không triển khai ngoại lệ allowlist của phương án A.

Kế hoạch thực thi: preflight đúng ID/Workspace/type/status/revision, không có liên kết Post/comment/decision/outbox; lưu bản gốc local; transaction cập nhật cả năm hoặc hủy toàn bộ. Đặt status=TODO, reviewStep/lastSubmission/firstStartedAt/firstStartedBy=null, approvalRound=1; tăng workflowRevision hiện có (thiếu thì khởi tạo 0), cập nhật updatedAt. Giữ nguyên mọi field còn lại, kể cả nội dung, deadline và người phụ trách. So sánh từng field trong transaction, fingerprint các Task ngoài phạm vi và bốn collection liên quan trước/sau. Không tạo lịch sử duyệt giả, không sửa SQL/Yjs.

Sau reset: chạy preflight migration gốc, chỉ APPLY metadata khi sạch; kiểm tra lại validator/index và fingerprint document. Giữ rollout tắt, không thay publish. Kết quả thực thi được bổ sung sau khi xác minh.

### Kết quả thực thi đã xác minh

- Đã reset đúng 5 Task bằng transaction majority; từng field được đối chiếu với bản gốc, chỉ các field liệt kê ở kế hoạch thay đổi. Revision lần lượt theo bảng ID: 0 / 1 / 2 / 2 / 2. Không xóa document hoặc tạo lịch sử giả.
- Fingerprint 23 Task ngoài phạm vi, toàn bộ posts/task_comments/task_approvals/task_notification_outbox không thay đổi khi reset.
- Bản gốc và kết quả local: `.local-backups/task-approval-20261018/reset-five-2026-10-18T12-50-53-893Z-{before,after}.json` (ngoài Git).
- Preflight sau reset: blocked=false, problems=[], unverifiedActiveReviews=0. Đã APPLY migration gốc trên Atlas; applied=true, appliedCollections=tasks/posts/task_approvals/task_notification_outbox.
- Fingerprint cả bốn collection không thay đổi trong bước APPLY metadata. Số lượng giữ nguyên: tasks=28, posts=44, task_approvals=0, task_notification_outbox=1.
- Checker đọc lại: taskApprovalFoundation=true, taskStructureSimplification=true; DRY_RUN sau APPLY sạch.
- Còn 4 Task khác thiếu revision/first-start và 35 Post không đạt toàn bộ validator cũ (posts vẫn warn). Đây là dữ liệu ngoài phạm vi, không được tự sửa hoặc coi mọi dữ liệu cũ đã sạch. Legacy QC assignments=5 giữ nguyên.
- Feature gate vẫn tắt. Không chạy mutation Approval thật trên Atlas hoặc tự khởi động writer; không kết luận đã E2E toàn bộ feature. PostgreSQL/Yjs/publish không thay đổi.

Các phần “chưa APPLY/chưa có quyết định” bên dưới ghi lại lịch sử trước quyết định reset này, không phải trạng thái hiện tại.

Người dùng yêu cầu APPLY migration `2026-10-18-task-approval-foundation.js`, xác nhận tất cả writer dùng chung Atlas đã dừng. Đã chạy **DRY_RUN thực tế** vào DB `brandhub` trên deployment cấu hình của dự án; không chạy init, seed hoặc sửa document.

## Kết quả

`blocked=true`, duy nhất `tasks / unverifiedActiveReviews`. **APPLY chưa thực hiện, liveWrites=0.** Không bỏ guard hoặc tự tạo lịch sử để ép migration chạy.

| Collection | Số document | Kết quả liên quan |
|---|---:|---|
| tasks | 28 | 5 active review chưa xác minh; 5 thiếu revision; 5 thiếu first-start field; 0 document sai validator đích |
| posts | 44 | 0 link sai/trùng; 35 document lệch validator cũ đang `warn`, chỉ báo thông tin, không sửa/siết |
| task_approvals | 0 | Không quyết định trùng/orphan |
| task_notification_outbox | 1 | Không document sai validator đích |

Số đếm này thay thế inventory cũ 16 Task/39 Post/2 active review; không được dùng thay preflight mới sau khi team ghi dữ liệu tiếp.

## 5 Task cần chủ dữ liệu quyết định

| Task ID | Workspace ID | Loại / trạng thái | Vấn đề quan sát |
|---|---|---|---|
| `59cd7cf6-0610-4844-af09-0baba1b28a2e` | `6a4bb422-3ef2-43d4-8019-93adb1dfa982` | POST / QC_REVIEW | Thiếu revision, first-start, reviewStep và lastSubmission; không tự suy QC thành Manager |
| `8e30b9e6-fe6a-444b-8dd4-3e09cac441ea` | `decfb14d-89f0-46e4-8225-ad6490218671` | EVENT_PLAN / IN_REVIEW | revision=0, firstStartedAt/By=null, thiếu reviewStep/lastSubmission; loại chưa nối nội dung Approval |
| `d3100000-0002-4000-8000-000000000002` | `d3100000-0000-4000-8000-000000000003` | POST / IN_REVIEW / MANAGER | Có first-start/revision nhưng thiếu lastSubmission |
| `d3100000-0001-4000-8000-000000000001` | `d3100000-0000-4000-8000-000000000002` | POST / IN_REVIEW / MANAGER | Có first-start/revision nhưng thiếu lastSubmission |
| `d3100000-0001-4000-8000-000000000002` | `d3100000-0000-4000-8000-000000000002` | POST / IN_REVIEW / CLIENT | Thiếu lastSubmission; collection không có decision chứng minh Manager đã duyệt |

Giữ nguyên cả năm Task. Không mặc định đây là dữ liệu có thể xóa dù ID có dạng fixture. Việc hủy/reset/xóa/backfill cần danh sách và quyết định riêng của người dùng/chủ module. Không dùng yêu cầu “clean file test” làm quyền xóa dữ liệu DB.

## Phạm vi schema sẽ thay đổi nếu preflight hợp lệ

- `tasks`: optional `lastSubmission` cho metadata lượt gần nhất, không snapshot.
- `posts`: optional `task_id`; partial unique `uq_posts_task` cho string.
- `task_approvals`: unique `uq_task_approvals_round_step`; index cursor `idx_task_approvals_timeline`.
- `task_notification_outbox`: optional approvalRound/reviewStep/decisionId/postId/postContentVersion và ba event types Approval/handoff.

Không thêm collection, không đổi PostgreSQL/Media Package/Campaign/Chat/Yjs/Admin post_versions/publish. Metadata đã đồng bộ init/checker từ giai đoạn trước; không chạy init lên Atlas.

Schema migration không tự bật API. Gate vẫn false theo quyết định giữ nguyên publish chờ thành viên phụ trách; không kiểm thử mutation thật bằng cách tự bật gate trên Atlas.

## Kiểm tra lại và dọn file local

- 48 tests migration offline Pass.
- Biên dịch Java 21 và chạy lại 231 kiểm tra backend/Post Approval Pass trên Mongo replica set `approval-api-test` riêng, cổng localhost 62871, tmpfs, không volume demo. SQL/ACL/Admin mock theo harness, không phải E2E trên Atlas.
- 71 guard/locale checks Pass; Playwright CLI chạy lại 25 flow + 5 lỗi tải/khôi phục Pass trên API fixtures. Rà lại 375/768/1440px, light/dark, vi/en, Escape/giữ note Pass. Vite riêng cổng 3012 và browser riêng đã đóng.
- Đã xóa 27 fixture/script/ảnh/snapshot Task Approval/Post trong `brandhub-web/output/playwright`, 9 log/snapshot CLI xác định do phiên kiểm thử này tạo, và 51 class tạm dưới `target/task-approval-smoke/com`. Tất cả file đều ignored/generated, không phải source hoặc test của thành viên khác; có thể tái tạo, không phải dữ liệu demo.
- Giữ nguyên tests migration trong Infrastructure và Java harness local còn dùng hồi quy (ngoài src, ignored). Không thêm test vào src, không xóa test đang tracked của team. Runner preflight local được giữ để tiếp tục vận hành sau khi người dùng quyết định; không chứa URI/password trong source.
- Container Mongo kiểm thử đã được xóa sau khi kiểm tên/nhãn và không có volume. PostgreSQL/Redis/RabbitMQ/ChromaDB/demo data không bị thay đổi.

Không gọi các kiểm tra cô lập này là kiểm thử sau APPLY hoặc nghiệm thu tính năng thật. Atlas vẫn chỉ READ_ONLY trong lượt này; APPLY đang chờ quyết định xử lý năm Task nêu trên. Không commit/push.

## Đề xuất từng Task — chờ người dùng duyệt

Đã đọc lại Atlas: số đếm/hash của bốn collection không đổi so với preflight trước, vẫn blocked với đúng năm Task. Cả năm không có Post gắn qua `task_id`, comment, approval decision hoặc outbox liên kết trong các collection đã kiểm. **Điều này không chứng minh Task chưa dùng:** dữ liệu Yjs/history ở PostgreSQL chưa được kiểm kê trong lượt này.

| Task | Đề xuất ưu tiên | Lý do / không được tự làm |
|---|---|---|
| `59cd7cf6-0610-4844-af09-0baba1b28a2e` — Chiến dịch Social Media hưởng ứng ngày chạy Marathon Quốc Tế | Giữ nguyên QC_REVIEW; ghi vào danh sách legacy chỉ đọc đối với API Approval mới | Không có bằng chứng bắt đầu hoặc bước QC đã hoàn tất. Không đổi QC thành Manager, không tạo lastSubmission giả hoặc xóa |
| `8e30b9e6-fe6a-444b-8dd4-3e09cac441ea` — Kế hoạch tổ chức sự kiện Workshop Sáng tạo Nội dung | Giữ nguyên IN_REVIEW; ngoại lệ legacy riêng, không mở duyệt mới cho EVENT_PLAN | Tên/trạng thái khớp mẫu TaskSampleSeeder, nhưng không có seed marker chứng minh nguồn tạo. EVENT_PLAN chưa có adapter nội dung; không tự reset TODO chỉ vì first-start null |
| `d3100000-0002-4000-8000-000000000002` — Bài viết Storytelling: Hành trình khởi nghiệp xanh | Giữ nguyên IN_REVIEW/MANAGER và first-start; legacy chỉ đọc đối với API mới | Workspace nằm trong khai báo dev-quick-login.sql, có thể phục vụ demo của người khác. Thiếu bài liên kết và lượt gửi; không bịa nội dung/lịch sử để mở duyệt |
| `d3100000-0001-4000-8000-000000000001` — Bài viết ra mắt BST Thời Trang Thu Đông 2026 | Giữ nguyên IN_REVIEW/MANAGER và first-start; legacy chỉ đọc đối với API mới | Cùng lý do bộ quick-login; chưa đủ dữ liệu chứng minh một lượt gửi hợp lệ. Không xóa/reset ảnh hưởng màn hình demo |
| `d3100000-0001-4000-8000-000000000002` — Kịch bản Video TikTok Hậu Trường Chiến Dịch | Giữ nguyên IN_REVIEW/CLIENT; không mở API mới cho bản ghi này | Không có decision Manager để chứng minh đã chuyển bước hợp lệ. Không tự thêm APPROVE thay Manager hoặc chuyển sang FINISHED |

### Phương án A — đề xuất ưu tiên để bảo toàn dữ liệu team

**Không update/delete/backfill bất kỳ Task hoặc nội dung nào.** Nếu người dùng duyệt, bổ sung cơ chế ngoại lệ preflight có kiểm soát cho **đúng năm ID** trên, chỉ để APPLY metadata/index. Hiện cơ chế này **chưa có code**, migration vẫn chặn; không được bật APPLY trực tiếp hoặc bỏ toàn bộ guard.

Điều kiện kỹ thuật cần thực hiện sau khi duyệt:

1. Ngoại lệ phải là allowlist tường minh, kiểm đúng ID/Workspace/trạng thái/bằng chứng hiện tại; không dùng điều kiện chung kiểu “bỏ qua mọi Task cũ”. Task mới/Task đổi dữ liệu hoặc lỗi validator/link/unique khác vẫn chặn trước DDL.
2. Report vẫn hiển thị số Task chưa xác minh và danh sách được miễn chặn; không đổi thành “đã xác minh”, không đặt lastSubmission giả.
3. API Approval mới giữ policy fail-closed cho các Task thiếu lịch sử/không hỗ trợ loại. Đây không phải cam kết khóa module cũ của thành viên khác; các luồng cũ không bị tự sửa trong đợt này.
4. Đối chiếu fingerprint document trước/sau, giữ field/validator/index ngoài scope, không thay PostgreSQL/Yjs/publish. Cập nhật migration/init-checker liên quan và test lại cơ chế ngoại lệ trước APPLY. Không bật feature gate.
5. Cần xác nhận lại writer freeze và DRY_RUN mới ngay trước APPLY. Backup metadata và kiểm schema/document sau đó; không áp dụng khi report có lỗi khác.

### Phương án B — nếu cần chính năm Task tham gia workflow mới

Chủ dữ liệu xác minh nguồn nội dung, lịch sử bắt đầu/gửi/duyệt thật và dữ liệu Yjs/PostgreSQL trước, rồi duyệt kế hoạch chuyển đổi từng bản ghi. Nếu chỉ cần test, tạo Task mới bằng flow hiện hành và để năm Task cũ nguyên trạng là lựa chọn ít rủi ro hơn reset/xóa. Không suy “không có liên kết Mongo” thành “không có dữ liệu liên quan”.

**Chưa có quyết định thực thi phương án A/B. Atlas vẫn không có document/DDL writes trong lượt lập đề xuất này.**

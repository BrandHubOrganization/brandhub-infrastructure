# Task Detail / Identify / Assign — bàn giao 2026-10-15

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

DA-978 / FR 3.6.1, 3.6.2. Code Business/Web trên merge/review2; Infrastructure trên docs/media-workflow-phase-1. Khôi phục có chọn lọc stash task-workflow-phase-1-Q13-backup-20261014; vẫn giữ nguyên stash và phần nối list Task thật. Không commit/push, không chạy app/seed hoặc migration lên Atlas/PostgreSQL dùng chung.

## Đã code

UI update 2026-10-15 sau bàn giao: Task Detail chuyển thành panel bên phải trong danh sách, desktop >=1280px không modal; mobile/tablet dùng Sheet. URL `/workspaces/:id/tasks?task=...`; route detail cũ redirect và link Campaign/Request đã cập nhật. Provider riêng trong TaskWorkflowContent, list refresh nền sau mutation; không đổi API/DB/editor. Regression mới 132 tests/14 files + build pass, browser mock desktop/mobile/Creator start/Client readonly/409/Back-Forward pass; xem [test UI](3-6-1-identify-task-detail/test.md). Không có migration bổ sung.

- GET `/api/v1/workspaces/{workspaceId}/tasks/{taskId}/workflow`: mọi thành viên active, bao gồm Client và Task manual/legacy. Không cấp quyền editor/content.
- GET `.../{taskId}/member-options`: Manager thực tế trong WS; trả User ID của Creator active, không phải membership ID.
- PATCH `.../{taskId}/detail`: description, dueDate, plannedPublishAt (POST, optional), inputReferences, expectedRevision. BACKLOG → DETAIL_IDENTIFIED lần đầu; sửa trước start giữ status/assignee.
- POST `.../{taskId}/assign`: assigneeId, qcAssigneeId nullable, requiresClientApproval, expectedRevision. DETAIL_IDENTIFIED → ASSIGNED; giao lại trước start giữ ASSIGNED. Creator/QC active cùng WS, khác nhau.
- POST `.../{taskId}/start`: expectedRevision; chỉ Creator được giao bấm rõ ràng. ASSIGNED → IN_PROGRESS, first-start marker; mở trang/editor không start.
- CAS workspace/task/revision/status/updatedAt/explicit start marker; targeted updates không đè typeMetadata, source, approvalRound hoặc cancellation. Campaign mutation dùng cùng agreement lock với completion, Task + assignment outbox trong Mongo transaction.
- Notification TASK_ASSIGNED có lease token/retry, stable UUID, SQL inbox INSERT ON CONFLICT, kiểm lại Creator active/Task scope. Không gửi email; không tạo collection tự động. Inbox UI hiện có đọc `/api/v1/notifications/me` không cần đổi global UI.
- Page `/workspaces/:id/tasks/:taskId/detail`: từ list summary, Campaign và Request; xem chung, form/quyền do backend trả. Giữ editor links cũ. Input min/max theo Workspace timezone; DST gap/fold bị từ chối. Conflict giữ draft; tải bản mới nhất là thao tác reset rõ ràng. vi/en, semantic light/dark, header gọn chỉ riêng trang mới.

## Schema / dữ liệu cũ

Migration: [2026-10-14-task-detail-comments-foundation.js](../../database/migrations/2026-10-14-task-detail-comments-foundation.js).
Đã khôi phục sync init-mongo/checker từ giai đoạn 1; không thay init PostgreSQL và không cần SQL migration mới cho đợt này. Comments/upload collections trong foundation chỉ là nền schema, chưa có feature FR 3.6.3.

Writer tạo Task mới (Campaign, Request acceptance, editor) khởi tạo revision=0 và explicit firstStartedAt/By=null. Không default revision khi đọc legacy. Task cũ thiếu marker/revision vẫn được xem nhưng khóa quản lý; migration không tự backfill. Không suy BACKLOG hay ASSIGNED là chứng minh chưa từng bắt đầu.

## Setup trước khi test trên môi trường của nhóm

1. Backup và kiểm tra đúng connection/database `brandhub`. Chạy checker/inventory chỉ đọc; xem [hướng dẫn Atlas](../../database/mongo-atlas-migrations.md) và [phase 1](task-workflow-phase-1.md).
2. Review dependencies Task V2/deployment/Request acceptance/Campaign closure. Chạy toàn bộ foundation trong Playground với `globalThis.TASK_WORKFLOW_FOUNDATION_APPLY = false` (mặc định). Nếu bị blocked/exception thì dừng review; không drop collection/index hoặc chạy lại init để chữa.
3. Chỉ sau khi operator đã kiểm tra/duyệt preflight: đặt flag true và chạy toàn script, rồi trả flag false. Agent chưa thực hiện bước này trên Atlas. Chạy checker lại; foundation phải MATCH.
4. Build sạch Business bằng Java 21: `mvn.cmd clean compile`, rồi khởi động Business theo cách hiện tại. Tải lại Web. Một lần chạy incremental đã gặp class báo Flexible Constructor Bodies; clean Maven rebuild đã pass toàn bộ. Không đổi source level lên Java 25 để xử lý class build cũ.
5. Dùng tài khoản hiện có: Manager và hai Creator active trong WS, Client. Không tạo account/seed mới. Task mới sau restart từ Campaign deployment hoặc Request acceptance có metadata mới; Task cũ cần inventory và đề xuất chuẩn hóa riêng được duyệt trước, không dùng migration để mở khóa ngầm.
6. Manager: xem Task → lưu brief/hạn và tài liệu tham khảo → giao Creator/QC, chọn cờ Client duyệt → kiểm thông báo inbox Creator. Creator mở trang chưa đổi trạng thái; bấm Bắt đầu làm mới chuyển IN_PROGRESS. Manager tải lại thì không còn form sửa/giao lại. Client chỉ xem.
7. Thử stale revision, QC trùng người làm, người ngoài WS, deadline ngoài Campaign, Task CANCELLED/COMPLETED và Campaign completed. Dữ liệu nhập lỗi/conflict phải được giữ.

Notification worker mặc định poll 5000ms, lease 60s, retry 30s; `APP_TASK_NOTIFICATIONS_ENABLED=false` để tắt khi kiểm tra chỉ đọc. Không có outbox collection thì worker bỏ qua, không tự init. Mongo phải hỗ trợ sessions/transactions (Atlas replica set có); SQL `user_notifications` là inbox hiện có.

## Bằng chứng kiểm tra và giới hạn

- Web: **128 tests / 13 Vitest files**, production build và scoped lint Task Detail/Assign pass. Cảnh báo bundle mockContentLibrary static/dynamic import có sẵn, ngoài scope. Hook list cũ còn hai lint advisory đã ghi ở đợt list.
- Business clean Maven: **170 focused tests / 18 suites**, 0 failures/errors/skips. Bao gồm 165 unit/MockMvc/regression (workflow quyền/status/validation; cờ Client duyệt true/false cho cả ba nguồn; editor 22; Request/Campaign/closure; security) và **5 integration Mongo thật**.
- Mongo integration chạy trên container tạm riêng, loopback 27029, replica set taskWorkflowTest, guard URI/flag/setName. Fresh init chỉ trong container trống này, không phải Atlas. Pass BSON explicit-null presence, schema, Task+outbox commit/rollback, unique event, stale CAS/cancellation, lease reclaim/token guard. Không dùng hoặc xóa dữ liệu nhóm.
- Infrastructure: **34 offline tests pass**, init/cumulative migrations parity, DRY_RUN/APPLY/repeat, giữ schema/index cũ, legacy không backfill và không có visibility.
- Browser CLI actual page + mocked transport: Manager detail/assign/QC/Client flag, 409 giữ draft rồi reload, min/max/date UTC conversion, readonly Client, explicit Creator start, legacy/schema gates, cross-Workspace response rejection, vi/en, screenshots 375/768/1440 light và 375 dark. Lỗi 503/409 là fixture; Vite HMR local-network console warnings không phải chat WebSocket.
- Chưa test end-to-end với tài khoản thật/Atlas hoặc SQL inbox delivery trên PostgreSQL thật; SQL retry/commit-order hiện kiểm qua unit test. Không chứng minh cross-store membership removal atomicity hay full service coverage.
- Chưa triển khai comments/ảnh/mention (DA-1236), chưa đổi resubmit/reject của E51-03; hợp đồng marker/CAS/duyệt lại vẫn cần chủ Approval review. Không đánh dấu FR/Jira Done chỉ vì build/schema/tests pass.

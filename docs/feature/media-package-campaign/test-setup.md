# Setup trước khi test Media Package / Campaign / Content Request

Ngày cập nhật: 2026-10-14. Code giai đoạn 2–5 và Campaign closure; không init lại PostgreSQL/Mongo đang có dữ liệu.
Các migration mới được kiểm thử trên DB cô lập. PostgreSQL local đã áp dụng các migration dưới đây trong phiên làm việc; máy khác cần kiểm tra riêng. Không suy ra Atlas đã cập nhật từ trạng thái PostgreSQL.
Không seed account mới; dùng account test trên trang đăng nhập và Workspace có quyền đúng.

## 1. Chuẩn bị

- Pull đúng code feature của business/web/infrastructure; Gateway giữ route `/api/v1/**` hiện có.
- Bật Docker Desktop. Các container hiện có: `brandhub-postgres`, `brandhub-redis`,
  `brandhub-rabbitmq`. Có thể khởi động lại riêng chúng (không tạo/init Mongo local):

```powershell
docker start brandhub-postgres brandhub-redis brandhub-rabbitmq
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

- Dừng Business Service và các writer/seeders khi migrate. Backup PostgreSQL bằng
  pgAdmin/pg_dump; backup Atlas theo quyền của team. Không commit backup/credential.
- Kiểm tra config đang chạy đúng: `POSTGRES_URL` tới local port 5432, database
  `brandhub`, `POSTGRES_USERNAME` đúng user; `MONGODB_URI` tới Atlas, database `brandhub`.
  Dùng env/launcher hiện có; không dán URI/password/token lên chat hoặc Jira.
- Backend cần Java 21 + Maven; frontend theo lockfile/CI của repo, `npm ci` nếu chưa cài dependencies.
- Không dùng `scripts/start-no-mobile.ps1` để setup đợt này: script cũ có service Mongo
  local; không cần nó vì dự án đang sử dụng Atlas.

## 2. PostgreSQL — kiểm tra ba migration mới, theo thứ tự

Inventory ban đầu: Campaign draft/review/deployment columns đã có;
partner lifecycle và bảng negotiation history chưa có (đã được migrate sau đó trên local). Nếu dùng DB máy khác,
đối chiếu migration cũ của Package/Campaign trước, không chạy toàn bộ SQL theo glob.

Tại `D:\FPT\FA26\SEP490\brandhub-infrastructure`:

```powershell
docker cp .\docs\database\migrations\2026-10-13-partner-directory-lifecycle.sql brandhub-postgres:/tmp/partner-directory-lifecycle.sql
docker exec brandhub-postgres psql -U brandhub -d brandhub -v ON_ERROR_STOP=1 -f /tmp/partner-directory-lifecycle.sql
```

Chỉ tiếp tục nếu migration trên thành công:

```powershell
docker cp .\docs\database\migrations\2026-10-13-package-negotiation-history.sql brandhub-postgres:/tmp/package-negotiation-history.sql
docker exec brandhub-postgres psql -U brandhub -d brandhub -v ON_ERROR_STOP=1 -f /tmp/package-negotiation-history.sql
```

Tiếp theo cần durable queue cho việc tự hủy Request PENDING khi hoàn thành Campaign:

```powershell
docker cp .\docs\database\migrations\2026-10-14-content-request-completion.sql brandhub-postgres:/tmp/content-request-completion.sql
docker exec brandhub-postgres psql -U brandhub -d brandhub -v ON_ERROR_STOP=1 -f /tmp/content-request-completion.sql
```

Các lệnh trên giả định DB/user local hiện có `brandhub`; nếu khác, đổi đúng tham số,
không tạo một DB mới để che lỗi cấu hình. Không chạy full `init-postgres-v2.sql`.

Kiểm tra trong SQL editor pgAdmin/psql:

```sql
SELECT column_name FROM information_schema.columns
WHERE table_schema='public' AND table_name='third_party_collaborators'
  AND column_name IN ('is_active','first_used_at','usage_history_verified','version');
SELECT to_regclass('public.package_negotiation_events');
SELECT to_regclass('public.content_request_completion_jobs');
SELECT action, COUNT(*) FROM package_negotiation_events GROUP BY action;
SELECT trigger_name FROM information_schema.triggers
WHERE event_object_table IN ('third_party_collaborators','campaign_collaborators','package_negotiation_events');
```

Mong đợi: đủ 4 cột, bảng history tồn tại, có trigger lifecycle/immutable. Legacy
non-DRAFT chỉ có BASELINE tại phiên bản hiện có; actor không xác định, thời gian
là lúc ghi nhận migration. DRAFT chưa có event là bình thường. Không mất dữ liệu
partner/link/selection; không tự mở khóa xóa legacy partner.

## 3. Mongo Atlas — không chạy init

Dùng kết nối mongosh trong VS Code/terminal bằng tài khoản DB có quyền `collMod`
và tạo index. Chọn/kiểm tra `brandhub`; pause writer suốt cutover. Trước hết:

```javascript
use brandhub
db.getName()
load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-09-campaign-task-preflight.js')
```

Campaign cần generic tasks/task approvals/type validators và unique index
`uq_tasks_campaign_work_item`. Nếu thiếu, review rồi chạy đúng ba migration nền
theo [hướng dẫn Atlas](../../database/mongo-atlas-migrations.md):

1. `2026-09-26-create-generic-tasks-collection.js`
2. `2026-09-27-create-task-approvals-collection.js`
3. `2026-10-09-campaign-task-deployment.js`

Không chạy lại các script nền nếu schema đang đúng, tránh ghi đè validator mới hơn.
Nếu preflight báo duplicates: dừng và báo team, không xóa Task để vượt unique index.

Content Request V2 (giai đoạn 2) — dry-run:

```javascript
globalThis.CONTENT_REQUEST_MIGRATION_APPLY = false;
load(
  "D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-13-content-requests-v2.js",
);
```

Chỉ sau backup/review và kết quả clean, apply:

```javascript
globalThis.CONTENT_REQUEST_MIGRATION_APPLY = true;
try {
  load(
    "D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-13-content-requests-v2.js",
  );
} finally {
  globalThis.CONTENT_REQUEST_MIGRATION_APPLY = false;
}
```

Tiếp theo acceptance (giai đoạn 3):

```javascript
globalThis.CONTENT_REQUEST_ACCEPTANCE_APPLY = false;
load(
  "D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-13-content-request-acceptance.js",
);
```

Chỉ nếu clean và đã review:

```javascript
globalThis.CONTENT_REQUEST_ACCEPTANCE_APPLY = true;
try {
  load(
    "D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-13-content-request-acceptance.js",
  );
} finally {
  globalThis.CONTENT_REQUEST_ACCEPTANCE_APPLY = false;
}
db.tasks
  .getIndexes()
  .filter((i) =>
    ["uq_tasks_campaign_work_item", "uq_tasks_content_request_source"].includes(
      i.name,
    ),
  );
db.content_requests.getIndexes();
db.getCollectionInfos({ name: "content_requests" })[0].options;
```

Mong đợi: 2 unique partial indexes trên Task, 3 `idx_content_requests_v2_*`, strict/error
validator có 5 status PENDING/IN_PROGRESS/ACCEPTED/DENIED/CANCELLED và optional
decision metadata. **Không chạy lại phase-2 sau phase-3** vì validator sẽ lùi phiên bản.
Nếu đã apply cả hai, chỉ kiểm tra readiness; không lặp lại toàn bộ danh sách.

Cuối cùng, trước khi dùng chức năng hủy đầu việc, chạy migration Campaign closure sau acceptance:

```javascript
globalThis.CAMPAIGN_CLOSURE_APPLY = false;
load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-14-campaign-closure.js');
```

Review dry-run và backup trước khi đổi flag thành `true` rồi chạy lại toàn script. Validator Task phải có `CANCELLED` và `cancellation`; không ghi đè bằng migration cũ hơn. Script không tự gắn lại Task Request cũ có campaignId=null. Kiểm tra toàn bộ metadata bằng `check-mongo-migrations.mongodb.js` (read-only).

## 4. Restart và đồng bộ UI/API

Sau migration mới restart Business Service bằng launcher đang dùng (giữ env/JWT,
PostgreSQL/Redis/RabbitMQ/Atlas config). Nếu chạy thủ công trong terminal đã load env:

```powershell
Set-Location D:\FPT\FA26\SEP490\brandhub-business-service
mvn.cmd spring-boot:run
```

Terminal khác chạy Gateway cùng bộ JWT public key/env của hệ thống:

```powershell
Set-Location D:\FPT\FA26\SEP490\brandhub-api-gateway
mvn.cmd spring-boot:run
```

Terminal UI:

```powershell
Set-Location D:\FPT\FA26\SEP490\brandhub-web
npm run dev
```

`VITE_API_BASE_URL` phải trỏ Gateway `http://localhost:8080` (default hiện có).
Không chạy 2 Business Service/Gateway trùng cổng. Đợi log `Started ...` và không có
Hibernate missing-table/column. Đăng xuất/đăng nhập lại bằng account test thật để
tránh token cũ; Owner/Manager và Client dùng hai browser profile/Incognito tách session.

**Contract mới bắt buộc:** PATCH negotiate gửi `expectedTermsVersion` + các terms
được chỉnh và optional `note`; POST approve gửi `{expectedTermsVersion: <version đang xem>}`.
Client cũ body rỗng nhận 400. Stale version nhận 409 MEDIA_PACKAGE_VERSION_CONFLICT;
giữ nội dung cần thiết, đóng modal và tải lại gói. Không tự retry duyệt phiên bản mới.

## 5. Thứ tự test thủ công

1. Owner: Agency → Danh bạ đối tác. Tạo mới/sửa; partner mới chưa dùng được xóa.
   Legacy khóa xóa; vẫn ngừng sử dụng được. Không dùng partner của Agency khác.
2. Dùng Workspace test thuộc Agency có Client/Manager đúng membership. Client chọn
   một gói khả dụng. Chưa chốt thì chỉ Package/Chat; Manager còn Workspace settings.
3. Client đề xuất có note → version/count tăng, Manager thấy history; Manager counter
   → version tăng nhưng Client count không tăng. Một bên duyệt rồi đổi terms → cả
   hai approval reset. Mở hai tab: tab cũ duyệt/đề xuất phải 409, không silent overwrite.
4. Cả hai duyệt cùng version → Package APPROVED; history chỉ để đọc/đối chiếu. Gói
   legacy có một baseline, không mong đợi tự phục hồi các vòng cũ.
5. Manager tạo Campaign nháp, tách mốc/đầu việc; Client góp ý, Manager sửa; hai bên
   duyệt cùng version rồi Manager triển khai. Deployment phải SUCCEEDED; Task BACKLOG
   theo work item, retry không nhân đôi/ghi đè Task đã làm. Một WS chỉ một Campaign.
6. Gán partner khả dụng vào Campaign, đổi cooperation status. Deactivate ở Agency:
   không chọn gán mới được, nhưng link cũ vẫn xem/cập nhật được.
7. Client tạo Content Request chỉ khi Campaign IN_PROGRESS + deploy SUCCEEDED.
   PENDING sửa/hủy được; Manager Receive → IN_PROGRESS khóa Client sửa/hủy.
   Accept → đúng một Task BACKLOG, campaignId=Campaign hiện tại, campaignWorkItemId=null, requiresClientApproval=false;
   POST có editor handoff cho Manager. Deny terminal; Cancel là CANCELLED, không delete.
8. Complete Campaign hiển thị đầu việc/yêu cầu đang xem xét còn tồn đọng và bị chặn nếu chưa xử lý hết.
   Tùy chọn hủy đầu việc mặc định thu gọn; mở mới chọn Task và lý do chung, xác nhận hủy riêng rồi mới complete.
   Task phải COMPLETED/CANCELLED; IN_PROGRESS Request phải được Manager chấp nhận/từ chối trước.
   Sau complete chặn tạo/sửa/tiếp nhận mới; PENDING tự chuyển CANCELLED qua durable queue, không hard delete.
   Task Request bổ sung hiển thị riêng, không đổi kế hoạch/sản lượng đã duyệt.
9. Deadline chỉ chọn từ max(ngày hiện tại, ngày bắt đầu) đến hết ngày kết thúc theo múi giờ Workspace.
   UI hiển thị giờ thiết bị và giới hạn picker; API vẫn kiểm tra. Không còn khoảng ngày hoặc lỗi cấu hình thì không lưu được.

## 6. Lỗi thường gặp

| Lỗi                         | Kiểm tra                                                                                     |
| --------------------------- | -------------------------------------------------------------------------------------------- |
| Hibernate thiếu cột/table   | SQL migration chưa chạy, sai DB hoặc service dùng config khác                                |
| 400 approve/negotiate       | UI/client cũ chưa gửi expectedTermsVersion; hard refresh/rebuild đúng branch                 |
| 409 version conflict        | Dữ liệu mới hơn màn hình; giữ input, đóng modal/tải lại, không bypass guard                  |
| REQUEST_SCHEMA_NOT_READY    | Thiếu migration/index readiness Request V2                                                   |
| TASK_SCHEMA_NOT_READY       | Thiếu validator/index Task tương ứng Campaign/Request                                        |
| 503 transaction unavailable | Kiểm tra Atlas replica set/sessions/quyền/network, không fallback standalone Mongo           |
| 403                         | Kiểm tra role/membership của đúng WS/Agency trong URL, không chỉ role hiển thị toàn hệ thống |
| 401                         | Đăng nhập lại, kiểm tra JWT keypair/Redis/refresh cookie; không đưa token lên chat           |

Live Gateway smoke và dữ liệu thật chỉ nghiệm thu sau khi operator setup xong.
Giai đoạn 5 không tự commit/push/đóng Jira hoặc chạy migration shared DB.

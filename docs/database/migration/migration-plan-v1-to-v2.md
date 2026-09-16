# Migration Plan — Database V1 → V2

> **STATUS: PLAN — chưa thực thi.** Tài liệu mô tả các công việc cần làm để migrate `scripts/init-postgres.sql` (V1, 15 bảng) sang schema V2 (`docs/database/schema-v2/brandhub-dbml.dbml`, 21 bảng PostgreSQL + 14 collection MongoDB).
> Nguồn: `docs/database/schema-v2/database-strategy.md`, `docs/database/schema-v2/brandhub-dbml.dbml`.

---

## 0. Điều kiện chặn (blocking) — ĐÃ XÁC NHẬN 2026-09-16

- [x] 3 quyết định thiết kế mở ở `database-strategy.md` §8 — giữ nguyên theo DBML hiện có, không đổi.
- [x] `workspace_member_permissions` (V1) — **bỏ hẳn**. Không dùng thật trong code hiện tại (không có query nào override quyền theo bảng này), 4 role cố định V2 đủ cover nghiệp vụ. YAGNI — thêm lại sau nếu phát sinh nhu cầu override lẻ.
- [x] Merge `user_subscriptions` 1-Owner-nhiều-Workspace — **bỏ qua**, chưa có data thật.
- [x] Môi trường: dev/staging trống/seed data — **drop & recreate sạch**. Không cần viết data-migration script (Giai đoạn C dưới đây bị loại khỏi scope thực thi).

---

## 1. Data Mapping V1 → V2

| Bảng V1 | Bảng V2 | Việc cần làm | Rủi ro |
|---|---|---|---|
| `workspaces` (đứng độc lập, có `owner_id`) | `agencies` (mới) + `workspaces.agency_id` | Mỗi `workspace` V1 → tạo 1 `agency` mới, `owner_id` chuyển sang `agencies.owner_id`, `workspaces.agency_id` trỏ agency vừa tạo | 1 user đang là owner nhiều workspace → tạo nhiều agency riêng, hay gộp 1 agency chứa nhiều workspace? Cần quyết định (mục 0) |
| `clients` (bảng đơn, `assigned_manager_id`/`portal_user_id`/`service_package`) | `client_profiles` (PG) + `workspace_members` (role=CLIENT) | Split: profile info (`name`, `contact_email`, `contact_phone`, `logo_url`) → `client_profiles`; quan hệ với workspace → insert row `workspace_members` role=CLIENT, `client_profile_id` trỏ tới | `portal_user_id` (nếu có) map vào `client_profiles.linked_user_id` |
| `clients.service_package` (jsonb tự do) | `media_packages` + `workspace_media_packages` + `media_campaigns` | Không map tự động được (jsonb tự do → 3 bảng có cấu trúc). Rule đề xuất: parse jsonb hiện có tạo 1 `media_package` custom (`is_template=false`) + 1 `workspace_media_packages` (`negotiation_status='APPROVED'` nếu đã dùng thật) cho mỗi client có `service_package` không rỗng | Data cũ có thể không đủ field để điền `package_type`/`duration_weeks`/`budget_amount` — cần default hoặc bỏ trống chờ nghiệp vụ sửa tay |
| `workspace_subscriptions` | `user_subscriptions` (đổi cấp Workspace → User/Owner) | Với mỗi agency mới tạo, lấy 1 sub đại diện gán cho `agencies.owner_id` | Conflict nếu nhiều workspace/owner có sub khác nhau — xem mục 0 |
| `payments` + `invoices` | `transactions` (gộp 2 bảng) | Map field trùng tên trực tiếp; field không tồn tại ở V2 (`invoice_number`, `period_start/end`) lưu vào `ref_id` hoặc bỏ | Mất lịch sử invoice chi tiết nếu không lưu — xác nhận có cần giữ archive riêng không |
| `workspace_member_permissions` | (không có trong V2 DBML) | Theo kết quả mục 0: xoá hẳn hoặc giữ nguyên bảng, không đổi | — |
| `audit_logs` | `audit_logs` (đổi `workspace_id` → `agency_id`, nullable) | Map `workspace_id` cũ → `agency_id` của agency vừa tạo cho workspace đó | Audit log cũ gắn theo workspace, sau migrate agency 1-nhiều-workspace thì mất độ chi tiết cấp workspace (chấp nhận, ghi rõ trong changelog) |
| `user_system_roles`, `user_oauth_providers`, `user_refresh_tokens`, `users` | Không đổi (Identity group V2 giữ nguyên V1) | Copy thẳng, không transform | — |
| `subscription_plans` | `subscription_plans` (đổi field: bỏ `max_clients`/`max_posts_month`, thêm `max_workspaces`) | Map field trùng tên, field mới cần giá trị default theo tier | — |

### Bảng hoàn toàn mới (chỉ tạo, không cần map data)
`agencies`, `agency_members`, `agency_invitations`, `workspace_templates`, `media_packages`, `workspace_media_packages`, `media_campaigns`, `third_party_collaborators`, `campaign_collaborators`, `ai_credit_ledgers`.

### MongoDB — 10 collection (business-service: 8, ai-service: giữ nguyên, publisher-service: giữ nguyên)
Chưa có collection nào tồn tại (0% code). Không phải migrate — là **tạo mới từ đầu**: `tasks`, `task_approvals`, `posts` (đổi nghĩa), `content_requests` (đổi FSM), `material_repository`, `brand_collections`, `hashtag_collections`, `content_versions`.

---

## 2. Trình tự thực hiện

### Giai đoạn A — Chuẩn bị
1. Backup toàn bộ DB hiện tại (`pg_dump`) trước khi chạy bất kỳ script nào — lưu ngoài server, có timestamp trong tên file.
2. Chốt toàn bộ mục 0 với Trung, ghi quyết định vào `database-strategy.md` (bỏ dòng "STATUS: DESIGN").

### Giai đoạn B — Schema DDL — ✅ DONE 2026-09-16
3. ✅ `scripts/init-postgres-v2.sql` — 20 bảng (bỏ `workspace_member_permissions` theo quyết định mục 0), enum V2 đầy đủ, trigger `updated_at` + audit-log immutability, seed 3 subscription plan (BASIC/PRO/ENTERPRISE). File V1 giữ nguyên không sửa, dùng làm tham khảo/rollback.
4. ⬜ Mongo schema validation (`$jsonSchema`) + index creation script cho 8 collection business-service mới — chưa làm, thuộc Epic E51 riêng.

### Giai đoạn C — Data migration — BỎ QUA (theo mục 0: không có data thật cần giữ)
~~5. Viết script migration data riêng~~
~~6. Chạy migration script trên staging trước~~

### Giai đoạn D — Cập nhật code
7. Cập nhật toàn bộ `@Entity` trong `brandhub-business-service/src/main/java/com/brandhub/business/model/` — đổi 10 entity hiện có, thêm 10 entity mới, xoá `Client.java`/`WorkspaceMemberPermission.java` nếu mục 0 quyết định bỏ.
8. Cập nhật `WorkspaceServiceImpl` và service liên quan: `createWorkspace` giờ tạo `agency` trước; `inviteMember`/`removeMember` xử lý thêm case role=CLIENT gắn `client_profile_id` thay vì `user_id`.
9. Cập nhật `RequireRoleAspect` — thêm check khi role=CLIENT chưa có `user_id` (chỉ có `client_profile_id`).
10. Cập nhật `openapi.yaml` — toàn bộ request/response DTO đổi theo bảng mới (workspace, client, billing endpoints).
11. Cập nhật `brandhub-web-dashboard` — type TypeScript, API call theo model Agency mới.
12. Viết code business logic cho 8 MongoDB collection mới (Task, Approval, Content Request FSM mới, Material, Brand Collection, Hashtag, Content Version) — đây là phần lớn nhất, 0% code hiện tại, tách riêng thành nhiều task con theo FR (đã có trong `brandhub-master-plan.md` Epic E51).

### Giai đoạn E — Kiểm chứng & rollback
13. Test integration đầy đủ trên staging: tạo agency → workspace → invite client → tạo media package → tạo campaign → tạo task, đi hết luồng chính trước khi merge.
14. Viết rollback script (revert về backup Giai đoạn A) — chuẩn bị sẵn, test thử trên staging, không chờ tới lúc lỗi thật mới viết.
15. Merge vào `develop` chỉ khi Giai đoạn D + E xong hết, có ít nhất 1 approval theo branch protection rule hiện có.

---

## 3. Rủi ro lớn nhất cần theo dõi

| Rủi ro | Mức độ | Ghi chú |
|---|---|---|
| 1 Owner nhiều Workspace nhưng V2 chỉ 1 `user_subscriptions`/Owner | Cao | Có thể mất data billing nếu không quyết rule trước (mục 0) |
| `workspace_member_permissions` biến mất khỏi V2 | Trung | Nếu đang dùng thật ngoài code audit đã thấy, mất tính năng fine-grained override |
| `clients.service_package` (jsonb tự do) → 3 bảng có cấu trúc | Trung | Data cũ thiếu field, cần default hoặc để trống chờ sửa tay |
| MongoDB 8 collection mới — 0% code, không phải "migrate" mà là "xây từ đầu" | Cao (nhưng đã biết trước) | Tách task riêng theo Epic E51, không gộp vào migration DB này |

---

## 4. Không nằm trong scope migration này

- FR 3.7 AI Features (loại trừ theo `brandhub-master-plan.md`).
- `ai-service`/`publisher-service` MongoDB collection (giữ nguyên V1, không đổi theo V2).
- Redis/ChromaDB (không đổi, độc lập với model Agency/Workspace).

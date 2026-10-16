# DA-949 / DA-950 — triển khai schema danh bạ đối tác

Migration: `migrations/2026-10-13-partner-directory-lifecycle.sql`.
Init mới: `init-postgres-v2.sql`. Không chạy full init trên database đang có dữ liệu.

## Thay đổi

| Cột | Ý nghĩa |
|---|---|
| is_active | Khả dụng cho gán mới; dữ liệu cũ mặc định true |
| first_used_at | Dấu sử dụng bền vững, không mất khi xóa Campaign/link |
| usage_history_verified | Legacy=false khóa xóa; API create mới=true |
| version | Optimistic version, tăng khi sửa/ngừng hoặc lần đầu sử dụng |

Backfill first_used_at bằng MIN(updated_at) của các link còn tồn tại — đây là
mốc baseline có chứng cứ, **không khẳng định là thời điểm sử dụng thật đầu tiên**.
Không sửa cooperation_status, không xóa partner/link. Rows không có link vẫn
history-unverified. Trigger bảo vệ writer cũ khỏi gán partner inactive, ghi marker
cùng transaction. Cooperation update của link cũ không bị active gate.

## Rollout cần operator review

1. Backup, xác nhận đúng database/credential và dừng writer (Business Service/seeders).
2. Chạy migration với `psql -v ON_ERROR_STOP=1 -f <absolute-path-to-migration>`.
   Migration có transaction/table lock; dùng maintenance window tránh chờ writer lâu.
3. Kiểm tra cột mới, trigger `trg_campaign_partner_usage`, số partner/link không đổi;
   kiểm tra legacy flag=false và baseline ở rows có surviving links.
4. Deploy/restart Business Service mới rồi test qua Gateway bằng account test hiện có:
   Owner CRUD, non-Owner 403, legacy delete 409, active-only options và inactive link cũ.
5. Deploy UI route danh bạ. Không cần Gateway route mới vì `/api/v1/**` đã forward.

**Cần chạy migration trước khi restart binary mới**, nếu không Hibernate validate
sẽ báo thiếu cột. Migration được thiết kế chạy lặp; không tự mở khóa legacy rows.
Không init Mongo hoặc thay đổi dữ liệu tài khoản trong đợt này.

## Rollback

Rollback UI/API trước và giữ nguyên các cột/trigger/history. Không tự drop lifecycle
columns hoặc xóa first_used_at để chạy binary cũ. Không bật lại partner inactive
qua SQL nhằm vượt quy tắc. Nếu cần rollback schema, phải có kế hoạch backup/data
review riêng; không kèm lệnh destructive rollback trong migration này.

Inventory chỉ đọc local 2026-10-13: 20 partners, 23 links, 6 partners không có link,
20 contact_info objects. Migration **chưa chạy trên database đó**.

# Plan — DA-949, tích hợp DA-950

## 1. Schema

Viết migration mới thêm `is_active BOOLEAN NOT NULL DEFAULT TRUE`, `first_used_at TIMESTAMPTZ NULL` vào third_party_collaborators; đồng bộ init-postgres-v2.sql. Backfill first_used_at cho đối tác có link bằng mốc cập nhật sớm nhất hiện có (đây là lower-quality baseline, không khẳng định là thời điểm sử dụng thật đầu tiên). Bảo toàn mọi link và cooperation_status. Inventory dữ liệu lịch sử mất liên kết trước khi kết luận partner chưa từng dùng; hỏi team nếu không xác minh được.

## 2. Service/API

Chi tiết đã chốt trước code: thêm `usage_history_verified BOOLEAN NOT NULL DEFAULT FALSE`
cho legacy, API create đặt true; `version BIGINT NOT NULL DEFAULT 0` chống stale writes.
DTO quản lý gồm canDelete + reason; contactInfo giữ JSONB object (API JSON object),
UI nhập người liên hệ/email/điện thoại/website, giữ các keys legacy không biết khi sửa.
Name trim/max255, notes max10000, contact JSON max10000 ký tự; fields lạ trên payload
bị từ chối. Mutation có expectedVersion; deactivate lặp cùng trạng thái trả hiện tại.
Schema trigger trên insert/link change khóa partner và chặn inactive; ghi firstUsedAt
bền vững + version lần dùng đầu, bảo vệ cả writer cũ. Trigger không làm mới marker
khi link/Campaign bị xóa. Marker mapped read-only trong JPA, không bị form overwrite.
Lock assign Campaign→partner; CRUD lifecycle chỉ partner; cooperation update giữ
link→partner read-only, không active gate cho link cũ. Không mở legacy CRUD stubs
của FR 3.7.12; legacy assign/update đã delegate DA-950 và nhận cùng guard.

- Owner-only Agency CRUD/deactivate, chống cross-Agency, optimistic guard update. Reuse entity/repository, không gọi UnsupportedOperationException từ endpoint mới.
- List management gồm inactive; Workspace selection list chỉ active, có quyền theo membership và không lộ toàn danh bạ sang Agency khác.
- Lock row đối tác trong cả assign/delete/deactivate theo cùng thứ tự; verify active trước tạo link mới, update first_used_at cùng transaction. Delete chỉ khi first_used_at null VÀ không link, FK RESTRICT là lớp phòng thủ cuối.
- Với link tồn tại, trả link idempotently trước active guard, không reset trạng thái. Inactive không chặn đọc/update cooperation link cũ.
- Giữ legacy APIs nếu có consumer; đưa assign legacy qua cùng guard. Không cho payload sửa isActive/firstUsedAt trực tiếp; deactivate command riêng, không hỗ trợ reactivate trong đợt này.

## 3. UI và phạm vi file

Owner route `/agency/:agencyId/collaborators`, form/list/detail và confirm actions tại feature riêng; typed API client. Thêm `src/i18n/locales/{vi,en}/collaborators.json` và đăng ký namespace. Chỉ thêm route/sidebar Owner cần thiết, không sửa menu/UI module khác. Workspace `pages/campaign-partners` dùng active picker; linked list hiện badge inactive. Locale `campaign.json` chỉ bổ sung keys liên quan. Theme tokens, focus, i18n, empty/retry/mobile/light-dark kiểm thử đầy đủ.

## 4. Verify/rollback

Unit/service tests và PostgreSQL integration race assign/delete/deactivate; legacy + Workspace APIs; browser flow thực. Migration rerun/parity test trên DB riêng, không chạy trên shared DB khi chưa có quyền. Rollback UI/API trước, giữ first_used_at và inactive data; không tự drop columns hoặc xóa lịch sử để quay về schema cũ. Commit schema/CRUD theo DA-949, Campaign guard/picker/regression theo DA-950.

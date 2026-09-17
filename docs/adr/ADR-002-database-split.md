# ADR-002 — MongoDB + PostgreSQL Split

**Status:** Accepted

## Context

business-service cần lưu 2 loại dữ liệu bản chất khác nhau: dữ liệu nghiệp vụ có cấu trúc, quan hệ chặt, giao dịch tiền thật (identity, Agency/Workspace, billing) và dữ liệu nội dung có schema linh hoạt, thay đổi nhanh theo tính năng (Task, Post, Material, Livestream). Cần quyết định dùng 1 DB duy nhất hay tách 2 loại.

## Decision

**Tách 2 database engine trong cùng business-service:**
- **PostgreSQL** — 23 bảng: Identity (users, oauth, roles), Organization (agencies, workspaces, members), Commerce (media packages, campaigns), Collaborator, Billing (subscriptions, transactions, AI credit).
- **MongoDB** — 14 collection: Task, TaskApproval, Post, ContentRequest, Material, Brand/Hashtag Collection, Livestream, Survey, Mail Template, Social Account, Notification.

## Consequences

**Tích cực:**
- PostgreSQL đảm bảo **ACID** cho giao dịch tiền thật (FR 3.9.3 Make Payment yêu cầu rõ ACID) và ràng buộc toàn vẹn quan hệ (1 Owner/Agency, 1 Manager/Workspace, FK giữa agency↔workspace↔member).
- MongoDB cho phép schema linh hoạt khi thêm field mới cho Task/Post (3 loại nội dung: Post/Livestream/Survey dùng chung khung Approval Sequence nhưng field riêng biệt) mà không cần migration ALTER TABLE.
- Content/Task volume ghi cao (mỗi comment, mỗi version content) phù hợp write throughput của MongoDB hơn PostgreSQL.

**Tiêu cực:**
- Không có JOIN cross-DB ở tầng engine — mọi tham chiếu (vd: `tasks.workspaceId`) là soft reference bằng ID string, business-service phải tự join ở application layer (xem `docs/architecture/db-ownership-diagram.html` — Cross-DB Reference Strategy).
- 2 connection pool, 2 hệ thống backup/migration riêng — tăng vận hành so với 1 DB duy nhất.
- Risk: dữ liệu không nhất quán nếu 1 thao tác cần ghi cả 2 DB (vd: approve Campaign → tạo Task) mà không có transaction xuyên DB — cần xử lý bằng application-level compensating logic, không có 2-phase commit thật.

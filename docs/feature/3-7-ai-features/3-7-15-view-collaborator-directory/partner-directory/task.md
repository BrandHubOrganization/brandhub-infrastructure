# Tasks — DA-949 / DA-950

- [x] Inventory schema/links/legacy consumers; báo dữ liệu không chứng minh được lịch sử sử dụng.
- [x] Chốt legacy chưa xác minh khóa xóa, mới chưa dùng được xóa; không reactivate/manual verify API.
- [x] New migration lifecycle/version/history flag + backfill có kiểm chứng + init parity.
- [x] Owner-only scoped CRUD/deactivate, DTO validation/version, management pagination/filter.
- [x] Active-only Workspace selection read, không mở danh bạ quản lý cho Manager/Creator/Client.
- [x] Row-lock assign/delete/deactivate và marker first use atomically, FK protection.
- [x] Legacy assign và Workspace assign cùng rule; existing link idempotency không reset.
- [x] Owner Agency UI riêng; giữ Campaign links inactive đọc/update được.
- [x] Thêm parallel vi/en collaborators.json, namespace registration; tái dùng labels Campaign hiện có.
- [x] Browser fixture: form auto-focus/Escape, mobile/light/dark, confirmation; chưa full accessibility audit.
- [x] Unit/MockMvc + PostgreSQL query/trigger/rerun/concurrency + browser fixture tests.
- [ ] API JWT thật qua Gateway với account hiện có sau operator migration; chưa nghiệm thu runtime.
- [x] Migration rerun/init và rollback review trên DB riêng; chưa chạy shared DB.
- [ ] Chia commit DA-949 schema/directory và DA-950 integration; ghi evidence trước review Jira.

Inventory 2026-10-13 (read-only): 20 partners / 23 links / 6 partners không có link
hiện tại; cả 20 contact_info là JSON object. Không suy ra 6 partners chưa từng dùng.
Migration chưa apply lên database đang dùng. Không commit/push trong giai đoạn này.

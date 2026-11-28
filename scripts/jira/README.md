# Jira Workload Dashboard Exporter (`scripts/jira/`)

- Quay lại: [Scripts Manual](../README.md) · [Infrastructure Hub](../../README.md) · [Docs Site Guide](../../docs-site/README.md)
- Template biến môi trường: [`../../.env.example`](../../.env.example)

Script [`export-jira.js`](export-jira.js) (Node.js 20+, không phụ thuộc thư viện npm ngoài) gọi trực tiếp **Jira Cloud REST API v3** (`POST /rest/api/3/search/jql` với phân trang `nextPageToken`) trên project **`DA`**, chuẩn hóa tên thành viên (`Trung`, `Lộc`, `Tuấn`, `Ân`, `Phước`), và xuất snapshot tiến độ `[DA-*]` ra [`../../docs/plan/jira-status.json`](../../docs/plan/jira-status.json) để Workload Dashboard hiển thị.

---

## 1. Cấu hình lần đầu (`.env` ở gốc repo)

1. Khởi tạo Atlassian API Token tại: https://id.atlassian.com/manage-profile/security/api-tokens
2. Tại thư mục gốc `brandhub-infrastructure/`, sao chép [`.env.example`](../../.env.example) sang `.env` (gitignored và được bảo vệ bởi `check_sensitive_paths.py`):
   ```bash
   cp .env.example .env
   ```
3. Điền đầy đủ 3 biến môi trường trong `.env`:
   - `JIRA_SITE=https://letritrung2605.atlassian.net`
   - `JIRA_EMAIL=<atlassian_account_email>`
   - `JIRA_API_TOKEN=<atlassian_api_token>`

---

## 2. Thực thi cập nhật Snapshot

Chạy từ bất kỳ thư mục nào (script tự định vị `REPO_ROOT`):

```bash
node scripts/jira/export-jira.js
```

**Cơ chế trích xuất**:
- Truy vấn JQL: `project = DA AND issuetype = Task ORDER BY key ASC` (`maxResults: 100` mỗi trang).
- Lọc mọi Jira issue có mã `[DA-...]` trong `summary` và ghi ra `docs/plan/jira-status.json` với cấu trúc `{ exportedAt, project, total, tasks: [{ taskId, jiraKey, status, assignee }] }` (hoàn toàn không chứa thông tin xác thực hay email cá nhân).

---

## 3. Liên kết với Kiến trúc Dashboard (`docs-site`)

| Thành phần | Đường dẫn | Vai trò |
| :--- | :--- | :--- |
| **Trang VitePress** | `docs/dashboard.md` | Route `/dashboard` nhúng giao diện Workload Dashboard |
| **Static UI** | `docs-site/public/dashboard/index.html` | Bố cục bộ lọc sprint, epic, thành viên và biểu đồ tiến độ |
| **Data Merger** | `docs-site/public/dashboard/dashboard.js` | Đọc `docs/plan/brandhub-master-plan.md` kết hợp `docs/plan/jira-status.json` |
| **Tracked Snapshot** | `docs/plan/jira-status.json` | Dữ liệu trạng thái Jira đã chuẩn hóa phục vụ build tĩnh trên GitHub Pages |

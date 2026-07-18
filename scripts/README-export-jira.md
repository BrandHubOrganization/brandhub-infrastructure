# Export Jira status cho Workload Dashboard

Script `export-jira.js` gọi thẳng Jira REST API v3 (không qua MCP hay treo), xuất `docs/plan/jira_status.json` cho dashboard đọc.

## Setup 1 lần

1. Tạo Jira API token: https://id.atlassian.com/manage-profile/security/api-tokens
2. Ở **gốc repo** (`brandhub-infrastructure/`): `cp .env.example .env` rồi điền `JIRA_EMAIL` + `JIRA_API_TOKEN`

## Chạy

```bash
node scripts/export-jira.js
```

Chạy lại mỗi khi muốn đồng bộ tiến độ Jira mới nhất vào dashboard.

## Kiến trúc dashboard (tham khảo)

| File | Vị trí | Vai trò |
|---|---|---|
| `docs/dashboard.md` | VitePress page, route `/dashboard` | Nhúng iframe trỏ `/dashboard/index.html` |
| `frontend/public/dashboard/index.html` | Vite static asset | Layout + style dashboard thật |
| `frontend/public/dashboard/dashboard.js` | Vite static asset | Parse `BrandHub_Master_Plan.md` + merge `jira_status.json`, render chart/bảng |
| `docs/plan/jira_status.json` | gitignored | Snapshot status Jira, tự tạo bằng `export-jira.js` |

**Vì sao dashboard nằm ở `frontend/public/` chứ không `docs/`:** VitePress coi mọi thư mục có `README.md`/`index.md` trong `docs/` (srcDir) là 1 route markdown — đặt `index.html` cùng cấp gây route trùng lồng nhau (nav lặp 3 lớp). `frontend/public/` là static passthrough thật của Vite, không qua markdown router.

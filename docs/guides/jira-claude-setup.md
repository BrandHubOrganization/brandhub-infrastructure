# Hướng dẫn kết nối Claude Code với Jira — BrandHub

> Dành cho Lộc và các thành viên team AI.
> Sau khi setup, Claude có thể đọc/ghi Jira issue, query sprint, assign task, cập nhật status.

---

## 1. Tạo Jira API Token

1. Vào https://id.atlassian.com/manage-profile/security/api-tokens
2. Nhấn **Create API token**
3. Đặt tên: `claude-code-brandhub`
4. **Copy token ngay** — Atlassian chỉ hiện 1 lần
5. Token có dạng: `ATATT3xFfGF0hOu...`

> Token này tương đương mật khẩu — không commit lên GitHub, không share qua chat công khai.

---

## 2. Lưu thông tin Jira

Tạo file `.env` trong thư mục gốc repo `brandhub-infrastructure/`:

```env
JIRA_SITE=letritrung2605.atlassian.net
JIRA_EMAIL=email-cua-ban@gmail.com
JIRA_TOKEN=ATATT3xFfGF0hOu...
```

> Mỗi người dùng email + token riêng. Token của Trung đã có sẵn trong các script fix_jira.

---

## 3. Cấu hình Claude Code MCP Server (khuyên dùng)

Thêm vào `C:\Users\<tên>\.claude\settings.json`:

```json
{
  "mcpServers": {
    "jira": {
      "type": "http",
      "url": "https://letritrung2605.atlassian.net",
      "headers": {
        "Authorization": "Basic <base64-cua-email:token>"
      }
    }
  }
}
```

Tạo base64 auth string bằng lệnh (PowerShell):

```powershell
[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("email-cua-ban@gmail.com:ATATT3...token..."))
```

Copy kết quả vào `Authorization: Basic <kết-quả>`.

---

## 4. Cách dùng nhanh (không cần MCP)

Nếu không cài MCP, dùng curl trực tiếp trong Claude Code qua Bash tool:

### Query sprint

```bash
curl -s -u "email:token" "https://letritrung2605.atlassian.net/rest/agile/1.0/sprint/78/issue?maxResults=100"
```

### Tạo task mới

```bash
curl -s -u "email:token" -X POST -H "Content-Type: application/json" \
  -d '{"fields":{"project":{"key":"DA"},"summary":"[DA-AIxx-xx] Task name","description":{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"type":"text","text":"Description"}]}]},"issuetype":{"id":"10045"},"parent":{"key":"DA-xxx"}}}' \
  "https://letritrung2605.atlassian.net/rest/api/3/issue"
```

### Gán task vào Sprint

```bash
curl -s -u "email:token" -X POST \
  -H "Content-Type: application/json" \
  -d '{"issues":["DA-xxx"]}' \
  "https://letritrung2605.atlassian.net/rest/agile/1.0/sprint/78/issue"
```

### Assign task

```bash
curl -s -u "email:token" -X PUT \
  -H "Content-Type: application/json" \
  -d '{"accountId":"<accountId-cua-nguoi-duoc-assign>"}' \
  "https://letritrung2605.atlassian.net/rest/api/3/issue/DA-xxx/assignee"
```

---

## 5. Thông số quan trọng của BrandHub Jira

| Tham số | Value | Ghi chú |
|---------|-------|---------|
| **Jira Site** | `letritrung2605.atlassian.net` | |
| **Project Key** | `DA` | |
| **Project ID** | `10035` | Dùng khi tạo issue qua API |
| **Issue Type ID (Task)** | `10045` | |
| **Issue Type ID (Epic)** | `10048` | |
| **Sprint 6 ID** | `78` | Đổi theo sprint |
| **Board ID** | *(tự tra)* | |

### Tra Sprint ID

```bash
# List tất cả sprint của board
curl -s -u "email:token" "https://letritrung2605.atlassian.net/rest/agile/1.0/board/<boardId>/sprint"
```

### Tra Account ID của thành viên

```bash
curl -s -u "email:token" "https://letritrung2605.atlassian.net/rest/api/3/user/assignable/search?project=DA"
```

| Người | Account ID |
|-------|-----------|
| Lê Trí Trung | `61bc48ad08e4e00069b20d6c` |
| Nguyễn Chơn Phước | `712020:d2f784a1-44cf-468f-bb96-cd8930b1c135` |
| Ân Hà | `712020:b501eda5-2140-417d-bc3a-c342db8310cc` |
| Nguyễn Thanh Lộc | `712020:5ec38295-3d34-4ff3-ae87-95279adf1dff` |

---

## 6. Code mẫu cho Claude Code

Khi chat với Claude, dùng prompt như sau để query Jira:

```
Kiểm tra tất cả task trong Sprint 6 của tôi trên Jira.
Token: ATATT3xFfGF0hOu...
Jira Site: letritrung2605.atlassian.net
```

Claude sẽ tự dùng Bash tool + curl để gọi API.

---

## 7. Quy tắc commit & branch (nhắc lại)

Xem chi tiết: `brandhub-infrastructure/docs/rule/git-commit-convention.md`

```
Branch:  <type>/DA-<id>-<mô-tả-ngắn>
Commit:  <type>(DA-<id>): <mô tả ngắn>
PR:      [DA-<id>] <Mô tả ngắn>

Ví dụ:
  feature/DA-47-user-schema
  feat(DA-47): implement User schema with validation
  [DA-47] User Schema — MongoDB + Validation
```

---

## 8. Troubleshooting

| Lỗi | Nguyên nhân | Fix |
|-----|------------|-----|
| `401 Unauthorized` | Token hết hạn hoặc sai | Tạo token mới tại https://id.atlassian.com/manage-profile/security/api-tokens |
| `404 Not Found` | Sai issue key hoặc không có quyền | Kiểm tra project key `DA` và quyền truy cập |
| `400 Bad Request` | Thiếu field bắt buộc | Kiểm tra `project.id`, `issuetype.id`, `summary` |
| `DeepSeek classifier block` | Classifier chặn ghi ra ngoài | Chạy script thủ công từ terminal thay vì qua Claude |

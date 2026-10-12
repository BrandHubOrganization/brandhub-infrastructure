# Plan — Delete Mail Template (FR 3.6.31)

> Nguồn chuẩn dùng chung cho cả 5 FR: [../3-6-28-32-mail-template/](../3-6-28-32-mail-template/) (spec, plan, task, test gộp). File này lấy đúng phần của FR 3.6.31 để mỗi FR có đủ bộ 4 tài liệu (`spec.md`, `plan.md`, `task.md`, `test.md`) theo `docs/rule/feature-workflow.md`. Khi có khác biệt, bản gộp là bản đúng.

- **Jira:** DA-1001
- **Mục tiêu:** Xóa mềm mẫu email không còn dùng; lô đã gửi trước đó không bị ảnh hưởng.
- **Spec:** [spec.md](spec.md) · **Sequence:** [report4_sequence.puml](report4_sequence.puml)

## 3. Vai trò và quyền

| Hành động | OWNER | MANAGER | CREATOR | CLIENT | ADMIN hệ thống |
|---|---|---|---|---|---|
| Xem danh sách / chi tiết template | ✔ | ✔ | ✔ | ✘ | ✔ (mẫu hệ thống) |
| Tạo / clone | ✔ | ✔ | ✔ | ✘ | ✔ (mẫu hệ thống) |
| Sửa / xóa template của Workspace | ✔ | ✔ | chỉ của mình | ✘ | — |
| Sửa / xóa template hệ thống | ✘ | ✘ | ✘ | ✘ | ✔ |
| Gửi, gửi thử, preview, hẹn giờ | ✔ | ✔ | ✔ | ✘ | — |
| Xem lịch sử lô / người nhận | ✔ | ✔ | ✔ | ✘ | — |
| Hủy lô đã hẹn | ✔ | ✔ | chỉ lô của mình | ✘ | — |

Backend: `@RequireRole({OWNER, MANAGER, CREATOR})` + kiểm tra sở hữu cho sửa/xóa/hủy. Admin API dùng quyền hệ thống `ADMIN` như các `Admin*Controller` hiện có.

### 4.1 MongoDB — `mail_templates` (theo ERD hiện có, bổ sung trường)
| Trường | Kiểu | Ghi chú |
|---|---|---|
| `_id` | ObjectId | |
| `workspaceId` | string / null | `null` với `SYSTEM_DEFAULT` |
| `name` | string ≤120 | bắt buộc |
| `subject` | string ≤200 | bắt buộc, được chứa biến |
| `bodyHtml` | string ≤100KB | bắt buộc, đã sanitize |
| `type` | `SYSTEM_DEFAULT` \| `CUSTOM` | |
| `attachments` | array `{attachmentId, name, contentType, size, s3Key}` | mặc định gắn kèm (D9) |
| `clonedFromId` | string | truy vết |
| `createdBy` | string | user id |
| `createdAt`, `updatedAt` | date | |
| `deletedAt` | date | soft delete; mọi truy vấn lọc `deletedAt = null` |

Index: `{workspaceId:1, deletedAt:1, createdAt:-1}`, `{type:1, deletedAt:1}`.

### 5.1 Template (Workspace)
| Method | Path | Mô tả |
|---|---|---|
| GET | `/workspaces/{id}/mail-templates?includeSystem=true&q=&page=&size=` | List: `id, name, subject (preview 120 ký tự), type, attachmentCount, createdAt` |
| GET | `/workspaces/{id}/mail-templates/{tid}` | Chi tiết đầy đủ (kể cả template hệ thống) |
| POST | `/workspaces/{id}/mail-templates` | `{name, subject, bodyHtml, attachmentIds?, cloneFromId?}` → `201 {id,...}`. Trống `subject`/`bodyHtml` → 400 `VALIDATION_ERROR`; `cloneFromId` thiếu `name/subject/bodyHtml` thì lấy từ nguồn |
| PATCH | `/workspaces/{id}/mail-templates/{tid}` | `{name?, subject?, bodyHtml?, attachmentIds?}` → `200`. Template hệ thống → 403 `SYSTEM_TEMPLATE_READ_ONLY` |
| DELETE | `/workspaces/{id}/mail-templates/{tid}` | Soft delete → `200 null` |
| POST | `/workspaces/{id}/mail-templates/{tid}/preview` | `{variables?, recipient?}` → `{subject, bodyHtml, missingVariables[]}` |
| POST | `/workspaces/{id}/mail-templates/{tid}/send-test` | `{variables?}` → gửi **đồng bộ** tới email người dùng; không tính quota; SMTP lỗi → 502 |
| POST | `/workspaces/{id}/mail-templates/{tid}/send` | Xem 5.2 |

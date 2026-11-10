# UC — List Task View (V2)

| | |
|---|---|
| FR Code | 3.6.4 |
| Feature | List Task View |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER, OWNER |
| Version | 2.1 (MongoDB Task Collection, 2026-10-14) |
| Trạng thái | Confirmed — Ready to Implement |

---

## 1. Objective

Cung cấp API truy xuất danh sách Task theo định dạng bảng chuẩn (List View kiểu Jira / ClickUp) cho Workspace. Hỗ trợ phân trang và sắp xếp linh hoạt theo các tiêu chí chính (`dueDate`, `createdAt`, `name`, `status`).

---

## 2. User Story

Là một **Creator**, **Manager**, **Client** hoặc **Owner** trong Workspace,
tôi muốn xem danh sách các công việc dưới dạng bảng danh sách có phân trang và sắp xếp,
để quét nhanh toàn bộ tiến độ, phân loại deadline và tình trạng thực hiện trong Workspace.

---

## 3. Acceptance Criteria

1. **Endpoint**: `GET /api/v1/workspaces/{id}/tasks`
2. **Authorization**:
   - Người dùng phải là thành viên hợp lệ (active member) của Workspace với một trong các role: `OWNER`, `MANAGER`, `CREATOR`, `CLIENT`.
   - Nếu không thuộc Workspace hoặc bị vô hiệu hóa → trả về `403 FORBIDDEN`.
3. **Pagination**:
   - `page`: số trang (0-indexed, default = 0).
   - `size`: số lượng item mỗi trang (default = 20, max = 100).
4. **Sorting**:
   - `sort`: trường cần sắp xếp. Hỗ trợ: `dueDate`, `createdAt`, `name`, `status` (default: `createdAt`).
   - `direction`: chiều sắp xếp (`asc` hoặc `desc`, default: `desc`).
5. **Dữ liệu trả về**:
   - Danh sách các item gồm: `id`, `workspaceId`, `campaignId`, `type`, `name`, `status`, `dueDate`, `assigneeId`, `createdAt`, `updatedAt`.
   - Thông tin phân trang: `page`, `size`, `totalElements`, `totalPages`, `isLast`.

---

## 4. API Contract

### Request

```http
GET /api/v1/workspaces/{workspaceId}/tasks?page=0&size=20&sort=dueDate&direction=asc
Authorization: Bearer <jwt_token>
```

#### Query Parameters:
| Param | Type | Required | Default | Description |
|---|---|---|---|---|
| `page` | integer | No | 0 | Chỉ mục trang (bắt đầu từ 0) |
| `size` | integer | No | 20 | Số lượng task mỗi trang (1..100) |
| `sort` | string | No | `createdAt` | Trường sort: `dueDate`, `createdAt`, `name`, `status` |
| `direction` | string | No | `desc` | Chiều sort: `asc` hoặc `desc` |

### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "c1f73752-9f37-4d1a-bd3c-8a032efb6920",
        "workspaceId": "cb6d5959-cceb-440c-92c8-2ec537eeb363",
        "campaignId": "851c638d-f60b-4bad-9edb-1838ed029753",
        "type": "POST",
        "name": "Bài viết giới thiệu sản phẩm mới",
        "status": "IN_PROGRESS",
        "dueDate": "2026-10-25T17:00:00Z",
        "assigneeId": "aef1f6f2-129a-4fb7-8e62-90063081603d",
        "createdAt": "2026-10-14T08:00:00Z",
        "updatedAt": "2026-10-14T09:30:00Z"
      }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 1,
    "totalPages": 1,
    "last": true
  },
  "requestId": "req-12345"
}
```

### Error Responses

- `401 UNAUTHORIZED`: Chưa đăng nhập hoặc token hết hạn.
- `403 FORBIDDEN`: Không có quyền truy cập Workspace này.
- `400 BAD_REQUEST`: Tham số sort hoặc pagination không hợp lệ.

---

## 5. Definition of Done (DoD)

1. API `GET /api/v1/workspaces/{workspaceId}/tasks` chạy đúng spec, có phân trang Page<TaskItemResponse>.
2. Sắp xếp theo các cột `dueDate`, `createdAt`, `name`, `status` cả ASC và DESC mượt mà trên MongoDB.
3. Kiểm tra bảo mật Workspace: chặn thành viên ngoài workspace hoặc role không hợp lệ.
4. Unit/Integration Test cho controller và service.

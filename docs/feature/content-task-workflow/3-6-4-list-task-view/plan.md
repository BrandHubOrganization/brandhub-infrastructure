# Plan — List Task View Implementation

| | |
|---|---|
| FR Code | 3.6.4 |
| Feature | List Task View (`GET /api/v1/workspaces/{id}/tasks`) |
| Tech Stack | Spring Boot 3, Spring Data MongoDB, Pageable |
| Trạng thái | Ready to Code |

---

## 1. Scope & Kiến trúc dữ liệu

- **Nguồn dữ liệu:** MongoDB collection `tasks` (document: `TaskDocument`).
- **Phạm vi thực hiện:** Chỉ cài đặt List View (phân trang + sort theo `dueDate`, `createdAt`, `name`, `status`). Các view Calendar, Gantt, Kanban để lại làm sau.
- **Bảo mật:** Dùng `WorkspaceAccessService.requireActiveMember(workspaceId, currentUser.getId())` cho phép các roles: `OWNER`, `MANAGER`, `CREATOR`, `CLIENT`.

---

## 2. Kế hoạch triển khai chi tiết

### Giai đoạn 1: DTO Models
1. **Tạo `TaskListItemResponse.java`:**
   - Trường: `id`, `workspaceId`, `campaignId`, `type`, `name`, `status`, `dueDate`, `assigneeId`, `createdAt`, `updatedAt`.
2. **Tạo `PagedResponse.java` (hoặc tái sử dụng Spring `Page<TaskListItemResponse>`):**
   - Đảm bảo trả về cấu trúc chuẩn: `content`, `page`, `size`, `totalElements`, `totalPages`, `last`.

### Giai đoạn 2: Repository
1. **Cập nhật `TaskMongoRepository`:**
   - Bổ sung phương thức phân trang:
     ```java
     Page<TaskDocument> findByWorkspaceId(String workspaceId, Pageable pageable);
     ```

### Giai đoạn 3: Service Layer
1. **Khai báo trong `TaskService` interface:**
   ```java
   Page<TaskListItemResponse> getWorkspaceTasks(UUID workspaceId, AuthenticatedUser currentUser, Pageable pageable);
   ```
2. **Cài đặt trong `TaskServiceImpl`:**
   - Xác thực quyền thành viên: `access.requireActiveMember(workspaceId, currentUser.getId())`.
   - Whitelist các trường sort hợp lệ (`dueDate`, `createdAt`, `name`, `status`) để tránh injection hoặc lỗi query.
   - Gọi `taskRepository.findByWorkspaceId(workspaceId.toString(), pageable)`.
   - Map `TaskDocument` sang `TaskListItemResponse`.

### Giai đoạn 4: Controller Layer
1. **Thêm endpoint vào `TaskController`:**
   ```java
   @GetMapping
   @RequireRole({MemberRole.OWNER, MemberRole.MANAGER, MemberRole.CREATOR, MemberRole.CLIENT})
   public ApiResponse<Page<TaskListItemResponse>> getTasks(
           @PathVariable UUID workspaceId,
           @AuthenticationPrincipal AuthenticatedUser currentUser,
           @RequestParam(defaultValue = "0") int page,
           @RequestParam(defaultValue = "20") int size,
           @RequestParam(defaultValue = "createdAt") String sort,
           @RequestParam(defaultValue = "desc") String direction,
           WebRequest webRequest)
   ```

---

## 3. Rủi ro & Cách phòng tránh

1. **Sai lệch trường sort giữa API và MongoDB:**
   - Query param frontend có thể truyền `name` hoặc `title` → mapping an toàn trong service: nếu client truyền `title` tự map về `name` trong `TaskDocument`.
2. **Quyền truy cập của CLIENT:**
   - Endpoint `GET /tasks` phải mở quyền cho `MemberRole.CLIENT` vì Client cần xem tiến độ công việc trong workspace.

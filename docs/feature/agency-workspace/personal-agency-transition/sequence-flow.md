# Sequence Flow — Create Agency with Personal & Business Mode

> Tài liệu đồng hành với `report3_spec.md` và `report4_sequence.puml` (FR 3.4.3.B). Mô tả chi tiết từng bước tương tác: Actor → Action → System Step theo đúng mô hình kiến trúc BrandHub.

## Các Thực Thể Tham Gia (Participants)

- **User** — Người dùng đã đăng nhập (JWT token hợp lệ).
- **Client (Frontend)** — Ứng dụng Web Dashboard (`brandhub-web-dashboard`).
- **Gateway** — API Gateway (`brandhub-api-gateway` port 8080).
- **System (Backend)** — Core service (`brandhub-business-service` port 8081).
- **Database** — PostgreSQL (`agencies`, `agency_members`, `workspaces`, `workspace_members`).

---

## Luồng A: Tạo Agency Cá Nhân (Personal Mode — Tự Động Kích Hoạt Workspace)

1. **User → Client**: Người dùng mở màn hình Tạo Agency (`/agency/create`), chọn mục đích **"Cá nhân" (`PERSONAL`)**.
2. **Client**: Form tự động thích ứng:
   - Ẩn trường quy mô nhân sự `companySize`.
   - Đổi nhãn thành "Tên thương hiệu cá nhân / Kênh của bạn".
   - Đổi nút submit thành "Bắt đầu sáng tạo ngay ✨".
3. **User → Client**: Nhập tên thương hiệu (bắt buộc) và các thông tin nhận diện tùy chọn (logo, màu chủ đạo, mô tả, MXH) -> Nhấn Submit.
4. **Client → Gateway → System**: Gửi `POST /api/v1/agencies` với payload:
   ```json
   {
     "name": "Bếp Nhà Mai",
     "type": "PERSONAL",
     "category": "FNB",
     "brandColor": "#f05a28",
     "logoIcon": "Utensils",
     "description": "Kênh ẩm thực gia đình"
   }
   ```
5. **System (Validation & Transaction)**:
   - Xác thực: `name` không rỗng, `brandColor` <= 9 ký tự, `tagline` <= 140 ký tự.
   - Bắt đầu transaction `@Transactional`.
6. **System → Database (Tạo Agency & Owner)**:
   - Lưu bản ghi `agencies` với `type = 'PERSONAL'`, `status = 'ACTIVE'`, `owner_id = currentUser.id`.
   - Lưu bản ghi `agency_members` với `agency_id`, `user_id`, `role = 'OWNER'`.
7. **System → Database (Auto-provision Workspace)**:
   - Do `type == 'PERSONAL'`, hệ thống tự động khởi tạo bản ghi `workspaces`:
     * `agency_id`: id của Agency vừa tạo ở bước 6.
     * `name`: "Bếp Nhà Mai" (kế thừa tên).
     * `created_by`: `currentUser.id`.
     * `brand_color`, `logo_icon`, `description`: kế thừa từ Agency.
     * `timezone_config`: "Asia/Ho_Chi_Minh".
     * `settings`: "{}".
   - Lưu bản ghi `workspace_members`:
     * `workspace_id`: id của Workspace vừa tạo.
     * `user_id`: `currentUser.id`.
     * `role`: `MANAGER`.
     * `is_active`: `true`.
8. **System → Gateway → Client**: Trả về `201 Created` kèm `AgencyResponse` có `defaultWorkspaceId = personalWorkspace.id`.
9. **Client (State Update & Navigation)**:
   - Cập nhật `agencyStore`: gán `currentAgencyId`.
   - Cập nhật `workspaceStore`: gán `currentWorkspace = personalWorkspace`.
   - Hiển thị Toast thông báo thành công.
   - **Chuyển hướng lập tức sang `/workspaces/{defaultWorkspaceId}/dashboard`**.
10. **Client UI State (Personal Mode Activated)**:
    - Sidebar ẩn hoàn toàn các mục: Khách hàng (`/clients`), Hồ sơ khách hàng (`/client-profiles`), Lời mời khách hàng (`/client/invitations`), Cổng khách hàng (`/portal`), Phân quyền (`/agency/:id/roles`).
    - Các công cụ Sáng tạo nội dung (Viết bài, Lịch, Thư viện, Đăng bài) được mở sẵn sàng để sử dụng.

---

## Luồng B: Tạo Agency Doanh Nghiệp (Business Mode — Luồng Chuẩn)

1. **User → Client**: Người dùng chọn mục đích **"Doanh nghiệp" (`BUSINESS`)**.
2. **Client**: Form hiển thị đầy đủ các trường doanh nghiệp: Quy mô công ty (`companySize`), Website, Thông tin liên hệ.
3. **User → Client**: Nhập thông tin và bấm "Tạo Agency".
4. **Client → Gateway → System**: Gửi `POST /api/v1/agencies` với `type = "BUSINESS"`.
5. **System → Database**: Lưu bản ghi `agencies` (`type = 'BUSINESS'`) và `agency_members` (`OWNER`). **Không** tự động tạo Workspace.
6. **System → Client**: Trả về `201 Created` (`defaultWorkspaceId = null`).
7. **Client**: Chuyển hướng người dùng về trang chi tiết Agency `/agency/{agencyId}`.

---

## Bảng Xử Lý Các Trường Hợp Lỗi (Error Paths)

| Giai đoạn | Điều kiện lỗi | HTTP Status | Error Code | Xử lý giao diện / Hệ thống |
|:---|:---|:---:|:---|:---|
| Client Validate | Tên để trống | N/A | MSG02 | Báo lỗi đỏ dưới ô input "Tên không được để trống", chặn submit. |
| Server Validate | Tên toàn khoảng trắng | 400 | `VALIDATION_ERROR` | GlobalExceptionHandler bắt lỗi, trả về danh sách field error. |
| Server Validate | Mã màu hoặc tagline vượt quá độ dài | 400 | `VALIDATION_ERROR` | Báo lỗi trường `brandColor` hoặc `tagline`. |
| Xác thực phiên | Không có Token hoặc Token hết hạn | 401 | `UNAUTHORIZED` | Chuyển hướng về `/login`, hiển thị toast MSG22. |
| Database Write | Lỗi lưu Workspace hoặc gán Member | 500 | `INTERNAL_SERVER_ERROR` | Transaction tự động rollback toàn bộ, không tạo Agency mồ côi. |

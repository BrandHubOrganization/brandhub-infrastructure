# 3.4.3.B Đặc Tả Nghiệp Vụ: Tạo Agency Hỗ Trợ Chế Độ Cá Nhân (Create Agency — Personal & Business Mode)

## Function Trigger
Người dùng đã đăng nhập nhấn mở màn hình Tạo Agency (`/agency/create`) từ thanh điều hướng, từ danh sách Agency, hoặc từ trạng thái rỗng (Empty State) khi chưa có tổ chức nào.

---

## Function Description
- **Actors / Roles**: Người dùng đã đăng nhập (Authenticated User). Khi hoàn tất, người dùng trở thành `Owner` của Agency và `Manager` của Workspace cá nhân (nếu chọn chế độ cá nhân).
- **Mục đích**: 
  1. Cho phép người dùng lựa chọn mục đích sử dụng tổ chức: **Cá nhân (`PERSONAL`)** hoặc **Doanh nghiệp (`BUSINESS`)**.
  2. Đối với chế độ **Cá nhân**: Tự động sinh không gian làm việc (`Workspace`) cá nhân trong cùng một giao dịch và đưa người dùng vào sử dụng ngay (viết bài, đăng bài, quản lý kênh) mà không bị cản trở bởi các nghiệp vụ quản lý khách hàng (Client Management) hay phân quyền phức tạp.
  3. Đối với chế độ **Doanh nghiệp**: Giữ nguyên luồng chuẩn của Agency truyền thống để quản lý đội ngũ, khách hàng và gửi duyệt bài viết.
- **Giao diện**: Màn hình Tạo Agency (`/agency/create`) bao gồm:
  - Khối chọn mục đích sử dụng (Segmented Cards: Cá nhân vs Doanh nghiệp).
  - Tên thương hiệu / Tổ chức (bắt buộc).
  - Lĩnh vực hoạt động (`category`), Màu sắc thương hiệu (`brandColor`), Tagline, Mô tả ngắn.
  - Logo (chọn Icon hoặc tải ảnh), Banner (chọn Preset hoặc tải ảnh).
  - Liên kết mạng xã hội (Facebook, Instagram, LinkedIn).
  - *Khi chọn Cá nhân*: Ẩn các trường quy mô doanh nghiệp (`companySize`), mã số thuế, và các trường phức tạp khác.
- **Xử lý dữ liệu (Data Processing)**:
  - Hệ thống kiểm tra tính hợp lệ của dữ liệu đầu vào.
  - Lưu bản ghi `Agency` mới với `type = 'PERSONAL'` hoặc `'BUSINESS'`, `status = 'ACTIVE'`, người tạo là `owner_id`.
  - Lưu bản ghi `AgencyMember` với `role = 'OWNER'`.
  - **Nếu là `PERSONAL`**:
    - Hệ thống tự động tạo 1 bản ghi `Workspace` mới thuộc Agency này với cùng tên, nhận diện thương hiệu (logo, brandColor, tagline, category).
    - Lưu bản ghi `WorkspaceMember` cho người dùng hiện tại với `role = 'MANAGER'`, `is_active = TRUE`.
    - Trả về `defaultWorkspaceId` trong payload phản hồi để Frontend điều hướng trực tiếp vào Workspace.

---

## Screen Layout (Bố Cục Màn Hình Chi Tiết)

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│  ← Quay lại danh sách                                                                 │
│                                                                                        │
│  TẠO KHÔNG GIAN THƯƠNG HIỆU CỦA BẠN                                                   │
│  Thiết lập không gian để sáng tạo nội dung, quản lý kênh và kết nối đối tượng          │
│                                                                                        │
│  1. CHỌN MỤC ĐÍCH SỬ DỤNG (Bắt buộc)                                                   │
│  ┌──────────────────────────────────────┐    ┌──────────────────────────────────────┐  │
│  │ (*) 👤 SỬ DỤNG CHO CÁ NHÂN           │    │ ( ) 🏢 SỬ DỤNG CHO DOANH NGHIỆP      │  │
│  │ Dành cho Solo Creator, Freelancer    │    │ Dành cho Agency & Đội nhóm           │  │
│  │ • Tự viết và đăng bài cho chính mình │    │ • Quản lý nhiều khách hàng (Clients) │  │
│  │ • Bỏ qua bước duyệt bài khách hàng   │    │ • Phân quyền thành viên & Manager    │  │
│  │ • Vào làm việc ngay lập tức          │    │ • Cổng duyệt bài riêng cho Client    │  │
│  └──────────────────────────────────────┘    └──────────────────────────────────────┘  │
│                                                                                        │
│  2. THÔNG TIN THƯƠNG HIỆU                                                             │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │ Tên thương hiệu cá nhân / Kênh của bạn (*): [ Trí Nguyễn Tech                 ]  │  │
│  │ Lĩnh vực hoạt động:                         [ Công nghệ & Marketing         ▼ ]  │  │
│  │ Khẩu hiệu (Tagline):                        [ Sáng tạo nội dung tinh gọn      ]  │  │
│  │ Mô tả ngắn:                                 [ Kênh chia sẻ kiến thức...       ]  │  │
│  └──────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                        │
│  3. NHẬN DIỆN HÌNH ẢNH (BRANDING)                                                      │
│  ┌────────────────────────────────────────┬─────────────────────────────────────────┐  │
│  │ LOGO / AVATAR                          │ BANNER THƯƠNG HIỆU                      │  │
│  │ [ Icon ]  [ Tải ảnh ]  [ URL ]         │ [ Mẫu có sẵn ]  [ Tải ảnh ]  [ URL ]    │  │
│  │ Màu chủ đạo: [ #f05a28 ■ ]             │                                         │  │
│  └────────────────────────────────────────┴─────────────────────────────────────────┘  │
│                                                                                        │
│  4. LIÊN KẾT MẠNG XÃ HỘI (Tùy chọn)                                                   │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │ Fanpage Facebook: [ https://facebook.com/tringuyentech                         ]  │  │
│  │ Instagram:        [ https://instagram.com/tringuyentech                        ]  │  │
│  └──────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                        │
│                       [ Hủy bỏ ]    [ Bắt đầu sáng tạo ngay ✨ ]                       │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Function Details (Chi Tiết Chức Năng)

### Data Specifications (Đặc Tả Dữ Liệu)
* **Input bắt buộc**:
  * `name`: Tên thương hiệu/Agency (String, 1 - 255 ký tự, không được để trống).
  * `type`: Loại hình tổ chức (`AgencyType`: `PERSONAL` hoặc `BUSINESS`).
* **Input tùy chọn**:
  * `category`: Lĩnh vực hoạt động (`AgencyCategory`).
  * `companySize`: Quy mô công ty (`CompanySize` — chỉ hiển thị/áp dụng khi `type == BUSINESS`).
  * `description`: Mô tả giới thiệu (Text).
  * `brandColor`: Mã màu HEX (tối đa 9 ký tự, mặc định `#f05a28`).
  * `logoIcon`: Tên icon biểu trưng Lucide (khi chọn logo icon).
  * `logoUrl`: Đường dẫn ảnh đại diện.
  * `bannerUrl`: Đường dẫn ảnh bìa.
  * `tagline`: Khẩu hiệu (tối đa 140 ký tự).
  * `foundedYear`: Năm thành lập (Số nguyên dương).
  * `website`, `phone`, `location`: Thông tin liên hệ.
  * `facebookUrl`, `linkedinUrl`, `instagramUrl`: Đường dẫn mạng xã hội.
* **System Data Generated**:
  * Bản ghi `agencies`: `id` (UUID), `owner_id`, `type`, `status = ACTIVE`, `created_at`, `updated_at`.
  * Bản ghi `agency_members`: `id`, `agency_id`, `user_id`, `role = OWNER`, `joined_at`.
  * *(Nếu là PERSONAL)* Bản ghi `workspaces`: `id`, `agency_id`, `name`, `created_by`, `settings`, `brand_color`, `logo_icon`, `logo_url`, `banner_url`, `timezone_config = 'Asia/Ho_Chi_Minh'`, `status = ACTIVE`.
  * *(Nếu là PERSONAL)* Bản ghi `workspace_members`: `workspace_id`, `user_id`, `role = MANAGER`, `is_active = TRUE`.
* **Output**:
  * DTO `AgencyResponse` mang đầy đủ thông tin Agency vừa tạo + `defaultWorkspaceId` (nếu có).

### Business Rules (Quy Tắc Nghiệp Vụ)
* **BR-AGENCY-01**: Tên Agency/Thương hiệu không được để trống (bỏ qua khoảng trắng đầu cuối). Nếu trống báo lỗi `400 VALIDATION_ERROR` (Mã MSG02).
* **BR-AGENCY-02**: Mã màu `brandColor` không vượt quá 9 ký tự, `tagline` không vượt quá 140 ký tự. Nếu vượt quá báo lỗi `400 VALIDATION_ERROR` (Mã MSG03).
* **BR-AGENCY-03 (Auto-provisioning)**: Nếu `type == PERSONAL`, hệ thống **bắt buộc** phải tạo song song 1 Workspace mặc định và gán người dùng là `MANAGER`. Toàn bộ thao tác chạy trong 1 Database Transaction duy nhất. Nếu việc tạo Workspace thất bại, hủy toàn bộ giao dịch (Rollback).
* **BR-AGENCY-04 (Immediate Navigation)**: Khi nhận phản hồi thành công với Agency loại `PERSONAL`, Frontend phải cập nhật `activeWorkspace` và điều hướng người dùng thẳng vào `/workspaces/{defaultWorkspaceId}/dashboard`, không đưa về trang cài đặt Agency rỗng.
* **BR-AGENCY-05 (Personal Workspace Boundary)**: Khi làm việc trong Workspace thuộc Agency loại `PERSONAL`:
  * Ẩn các tính năng: Quản lý khách hàng (`/clients`), Hồ sơ khách hàng (`/client-profiles`), Cổng khách hàng (`/portal`), Lời mời (`/client/invitations`), Phân quyền (`/agency/:id/roles`).
  * Bỏ khâu phê duyệt `PENDING_CLIENT_APPROVAL` trong quy trình viết bài và xuất bản.

---

## Functionalities (Các Kịch Bản Luồng Chức Năng)

### Normal Flow 1: Tạo Agency Cá nhân (Personal Mode)
1. Người dùng mở trang `/agency/create`.
2. Hệ thống mặc định chọn mục đích sử dụng là **"Cá nhân" (`PERSONAL`)**. Form tự động ẩn trường quy mô nhân sự `companySize`.
3. Người dùng nhập tên thương hiệu, chọn màu sắc và logo/banner mong muốn.
4. Người dùng bấm **"Bắt đầu sáng tạo ngay ✨"**.
5. Client gửi `POST /api/v1/agencies` kèm `type = "PERSONAL"`.
6. Server xác thực dữ liệu thành công.
7. Server lưu `agencies`, lưu `agency_members` (`OWNER`), tạo `workspaces` cá nhân, tạo `workspace_members` (`MANAGER`).
8. Server trả về HTTP 201 với `defaultWorkspaceId`.
9. Client nhận kết quả, hiển thị thông báo thành công (MSG31).
10. Client lưu thông tin vào `agencyStore` và `workspaceStore`, sau đó chuyển hướng người dùng thẳng tới `/workspaces/{defaultWorkspaceId}/dashboard`.

### Normal Flow 2: Tạo Agency Doanh nghiệp (Business Mode)
1. Người dùng mở trang `/agency/create` và chọn **"Doanh nghiệp" (`BUSINESS`)**.
2. Form hiển thị đầy đủ các trường: Tên công ty, Lĩnh vực, Quy mô nhân sự (`companySize`), Website, Thông tin liên hệ.
3. Người dùng nhập dữ liệu và bấm **"Tạo Agency"**.
4. Client gửi `POST /api/v1/agencies` kèm `type = "BUSINESS"`.
5. Server lưu `agencies` và `agency_members` (`OWNER`), không tự động tạo Workspace.
6. Server trả về HTTP 201 (`defaultWorkspaceId = null`).
7. Client chuyển hướng người dùng về trang chi tiết `/agency/{agencyId}` như luồng truyền thống.

### Abnormal Cases (Các Trường Hợp Lỗi)
- **3.a1 (Tên để trống)**: Người dùng xóa trống tên → Hệ thống hiển thị cảnh báo đỏ tại input "Tên không được để trống" (MSG02), không gửi request.
- **5.a1 (Hết phiên đăng nhập)**: Token JWT hết hạn khi gửi request → Server trả về `401 UNAUTHORIZED`. Client xóa phiên và chuyển hướng về màn hình đăng nhập (MSG22).
- **7.a1 (Lỗi lưu cơ sở dữ liệu)**: Database timeout hoặc lỗi ràng buộc khi lưu Workspace → Server ném ngoại lệ và Rollback toàn bộ transaction. Server trả về `500 INTERNAL_SERVER_ERROR`. Client hiển thị toast lỗi (MSG01), không có dữ liệu rác nào được lưu lại.

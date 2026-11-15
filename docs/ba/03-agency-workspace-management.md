# 03 — Quản trị Công ty, Không gian làm việc & Chế độ Cá nhân (Agency, Workspace & Personal Studio)

> [<< 02 - Authentication & Profile](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/02-authentication-profile.md) | [Overview](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/00-overview.md) | [Tiếp: 04 - Media Package & Campaign >>](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/04-media-package-campaign.md)
>
> **Phạm vi FR chuẩn**: **Mục `3.4 Agency & Workspace` — 26 FR (`3.4.1` – `3.4.26`)** | `UC-014` – `UC-039`.
> Kết hợp kiến trúc **Hybrid Personal Studio + Solo Workspace Mode (`workspaceMode = "PERSONAL" | "AGENCY"`)** theo `docs/feature/personal-workspace-mode/spec.md`.

---

## 1. Bảng Tổng hợp 26 Yêu cầu Chức năng Chuẩn (`3.4.1` – `3.4.26`)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (Atomic CRUD FR) | Actors / Roles Chuẩn | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :--- |
| **`3.4.1`** | `UC-014` | **Create Agency** | `Owner` | Tạo mới một Công ty truyền thông (`Agency`) hoặc tự động khởi tạo `Personal Hub` (`isPersonalHub`) khi dùng chế độ cá nhân; người tạo trở thành `Owner`. |
| **`3.4.2`** | `UC-015` | **View Agency List** | `Owner`, `Manager`, `Creator` | Xem danh sách các `Agency` mà người dùng sở hữu hoặc đang là thành viên chính thức. |
| **`3.4.3`** | `UC-016` | **View Agency Detail** | `Owner`, `Manager`, `Creator` | Xem thông tin tổng quan, hồ sơ thương hiệu công ty, số liệu thống kê và gói cước của `Agency`. |
| **`3.4.4`** | `UC-017` | **Update Agency Profile** | `Owner` | Cập nhật thông tin hồ sơ công ty (Tên, Logo, Tagline, Quy mô, Lĩnh vực, Mã số thuế, Địa chỉ, Website, Thông tin liên hệ). |
| **`3.4.5`** | `UC-018` | **Delete Agency** | `Owner` | Xóa mềm (`soft-delete`) một `Agency` khi không còn chiến dịch/hóa đơn treo. |
| **`3.4.6`** | `UC-019` | **View Agency Members** | `Owner`, `Manager`, `Creator` | Xem danh sách thành viên thuộc `Agency` và danh sách các lời mời đang chờ phản hồi (`PENDING`). |
| **`3.4.7`** | `UC-020` | **View Agency Organization Chart** | `Owner`, `Manager`, `Creator` | Xem sơ đồ tổ chức trực quan (cây phân cấp `Owner → Workspaces → Manager & Creators`) của toàn bộ `Agency`. |
| **`3.4.8`** | `UC-021` | **Invite Agency Member** | `Owner` | Gửi lời mời tham gia `Agency` qua email (hỗ trợ chọn ngôn ngữ email `vi`/`en`, mẫu email, lời nhắn cá nhân, xem trước trực tiếp bản mẫu email mời và tùy chọn gán thẳng vào `Workspace` + `WorkspaceRole`). |
| **`3.4.9`** | `UC-022` | **Accept Agency Invitation** | `Owner`, `Manager`, `Creator`, `Client` | Chấp nhận lời mời tham gia `Agency` (và tự động gia nhập `Workspace` nếu lời mời có gán sẵn Workspace). |
| **`3.4.10`** | `UC-023` | **Decline Agency Invitation** | `Owner`, `Manager`, `Creator`, `Client` | Từ chối lời mời tham gia `Agency`; cập nhật trạng thái lời mời thành `DECLINED`. |
| **`3.4.11`** | `UC-024` | **Remove Agency Member** | `Owner` | Gỡ một thành viên ra khỏi `Agency` và thu hồi quyền truy cập của người đó tại các `Workspace` trực thuộc. |
| **`3.4.12`** | `UC-025` | **List Workspace** | `Owner`, `Manager`, `Creator`, `Client` | Xem danh sách các `Workspace` được phép truy cập (hiển thị rõ badge chế độ **`Agency`** hoặc **`Cá nhân / Personal`**). |
| **`3.4.13`** | `UC-026` | **Create Workspace** | `Owner` | Tạo mới một `Workspace` thuộc `Agency` với chế độ `workspaceMode = "AGENCY"` (dành cho khách hàng B2B) hoặc `workspaceMode = "PERSONAL"` (dành cho dự án cá nhân / nhóm nhỏ, tự động gán `Owner` làm `Manager`). |
| **`3.4.14`** | `UC-027` | **View Workspace Dashboard** | `Owner`, `Manager`, `Creator`, `Client` | Xem Bảng điều khiển tổng quan của `Workspace` (ở chế độ `PERSONAL`, hiển thị **Bệ phóng Sáng tạo Cá nhân — Personal Quick Launchpad** thay vì cảnh báo thiếu Gói dịch vụ). |
| **`3.4.15`** | `UC-028` | **Update Workspace** | `Owner`, `Manager` | Cập nhật thông tin cấu hình `Workspace` (Tên, Thương hiệu, Múi giờ, Mô tả) và **chuyển đổi chế độ `workspaceMode` giữa `PERSONAL` và `AGENCY`**. |
| **`3.4.16`** | `UC-029` | **Delete Workspace** | `Owner` | Xóa mềm (`soft-delete`) một `Workspace` khỏi hệ thống. |
| **`3.4.17`** | `UC-030` | **Archive Workspace** | `Owner`, `Manager` | Lưu trữ (`ARCHIVE`) một `Workspace` đã kết thúc dự án để chuyển sang chế độ chỉ-đọc. |
| **`3.4.18`** | `UC-031` | **Restore Workspace** | `Owner`, `Manager` | Khôi phục (`RESTORE`) một `Workspace` từ trạng thái `ARCHIVED` về lại `ACTIVE`. |
| **`3.4.19`** | `UC-032` | **Save Workspace Template** | `Owner`, `Manager` | Lưu cấu hình của một `Workspace` hiện tại thành mẫu (`Workspace Template`) để tái sử dụng cho các dự án tương tự. |
| **`3.4.20`** | `UC-033` | **View Workspace Templates** | `Owner`, `Manager` | Xem danh sách các mẫu `Workspace Template` đã lưu của `Agency`. |
| **`3.4.21`** | `UC-034` | **Apply Workspace Template** | `Owner`, `Manager` | Áp dụng một mẫu `Workspace Template` khi khởi tạo hoặc thiết lập nhanh `Workspace` mới. |
| **`3.4.22`** | `UC-035` | **Delete Workspace Template** | `Owner`, `Manager` | Xóa một mẫu `Workspace Template` không còn sử dụng. |
| **`3.4.23`** | `UC-036` | **View Workspace Members** | `Owner`, `Manager`, `Creator`, `Client` | Xem danh sách thành viên trong `Workspace` cùng vai trò cụ thể (`Manager`, `Creator`, `Client`). |
| **`3.4.24`** | `UC-037` | **Add Workspace Member** | `Owner`, `Manager` | Thêm nhân sự từ `Agency` (với vai trò `Manager` / `Creator`) hoặc mời khách hàng (`Client` ở chế độ `AGENCY`) vào `Workspace`. |
| **`3.4.25`** | `UC-038` | **Update Workspace Member Role** | `Owner`, `Manager` | Thay đổi vai trò của thành viên trong `Workspace` (ví dụ nâng `Creator` lên `Manager` hoặc chuyển quyền quản lý). |
| **`3.4.26`** | `UC-039` | **Remove Workspace Member** | `Owner`, `Manager` | Gỡ một thành viên ra khỏi `Workspace` (không được gỡ `Manager` duy nhất còn lại của Workspace). |

---

## 2. Đặc tả Nghiệp vụ Quản trị Agency (`3.4.1` – `3.4.11`)

### 2.1. Vòng đời Công ty (`Create / View / Update / Delete Agency` — `3.4.1`..`3.4.5`)
- **Tạo Agency B2B (`3.4.1`)**:
  - Người dùng nhập Tên công ty (`name`, bắt buộc), Quy mô (`companySize`), Lĩnh vực (`category`), Tagline, Website, Địa chỉ.
  - Hệ thống tạo bản ghi `Agency` với `ownerId = currentUser.id`, thêm bản ghi `AgencyMember` (`status = ACTIVE`), khởi tạo gói cước mặc định (`Basic`) và ví AI Credit (`agency_credit_wallets`).
- **Tự động khởi tạo `Personal Hub Agency` (Luồng Bootstrap Cá nhân)**:
  - Khi người dùng cá nhân bấm **"Không gian Cá nhân (Personal Studio)"** (`POST /api/v1/workspaces/personal/bootstrap`), hệ thống tự động tạo ngầm một `Agency` cá nhân (`logoIcon = "personal-studio"`, `name = "Personal Studio — " + displayName`) nếu chưa có. Người dùng giữ vai trò `Owner` của `Personal Hub` này và được hưởng đầy đủ cơ chế Ví AI Credit + Gói cước mà không phải điền form thành lập công ty.
- **Xem Danh sách, Chi tiết & Sơ đồ Tổ chức (`3.4.2`, `3.4.3`, `3.4.7`)**:
  - Trang `/agency/members` hỗ trợ 2 chế độ hiển thị: **Dạng danh sách (`3.4.6`)** và **Sơ đồ tổ chức trực quan (`3.4.7`)** thể hiện cấu trúc phân cấp từ `Owner` xuống từng `Workspace`, `Manager` và các `Creator`.

### 2.2. Luồng Lời mời Thành viên Công ty (`3.4.8` – `3.4.11`)
- **Gửi lời mời (`3.4.8 Invite Agency Member`)**:
  - Chỉ `Owner` thực hiện.
  - Hỗ trợ:
    1. Nhập email người nhận (kiểm tra không trùng thành viên đang `ACTIVE` hoặc lời mời `PENDING` còn hạn).
    2. Chọn ngôn ngữ email mời (`Tiếng Việt` hoặc `English`) — có khung **Xem trước trực tiếp (Live Email Preview)** tự động co giãn chiều cao chuẩn xác, không bị cắt nội dung.
    3. Nhập lời nhắn cá nhân hóa hoặc chọn từ mẫu email của công ty, đặt hạn hiệu lực lời mời (mặc định 7–30 ngày).
    4. Tùy chọn gán trước `Workspace` và vai trò trong Workspace (`Manager` hoặc `Creator`).
- **Chấp nhận / Từ chối lời mời (`3.4.9 Accept` & `3.4.10 Decline`)**:
  - Người nhận mở link từ email hoặc xem thông báo lời mời trong ứng dụng:
    - Nếu chọn **Chấp nhận (`3.4.9`)**: cập nhật lời mời sang `ACCEPTED`, kích hoạt `AgencyMember` (`status = ACTIVE`), và nếu lời mời có gán sẵn `Workspace` thì tự động thêm bản ghi `WorkspaceMember` tương ứng.
    - Nếu chọn **Từ chối (`3.4.10`)**: cập nhật lời mời sang `DECLINED`.
- **Gỡ thành viên khỏi Agency (`3.4.11 Remove Agency Member`)**:
  - `Owner` có thể gỡ thành viên khỏi Agency (không thể tự gỡ chính `Owner`). Khi bị gỡ khỏi Agency, thành viên cũng bị thu hồi quyền truy cập tại các Workspace thuộc Agency đó (trừ khi họ đang là `Manager` duy nhất của một Workspace đang chạy — hệ thống yêu cầu chuyển giao `Manager` trước).

---

## 3. Đặc tả Nghiệp vụ Quản trị Workspace & Chế độ `PERSONAL | AGENCY` (`3.4.12` – `3.4.26`)

### 3.1. Phân loại Chế độ `workspaceMode` (`AGENCY` vs `PERSONAL`)
Mỗi bản ghi `Workspace` lưu thuộc tính `"workspaceMode"` bên trong cột JSONB `workspaces.settings`:
- **`"AGENCY"` (Mặc định cho toàn bộ Workspace hiện có — AC2)**:
  - Phục vụ mô hình công ty truyền thông làm việc với khách hàng thương hiệu (`Client`).
  - Yêu cầu chỉ định `Manager` khi tạo, hiển thị đầy đủ 3 bước tiến trình (`1. Gói dịch vụ → 2. Chiến dịch → 3. Công việc`), Cổng Khách hàng (`Client Portal`) và phê duyệt 2 cấp.
- **`"PERSONAL"` (Chế độ Không gian Cá nhân & Nhóm nhỏ)**:
  - Phục vụ nhà sáng tạo độc lập (Solo Creator), Freelancer, Sinh viên làm đồ án/bài tập nhóm, Chủ shop nhỏ.
  - Khi tạo Workspace với `workspaceMode = "PERSONAL"`, nếu không truyền `managerId`, hệ thống **tự động gán chính người tạo (`Owner`) làm `Manager`** của Workspace đó (AC3).
  - Bỏ qua bước `1. Gói dịch vụ`, không yêu cầu có `Client`, mở khóa tạo Chiến dịch tự do và Tạo Công việc độc lập đủ 8 loại `TaskType`, kèm nút **Tự duyệt 1 chạm (`Self-Approve`)**.

### 3.2. Chuyển đổi Chế độ `PERSONAL ↔ AGENCY` (`3.4.15 Update Workspace`)
- **Nâng cấp từ `PERSONAL` → `AGENCY` (Scale-Up — AC4)**:
  - Khi dự án cá nhân hoặc nhóm nhỏ phát triển thành dự án có khách hàng (`Client`), `Owner` hoặc `Manager` vào trang Cài đặt Workspace (`/workspaces/:id/settings`) và bấm **"Nâng cấp sang chế độ Agency"**.
  - Hệ thống cập nhật `settings.workspaceMode = "AGENCY"`. Toàn bộ Chiến dịch, Công việc, Bài viết, Thư viện tư liệu, Lịch sử AI và Tài khoản MXH được **giữ nguyên 100%**. Giao diện lập tức mở khóa bước `1. Gói dịch vụ` và cho phép mời `Client` vào `Client Portal`.
- **Chuyển từ `AGENCY` → `PERSONAL` (Simplify — AC5)**:
  - Chỉ được phép thực hiện khi trong Workspace hiện **không có thành viên nào giữ vai trò `Client` đang `ACTIVE`** và không có Công việc/Phần nào đang chờ `Client` duyệt. Nếu đang có `Client` hoạt động, Backend từ chối với mã lỗi `WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT` (`409 Conflict`).

### 3.3. Lưu trữ, Khôi phục & Mẫu Không gian (`3.4.17` – `3.4.22`)
- **Lưu trữ & Khôi phục (`3.4.17 Archive` & `3.4.18 Restore`)**:
  - `Owner` hoặc `Manager` có thể chuyển Workspace đã hoàn thành sang trạng thái `ARCHIVED` (mọi dữ liệu chuyển sang chỉ-đọc, dừng các job đăng bài tự động). Khi cần tiếp tục làm việc, gọi `Restore (3.4.18)` để đưa Workspace về `ACTIVE`.
- **Bộ Mẫu Không gian làm việc (`3.4.19 Save`, `3.4.20 View`, `3.4.21 Apply`, `3.4.22 Delete Workspace Template`)**:
  - Cho phép lưu cấu trúc thiết lập chuẩn của một Workspace (múi giờ, cấu hình quy trình, danh mục mẫu) thành `Workspace Template` để áp dụng nhanh cho các dự án mới cùng ngành hàng.

### 3.4. Quản lý Thành viên trong Workspace (`3.4.23` – `3.4.26`)
- **Xem danh sách thành viên (`3.4.23`)**: Tất cả thành viên trong Workspace (`Owner`, `Manager`, `Creator`, `Client`) đều xem được danh sách thành viên của Workspace đó.
- **Thêm thành viên (`3.4.24`)**:
  - Trong chế độ `AGENCY`: `Owner`/`Manager` thêm nhân sự từ Agency vào làm `Manager` hoặc `Creator`, và mời khách hàng vào làm `Client` (mỗi Workspace `AGENCY` gắn với 1 thương hiệu khách hàng).
  - Trong chế độ `PERSONAL`: Chủ không gian (`Owner`/`Manager`) có thể làm việc 1 mình (Solo) hoặc mời thêm các bạn cùng nhóm / cộng tác viên vào với vai trò **`Creator`** để cùng thực hiện các `Subtask` theo vai trò mà không cần có `Client`.
- **Cập nhật vai trò (`3.4.25`) & Gỡ thành viên (`3.4.26`)**:
  - Đảm bảo quy tắc bất biến: **Mỗi Workspace đang hoạt động phải luôn có ít nhất 1 `Manager` (`ACTIVE`)**. Nếu muốn gỡ hoặc đổi vai trò của `Manager` duy nhất, phải chỉ định một `Manager` kế nhiệm trước.

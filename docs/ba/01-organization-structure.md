# 01 — Cấu trúc Tổ chức & Kiến trúc Không gian Lai (Organization Structure & Hybrid Workspace Architecture)

> [<< Về Overview](file:///D:/ProjectCode\BrandHub\brandhub-infrastructure\docs\ba\00-overview.md) | [Tiếp: 02 - Authentication & Profile >>](file:///D:/ProjectCode\BrandHub\brandhub-infrastructure\docs\ba\02-authentication-profile.md)

---

## 1. Kiến trúc Đa tầng Chuẩn (`User → Agency / Personal Hub → Workspace`)

BrandHub tổ chức dữ liệu và phân quyền theo mô hình đa thuê bao (multi-tenant) 3 tầng, hỗ trợ đồng thời cả **Công ty Truyền thông (`Agency B2B`)** và **Không gian Cá nhân (`Personal Studio`)** trên cùng một cấu trúc cơ sở dữ liệu:

```
┌────────────────────────────────────────────────────────────────────────────┐
│                      TẦNG 1: TÀI KHOẢN NGƯỜI DÙNG (USER)                   │
│  Mỗi tài khoản xác thực (Owner / Manager / Creator / Client / Admin)       │
│  có thể tham gia nhiều Agency và sở hữu 1 Personal Hub riêng biệt.         │
└───────────────────┬────────────────────────────────────┬───────────────────┘
                    │                                    │
                    ▼                                    ▼
┌───────────────────────────────────────┐  ┌─────────────────────────────────┐
│     TẦNG 2A: AGENCY B2B (CÔNG TY)     │  │  TẦNG 2B: PERSONAL HUB (STUDIO) │
│ • Đại diện cho 1 công ty truyền thông │  │ • Bản ghi Agency cá nhân tự tạo │
│ • Chủ sở hữu giữ vai trò: Owner       │  │   1 chạm (logoIcon =            │
│ • Có Ví AI Credit tổng & Gói cước     │  │   "personal-studio")            │
│ • Quản lý danh sách nhân sự công ty   │  │ • Chủ sở hữu giữ vai trò: Owner │
│   & danh mục Gói truyền thông mẫu     │  │ • Có sẵn Ví AI Credit & Gói     │
└───────────────────┬───────────────────┘  └────────────────┬────────────────┘
                    │                                       │
                    ▼                                       ▼
┌───────────────────────────────────────┐  ┌─────────────────────────────────┐
│ TẦNG 3A: WORKSPACE (mode = "AGENCY")  │  │ TẦNG 3B: WORKSPACE ("PERSONAL") │
│ • Đại diện cho 1 Thương hiệu Client   │  │ • Đại diện cho Dự án cá nhân,   │
│ • Bắt buộc có 1 Manager               │  │   Kênh MXH riêng hoặc Bài tập   │
│ • Có thể mời nhiều Creator & 1 Client │  │ • Chủ không gian là Manager     │
│ • Quy trình 3 bước:                   │  │ • Không cần MediaPackage/Client │
│   Gói dịch vụ → Chiến dịch → Task     │  │ • Tạo Chiến dịch tự do hoặc     │
│ • Phê duyệt 2 cấp:                    │  │   Tạo Task độc lập 8 loại       │
│   Manager/Supervisor → Client         │  │ • Tự duyệt 1 chạm (Self-Approve)│
└───────────────────────────────────────┘  └─────────────────────────────────┘
```

---

## 2. Định nghĩa 6 Vai trò Hệ thống Chuẩn (6 Canonical Roles)

Theo quy chuẩn bắt buộc tại `AGENTS.md`, toàn hệ thống **chỉ sử dụng đúng 6 tên Role chuẩn** dưới đây (không tồn tại các tên như `USER`, `MEMBER`, `Account Manager` hay `Brand Client`):

| Role chuẩn | Enum Code | Cấp định danh | Mô tả & Quyền hạn thực tế trong hệ thống |
| :--- | :--- | :--- | :--- |
| **`Guest`** | `GUEST` | Công khai (Chưa đăng nhập) | Người dùng chưa đăng nhập hoặc người truy cập qua đường dẫn chia sẻ công khai (`/s/:token`). Được phép đăng ký, đăng nhập, khôi phục mật khẩu, nộp phản hồi khảo sát công khai (`/public/surveys/:token`) và xem chỉ-đọc tài nguyên được chia sẻ qua `ShareLink`. |
| **`Owner`** | `OWNER` | Cấp `Agency` (`agencies.owner_id`) | Người sáng lập / chủ sở hữu của một `Agency` (hoặc chủ sở hữu `Personal Hub` cá nhân). Toàn quyền cập nhật hồ sơ công ty, mời/gỡ thành viên công ty, tạo/xóa/lưu trữ `Workspace`, cấu hình trần AI Credit cho từng `Workspace` (`workspaceLimit`), nâng cấp gói cước (`Subscription`), thanh toán qua SePay và tạo Gói truyền thông mẫu (`MediaPackage`). |
| **`Manager`** | `MANAGER` | Cấp `Workspace` (`workspace_members`) | Người điều hành trực tiếp một `Workspace`. Mỗi Workspace luôn có ít nhất 1 `Manager`. Trong Workspace `AGENCY`, `Manager` chốt Gói dịch vụ, lập & triển khai Chiến dịch, phân công Công việc/Subtask, duyệt nội bộ các phần (`INTERNAL_APPROVED`), quản lý tư liệu, gửi bản tin và kết nối MXH. Trong Workspace `PERSONAL`, chủ không gian giữ đồng thời vai trò `Owner` và `Manager`, có thêm quyền **Tự duyệt 1 chạm (`Self-Approve`)**. |
| **`Creator`** | `CREATOR` | Cấp `Workspace` (`workspace_members`) | Thành viên thực thi sáng tạo trong `Workspace` (nhân sự nội bộ của Agency hoặc bạn cùng nhóm được mời vào Workspace `PERSONAL`). Được giao `Task` cha (với tư cách Điều phối viên) hoặc `Subtask` theo vai trò chuyên môn (`POST_CONTENT`, `POST_MEDIA`, `VIDEO_SCRIPT`, `EVENT_AGENDA`...), sử dụng AI Studio để tạo nội dung và nộp duyệt từng phần (`TaskSection`). |
| **`Client`** | `CLIENT` | Cấp `Workspace` (`workspace_members`) | Khách hàng thương hiệu trong Workspace có `workspaceMode = "AGENCY"`. Truy cập `Client Portal` để xem tiến độ, tạo yêu cầu nội dung (`Content Request`), kết nối tài khoản MXH của thương hiệu, và duyệt/trả lại các phần sản phẩm đầu ra (`OUTPUT` sections → `CLIENT_APPROVED`). Không xuất hiện trong Workspace `PERSONAL`. |
| **`Admin`** | `ADMIN` | Toàn hệ thống (`users.system_role`) | Quản trị viên vận hành nền tảng BrandHub (`/admin/*`). Quản lý danh sách người dùng, hàng đợi kiểm duyệt nội dung vi phạm (`Content Moderation Queue`), cấu hình gói cước & bảng giá AI Credit, điều khiển đường ống thu thập xu hướng (`Trend Crawler Pipeline`), theo dõi sức khỏe hệ thống và xuất báo cáo doanh thu. |

---

## 3. Quy tắc Đa Vai trò theo Ngữ cảnh (Contextual Multi-Role Rules)

Một tài khoản người dùng vật lý (`User`) có thể giữ các vai trò khác nhau tùy theo ngữ cảnh đang mở:

1. **Giữa các Agency khác nhau**:
   - Người dùng A có thể là **`Owner`** của `Personal Studio` cá nhân của mình, đồng thời là **`Creator`** hoặc **`Manager`** được mời vào `Agency X` (công ty nơi họ làm việc).
2. **Giữa các Workspace trong cùng một Agency**:
   - Nhân sự B thuộc `Agency X` có thể được bổ nhiệm làm **`Manager`** tại `Workspace 1` (dự án thương hiệu A), nhưng chỉ là **`Creator`** hỗ trợ viết bài tại `Workspace 2` (dự án thương hiệu B).
3. **Trong cùng một Workspace**:
   - Mỗi người dùng chỉ có **1 bản ghi vai trò (`WorkspaceRole`: `MANAGER`, `Creator`, hoặc `CLIENT`)** trong một `Workspace` cụ thể (`UNIQUE (workspace_id, user_id)`).
   - Riêng `Owner` của Agency chứa Workspace đó mặc định có quyền quản trị cấp cao trên mọi Workspace thuộc Agency của mình; khi tạo Workspace ở chế độ `PERSONAL`, `Owner` được gán trực tiếp làm `MANAGER` của Workspace đó.

---

## 4. So sánh Chi tiết Chế độ `AGENCY` và Chế độ `PERSONAL`

| Tiêu chí Nghiệp vụ | Chế độ `AGENCY` (`workspaceMode = "AGENCY"`) | Chế độ `PERSONAL` (`workspaceMode = "PERSONAL"`) |
| :--- | :--- | :--- |
| **Cách khởi tạo** | `Owner` tạo `Agency` → mời nhân sự → tạo `Workspace` → chọn `Manager` từ danh sách nhân sự. | Bấm 1 chạm **"Không gian Cá nhân (Personal Studio)"** (`POST /api/v1/workspaces/personal/bootstrap`) hoặc chọn chế độ `PERSONAL` khi tạo Workspace mới (tự gán bản thân làm `Manager`). |
| **Bước 1: Gói dịch vụ (`Media Package`)** | **Bắt buộc**: Phải gắn `WorkspaceMediaPackage` và chốt gói trước khi triển khai chiến dịch. | **Bỏ qua**: Ẩn khỏi thanh Tiến trình. Hệ thống tự cấp ngầm gói khung nội bộ không giới hạn nếu người dùng muốn lập Chiến dịch. |
| **Bước 2: Chiến dịch (`Media Campaign`)** | Khởi tạo từ các hạng mục trong Gói dịch vụ đã chốt; kiểm tra chặt số lượng hạng mục theo gói. | **Tùy chọn & Tự do**: Có thể lập Chiến dịch cá nhân với bất kỳ số lượng hạng mục nào thuộc 8 loại `TaskType`, hoặc bỏ qua để tạo Task trực tiếp. |
| **Bước 3: Tạo Công việc (`Task`)** | Sinh từ khi `deploy` Chiến dịch, từ `Content Request` của `Client`, hoặc do `Manager` tạo. | Hỗ trợ thêm nút **"+ Tạo công việc mới" (`Standalone Task`)** tạo trực tiếp đủ 8 loại `TaskType` ngay tại bảng Công việc hoặc từ `Personal Quick Launchpad`. |
| **Quy trình Phê duyệt (`Approval Flow`)** | Mặc định 2 cấp: `Creator` nộp → `Manager`/`Supervisor` duyệt nội bộ (`INTERNAL_APPROVED`) → `Client` duyệt đầu ra (`CLIENT_APPROVED`). | Mặc định `requiresClientApproval = false`. Hỗ trợ nút **Tự duyệt 1 chạm (`Self-Approve`)** đưa toàn bộ các phần sang `INTERNAL_APPROVED` và đóng Task `FINISHED` (`APPROVED`) tức thì. |
| **Cộng tác Nhóm (`Team Collaboration`)** | Đầy đủ `Owner`, `Manager`, nhiều `Creator` và `Client`. | Chủ không gian (`Owner`/`Manager`) có thể làm 1 mình (Solo) hoặc mời thêm bạn cùng nhóm làm **`Creator`** để chia `Subtask` theo vai trò (rất phù hợp cho nhóm đồ án sinh viên / nhóm freelancer). |
| **Thanh điều hướng (`Sidebar`) & `Dashboard`** | Hiển thị đầy đủ 3 bước tiến trình, `Cổng Khách hàng`, `Hồ sơ Khách hàng`, `Yêu cầu nội dung`, `PackageStatusBanner`. | Rút gọn còn 2 bước tiến trình luôn mở sẵn; ẩn các menu của `Client`; hiển thị **Bệ phóng Sáng tạo Cá nhân (`Personal Quick Launchpad`)**. |
| **Chuyển đổi qua lại (`Mode Switching`)** | Có thể chuyển về `PERSONAL` nếu trong Workspace chưa có `Client` đang hoạt động (AC5). | Có thể bấm **"Nâng cấp sang chế độ Agency"** bất kỳ lúc nào trong Cài đặt mà **giữ nguyên 100% dữ liệu** (AC4). |

---

## 5. Quy tắc Chia sẻ Công khai cho `Guest` (`ShareLink` Architecture)

Ngoài các thành viên có tài khoản trong Workspace, hệ thống hỗ trợ chia sẻ chỉ-đọc (read-only) ra bên ngoài cho **`Guest`** thông qua thực thể `ShareLink` (`/s/:token`):
- Chỉ **`Owner`** và **`Manager`** của Workspace mới có quyền tạo hoặc thu hồi (`revoke`) đường dẫn chia sẻ công khai.
- Các loại tài nguyên hỗ trợ chia sẻ công khai:
  1. `MEDIA_PACKAGE` — Bảng đề xuất gói dịch vụ truyền thông.
  2. `POST` — Bản xem trước bài đăng mạng xã hội kèm hình ảnh/video.
  3. `DOCUMENT` / `FOLDER` — Tài liệu hoặc thư mục tư liệu trong Thư viện (`Material`).
- Ngoài ra, công việc loại `SURVEY` và `WORKSHOP` có đường dẫn biểu mẫu công khai riêng (`/public/surveys/:token`) để `Guest` gửi câu trả lời khảo sát hoặc đăng ký tham dự.

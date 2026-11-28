# UC 03 — Media Package & Media Campaign (`UC-040` – `UC-052`)

> [<< 02-agency-workspace.md](./02-agency-workspace.md) | [UC Index](./README.md) | [Domain BA Spec: 04-media-package-campaign.md](../04-media-package-campaign.md) | [04-content-task-workflow.md >>](./04-content-task-workflow.md)
>
> Đồng bộ chuẩn xác 1-đối-1 với `Các FR của hệ thống - Feature_Function Requirement.csv` và `AGENTS.md`. Chỉ sử dụng **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)**.

---

## 1. Bảng Tổng Hợp Use Cases (13 UCs)

| UC ID | Use Case Title | Canonical Actor(s) | Related FR | Business Rules |
| :-: | :--- | :--- | :-: | :--- |
| `UC-040` | Create Media Package | `Owner` | `3.5.1` | `BR-15, BR-25` |
| `UC-041` | View Template Media Package | `Owner`, `Manager`, `Client` | `3.5.2` | `BR-20, BR-25` |
| `UC-042` | Request Media Package | `Owner`, `Manager`, `Client` | `3.5.3` | `BR-25, BR-26` |
| `UC-043` | Approve Media Package | `Owner`, `Manager`, `Client` | `3.5.4` | `BR-26, BR-27` |
| `UC-044` | Create Media Campaign | `Owner`, `Manager` | `3.5.5` | `BR-22, BR-27, BR-28` |
| `UC-045` | View Media Campaign | `Owner`, `Manager`, `Creator`, `Client` | `3.5.6` | `BR-20, BR-27, BR-28` |
| `UC-046` | Update Media Campaign | `Owner`, `Manager`, `Client` | `3.5.7` | `BR-27, BR-28, BR-29, BR-30` |
| `UC-047` | Approve Media Campaign | `Owner`, `Manager`, `Client` | `3.5.8` | `BR-28, BR-29` |
| `UC-048` | Complete Media Campaign | `Owner`, `Manager` | `3.5.9` | `BR-30, BR-32` |
| `UC-049` | Create Content Request | `Owner`, `Manager`, `Client` | `3.5.10` | `BR-20, BR-31` |
| `UC-050` | Track Request Status | `Owner`, `Manager`, `Client` | `3.5.11` | `BR-31, BR-33` |
| `UC-051` | Update Request | `Owner`, `Manager`, `Client` | `3.5.12` | `BR-31, BR-32` |
| `UC-052` | Cancel Request | `Owner`, `Manager`, `Client` | `3.5.13` | `BR-31, BR-32` |

---

## UC-040 — Create Media Package

- **Related FR:** `3.5.1` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-25`
- **System Messages:** `MSG02, MSG03, MSG07, MSG31`
- **Specification & Flow:** Tạo gói dịch vụ truyền thông mẫu hoặc gói tùy chỉnh (Create Media Package — /workspaces/:id/packages). Hệ thống hỗ trợ các gói mẫu theo thời lượng (2 tuần, 3 tuần, 1 tháng...), theo ngân sách hoặc gói trọn gói theo KPI do Admin/Owner thiết lập sẵn; cho phép định nghĩa Tên gói, Thời lượng, Ngân sách dự kiến, Số lượng ấn phẩm/bài đăng cam kết theo từng nền tảng. Khi tạo Workspace bắt buộc phải gắn hoặc nhắc cấu hình Media Package làm cơ sở làm việc với Client (BR-25).

---

## UC-041 — View Template Media Package

- **Related FR:** `3.5.2` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-20, BR-25`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem danh sách và chi tiết các gói truyền thông mẫu (View Template Media Package — /workspaces/:id/packages). Giúp Client hình dung rõ quy mô triển khai, thời lượng thuê Agency, cơ cấu nhân sự và số lượng đầu mục công việc theo 3 nhóm hình thức: (1) Gói theo khung thời gian, (2) Gói theo ngân sách cố định, và (3) Gói ủy thác toàn diện theo KPI (BR-25).

---

## UC-042 — Request Media Package

- **Related FR:** `3.5.3` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-25, BR-26`
- **System Messages:** `MSG02, MSG03, MSG07, MSG31, MSG36`
- **Specification & Flow:** Đề xuất và đàm phán điều chỉnh gói truyền thông (Request Media Package — /workspaces/:id/packages/:packageId). Từ gói mẫu ban đầu, Client và Agency (Owner/Manager) trao đổi, đề xuất chỉnh sửa về mức giá, thời gian triển khai, số lượng bài đăng, sự kiện hoặc hình thức truyền thông qua từng vòng đàm phán cho đến khi hai bên thống nhất phương án cuối cùng (BR-26).

---

## UC-043 — Approve Media Package

- **Related FR:** `3.5.4` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-26, BR-27`
- **System Messages:** `MSG02, MSG03, MSG07, MSG31, MSG36`
- **Specification & Flow:** Phê duyệt chốt gói truyền thông (Approve Media Package — /workspaces/:id/packages/:packageId). Khi cả hai bên (Agency và Client) đồng thuận xác nhận toàn bộ các điều khoản, chi phí và hạng mục bàn giao của gói truyền thông, hệ thống khóa phiên bản gói ở trạng thái APPROVED làm căn cứ lập chiến dịch truyền thông chi tiết (BR-26).

---

## UC-044 — Create Media Campaign

- **Related FR:** `3.5.5` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-22, BR-27, BR-28`
- **System Messages:** `MSG02, MSG03, MSG07, MSG32, MSG36`
- **Specification & Flow:** Khởi tạo Kế hoạch Chiến dịch Truyền thông chi tiết dựa trên Media Package đã được phê duyệt (Create Media Campaign — /workspaces/:id/campaigns/new). Đóng vai trò là bản chiến lược thực thi chi tiết phù hợp với thương hiệu của Client: xác định mục tiêu chiến dịch, lộ trình thời gian (Start/End Date), danh sách các đầu mục bài viết dự kiến (tiêu đề, nền tảng đăng tải, định dạng, lịch dự kiến) (BR-27).

---

## UC-045 — View Media Campaign

- **Related FR:** `3.5.6` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-27, BR-28`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem chi tiết Kế hoạch Chiến dịch Truyền thông (View Media Campaign — /workspaces/:id/campaigns/:campaignId). Hiển thị thông tin tổng quan chiến dịch, gói truyền thông gốc, danh sách toàn bộ các hạng mục công việc dự kiến, lịch sử các phiên bản chỉnh sửa và luồng phản hồi giữa Agency với Client (BR-27).

---

## UC-046 — Update Media Campaign

- **Related FR:** `3.5.7` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-27, BR-28, BR-29, BR-30`
- **System Messages:** `MSG02, MSG07, MSG32, MSG36`
- **Specification & Flow:** Cập nhật nội dung Kế hoạch Chiến dịch Truyền thông và gửi phản hồi điều chỉnh trước khi phê duyệt chính thức (Update Media Campaign — /workspaces/:id/campaigns/:campaignId). Cho phép Agency chỉnh sửa danh sách hạng mục bài viết, mốc thời gian, kênh phân phối theo góp ý của Client khi chiến dịch đang ở trạng thái DRAFT hoặc PENDING_APPROVAL (BR-27).

---

## UC-047 — Approve Media Campaign

- **Related FR:** `3.5.8` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-28, BR-29`
- **System Messages:** `MSG02, MSG03, MSG07, MSG33, MSG36`
- **Specification & Flow:** Phê duyệt và kích hoạt triển khai Chiến dịch Truyền thông (Approve Media Campaign — /workspaces/:id/campaigns/:campaignId). Ngay khi cả hai bên đồng ý phê duyệt chiến lược, hệ thống chuyển trạng thái chiến dịch sang ACTIVE và tự động đẩy toàn bộ các hạng mục công việc trong Media Campaign vào bảng Task Backlog của Workspace (tương tự Jira Backlog) với tiêu đề và khung thời gian dự kiến để Manager tiếp tục phân rã chi tiết (BR-29).

---

## UC-048 — Complete Media Campaign

- **Related FR:** `3.5.9` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-30, BR-32`
- **System Messages:** `MSG02, MSG03, MSG07, MSG34, MSG36`
- **Specification & Flow:** Nghiệm thu và hoàn tất Chiến dịch Truyền thông (Complete Media Campaign — /workspaces/:id/campaigns/:campaignId). Chuyển trạng thái chiến dịch từ ACTIVE sang COMPLETED sau khi hoàn thành bàn giao, đồng thời hệ thống tự động hủy (CANCELLED) toàn bộ các yêu cầu phát sinh (Content Requests) còn đang treo ở trạng thái PENDING thuộc chiến dịch đó (BR-30).

---

## UC-049 — Create Content Request

- **Related FR:** `3.5.10` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-20, BR-31`
- **System Messages:** `MSG02, MSG03, MSG07, MSG35`
- **Specification & Flow:** Tạo yêu cầu nội dung bổ sung/phát sinh ngoài kế hoạch ban đầu (Create Content Request — /workspaces/:id/requests/new). Cho phép Client hoặc Manager gửi yêu cầu bài viết/sự kiện mới kèm tiêu đề, mô tả, nền tảng mong muốn, hạn chót và tệp đính kèm. Yêu cầu khởi tạo ở trạng thái PENDING để chờ Manager xem xét và ghi nhận làm căn cứ tính khối lượng công việc bổ sung (BR-31).

---

## UC-050 — Track Request Status

- **Related FR:** `3.5.11` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-31, BR-33`
- **System Messages:** `MSG02, MSG03, MSG07, MSG35, MSG36`
- **Specification & Flow:** Theo dõi và điều phối trạng thái của Yêu cầu nội dung (Track Request Status — /workspaces/:id/requests). Gồm 4 trạng thái chuẩn: PENDING -> IN_PROGRESS -> ACCEPTED (hoặc DENIED). Chỉ phía Agency (Manager/Owner) mới có quyền chuyển trạng thái xét duyệt; khi chuyển sang ACCEPTED, hệ thống tự động sinh một Task tương ứng đẩy vào danh sách Task Backlog của Workspace để phân công thực hiện (BR-31).

---

## UC-051 — Update Request

- **Related FR:** `3.5.12` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-31, BR-32`
- **System Messages:** `MSG02, MSG07, MSG35, MSG36`
- **Specification & Flow:** Chỉnh sửa nội dung của Yêu cầu phát sinh (Update Request — /workspaces/:id/requests/:requestId). Người tạo chỉ được phép cập nhật tiêu đề, mô tả, hạn mong muốn hoặc tệp tham khảo khi yêu cầu đang ở trạng thái PENDING; một khi Agency đã chuyển sang IN_PROGRESS, ACCEPTED hoặc DENIED thì nội dung yêu cầu bị khóa không cho sửa (BR-32).

---

## UC-052 — Cancel Request

- **Related FR:** `3.5.13` (3.5 Media Package & Media Campaign)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-31, BR-32`
- **System Messages:** `MSG02, MSG03, MSG07, MSG35, MSG36`
- **Specification & Flow:** Hủy yêu cầu nội dung phát sinh (Cancel Request — /workspaces/:id/requests/:requestId). Chỉ cho phép hủy yêu cầu khi đang ở trạng thái PENDING (chuyển trạng thái sang CANCELLED); các yêu cầu đã chuyển sang xử lý hoặc đã duyệt không được phép xóa/hủy (BR-32).

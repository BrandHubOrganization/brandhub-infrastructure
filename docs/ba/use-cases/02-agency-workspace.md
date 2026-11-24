# UC 02 — Agency & Workspace (`UC-014` – `UC-039`)

> [<< 01-authentication-profile.md](./01-authentication-profile.md) | [UC Index](./README.md) | [Domain BA Spec: 03-agency-workspace.md](../03-agency-workspace.md) | [03-media-package-campaign.md >>](./03-media-package-campaign.md)
>
> Đồng bộ chuẩn xác 1-đối-1 với `Các FR của hệ thống - Feature_Function Requirement.csv` và `AGENTS.md`. Chỉ sử dụng **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)**.

---

## 1. Bảng Tổng Hợp Use Cases (26 UCs)

| UC ID | Use Case Title | Canonical Actor(s) | Related FR | Business Rules |
| :-: | :--- | :--- | :-: | :--- |
| `UC-014` | List Agency | `Owner`, `Manager`, `Creator`, `Client`, `Admin` | `3.4.1` | `BR-15, BR-16` |
| `UC-015` | View Agency Dashboard | `Owner` | `3.4.2` | `BR-15, BR-20` |
| `UC-016` | Create Agency | `Owner`, `Manager`, `Creator` | `3.4.3` | `BR-12, BR-15, BR-58` |
| `UC-017` | View Agency Profile | `Owner`, `Manager`, `Creator`, `Client` | `3.4.4` | `BR-15` |
| `UC-018` | Update Agency Profile | `Owner` | `3.4.5` | `BR-12, BR-15` |
| `UC-019` | Remove Agency | `Owner` | `3.4.6` | `BR-15, BR-16` |
| `UC-020` | Invite Agency Member | `Owner` | `3.4.7` | `BR-01, BR-15, BR-17` |
| `UC-021` | View Agency Invitation Status | `Owner`, `Manager`, `Creator`, `Client` | `3.4.8` | `BR-17, BR-18` |
| `UC-022` | Accept Agency Invitation | `Owner`, `Manager`, `Creator`, `Client` | `3.4.9` | `BR-17, BR-18` |
| `UC-023` | Decline Agency Invitation | `Owner`, `Manager`, `Creator`, `Client` | `3.4.10` | `BR-17, BR-18` |
| `UC-024` | Remove Agency Member | `Owner` | `3.4.11` | `BR-15, BR-19, BR-21` |
| `UC-025` | List Workspace | `Owner`, `Manager`, `Creator`, `Client` | `3.4.12` | `BR-15, BR-20` |
| `UC-026` | View Workspace Dashboard | `Owner`, `Manager`, `Creator`, `Client` | `3.4.13` | `BR-20, BR-22` |
| `UC-027` | Create Workspace | `Owner` | `3.4.14` | `BR-12, BR-15, BR-21, BR-22, BR-58` |
| `UC-028` | View Workspace Profile | `Owner`, `Manager`, `Creator`, `Client` | `3.4.15` | `BR-20, BR-22` |
| `UC-029` | Update Workspace Profile | `Owner`, `Manager` | `3.4.16` | `BR-12, BR-15, BR-21, BR-22` |
| `UC-030` | Delete Workspace | `Owner` | `3.4.17` | `BR-15, BR-16` |
| `UC-031` | Leave Workspace | `Owner`, `Manager`, `Creator`, `Client` | `3.4.18` | `BR-21, BR-23` |
| `UC-032` | Save Workspace Template | `Owner` | `3.4.19` | `BR-15, BR-24` |
| `UC-033` | View Workspace Templates | `Owner` | `3.4.20` | `BR-15, BR-24` |
| `UC-034` | Apply Workspace Template | `Owner` | `3.4.21` | `BR-15, BR-22, BR-24` |
| `UC-035` | Delete Workspace Template | `Owner` | `3.4.22` | `BR-15, BR-24` |
| `UC-036` | View Workspace Members | `Owner`, `Manager`, `Creator`, `Client` | `3.4.23` | `BR-20, BR-21` |
| `UC-037` | Add Workspace Member | `Owner`, `Manager` | `3.4.24` | `BR-13, BR-15, BR-20, BR-21` |
| `UC-038` | Update Workspace Member Role | `Owner`, `Manager` | `3.4.25` | `BR-15, BR-21` |
| `UC-039` | Remove Workspace Member | `Owner`, `Manager` | `3.4.26` | `BR-19, BR-20, BR-21` |

---

## UC-014 — List Agency

- **Related FR:** `3.4.1` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`, `Admin`
- **Business Rules:** `BR-15, BR-16`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem danh sách toàn bộ các Agency mà người dùng đang sở hữu (tư cách Owner) hoặc đang tham gia làm thành viên chính thức trên màn hình Agency Directory (/agencies). Hỗ trợ tìm kiếm theo tên Agency, lọc theo vai trò (Owned / Joined) và hiển thị tóm tắt số lượng thành viên, số lượng Workspace đang hoạt động.

---

## UC-015 — View Agency Dashboard

- **Related FR:** `3.4.2` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-20`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36`
- **Specification & Flow:** Xem bảng điều khiển tổng quan của công ty (Agency Dashboard — /agency/:id/dashboard). Hiển thị các chỉ số KPI toàn Agency: tổng số Workspace đang hoạt động, số thành viên, tiến độ các chiến dịch truyền thông (Media Campaigns), hiệu suất hoàn thành công việc theo tuần/tháng, và mức tiêu thụ hạn mức gói cước / AI Credit.

---

## UC-016 — Create Agency

- **Related FR:** `3.4.3` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-12, BR-15, BR-58`
- **System Messages:** `MSG02, MSG03, MSG07, MSG22, MSG23`
- **Specification & Flow:** Khởi tạo một Agency mới trên màn hình Create Agency (/agencies/new). Người tạo bắt buộc nhập Tên công ty/Agency, Lĩnh vực hoạt động, Mô tả, Thông tin liên hệ và Logo (tùy chọn). Hệ thống kiểm tra giới hạn số lượng Agency theo gói đăng ký hiện tại (BR-58) và tự động gắn cứng owner_id của Agency với user_id của người khởi tạo duy nhất (vai trò OWNER, BR-15).

---

## UC-017 — View Agency Profile

- **Related FR:** `3.4.4` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-15`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36`
- **Specification & Flow:** Xem trang hồ sơ giới thiệu công ty (Agency Profile — /agency/:id/profile). Hiển thị thông tin đại diện chính thức của Agency (Tên công ty, Logo, Ảnh bìa, Giới thiệu năng lực, Lĩnh vực chuyên môn, Website, Email/Hotline liên hệ và các gói dịch vụ mẫu) để khách hàng (Client) tìm hiểu năng lực của Agency.

---

## UC-018 — Update Agency Profile

- **Related FR:** `3.4.5` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-12, BR-15`
- **System Messages:** `MSG02, MSG03, MSG07, MSG21, MSG22`
- **Specification & Flow:** Cập nhật thông tin hồ sơ công ty (Agency Profile — /agency/:id/settings). Chỉ chủ sở hữu (Owner) mới có quyền chỉnh sửa Tên Agency, Mô tả giới thiệu, Website, Địa chỉ, Thông tin liên hệ và tải lên Logo/Banner mới (BR-15, BR-15).

---

## UC-019 — Remove Agency

- **Related FR:** `3.4.6` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-16`
- **System Messages:** `MSG02, MSG03, MSG07, MSG24`
- **Specification & Flow:** Xóa mềm công ty (Remove Agency) tại màn hình Agency Settings (/agency/:id/settings) kèm hộp thoại xác nhận tên Agency. Hệ thống chỉ thực hiện xóa mềm (chuyển trạng thái sang INACTIVE/DELETED_PENDING) và lưu giữ toàn bộ dữ liệu để Owner có thể khôi phục lại trong vòng 30 ngày trước khi hết hạn lưu trữ (BR-16); tạm khóa quyền truy cập vào các Workspace trực thuộc trong thời gian bị xóa mềm.

---

## UC-020 — Invite Agency Member

- **Related FR:** `3.4.7` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-01, BR-15, BR-17`
- **System Messages:** `MSG02, MSG04, MSG07, MSG08, MSG25, MSG26`
- **Specification & Flow:** Mời thành viên mới gia nhập Agency thông qua địa chỉ Email và thông báo trên hệ thống (/agency/:id/members). Khi được mời vào cấp độ Agency, người dùng chỉ mang tư cách thành viên chung của công ty (Agency Member) chứ chưa gắn vai trò quản trị đặc thù (chỉ người sáng lập ban đầu mới có vai trò OWNER); lời mời tự động hết hạn sau 30 ngày (30 ngày, BR-17).

---

## UC-021 — View Agency Invitation Status

- **Related FR:** `3.4.8` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-17, BR-18`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Theo dõi danh sách và trạng thái các lời mời tham gia Agency (PENDING, ACCEPTED, DECLINED, EXPIRED) kèm thời gian đếm ngược hết hạn 30 ngày (30 ngày, BR-17). Cả người gửi lời mời (Owner) và người nhận lời mời đều có thể xem trạng thái; Owner có thể gửi lại (Resend) hoặc thu hồi lời mời đang ở trạng thái PENDING.

---

## UC-022 — Accept Agency Invitation

- **Related FR:** `3.4.9` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-17, BR-18`
- **System Messages:** `MSG02, MSG03, MSG07, MSG27, MSG28`
- **Specification & Flow:** Chấp nhận lời mời tham gia Agency từ thông báo trong ứng dụng hoặc liên kết trong email (/invitations/:token). Hệ thống kiểm tra lời mời còn ở trạng thái PENDING và chưa quá hạn 30 ngày (BR-17), chuyển trạng thái lời mời sang ACCEPTED và thêm người dùng vào danh sách thành viên chính thức của Agency.

---

## UC-023 — Decline Agency Invitation

- **Related FR:** `3.4.10` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-17, BR-18`
- **System Messages:** `MSG02, MSG03, MSG07, MSG27, MSG28`
- **Specification & Flow:** Từ chối lời mời tham gia Agency (/invitations/:token). Hệ thống kiểm tra lời mời đang ở trạng thái PENDING (BR-17), cập nhật trạng thái lời mời sang DECLINED và gửi thông báo phản hồi cho Owner.

---

## UC-024 — Remove Agency Member

- **Related FR:** `3.4.11` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-19, BR-21`
- **System Messages:** `MSG02, MSG03, MSG07, MSG29, MSG36`
- **Specification & Flow:** Xóa thành viên khỏi Agency (/agency/:id/members). Sau khi bị xóa, người dùng lập tức mất quyền truy cập vào Agency và toàn bộ các Workspace trực thuộc; tuy nhiên mọi tài nguyên, bài viết, tư liệu và lịch sử công việc mà người đó đã tạo ra vẫn được bảo toàn nguyên vẹn vì thuộc tài sản chung của Agency. Nếu sau này được mời quay lại, họ có thể tiếp tục sử dụng và chỉnh sửa các tài nguyên được phân quyền (BR-19).

---

## UC-025 — List Workspace

- **Related FR:** `3.4.12` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-15, BR-20`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem danh sách các Workspace trong Agency (/agency/:id/workspaces). Owner nhìn thấy toàn bộ tất cả các Workspace của công ty; các vai trò khác (Manager, Creator, Client) chỉ nhìn thấy các Workspace mà mình được gán làm thành viên (BR-20).

---

## UC-026 — View Workspace Dashboard

- **Related FR:** `3.4.13` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-22`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36`
- **Specification & Flow:** Xem bảng điều khiển tổng quan của từng Workspace (Workspace Dashboard — /workspaces/:id/dashboard). Hiển thị thống kê tiến độ công việc theo trạng thái (Backlog, In Progress, In Review, Approved, Published), lịch đăng bài sắp tới, tiến độ chiến dịch truyền thông và lượng AI Credit đã sử dụng của Workspace.

---

## UC-027 — Create Workspace

- **Related FR:** `3.4.14` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-12, BR-15, BR-21, BR-22, BR-58`
- **System Messages:** `MSG02, MSG07, MSG22, MSG23, MSG48`
- **Specification & Flow:** Tạo mới một Workspace trực thuộc Agency (/agency/:id/workspaces/new). Khi khởi tạo Workspace, Owner bắt buộc phải chọn và gán ít nhất 01 thành viên của Agency làm Manager (người chịu trách nhiệm quản lý toàn bộ vận hành trong Workspace đó, BR-21), đồng thời cấu hình Tên Workspace, Mô tả, Múi giờ chuẩn (Timezone Configuration, BR-22) và liên kết gói truyền thông mẫu ban đầu.

---

## UC-028 — View Workspace Profile

- **Related FR:** `3.4.15` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-22`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36`
- **Specification & Flow:** Xem thông tin cấu hình chi tiết của Workspace (Workspace Profile — /workspaces/:id/settings). Hiển thị Tên Workspace, Mô tả dự án/nhãn hàng, Thông tin Client liên kết, Trạng thái hoạt động, và đặc biệt là trường cấu hình Múi giờ chuẩn (Timezone Configuration theo chuẩn IANA UTC offset, BR-22) giúp đồng bộ lịch đăng bài viral theo đúng khu vực địa lý của chiến dịch truyền thông.

---

## UC-029 — Update Workspace Profile

- **Related FR:** `3.4.16` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-12, BR-15, BR-21, BR-22`
- **System Messages:** `MSG02, MSG07, MSG21, MSG22`
- **Specification & Flow:** Cập nhật thông tin hồ sơ Workspace (/workspaces/:id/settings). Cho phép chỉnh sửa Tên Workspace, Mô tả, Ảnh đại diện Workspace và cập nhật trường Múi giờ chuẩn (Timezone Configuration, BR-22) để tự động quy đổi mốc thời gian lên lịch đăng bài và hạn chót công việc.

---

## UC-030 — Delete Workspace

- **Related FR:** `3.4.17` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-16`
- **System Messages:** `MSG02, MSG03, MSG07, MSG24, MSG36`
- **Specification & Flow:** Xóa mềm Workspace (/workspaces/:id/settings). Chỉ duy nhất Owner mới có quyền xóa Workspace. Khi xóa, toàn bộ dữ liệu bên trong chuyển sang trạng thái INACTIVE, các thành viên không còn quyền truy cập, nhưng dữ liệu được bảo lưu và Owner có thể khôi phục lại hoàn toàn trong vòng 30 ngày (BR-16).

---

## UC-031 — Leave Workspace

- **Related FR:** `3.4.18` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-21, BR-23`
- **System Messages:** `MSG02, MSG03, MSG07, MSG29, MSG36`
- **Specification & Flow:** Rời khỏi một Workspace cụ thể (/workspaces/:id/settings). Thành viên rời khỏi Workspace sẽ không còn quyền truy cập vào Workspace đó nữa nhưng vẫn giữ nguyên tư cách là thành viên của Agency chủ quản (BR-23). Nếu người rời đi là Manager duy nhất còn lại thì hệ thống yêu cầu bổ nhiệm Manager thay thế trước khi rời (BR-21).

---

## UC-032 — Save Workspace Template

- **Related FR:** `3.4.19` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-24`
- **System Messages:** `MSG02, MSG03, MSG07, MSG30`
- **Specification & Flow:** Lưu cấu hình của một Workspace hiện hành thành Mẫu triển khai (Save Workspace Template — /workspaces/:id/settings). Lưu lại các thông tin cấu trúc chuẩn (Múi giờ mặc định, danh mục công việc mẫu, bộ sưu tập hashtag mẫu, mẫu email và cấu hình quy trình duyệt) thành các Template khác nhau để tái sử dụng nhanh cho các dự án sau (BR-24).

---

## UC-033 — View Workspace Templates

- **Related FR:** `3.4.20` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-24`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem danh sách và chi tiết các mẫu cấu hình Workspace (View Workspace Templates — /agency/:id/workspace-templates). Hiển thị cả các mẫu mặc định của hệ thống và các mẫu riêng do Agency đã lưu, bao gồm mô tả cấu trúc công việc, múi giờ và các thiết lập đi kèm (BR-24).

---

## UC-034 — Apply Workspace Template

- **Related FR:** `3.4.21` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-22, BR-24`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG30, MSG36`
- **Specification & Flow:** Áp dụng một mẫu cấu hình Workspace đã lưu vào Workspace mới hoặc hiện hành (Apply Workspace Template). Hệ thống tự động khởi tạo nhanh các thiết lập múi giờ, danh mục mẫu công việc, bộ hashtag và mẫu email từ Template vào Workspace đích mà không làm ảnh hưởng đến dữ liệu lịch sử (BR-24).

---

## UC-035 — Delete Workspace Template

- **Related FR:** `3.4.22` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-24`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG30, MSG36`
- **Specification & Flow:** Xóa mẫu cấu hình Workspace do Agency tự tạo khỏi thư viện mẫu (/agency/:id/workspace-templates). Việc xóa Template không làm ảnh hưởng đến các Workspace đã được áp dụng mẫu đó trước đây (BR-24).

---

## UC-036 — View Workspace Members

- **Related FR:** `3.4.23` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-21`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem danh sách các thành viên đang tham gia trong Workspace (/workspaces/:id/members). Hiển thị Họ tên, Email, Ảnh đại diện, Vai trò trong Workspace (`Manager`, `Creator`, `Client` — cùng `Owner` của Agency), Ngày tham gia và trạng thái hoạt động.

---

## UC-037 — Add Workspace Member

- **Related FR:** `3.4.24` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-13, BR-15, BR-20, BR-21`
- **System Messages:** `MSG02, MSG07, MSG26, MSG29`
- **Specification & Flow:** Thêm thành viên thuộc Agency (hoặc tài khoản Client) vào trong Workspace và gán vai trò cụ thể (MANAGER, CREATOR hoặc CLIENT — /workspaces/:id/members). Hệ thống kiểm tra người được thêm phải thuộc Agency (hoặc là Client đối tác) và chưa tồn tại trong Workspace (BR-20).

---

## UC-038 — Update Workspace Member Role

- **Related FR:** `3.4.25` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-15, BR-21`
- **System Messages:** `MSG02, MSG03, MSG07, MSG29, MSG36`
- **Specification & Flow:** Cập nhật vai trò (Role) của thành viên trong Workspace (ví dụ chuyển đổi giữa CREATOR và MANAGER — /workspaces/:id/members). Hệ thống kiểm tra ràng buộc luôn phải duy trì ít nhất 01 Manager đang hoạt động trong mỗi Workspace (BR-21, BR-21).

---

## UC-039 — Remove Workspace Member

- **Related FR:** `3.4.26` (3.4 Agency & Workspace)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-19, BR-20, BR-21`
- **System Messages:** `MSG02, MSG03, MSG07, MSG29, MSG36`
- **Specification & Flow:** Xóa thành viên ra khỏi Workspace (/workspaces/:id/members). Thành viên bị xóa khỏi Workspace không còn truy cập được dữ liệu của Workspace đó nhưng các công việc/tư liệu họ đã đóng góp vẫn được giữ lại, và họ vẫn là thành viên của Agency (BR-19, BR-21, BR-21).

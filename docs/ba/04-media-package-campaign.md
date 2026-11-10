# 04 — Media Package, Campaign và Content Request

> [<< Về Overview](00-overview.md)

> **BA đã chốt 2026-11-05** theo [spec Guest sharing và Manager-led](../feature/3-5-media-package-campaign/3-5-6-view-media-campaign/guest-sharing-manager-led/spec.md). Đợt này chỉ cập nhật đặc tả. Flow Client chọn/đàm phán/duyệt Package và duyệt Campaign hai phía được thay thế trong phạm vi Package/Campaign. Quyền duyệt kết quả Task/bài đăng và Content Request theo spec riêng.

## 1. Hành trình hiện hành

1. Owner tạo Media Package trong danh mục Agency.
2. Hệ thống hỗ trợ Owner xuất ảnh/PDF hoặc link guest để quảng bá, gửi cho khách xem.
3. Khách xem gói được chia sẻ trước khi có tài khoản hoặc membership workspace. Link luôn hiển thị bản mới nhất đã lưu của đúng gói Agency hoặc Custom Package workspace được chia sẻ.
4. Owner tạo workspace và gán Manager. Chưa bắt buộc có Client.
5. Manager chốt gói với Client bên ngoài hệ thống.
6. Manager chọn gói Agency để tùy chỉnh hoặc tạo mới trong workspace, ghi nhận đúng thỏa thuận.
7. Lưu gói workspace hợp lệ tự tạo một Campaign DRAFT và task lớn theo gói. Lưu lại/retry không sinh trùng.
8. Manager mời Client vào workspace để xem gói đã ghi nhận, xem kế hoạch và comment góp ý cả khi Campaign còn DRAFT.
9. Manager hoàn thiện kế hoạch và chủ động triển khai khi đủ điều kiện. Bỏ bước duyệt Campaign hai phía.
10. Client theo dõi và góp ý. Những thao tác duyệt kết quả Task/nội dung thuộc quy trình riêng.

Một workspace tiếp tục có một Campaign. Manager được sửa gói trước triển khai và đồng bộ kế hoạch/task, giữ thông tin đã nhập ở hạng mục còn hiệu lực. Khi triển khai phải cố định bản gói/kế hoạch dùng cho lượt đó, khóa sau triển khai. Góp ý của Client không trở thành gate duyệt.

## 2. Media Package — FR 3.5.1 đến 3.5.4

### 3.5.1 — Tạo gói

Owner quản lý danh mục Agency để quảng bá độc lập với workspace. Manager tạo gói thực hiện trong workspace từ mẫu hoặc nhập mới theo thỏa thuận bên ngoài, không cần thêm lượt duyệt Owner/Client.

Gói workspace giữ nội dung riêng và nguồn tham khảo khi có. Chỉnh gói quảng bá không tự sửa điều khoản gói workspace hoặc Campaign/task. Ngân sách và thời lượng tùy chọn. Giữ tổng sản lượng, đơn vị, dịch vụ và phạm vi bàn giao hiện hành, theo [spec package-driven](../feature/3-5-media-package-campaign/3-5-5-create-media-campaign/package-driven-campaign-tasks/spec.md).

### 3.5.2 — Guest view và chia sẻ

Owner xuất gói Agency đã lưu thành ảnh/PDF hoặc chia sẻ link. Manager phụ trách/Owner có quyền quản lý cũng chia sẻ được Custom Package workspace qua ba hình thức này để trao đổi với Client. Guest xem nội dung gói mà không cần đăng nhập. Link đọc bản mới nhất của đúng gói, ảnh/PDF là bản tại thời điểm xuất và có ngày xuất để đối chiếu. Cơ chế bảo mật nâng cao sẽ được bàn với team sau.

Link chỉ hiển thị nội dung và điều khoản của gói được chia sẻ; không trả Client Profile, quyền truy cập workspace, bình luận hoặc lịch sử đàm phán/duyệt. Có link không tự tạo workspace, đơn hàng, xác nhận mua hoặc membership.

### 3.5.3 — Ghi nhận và điều chỉnh thỏa thuận

Manager thực hiện trao đổi/chốt với Client bên ngoài, rồi lưu điều khoản gói trong workspace. Client vào workspace sau để xem thông tin đã ghi nhận. Bỏ hành trình request-change/counter-offer của Client trên hệ thống.

Trước triển khai, chỉnh gói phải đồng bộ Campaign/task, bảo toàn dữ liệu đã nhập và xử lý tác động giảm/đổi hạng mục có xác nhận cần thiết. Gói/kế hoạch đã triển khai được khóa, phát sinh mới theo quy trình bổ sung hiện hành.

### 3.5.4 — Thay bước duyệt Package

Không yêu cầu Client chọn hay duyệt gói. Lưu gói workspace hợp lệ là điểm tự tạo Campaign DRAFT và task, không có bước xác nhận gói riêng sau lưu. Các redirect, checklist và điều kiện chờ Client duyệt Package của flow cũ cần được thay thế khi triển khai.

## 3. Media Campaign — FR 3.5.5 đến 3.5.6

### 3.5.5 — Campaign DRAFT từ gói

Campaign là kế hoạch thực hiện gói đã ghi nhận trong workspace. Backend tự tạo Campaign DRAFT/task khi Manager lưu gói hợp lệ. Manager tiếp tục bổ sung strategy, timeline, brief/deadline và các thông tin thực hiện còn thiếu. Task/subtask theo contract riêng, thành viên bắt đầu khi Campaign IN_PROGRESS.

### 3.5.6 — Client góp ý, Manager triển khai

Client đã tham gia workspace xem/comment góp ý cả bản nháp. Comment lưu người/thời điểm/ngữ cảnh đang xem, không sửa kế hoạch hoặc chuyển trạng thái. Manager quyết định điều chỉnh kế hoạch theo trạng thái cho phép.

Manager triển khai khi kế hoạch/task đủ thông tin và khớp gói. Không yêu cầu trạng thái APPROVED hay timestamp duyệt Campaign hai phía. Lượt triển khai phải cố định bản được dùng, giữ task identity, chống trùng và hỗ trợ retry. Thành công chuyển Campaign IN_PROGRESS, sau đó gói/phạm vi kế hoạch được khóa.

Vòng đời nghiệp vụ đích là DRAFT → IN_PROGRESS → COMPLETED. Điều kiện hoàn thành tiếp tục theo [Campaign closure](../feature/3-5-media-package-campaign/3-5-9-complete-media-campaign/campaign-closure/spec.md) và [package-driven task](../feature/3-5-media-package-campaign/3-5-5-create-media-campaign/package-driven-campaign-tasks/spec.md). Duyệt kết quả Task/bài đăng không được thay bằng comment Campaign.

### Lịch sử và phạm vi thiết kế

Giữ lịch sử đàm phán, approval và dữ liệu cũ để truy vết. Mapping dữ liệu legacy, endpoint, schema và quyền truy cập sẽ chốt trong plan triển khai. Spec này không tạo migration, không xác nhận implementation và không mở thêm Campaign Addendum hoặc checkout/thanh toán.

Các phần Content Request bên dưới giữ phạm vi hiện hành. Những ghi chú lịch sử không liên quan Package/Campaign phải được đọc cùng spec riêng mới nhất đã dẫn.

## 4. Content Request — kênh bổ sung riêng (FR 3.5.7 – 3.5.10)

> **Quyết định người dùng 2026-10-14 (cần đồng bộ với team):** chỉ Client thuộc Workspace có Campaign IN_PROGRESS và deployment SUCCEEDED được tạo Request. Client sửa title/description/type/dueDate hoặc hủy khi PENDING. Deadline từ ngày hiện tại, không trước ngày bắt đầu và không sau ngày kết thúc Campaign, theo timezone Workspace. Manager chủ động tiếp nhận để chuyển IN_PROGRESS và khóa sửa/hủy của Client; sau đó ACCEPTED hoặc DENIED. Hủy là CANCELLED, không xóa. Request được chấp nhận sinh đúng một Task BACKLOG, campaignId=null. Khi Manager đánh dấu Campaign COMPLETED, chặn tạo mới và tự hủy PENDING có lịch sử; IN_PROGRESS tiếp tục xử lý. Hết ngày kế hoạch không tự hoàn thành Campaign. Quy tắc này thay thế quyết định 2026-10-13 giữ PENDING sau hoàn thành.

Đây là 1 luồng **bổ sung, độc lập** với luồng Package/Campaign chính — cho phép Client đề xuất thêm 1 bài đăng cụ thể ngoài kế hoạch Campaign đã duyệt.

### 3.5.7 — Create Content Request
- Client tạo được bài content mới, chờ Manager coi và quyết định đồng ý làm hay không.
- Nếu đồng ý → chuyển trạng thái `accepted` để phân chia task cho role khác thực hiện.
- **[CONFIRMED 2026-09-15]** Nếu Manager từ chối → `denied` là trạng thái **cuối (terminal)**, khác với Task reject. Client không sửa lại được request đã denied — phải tạo Content Request mới hoàn toàn nếu muốn đề xuất lại.
- Ghi chú thêm: cần **note lại** để sau này tính vào công việc bổ sung (có thể liên quan đến billing/KPI ngoài phạm vi Package gốc).
- **[CONFIRMED 2026-09-14]** Role list trong CSV ghi cả OWNER/MANAGER/CLIENT, nhưng thực tế hành động **Create chỉ do CLIENT thực hiện** — Owner/Manager có mặt trong role list vì họ có quyền TRUY CẬP xem màn hình này (để duyệt), không phải vì họ tự tạo request cho mình.

### 3.5.8 — Track Request Status
- Manager điều chỉnh status của yêu cầu do Client đưa lên.
- Luồng trạng thái: `pending → in progress → accept` (chuyển công việc vào backlog) hoặc `denied`.
- 4 trạng thái (pending / in progress / accept / denied) **do Agency setting quyết định** — Client hoàn toàn không có quyền tự set trạng thái.
- Role: MANAGER.
- **Ghi chú kèm theo trong nguồn** (về Template Media Package, liên quan gián tiếp tới luồng): Template media package bao gồm số lượng bài, thời gian thực hiện, chất lượng nội dung... Team truyền thông thảo luận cụ thể hóa các bài viết → ra kế hoạch truyền thông (tiêu đề bài viết, nền tảng đăng tải...) → thảo luận với Client xem kế hoạch có ok không → ra hợp đồng chính thức để ký. Đây là mô tả luồng thực tế ngoài đời mà hệ thống đang số hóa lại qua Package→Campaign.

### 3.5.9 — Update Request
- Client điều chỉnh nội dung content muốn thêm vào.
- **Chỉ được làm khi đang ở trạng thái PENDING**.
- Role: CLIENT.

### 3.5.10 — Cancel Request
- Khi Track Request Status đã đổi khỏi PENDING, Client **không còn quyền xóa/hủy** request nữa — hủy chỉ hợp lệ khi status vẫn là PENDING.
- Role: CLIENT.

## 5. Liên kết với Task backlog

**[CONFIRMED 2026-09-14]** Khi Manager set trạng thái Content Request thành `accepted`, hệ thống **tự động sinh 1 Task mới** trong backlog của Workspace — task này sau đó chảy vào đúng quy trình Task chuẩn (Identify Task Detail → Assign → Approval Sequence...). Xem chi tiết đầy đủ tại [05-content-task-workflow.md](05-content-task-workflow.md).

Ngoài nguồn từ Campaign (mục 3) và Content Request (mục 4), Manager còn được tự do thêm Task thủ công trực tiếp vào backlog bất cứ lúc nào (việc nội bộ, không cần qua Campaign hay Content Request) — xem file 05.

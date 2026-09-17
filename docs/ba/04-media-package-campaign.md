# 04 — Media Package & Contract (Package → Campaign → Content Request)

> [<< Về Overview](00-overview.md)

## 1. Thứ tự chuẩn: Workspace → Package → Campaign → Task

**[CONFIRMED 2026-09-14]** — đây là điểm quan trọng nhất của file này, đảo ngược cách đọc thẳng câu chữ CSV gốc.

```
1. Owner tạo Workspace + gán Manager (xem 01-organization-structure.md)
2. Manager chọn 1 Media Package template ngay sau khi tạo workspace
3. Manager invite Client vào Workspace
4. Client + Manager/Owner đàm phán Media Package (bên trong Workspace)
5. Cả 2 bên Approve Media Package  → "hợp đồng khung"
6. Agency tạo Media Campaign (chi tiết, bám brand Client)
7. Cả 2 bên Approve Media Campaign
8. Toàn bộ đầu việc trong Campaign → tự động đẩy thành Task backlog trong Workspace
```

**Điểm khác so với đọc thẳng câu chữ CSV gốc:** FR 3.5.1 viết "khi tạo Workspace bắt buộc phải có template media package khi Owner chưa nhập thì thông báo Manager" — dễ đọc nhầm là Package phải tồn tại trước khi Workspace được tạo ra. Đã confirm thực tế: **Workspace tạo trước** (Owner + gán Manager), Package là bước Manager làm ngay sau đó, trước khi mời Client vào — không phải điều kiện tiên quyết để ĐƯỢC tạo Workspace.

## 2. Media Package (FR 3.5.1 – 3.5.4)

### 3.5.1 — Create Media Package
- Admin tạo sẵn các package mẫu (2 tuần, 3 tuần...) từ trước.
- Owner có thể **chọn package mẫu có sẵn** hoặc **custom thêm gói truyền thông mới** riêng cho Agency của mình.
- Khi tạo Workspace, nếu Manager/Owner chưa nhập package template → hệ thống **thông báo cho Manager** để nhắc nhở hoàn thành bước này.
- Template Package cần dễ tùy chỉnh theo ý Client (mức độ dễ nhất để thay đổi).
- **Thiết kế DB đề xuất từ nguồn**: tạo 2 bảng riêng — 1 bảng cho package do Owner tạo, 1 bảng cho package custom. Cột "chọn media package" trong Workspace chỉ cần lưu **ID tham chiếu** tới 1 trong 2 bảng đó — giảm độ phức tạp và tăng tốc truy vấn (không JOIN nhiều tầng).
- Role: OWNER/MANAGER.

### 3.5.2 — View the Template Media Package
- Client xem được các package mẫu (chiến lược truyền thông dài/ngắn) để hiểu quy mô triển khai, nhân sự, hình dung được sẽ book Agency trong bao lâu.
- Package chia theo nhiều kiểu:
  - Theo **khoảng thời gian**: trong X tuần sẽ làm những gì.
  - Theo **ngân sách**: với số tiền Y sẽ làm được những gì.
  - **Phó mặc toàn bộ**: Agency tự quyết cách làm, miễn đạt KPI đã thỏa thuận.
- Role: OWNER/MANAGER/CLIENT.

### 3.5.3 — Request Media Package
- Với package mẫu do Agency cung cấp, **Client được quyền thảo luận lại**: đưa ra yêu cầu về giá, thời gian, sự kiện, hình thức...
- Owner/Manager phản hồi: chấp nhận, từ chối, hoặc chuyển đổi thành 1 đề xuất khác phù hợp hơn.
- Quá trình lặp lại (negotiate qua lại) **cho đến khi cả 2 bên chốt được gói cuối cùng**.
- Role: OWNER/MANAGER/CLIENT.

### 3.5.4 — Approve Media Package
- Khi package đã đúng thỏa thuận của cả 2 bên → **cả 2 bên cùng đồng ý** với yêu cầu và các chỉnh sửa đã thống nhất.
- Role: OWNER/MANAGER/CLIENT.

## 3. Media Campaign (FR 3.5.5 – 3.5.6)

### 3.5.5 — Create Media Campaign
- Dựa trên Media Package đã chọn và thống nhất giữa 2 bên, nhưng **chi tiết hơn** — có nội dung triển khai phù hợp với brand cụ thể của Client.
- **Quan trọng**: Media Campaign **KHÔNG phải là hợp đồng** — nó là **chiến lược thực hiện** (execution strategy/plan).
- Role: OWNER/MANAGER/CLIENT.

### 3.5.6 — Approve Media Campaign
- Sau khi đưa chiến lược ra và cả 2 bên đồng ý → tiến hành nhấn **triển khai**.
- Toàn bộ công việc trong Media Campaign được **đẩy tự động vào Workspace, tạo thành bảng backlog công việc** (giống Jira backlog).
- **Lưu ý mức độ chi tiết ở giai đoạn này**: backlog sinh ra CHƯA đầy đủ quy trình triển khai, chưa có yêu cầu cụ thể — chỉ mới là tên công việc + thời gian thông thường. Chi tiết hóa xảy ra ở bước Identify Task Detail (xem [05-content-task-workflow.md](05-content-task-workflow.md)).
- **[CONFIRMED 2026-09-15]** Sau khi approved và đã đẩy backlog, Campaign **immutable** — không sửa lại được. Muốn thêm nội dung giữa chiến dịch → dùng Content Request (mục 4 dưới) hoặc Manager add Task thủ công (FR 3.6.10), không amend Campaign gốc.
- **[CONFIRMED 2026-09-17]** Với khối lượng công việc lớn phát sinh giữa chiến dịch (không phải 1 task lẻ) — dùng **Campaign Addendum**: bản bổ sung link tới Campaign gốc, đi qua chu trình duyệt 2 phía riêng, tách biệt Manual Task đơn lẻ ra khỏi Campaign có nguồn gốc rõ ràng để phục vụ báo cáo/billing. Xem chi tiết state machine tại [12-state-machines.md](12-state-machines.md) mục 3, entity tại [11-data-entities-glossary.md](11-data-entities-glossary.md).
- Role: OWNER/MANAGER/CLIENT.

## 4. Content Request — kênh bổ sung riêng (FR 3.5.7 – 3.5.10)

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

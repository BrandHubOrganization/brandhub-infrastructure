# Role-based Dashboards — spec

## Objective
Làm lại toàn bộ dashboard trên web theo 3 tầng (Cá nhân → Agency → Workspace). Mỗi tầng có tab **Tổng quan**
và **Phân tích**, mỗi vai trò chỉ thấy đúng phạm vi của mình. Gọn, dễ hiểu, toàn bộ số liệu là thật (tính ở
backend). Owner so sánh được hiệu quả các workspace trong agency; người dùng so sánh được các agency mình tham gia.

Thay thế quyết định "Không thêm aggregate API" của `docs/feature/dashboard-experience` (2026-11-18): tính tổng
trên trình duyệt từ một trang task cho ra số sai với workspace lớn. Giữ nguyên các nguyên tắc còn lại của
feature đó: không mock, empty khác lỗi, retry riêng từng khối, token theme.

## Bối cảnh (hiện trạng 2026-11-23)
- Tab Phân tích của agency (`AgencyAnalyticsSection.tsx`) đang hiện **số giả**: đường xu hướng T8→T1 sinh theo
  công thức, biểu đồ nền tảng tự chia 40/30/20/10% khi không có dữ liệu, ô "Kênh mạng xã hội = 4" ghi cứng.
  Chỉ lấy 5 workspace × 50 việc. Bỏ qua vai trò, nên Manager thấy như Owner.
- Trang cá nhân `/dashboard` chưa có phần phân tích.
- Tab Phân tích của workspace (`WorkspaceAnalyticsTab.tsx`, 1.692 dòng) tính trên trình duyệt từ 100 việc gần
  nhất.
- 9 component trong `pages/dashboard/components/` không còn được dùng. Ba trang `/analytics`, `/reports`,
  `/agency/:id/stats` không có trên menu.

## User Stories
- Là **Owner**, tôi muốn xếp hạng các workspace trong agency theo hiệu quả và xem tiền đã chi, giá trị hợp đồng
  client, để biết brand nào làm tốt, brand nào cần can thiệp.
- Là **Manager**, tôi muốn xem tiến độ, khối lượng việc theo người và việc bị nghẽn trong các workspace tôi quản
  lý, để phân việc lại kịp thời.
- Là **Creator**, tôi muốn thấy việc của mình và điểm hiệu suất cá nhân ở từng workspace, để biết mình cần cải
  thiện gì.
- Là **Client**, tôi muốn thấy tiến độ brand của mình, nội dung đang chờ tôi duyệt và kết quả bài đã đăng.
- Là **người dùng có nhiều agency**, tôi muốn so sánh các agency mình tham gia trên cùng một bảng.

## Quyết định nghiệp vụ (đã chốt với chủ dự án 2026-11-23)
1. **Tiền chỉ Owner thấy.** Gồm: số đã chi (đơn gói cước + mua credit đã thanh toán) và giá trị gói truyền thông
   client đã duyệt. Manager, Creator, Client không thấy tiền mà thấy **Điểm hiệu suất 0–100**. Không thêm khái
   niệm thu nhập Creator.
2. **Hiệu quả = bảng chỉ số + Điểm hiệu quả 0–100** để xếp hạng (công thức ở mục Chỉ số).
3. **Manager** ở tầng agency chỉ thấy các workspace mình là MANAGER. Không thấy tiền, credit, thành viên agency.
4. **Creator** thấy việc của mình và hiệu suất cá nhân (không xếp hạng với người khác).
5. **Client** ở tầng agency có cả tab Tổng quan và tab Phân tích, giới hạn trong các workspace mình là CLIENT.
6. **Bộ lọc thời gian** dùng chung: 7 / 30 / 90 ngày, mặc định 30. Mỗi ô số so với kỳ liền trước cùng độ dài.
7. **Gộp** `/analytics`, `/reports`, `/agency/:id/stats` vào tab Phân tích. Ba đường dẫn cũ chuyển hướng sang
   tab mới. Xoá 3 trang và các component chết.
8. **Chỉ làm web** đợt này. Mobile vẫn gọi `/agencies/{id}/stats`, `/analytics/overview`,
   `/workspaces/{id}/dashboard`, nên backend **giữ nguyên** các endpoint cũ.

Chốt thêm 2026-11-23 (vòng 2):

9. **Mọi con số, ô, cột, lát, điểm, hàng, dòng trên dashboard đều bấm được.** Bấm số hoặc biểu đồ mở **ngăn kéo
   chi tiết** bên phải, liệt kê đúng các việc/bài tạo nên con số đó. Có nút **Mở trang đầy đủ** sang trang Việc
   (hoặc Xuất bản) của workspace, đã lọc sẵn.
10. **Thao tác nhẹ ngay trong ngăn kéo:** nhận việc, Bắt đầu, đổi người làm, dời hạn, Gửi duyệt. **Duyệt/từ chối
    không làm trên dashboard**, nút "Duyệt" mở màn hình duyệt để xem đủ nội dung.
11. **Hàng nút hành động nhanh cố định theo vai trò**, 4–6 nút ngay dưới tiêu đề tab Tổng quan, nút có số đếm khi
    liên quan. Không cho người dùng tự ghim.
12. **Biểu đồ:** rê chuột hiện số chính xác; bấm cột/điểm/lát mở ngăn kéo; bấm chú thích để ẩn/hiện chuỗi; bảng
    sắp xếp được, bấm hàng mở dashboard workspace/agency.
13. **Thẻ "Làm tiếp"** ở tab Tổng quan: 3 việc nên làm trước, mỗi việc có nút chính theo trạng thái. Client thấy
    "Nội dung chờ bạn duyệt".
14. **Tự cập nhật:** nhận tín hiệu thông báo realtime thì tải lại số liệu ngầm. Có dòng "Cập nhật lúc HH:mm" và
    nút làm mới.
15. **Trang Việc của workspace nhận bộ lọc qua URL.** Số gộp nhiều workspace chỉ xem bằng ngăn kéo (nhóm theo
    workspace, mỗi nhóm có link "Mở trong workspace"). Không làm trang việc xuyên workspace.
16. **Dải "Cần chú ý" không ẩn được**, dòng tự mất khi vấn đề được xử lý.

Chốt thêm 2026-11-23 (vòng 3):

17. **Không lặp số:** một con số chỉ hiện một lần trên màn hình. Nút nhanh trùng với ô số thì bỏ số đếm, vẫn bấm
    được.
18. **Người nhiều vai trò** thấy bộ nút nhanh của vai trò cao nhất (Owner > Manager > Creator > Client), cộng nút
    "Chờ tôi duyệt" nếu có. Tối đa 6 nút.
19. **Việc bị nghẽn** = quá hạn, hoặc chờ duyệt quá 3 ngày (tính từ `lastSubmission.submittedAt`).
20. **Ngưỡng điểm:** tỷ lệ cần ≥ 3 việc; tỷ lệ tương tác cần reach ≥ 100; tương tác 5% = điểm tối đa (cấu hình
    được).
21. **Dữ liệu cũ:** task đã hoàn thành trước khi triển khai lấy `finishedAt` = lúc duyệt cuối
    (`lastSubmission.closedAt`), không có thì lúc cập nhật cuối.
22. **"Tiếp tục ở {agency gần nhất}"** lấy agency vừa chọn lưu trên trình duyệt (`agencyStore`), không thêm DB.
    Chưa có hoặc người dùng không còn thuộc agency đó thì ẩn nút.
23. **Owner xuất báo cáo:** nút **In** (in tab Phân tích, lưu PDF bằng trình duyệt) và nút **Xuất Excel** (file
    .xlsx gồm bảng xếp hạng workspace + tài chính + đội ngũ của khoảng thời gian đang chọn).
24. **Khối không có dữ liệu:** hiện trạng thái trống ghi rõ lý do, kèm nút hành động (Tạo việc / Đổi sang 90 ngày
    / Kết nối mạng xã hội...). Không ẩn khối, không số giả.

## Chỉ số (định nghĩa dùng chung mọi tầng)
Khoảng thời gian `R = [from, to)`, kỳ trước `R' = [from − len, from)`.

| Mã | Tên hiển thị | Công thức | Mẫu tối thiểu |
|---|---|---|---|
| `finished` | Việc hoàn thành | Task `FINISHED` có `finishedAt ∈ R` | — |
| `onTimeRate` | % đúng hạn | Trong `finished` có `dueDate`: tỷ lệ `finishedAt ≤ dueDate` | ≥ 3 |
| `firstPassRate` | % duyệt lần đầu | Trong `finished`: tỷ lệ `approvalRound = 1` | ≥ 3 |
| `completionRate` | % hoàn thành | Task không `CANCELLED` có `dueDate ∈ R`: tỷ lệ đã `FINISHED` | ≥ 3 |
| `overdue` | Quá hạn | Task không `FINISHED`/`CANCELLED`, `dueDate < now` | — |
| `published` | Bài đã đăng | Post `PUBLISHED`, `publishedAt ∈ R` | — |
| `reach` | Reach | Tổng `reachCount` của `published` | — |
| `engagementRate` | Tỷ lệ tương tác | (reaction + comment + share + saved) / reach của `published` | reach ≥ 100 |
| `returnedRate` | % bị trả lại sửa | 1 − `firstPassRate` | ≥ 3 |
| `score` | Điểm hiệu quả | Xem dưới | — |

`finishedAt`: thời điểm task chuyển sang `FINISHED` (trường mới, xem plan).

**Điểm hiệu quả (0–100):**
`score = Σ wᵢ·vᵢ / Σ wᵢ`, chỉ lấy các thành phần đủ mẫu tối thiểu.
- `onTimeRate` w = 30
- `firstPassRate` w = 25
- `completionRate` w = 25
- `engagementScore` w = 20, với `engagementScore = min(engagementRate / 5%, 1) × 100`
  (mốc 5% là cấu hình `brandhub.analytics.engagement-benchmark`, mặc định 0.05)

Không thành phần nào đủ mẫu → `score = null`, UI hiện "Chưa đủ dữ liệu". Làm tròn số nguyên.
Đặt tên hiển thị: "Điểm hiệu quả" cho workspace và agency, "Điểm hiệu suất" cho cá nhân (cùng công thức).

**Tiền (chỉ Owner):**
- `spent` = Σ `billing_orders.amount` của agency, `status ∈ (PAID, FULFILLED)`, `paid_at ∈ R`, tách theo `kind`
  (SUBSCRIPTION / CREDIT_TOPUP).
- `contractValue` = Σ `final_terms->>'budgetAmount'` của `workspace_media_packages` có
  `approved_by_client_at ∈ R`, theo workspace.
- `creditsUsed` = Σ `workspace_credit_usage.used` của các kỳ credit giao với `R`, theo workspace. UI ghi chú
  "tính theo kỳ credit".

## Màn hình

### Nguyên tắc chung
- **Thứ tự khối tab Tổng quan** (mọi tầng, mọi vai trò): Hành động nhanh → Ô số → Cần chú ý → Làm tiếp → danh sách
  (agency/workspace/việc gần đây). Tab Phân tích: bộ lọc thời gian → Ô số → bảng so sánh → biểu đồ.
- **Không lặp số:** một con số chỉ xuất hiện một lần trên cùng màn hình. Nếu ô số đã có "Chờ tôi duyệt" thì nút
  nhanh "Chờ tôi duyệt" không hiện số đếm (vẫn bấm được).
- **Làm tiếp chỉ hiện khi có việc.** Owner thường không có việc riêng nên chỉ thấy thẻ này khi được giao việc
  hoặc có việc chờ mình duyệt.
- Hàng đầu: tối đa 4 ô số, mỗi ô có giá trị, mũi tên ↑↓ và % so với kỳ trước (ẩn % khi kỳ trước = 0).
- Dưới hàng ô số: dải **Cần chú ý** (tối đa 3 mục, bấm được), ẩn khi không có gì.
- Mỗi biểu đồ có tiêu đề dạng câu hỏi ("Workspace nào hiệu quả nhất?") và trạng thái trống riêng.
- **Không bao giờ hiện số giả hoặc ước lượng.** Thiếu dữ liệu thì hiện trống hoặc "Chưa đủ dữ liệu".
- Bộ lọc thời gian ở góc phải đầu tab Phân tích. Tab và khoảng lưu trên URL: `?tab=overview|analytics&range=30D`.
- Bảng so sánh sắp xếp được theo mọi cột, mặc định theo `score` giảm dần. Bấm một hàng để mở dashboard của
  workspace hoặc agency đó.

### Tầng 1 — Cá nhân `/dashboard`
**Tổng quan:** giữ bố cục hiện tại (agency sở hữu / tham gia / hồ sơ khách hàng, lời mời, tài khoản). Thêm hàng
4 ô gộp mọi agency: Việc đang giữ · Quá hạn · Chờ tôi duyệt · Hoàn thành (30 ngày).

**Phân tích:**
1. Ô số: Việc hoàn thành · % đúng hạn · % duyệt lần đầu · Điểm hiệu suất của tôi (tính trên việc giao cho tôi).
2. Bảng **So sánh agency**, mỗi agency một hàng: Agency · Vai trò của tôi · Điểm · Hoàn thành · % đúng hạn ·
   % duyệt lần đầu · Bài đã đăng · Reach · Tỷ lệ tương tác · Đã chi · Giá trị hợp đồng.
   - Hai cột tiền chỉ có giá trị ở hàng agency tôi là Owner, các hàng khác hiện "—".
   - Số liệu theo phạm vi vai trò của tôi trong từng agency: Owner tính cả agency, Manager tính workspace mình
     quản lý, Creator tính việc của mình, Client tính brand của mình.
3. Biểu đồ cột: Điểm theo agency.
4. Biểu đồ đường: Việc hoàn thành theo tuần, mỗi agency một đường (top 5 + "Khác").

### Tầng 2 — Agency `/agency/:id/dashboard`
Server quyết định nội dung theo vai trò người gọi. Một người vừa là Manager ở workspace A vừa là Creator ở
workspace B thì thấy **cả 2 khối**, thứ tự Manager → Creator → Client (`viewer.sections`).

**Owner**
- Tổng quan: ô số Workspace · Thành viên · Credit khả dụng · Việc quá hạn. Dải Cần chú ý. Danh sách workspace
  (giữ). Việc gần đây (giữ).
- Phân tích:
  1. Ô số: Điểm hiệu quả agency · Việc hoàn thành · Bài đã đăng · Đã chi.
  2. Bảng **Xếp hạng workspace**: Workspace · Client · Điểm · Hoàn thành · % đúng hạn · % duyệt lần đầu ·
     Quá hạn · Bài đã đăng · Reach · Tỷ lệ tương tác · Credit đã dùng · Giá trị hợp đồng.
  3. Cột ngang: Điểm theo workspace.
  4. Đường: Việc hoàn thành theo tuần, mỗi workspace một đường (top 5 + "Khác").
  5. Cột chồng: Trạng thái công việc theo workspace (Chưa làm / Đang làm / Chờ duyệt / Hoàn thành).
  6. Cột: Bài đã đăng theo nền tảng (Facebook, Instagram, TikTok, Threads), số thật.
  7. Khối **Tài chính**: Đã chi theo tháng (cột chồng Gói cước / Credit), Giá trị hợp đồng theo workspace,
     Credit đã dùng theo workspace.
  8. Khối **Đội ngũ** (thay `/agency/:id/stats`): thành viên theo vai trò, tăng trưởng thành viên theo tháng.
  9. Nút **In báo cáo** (thay `/reports`): in tab Phân tích bằng CSS print, ẩn sidebar và thanh trên. Nút
     **Xuất Excel**: tải `.xlsx` gồm 3 sheet:
     - "Xếp hạng workspace": đủ cột bảng xếp hạng
     - "Tài chính": đã chi theo tháng/loại, giá trị hợp đồng và credit theo workspace
     - "Đội ngũ": thành viên theo vai trò, tăng trưởng theo tháng

     Tên file `bao-cao-{agency-slug}-{from}-{to}.xlsx`, tiêu đề cột theo ngôn ngữ đang dùng.

**Manager** (chỉ các workspace mình là MANAGER)
- Tổng quan: ô số Workspace quản lý · Việc đang mở · Quá hạn · Chờ tôi duyệt. Dải Cần chú ý. Danh sách workspace
  (trong phạm vi). Việc gần đây.
- Phân tích:
  1. Ô số: Điểm hiệu quả · Việc hoàn thành · % đúng hạn · Bài đã đăng.
  2. Bảng xếp hạng workspace như Owner, **bỏ** Credit đã dùng và Giá trị hợp đồng.
  3. **Khối lượng theo người**: cột chồng mỗi thành viên (đang mở / quá hạn / hoàn thành trong kỳ).
  4. **Việc bị nghẽn**: việc quá hạn hoặc chờ duyệt quá 3 ngày, sắp theo độ trễ, tối đa 10, bấm mở task.
  5. Đường: Việc hoàn thành theo tuần.

**Creator** (việc giao cho mình trong agency)
- Tổng quan: ô số Việc đang giữ · Quá hạn · Đến hạn trong 7 ngày · Hoàn thành trong kỳ. Danh sách việc của tôi
  sắp theo hạn.
- Phân tích:
  1. Ô số: Điểm hiệu suất của tôi · % đúng hạn · % duyệt lần đầu · % bị trả lại sửa.
  2. Cột: Việc hoàn thành theo tuần.
  3. Bảng **So sánh workspace của tôi**: Workspace · Điểm · Hoàn thành · % đúng hạn · % duyệt lần đầu.
  4. Cột ngang: Việc của tôi theo loại task.

**Client** (các workspace mình là CLIENT)
- Tổng quan: ô số Brand của tôi · Chờ tôi duyệt · Việc đang làm · Bài đã đăng trong kỳ. Danh sách nội dung chờ
  tôi duyệt (bấm mở màn hình duyệt, không duyệt ngay trên dashboard).
- Phân tích:
  1. Ô số: Bài đã đăng · Reach · Tỷ lệ tương tác · % hoàn thành.
  2. Đường: Bài đã đăng theo tuần.
  3. Cột nhóm: Reach và tương tác theo nền tảng.
  4. Bảng: Top 5 bài theo tương tác (link mở bài).
  5. Có từ 2 brand trở lên: bảng so sánh brand (Bài đã đăng · Reach · Tỷ lệ tương tác · % hoàn thành).

### Tầng 3 — Workspace `/workspaces/:id/dashboard`
Giữ 3 tab Tổng quan / Xuất bản / Phân tích. Tab Phân tích chuyển sang API backend (cùng định nghĩa chỉ số), cùng
bộ lọc 7/30/90, bố cục như tầng agency thu về 1 workspace:
- Owner/Manager: ô số (Điểm · Hoàn thành · % đúng hạn · Bài đã đăng) + khối lượng theo người + việc bị nghẽn +
  trạng thái + nền tảng + xu hướng.
- Creator: như khối Creator tầng agency, giới hạn 1 workspace (bỏ bảng so sánh).
- Client: như khối Client tầng agency, giới hạn 1 workspace (bỏ bảng so sánh).

Tab Tổng quan và Xuất bản giữ chức năng, chỉ thống nhất kiểu ô số và khoảng cách.

## Việc người dùng làm trên dashboard
Dashboard là nơi **bắt đầu ngày làm việc**: thấy ngay việc gì gấp, bấm một lần là tới chỗ làm. Tab Tổng quan trả
lời "Hôm nay tôi làm gì?", tab Phân tích trả lời "Chúng ta đang làm tốt đến đâu?".

| Vai trò | Câu hỏi khi mở dashboard | Việc làm ngay từ dashboard |
|---|---|---|
| Mọi người (cá nhân) | Hôm nay tôi phải làm gì, ở agency nào? Agency nào tôi làm tốt nhất? | Vào lại agency gần nhất, xử lý lời mời, mở việc gấp nhất, so sánh agency |
| Owner | Agency có ổn không? Workspace nào đang tụt? Tiền và credit còn bao nhiêu? | Tạo workspace, mời người, mua credit, xem workspace tụt điểm, in báo cáo |
| Manager | Việc nào trễ, ai đang quá tải, cái gì chờ tôi duyệt? | Phân việc chưa giao, đổi người làm, dời hạn, mở màn duyệt, tạo việc |
| Creator | Tôi làm việc nào trước? Việc nào bị trả lại? | Bắt đầu việc, tiếp tục việc dở, sửa theo góp ý, gửi duyệt, viết nội dung với AI |
| Client | Có gì chờ tôi duyệt? Brand của tôi đang chạy thế nào? | Mở màn duyệt, gửi yêu cầu nội dung, xem gói truyền thông, xem bài đã đăng, nhắn agency |

### Hành động nhanh (hàng nút đầu tab Tổng quan)
Cố định theo vai trò, 4–6 nút, `(n)` là số đếm, ẩn số khi bằng 0. Nút cần chọn workspace (khi phạm vi có hơn 1
workspace) mở **popover chọn workspace**; có đúng 1 workspace thì đi thẳng. Người có nhiều vai trò thấy bộ nút của
vai trò cao nhất (Owner > Manager > Creator > Client) cộng nút "Chờ tôi duyệt" nếu có.

| Tầng / vai trò | Nút → đích |
|---|---|
| Cá nhân | **Tiếp tục ở {agency gần nhất}** → `/agency/:id/dashboard` · **Lời mời (n)** → `/agency/invitations` hoặc `/client/invitations` · **Việc gấp (n)** → ngăn kéo việc quá hạn + đến hạn hôm nay, mọi agency · **Chờ tôi duyệt (n)** → ngăn kéo · **Tạo công ty** → `/agency/create` |
| Agency · Owner | **Tạo workspace** → `/workspaces/create?agencyId=` · **Mời thành viên** → `/agency/:id/members` · **Mua credit** → `/agency/:id/credit` · **Gói dịch vụ truyền thông** → `/agency/:id/media-packages` · **Nâng cấp gói** → `/subscription/plans` |
| Agency · Manager | **Tạo việc** → chọn workspace → hộp tạo việc nhanh (`QuickCreateTaskDialog`) · **Chờ tôi duyệt (n)** → ngăn kéo · **Chưa giao (n)** → ngăn kéo việc chưa có người làm · **Lịch đăng** → `/workspaces/:id/calendar` · **Chiến dịch** → `/workspaces/:id/campaigns` |
| Agency · Creator | **Làm tiếp** → mở việc đầu tiên của thẻ Làm tiếp · **Việc của tôi (n)** → ngăn kéo · **Bị trả lại (n)** → ngăn kéo · **Viết với AI** → `/workspaces/:id/content-writing` · **Lịch** → `/calendar` |
| Agency · Client | **Chờ tôi duyệt (n)** → ngăn kéo · **Gửi yêu cầu nội dung** → `/workspaces/:id/requests` · **Gói truyền thông** → `/workspaces/:id/media-package` · **Bài đã đăng** → `/workspaces/:id/publish/dashboard` · **Nhắn agency** → `/workspaces/:id/chat` |
| Workspace | Như tầng agency của vai trò đó, khoá vào workspace hiện tại (không popover). Owner/Manager thêm **Thành viên** → `/workspaces/:id/members` |

### Thẻ "Làm tiếp"
- Manager và Creator: 3 việc của tôi, xếp theo thứ tự: quá hạn → bị trả lại sửa → đến hạn hôm nay → ưu tiên
  URGENT/HIGH → hạn gần nhất. Manager tính cả việc chờ mình duyệt.
- Mỗi dòng: tên việc, workspace, hạn (đỏ nếu quá), nhãn lý do ("Quá hạn 2 ngày", "Bị trả lại"). Nút chính theo
  trạng thái:
  - TODO → **Bắt đầu**
  - IN_PROGRESS → **Tiếp tục**
  - REJECTED → **Sửa theo góp ý**
  - chờ mình duyệt → **Duyệt** (mở màn duyệt)
- Client: "Nội dung chờ bạn duyệt" (3 dòng, nút **Xem và duyệt**).
- Hết việc: hiện "Bạn đã xong việc gấp" + link xem toàn bộ việc.

### Bản đồ tương tác (mọi chỗ bấm được)
| Phần tử | Bấm / rê chuột | Kết quả |
|---|---|---|
| Ô số (KPI) | Bấm | Ngăn kéo với bộ lọc của ô đó (ví dụ Quá hạn → việc quá hạn trong phạm vi) |
| Ô số tiền (Owner) | Bấm | Ngăn kéo danh sách đơn đã thanh toán; nút "Lịch sử thanh toán" → `/subscription/invoices` |
| Ô Credit | Bấm | `/agency/:id/credit` |
| Ô Thành viên | Bấm | `/agency/:id/members` |
| Dòng Cần chú ý | Bấm | Ngăn kéo đúng nhóm việc đó |
| Thẻ Làm tiếp | Bấm dòng / nút chính | Mở việc (`/workspaces/:ws/tasks?task=`) / thực hiện hành động |
| Hàng bảng so sánh | Bấm | Dashboard workspace (tầng agency) hoặc agency (tầng cá nhân), giữ `range` |
| Ô số trong bảng | Bấm | Ngăn kéo lọc theo hàng × chỉ số (ví dụ WS-A × Quá hạn) |
| Tiêu đề cột bảng | Bấm | Sắp xếp tăng/giảm |
| Cột / điểm / lát biểu đồ | Rê chuột | Tooltip số chính xác + % |
| Cột / điểm / lát biểu đồ | Bấm | Ngăn kéo lọc theo phần đó (workspace × trạng thái, tuần × hoàn thành, nền tảng × bài đã đăng...) |
| Chú thích biểu đồ | Bấm | Ẩn/hiện chuỗi; còn 1 chuỗi thì không cho ẩn |
| Khối lượng theo người | Bấm cột người | Ngăn kéo việc của người đó (nút "Đổi người làm" trên từng dòng) |
| Việc bị nghẽn / Top bài | Bấm dòng | Mở việc / mở bài trên nền tảng (tab mới) |
| Thẻ agency/workspace ở danh sách | Bấm | Vào dashboard; nút phụ Công việc / Chiến dịch giữ như hiện tại |
| Nút In báo cáo | Bấm | In tab Phân tích |

Mọi phần tử bấm được: dùng `<button>`/`<a>` thật (đi được bằng Tab, Enter/Space), có focus ring, con trỏ tay,
hover rõ. Biểu đồ có thêm bảng số liệu ẩn cho trình đọc màn hình.

### Ngăn kéo chi tiết
- Mở từ phải, rộng 480px (toàn màn hình ở mobile). Tiêu đề = tên bộ lọc ("Quá hạn · Tiệm Trà & Bánh · 30 ngày").
  URL có `?drill=<mã>` để chia sẻ và để nút Back của trình duyệt đóng ngăn kéo.
- Nội dung: danh sách việc hoặc bài, phân trang 20. Số gộp nhiều workspace thì **nhóm theo workspace**, mỗi nhóm
  có link "Mở trong workspace".
- Dòng việc: tên, workspace, người làm (avatar), hạn, trạng thái. Bấm dòng mở việc.
- **Thao tác nhẹ** trên dòng (chỉ hiện khi người xem có quyền, server vẫn kiểm lại):

  | Thao tác | Ai | API có sẵn |
  |---|---|---|
  | Nhận việc | Creator (việc chưa giao trong workspace mình) | `POST /tasks/{id}/assign` |
  | Đổi người làm | Owner, Manager | `POST /tasks/{id}/assign` (+ `GET /member-options`) |
  | Bắt đầu | Người làm | `POST /tasks/{id}/start` |
  | Dời hạn | Owner, Manager | `PATCH /tasks/{id}/field` (`dueDate`) |
  | Gửi duyệt | Người làm | `POST /tasks/{id}/submit` |
  | Duyệt | Người duyệt, Client | Không làm tại chỗ, mở `/workspaces/:ws/task-approvals?task=` |

  Thao tác thành công: dòng cập nhật tại chỗ, số liệu dashboard tải lại ngầm, toast ngắn. Lỗi: toast theo
  `notifyError` (mã lỗi có sẵn), dòng giữ nguyên.
- Chân ngăn kéo: **Mở trang đầy đủ** → `/workspaces/:ws/tasks?status=&assignee=&due=` (chỉ hiện khi bộ lọc thuộc
  1 workspace) hoặc `/workspaces/:ws/publish/dashboard?status=&platform=&dateRange=` với bài đăng.

### Tự cập nhật
- Dashboard lắng nghe `useNotificationSocket`. Nhận tín hiệu thì gọi lại các query dashboard đang mở (debounce
  3 s, tối đa 1 lần/10 s).
- Góc phải tiêu đề hiện "Cập nhật lúc HH:mm" + nút làm mới.
- Quay lại tab trình duyệt sau hơn 60 s cũng tải lại (React Query `refetchOnWindowFocus`).

## Acceptance Criteria
- AC1 Không còn số giả: không giá trị nào sinh theo công thức hay ghi cứng trong code dashboard. Mọi số ở tab
  Phân tích đến từ API mới.
- AC2 `/dashboard` có tab Tổng quan và Phân tích. Phân tích có bảng so sánh agency đúng định nghĩa chỉ số. Cột tiền
  chỉ có giá trị ở agency người dùng là Owner.
- AC3 Owner ở `/agency/:id/dashboard?tab=analytics` thấy đủ 9 khối mục Owner.
- AC4 Manager chỉ thấy workspace mình là MANAGER. JSON **không chứa** `money`, `finance`, `team`, credit (kiểm ở
  server, không chỉ ẩn trên UI).
- AC5 Creator chỉ thấy số liệu việc giao cho mình. JSON không có `workload`, không có dữ liệu người khác.
- AC6 Client chỉ thấy workspace mình là CLIENT, có cả 2 tab. JSON không có `money`, `finance`, `team`, `workload`.
- AC7 Người vừa là Manager vừa là Creator trong cùng agency thấy cả 2 khối, đúng thứ tự.
- AC8 Bộ lọc 7/30/90 đổi mọi số trong tab. Ô số hiện ↑↓ % so kỳ trước. Tab và khoảng giữ nguyên khi tải lại.
- AC9 Điểm đúng công thức, tự chia lại trọng số khi thiếu thành phần. Không thành phần nào đủ mẫu → "Chưa đủ dữ
  liệu".
- AC10 Tab Phân tích workspace dùng API backend. Workspace hơn 100 task cho số đúng.
- AC11 Chuyển hướng: `/analytics` → `/dashboard?tab=analytics`; `/reports` →
  `/agency/{agency hiện tại}/dashboard?tab=analytics` (không có agency hiện tại → `/dashboard?tab=analytics`);
  `/agency/:id/stats` → `/agency/:id/dashboard?tab=analytics`.
- AC12 Owner bấm In báo cáo → bản in chỉ gồm tab Phân tích, đủ biểu đồ.
- AC13 Không có quyền → 403. Agency hoặc workspace không tồn tại → 404.
- AC14 i18n: key mới thêm song song `vi` + `en`, không chuỗi cứng trong JSX.
- AC15 Light/Dark: chỉ dùng token theme, biểu đồ đọc được ở cả 2 chế độ.
- AC16 Ở 375px không cuộn ngang trang. Bảng so sánh cuộn ngang trong khung riêng, cột tên cố định.
- AC17 API analytics phản hồi ≤ 1,5 s với agency 10 workspace × 2.000 task (DB local).
- AC18 Mobile không bị ảnh hưởng: 3 endpoint cũ trả đúng như trước.
- AC19 Mọi phần tử trong bảng "Bản đồ tương tác" bấm được, đúng kết quả. Đi được bằng bàn phím (Tab, Enter/Space),
  có focus ring.
- AC20 Bấm số/biểu đồ mở ngăn kéo. Tổng số dòng trong ngăn kéo **bằng đúng** con số đã bấm. URL có `?drill=`,
  nút Back đóng ngăn kéo.
- AC21 Thao tác nhẹ trong ngăn kéo chỉ hiện khi có quyền. Làm xong thì dòng và số liệu cập nhật không cần tải lại
  trang. Duyệt luôn mở màn duyệt.
- AC22 Hàng nút nhanh đúng bộ theo vai trò ở bảng Hành động nhanh. Số đếm đúng. Nút cần workspace mở popover khi
  phạm vi có hơn 1 workspace.
- AC23 Thẻ Làm tiếp xếp đúng thứ tự ưu tiên. Nút chính đúng theo trạng thái.
- AC24 Có thông báo realtime liên quan thì số liệu tự đổi trong ≤ 15 s mà không cần bấm làm mới.
- AC25 Trang Việc của workspace mở với `?status=&assignee=me&due=overdue` thì bộ lọc đã chọn sẵn và đúng kết quả.
  Đổi bộ lọc trên trang thì URL đổi theo.
- AC26 Biểu đồ: tooltip khi rê chuột/focus; bấm chú thích ẩn/hiện chuỗi.
- AC27 Owner bấm Xuất Excel → file 3 sheet, số khớp màn hình cùng khoảng thời gian. Không phải Owner gọi API xuất
  → 403.
- AC28 Khối không có dữ liệu hiện lý do + nút hành động, không ẩn khối.
- AC29 Nút "Tiếp tục ở…" chỉ hiện khi agency đã lưu trên trình duyệt còn nằm trong danh sách agency của người dùng.

## API Contract
| Method | Path | Quyền | Mô tả |
|---|---|---|---|
| GET | `/api/v1/analytics/me?range=7D\|30D\|90D` | Đã đăng nhập | Tầng cá nhân |
| GET | `/api/v1/analytics/agencies/{agencyId}?range=` | Thành viên agency | Tầng agency theo vai trò |
| GET | `/api/v1/analytics/workspaces/{workspaceId}?range=` | Thành viên workspace | Tầng workspace theo vai trò |

| GET | `/api/v1/analytics/{me \| agencies/{id} \| workspaces/{id}}/overview` | Như trên | Tab Tổng quan: ô số, Cần chú ý, Làm tiếp, số đếm cho nút nhanh |
| GET | `/api/v1/analytics/{me \| agencies/{id} \| workspaces/{id}}/items?drill=&range=&workspaceId=&page=&size=` | Như trên | Danh sách cho ngăn kéo |
| GET | `/api/v1/analytics/agencies/{agencyId}/export.xlsx?range=&lang=vi\|en` | Owner | Tải báo cáo Excel |
| GET | `/api/v1/workspaces/{id}/tasks` (sửa) | Như hiện tại | Thêm param `assignee=<userId>\|me\|none`, `due=overdue\|today\|week` |

`range` mặc định `30D`. Múi giờ tính tuần/tháng: `Asia/Ho_Chi_Minh`, tuần bắt đầu thứ Hai.

**`/overview` response:**
```
{ viewer: { sections }, kpis: [{ key, value, drill }], attention: [{ kind, count, drill }],
  nextUp: [{ taskId, workspaceId, workspaceName, title, status, dueDate, reason: OVERDUE|REJECTED|DUE_TODAY|HIGH_PRIORITY|AWAITING_ME, primaryAction: START|CONTINUE|FIX|REVIEW }],
  actionCounts: { awaitingMe, unassigned, myOpen, returned, urgent, invitations },
  updatedAt }
// "Tiếp tục ở agency gần nhất": web tự lấy từ agencyStore, đối chiếu danh sách agency, không có trong API.
```

**`drill`** là mã bộ lọc server sinh ra và tự kiểm lại phạm vi. Dạng `metric[:workspaceId][:dimension=value]`,
ví dụ `overdue`, `finished:WS-A`, `status:WS-A:inReview`, `published:platform=TIKTOK`, `week:2026-11-16:finished`,
`assignee:<userId>:open`, `spent`. Mọi `kpis`, `attention`, `rows.metrics`, điểm biểu đồ trong response
analytics đều kèm `drill` tương ứng để web không phải tự dựng bộ lọc.

**`/items` response:** `{ title, kind: TASK|POST|ORDER, total, page, groups: [{ workspaceId, workspaceName,
fullPageUrl?, items: [...] }] }`.
- Dòng TASK kèm `allowedActions: [ASSIGN_SELF, REASSIGN, START, RESCHEDULE, SUBMIT, OPEN_REVIEW]`, server tính theo
  quyền thật của người xem.
- `total` phải bằng giá trị của con số đã bấm (cùng hàm đếm).

Response chung. Khối không thuộc vai trò thì **không có trong JSON** (`@JsonInclude(NON_NULL)`):
```
{
  range: { from, to, previousFrom, previousTo },
  viewer: { sections: ["OWNER"|"MANAGER"|"CREATOR"|"CLIENT"] },
  kpis: [{ key, value, previous, deltaPercent }],
  attention: [{ kind: OVERDUE|STALE_REVIEW|AWAITING_ME|NO_ACTIVITY, count, link }],
  rows: [{ id, name, logoUrl, clientName?, role?, metrics: { finished, onTimeRate, firstPassRate,
           completionRate, overdue, published, reach, engagementRate, score },
           money?: { spent, contractValue, creditsUsed } }],
  trend: [{ seriesId, seriesName, points: [{ weekStart, finished, published }] }],
  statusBreakdown?: [{ rowId, todo, inProgress, inReview, finished }],
  platformBreakdown?: [{ platform, published, reach, interactions }],
  taskTypeBreakdown?: [{ type, count }],
  workload?: [{ userId, name, avatarUrl, open, overdue, finished }],
  blocked?: [{ taskId, workspaceId, title, reason: OVERDUE|STALE_REVIEW, days }],
  myTasks?: [{ taskId, workspaceId, title, status, dueDate }],
  awaitingMe?: [{ taskId, workspaceId, title, submittedAt }],
  finance?: { spentByMonth: [{ month, subscription, credit }],
              contractByWorkspace: [{ workspaceId, value }], creditsByWorkspace: [{ workspaceId, used }] },
  team?: { membersByRole, memberGrowthByMonth },
  topPosts?: [{ postId, workspaceId, platform, publishedAt, reach, interactions, url }],
  partialErrors?: ["finance" | "posts" | ...]
}
```
- Tầng cá nhân: `rows` là agency (kèm `role`), `money` chỉ ở hàng Owner.
- Tầng agency: `rows` là workspace trong phạm vi.
- Tầng workspace: `rows` rỗng.
- Với khối Creator, `metrics` trong `rows` chỉ tính việc giao cho người gọi.

### Điều chỉnh khi triển khai (2026-11-23)
- Response analytics có `blocks: [{ section, kpis, rows, trend, ... }]`, mỗi vai trò một khối (Manager + Creator cần số
  riêng cho từng khối). `viewer.workspaces` liệt kê workspace trong phạm vi kèm vai trò (cho popover chọn workspace).
- Mã `drill` có dạng `METRIC[:key=value]*`, khoá: `ws`, `agency`, `user`, `week`, `platform`, `type`, `as` (khối vai
  trò, `MINE` = việc giao cho tôi). Web coi mã là chuỗi đóng, không tự dựng.
- Ô số tỷ lệ mở ngăn kéo với mẫu số (ví dụ `% đúng hạn` → việc hoàn thành có hạn). Số đếm luôn khớp `total`.
- Bỏ thao tác **Nhận việc** của Creator: `POST /tasks/{id}/assign` chỉ cho Owner/Manager, spec không cho thêm luật quyền.
- **Gửi duyệt** trong ngăn kéo đọc `/review` lấy revision rồi gọi `/submit`.
- `/items` không trả `title`; web ghép tiêu đề từ mã drill + i18n. Số lời mời ở nút nhanh lấy từ dữ liệu trang cá nhân.
- `NO_ACTIVITY` = workspace không có task cập nhật và không có bài đăng trong 14 ngày; bấm mở danh sách workspace
  (không có ngăn kéo vì không phải danh sách việc/bài). Cột Client lấy client đầu tiên của workspace.

## Error Handling
- `VALIDATION_ERROR` (400): `range` không hợp lệ.
- `FORBIDDEN` (403): không phải thành viên agency/workspace.
- `AGENCY_NOT_FOUND` / `WORKSPACE_NOT_FOUND` (404).
- Một nguồn phụ lỗi (Postgres tiền/credit, Mongo posts): vẫn trả các khối còn lại, tên khối lỗi nằm trong
  `partialErrors`. UI hiện lỗi riêng khối đó kèm nút thử lại.

## Edge Cases
- Agency chưa có workspace hoặc task: mọi khối hiện trạng thái trống kèm hành động (Tạo workspace, Tạo việc).
- Chưa vào agency nào: tab Phân tích cá nhân trống, gợi ý tạo agency hoặc xem lời mời.
- Workspace `PERSONAL`: tính như workspace thường, không có khối Client.
- Workspace đã lưu trữ/xoá mềm: không vào bảng xếp hạng, vẫn tính vào tiền đã chi của agency.
- Task không có `dueDate`: không tính vào `onTimeRate`, `completionRate`; vẫn tính `finished`, `firstPassRate`.
- Post chưa có số liệu tương tác (`engagementUpdatedAt = null`): tính vào `published`, không tính reach.
- Kỳ trước = 0: hiện giá trị, không hiện %.
- Bị gỡ vai trò giữa chừng: lần gọi API kế tiếp trả phạm vi mới (không cache theo vai trò quá 60 s).

## Out of Scope
Mobile app; thu nhập Creator; xếp hạng Creator với nhau; khoảng thời gian tuỳ ý; xuất PDF riêng (dùng In → Lưu PDF); xuất Excel cho vai trò khác Owner;
dashboard Admin; báo cáo SRS (Report 3–7); duyệt/từ chối ngay trên dashboard; tự ghim/tuỳ chỉnh nút nhanh;
ẩn dòng Cần chú ý; trang việc xuyên workspace; so sánh 2 workspace đặt cạnh nhau.

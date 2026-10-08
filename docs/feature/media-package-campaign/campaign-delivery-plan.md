# Media Campaign — lộ trình triển khai sau Media Package

Ngày: 2026-10-08. Trạng thái: đề xuất triển khai; các quyết định mở bên dưới chưa
được phép coi là BA đã chốt. Chỉ lập kế hoạch trong checkpoint này, chưa code Campaign mới.

## 1. BA đã xác nhận

- Manager tạo một Media Campaign tương ứng với mỗi bản Media Package đã approved
  trong Workspace. Đây là quan hệ với `WorkspaceMediaPackage`, không phải gói trong
  danh mục Agency (`MediaPackage`). Trước khi Manager tạo, thỏa thuận có 0 Campaign;
  sau khi tạo có đúng 1 Campaign.
- Giữ Workspace để hợp tác tiếp với cùng Client. Mỗi đợt cần bản thỏa thuận riêng,
  giữ nguyên lịch sử điều khoản, approval, Campaign và Task của các đợt trước.
- Agency và Client có thể đàm phán đợt kế tiếp khi Campaign hiện tại đang chạy.
  Điều này chưa xác nhận quyền triển khai hai Campaign đồng thời.
- Giữ ba cách đóng gói. RETAINER tính sản lượng theo tháng, không chuyển dư;
  theo quan hệ 1:1 mới, các tháng thuộc kế hoạch bên trong cùng một Campaign.
- Package mới không được ghi đè snapshot của đợt đang thực hiện. Việc sao chép
  gói cũ cho lần hợp tác mới không mang theo approval cũ.
- Event chỉ bàn giao kế hoạch; Workshop chỉ hỗ trợ Meet/survey. Không thêm Task
  type EVENT hoặc triển khai module hậu cần, nhân sự, phát sóng, booking báo chí.

## 2. Hiện trạng đã đối chiếu code và migration

| Phần | Hiện trạng | Khoảng trống |
|---|---|---|
| Package | Catalogue, structured offerings, snapshot, đàm phán, giới hạn lượt Client, thông báo/diff | Chưa có nhiều đợt trong một Workspace |
| Workspace agreement | `workspace_id` đang UNIQUE; repository đọc một bản theo Workspace | Cần định danh đợt và đọc/ghi theo agreement ID |
| Campaign nháp | Create/read/list, package snapshot/version, allocations, khóa tránh phân bổ vượt mức | Prototype cho phép nhiều Campaign một agreement; phải đổi theo BA mới |
| Campaign approve | Trả `CAMPAIGN_APPROVAL_NOT_AVAILABLE` | Chưa có duyệt hai bên và kiểm tra phiên bản |
| Campaign deploy | Chưa có | Cần đầu việc, chống trùng và phục hồi khi lỗi |
| Task | V2/migration dùng Mongo; Content Writing hiện dùng JPA/PostgreSQL | Phải thống nhất tích hợp trước khi sinh backlog |

Không dùng checklist Jira hoặc entity tồn tại để kết luận feature đã hoàn thành.
`previous_terms` hiện chỉ giữ bản liền trước, không phải toàn bộ lịch sử đàm phán.

## 3. Thứ tự triển khai và mapping FR/Jira

| Mốc | FR / Jira | Kết quả bàn giao | Điều kiện bắt đầu |
|---|---|---|---|
| M0 | DA-942/944/945/946; prototype DA-947 | Commit baseline Package và draft đang có | Đã checkpoint; không đánh dấu toàn bộ Jira Done |
| M1 | FR 3.5.3/3.5.4; follow-up E50 mới, liên kết DA-943–946 | Nhiều đợt thỏa thuận trong Workspace, lịch sử và đàm phán đợt tiếp theo | Chốt lifecycle đợt và tạo Jira follow-up trước code |
| M2 | FR 3.5.5 — DA-947 / E50-06 | Một Campaign/thỏa thuận, kế hoạch và work items, UI tạo/xem/sửa nháp | M1; chốt kỳ RETAINER và mapping dịch vụ |
| M3 | FR 3.5.6 — DA-948 / E50-07 | Duyệt hai bên theo contentVersion, thông báo và reset-on-edit | M2; chốt cách Client góp ý |
| M4 | FR 3.5.6 — DA-948; phối hợp E51-01 | Triển khai an toàn thành Task backlog | M3; chốt nguồn Task/editor và quyền chạy Campaign đồng thời |
| M5 | E50-08/09 — DA-949/950 | Danh bạ đối tác và theo dõi hợp tác theo Campaign | Campaign có dữ liệu; không chặn M2/M3 |
| M6 | FR 3.5.7–3.5.10 — DA-951 | Content Request ngoài kế hoạch | Giữ luồng riêng, dùng chung contract sinh Task đã chốt ở M4 |

M1 là mở rộng BA so với scope một Workspace/một agreement cũ. Chưa tự đặt mã
Jira mới hoặc giả định DA-943–946 đã bao gồm toàn bộ phần này. Cần task follow-up
có Epic/Sprint, cập nhật master-plan và mã commit thật trước khi code M1.
Campaign Addendum cũng chưa có task riêng; không tự gộp vào DA-947/948.

## 4. Thiết kế dự kiến cho từng mốc

### M1 — các đợt hợp tác trong một Workspace

- Tái sử dụng `workspace_media_packages` làm bản thỏa thuận từng đợt. Bổ sung
  số thứ tự/nhãn đợt nếu cần, và quy tắc phân biệt đợt đang thực hiện/đang chuẩn bị.
  Trạng thái đàm phán không thay thế trạng thái vòng đời đợt hợp tác.
- Bỏ UNIQUE riêng trên workspace_id bằng migration mới; giữ FK và index truy vấn
  theo Workspace. Chốt giới hạn đợt đang chuẩn bị trước khi chọn partial unique index.
- Audit `findByWorkspaceId`, khóa agreement, DTO, cache/query key, notification link,
  và `workspaces.workspace_media_package_id`. Không dùng một con trỏ duy nhất để vừa
  chỉ đợt đang chạy vừa chỉ đợt đang đàm phán; không chọn bản "mới nhất" một cách ngầm định.
- API selection/negotiate/approve phải chỉ rõ agreement ID và kiểm tra agreement
  thuộc workspaceId của URL. Giữ tương thích endpoint cũ bằng quy tắc tường minh;
  nếu có nhiều agreement và không rõ đích thì báo lỗi, không tự cập nhật nhầm đợt.
- Hard gate lần đầu vẫn theo Package approval. Khi có đợt cũ, đàm phán đợt mới
  không làm mất quyền truy cập chat, lịch sử và công việc đã được phép thực hiện.
- Gói Catalogue được dùng lại nhưng approval/counter/snapshot mỗi đợt độc lập.

### M2 — Campaign planning (DA-947)

- Unique FK `media_campaigns.workspace_media_package_id`: tối đa một Campaign
  cho một agreement, áp dụng với cả draft. Concurrent create phải trả cùng tài nguyên
  hoặc lỗi conflict rõ ràng, không sinh Campaign thứ hai.
- Trước migration: thống kê agreement đã có nhiều Campaign. Không xóa/gộp/sửa liên
  kết tự động; giữ dữ liệu và yêu cầu quyết định với danh sách ID cụ thể nếu gặp.
- Giữ snapshot/version Package; thêm content_version, work_items JSONB và khóa
  optimistic concurrency. Work item có ID ổn định, deliverableId, tên, loại Task
  khi phù hợp, hạn hoàn thành; chưa giao người làm ở bước này.
- Thay prototype chọn sản lượng cho nhiều Campaign bằng kế hoạch cho toàn bộ một
  agreement. Bundle chia theo giai đoạn bên trong Campaign; RETAINER chia theo kỳ
  bên trong Campaign. Số đầu việc không mặc nhiên bằng số sản phẩm bàn giao.
- Cần kỳ bắt đầu/kết thúc rõ cho RETAINER. Không quy đổi durationWeeks thành số tháng
  hoặc tự coi mỗi tháng là 4 tuần. Các ràng buộc này chờ BA ở mục 6.
- UI `/workspaces/:id/campaigns` và trang chi tiết: phạm vi gói đã chốt, chiến lược,
  hướng dẫn thương hiệu, timeline, hạng mục/đầu việc, trạng thái duyệt.
- Giữ route `/api/v1/media-campaigns` đang được UI sử dụng trong thời gian chuyển đổi;
  thêm contract workspace-scoped nhất quán hoặc alias cùng service, không để hai bộ logic.

### M3 — approval (DA-948)

- Agency và Client approve cùng `contentVersion`; lưu actor, version, timestamp.
  Một người không đại diện đồng thời cho hai phía trong cùng thỏa thuận.
- Thay đổi nội dung trước khi chốt làm tăng version và hủy hiệu lực cả hai approval.
  Reject/góp ý không xóa lịch sử duyệt; chính sách góp ý chờ BA xác nhận.
- Sau khi cả hai phía approve, nội dung Campaign bất biến theo BA Campaign hiện hành.
  Dữ liệu vận hành/tiến độ tách khỏi nội dung đã chốt.
- Dùng inbox hiện có, kiểm tra recipient và link đúng Workspace/Campaign; hiển thị
  hai bản khi review thay đổi nếu có phiên bản trước. Không dùng maxChanges của
  Package làm giới hạn sửa Campaign khi chưa có yêu cầu.

### M4 — deployment (DA-948; đang có dependency kiến trúc)

- Chỉ Agency được triển khai Campaign đã được hai bên duyệt. Quyền triển khai khi
  Campaign khác đang chạy chưa được chốt, không suy ra từ quyền đàm phán song song.
- Nếu Task tiếp tục theo V2 Mongo: outbox/deployment record bền vững trong PostgreSQL,
  ID task ổn định, unique key `(campaignId, campaignWorkItemId)`, upsert chỉ tạo mới
  để retry không ghi đè Task đã được Creator xử lý. Partial unique index phải tránh
  ảnh hưởng các Task thủ công/Content Request không có campaignWorkItemId.
- Chỉ chuyển IN_PROGRESS sau khi toàn bộ task cần sinh được ghi thành công. Lưu tiến
  trình/lỗi để retry sau restart; không dựa vào một timestamp hoặc lock trong RAM.
- Phải thống nhất Task ID và cách Content Writing tra cứu trước khi deploy: hiện
  editor có FK PostgreSQL tới tasks. Không dual-write hai nguồn Task độc lập.
- Không init lại Atlas. Nếu cần, chỉ bổ sung migration validator/index có kiểm tra
  dữ liệu hiện hữu và kiểm thử editor của thành viên phụ trách.
- Các Task mới ở BACKLOG, chưa assignee/QC. Identify detail/assign và nội dung
  Livestream/Survey/Meet tiếp tục thuộc E51.

## 5. Repo và commit

- Infrastructure: spec → plan → task → test; migration mới + init đồng bộ. Không sửa
  migration đã commit để thay đổi lịch sử. Tài liệu SQL dùng tag `docs` theo yêu cầu.
- Business Service: agreement selection, campaign service/controller/entity, approval,
  deployment adapter, notification và test phạm vi liên quan.
- Web: các trang Package/Campaign, route/sidebar/gate theo đợt, UI trạng thái;
  thêm key tương ứng trong `src/i18n/locales/{vi,en}/mediaPackage.json` và namespace
  Campaign mới nếu cần. Kiểm tra light/dark, mobile và stale request khi đổi Workspace.
- Gateway: route `/api/v1/**` đã forward Business; chỉ commit khi thực sự cần đổi.
- Không code trên develop, không tự push/merge. Chốt baseline trước khi bắt đầu
  implementation; đồng bộ develop bằng bước riêng có kiểm tra thay đổi đang có.

Commit dự kiến: `docs(DA-947): define one-campaign agreement planning`,
`feat(DA-947): implement versioned campaign plans`,
`feat(DA-948): add two-party campaign approval`,
`feat(DA-948): deploy campaign work items with retry safety`,
`test(DA-948): cover stale approvals and partial deployment recovery`.
M1 dùng mã Jira follow-up thật khi được cấp; không dùng placeholder trong commit.

## 6. Câu hỏi và cổng quyết định

| ID | Cần chốt | Đề xuất để review, chưa phải quyết định |
|---|---|---|
| Q1 | Có cho hai Campaign cùng chạy? | Cho chuẩn bị/duyệt sớm; chốt điều kiện deploy riêng |
| Q2 | Task dùng Mongo hay PostgreSQL, editor nối thế nào? | Giữ V2 Mongo và phối hợp chủ editor; chốt một nguồn chính/ID thống nhất |
| Q3 | Event/press và Workshop Meet trở thành work item gì? | Giữ deliverable kế hoạch; chỉ sinh Task hỗ trợ đúng loại đã thống nhất |
| Q4 | Client trực tiếp sửa Campaign hay gửi góp ý? | Client góp ý, Manager sửa và hai bên duyệt lại |
| Q5 | Ai mở đợt mới, tối đa bao nhiêu đợt chuẩn bị, có hủy draft? | Manager mở một đợt kế tiếp; soft cancel có lịch sử, không reset đợt đang chạy |
| Q6 | RETAINER tính tháng lịch hay chu kỳ từ ngày bắt đầu? Kỳ cuối xử lý thế nào? | Chốt mốc bắt đầu/kết thúc và sản lượng từng kỳ, không suy từ durationWeeks |
| Q7 | Campaign COMPLETED khi có deliverable không phải Task hoặc chỉ có Event/press? | Chốt nghiệm thu phần phi-Task; tránh tự completed khi danh sách Task rỗng |

Không triển khai đoạn phụ thuộc câu hỏi chưa trả lời. Mốc create/approve và deploy
có thể tách bàn giao; không báo hoàn tất FR 3.5.6 khi chưa đi được tới backlog thật.

## 7. Kiểm thử và tiêu chí demo

- Agreement mới có ID và snapshot riêng; chọn lại gói catalogue không sửa đợt trước.
- Đàm phán đợt kế tiếp không chặn Task/chat/lịch sử của đợt đang chạy.
- Không truy cập/sửa agreement hoặc Campaign của Workspace khác bằng cách đổi ID.
- Một agreement chỉ có một Campaign kể cả hai request tạo đồng thời.
- Sửa draft, approve cạnh tranh hoặc approve phiên bản cũ không chốt sai nội dung.
- Retry/deploy song song/crash giữa chừng không sinh trùng hoặc reset Task hiện hữu.
- Demo bằng account hiện có: Package approved → Manager lập Campaign → hai bên duyệt
  → deploy → đọc được backlog thật → mở đợt tiếp theo mà đợt cũ không bị ảnh hưởng.
- Hồi quy Media Package, notification, Workspace settings/gate và Content Writing;
  kiểm thử migration trên dữ liệu cũ và fresh init. Test mới ghi Chưa chạy đến khi có code.

## Nguồn

- [Team guide](../../team_guide.md), [commit convention](../../rule/git-commit-convention.md).
- [FR 3.5.5](3-5-5-create-media-campaign/spec.md), [FR 3.5.6](3-5-6-approve-media-campaign/spec.md).
- [BA](../../ba/04-media-package-campaign.md), [state machines](../../ba/12-state-machines.md).
- [Master-plan](../../plan/brandhub-master-plan.md), [Jira mapping](../../plan/jira_status.json).
- Xác nhận người dùng trong phiên làm việc ngày 2026-10-07/08: một Campaign cho
  mỗi agreement và cho phép đàm phán đợt kế tiếp khi Campaign hiện tại đang chạy.

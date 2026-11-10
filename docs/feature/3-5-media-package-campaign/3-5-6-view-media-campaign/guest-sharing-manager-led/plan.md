# Plan — Guest sharing và Campaign do Manager quản lý

Ngày lập: 2026-11-06. Phạm vi share gồm cả gói Agency và Custom Package workspace; bảo mật nâng cao để team bàn sau. Trạng thái: đã triển khai mã nguồn và migration, đang hoàn tất kiểm chứng; chưa APPLY môi trường ứng dụng hoặc production.

Nguồn nghiệp vụ: [spec.md](./spec.md). Checklist thực thi: [task.md](./task.md). Áp dụng [feature workflow](../../../../rule/feature-workflow.md); cần hoàn tất `test.md` trước khi viết code.

## 1. Mục tiêu và ranh giới

Triển khai hành trình Owner quảng bá gói → Manager ghi nhận thỏa thuận trong workspace → tự chuẩn bị Campaign/task → Manager triển khai. Client xem và góp ý từ DRAFT, không chọn/đàm phán/duyệt Package hoặc duyệt Campaign trên hệ thống.

Giữ nguyên quy trình duyệt kết quả Task/Post, publishing, Content Request, điều kiện closure và phân quyền của các module khác. Việc bỏ duyệt Campaign không bỏ duyệt kết quả công việc. Chưa triển khai checkout, chữ ký điện tử, guest comment hoặc sửa gói sau triển khai.

Đợt lập tài liệu này không chạy migration, seed, đổi dữ liệu local/Atlas hoặc thao tác AWS/production. Các bước triển khai môi trường dùng chung phải có kế hoạch và được người dùng cho phép riêng.

## 2. Cơ sở code hiện tại và phần cần thay

Đường dẫn ở bảng dưới tính từ repo tương ứng; đây là điểm bắt đầu rà soát, không khẳng định mọi logic chỉ nằm trong các file này.

| Thành phần | Hiện trạng đã đối chiếu | Hướng thay đổi |
|---|---|---|
| Business `model/MediaPackage.java` | Có `agencyId`, `customWorkspaceId`, `sourceTemplateId`, `offeringDetails` | Tái sử dụng để phân biệt gói Agency và gói riêng workspace; không tạo bảng gói song song |
| Business `model/WorkspaceMediaPackage.java` | Có `finalTerms`, `termsVersion`, trạng thái đàm phán và timestamp duyệt | Dùng nội dung/phiên bản làm thỏa thuận workspace; bỏ phụ thuộc duyệt trong flow mới |
| Business `MediaPackageServiceImpl` | Có select, negotiate, approve; xử lý khi APPROVED | Bổ sung lệnh lưu thỏa thuận Manager và điều phối chuẩn bị; cô lập endpoint cũ |
| Business `MediaCampaignServiceImpl`, `CampaignPlanValidator`, `CampaignDeploymentServiceImpl`, `CampaignDeploymentProcessor`, `CampaignTaskStore` | Có Campaign/version, tạo task và deployment; request triển khai kiểm tra hai version duyệt và APPROVED | Chuyển điều kiện sang phiên bản gói/kế hoạch đã đồng bộ, quyền Manager và dữ liệu triển khai hợp lệ |
| PostgreSQL `campaign_deployments` | Một bản ghi mỗi Campaign, trạng thái PENDING/FAILED/SUCCEEDED | Giữ theo dõi triển khai thực tế; không dùng SUCCEEDED để diễn tả chỉ chuẩn bị xong DRAFT |
| PostgreSQL `media_campaigns`, `workspace_media_packages` | Đã có định danh, phiên bản, snapshot và lịch sử | Tận dụng trước khi thêm metadata; bảo toàn lịch sử cũ |
| Business `pom.xml`, `service/admin/AdminReportPdf.java` | Đã có OpenPDF và cách tạo PDF | Tái sử dụng thư viện/font phù hợp, không mặc định cần dịch vụ xuất file ngoài |
| Web `src/pages/media-package/`, `src/pages/campaign/`, `src/pages/workspace/` | Có catalog, gói workspace, form Campaign, review/delivery, tạo workspace | Thay hành trình và gate cũ; tái sử dụng editor hạng mục và component hiển thị |
| Gateway và Business security | API nghiệp vụ dùng xác thực | Mở hẹp API GET guest cho hai phạm vi gói; giữ xác thực với cấu hình share, export và workspace |

Workspace Web hiện có phần mời Client tùy chọn. Cần kiểm tra cả DTO, service, DB và các guard điều hướng trước khi xác định có cần sửa thêm; không viết lại phần đã đáp ứng.

## 3. Giai đoạn 1 — Chốt contract và tương thích

### 3.1. Hai phạm vi gói

- Gói Agency dùng để quảng bá, không gắn `customWorkspaceId`. Owner quản lý và phát hành share.
- Manager phụ trách/Owner có quyền quản lý được share và export bản gói workspace đã lưu, không tự đưa gói đó lên catalog Agency.
- Gói workspace dùng bản riêng với `customWorkspaceId`, `sourceTemplateId` khi lấy mẫu; `workspace_media_packages` giữ thỏa thuận hiệu lực và phiên bản.
- Khi chọn mẫu, sao chép nội dung đã lưu và nguồn tham chiếu trong một thao tác. Sửa mẫu sau đó không sửa bản workspace.
- Một workspace có một thỏa thuận hiệu lực và một Campaign. Lưu lần sau cập nhật cùng định danh, không tạo lại Campaign.
- Xác định một nguồn dữ liệu hiệu lực cho điều khoản (`finalTerms` và schema DTO); không cho hai bản sao gói/thỏa thuận cập nhật độc lập gây lệch nhau.

### 3.2. API dự kiến

Các route dưới là contract đề xuất, cần rà soát xung đột với route hiện có trước khi code. Giữ envelope/error convention của dự án.

| API | Quyền và hành vi |
|---|---|
| `GET/POST/DELETE /api/v1/agencies/{agencyId}/media-packages/{packageId}/share` | Owner đúng Agency xem/phát hành/thu hồi link quảng bá |
| `GET/POST/DELETE /api/v1/workspaces/{workspaceId}/media-package/share` | Manager phụ trách/Owner có quyền quản lý xem/phát hành/thu hồi link của thỏa thuận workspace |
| `GET /api/v1/workspaces/{workspaceId}/media-package/export?format=pdf|png` | Manager phụ trách/Owner có quyền quản lý xuất đúng nội dung thỏa thuận workspace đã lưu |
| `GET /api/v1/public/media-packages/{shareId}` | Guest đọc DTO công khai của bản gói mới nhất; không trả entity trực tiếp |
| `GET /api/v1/agencies/{agencyId}/media-packages/{packageId}/export?format=pdf|png` | Owner xuất nội dung đã lưu; kiểm tra Agency/scope phía server |
| `PUT /api/v1/workspaces/{workspaceId}/media-package` | Manager lưu gói mới hoặc cập nhật, kèm `expectedTermsVersion`, request idempotency key và dữ liệu hạng mục |
| `POST /api/v1/workspaces/{workspaceId}/media-package/impact` | Tính danh sách task chịu tác động khi giảm/xóa/đổi loại; chưa ghi dữ liệu |
| `GET /api/v1/workspaces/{workspaceId}/media-package/preparation` | Đọc phiên bản đang chuẩn bị, trạng thái, số task và lỗi có thể thử lại |
| `POST /api/v1/workspaces/{workspaceId}/media-package/preparation/retry` | Thử lại đúng phiên bản đang lỗi, không tạo thỏa thuận/Campaign mới |
| API Campaign/feedback/deploy hiện có | Giữ route khi phù hợp; đổi gate nghiệp vụ, trả capability rõ cho Web |

`PUT` đầu tiên tự ghi nhận yêu cầu chuẩn bị. Có thể trả `202` với Campaign DRAFT và trạng thái chưa đồng bộ; chỉ thông báo sẵn sàng khi toàn bộ task đã được xác minh. Trong revision hiện hành, cùng idempotency key và cùng payload trả cùng kết quả; cùng key khác payload trả conflict. Key/revision cũ sau lần chỉnh sửa tiếp theo trả version conflict thay vì áp lại dữ liệu cũ; không tạo bảng lưu mọi request. Khóa phiên bản phải dựa vào server, không dựa nút disabled trên Web.

Response workspace nên có capability như `canEditPackage`, `canDeploy`, `canComment` và nguyên nhân không khả dụng. Không suy quyền Manager từ role gửi trong request. Lỗi phân biệt thiếu quyền, phiên bản xung đột, gói bị khóa, đồng bộ chưa xong, tác động chưa xác nhận và dữ liệu triển khai thiếu.

## 4. Giai đoạn 2 — Database, init và seeder

### 4.1. PostgreSQL

Ưu tiên mở rộng bảng hiện có, không tạo thêm bảng chỉ để thay tên nghiệp vụ.

| Bảng | Thay đổi dự kiến |
|---|---|
| `media_packages` | Metadata link chia sẻ: định danh ngẫu nhiên đủ mạnh, bật/tắt chia sẻ, thời điểm phát hành/thu hồi; unique index cho định danh link. Hỗ trợ gói Agency và gói workspace, tách quyền phát hành theo scope |
| `workspace_media_packages` | Metadata share gói workspace cần trỏ đúng thỏa thuận hiệu lực, không trỏ bản mẫu; tận dụng package ID gắn workspace và kiểm tra mapping. Metadata chuẩn bị gồm `manager_led`, `preparation_status`, actor/lease/lease_until/error và last_request_id/hash. Tái sử dụng terms_version cùng work_items/deliverable_plan của Campaign làm manifest bền vững, không lưu thêm bản JSON trùng |
| `media_campaigns` | Giữ một Campaign/workspace, content version và snapshot. Ghi rõ revision thỏa thuận đã đồng bộ; bỏ gate hai lượt duyệt ở flow mới |
| Bảng version/history hiện có | Ghi thay đổi gói và tác động lên kế hoạch; giữ lịch sử approval/đàm phán cũ, không tạo approval giả |
| `campaign_deployments` | Tiếp tục là trạng thái triển khai; cố định revision/snapshot khi yêu cầu deploy và giữ cùng bản khi retry |

Metadata chuẩn bị thuộc thỏa thuận có vòng đời riêng với deployment. Dùng trạng thái/revision/lease trên thỏa thuận và manifest `work_items` trên Campaign đã có, chưa tạo bảng job mới. Manifest chỉ giữ định danh, revision và dữ liệu kỹ thuật cần retry; không sao chép toàn bộ Task/comment sang SQL. Đánh giá kích thước theo giới hạn sản lượng hiện hành trước khi chốt.

Giữ `APPROVED` và các cột duyệt cũ trong giai đoạn tương thích, không xóa enum/cột gây lỗi client cũ. Flow mới không ghi nhận duyệt và không yêu cầu chúng. Cần kiểm tra trigger, constraint, index, function và query hiện dùng trạng thái cũ, không chỉ sửa Java enum.

### 4.2. MongoDB

- Tái sử dụng collection `tasks`, index duy nhất Campaign/work item và định danh work item ổn định.
- Không thêm trạng thái Task để mô tả đồng bộ gói. TODO là trạng thái công việc, preparation là trạng thái kỹ thuật riêng.
- Chỉ thêm metadata revision/operation trên Task nếu contract hiện tại chưa đủ chống ghi cũ; cập nhật validator/index cùng lúc nếu cần.
- Giữ assignee, supervisor, brief, deadline, subtask, comment và lịch sử của task không đổi. Không reset workflow để làm migration chạy qua.
- Không đổi schema Post, task approvals, chat hoặc content requests cho mục đích bỏ duyệt Campaign.

### 4.3. Cách nâng cấp

1. Viết migration có preflight: kiểm kê scope gói, Campaign trùng workspace, task trùng nguồn, trạng thái/lịch sử cũ và constraint xung đột.
2. Thực hiện additive trước. Bản cài mới trong `docs/database/init-postgres-v2.sql` và `docs/database/init-mongo.js` phải đạt cùng schema đích với DB nâng cấp.
3. Cập nhật các seeder thực sự tạo dữ liệu liên quan trong Business: rà soát `WorkspaceSeeder`, `CampaignSeeder`, `TaskSampleSeeder`, `LinkedDemoSeeder`, `DataSeeder` và các seeder Mongo được chúng gọi. Không tạo seed cần duyệt Client để dùng flow mới.
4. Không backfill ý nghĩa thỏa thuận/approval bằng suy đoán. Dữ liệu không xác định đưa vào báo cáo xử lý riêng, không tự xóa.
5. Kiểm tra fresh init, upgrade DB mẫu và chạy lại migration/seeder. Không chỉnh migration của thành viên khác; thêm migration chuyển tiếp, chỉ sửa init thuộc phạm vi cần thiết.

## 5. Giai đoạn 3 — Lưu gói và đồng bộ Campaign/task

### 5.1. Ghi nhận và retry giữa hai database

Không có transaction nguyên tử chung cho PostgreSQL và MongoDB. Dùng thao tác bền vững có revision và worker retry, không giữ transaction SQL mở trong lúc chờ ghi Mongo.

1. Transaction SQL khóa thỏa thuận/Campaign của workspace theo thứ tự cố định; kiểm tra quyền, version và chưa bắt đầu deployment.
2. Validate gói, tính chênh lệch trên ID hạng mục ổn định. Sinh trước manifest với ID work item/task cố định, tạo hoặc cập nhật Campaign DRAFT và đánh dấu preparation PENDING trong cùng transaction.
3. Worker claim operation bằng lease và revision. Thực hiện upsert có điều kiện trên Mongo; unique index là hàng rào chống nhân đôi, không phải cơ chế ghi đè dữ liệu.
4. Giữ trường người dùng đã nhập; cập nhật có kiểm soát các trường do gói quản lý. Dùng workflow revision/CAS cho task đã tồn tại, không `replace` toàn document.
5. Đối chiếu đủ task theo manifest và kiểm tra operation vẫn là bản hiện hành trước khi đánh dấu READY trong SQL. Đếm đúng task thuộc gói, không tính thêm Content Request/subtask.
6. Crash, timeout hoặc lease hết hạn được retry cùng operation/ID. Không xóa task đã ghi chỉ vì bước SQL sau thất bại; phục hồi và đối chiếu operation đã lưu.

Trong khi preparation chưa READY, chặn lưu revision tiếp theo và deploy để tránh hai bản chạy chồng; Web giữ bản nhập và cho theo dõi/thử lại. Điều này không thêm bước xác nhận của Client. Dùng lỗi có request/operation ID để trace xuyên DB.

### 5.2. Thay đổi sản lượng và bảo toàn dữ liệu

- Hạng mục không đổi: giữ ID và các task tương ứng; tăng số lượng chỉ tạo thêm các ID chưa tồn tại.
- Không dùng vị trí mảng hoặc tiêu đề để nhận diện hạng mục. Đổi loại không được tái sử dụng task của loại cũ như thể cùng nội dung.
- Giảm/xóa/đổi loại phải có impact response chứa task cụ thể và revision dùng tính tác động. Xác nhận của Manager phải khớp cùng revision; server tính lại khi lưu.
- Phương án an toàn đợt đầu: chặn giảm/xóa các task có thông tin do người dùng sửa, subtask, comment, nội dung liên kết hoặc lịch sử bắt đầu/duyệt. Giữ toàn bộ gói/kế hoạch cũ khi bị chặn; không tự chuyển các task đó sang CANCELLED.
- Chỉ xem xét bỏ task TODO nguyên bản do hệ thống sinh, không có phụ thuộc, sau khi Manager xác nhận. Phải chứng minh kiểm tra phụ thuộc và thao tác bỏ an toàn trước ghi đồng thời; nếu chưa có cơ chế fence chung cho các writer liên quan thì vẫn chặn, không kiểm tra rồi xóa theo hai bước rời.
- Ghi nhận ID và lý do thay đổi trong lịch sử gói/operation để retry không tác động nhầm task khác. Không dùng phép giảm số lượng để xóa nội dung của module khác.

Cách xử lý task có dữ liệu khi giảm sản lượng là điểm cần team review trước khi mở rộng hỗ trợ. Phương án mặc định là chặn có giải thích, phù hợp yêu cầu không đồng bộ khi chưa an toàn trong spec.

## 6. Giai đoạn 4 — Guest link và xuất file

### 6.1. Link public

Owner phát hành link cho gói Agency; Manager phụ trách/Owner có quyền quản lý phát hành link cho Custom Package workspace. Link workspace đọc đúng thỏa thuận mới nhất đã lưu, không dùng bản mẫu hoặc điều khoản cũ trên entity nguồn. Dùng cùng cơ chế link ổn định, thu hồi và tạo lại cho hai phạm vi. Dùng định danh ngẫu nhiên tối thiểu 128 bit entropy, không dùng ID tuần tự hoặc package ID như quyền truy cập. Không ghi link đầy đủ vào log/analytics; cấu hình referrer policy phù hợp.

Đề xuất link không tự hết hạn ở đợt đầu; Người quản lý có quyền tương ứng chủ động thu hồi. Đây là đề xuất vòng đời để team review sau. Chưa thêm OTP, mật khẩu, xác minh email hoặc điều kiện phê duyệt bảo mật nâng cao vào phạm vi triển khai hiện tại. Không phát hành link mặc định cho mọi gói hiện có.

GET public kiểm tra scope, trạng thái link và gói còn tồn tại, trả allowlist DTO: nhận diện Agency được công bố, tên/phạm vi gói, hạng mục, sản lượng/đơn vị, ngân sách/thời lượng nếu có. Với gói workspace, trả thêm điều khoản của đúng thỏa thuận được chia sẻ nhưng không trả DTO workspace, Client Profile, user IDs, approval/history hoặc asset nội bộ. Không công khai danh sách gói workspace.

Đợt đầu trả `Cache-Control: no-store` để tải lại luôn đọc bản mới và thu hồi có hiệu lực. Rate limit theo client ở Gateway và giới hạn payload phía server. Chỉ cấu hình public cho route/method guest cụ thể ở cả Gateway và Business; không `permitAll` toàn nhóm media package. Link sai/thu hồi trả thông báo không khả dụng chung.

### 6.2. PDF và ảnh

- DTO nội dung gói theo scope được kiểm tra quyền và đọc nhất quán tại một revision sẽ làm nguồn chung cho guest/export. Export không lấy dữ liệu biểu mẫu chưa lưu.
- Dùng font Liberation Sans sẵn có và layout A4 dùng chung. OpenPDF xuất text/vector có thể chọn/copy; Java2D headless xuất PNG. Không thêm dịch vụ bên ngoài.
- PDF và PNG dùng cùng layout đo chữ bằng OpenPDF BaseFont; ảnh xuất là ZIP các PNG theo thứ tự. Giới hạn hai lượt export đồng thời, tối đa 200 trang và giới hạn dung lượng bộ xuất; xử lý từng trang, không giữ toàn bộ bitmap trong bộ nhớ.
- Gói dài xuất một PDF nhiều trang; ảnh nhiều trang trả một bộ tải về có thứ tự, đề xuất ZIP chứa PNG. Định dạng bộ ảnh cần review trước khi chốt UI/API.
- Stream file tạm trong thời gian request và dọn sau khi hoàn tất/thất bại. Chưa lưu lâu dài lên S3, chưa phát sinh quota mới. Giới hạn số trang/pixel/thời gian và request đồng thời dựa trên giới hạn nội dung hợp lệ, lỗi phải rõ và có retry.
- Asset/font từ nguồn cho phép; không cho renderer fetch URL tùy ý. Có tên Agency, tên gói, thời điểm xuất; filename và nội dung Unicode được xử lý đúng.

## 7. Giai đoạn 5 — Campaign, Client feedback và khóa triển khai

1. Client đúng workspace được đọc Campaign DRAFT và gửi feedback theo API hiện có. Góp ý không thay version kế hoạch hoặc tạo approval. Giữ phân quyền/lifecycle comment hiện hành.
2. Bỏ gate chọn/duyệt gói, nhắc Client duyệt Campaign, các timestamp/version duyệt bắt buộc ở flow mới và điều hướng ép Client hoàn thành bước đã bỏ.
3. Deploy yêu cầu quyền quản lý hiệu lực, Campaign DRAFT hợp lệ, preparation READY đúng phiên bản, đủ điều kiện kế hoạch/task. Không yêu cầu Client tồn tại hoặc approve Campaign.
4. Trong transaction SQL, deploy khóa cùng bản ghi/thứ tự như lưu gói, cố định snapshot/revision. Chặn sửa gói và phạm vi kế hoạch từ lúc nhận deploy, kể cả lúc deployment FAILED; retry cùng bản cố định.
5. Processor đối chiếu manifest và task, không tạo bản kế hoạch/task song song. Chỉ chuyển IN_PROGRESS khi xác minh đủ công việc. DRAFT đã có task không đồng nghĩa đã triển khai.
6. Bắt đầu Task vẫn yêu cầu Campaign IN_PROGRESS. Hoàn thành Campaign giữ điều kiện closure; Client không có quyền deploy/complete chỉ vì được góp ý.

Endpoint approve/select/negotiate cũ không được tiếp tục là đường ghi bỏ qua luật mới. Cần lập danh sách Web/mobile đang gọi: chuyển client được hỗ trợ trước, sau đó trả lỗi deprecation có mã rõ cho mutation bị thay thế; không giả vờ approve thành công. Với dữ liệu APPROVED cũ, cho adapter kiểm tra điều kiện mới và đi tiếp mà không tạo lượt duyệt giả; giữ lịch sử đọc và không tự reset Campaign đang chạy.

## 8. Giai đoạn 6 — Web và hành trình người dùng

| Màn hình/file chính trong Web | Nội dung thay đổi |
|---|---|
| `src/pages/media-package/agency.tsx`, catalog/card/detail, service/types | Owner xem gói Agency, nút Share/Export một bước; trạng thái phát hành/thu hồi/xuất file |
| Route guest mới trong `src/App.tsx`, component guest trong module media-package | Ngoài AuthGuard/workspace layout; skeleton, nội dung quảng bá, lỗi link; không fetch API tài khoản/workspace |
| `src/pages/workspace/create.tsx`, hook và form tạo workspace | Cho tạo khi chưa có Client, vẫn gán Manager đúng quyền; không xóa capability mời Client tùy chọn đã có |
| `src/pages/media-package/index.tsx`, `SelectedMediaPackage`, `CreateCustomPackageForm`, `OfferingEditor`, hook/service/types | Manager chọn mẫu hoặc tạo mới, lưu trực tiếp, share/export bản đã lưu, xem tác động thay đổi, theo dõi preparation; Client chỉ đọc |
| `src/pages/campaign/index.tsx`, `CampaignForm`, `CampaignReview`, `CampaignDelivery`, `CampaignNextStep` | DRAFT feedback, một action deploy của Manager, bỏ approval Campaign và CTA giả thành công; phân biệt chuẩn bị/triển khai |
| Các guard/sidebar/checklist liên quan | Bỏ redirect theo Client approval; giữ membership và quyền module khác |

Không cần làm mới toàn bộ UI. Ưu tiên hành trình ngắn, sửa tại đúng ngữ cảnh, không dùng confirm mặc định của trình duyệt. Gói đang đồng bộ hiển thị tiến độ và retry; dữ liệu gói lỗi vẫn giữ bản nhập của Manager. Khi conflict cho tải bản mới, không tự ghi đè.

Locale hiện tại tách theo namespace: sửa song song `src/i18n/locales/vi/mediaPackage.json` và `en/mediaPackage.json`; `vi/campaign.json` và `en/campaign.json`; thêm key ở cặp `workspace.json`/`common.json` chỉ khi có nhãn tương ứng. Đối chiếu tên file thực tế khi triển khai; dùng namespace `mediaPackage.share.*`, `.guest.*`, `.workspace.*`, `campaign.feedback.*`. Không gom lại thành hai file locale lớn chỉ để theo mẫu tài liệu cũ.

Kiểm tra light/dark bằng token hiện hành, keyboard/focus, dialog, mobile và nội dung dài. Các action chỉ ẩn/khóa theo capability server nhưng server vẫn kiểm quyền từng request.

## 9. Giai đoạn 7 — Kiểm thử, chuyển đổi và bàn giao

Trước code, viết `test.md` theo AC-01 đến AC-12; không coi checklist tài liệu là test đã chạy. Bộ xác minh gồm:

- Backend: quyền/scope, public DTO, invalid/revoked link, latest revision, export dài và tiếng Việt; regression endpoint cũ.
- PostgreSQL/Mongo cô lập: fresh init/upgrade, unique identity, retry/crash ở từng ranh giới, lease hết hạn, CAS và hai request đồng thời, lưu đua với deploy.
- Dữ liệu: gói tăng số lượng, đổi tên, giảm có phụ thuộc bị chặn, task đã nhập giữ nguyên, cùng mẫu được dùng ở nhiều workspace không ảnh hưởng nhau.
- UI: Owner → guest → workspace chưa Client → Manager lưu và share gói workspace → Client guest xem đúng thỏa thuận → Client DRAFT comment → deploy → Task bắt đầu; state lỗi/trống/loading, vi/en, light/dark/mobile.
- Regression: Task/Post approval, content writing/editor, Content Request, publishing và closure. Không gọi AI có phí hoặc publish thật để kiểm tra flow này nếu chưa được cho phép.
- Tương thích: Web/mobile cũ không ghi sai qua endpoint cũ; lịch sử cũ còn đọc được; Campaign đang chạy không bị reset.

Triển khai theo thứ tự: kiểm kê/đóng writer cần thiết → schema additive → Business/Gateway tương thích → Web mới → kiểm tra read/write có kiểm soát → chuyển client cũ → dọn code obsolete ở đợt riêng. Không drop lịch sử hoặc enum cũ trong lần rollout đầu.

Rollback ưu tiên quay ứng dụng về bản tương thích schema additive, giữ operation đang dở để phục hồi; không dùng down migration xóa Task/Campaign mới. Trước rollout cần có phiên bản ứng dụng lùi tương thích với luật mới; không quay về bản cho Client duyệt để mở khóa dữ liệu mới.

## 10. Điểm cần review và điều kiện bắt đầu code

| Điểm | Đề xuất trong plan | Tình trạng |
|---|---|---|
| Vòng đời link | Owner cho gói Agency; Manager phụ trách/Owner có quyền cho gói workspace; đề xuất không hết hạn tự động, thu hồi/tạo lại được | Cần review; spec chưa chốt |
| Bộ ảnh dài | PNG từng trang trong ZIP; PDF text/vector nhiều trang, cùng layout A4 | Đã kiểm thử nhiều trang/tiếng Việt; PDF chọn/copy được text |
| Giảm task đã có dữ liệu | Chặn có impact cụ thể; không tự xóa/hủy hoặc chuyển lịch sử | Phương án an toàn trong giới hạn spec; review trước khi mở rộng |
| Coordination SQL/Mongo | Durable preparation trên thỏa thuận, manifest Campaign, lease; deployment riêng | Đã kiểm thử hai save đồng thời và phục hồi trên DB QA |
| Client cũ/mobile | Inventory endpoint cũ, chuyển client rồi khóa mutation cũ | Cần phối hợp chủ module trước rollout |

Hoàn tất plan/task review và `test.md`, chốt API/DB contract cùng các điểm trên, sau đó mới thực thi checklist. Tiêu chí hoàn thành là AC được kiểm chứng và tài liệu/init/seeder khớp code; không đánh dấu xong chỉ vì build thành công.


## 11. Contract thực thi và bàn giao 2026-11-06

- Migration nâng cấp: `docs/database/migrations/2026-11-06-manager-led-package-sharing.sql`; cần baseline gói/Campaign và `custom_workspace_id` từ migration 2026-11-04.
- Fresh init khai báo schema cuối ngay trong CREATE TABLE. Không chạy lại init trên DB đang có dữ liệu.
- Thay schema PostgreSQL: `media_packages`, `workspace_media_packages` và CHECK action/actor của `package_negotiation_events` (thêm MANAGER_SAVE, không ghi counter-offer/approval giả). Không tạo bảng nghiệp vụ mới.
- Schema Mongo không đổi; Task dùng định danh/index hiện có. Campaign/work_items/version là manifest, giữ dữ liệu người dùng bằng `$setOnInsert` khi phục hồi.
- API impact trả task ID/tên bị ảnh hưởng. Đợt đầu chặn toàn bộ giảm/xóa/đổi loại làm loại bỏ task hiện có, kể cả task chưa nhập thêm; chưa có thao tác xác nhận để xóa chúng. Tăng số lượng và sửa metadata được hỗ trợ.
- Mutation select/negotiate/approve cũ và tạo custom workspace qua endpoint Agency trả PACKAGE_WORKFLOW_REPLACED. Web mới dùng PUT workspace package; lịch sử vẫn có thể đọc. Mobile cần cập nhật caller trước rollout chung.
- Link Agency đọc package; link workspace đọc final_terms của đúng agreement, không đọc mẫu. Cơ chế OTP/mật khẩu/xác minh email chưa triển khai theo quyết định người dùng.
- Chuẩn bị dùng PENDING → PROCESSING → READY/FAILED; lease hết hạn được claim lại. Retry FAILED dùng đúng termsVersion. Deploy khóa thành DEPLOYING và sau thành công thành DEPLOYED; deployment lỗi vẫn khóa gói và retry cùng bản.

### Runbook áp dụng (chưa thực thi trên DB ứng dụng)

1. Team review diff và chuyển các client còn dùng mutation cũ. Xác định đúng PostgreSQL môi trường đích và quyền APPLY riêng; không suy authorization production từ yêu cầu viết code.
2. Dừng writer liên quan theo lịch thống nhất. Chạy kiểm kê duplicate Campaign/thỏa thuận và các constraint/schema xung đột. Giữ báo cáo Task/approval cũ, không reset hoặc seed lại.
3. Chạy duy nhất migration 2026-11-06 trên DB đã có baseline, với stop-on-error. Migration nằm trong transaction, có preflight và có thể chạy lại. Nếu thiếu prerequisite thì dừng, không chạy init bù.
4. Deploy/restart Business và Gateway cùng Web mới. Kiểm tra anonymous GET chỉ mở route guest; private share/export/save vẫn bắt quyền.
5. Manual test với một workspace chưa Client: Manager lưu → preparation READY → share guest/export → Client xem/góp ý DRAFT → Manager hoàn thiện kế hoạch → deploy → Task được bắt đầu.
6. Nếu lỗi, giữ operation/revision và dữ liệu đã tạo để trace/retry. Không rollback bằng cách xóa Task hoặc giả lập Client approval. Chỉ quay ứng dụng về phiên bản hiểu schema và flow manager-led.

Bằng chứng kiểm thử và các phần chưa kiểm tra thủ công ghi tại [test.md](./test.md). Không tự commit/push hoặc thay nhánh/worktree trong đợt triển khai này.


## 12. Format proposal xuất gói

Tham khảo cấu trúc công khai của The Social Media Agents (https://www.thesocialmediaagents.com/), Go Thrive Marketing (https://gothrivemarketing.com/wp-content/uploads/2021/08/Social-Media-Packages-2021-Web.pdf) và HubSpot (https://53.fs1.hubspotusercontent-na1.net/hubfs/53/assets/directories/business-templates/files/EN/marketing-proposal-file-pdf.pdf). Thiết kế riêng cho dữ liệu BrandHub, không sao chép branding/nội dung hoặc thêm điều kiện thương mại của các mẫu.

Tách layout thành danh sách phép vẽ theo tọa độ A4. Dùng OpenPDF BaseFont đo chữ để word-wrap thống nhất; canvas PDF vẽ text/vector, canvas PNG dùng Java2D cùng font Liberation Sans. Không cần thư viện raster PDF hoặc dịch vụ ngoài. Phân trang trước, sau đó thêm header/footer và tổng số trang. Bảng tổng quan hạng mục ngắn, chi tiết mô tả/tiêu chí nằm ở phần riêng, tiêu đề lặp khi tiếp tục trang.

Giữ endpoint/format cũ, thêm query `language=vi|en` tùy chọn, mặc định vi. Web gửi ngôn ngữ hiện hành khi export. Không đổi DB, permission hoặc luồng lưu gói. Giữ semaphore 2 lượt, giới hạn trang/dung lượng; ảnh tiếp tục đóng ZIP. Preview QA dùng dữ liệu giả, lưu trong keep-local-only, không commit file xuất.


### Điều chỉnh nhãn export theo review

Bỏ dòng “Đề xuất gói truyền thông”, cột Lượt sửa, hai chú thích dưới Ngân sách/Thời lượng và dòng sản lượng toàn gói. Dùng “Ngân sách”, “Số lượng”, “Mô tả thực hiện”, “Mục tiêu đạt được”. Dòng mô tả dịch vụ dùng số lượng tự nhiên, ví dụ “12 bài đăng mạng xã hội”, “1 sự kiện”, “2 buổi livestream”, “1 danh sách đề xuất báo điện tử”, “2 buổi workshop”. Cập nhật tương ứng en; chỉ thay phần trình bày export, không xóa revisionLimit trong dữ liệu. Kiểm tra lại PDF/PNG sau thay đổi.


### Báo điện tử — làm rõ cách hiển thị cho Client

Cập nhật nhãn vi/en mediaPackage, đơn vị hiển thị trên OfferingSummary và MediaPackageCard, và nhãn/câu số lượng/đơn vị trong PackageProposalLayout. Giữ nguyên đơn vị lưu/API hiện hành để không làm lỗi validator và dữ liệu cũ; thay đổi nghiệp vụ unit/type backend cần đợt đồng bộ riêng. Chỉ cập nhật text, giữ theme/layout và khả năng keyboard hiện hành.


### Xuất ảnh trang đầu theo xác nhận

Đổi renderer ảnh thành JPEG trang đầu, controller trả image/jpeg và filename .jpg; Web gửi format=jpg và tải .jpg. Đổi contract format ảnh từ png sang jpg đồng bộ Web và Business; format khác trả INVALID_REQUEST. Không đổi dữ liệu/permission/share/PDF.


### Bản xem theo format proposal

Tạo PackageProposalView read-only dùng chung, nhận subset MediaPackage tương thích PublicPackage. Thay nội dung MediaPackageDetail, WorkspaceMediaPackagePage và GuestMediaPackagePage, không đổi fetch/API hoặc form chỉnh sửa. Dùng namespace mediaPackage.proposal vi/en song song, semantic table tự wrap không min-width cố định, thứ bậc h1/h2/h3/h4 phù hợp. Giữ OfferingSummary cho các màn legacy ngoài phạm vi.


### Workspace package — overview gọn và share menu

Tách layout WorkspacePackageOverview từ orchestrator để không trộn thêm JSX vào index. Dùng MediaPackageCard compact cho gói hiện tại và MediaPackageCatalog với onViewPackage external để mở chi tiết full width. Cho catalog enabled theo role OWNER/MANAGER/CLIENT, vẫn dùng API workspace-scoped sẵn có. Card dùng native button overlay, các action nằm lớp trên không bị trigger xem. PackageShareActions dùng Radix DropdownMenu, trigger icon 44px có aria-label; fallback copy giữ input chỉ khi clipboard thất bại. Thêm nhãn layout và menu vi/en song song; giữ theme semantic và focus restore của InlineWorkArea.


### Sketch được duyệt — detail trái, list phải

WorkspacePackageOverview quản lý search/visibleCount (12 tăng dần) và pane scroll. Parent giữ viewing bằng ID để bản chi tiết lấy từ dữ liệu mới, fallback current hoặc catalog đầu khi không còn ID. Dùng card compact với aria-pressed cho card đang xem, selected badge chỉ gói đang dùng. Bỏ nhánh MediaPackageDetail full width ở Workspace, giữ component đó cho Agency/catalog cũ. Scoped media-package layout ở Layout main để xác định chiều cao, PageWrapper h-full; form chỉnh sửa vẫn cuộn tự nhiên. Locale thêm danh sách/đang xem/không có gói/no results. Không API/DB mới.


### Sketch compact được duyệt — mô tả ngắn và bảng mở chi tiết

Viết lại PackageProposalView dùng chung dạng compact; optional actions prop để Workspace đặt sửa/share cạnh tên thay vì thêm toolbar riêng. Tách ExpandablePackageText đo overflow thực bằng ResizeObserver (không ước lượng ký tự) và PackageDeliverableRow giữ state mở từng hàng, aria-controls/expanded, text đầy đủ không bị xóa. Key proposal theo viewed package ID để reset mở/thu gọn khi đổi gói. Locale mediaPackage.proposal thêm packageDescription, view/expand/collapse/detailsFor/noDetails. Giữ scopeDescription, quyền action/fetch và export renderer.


### UI v3 đã duyệt — cam nhạt, xám/trắng và nội dung theo không gian

Dùng token BrandHubDesign.md và globals.css: bg-muted, bg-card, bg-brand-orange-soft, border-brand-orange, Button orange/secondary; không palette mới. PackageProposalView có header/body/table wrapper; PackageDeliverableRow dùng FileText/Target, bỏ title lặp, ô trắng trên xám. Thêm usePackageDetailSpace trong hooks: đo toàn row ở trạng thái text đầy đủ và so article với viewport; đo/khôi phục inline clamp tạm đồng bộ trong callback trước paint, chỉ chạy theo width/height/content/language để tránh vòng lặp đo do chính clamp gây ra. ExpandablePackageText nhận limitLines null hoặc 2, manual expand vẫn ưu tiên. Đánh dấu article/viewport/text/toggle bằng data attributes, không query theo nhãn dịch. Row và text giữ aria-controls/expanded, semantic keyboard. Card compact highlight nền cam nhạt theo sketch. Không DB/API/export thay đổi.


### Số lượng đầu hàng và tự mở hạng mục khi có chỗ

Thêm usePackageDisclosure cấp proposal: giữ auto IDs và manual overrides; đo root/base height và full height từng detail row (hidden rows vẫn mounted), phân bổ phần trống theo thứ tự sau khi dành chỗ cho manual-open. Đo đồng bộ rồi khôi phục hidden/clamp/toggle trước paint; ResizeObserver chỉ set state khi tập IDs đổi để tránh loop. Giữ usePackageDetailSpace cho text dài mở thủ công. Bảng 3 cột, detail colSpan=3, PackageDeliverableRow controlled. Event hàng bỏ qua interactive target và chọn text; Button gọi cùng toggle. Reserve scrollbar gutter desktop để phép đo không làm đổi bề ngang. Locale không phát sinh nhãn mới.


### PDF và JPG theo sketch duyệt 06/11/2026

Cập nhật PackageProposalLayout dùng layout chung PDF/JPG: mô tả trước facts, bảng 2 cột, header cam nhạt, detail header quantity+name, fields dọc. JPG ghép tối đa hai cột rồi nối hàng cho tài liệu trên hai trang để giữ khả năng đọc và giới hạn kích thước; kiểm tra pixel budget trước cấp phát, không bỏ trang. Giữ PDF full text/embedded font, MIME và filename.


### Chọn ngôn ngữ khi xuất file

Dùng Radix DropdownMenuSub sẵn có cho từng định dạng, hai menu item ngôn ngữ. Truyền language tường minh vào export API; tên file có mã ngôn ngữ. Copy/revoke share giữ nguyên. Không thêm modal/state cấu hình ngôn ngữ hoặc thay backend renderer.


### Ngôn ngữ trang guest

Thêm group hai Button aria-pressed/lang trên guest page trước query states; dùng i18n.changeLanguage và handler lưu lựa chọn đã có trong i18n/index.ts. Không đổi queryKey, API public, token hoặc quyền. Token màu semantic, responsive, locale song song.


### Form nhập liệu theo sketch đã duyệt

Đổi OfferingEditor có state selected và cache draft; fixed 4 service rows, legacy entries chỉ hiển thị giữ nguyên. Tách SuggestedPackageText giữ text controlled, options theo locale và chỉ thao tác dòng khớp; không vượt maxLength. Form CreateCustomPackageForm dùng InlineWorkArea compact header, thông tin grid và quick picks semantic tokens, footer sticky; mode edit từ parent để đúng nhãn. Không thêm dependency React Bits: áp dụng selected transition motion-reduce với CSS. API/DB không đổi, sửa unit press cho dữ liệu mới/copy thành bài.

InlineWorkArea có compactHeader optional, PageWrapper có hideHeader optional (default false); chỉ bật cho form gói để tránh title lặp. SuggestedPackageText dùng state lưu phrase gốc theo option ID để bỏ đúng nội dung sau đổi locale; checkbox disabled khi thêm vượt 2000 ký tự. Bố cục panel khác hidden nhưng vẫn mounted để giữ lựa chọn gợi ý và native validation; invalid handler chọn/focus panel đầu tiên, có lỗi inline. Legacy/duplicate được giữ nguyên, không tự sửa DB.


### Sửa thanh Lưu đè nội dung

Tách footer khỏi fieldset cuộn, form flex min-h-0. InlineWorkArea nhận className optional. Hook đo chiều cao khả dụng từ vị trí form tới đáy main/viewport (trừ padding mobile); observe resize qua rAF, không thay logic lưu hoặc API. Áp dụng chung form Agency/Workspace.


### Thu gọn vùng tiêu đề và thao tác lưu

InlineWorkArea headerActions optional; compact toolbar flex-nowrap, back icon aria label, title min-w-0 line-clamp2; CreateCustomPackageForm dùng useId liên kết Button form với form id, bỏ footer. Root padding/gap giảm; usePackageEditorHeight chừa 8px dưới, Workspace/Agency edit giảm padding container.


### Thu nhỏ toolbar lần hai

Chỉ đổi utility CSS trên nhánh headerActions của InlineWorkArea và form gói; không đổi handler/save/API.


### Sửa 400 impact do đơn vị Báo điện tử

Sửa PackageOfferingValidator.validateStandardUnits expected press thành bài và nhánh tương thích unit cũ. Cùng validator áp dụng impact/save/create. CampaignSeeder tạo gói bài báo với unit bài; không chạy seeder hoặc migration. Test canonical/legacy/reject sai/duplicate.


### Không tự đóng các dịch vụ khác khi bấm Xem

Dừng đo/phân bổ automatic khi manual map có key. Cleanup observer/rAF trên transition đầu, giữ automatic set hiện hành. Manual overrides chỉ item được bấm, resize/locale không thu gọn các hàng trước đó.


### Micro-interaction chọn và xem gói
WorkspacePackageOverview nhập CSS scoped, đặt animation trên proposal keyed theo ID; xử lý bàn phím trong vùng danh sách chỉ với button card, giữ focus. MediaPackageCard chỉ chuyển màu/viền/shadow 160ms; không animate kích thước và không thay đổi footprint khi chọn. PackageDeliverableRow giữ hidden row để tương thích auto sizing; animate nội dung lúc mở và xoay chevron. CSS chỉ áp dụng overview, reduced-motion tắt animation/transition. Locale vi/en dùng lại keys, không thay file locale.

### Xác nhận giảm hạng mục/số lượng
Thêm pure PackagePlanChange resolver giữ work item cũ theo deliverable/type, tạo thêm đủ số lượng với ID tránh lịch sử cũ; packageDriven kiểm tra số lượng, loại, ID unique và deliverable đúng thay vì đòi ID tái tạo. Request thêm confirmedRemovedTaskIds nullable; impact trả nhóm candidates/removeCount và default affectedTasks, giữ blocked=true cho client cũ dừng an toàn. Save yêu cầu xác nhận chính xác tập bị bỏ; requireEditable cả impact/save. Worker hủy Task ngoài kế hoạch, marker trong typeMetadata hiện có; CampaignTaskStore.byCampaign loại marker khỏi phép đếm deployment/closure. Giữ tài liệu cũ nguyên vẹn, không collection/index mới; cập nhật seeder nếu đổi schema (đợt này không đổi schema). Web dialog cho chọn task giảm, await quyết định trả boolean cho form; không native confirm. Không chạm Auth/concurrent edits.

### Phân biệt bỏ hạng mục và giảm số lượng
PackageImpactDialog phân nhóm removeCount === candidates.length là bỏ trọn hạng mục; tự đưa IDs của nhóm này vào payload xác nhận. Chỉ render checkbox/count cho nhóm giảm một phần. Impact trả tên deliverable gốc cho nhóm bị bỏ, không dùng tên Task #1 làm tên hạng mục. Không đổi DB hoặc quyền.

# Test — Guest sharing và Campaign do Manager quản lý

Ngày 2026-11-06. Kịch bản trước triển khai theo [spec](spec.md), [plan](plan.md), [task](task.md). Trạng thái ban đầu: chưa chạy; chỉ đánh dấu pass khi có bằng chứng.

## Môi trường

PostgreSQL và Mongo replica set cô lập; không dùng Atlas/production. Có Owner, Manager, Client và tài khoản khác Agency/workspace. Không publish thật hoặc gọi AI có phí. Giữ dữ liệu tham chiếu để so sánh trước/sau.

| ID | AC | Thao tác | Mong đợi |
|---|---|---|---|
| S01 | 01,02 | Owner phát hành link gói Agency; mở không đăng nhập | Chỉ nội dung gói; không membership/Client/history |
| S02 | 01,02 | Manager share Custom Package workspace; mở guest trước khi mời Client | Đúng thỏa thuận workspace, không phải mẫu Agency |
| S03 | 02 | Manager khác workspace/Client gọi API phát hành/export | Bị từ chối; không trả token hoặc nội dung |
| S04 | 03 | Lưu sửa mẫu/gói workspace rồi tải lại link | Bản mới nhất của đúng gói; sửa mẫu không đổi gói workspace |
| S05 | 01,03,11 | PDF/PNG gói dài, tiếng Việt, ký tự đặc biệt; giả lập lỗi renderer | Đủ trang/nội dung; file tại thời điểm xuất; lỗi không trả file thành công giả |
| S06 | 02,11 | Thu hồi link, tạo lại, mở link cũ/sai | Không khả dụng; link mới xem được; không cache nội dung cũ |
| W01 | 04 | Owner tạo workspace có Manager, không Client | Thành công; không redirect ép Client chọn/duyệt |
| W02 | 05 | Manager chọn mẫu/tạo mới và lưu gói hợp lệ | Một Campaign DRAFT, một task TODO mỗi đơn vị; Manager mặc định |
| W03 | 06 | Lặp cùng request/key; cùng key payload khác; hai save đồng thời | Không trùng Campaign/task; conflict có cấu trúc khi khác dữ liệu |
| W04 | 06 | Crash sau SQL trước Mongo, sau một phần task, sau Mongo trước SQL | Operation bền vững; retry cùng ID; READY chỉ khi đủ task |
| W05 | 06 | Worker mất lease, worker cũ quay lại; restart service | Không ghi lùi trạng thái/revision; operation mới không bị ghi đè |
| W06 | 07 | Tăng số lượng/đổi tên gói; task đã sửa brief/assignee/deadline/comment | Giữ ID và thông tin đã nhập, chỉ thêm task còn thiếu |
| W07 | 07 | Giảm/xóa/đổi loại làm mất task | Impact trả ID; khi chưa chứng minh an toàn thì chặn, không xóa/hủy dữ liệu |
| W08 | 06,07 | Save khi đang preparation; stale terms version; retry sai revision | Conflict rõ; dữ liệu bản hiện hành giữ nguyên |
| C01 | 08 | Mời Client sau; xem DRAFT và comment | Xem và góp ý được; không approve hoặc sửa kế hoạch |
| C02 | 09 | Manager deploy kế hoạch đủ dữ liệu, không có approval | Deploy được; READY đúng revision bắt buộc |
| C03 | 09,10 | Save/update campaign đồng thời deploy; retry failed deployment | Cố định bản; không chỉnh khi pending/failed; retry cùng version |
| C04 | 05,10 | Creator bắt đầu Task khi Campaign DRAFT rồi IN_PROGRESS | DRAFT bị chặn, IN_PROGRESS tuân workflow hiện hành |
| C05 | 10 | Task/Post approval, editor, Content Request, closure | Quyền và điều kiện module riêng giữ nguyên |
| C06 | 08 | Feedback khi IN_PROGRESS/COMPLETED | Theo lifecycle feedback được hỗ trợ, không đổi Campaign hoặc mở lại |
| L01 | 10 | Đọc lịch sử cũ, Campaign APPROVED/đang chạy | Giữ lịch sử; không reset/approval giả; mutation cũ không bypass khóa |
| D01 | 06,10 | Fresh init và upgrade cùng fixture; chạy lại migration | Cùng schema/index; không xóa dữ liệu ngoài phạm vi |
| D02 | 05,10 | Seeder chạy lại | Dataset đúng flow mới; không trùng dữ liệu; Task metadata hợp lệ |
| U01 | 11 | Loading/empty/error/offline/conflict/failed preparation | Skeleton hoặc trạng thái tương ứng; giữ draft nhập; retry có nghĩa |
| U02 | 12 | Chuyển vi/en trên các màn share/guest/workspace/campaign | Không thiếu key, không hardcode hoặc vỡ bố cục |
| U03 | 12 | Light/dark, mobile, tab/keyboard/dialog focus | Contrast rõ, action truy cập được, không tràn ngang |

## Failure matrix cần ghi kết quả

Mỗi W03–W08/C03 phải ghi trạng thái SQL, task IDs/count và dữ liệu người dùng trước/sau. Không kết luận atomic xuyên hai DB. Lỗi một phần phải có preparation status và đường retry; không dùng xóa bù toàn bộ task.

## Kết quả thực thi

### Đã xác minh ngày 2026-11-06

- Business: bộ `service.*Package*Test`, `service.*Campaign*Test`, `service.impl.*Test`, `seed.*Test` chạy cùng `BRANDHUB_PACKAGE_QA=true`: 432 test, 0 failure/error, 12 test có điều kiện khác bị skip. Bao gồm test tích hợp mới, không khởi động application hoặc dùng cấu hình `.env`.
- Sau lượt tổng thể, bổ sung và chạy lại 5 test share/export (pass), gồm kiểm tra export Agency không dùng SELECT FOR UPDATE trong transaction chỉ đọc.
- Test SQL/Mongo dùng hai container QA riêng ở cổng 55439/57019: hai save đồng thời cùng key trả cùng Campaign; task đủ số lượng; crash giả lập sau Mongo trước READY phục hồi qua lease hết hạn; giữ description/workflowRevision đã sửa; không tăng số task hoặc tạo lại version; issue/revoke workspace link hợp lệ.
- Gateway: `RateLimitGatewayFilterFactoryTest` và `LoggingGlobalFilterTest`: 13 test pass. Guest rate limit theo IP không cần X-User-Id và không tin header giả; public mode không mở route workspace.
- Web: `npm run build` và type-check pass. ESLint các file thay đổi: 0 error; một warning có sẵn ở AuthGuard về setState trong effect. Bundle lớn của module có sẵn còn cảnh báo, không chặn build.
- Locale mediaPackage/campaign key-parallel vi/en. Workspace còn hai key plural lệch sẵn trên HEAD (`list.members_other`, `list.posts_other`), đợt này không làm tăng số key lệch.
- PostgreSQL QA: fresh init khai báo schema cuối chạy được; init HEAD cũ + migration mới chạy được; migration chạy lại được. Đối chiếu 47 cột/kiểu/nullability/default của ba bảng liên quan giữa fresh và upgrade khớp nhau.
- Trình duyệt local: route guest mở khi chưa đăng nhập và hiển thị đúng trạng thái link không khả dụng, không redirect login. Chưa manual toàn bộ flow trên tài khoản thật vì chưa APPLY schema vào DB ứng dụng.

### Chưa coi là đã hoàn tất

- Ma trận UI vi/en/light/dark/mobile/keyboard và luồng đầy đủ qua HTTP với các tài khoản Owner/Manager/Client sau migration/restart.
- Phối hợp mobile/client cũ và nghiệm thu với chủ module Task/Post/publishing.
- Giảm/xóa/đổi loại làm mất task hiện có đang được chặn theo phương án an toàn; chưa hỗ trợ xác nhận để xóa task nguyên bản.
- Bản export ban đầu là PDF ảnh. Đã được thay bằng PDF text/vector trong mục nghiệm thu format bên dưới; PNG tiếp tục tải theo bộ ZIP.
- Chưa APPLY schema hoặc ghi seed trên PostgreSQL demo, Atlas hay production. Chưa deploy/restart các service dùng DB ứng dụng.

Các container QA và file baseline tạm được dọn sau kiểm thử. Không có request AI có phí, publish thật hoặc thao tác AWS trong lượt này.


## Nghiệm thu format proposal

| ID | Input/Thao tác | Kết quả cần đạt |
|---|---|---|
| E01 | Gói 3-4 dịch vụ, có ngân sách/thời lượng | Thứ tự đọc rõ; bảng hạng mục/cột số lượng không đè chữ; không có enum nội bộ |
| E02 | Không ngân sách/thời lượng hoặc không mô tả | Không biến thành 0, không tạo phần trống lớn hoặc cam kết giả |
| E03 | Mô tả/tiêu chí dài, nhiều đoạn và dấu tiếng Việt | Không thiếu chữ/cắt dòng; continuation rõ; không tiêu đề lẻ/trang trắng cuối |
| E04 | Tên gói/Agency 255 ký tự, đơn vị dài, URL không khoảng trắng | Wrap trong vùng nội dung, không tràn lề hoặc footer |
| E05 | Xuất vi/en cùng dữ liệu | Nhãn đúng ngôn ngữ, text do người dùng nhập giữ nguyên, không trộn nhãn song ngữ |
| E06 | Đọc PDF text bằng PdfTextExtractor/Poppler và đối chiếu PNG ZIP | PDF chọn/copy được tiếng Việt; số trang ảnh/PDF trùng; nội dung cuối vẫn có |
| E07 | Số lượt sửa 0, giá trị null | 0 được thể hiện đúng, null không tự suy thành 0 |
| E08 | Render và xem trang đầu, trang tiếp tục, trang cuối ở 96–110 dpi, ảnh xuất thật ở 1240 × 1754 | Không overlap, glyph lỗi, mất dấu, bảng cắt ngang hoặc footer lẫn body |

Kết quả format ngày 2026-11-06:

- `PackageExportRendererTest` (5) và `PackageProposalLayoutTest` (1): pass. Kiểm tra PDF text tiếng Việt/NFC, enum thành nhãn, vi/en, null/0, PDF/PNG cùng số trang, nội dung dài và vùng biên tên/URL/đơn vị dài.
- Đã xem trực tiếp toàn bộ mẫu vi (2 trang), en (2 trang), gói dài (5 trang), mẫu không giá/thời lượng (1 trang), và PNG thực tế từ bộ ZIP. Poppler render 96–110 dpi; PNG xuất 1240 × 1754. Không thấy overlap, mất dấu, cắt chữ hoặc footer đè nội dung. Gói ít nội dung có khoảng trắng chủ đích, không thêm nội dung giả để lấp trang.
- Web type-check và ESLint riêng `PackageShareActions.tsx`: pass. Ngôn ngữ export theo locale hiện hành.
- Artifact QA lưu trong `keep-local-only/proposal-export-qa`, không đưa vào Git. Không cần migration/init/seeder vì thay đổi chỉ ở renderer và query language tùy chọn.
- Chưa kiểm thử tải file qua phiên đăng nhập HTTP sau restart Business; không coi unit test là nghiệm thu toàn bộ hành trình UI.

- Hồi quy cuối: `PackageExportRendererTest`, `PackageProposalLayoutTest`, `MediaPackageShareServiceTest`, `WorkspacePackagePlanningServiceTest`: tổng 16 test, 0 failure/error/skip. Lượt chạy ngoài sandbox pass; lượt sandbox ban đầu bị chặn Mockito JVM attach (named pipe), không phải lỗi nghiệp vụ.


### Kiểm chứng sau review nhãn export

Đã bỏ nhãn đề xuất, cột lượt sửa và các chú thích được yêu cầu. Kiểm tra PDF text xác nhận nhãn mới, câu số lượng tự nhiên và không còn các nhãn cũ ở cả vi/en. `PackageExportRendererTest` (5) + `PackageProposalLayoutTest` (1): 6 test pass, 0 failure/error. Đã xem lại hai trang PDF vi và PNG xuất thật; xem tổng thể các trang dài/en/thiếu giá để kiểm tra phân trang. Không đổi DB hoặc giá trị revisionLimit; chỉ bỏ hiển thị trong export.


### Báo điện tử — làm rõ cách hiển thị cho Client

Bản xem gói/card/guest chứa PRESS_RECOMMENDATION quantity=3 unit=danh sách đề xuất phải hiện “3 bài” và “Bài báo điện tử”; en là articles/Online press articles. Export phải hiện “3 bài báo điện tử”, không hiện recommendation list ở cột unit; mô tả do người dùng nhập giữ nguyên. Không mutation dữ liệu, không đổi Task type. Text dùng t(), không đổi CSS/theme/focus.

Kết quả: 6 test export/layout pass, locale vi/en và plural unit pass; xem trực tiếp hai trang PDF mẫu mới. Type-check toàn Web dừng ở GuidePage.tsx (Database, Hash và t không được dùng), không thuộc thay đổi này. Không sửa dữ liệu cũ hoặc schema/enum/workflow.

ESLint hai component OfferingSummary/MediaPackageCard: pass. Chỉ đổi nhãn/unit hiển thị; tên và mô tả hạng mục người dùng đã nhập không bị ghi đè.


### Xuất ảnh trang đầu theo xác nhận

Với gói PDF nhiều trang: Xuất ảnh trả JPEG magic FF D8, decode được 1240x1754, không ZIP và chỉ trang đầu. Controller trả image/jpeg và .jpg; Web tải .jpg. PDF giữ số trang và nội dung cuối. Format ảnh mới là jpg, không còn ZIP. File ảnh được xem trực tiếp, không crop nhầm trang.

Kết quả JPG: 6 test renderer/layout pass; JPEG thực có FF D8, decode 1240×1754, PDF mẫu vẫn nhiều trang và giữ nội dung cuối. Đã xem trực tiếp JPG xuất thật, chỉ trang đầu. Web type-check và ESLint PackageShareActions pass. Chưa kiểm tra tải qua phiên HTTP thật sau restart; không cần migration.


### Bản xem theo format proposal

Kiểm tra 3 route dùng cùng component. Dữ liệu 3 dịch vụ có budget/duration: thứ tự giống PDF, không cột lượt sửa, không hướng dẫn dư, chi tiết mở sẵn; press= bài báo điện tử. Không giá/thời lượng: trao đổi thêm, không 0. Tên/mô tả dài wrap không cắt. vi/en đúng nhãn, dark/light đủ contrast, mobile 390px không tràn trang, bảng còn đọc được. Back/share/edit/guest loading/error giữ nguyên. Không sửa DB/API.

Kết quả bản xem proposal: type-check pass; lint các file tích hợp và component pass. Playwright trên fixture local đã kiểm tra 24 tổ hợp (normal/missing/long × vi/en × light/dark × 390/1440px), không page error hoặc document overflow; đã xem trực tiếp ảnh desktop vi/light, en/dark và mobile vi/dark. Không có API/DB được gọi trong fixture; chưa coi đây là kiểm thử HTTP đầy đủ qua các tài khoản thật. Back/share/edit và query/loading/error hiện hành giữ nguyên; 3 route tích hợp dùng cùng component. Nhãn/unit dịch vụ chuẩn hóa vi/en. Artifact và browser QA ở keep-local-only, không đưa Git.

Production build local pass; còn cảnh báo chunk Agora lớn có sẵn. Không deploy hoặc thao tác AWS. Đã đóng browser QA và Vite fixture sau kiểm tra.


### Workspace package — overview gọn và share menu

Kiểm tra current card trái/catalog phải, chọn card mở proposal full width và Back về card; Space/Enter xem, Tab đến action không vô tình mở card. Icon share mở menu, JPG/PDF/link đúng request và filename; mặc định không gọi API share/export, revoke vẫn riêng. Client xem catalog nhưng không select/edit/share; locked manager vẫn xem nhưng không sửa/chọn; missing/error/pending không bypass khóa; FAILED vẫn retry. Không banner LEGACY hoặc link Campaign. Sáng/tối và mobile 390px không tràn; vi/en key parity, title dài wrap. Dùng mock local, không ghi API/DB thật.

Kết quả Workspace overview: type-check, lint 6 file thay đổi và production build local pass (cảnh báo chunk Agora lớn có sẵn). Playwright fixture tích hợp WorkspaceMediaPackagePage với API mock: catalog tự tải; không CTA Campaign/banner LEGACY; card hiện tại và card khác mở proposal full width/Back; Enter mở card; chọn gói mở form đã điền mà không mở detail; menu share không mở card, tải JPG/PDF đúng format/filename, copy link gọi đúng API mock; keyboard Enter/Escape trả focus về share. Client không có edit/select/share, Manager DEPLOYED không sửa/chọn, PENDING/FAILED bị khóa sửa. Kiểm tra 8 tổ hợp vi/en × light/dark × 390/1440, không tràn ngang/page error; đã xem screenshot vi/light desktop và vi/dark mobile. Không gọi API thật/ghi DB, không submit lưu form hoặc APPLY migration. QA/download/mock và ảnh nằm keep-local-only, không đưa Git. Chưa kiểm thử save thật hoặc HTTP phân quyền Backend trong lượt UI này.


### Sketch được duyệt — detail trái, list phải

Mặc định hiện proposal current bên trái và current card đầu bên phải. Click card khác giữ list/card focus, đổi proposal trái và aria-pressed; current badge không chuyển. Search không ẩn current card; xóa search khôi phục list; thêm 12 cho catalog dài. Desktop scroll trái không dịch list/header hoặc body, scroll list không dịch proposal; mobile không tràn và vẫn chọn được gói. Gói mất khỏi catalog fallback hợp lệ. Client không select/edit/share; locked manager không sửa/chọn. Form cuộn được; share menu giữ formatjpg/pdf. Không mutation ngoài mock QA.

Kết quả sketch: type-check/lint pass. Playwright trên fixture tích hợp có header và main giới hạn chiều cao như app: detail trái, list phải; current ghim thứ tự đầu, mặc định xem current; click/Enter đổi proposal không điều hướng, aria-pressed phân biệt đang xem; cuộn detail 350px không đổi list và ngược lại; body desktop không cuộn. Tìm kiếm giữ card current, load more mở đủ 22 gói QA; JPG/PDF request và filename đúng. Client không có edit/select/share, Manager DEPLOYED không sửa/chọn; 8 tổ hợp vi/en × light/dark × 390/1440 không tràn ngang/page error. Đã xem trực tiếp ảnh desktop vi/light và mobile vi/dark, xác minh mobile cuộn tới cuối chi tiết được. State xem gắn Workspace ID, dữ liệu xem lấy từ query mới; ID mất thì fallback current/catalog. Không API thật, DB hay AWS. QA nằm keep-local-only.

Build cuối sau tất cả sửa đổi pass, chỉ cảnh báo bundle lớn có sẵn. Đã đóng browser QA/Vite fixture. Không commit/push hoặc deploy.


### Sketch compact được duyệt — mô tả ngắn và bảng mở chi tiết

Fixture 3 dịch vụ với mô tả dài: mặc định chỉ header, metadata, mô tả 2 dòng và 3 hàng; không section chi tiết lặp, không wordmark/factcards. Ở viewport desktop thông thường pane detail scrollHeight<=clientHeight. Click Xem đúng hàng mở mô tả/mục tiêu, Xem thêm hiện chỉ khi đo tràn 2 dòng; Thu gọn hoạt động, full text giữ nguyên. Resize cập nhật overflow; đổi gói reset state. Hàng thiếu details không mở action rỗng. Keyboard Enter/Space, aria-controls/expanded và nút có tên gắn hạng mục. Mobile không tràn ngang, nội dung dài đọc hết sau mở/scroll; client/locked không đổi quyền; search/list/share giữ nguyên. Fixtures/read-only mock, không mutation DB.

Kết quả compact: type-check, ESLint 4 component và build cuối pass (còn warning chunk lớn có sẵn). Playwright fixture mock 3 hạng mục ở desktop 1440×900: detail clientHeight=scrollHeight=753px, không cần cuộn mặc định; title computed 18px. Đã xác minh mô tả tối đa 2 dòng, chỉ text tràn có Xem thêm; mở/thu gọn mô tả và từng hàng, keyboard Enter, aria-expanded/controls đúng; text ngắn không có nút dư, hạng mục không có details không có action rỗng; đổi gói reset trạng thái mở. Budget/duration null vẫn “Trao đổi thêm”. Share JPG đúng API/filename mock, Client và Manager locked giữ quyền. 8 tổ hợp vi/en × light/dark × 390/1440 không tràn ngang, không page error; đã xem trực tiếp vi/light desktop, vi/dark mobile, en/dark desktop. Không cam kết không cuộn khi gói quá nhiều hạng mục hoặc người dùng mở text dài. PDF/JPG renderer, API và DB không thay đổi; chưa manual HTTP save trên dữ liệu thật. QA được giữ trong keep-local-only và không đưa Git.


### UI v3 đã duyệt — cam nhạt, xám/trắng và nội dung theo không gian

Header table dùng brand-orange-soft, detail nền muted/field bg-card; edit Button orange và share gray; không tên hạng mục lặp trong detail. Short description 3–5 dòng vẫn hiện đủ sau Xem nếu vừa pane (không bị ép 2 dòng). Long row làm tràn thì có Xem thêm, mở đủ và thu gọn được. Resize và đổi locale không gây loop/page error. Mở nhiều hàng không tự đổi quyết định/permission; explicit expand cho phép scroll. Kiểm tra selected/viewed card, share download/mock, Client/locked, responsive 390/1440, chữ vẫn 18/14. QA local mock, không ghi DB thật.

Kết quả UI v3: type-check và lint 7 file thay đổi pass. Playwright QA tích hợp Workspace page dùng mock: xác minh computed colors table/header/action/card đúng token, detail row xám + field trắng, không title lặp. Text 4 dòng hiện đủ nếu vừa pane; long text fallback có Xem thêm và mở/thu gọn được. Resize hai chu kỳ 1440×420 ↔ 1440×1100 không loop/page error, aria và keyboard đúng, đổi gói reset row. Mobile long text dùng viewport thực thay vì chiều cao nội dung tự giãn, có thể mở đủ thủ công, không tràn ngang. Client/locked giữ điều kiện action; JPG download mock đúng filename. 8 tổ hợp vi/en × sáng/tối × 390/1440 pass; đã xem trực tiếp ảnh vi/light với hai hàng mở và vi/dark mobile. Default 3 hàng vẫn không cần cuộn desktop. Chưa kiểm thử HTTP save thật; không DB/API/export renderer/migration hoặc AWS thay đổi. QA và hình ảnh được giữ trong keep-local-only, không đưa Git.

Build cuối sau chỉnh adaptive mobile pass; còn cảnh báo bundle lớn có sẵn. Browser QA và Vite fixture đã đóng. Chưa commit/push hoặc deploy.


### Số lượng đầu hàng và tự mở hạng mục khi có chỗ

3 hạng mục ngắn đủ chỗ: chi tiết có dữ liệu tự mở khi chọn gói, không cần click Xem; title không lặp. Cột đầu là quantity+unit, không còn #/STT và quantity cột khác. Bấm tên/số lượng/native Xem đều toggle đúng 1 lần, Enter/Space và aria đúng. Đóng thủ công không bị observer mở lại. Gói dài chỉ auto mở hàng vừa budget, mở thủ công vẫn đọc hết qua Xem thêm; nhiều hàng không auto overflow. Đổi gói/reset, resize/locale không loop, search/current top/share/Client/locked còn đúng. Mock local, không ghi dữ liệu thật.

Kết quả: build/type-check và ESLint 4 file pass; git diff --check pass. Playwright local mock xác minh 3 hàng ngắn tự mở, desktop pane clientHeight=scrollHeight=753px; hàng dài bỏ qua tự mở nhưng hàng ngắn phía sau vẫn mở; 18 hàng không tự làm tràn. Click tên/số lượng/button/Space toggle một lần; manual close giữ khi resize, đổi gói reset. 8 tổ hợp vi/en × sáng/tối × 390/1440 không page error hoặc tràn ngang. Share JPG mock và Client/Manager locked pass. Đã xem screenshot desktop. Không sửa DB/API, không chạy trên production; QA trong keep-local-only.


### PDF và JPG theo sketch duyệt 06/11/2026

Kiểm tra 3 hạng mục ngắn thành overview+detail; thứ tự quantity/name, không STT/hướng dẫn; metadata vắng không bịa giá. Long text giữ sentinel cuối, không vượt printable area. JPG hai trang đặt cạnh nhau; nhiều trang nối hàng không mất trang; vượt pixel budget trả lỗi có cấu trúc thay vì OOM. QA artifact chỉ trong keep-local-only, không DB/AWS.

Kết quả: Maven compile/test pass, 8 test (PackageExportRendererTest + PackageProposalLayoutTest), không DB/service ngoài. PDF vi/en mẫu 2 trang, null 1 trang, long 5 trang và nhiều hạng mục 5 trang; text cuối không mất, text nằm trong printable area. JPG 2 trang 2540×1794; tài liệu nhiều trang giữ đủ từng tile theo thứ tự trái→phải, trên→dưới. Pixel budget 24 triệu (tối đa 10 trang A4 ở scale hiện tại), vượt trả PACKAGE_EXPORT_FAILED trước cấp phát, vẫn xuất PDF và slot được giải phóng. Đã render/rà soát ảnh PDF/JPG, long/many contacts; không tràn/chồng chữ, dấu Việt đọc được. Preview/log chỉ keep-local-only. Không sửa DB/migration, không AWS/deploy, chưa thử HTTP authenticated export thật.


### Chọn ngôn ngữ khi xuất file

Mock export API local: website VI xuất EN và ngược lại, đủ pdf/jpg × vi/en; request đúng format/language, filename có mã ngôn ngữ. Không phát sinh request chỉ mở menu. Arrow/Enter/Escape và click mobile dùng được; copy/revoke giữ nguyên. Không dịch nội dung người dùng.

Kết quả: ESLint component và production build/type-check pass. Playwright API mock pass 8 lượt download (4 tổ hợp × website VI/light/1440 và EN/dark/390); format/language và filename khớp, không thêm request ngoài 8 export. ArrowRight mở submenu, Escape thoát; menu có font/màu đúng theme. Không page error; artifacts trong keep-local-only. Backend vi/en PDF/JPG đã qua 8 test bộ xuất ở thay đổi trước; không sửa DB hoặc HTTP dữ liệu thật.


### Ngôn ngữ trang guest

Fixture guest public API mock không đăng nhập. Đổi VI→EN: Budget/Duration/Quantity/units đổi, tên/mô tả gốc giữ nguyên, API không fetch lại do đổi locale; reload giữ EN. Error/retry và skeleton vẫn có selector; không overflow ngang ở 390, aria-pressed/keyboard đúng.

Kết quả: focused ESLint + production build/type-check pass. Browser local mock pass: switch labels, pressed state, nội dung gốc giữ nguyên, không refetch khi đổi ngôn ngữ, persist qua reload, selector có ở loading/error/retry, keyboard Enter, 4 tổ hợp 390/1440 sáng/tối không tràn ngang và không pageerror. Không DB/API/production thay đổi; fixture/artifact trong keep-local-only.

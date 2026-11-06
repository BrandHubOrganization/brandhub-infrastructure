# Task — Guest sharing và Campaign do Manager quản lý

Ngày lập: 2026-11-06. Checklist đã cập nhật theo bằng chứng mã nguồn/QA. Mục chưa tick còn cần review, mở rộng hoặc kiểm thử thủ công; không đồng nghĩa migration đã APPLY môi trường ứng dụng.

Nguồn: [spec.md](./spec.md), [plan.md](./plan.md). Thứ tự thực thi theo các giai đoạn; việc triển khai chỉ bắt đầu sau review và hoàn tất `test.md` theo rule của team.

## G1. Contract và review — plan §3, §10

- [ ] T01. Review hành trình Owner → guest → Manager → Client và ma trận quyền; xác nhận không đổi Task/Post approval, publishing và closure. Đầu ra: biên bản phạm vi, AC-01–AC-10.
- [ ] T02. Kiểm kê endpoint/gate/trigger/query cũ liên quan select, negotiate, approve Package/Campaign; xác định caller Web/mobile và người phụ trách chuyển đổi. Đầu ra: danh sách thay đổi tương thích, AC-04, AC-08–AC-10.
- [x] T03. Chốt schema request/response/error/capability, version và idempotency cho save/impact/preparation/retry/deploy; xác định nguồn điều khoản hiệu lực. Đầu ra: API contract được review, AC-05–AC-07, AC-09, AC-11.
- [x] T04. Review đề xuất phát hành/thu hồi/hết hạn link cho hai scope gói, định dạng bộ ảnh nhiều trang và giới hạn renderer; ghi bảo mật nâng cao là phạm vi bàn sau, chưa yêu cầu OTP/mật khẩu/xác minh email. Không tự coi đề xuất là BA đã chốt. Đầu ra: quyết định trong plan/spec, AC-01–AC-03.
- [x] T05. Chốt chính sách giảm/xóa/đổi loại hạng mục: impact, xác nhận theo revision, chặn task có dữ liệu và điều kiện an toàn cho task nguyên bản. Đầu ra: bảng tình huống giữ/chặn, AC-07.
- [x] T06. Viết `test.md` trước code, ánh xạ AC-01–AC-12 và failure matrix SQL/Mongo. Đầu ra: đủ bộ spec → plan → task → test để team review.

Điều kiện qua G1: contract và các quyết định ảnh hưởng BA đã được review; không còn giả định ngầm về xóa dữ liệu hoặc quyền guest.

## G2. Database, init và seeder — plan §4

- [ ] T07. Viết preflight chỉ đọc cho scope gói, Campaign/workspace, duplicate task source, revision và approval lịch sử. Đầu ra: báo cáo xung đột, không tự reset/xóa, AC-06, AC-10.
- [x] T08. Thiết kế migration additive cho metadata share và preparation/revision/manifest/lease trên bảng hiện có; rà soát index/constraint/function/trigger. Đầu ra: SQL migration có kiểm tra điều kiện áp dụng, AC-02, AC-05–AC-07, AC-09.
- [x] T09. Thiết kế thay đổi validator/index Task chỉ nếu metadata hiện tại chưa đủ; giữ workflow và schema module khác. Đầu ra: contract Mongo cùng preflight, hoặc ghi rõ không cần migration Mongo, AC-06, AC-07, AC-10.
- [x] T10. Cập nhật `docs/database/init-postgres-v2.sql` và `docs/database/init-mongo.js` nếu schema tương ứng thay đổi; fresh init phải bằng schema nâng cấp. Không xóa migration của thành viên khác.
- [x] T11. Cập nhật các Business seeder thực sự tạo Workspace/gói/Campaign/Task liên quan; bỏ dữ liệu mẫu phụ thuộc Client approval, giữ metadata workflow hợp lệ. Đầu ra: dataset phục vụ flow mới, AC-04–AC-10.
- [x] T12. Kiểm tra fresh init, upgrade dataset cũ và chạy lại migration/seeder trên DB cô lập; đối chiếu schema/index và dữ liệu không thuộc phạm vi. Chưa APPLY môi trường dùng chung.

Điều kiện qua G2: init/migration/seeder nhất quán; không có xóa dữ liệu hoặc lịch sử duyệt giả; dữ liệu cũ không rõ nghĩa có báo cáo xử lý riêng.

## G3. Manager lưu gói và chuẩn bị Campaign/task — plan §5

- [x] T13. Thêm service/DTO/repository cho Manager tạo gói riêng workspace từ mẫu hoặc nhập mới; kiểm tra Agency/workspace/scope, version và field hợp lệ. Đầu ra: bản thỏa thuận độc lập mẫu, AC-05.
- [x] T14. Trong transaction SQL, tạo/cập nhật cùng Campaign DRAFT và durable preparation manifest với ID hạng mục/task ổn định; xử lý idempotency key và lock theo thứ tự cố định. Đầu ra: một Campaign/workspace, AC-05, AC-06.
- [x] T15. Implement worker claim/lease/retry theo revision; upsert Mongo có điều kiện, kiểm đủ task rồi mới READY. Đầu ra: khôi phục được sau crash từng ranh giới, không nhân đôi, AC-06.
- [x] T16. Implement cập nhật chênh lệch: giữ ID và thông tin người dùng đã nhập; tăng số lượng chỉ thêm task cần thiết, không replace toàn document. Đầu ra: diff an toàn, AC-07.
- [ ] T17. Implement impact và xác nhận theo revision cho giảm/xóa/đổi loại; chặn phụ thuộc/không chứng minh được an toàn khi ghi đồng thời. Không tự hủy task hoặc xóa comment/nội dung. Đầu ra: kết quả/điểm chặn cụ thể, AC-07.
- [x] T18. Thêm API preparation/retry và lỗi cấu trúc; chặn revision mới/deploy khi chưa READY; log request/operation ID không chứa dữ liệu nhạy cảm. Đầu ra: có thể theo dõi và phục hồi, AC-06, AC-11.
- [ ] T19. Test đồng thời save/save, save/retry, crash sau Mongo trước SQL, worker trễ hết lease và cùng key khác payload; so sánh task/comment/subtask trước sau. Đầu ra: failure matrix pass, AC-06, AC-07.

Điều kiện qua G3: lưu gói hợp lệ tự chuẩn bị đủ task; lỗi một phần được phản ánh đúng và retry an toàn; Task chưa được bắt đầu khi Campaign DRAFT.

## G4. Guest share và export — plan §6

- [x] T20. Implement Owner phát hành/xem/thu hồi/tạo lại link cho gói Agency và Manager phụ trách/Owner có quyền làm tương tự cho Custom Package workspace; unique định danh ngẫu nhiên và kiểm scope ở server. Đầu ra: hai phạm vi chia sẻ đúng quyền và đúng gói, AC-01, AC-02.
- [x] T21. Implement public GET bằng DTO allowlist, đọc bản đã lưu mới nhất; link lỗi/thu hồi trả trạng thái chung. Đầu ra: chỉ trả nội dung/điều khoản gói được share, không lộ Client Profile/workspace/history/asset riêng, AC-02, AC-03.
- [x] T22. Cấu hình Gateway và Business security đúng route/method public, rate limit và no-store; không nới quyền nhóm endpoint nghiệp vụ. Đầu ra: guest dùng được, mutation vẫn có auth, AC-02, AC-11.
- [x] T23. Implement PDF cho gói Agency và workspace từ DTO nhất quán một revision, dùng OpenPDF/font phù hợp; đủ hạng mục, phân trang, tên Agency/gói/ngày xuất. Đầu ra: file Việt/Anh đọc đúng, AC-01, AC-03.
- [x] T24. Spike và chốt renderer PNG; implement export nhiều trang theo định dạng được review, giới hạn memory/time/concurrency, dọn file tạm và lỗi retry. Đầu ra: không cắt nội dung, không lưu lâu dài ngoài kế hoạch, AC-01, AC-11.
- [ ] T25. Test latest link sau sửa ở cả hai scope, link workspace không đổi theo mẫu Agency, Client guest chưa có membership, static file đã tải, thu hồi/tạo lại, cross-Agency/cross-workspace access, file dài/ký tự đặc biệt và lỗi renderer. Đầu ra: AC-01–AC-03, AC-11 pass.

Điều kiện qua G4: guest chỉ xem nội dung gói được chia sẻ; Owner/Manager theo scope xuất được nội dung đầy đủ; xem/share/export không tự tạo Campaign/task hoặc xác nhận mua gói.

## G5. Campaign feedback và triển khai — plan §7

- [x] T26. Rà soát DTO/service/DB tạo workspace không bắt buộc Client; giữ Manager assignment và kiểm quyền mời hiện hành. Chỉ sửa điểm chưa đáp ứng. Đầu ra: AC-04 pass.
- [x] T27. Cho Client đúng workspace xem và feedback Campaign DRAFT theo contract comment hiện hành; feedback không đổi kế hoạch/trạng thái/approval. Đầu ra: AC-08 pass.
- [x] T28. Thay gate deploy từ hai approval sang quyền Manager, dữ liệu đủ và preparation READY đúng revision; khóa cùng scope với save. Đầu ra: deploy không cần Client approve hoặc có mặt trong workspace, AC-09.
- [x] T29. Cố định snapshot/revision lúc nhận deploy, chặn sửa trong pending/failed/succeeded; retry đúng bản; xác minh đủ task rồi chuyển IN_PROGRESS. Đầu ra: AC-06, AC-09, AC-10 pass.
- [x] T30. Kiểm tra Task start chỉ khi Campaign IN_PROGRESS và giữ điều kiện complete/Content Request closure. Đầu ra: regression Task/Post/publish/closure không đổi, AC-10.
- [ ] T31. Implement adapter dữ liệu cũ/endpoint deprecation theo T02; giữ lịch sử, không tạo approval giả hoặc reset Campaign đang chạy. Đầu ra: kế hoạch chuyển Web/mobile khả thi.

Điều kiện qua G5: Client góp ý được ở DRAFT, Manager triển khai được theo bản đã đồng bộ, không có đường ghi endpoint cũ bỏ qua khóa mới.

## G6. Web — plan §8

- [x] T32. Bổ sung action Share/Export tại catalog/detail Agency và detail gói workspace cho Manager/Owner có quyền; trạng thái tạo link, copy, thu hồi, tải file và retry. Đầu ra: hành trình trực tiếp cho Owner, AC-01, AC-11.
- [x] T33. Thêm route guest ngoài AuthGuard/workspace layout; không gọi API tài khoản/workspace; skeleton và lỗi link. Đầu ra: mở bằng trình duyệt chưa đăng nhập, AC-02, AC-03, AC-11.
- [x] T34. Điều chỉnh tạo workspace và empty state để Owner/Manager chuẩn bị trước khi mời Client; không redirect ép Client chọn/duyệt gói. Đầu ra: AC-04.
- [x] T35. Thay màn gói workspace bằng chọn mẫu/tạo mới/lưu của Manager và read-only của Client; giữ bản nhập khi lỗi, hiển thị impact/conflict/preparation/retry. Đầu ra: AC-05–AC-07, AC-11.
- [x] T36. Điều chỉnh Campaign review/next step/delivery: Client feedback DRAFT, bỏ approve Campaign, deploy của Manager theo capability server; chỉ báo triển khai thành công khi backend xác nhận. Đầu ra: AC-08–AC-10.
- [x] T37. Cập nhật song song các namespace locale trong `src/i18n/locales/vi/` và `en/`: `mediaPackage.json`, `campaign.json`, cùng file workspace/common thực sự có nhãn đổi. Không hardcode text. Đầu ra: key vi/en tương ứng, AC-12.
- [ ] T38. Kiểm tra light/dark mode, contrast, keyboard/focus, dialog, mobile và nội dung dài; dùng theme token hiện có. Đầu ra: AC-12.

Điều kiện qua G6: flow mới dùng được từ UI, không còn CTA/checklist Client approval; mọi state thiếu quyền/loading/trống/lỗi/conflict có hành động đúng.

## G7. Kiểm thử tổng thể và bàn giao — plan §9

- [ ] T39. Chạy toàn bộ `test.md` trên môi trường cô lập và ghi kết quả theo AC-01–AC-12; bao gồm role, scope, restart/retry/concurrency và dữ liệu cũ.
- [ ] T40. Chạy regression các module Task approval, editor/content writing, publishing, Content Request và closure với chủ module; không gọi AI có phí/publish thật khi chưa được phép.
- [ ] T41. Đối chiếu migration ↔ init ↔ seeder ↔ DTO ↔ UI; kiểm tra build/lint/test cần thiết và dữ liệu không thuộc phạm vi còn nguyên.
- [x] T42. Viết runbook preflight, rollout schema → Business/Gateway → Web → chuyển client cũ; chuẩn bị rollback ứng dụng tương thích và phục hồi operation đang dở. Không tự thực thi AWS/production.
- [x] T43. Báo cáo diff schema/API, trạng thái dữ liệu cũ, giới hạn hỗ trợ giảm task, test đã chạy/chưa chạy và vấn đề tồn; team review trước rollout.
- [x] T44. Rà soát thay đổi trước commit khi được yêu cầu: bỏ artifact local, ảnh QA, credential và file thừa; không tạo nhánh/worktree mới. Giữ test đúng convention repo, không đưa test vào Web `src`.

Definition of Done: tất cả task áp dụng đã có bằng chứng hoàn thành; AC pass; không mất dữ liệu/lịch sử; init và seeder khớp schema; chủ module liên quan đã review; không còn gate duyệt Package/Campaign trong flow mới. Migration APPLY và production rollout là bước có phê duyệt riêng, không mặc nhiên hoàn thành theo checklist code.


## Ghi chú triển khai

- T02/T31: endpoint cũ đã chặn ghi và dữ liệu cũ giữ nguyên; cần chủ mobile/client cũ review trước rollout.
- T07: preflight SQL trong migration đã có, chưa kiểm kê đầy đủ dữ liệu môi trường ứng dụng/Atlas.
- T17: impact đã trả danh sách và chặn giảm/xóa/đổi loại; chưa mở bước xác nhận để xóa task nguyên bản. Phương án bảo toàn là chặn toàn bộ giảm task trong đợt này.
- T19/T25/T39–T41: có unit và SQL/Mongo QA tự động; chưa coi toàn bộ ma trận UI/role/manual và xác nhận chủ module là hoàn thành. Xem kết quả chi tiết trong test.md.
- T38: dùng theme tokens và key vi/en song song; cần manual kiểm tra light/dark/mobile trên tài khoản thật sau APPLY.
- T43/T44: bàn giao theo kết quả cuối lượt; chưa có yêu cầu commit/push. Không tạo branch/worktree mới.


## G8. Nâng cấp format ảnh/PDF

- [x] E01. Rà mẫu proposal của agency, chốt cấu trúc phù hợp dữ liệu hiện có.
- [x] E02. Layout A4 có typography, bảng sản lượng, ngân sách/thời lượng và chi tiết tiêu chí; word-wrap, continuation và footer.
- [x] E03. PDF text/vector và PNG dùng cùng layout, font tiếng Việt, giới hạn xuất và i18n vi/en.
- [x] E04. Test nội dung dài/đa trang, tên dài/URL liền, trường thiếu, enum, zero revision và bảo toàn text.
- [x] E05. Xuất mẫu từ renderer thật, render PDF ra PNG và kiểm tra trực quan; cập nhật kết quả/giới hạn.


### Điều chỉnh nhãn export theo review

Bỏ dòng “Đề xuất gói truyền thông”, cột Lượt sửa, hai chú thích dưới Ngân sách/Thời lượng và dòng sản lượng toàn gói. Dùng “Ngân sách”, “Số lượng”, “Mô tả thực hiện”, “Mục tiêu đạt được”. Dòng mô tả dịch vụ dùng số lượng tự nhiên, ví dụ “12 bài đăng mạng xã hội”, “1 sự kiện”, “2 buổi livestream”, “1 danh sách đề xuất báo điện tử”, “2 buổi workshop”. Cập nhật tương ứng en; chỉ thay phần trình bày export, không xóa revisionLimit trong dữ liệu. Kiểm tra lại PDF/PNG sau thay đổi.


### Báo điện tử — làm rõ cách hiển thị cho Client

- [x] Đổi label dịch vụ vi/en và unit hiển thị ở summary/card/guest.
- [x] Đổi export PDF/PNG thành bài báo điện tử; điều chỉnh mẫu và assertion.
- [x] Chạy unit test và kiểm tra locale; giữ nguyên dữ liệu/schema. Type-check bị lỗi có sẵn ngoài phạm vi ở GuidePage.tsx; xem test.md.


### Xuất ảnh trang đầu theo xác nhận

- [x] Đổi renderer/controller/Web sang JPG trang đầu.
- [x] Xác minh JPEG thực, đúng kích thước và trang đầu; PDF nhiều trang vẫn đủ nội dung.
- [x] Xem mẫu JPG, lint/type-check và ghi kết quả.


### Bản xem theo format proposal

- [x] Tạo component proposal responsive dùng token sẵn có và nhãn vi/en.
- [x] Nối 3 bản xem Agency/Workspace/guest; giữ actions và kiểm tra loading/error.
- [x] Chạy type-check/lint; xem local light/dark/mobile và nội dung dài, ghi kết quả.


### Workspace package — overview gọn và share menu

- [x] Chỉnh share dropdown icon và clickable card đúng keyboard/focus.
- [x] Tạo overview hai cột, catalog tự tải theo quyền; nối view/edit/save, bỏ CTA campaign/banner legacy.
- [x] Thêm locale vi/en, test local desktop/mobile/light/dark và actions/permission bằng fixture, type-check/lint/build.


### Sketch được duyệt — detail trái, list phải

- [x] Nối mặc định current và xem theo ID, chi tiết trái/list phải, card đang dùng trên đầu.
- [x] Cố định chiều cao desktop và scroll độc lập, mobile một scroll, toolbar/share/search.
- [x] Kiểm thử pane switching, focus, search/load more, Client/locked, light/dark vi/en responsive; type-check/lint/build.


### Sketch compact được duyệt — mô tả ngắn và bảng mở chi tiết

- [x] Thu gọn header/facts và đổi nhãn Mô tả gói.
- [x] Bảng hạng mục có Xem/Thu gọn tại hàng, text dài mở thêm thực tế; nối actions vào header.
- [x] Kiểm tra default không cuộn với gói 3 hạng mục, text dài/empty, keyboard vi/en sáng/tối mobile, quyền/share; type-check/lint/build.


### UI v3 đã duyệt — cam nhạt, xám/trắng và nội dung theo không gian

- [x] Áp dụng header/bảng/card/action theo bảng màu sketch v3, tương ứng sáng/tối.
- [x] Bỏ tên lặp; full text khi vừa viewport, fallback Xem thêm khi tràn, kiểm tra vòng lặp đo.
- [x] Test local short/long details, resize, vi/en light/dark desktop/mobile, permission/share và build/lint/type-check.


### Số lượng đầu hàng và tự mở hạng mục khi có chỗ

- [x] Đổi 3 cột và click cả hàng/keyboard không double-toggle.
- [x] Tự mở theo chiều cao, giữ manual override, reset theo gói; kiểm tra resize không loop.
- [x] QA short/long/many rows, vi/en light/dark responsive, share/permission, type-check/lint/build.


### PDF và JPG theo sketch duyệt 06/11/2026

- [x] Điều chỉnh layout PDF đúng sketch và bỏ hướng dẫn.
- [x] JPG ghép trang, bảo vệ bộ nhớ và giữ đủ nội dung.
- [x] Test PDF text/page breaks, JPG dimensions, vi/en/null/long, render ảnh kiểm tra.


### Chọn ngôn ngữ khi xuất file

- [x] Thêm chọn Việt/Anh cho PDF và JPG, locale song song.
- [x] Kiểm tra bốn tổ hợp request/filename, keyboard/touch, sáng/tối/responsive và build/lint.


### Ngôn ngữ trang guest

- [x] Thêm bộ chọn ngôn ngữ guest và locale.
- [x] Kiểm tra loading/error/success, giữ lựa chọn khi reload, không refetch khi đổi ngôn ngữ, keyboard/mobile/theme và build.


### Form nhập liệu theo sketch đã duyệt

- [x] Form bố cục và quick budget/duration không option Trao đổi thêm.
- [x] OfferingEditor 4 dịch vụ, không trùng, giữ draft/ID/legacy, checkbox gợi ý và locale.
- [x] QA tạo/sửa request, validation lỗi ở hạng mục không active, undo draft, copy/null, loading/quyền; vi/en theme mobile keyboard và CI.


### Sửa thanh Lưu đè nội dung

- [x] Tách vùng cuộn và thanh action, kiểm tra không giao nhau ở đầu/giữa/cuối nội dung.
- [x] QA Workspace/Agency fixture, màn thấp/mobile, loading và submit; lint/build.


### Thu gọn vùng tiêu đề và thao tác lưu

- [x] Toolbar gọn với Lưu/Quay lại và vùng cuộn cao hơn.
- [x] Kiểm tra submit ngoài form bằng form id, validation, dirty-back, loading, resize/mobile và đo chiều cao sử dụng.


### Thu nhỏ toolbar lần hai

- [x] Giảm height toolbar bằng padding/font/button responsive; focused lint và browser đo desktop/mobile.


### Sửa 400 impact do đơn vị Báo điện tử

- [x] Sửa contract đơn vị Báo điện tử giữa UI và impact/save; cập nhật seeder.
- [x] Test validator các đơn vị, duplicate và service/seed liên quan.


### Không tự đóng các dịch vụ khác khi bấm Xem

- [x] Sửa auto-budget đóng hàng khác sau explicit expand.
- [x] QA đúng trường hợp 2 mở/1 đóng rồi mở mục thứ ba, resize và đóng độc lập; lint.


### Micro-interaction chọn và xem gói
- [x] Chuyển preview, trạng thái card rõ và keyboard navigation.
- [x] Chevron/mở nội dung và giảm chuyển động; giữ disclosure độc lập.
- [x] Xác nhận tái sử dụng key vi.json + en.json; kiểm tra light/dark/mobile.
- [x] Lint/type-check/build và browser QA local; không ghi DB.

### Xác nhận giảm hạng mục/số lượng
- [x] Resolver, contract impact/save, kiểm tra version/lock/confirmation.
- [x] Đồng bộ worker idempotent, hủy bảo toàn dữ liệu, loại Task đã bỏ khỏi kế hoạch active.
- [x] UI chọn Task/xác nhận/hủy và cập nhật vi.json + en.json.
- [x] Kiểm thử light/dark, keyboard/mobile, HTTP mock và backend regression; ghi rõ giới hạn xác minh.

### Phân biệt bỏ hạng mục và giảm số lượng
- [x] Tách xác nhận bỏ hạng mục và chọn Task giảm; cập nhật vi/en.
- [x] Tên hạng mục gốc từ impact; kiểm tra bỏ toàn bộ/giảm/hỗn hợp/hủy/payload/light-dark/mobile.

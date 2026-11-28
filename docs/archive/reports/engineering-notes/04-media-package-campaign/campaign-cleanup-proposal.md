# Lịch sử dọn Campaign trùng — đã thực hiện theo quyết định của người dùng

**2026-10-09:** Người dùng đã duyệt xóa hẳn cả 35 Workspace có Campaign trùng.
Đây là danh sách kiểm kê trước khi xóa; các đề xuất A/B/C bên dưới không còn là
phương án thao tác. Backup và script xóa có allowlist nằm ở
`D:/FPT/FA26/SEP490/.backups/workspace-cleanup-20261009/`.
Transaction thực tế xóa 35 Workspace, 35 WorkspaceMediaPackage, 70 Campaign,
30 CampaignCollaborator, 141 WorkspaceMember và 10 WorkspaceInvitation.
Mongo Atlas có 0 bản ghi thuộc 35 Workspace này, đã sao lưu 14 collection hiện có.
Sau xóa còn 121 Workspace, 46 Campaign, 0 agreement trùng, 0 orphan Campaign/agreement.
Migration `2026-10-08-campaign-draft-plan.sql` đã áp thành công; unique index
`uq_media_campaigns_agreement` tồn tại. Hai Workspace QA mới cho DA-947 được tạo
sau cleanup, xem `implementation-roadmap.md`.

Ngày kiểm tra: 2026-10-08. Database local: brandhub / container brandhub-postgres.
Các số liệu/danh sách dưới đây là snapshot kiểm kê **trước khi xóa**, giữ lại để đối chiếu backup.

## Bằng chứng và giới hạn

- 116 Campaign; 35 agreement có hai Campaign (70 bản trong nhóm trùng).
- Cả 70 bản cùng created_at = updated_at = 2026-09-29T04:18:24.721896Z,
  không có package_terms_snapshot/package_terms_version, hai timestamp approval đều NULL,
  allocations rỗng. Có dấu hiệu dữ liệu sinh hàng loạt, nhưng CHƯA xác nhận là seed
  có thể xóa; không suy ra không có nội dung chỉ vì thiếu snapshot.
- PostgreSQL có FK campaign_collaborators.media_campaign_id ON DELETE CASCADE.
  Không có cột campaign_id/media_campaign_id khác trong kết quả kiểm tra schema;
  điều này không loại trừ tham chiếu JSON, tên cột khác hoặc hệ thống khác.
- **Chưa kiểm tra Mongo Atlas** tasks.campaignId, notifications hay dữ liệu chuyên biệt.
  Không được coi số liên kết PostgreSQL = 0 là không còn dữ liệu phụ thuộc.
- Không dùng ngày tạo/mới nhất để chọn: các bản có cùng timestamp.
- Chỉ đề xuất A để dọn trước có điều kiện. B/C giữ nguyên chờ quyết định cụ thể.
- Nếu xóa A: còn 108 Campaign, 27 nhóm trùng; CHƯA đủ để áp uniqueness toàn DB.

## A — Đề xuất xét duyệt xóa 8 bản DRAFT không có liên kết đối tác PostgreSQL

Giữ Campaign còn lại trong cùng Workspace. Chỉ thực hiện sau khi người dùng xác nhận
đây là dữ liệu có thể bỏ, kiểm tra tham chiếu Mongo/khác và sao lưu phục hồi được.

| Mã | Workspace | Campaign đề xuất xóa (DRAFT) | Campaign giữ | Trạng thái giữ |
|---|---|---|---|---|
| A1 | Acecook Vietnam x Ants Digital | circle back<br>`432d0363-4ad0-4463-9d3c-5d4f83f812a5` | immersive experience<br>`d6c4ef1a-8fec-4c24-b3b4-7a6d9921f735` | COMPLETED |
| A2 | Coca-Cola x TBWA Vietnam | give you some time back<br>`6cdb048d-abd7-467c-a6e8-411a694f497c` | snackable content<br>`135d5566-9702-40ec-8c43-1b3c677770ee` | IN_PROGRESS |
| A3 | Honda Vietnam x Ogilvy Vietnam | get value out of the conversation<br>`112ed2ab-8c6f-4963-8ea6-1db0b854f251` | deep dive<br>`855c3193-699c-455f-a59c-e7678c688c85` | IN_PROGRESS |
| A4 | IKEA x Innity Vietnam | deep dive<br>`63841364-24d2-4992-b542-cb1d5ab516d3` | plug and chug<br>`0ca68c6d-f6e8-4189-92df-314f735a97f2` | COMPLETED |
| A5 | Momo x SOO Digital | impact map<br>`31735c6f-4563-48f4-8fc0-2d17fbee6511` | put a pin in it<br>`7d817bc0-29aa-43df-bb83-d74b666a6000` | COMPLETED |
| A6 | Sabeco x Golden Digital | button up the loose ends<br>`cd75e2e0-6521-4b3b-b9ec-0eb2775177dc` | synergy<br>`a3291fc5-480d-4292-be59-aaaf9d069dac` | APPROVED |
| A7 | Vinamilk x Ogilvy Vietnam | infographic<br>`89e26a53-72e6-4958-b7b9-7997ad11bfb7` | heads down<br>`08063492-00e3-4f67-967d-b79ab6f6ba94` | COMPLETED |
| A8 | ZaloPay x Ogilvy Vietnam | ideate<br>`ed551acb-802f-4a75-9c6f-51b0a3255981` | branding<br>`cfaec2ee-4099-4ab9-b017-e15a59005af9` | APPROVED |

## B — 8 bản DRAFT có liên kết đối tác: KHÔNG đề xuất xóa lúc này

Có cả liên kết LIVE/CONFIRMED: không thể coi DRAFT là bản không sử dụng.
Nếu về sau duyệt xóa phải duyệt riêng cả liên kết bị cascade. Không tự chuyển liên kết
sang Campaign giữ vì sẽ thay đổi ý nghĩa hợp tác. Danh bạ đối tác gốc không thuộc phạm vi xóa.

| Mã | Workspace | Campaign DRAFT cần quyết định | Campaign còn lại (cũng giữ nguyên) | Liên kết sẽ bị cascade nếu xóa DRAFT |
|---|---|---|---|---|
| B1 | Coca-Cola x Novaon Digital | sprint to the finish line<br>`46db17c8-232b-4ac5-89fe-f6a6a07ec018` | snackable content (APPROVED)<br>`929bf7fa-fd7a-44c9-a60b-9d9c9052b0ea` | LIVE<br>`3350fe74-d416-4d85-be16-c0d120e9eb7a` |
| B2 | IKEA x SOO Digital | branding<br>`10831e8b-30e6-4d04-a915-101893172bad` | customer journey (IN_PROGRESS)<br>`a0e8311e-7f12-4e11-b1f9-9efe45bea976` | CONFIRMED<br>`720d35db-fa66-4b9d-afb7-88047d64d47a` |
| B3 | L'Oréal Paris x TBWA Vietnam | agile marketing<br>`41582f1b-c4d5-4c76-b7aa-0745604b3780` | plug and chug (IN_PROGRESS)<br>`b8cab0c8-5078-4855-a783-0832da411c68` | NEGOTIATING<br>`fc91bbac-9f94-4835-9c3f-599a772cc9e6` |
| B4 | Sabeco x Yeah1 Network | had to 'punt' on that<br>`62a9b4cc-ea9f-4c13-a672-82c5472c14e9` | SWAG (COMPLETED)<br>`950c1101-89dd-4bcc-9409-b57eefd557b6` | CONTACTED<br>`9ca15697-a96f-4d8f-b08e-40918aeb8e2f` |
| B5 | Sony x Metub Network | etc. etc.<br>`e8c8e0be-b32a-44f3-911e-90caef006e8d` | sprint to the finish line (COMPLETED)<br>`7a649ff3-651c-421f-af07-48ad332ec092` | CONFIRMED<br>`5de9dc3c-a664-47b9-81df-c42277e581a8` |
| B6 | Thế Giới Di Động x Novaon Digital | value add<br>`368c7102-4df7-4315-9e1b-860236a7bc1b` | streamline (IN_PROGRESS)<br>`f678d64f-45a1-46f4-8c0f-50f075e0415b` | NEGOTIATING<br>`17562da1-4907-44b3-9f0b-bb23a7fe87f7` |
| B7 | Traveloka x Saatchi & Saatchi Vietnam | put a pin in it<br>`b5709f67-ffde-4772-9fdf-720b70beea21` | get a pulse on (IN_PROGRESS)<br>`f9ef93a8-e1e6-448c-bc56-dc92e7d59e16` | CONFIRMED<br>`2c3a2ba7-123e-4227-9cf5-6997f94aa63d` |
| B8 | Vietjet Air x Innity Vietnam | impact map<br>`3a87ab02-9078-48aa-93c4-ead18223ae72` | customer journey (IN_PROGRESS)<br>`c6cf4f0c-3a11-4513-9f73-b211c6c86916` | CONFIRMED<br>`2a4da960-e7b4-4019-b495-e20d07dd3602` |

## C — 19 nhóm không có DRAFT: giữ cả hai, cần quyết định từng nhóm

Không đề xuất xóa APPROVED/IN_PROGRESS/COMPLETED chỉ để vượt migration.
Có thể chọn bản không cần giữ nếu xác nhận dữ liệu test; hoặc thiết kế di chuyển lịch sử
sang Workspace riêng. Cả hai cách đều cần phê duyệt phạm vi và kiểm tra dữ liệu phụ thuộc.

| Mã | Workspace | Campaign 1 | Campaign 2 |
|---|---|---|---|
| C1 | Adidas x Metub Network | value add · IN_PROGRESS · 1 liên kết<br>`94eef5aa-f195-4c3f-bd5a-f4ac873706be` | out of the box · COMPLETED · 0 liên kết<br>`c5998fd6-24a6-4c98-917a-c790b8171935` |
| C2 | Comfort x Ogilvy Vietnam | get value out of the conversation · COMPLETED · 1 liên kết<br>`0fd76ccd-ad6c-40e6-924f-956b9f826584` | let's take this offline · IN_PROGRESS · 1 liên kết<br>`63a7b70b-41fa-40e2-a29c-60f9ebfcc965` |
| C3 | Grab x Golden Digital | immersive experience · COMPLETED · 0 liên kết<br>`11995a2d-69e3-4406-852f-1dacf16b7b1f` | swim lane · COMPLETED · 0 liên kết<br>`908a1191-9f25-4919-8d5b-75bd0ea15559` |
| C4 | Honda Vietnam x Golden Digital | make it actionable · IN_PROGRESS · 0 liên kết<br>`30b69fc2-a8ce-4b9d-b7fd-80c80d4d40bd` | impact map · IN_PROGRESS · 1 liên kết<br>`ea13e9ac-f3e3-40a8-aeed-41f7c424a754` |
| C5 | Momo x Innity Vietnam | get a pulse on · APPROVED · 0 liên kết<br>`ca2061b4-a5f5-4842-9f0f-75d7d43f5595` | swim lane · APPROVED · 1 liên kết<br>`d9b17884-2c39-4d7e-b6e2-5756c523e5ac` |
| C6 | Nike x Ogilvy Vietnam | get a pulse on · IN_PROGRESS · 0 liên kết<br>`4fd0987a-6e3f-4f1b-bb1b-cd9ce9a85fe3` | thought leadership · COMPLETED · 0 liên kết<br>`97e5a7c3-11b8-488c-9ab3-453bc458ad6b` |
| C7 | P&G x Ogilvy Vietnam | agile marketing · COMPLETED · 0 liên kết<br>`28480f5f-7b40-4747-b095-3b97c9bd1d2e` | expansion play · APPROVED · 1 liên kết<br>`8cb9dc63-3c16-415a-8322-046a6dc0d123` |
| C8 | Panasonic x Ogilvy Vietnam | plug and chug · COMPLETED · 1 liên kết<br>`1387b7cf-e167-499e-addb-65978eb7e01d` | plug and chug · APPROVED · 0 liên kết<br>`cc49e510-bbca-4013-bbd4-f452f61b2eca` |
| C9 | Pepsi x Innity Vietnam | buying cycle · COMPLETED · 1 liên kết<br>`65747305-3853-4916-a2fb-de455473e3aa` | tee it up · IN_PROGRESS · 0 liên kết<br>`8f8ded30-14ed-442d-807f-732309d12e79` |
| C10 | Sony x Golden Digital | streamline · COMPLETED · 0 liên kết<br>`0a44a2a6-6d3e-4ca4-86b1-e1b621c81103` | two-way street · IN_PROGRESS · 0 liên kết<br>`5313a718-03a6-4ab1-b5fc-267a99961576` |
| C11 | Sony x TBWA Vietnam | etc. etc. · APPROVED · 1 liên kết<br>`5e930876-65fa-4186-abd4-292ee7d9d450` | value proposition · COMPLETED · 0 liên kết<br>`d3a06c35-2ec5-49ed-aa7c-8d1f0fa8301a` |
| C12 | Sunhouse x Novaon Digital | infographic · COMPLETED · 0 liên kết<br>`40bf0750-da14-4f18-a22a-47d259be9aef` | growth unit · COMPLETED · 0 liên kết<br>`83de0d2c-8509-4ef1-a066-d3eb8c3e1d2d` |
| C13 | Tiki x Leo Burnett Vietnam | plug and chug · IN_PROGRESS · 1 liên kết<br>`260cc5f9-3e8c-4c5b-a71a-39c160c1f8e6` | had to 'punt' on that · COMPLETED · 1 liên kết<br>`be4f073a-5d5e-4baf-a97a-1e531d6ebfd9` |
| C14 | Traveloka x Isobar Vietnam | put a bow on it · COMPLETED · 1 liên kết<br>`546348c5-a835-444b-ac29-6e80bec52b15` | t-shirt sizes · APPROVED · 0 liên kết<br>`b24b0181-57ae-45bb-bb47-923d61198d1c` |
| C15 | Traveloka x Leo Burnett Vietnam | value proposition · APPROVED · 0 liên kết<br>`b42da2bf-4241-4e01-ab62-7603f30bc1dd` | plug and chug · APPROVED · 1 liên kết<br>`ec28414b-b513-47c4-aa1b-ea2befaab0b7` |
| C16 | Unilever x TBWA Vietnam | market share · IN_PROGRESS · 0 liên kết<br>`79b29e51-4b11-452a-bb35-3d587682f29b` | tee it up · IN_PROGRESS · 0 liên kết<br>`ac123a44-b287-4560-9845-8c73bd0476c3` |
| C17 | VinFast Auto x Golden Digital | get a pulse on · COMPLETED · 0 liên kết<br>`3bb1f10a-242c-4fea-abf6-70d4cd003926` | snackable content · IN_PROGRESS · 1 liên kết<br>`76903f2a-f4ac-41f8-94d5-ffba230e342b` |
| C18 | VinFast x Saatchi & Saatchi Vietnam | bucketize it · COMPLETED · 0 liên kết<br>`00870c37-146c-429c-a087-4d99184b95c3` | bucketize it · COMPLETED · 1 liên kết<br>`7896274c-7f75-43f7-ad7e-e6537b011a33` |
| C19 | ZaloPay x AIM Academy | t-shirt sizes · APPROVED · 0 liên kết<br>`2fa1e8db-bcd5-4b63-9600-05f7a6376c7c` | expansion play · COMPLETED · 0 liên kết<br>`dae34953-52a3-4dfa-9be1-c140da4aad2f` |

## Điều kiện thực thi sau duyệt

1. Người dùng duyệt bằng mã A/B/C và ID Campaign cụ thể, không dùng tên đơn thuần.
2. Đọc lại dữ liệu và tham chiếu PostgreSQL/Mongo; nếu có thay đổi so với danh sách
   hoặc có Task/approval/content liên quan thì dừng, báo lại, không cascade ngầm.
3. Sao lưu toàn bộ bản ghi mục tiêu + bảng con, kiểm tra bản sao đọc được và phương án
   restore (kể cả phải tháo uniqueness nếu khôi phục lại dữ liệu trùng).
4. Xóa trong transaction theo allowlist ID đã duyệt, khóa/chặn ghi đồng thời phù hợp;
   assert số bản ghi/trạng thái/liên kết đúng trước commit. Không xóa Workspace, agreement,
   package, account, Task hoặc danh bạ đối tác.
5. Kiểm tra orphan refs và số nhóm trùng sau thao tác. Chỉ chạy migration unique khi
   mọi nhóm trùng đã được xử lý theo quyết định được duyệt.

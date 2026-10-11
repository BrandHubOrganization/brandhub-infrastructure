# Media Campaign — lộ trình triển khai sau Media Package

Theo dõi tiến độ theo [lộ trình 6 giai đoạn](implementation-roadmap.md).
File hiện tại giữ thiết kế kỹ thuật và các phương án cần BA quyết định.

**Giai đoạn 1 hoàn thành thiết kế 2026-10-08:** [spec](phase-1-design/spec.md),
[data/API/editor contract](phase-1-design/plan.md), [checklist](phase-1-design/task.md),
[test matrix](phase-1-design/test.md). A1–A3 đã được người dùng xác nhận.

Ngày: 2026-10-08. BA mới nhất thay thế đề xuất nhiều đợt hợp tác trong một
Workspace. Code/migration cho giai đoạn 2–5 đã có; trạng thái kiểm chứng mới nhất
nằm trong [roadmap](implementation-roadmap.md), checkpoint 2026-10-10.

## 1. BA đã xác nhận

- Một Workspace gắn với một Media Campaign. Trước khi Manager tạo thì có 0 Campaign;
  sau khi tạo có đúng 1, kể cả Campaign đã hoàn thành. Chiến dịch mới dùng Workspace mới.
- Manager tạo Campaign từ WorkspaceMediaPackage đã được hai bên approved.
- Owner có tính năng Nhân bản Workspace để chọn thông tin/tài nguyên từ Workspace
  cũ đưa sang Workspace mới, giảm công việc setup. DA-1255 đã chốt copy từng thành
  viên và tùy chọn timezone; tài nguyên chờ module riêng.
- Không triển khai nhiều đợt Package/Campaign trong cùng Workspace. Đề xuất đàm phán
  đợt tiếp theo trong cùng Workspace được thay thế bằng chuẩn bị Workspace mới.
- Task tiếp tục dùng MongoDB theo V2. Phải nối editor PostgreSQL hiện tại vào cùng
  Task identity/source of truth trước khi hoàn thiện Campaign → backlog.
- Client góp ý; Manager sửa Campaign; cả hai duyệt lại phiên bản nội dung đã sửa.
- Manager chủ động mark Campaign COMPLETED; còn Task dang dở thì bắt buộc ghi lý do,
  giữ nguyên trạng thái Task con. Không tự complete chỉ vì Task list rỗng/đã xong hết.
- Thêm EVENT_PLAN và PRESS_RECOMMENDATION vào tasks chung, collection riêng lưu
  nội dung theo taskId. Không mở scope hậu cần, nhân sự, vận hành sự kiện hoặc booking.
- Gói mới dùng tổng sản lượng cả gói, không monthly allowance trong đợt này. Ba
  offeringModel cũ không còn quyết định luồng mới; giữ đọc legacy/snapshot đã chốt
  và không tự quy đổi gói theo tháng khi thiếu thông tin.

## 2. Hiện trạng và tác động

| Phần | Hiện trạng | Thay đổi cần làm |
|---|---|---|
| WorkspaceMediaPackage | workspace_id UNIQUE; một selection mỗi Workspace | Giữ quan hệ hiện tại; bỏ kế hoạch mở nhiều đợt |
| Campaign | Prototype tạo nhiều draft/allocations cho một agreement | Giới hạn một Campaign/Workspace, sửa UI không còn tạo thêm |
| Campaign approval/deploy | Approve chưa khả dụng, chưa có deploy | Hoàn thiện DA-948 |
| Task | V2 Mongo; editor dùng JPA Task và FK PostgreSQL | Mongo đã chốt; còn thiết kế tích hợp editor |
| Duplicate Workspace | Chưa được audit implementation | Task riêng thuộc Workspace; chốt danh mục copy rồi mới code |

Audit cả số Campaign theo agreement và theo Workspace trước khi thêm constraint.
Không tự xóa/gộp/chuyển Campaign cũ để migration chạy được.
previous_terms chỉ giữ bản liền trước, không phải full negotiation history.

## 3. Thứ tự triển khai và Jira

| Mốc | FR / Jira | Kết quả |
|---|---|---|
| M0 | DA-942/944/945/946; prototype DA-947 | Baseline đã commit; không khẳng định mọi AC của Jira đã xong |
| M1 | FR 3.5.5 — DA-947 / E50-06 | Một Campaign/Workspace; kế hoạch, work items, UI xem/sửa |
| M2 | FR 3.5.6 — DA-948 / E50-07 | Client góp ý, Manager sửa, duyệt hai bên theo phiên bản |
| M3 | FR 3.5.6 — DA-948, phối hợp E51 | Sinh Task Mongo an toàn và mở được trong editor; Manager hoàn thành Campaign |
| M4 | Duplicate Workspace — DA-1255 / E16-13 | Owner chọn từng thành viên và tùy chọn timezone để tạo Workspace mới; tài nguyên chưa có module |
| M5 | DA-949/950 — E50-08/09 | Danh bạ đối tác và theo dõi hợp tác |
| M6 | DA-951 — FR 3.5.7–3.5.10 | Content Request ngoài kế hoạch, giữ luồng riêng |

M4 có thể triển khai độc lập sau khi audit tạo Workspace hiện tại, không chặn M1/M2.
Không dùng các mã DA-943–946 để ngầm bao gồm Duplicate Workspace. Tạo task có
Epic/Sprint và mã thật trước khi code; chưa tự tạo task hoặc cập nhật Jira trong lần này.
Campaign Addendum chưa có task; phải xem lại tính tương thích với một Campaign/Workspace
trước khi thiết kế, không tự tạo thêm Campaign trong cùng Workspace dưới tên Addendum.

## 4. Thiết kế dự kiến

### M1 — Campaign planning

- Giữ UNIQUE workspace_media_packages.workspace_id. Thêm unique FK
  media_campaigns.workspace_media_package_id và kiểm tra truy cập Workspace để đảm bảo 1:1.
  Không cho đổi agreement hoặc chuyển Campaign sang Workspace khác nhằm lách constraint.
- Concurrent create phải trả Campaign đã tồn tại hoặc conflict rõ ràng. UI chuyển sang
  Xem/Chỉnh sửa Campaign khi đã có một bản, không cho tạo thêm dù bản trước COMPLETED.
- Giữ snapshot/version Package; thêm content_version, work_items JSONB và concurrency guard.
  Mỗi đầu việc có ID ổn định, deliverableId, tên, loại phù hợp và hạn thực hiện.
- Dùng EVENT_PLAN/PRESS_RECOMMENDATION đã chốt cho Event/press, không ép thành POST.
  Phối hợp schema/adapter chuyên biệt với chủ E51; dữ liệu nội dung tham chiếu taskId.
- Một sản phẩm bàn giao có thể cần nhiều Task. Không trừ sản lượng theo số Task máy móc.
- UI danh sách Workspace dẫn đến Campaign duy nhất; phần chi tiết gồm phạm vi gói đã
  chốt, chiến lược, brand guideline, timeline, đầu việc và approval.
- Giữ tương thích endpoint hiện tại khi bổ sung API workspace-scoped. Khóa record để
  chống cập nhật mất dữ liệu. Không tạo hai service logic cho hai kiểu route.
- Luồng mới dùng quantityBasis=TOTAL; không chọn period. Xử lý tương thích legacy
  theo phase-1-design/plan.md, không tự nhân hoặc chuyển monthly snapshot.

### M2 — góp ý và duyệt

- Client gửi góp ý; Manager sửa draft. Mọi sửa nội dung tăng contentVersion và làm
  mất hiệu lực cả hai approval. Reject/góp ý không xóa lịch sử đã duyệt.
- Approve phải kèm version; lưu actor/version/timestamp. Một actor không được đại diện
  cả Agency và Client để tự hoàn thành hai phía.
- Sau khi cả hai approve, giữ nội dung bất biến theo BA hiện hành; tiến độ vận hành
  tách khỏi nội dung. Không áp maxChanges của Package vào Campaign khi chưa được yêu cầu.
- Inbox hiện có gửi thông báo cho phía đối diện, link đúng Workspace/Campaign.
  So sánh bản cũ/mới cho Client khi duyệt lại.

### M3 — deploy và complete

- Mongo là nguồn chính cho Task. Thống nhất ID và chỉnh lookup/editor integration;
  giữ dữ liệu editor đang có, không ghi hai bản Task độc lập ở Mongo và PostgreSQL.
- Outbox/deployment record bền vững ở PostgreSQL; unique key
  (campaignId, campaignWorkItemId), insert-only upsert để retry không reset Task hiện hữu.
  Partial unique index không ảnh hưởng Task thủ công/Content Request thiếu campaignWorkItemId.
- Chỉ chuyển IN_PROGRESS sau khi tất cả Task cần sinh đã được ghi bền vững.
  Lưu tiến trình/lỗi và phục hồi được sau restart hoặc mất kết nối.
- Task mới ở BACKLOG, chưa assignee/QC. Nội dung Post/Livestream/Survey/Meet theo E51.
  Không init lại Atlas; chỉ migration có kiểm tra dữ liệu và index phù hợp.
- Manager mark completed từ IN_PROGRESS; lưu actor/time/reason/Task summary và xử lý
  request lặp an toàn. Có unfinished Task thì reason bắt buộc; không đổi Task con.
- Quyền chuẩn bị Workspace mới không tự xác nhận hạn mức hoặc điều kiện deploy
  đồng thời giữa các Workspace; audit quy tắc Workspace/subscription hiện tại.

### M4 — Duplicate Workspace (đề xuất để BA review)

Owner chọn Workspace nguồn → chọn Nhân bản → nhập tên mới, kiểm tra Client/Manager
và chọn nhóm dữ liệu → xem tóm tắt → tạo Workspace mới → chọn/duyệt Package mới
→ Manager lập Campaign mới.

| Nhóm dữ liệu | Đề xuất, chưa mặc định copy |
|---|---|
| Brand, mô tả, guideline, cấu hình phù hợp | Cho chọn copy; giá trị mới độc lập với nguồn |
| Tài liệu thương hiệu, material, template, hashtag | Chọn danh mục; audit quyền và cơ chế lưu file trước |
| Client/Manager/thành viên | Owner chọn lại hoặc xác nhận người được giữ; kiểm tra trạng thái/quyền hiện tại |
| Package | Có thể gợi ý gói catalogue đã dùng; nếu copy terms thì phải là draft cần duyệt lại |
| Campaign, Task, approval, chat, lịch sử | Đề xuất không copy như công việc đang thực hiện; Workspace nguồn giữ lịch sử |
| Social account/token, lời mời, lịch đăng, job | Không tự chuyển kết nối/quyền/thực thi; chốt quy trình kết nối riêng nếu cần |

- Scope đầu tiên đề xuất chỉ trong cùng Agency; kiểm tra Owner có quyền đọc nguồn
  và tạo đích. Cross-Agency cần yêu cầu riêng, không suy ra từ quyền Owner.
- Có sourceWorkspaceId để truy vết, nhưng không phụ thuộc vòng đời nguồn. FK hoặc
  liên kết phải tránh cascade xóa dữ liệu đã copy khi xóa Workspace nguồn.
- Tài nguyên tham chiếu chung và file copy riêng có chi phí/quyền/xóa khác nhau;
  phải chốt. Không dùng bản sao metadata trỏ vào object sẽ bị xóa theo Workspace cũ.
- Idempotency cho thao tác tạo; nếu copy nhiều tài nguyên dùng tiến trình/job có retry
  và hiển thị lỗi rõ ràng. Không báo hoàn thành khi chỉ copy được một phần.
- Workspace mới giữ package gate hiện tại; thao tác trên đích không ảnh hưởng nguồn.
- Trước code: audit Workspace create/template/member/material services, viết đủ
  spec → plan → task → test riêng và phối hợp người phụ trách Workspace.

## 5. Quyết định và câu hỏi còn mở

| ID | Trạng thái mới |
|---|---|
| Q1 | Cho chuẩn bị/duyệt sớm; nay ở Workspace mới. Điều kiện deploy riêng chưa chốt |
| Q2 | Mongo V2; thiết kế editor soft refs/backfill/cutover ở phase-1-design/plan.md, còn thực hiện và kiểm chứng |
| Q3 | Đã chốt EVENT_PLAN/PRESS_RECOMMENDATION + collection riêng; phối hợp ownership và schema form trước implementation |
| Q4 | Đã chốt Client góp ý, Manager sửa, hai bên duyệt lại |
| Q5 | Đề xuất nhiều đợt trong một Workspace bị thay thế bởi Duplicate Workspace cho Owner |
| Q6 | Đã chốt tổng sản lượng cả gói; không theo tháng trong đợt này |
| Q7 | Đã chốt Manager được complete còn Task dang dở nếu ghi lý do; giữ nguyên Task con |
| D1 | Owner được copy nhóm tài nguyên/thành viên nào; default chọn gì? |
| D2 | File dùng chung hay sao chép độc lập; xử lý sửa/xóa nguồn và quota ra sao? |
| D3 | Package chỉ gợi ý catalogue hay cho sao chép terms thành draft mới? |

## 6. Repo, commit và kiểm thử

- Infrastructure: migration mới + init đồng bộ; SQL trong docs dùng docs tag theo
  yêu cầu. Không sửa migration cũ. Business/Web triển khai theo từng mốc đã chốt.
- Web: paired vi/en keys, light/dark/mobile, lỗi/loading/empty/permission states.
  Gateway /api/v1/** đã forward Business; chỉ sửa khi có nhu cầu thật.
- Commit DA-947 cho planning; DA-948 cho approve/deploy. Duplicate Workspace dùng
  mã Jira được cấp, không dùng placeholder hay đánh dấu task Done khi mới có tài liệu.
- Test một Campaign/Workspace kể cả concurrent create, COMPLETED hoặc đổi ID.
- Test approve phiên bản cũ, reset cả hai approval, permission và notification.
- Test crash/retry deploy không sinh trùng/reset Task; Post mở trong editor dùng cùng ID.
- Test duplicate theo allowlist, người không phải Owner, retry, copy lỗi một phần,
  thành viên inactive, xóa/sửa nguồn, không copy approval/token/job, và package gate đích.
- Demo bằng account hiện có; không seed account mới. Không thay đổi DB trong lần cập nhật này.
- Các test cho BA mới đều chưa chạy vì chưa có implementation.

## Nguồn và lịch sử

[Team guide](../../team_guide.md) · [Master-plan](../../plan/brandhub-master-plan.md) ·
[BA](../../ba/04-media-package-campaign.md) ·
[FR 3.5.5](3-5-5-create-media-campaign/spec.md) · [FR 3.5.6](3-5-6-approve-media-campaign/spec.md).

Bản kế hoạch nhiều đợt trong một Workspace đã được thay thế bởi quyết định BA mới nhất
ngày 2026-10-08: một Workspace/một Campaign, Owner nhân bản Workspace cho chiến dịch mới.

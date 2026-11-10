# Giai đoạn 1 — mô hình và phạm vi Campaign

| Thuộc tính | Giá trị |
|---|---|
| Ngày | 2026-10-08 |
| FR / Jira | 3.5.5 / DA-947; 3.5.6 / DA-948; tích hợp E51 |
| Trạng thái | Hoàn thành thiết kế giai đoạn 1; A1–A3 được người dùng xác nhận 2026-10-08; chưa implementation |
| Phạm vi | Thiết kế và hợp đồng tích hợp; không viết/chạy migration hay thay application code |

## Objective và user story

Manager lập một kế hoạch triển khai từ Package đã chốt trong Workspace; Client xem,
góp ý và duyệt; Manager triển khai thành backlog rồi chủ động kết thúc Campaign.
Thiết kế phải giữ dữ liệu và khả năng sử dụng editor hiện có khi Task chuyển về Mongo V2.

## Quyết định BA đã chốt

- AC1: một Workspace có tối đa một Campaign, kể cả draft/completed; chiến dịch khác
  dùng Workspace khác, Owner có tính năng Duplicate Workspace ở giai đoạn 5.
- AC2: nguồn phạm vi là snapshot của WorkspaceMediaPackage APPROVED, không lấy
  lại nội dung catalogue có thể bị Owner sửa sau đó.
- AC3: Client góp ý, Manager sửa. Mỗi thay đổi nội dung thực sự tăng contentVersion,
  làm mất hiệu lực cả hai approval. Approval gắn với đúng phiên bản được xem.
- AC4: chỉ triển khai sau khi cả Agency và Client duyệt. Nội dung đã chốt bất biến;
  trạng thái vận hành, deployment và completion được quản lý riêng.
- AC5: Task dùng Mongo V2. Task mới do Campaign sinh ra bắt đầu BACKLOG, chưa giao
  người thực hiện/QC; nội dung chuyên biệt thuộc E51 hoặc task mở rộng được phân công.
- AC6: Manager chủ động mark completed từ IN_PROGRESS; được phép khi còn Task
  chưa COMPLETED nhưng phải ghi lý do. Lưu actor/time/reason; giữ nguyên trạng thái
  và khả năng tiếp tục xử lý Task con theo quyền/workflow của Task.
- AC7: retry/concurrent deploy không tạo trùng hoặc reset Task đang được thực hiện.
- AC8: mọi thao tác phải xác minh Workspace thực tế và vai trò hiện tại; không dựa
  riêng vào Workspace/role được lưu trong JWT hoặc lựa chọn cũ trên UI.

## Quyết định BA trong giai đoạn 1 (đã xác nhận)

| ID | Nội dung | Quyết định người dùng | Ảnh hưởng |
|---|---|---|---|
| A1 | Mô hình tính sản lượng | Tổng cho cả gói; không có hạn mức theo tháng trong đợt này | Schema Package, conversion, planning form |
| A2 | Event/press có Task workflow không? | Thêm EVENT_PLAN và PRESS_RECOMMENDATION trong tasks chung, collection riêng chứa nội dung | Enum/validator/views/approval và phối hợp E51 |
| A3 | Complete khi còn Task chưa xong? | Cho phép, bắt buộc lý do; giữ nguyên trạng thái từng Task | Complete API/UI và test |

Workshop dùng SURVEY cho khảo sát và khả năng Meet gắn Task theo E51-08d;
không giả danh Workshop thành LIVESTREAM. Hợp đồng tích hợp được ghi ở plan.md,
cần phối hợp chủ E51 trước khi thay implementation chuyên biệt. Task types mới
không mở rộng scope sang hậu cần/vận hành sự kiện, booking hoặc tự đăng lên báo.

Sản lượng của mỗi deliverable là tổng cho cả Package; duration chỉ mô tả thời gian,
không nhân sản lượng theo tháng. offeringModel cũ giữ để đọc dữ liệu legacy, không
còn quyết định luồng Campaign mới. Snapshot RETAINER đã chốt không tự chuyển đổi;
phải xử lý riêng trước khi cho lập Campaign theo quy tắc tổng mới.

## UI/UX mục tiêu

- Một mục Campaign trong Workspace. Chưa có: Manager tạo từ Package approved,
  Client thấy trạng thái chờ kế hoạch. Đã có: xem Campaign, không có nút tạo thứ hai.
- Các phần: phạm vi Package, chiến lược, timeline, sản phẩm bàn giao, đầu việc,
  góp ý/phiên bản/duyệt và tiến độ triển khai.
- Lưu nháp cho phép kế hoạch chưa đầy đủ; trước approve kiểm tra đủ thông tin
  triển khai. Client góp ý không tự thay nội dung Campaign.
- Trạng thái UI: loading, chưa có Package, Package chưa chốt, chưa có Campaign,
  draft, approval một phía, approved, deploying/failed, in progress, completed,
  conflict version, forbidden và lỗi kết nối.
- Text mới dùng key vi/en song song trong namespace campaign: overview, plan,
  workItems, feedback, approval, deployment, completion, errors. Dùng semantic
  theme tokens, light/dark và responsive theo quy tắc dự án.

## Lỗi và edge cases

- Package chưa chốt: 409 PACKAGE_NOT_APPROVED; Campaign đã có: 409 conflict và ID hiện có.
- Sai Workspace/quyền: 403 hoặc 404 theo convention, không lộ dữ liệu Workspace khác.
- Version cũ: 409, yêu cầu tải lại; không tự approve phiên bản mới thay người dùng.
- Chưa đủ hai approval/plan chưa đầy đủ: không deploy/approve, trả lỗi field/state rõ.
- Dữ liệu prototype có nhiều Campaign: báo danh sách xung đột, không tự xóa/gộp.
- Catalogue đổi, retry sau crash, mất kết nối Mongo hoặc editor lookup fail: fail closed,
  giữ dữ liệu đã ghi và cho phép retry theo contract.
- Chi tiết API/data model và các điều kiện tương thích ở plan.md.

## Definition of done của giai đoạn 1

1. A1–A3 đã được người dùng xác nhận và ghi lại ở trên.
2. Schema Campaign/work item, API, state/version và quyền đã thống nhất.
3. Có phương án Task/editor, migration dữ liệu cũ và checklist kiểm chứng; chưa chạy migration.
4. spec/plan/task/test, roadmap và FR liên quan đồng bộ; ghi rõ task/ownership cần phối hợp.
5. Không đánh dấu giai đoạn 2–4 hoặc Jira DA-947/948 Done chỉ vì hoàn thành thiết kế.

Ngoài phạm vi: Duplicate Workspace implementation, specialist authoring forms,
booking/phát sóng/hậu cần sự kiện, billing, Campaign Addendum, seed tài khoản mới.

Nguồn: [BA](../../../ba/04-media-package-campaign.md),
[roadmap](../implementation-roadmap.md), [delivery plan](../campaign-delivery-plan.md).

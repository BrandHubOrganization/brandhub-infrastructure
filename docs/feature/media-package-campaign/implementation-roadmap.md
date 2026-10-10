# Lộ trình triển khai Media Campaign — 6 giai đoạn

Cập nhật: 2026-10-10. Đây là thứ tự triển khai, chưa có ngày bắt đầu/kết thúc
hoặc deadline được chốt. Dùng file này để xác định điểm tiếp tục công việc;
thiết kế kỹ thuật nằm trong [campaign-delivery-plan.md](campaign-delivery-plan.md).

## Điểm tiếp tục hiện tại

- Media Package đã có baseline demo và commit trên nhánh
  `feature/media-package-offering-model`; chưa push trong lần checkpoint.
- Campaign đã có code một Campaign/Workspace, lập kế hoạch nháp, góp ý/duyệt
  hai bên theo phiên bản, deploy Task Mongo có retry và hoàn thành có lý do.
  Các bước kiểm chứng dữ liệu thật bên dưới còn phải hoàn tất trước khi đóng task.
- **Giai đoạn 1 đã hoàn thành thiết kế:** xem [bộ hồ sơ](phase-1-design/spec.md).
- **Đã giải quyết blocker dữ liệu giai đoạn 2 (2026-10-09):** theo quyết định
  của người dùng, xóa hẳn 35 Workspace có Campaign trùng sau backup;
  áp migration DA-947. Còn 121 Workspace, 46 Campaign và 0 trùng.
  Có 2 Workspace QA dùng account có sẵn để test tạo/sửa Campaign.
- Giai đoạn 2–5 đã có code; chưa hoàn tất smoke test API/Atlas/browser theo từng
  mục. Không suy ra trạng thái Jira Done từ việc code hoặc unit test đã có.

## BA cần giữ khi tiếp tục

- Một Workspace có tối đa một Campaign, kể cả draft hoặc Campaign đã hoàn thành.
  Manager tạo Campaign từ Package đã được hai bên duyệt trong Workspace đó.
- Chiến dịch mới dùng Workspace mới. Owner có tính năng Nhân bản Workspace để
  chọn thông tin/tài nguyên từ Workspace cũ. Không làm nhiều đợt trong cùng Workspace.
- Task dùng MongoDB V2; cần tích hợp editor hiện đang dùng Task PostgreSQL.
- Client góp ý, Manager sửa; nội dung đổi làm mất hiệu lực cả hai approval và
  cả hai phải duyệt lại phiên bản mới.
- Manager được hoàn thành Campaign còn Task dang dở nếu ghi lý do; Task giữ nguyên trạng thái.
- Gói mới tính tổng sản lượng, không có hạn mức theo tháng; giữ snapshot legacy để xử lý riêng.
- Thêm EVENT_PLAN và PRESS_RECOMMENDATION vào tasks; nội dung chuyên biệt ở collection riêng.
- Không init lại Mongo Atlas, không tạo account test mới. Dùng account hiện có.

## Các giai đoạn

| Giai đoạn | Phạm vi | Kết quả bàn giao / tiêu chí qua giai đoạn | Jira | Trạng thái |
|---|---|---|---|---|
| **1. Chốt mô hình và phạm vi** | Chốt fields Campaign, cách tính sản lượng Package, loại đầu việc và contract Task/editor; cập nhật spec → plan → task → test | A1–A3 đã được người dùng chốt; data/API contract và phương án Mongo/editor đã ghi trong phase-1-design | DA-947, DA-948; phối hợp E51 | Hoàn thành thiết kế 2026-10-08; chưa implementation |
| **2. Tạo và quản lý Campaign nháp** | Ràng buộc một Campaign/Workspace; tạo từ Package approved; chiến lược, timeline, hạng mục, work items; lưu/sửa nháp và trang chi tiết | Manager lập được kế hoạch, Client xem được; concurrent create không sinh Campaign thứ hai | DA-947 / E50-06 / FR 3.5.5 | Code + unit/UI tests + migration + QA data + Hibernate validate; cần smoke test API thật và concurrent create |
| **3. Góp ý và duyệt Campaign** | Client góp ý; Manager sửa; version/diff, thông báo; approval hai bên và reset-on-edit | Hai bên chốt cùng phiên bản; lỗi stale version và sai quyền được xử lý; sẵn sàng triển khai | DA-948 / E50-07 / FR 3.5.6 | Code + migration local + targeted tests + Web build đã có 2026-10-09; còn smoke test API và review UI trực quan |
| **4. Triển khai và kết thúc Campaign** | Sinh Task Mongo ở BACKLOG; chống trùng/retry, tích hợp editor, tiến độ; Manager mark completed | Demo Package → Campaign → Task thật → hoàn thành; retry không ghi đè Task đã xử lý | DA-948, phối hợp E51 | Code, PostgreSQL migration local và unit tests đã có. Đã cung cấp hướng dẫn chạy/kiểm tra migration Atlas; chưa nhận kết quả xác minh schema và chưa smoke test deploy/editor với Atlas thật |
| **5. Nhân bản Workspace** | Owner chọn nguồn, tên mới, múi giờ và thành viên cần sao chép; tài nguyên chờ module quản lý tài nguyên | Setup chiến dịch mới từ dữ liệu được chọn; nguồn không đổi; không kế thừa approval hoặc thực thi cũ ngoài ý muốn | DA-E16-13 / DA-1255 | Code API/UI và migration đã có; migration local đã áp và kiểm tra cột/index 2026-10-09; còn smoke test API/browser |
| **6. Bổ sung nghiệp vụ mở rộng** | Danh bạ đối tác, theo dõi hợp tác Campaign; Content Request bổ sung ngoài kế hoạch | Hoàn thiện các nhánh đối tác và yêu cầu bổ sung, không trộn vào luồng Campaign chính | DA-949, DA-950, DA-951 | Chưa triển khai trong lộ trình này |

## Thứ tự và phụ thuộc

- Ưu tiên **1 → 2 → 3**. Mốc demo tiếp theo: Manager lập Campaign từ Package
  đã chốt, Client góp ý và hai bên duyệt.
- Giai đoạn **4** tiếp nối 3, cần thống nhất Task identity và tích hợp editor với Mongo.
- Giai đoạn **5** có thể thực hiện độc lập sau khi chốt scope copy và audit module
  Workspace, không bắt buộc chờ giai đoạn 4 hoàn tất.
- Giai đoạn **6** chia riêng DA-949 → DA-950 và DA-951. Danh bạ đối tác có thể làm
  độc lập; liên kết đối tác cần Campaign; Content Request sinh Task dùng contract của 4.
- Không triển khai nội dung thuộc phần chuyên biệt của thành viên khác nếu chưa
  thống nhất interface, trách nhiệm và task liên quan.

## Quyết định còn mở

| Vấn đề | Cần trả lời trước khi làm |
|---|---|
| Legacy Package | Tổng sản lượng đã chốt cho gói mới; inventory snapshot monthly cũ và xử lý từng trường hợp trước migrate |
| Phối hợp E51 | Hai Task type mới đã chốt; phân task và review schema form/Workshop adapter với người phụ trách trước code chuyên biệt |
| Task/editor | Phương án ở phase-1-design/plan.md: Mongo Task, PG Yjs soft refs; cần inventory/backfill/cutover và regression |
| Duplicate Workspace | Đã chốt DA-1255: Owner chọn từng thành viên và tùy chọn copy chỉ múi giờ; không copy Package/Campaign/history hay file. Tài nguyên chờ module quản lý tài nguyên. Migration local đã kiểm tra; còn smoke test API và review UI. |
| Deploy | Điều kiện triển khai và hạn mức giữa các Workspace cần đối chiếu rule hiện tại; không suy ra từ quyền chuẩn bị/duyệt sớm |

Các phương án trong delivery plan là đề xuất khi được ghi là chưa chốt, không phải
sự đồng ý ngầm của BA. Mỗi câu trả lời mới phải cập nhật spec trước kế hoạch/code.

## Bàn giao giai đoạn 1 — 2026-10-08

- A1: tổng sản lượng cả gói; A2: thêm hai Task type Event/press; A3: complete với
  lý do nếu còn Task dang dở — người dùng xác nhận trong phiên làm việc.
- Đã lưu fields/API/version/permission, phương án Task/editor và 26 test cases.
- Chỉ thay tài liệu; chưa chạy migration, đổi dữ liệu hay code giai đoạn 2.
- Hồ sơ: [spec](phase-1-design/spec.md), [plan](phase-1-design/plan.md),
  [task](phase-1-design/task.md), [test](phase-1-design/test.md). Chưa tạo commit cho lần này.

## Quy tắc bàn giao và commit

### Kiểm tra trước commit — 2026-10-10

- Business Service: `mvn.cmd -q test` thành công; 447 test được báo cáo,
  416 pass, 31 skip, 0 failure/error. Đây là test suite, không phải bằng chứng
  đã smoke test API và Atlas đang chạy.
- Web: lint 0 error/81 warning; type-check và production build pass. Build và
  browser tests cần chạy ngoài sandbox Windows do lỗi `spawn EPERM`.
- Playwright Package/Campaign (API mock): lần đầu 16/18 pass. Test RETAINER
  timeout nhưng chạy lại riêng pass; bốn case Campaign đều pass. Còn lỗi đã biết:
  utility `/media-package` chuyển về `/dashboard`, không về Workspace.
- Các file Mongo init/deployment/preflight qua `node --check`; diff không có lỗi
  whitespace. Không chạy migration, seed hoặc sửa dữ liệu thật trong lần review này.
- Chia commit theo DA-947/DA-948 (Campaign) và DA-1255 (Duplicate Workspace),
  giữ nguyên nhánh `feature/media-package-offering-model`. Không push hoặc đổi Jira.
- Giữ ngoài commit: cấu hình ChromaDB, định dạng team guide, định dạng migration
  E51-01 cũ và seed demo cũ tạo account mới. Không xóa các thay đổi này.

Commit local cho checkpoint này (chưa push):

| Repo | Campaign DA-947/DA-948 | Duplicate Workspace DA-1255 |
|---|---|---|
| business-service | `7600dd4` | `32b94d2` |
| web | `ae22c58` | `55b428e` |
| infrastructure (migration/init/spec nhân bản) | `325c938` | `635ecc5` |

Tài liệu BA/master-plan và trạng thái kiểm thử được lưu bằng commit docs riêng
cùng checkpoint; dùng `git log` để tra mã commit đó.

### Tiến độ theo Jira sau review

| Jira / Master-plan | Bằng chứng hiện tại | Việc còn lại trước khi đóng task |
|---|---|---|
| DA-942 / E50-01 | Entity, API template/Agency package, tạo/copy gói, ẩn/hiện và UI đã có ở baseline | Admin authoring thuộc luồng Admin; review theo AC hiện hành |
| DA-943 / E50-02 | Client chọn gói Agency, snapshot và gate Workspace đã có | Reminder sau X ngày chưa triển khai; X/cadence cần chốt; AC prompt không chặn trong master-plan cũ cần đối chiếu BA hard gate đã chốt |
| DA-944 / E50-03 | WorkspaceMediaPackage, snapshot/version/approval persistence đã có | Không phát hiện phần triển khai mới còn thiếu trong phạm vi entity |
| DA-945 / E50-04 | Đàm phán hai phía, thông báo và diff bản liền trước đã có | Chưa có append-only full negotiation history; giới hạn Client proposals theo maxChanges khác AC không giới hạn trong master-plan cũ |
| DA-946 / E50-05 | Duyệt hai phía và reset approvals khi đổi terms đã có | Chưa có thao tác tự rút approval; cần đối chiếu AC |
| DA-947 / E50-06 | Code/API/UI Campaign nháp 1:1, snapshot, work items và version guard; migration local đã kiểm tra | Smoke test API có xác thực và concurrent create; lỗi utility redirect |
| DA-948 / E50-07 | Code góp ý/duyệt/version/diff/inbox, durable deploy Mongo, retry và complete | Xác minh migration Atlas; smoke test Package → Campaign → Task/editor, retry sau partial failure/restart |
| DA-949 / E50-08 | Entity/controller/repository có sẵn; service vẫn throw Not implemented | Implement CRUD đối tác và test |
| DA-950 / E50-09 | Entity/repository có sẵn; assign/update service vẫn throw Not implemented | Implement liên kết/trạng thái hợp tác và test |
| DA-951 / E50-10 | Đã có tài liệu/DB baseline | Chưa có backend Content Request lifecycle và UI thật trong luồng hiện tại |
| DA-1255 / E16-13 | API/UI nhân bản thành viên có chọn lọc + timezone, idempotency; migration local và 7 service tests pass | Smoke test API/browser light/dark/mobile; tài nguyên chờ module riêng |

Các đánh giá này là trạng thái code được kiểm tra, không phải trạng thái Jira đã cập nhật.

### Checkpoint giai đoạn 2 — 2026-10-08

- Business: workspace-scoped create/list/detail/PATCH, snapshot, total deliverables,
  typed work items, version guard/reset-on-edit, immutable approved plans; old create
  route also enforces one Campaign and rejects monthly/partial allocations.
- Web: `/workspaces/:id/campaigns`, sidebar entry after Package gate, Manager form,
  Client read-only detail, vi/en, legacy warning, conflict preserves input.
- Migration `2026-10-08-campaign-draft-plan.sql` + init updated; migration NOT applied.
  It aborts on duplicate agreements before any schema change. New code needs this
  schema before runtime rollout; do not restart it against the old schema yet.
- Targeted backend suite: 66 tests pass after clean build. Web production build and
  targeted lint pass. Browser regression: 17/18 pass, including all 4 new Campaign
  cases; utility `/media-package` redirect test fails (lands on `/dashboard`), unresolved.
- No Mongo init, seed, data mutation, approval/deploy implementation, commit or push.
- Catalogue offering-model UI remains the existing Package slice; this stage only
  consumes total-compatible frozen terms and explicitly blocks legacy monthly terms.
- Remaining: decide duplicate-data treatment; test migration + actual concurrent
  creates/rollback/schema validation; review legacy plans and utility redirect failure.

### Data checkpoint — 2026-10-09

- Backup trước xóa: `D:/FPT/FA26/SEP490/.backups/workspace-cleanup-20261009/postgres.dump`
  (PostgreSQL full custom dump; SHA-256:
  `891F559FED232AD3A5BBAFC9B03BC67DAEBB4ACDE6A2548E8492334EC037C700`),
  `mongo-backup/` (14 collection). Tệp `targets.json` khóa 35 Workspace/70 Campaign.
- Script `delete-approved-workspaces.sql` đã commit transaction thành công. Không xóa
  User, Agency, MediaPackage catalogue, ClientProfile hoặc ThirdPartyCollaborator dùng chung.
- Mongo không có document thuộc 35 Workspace; số liệu chat/post/social account khác
  giữ nguyên. PostgreSQL sau xóa: 121 Workspace, 46 Campaign, 0 duplicate, 0 orphan.
- Migration DA-947 đã áp; unique index có mặt. QA fixture `seed-campaign-qa.sql`
  tạo hai Workspace riêng, dùng Agency package "Bộ 20 bài đăng mạng xã hội" và
  account Quick Login hiện có:
  - `da947000-0000-4000-8000-000000000001` — DA-947 QA Campaign create;
    Package APPROVED, **chưa có Campaign**; dùng để test tạo.
  - `da947000-0000-4000-8000-000000000002` — DA-947 QA Campaign edit;
    Package APPROVED, Campaign DRAFT `da947000-0000-4000-8000-000000000005`;
    dùng để test sửa và Client xem.
  - Manager/Agency Owner: `user177@hotmail.com`; Client: `user59@gmail.com`.
  - Đây là fixture QA từ snapshot gói đã duyệt, không phải một vòng đàm phán
    thực tế mới; không dùng làm bằng chứng approval nghiệp vụ.
- Hibernate `validate` và khởi động Business Service thành công với schema đã migrate;
  tiến trình kiểm tra đã dừng sau xác nhận. Lần chạy đầu bị AWS S3 region có
  whitespace cuối dòng; đã sửa duy nhất dòng `AWS_S3_REGION` trong `.env` local.
  Chưa chạy smoke test API có xác thực hoặc concurrent create. Không init Mongo Atlas.
- Vào `/workspaces/da947000-0000-4000-8000-000000000001/campaigns` để test tạo;
  `/workspaces/da947000-0000-4000-8000-000000000002/campaigns` để test sửa/xem.

1. Mỗi giai đoạn có tài liệu đúng BA, checklist và test case trước code.
2. Triển khai backend/UI theo phạm vi đã chốt; migration mới và init phải đồng bộ.
3. Chạy kiểm tra phù hợp, ghi rõ phần chưa kiểm chứng; kiểm tra i18n vi/en,
   light/dark/mobile và hồi quy Package/Workspace/editor khi bị ảnh hưởng.
4. Commit nhỏ theo Jira bằng tiếng Anh, ví dụ `feat(DA-947): add campaign plan editor`,
   `feat(DA-948): add versioned campaign approval`; tài liệu dùng `docs`.
5. Duplicate Workspace thuộc DA-E16-13 / Jira DA-1255; không gán vào task Package cũ.
6. Khi kết thúc một giai đoạn, cập nhật trạng thái, commit, kết quả kiểm tra và
   bước tiếp theo trong file này. Chỉ đánh dấu hoàn thành khi đạt tiêu chí bàn giao.

## Liên kết để tiếp tục

- [Kế hoạch kỹ thuật và câu hỏi chi tiết](campaign-delivery-plan.md).
- [FR 3.5.5 — Create Media Campaign](3-5-5-create-media-campaign/spec.md).
- [FR 3.5.6 — Approve/Deploy Media Campaign](3-5-6-approve-media-campaign/spec.md).
- [Master-plan](../../plan/brandhub-master-plan.md).
- [Team guide](../../team_guide.md).

Lưu ý: các mốc M0–M6 trong delivery plan là nhóm kỹ thuật, không phải số giai đoạn
trong file này. Giai đoạn 1 là bước chốt thiết kế; giai đoạn 6 gom hai nhánh đối tác
và Content Request. Khi trao đổi tiến độ dùng số giai đoạn 1–6 ở đây.

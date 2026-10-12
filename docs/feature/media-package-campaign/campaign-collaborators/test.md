# Kiểm chứng E50-09 / DA-950

| ID | Input/điều kiện | AC | Mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC01 | Gán đối tác cùng Agency | AC1 | CONTACTED và actor/time | Happy | Pass — service unit + browser mock |
| TC02 | Gán lại link đang CONFIRMED | AC1 | Link cũ, giữ trạng thái | Edge | Pass — service unit |
| TC03 | Gán đối tác khác Agency | AC1,6 | Từ chối, không insert | Error | Pass — service unit |
| TC04 | Cùng đối tác ở hai Campaign | AC3 | Hai link độc lập | Happy | Pass — service unit |
| TC05 | NEGOTIATING → CONTACTED | AC2,3 | Cập nhật actor/time, không sửa Campaign | Edge | Pass — unit + browser mock |
| TC06 | Manager/Creator/Owner vs Client/outsider | AC4 | Ghi đúng role; Client read-only; outsider 403 | Error | Pass — access unit + MVC + browser mock |
| TC07 | Workspace/Agency inactive; membership inactive | AC4 | Từ chối | Error | Pass — access unit |
| TC08 | Campaign/link khác Workspace | AC6 | 404, không ghi | Error | Pass — service unit |
| TC09 | Timestamp cũ | AC6 | 409, giữ trạng thái | Error | Pass — unit + MVC + browser mock |
| TC10 | Null/unknown enum, invalid paging | AC6 | 400 | Error | Pass — MVC; có page offset overflow |
| TC11 | Chưa có Campaign; danh bạ rỗng | AC5 | Empty rõ ràng, không có thao tác gán sai | Edge | Pass — unit + browser mock |
| TC12 | List nhiều trang, Client đọc | AC4,5 | Đúng Agency/Campaign, không lộ contact | Happy | Pass — unit + browser mock; HQL parse validation |
| TC13 | Browser Manager gán/sửa, Creator vào trang | AC2,4,5 | UI hoạt động, không mở quyền duyệt Campaign | Happy | Pass — browser mock |
| TC14 | Browser 403/409/network lỗi | AC5,6 | Báo lỗi/reload, không báo thành công giả | Error | Pass — browser mock, list retry và write 403/409 |
| TC15 | Build và regression suites | AC1–6 | Không có failure mới | Edge | Pass — Maven, Web checks, 12 mới + 4 browser regression |

Unit/controller và browser API-mock không thay thế smoke trên PostgreSQL thực.
Chưa chạy smoke dữ liệu thật; không seed hoặc init database trong task này.

## Bằng chứng 2026-10-10

- `mvn.cmd -q test -Ddebug=false`: 496 tests trước khi thêm optional PostgreSQL
  smoke; 465 pass, 31 skipped, 0 failures/errors. Bộ E50-09 có 49 tests
  (23 service, 11 access, 14 MVC, 1 Hibernate query validation).
- `npm.cmd run type-check`, `npm.cmd run build`: pass. Build chạy ngoài sandbox
  do giới hạn Windows spawn EPERM, không sửa dependencies.
- `npm.cmd run lint`: 0 errors, 81 warnings có sẵn; lint các file mới/sửa E50-09
  không có warnings.
- Playwright campaign-partners: 12/12 pass; regression `media-package --grep
  Campaign`: 4/4 pass. Đã xem ảnh mobile dark; không tràn ngang light/dark.
- Parse OpenAPI YAML và kiểm tra 269 local references: pass.
- Không tuyên bố full browser suite pass: lỗi utility `/media-package` redirect
  đã biết từ checkpoint trước, không thuộc task này và không được sửa ở đây.

## Smoke PostgreSQL tùy chọn

Pre-commit verification (2026-10-11): reran the four targeted E50-09 unit/controller/
query test classes successfully (49 tests). Web scoped ESLint has 0 errors and one
existing initialization-effect warning in NegotiateTermsModal; app/node TypeScript
checks pass. This does not claim PostgreSQL/JWT/concurrency smoke completion.

Test `CampaignCollaboratorPostgresTest` chỉ chạy khi `BRANDHUB_POSTGRES_SMOKE=true`.
Truyền `BRANDHUB_POSTGRES_TEST_URL`, `BRANDHUB_POSTGRES_TEST_USER`,
`BRANDHUB_POSTGRES_TEST_PASSWORD` qua environment (không commit credentials).
Chạy `mvn.cmd -q -Dtest=CampaignCollaboratorPostgresTest test`.

Test dùng Campaign/account Owner đã có, tạo duy nhất fixture đối tác/link trong
transaction và luôn rollback, kiểm tra fixture đã biến mất. Không khởi động app,
không chạy seeders/Mongo, không tạo account hay Workspace mới. Đây là service/JPA
smoke; API JWT smoke và kiểm thử đồng thời nhiều connection vẫn riêng.

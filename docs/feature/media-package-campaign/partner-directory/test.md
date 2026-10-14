# Test — DA-949/950

| ID | Case | Expected |
|---|---|---|
| P01 | Owner CRUD Agency mình | Tạo/read/update đúng DTO, scope/audit/version |
| P02 | Manager/Creator/Client ghi directory | 403; Agency MEMBER không suy ra quyền Owner |
| P03 | Owner Agency khác, tamper agencyId hoặc partnerId | Từ chối không lộ/di chuyển dữ liệu |
| P04 | Xóa partner chưa dùng | Xóa thành công; không tác động Campaign/partner khác |
| P05 | Xóa partner đang linked hoặc firstUsedAt có giá trị | 409; chỉ deactivate được; link/history còn |
| P06 | Inactive partner | Management thấy badge, active picker không thấy; API/legacy assign link mới bị chặn |
| P07 | Existing inactive link đọc/update hợp tác | Được theo quyền DA-950; không reset Campaign approvals |
| P08 | Assign lặp inactive link đã tồn tại | Trả link cũ, không tạo mới/reset trạng thái |
| P09 | Assign vs delete/deactivate đồng thời | Lock/FK bảo vệ; không orphan hoặc link mới sau deactivate thắng |
| P10 | Một partner nhiều Campaign | Cooperation độc lập, first use marker không mất |
| P11 | Link/Campaign cũ bị xóa sau lần sử dụng | Marker giữ; partner vẫn không hard delete được |
| P12 | Stale update hoặc deactivate lặp | Không silent overwrite; hành vi idempotent/conflict nhất quán DTO |
| P13 | Migration rerun/init parity/backfill | Existing partners active, link/status giữ nguyên; marker baseline ghi rõ nguồn |
| P14 | Legacy history không xác minh được | Báo review dữ liệu, không đoán partner chưa dùng để xóa |
| P15 | UI vi/en, light/dark, 375/768/1440, keyboard | Key song song, focus/contrast/layout đạt, confirm rõ xóa vs ngừng |
| P16 | Empty/error/retry và API thật | Không fallback mock, scope đúng, không tác động AI/module khác |

Unit/service, PostgreSQL concurrent integration, JWT API và browser tests phải ghi evidence riêng. Mock browser pass không thay cho kiểm chứng FK/lock trên PostgreSQL thật.

Trước code: thêm case legacy usageHistoryVerified=false không có link vẫn 409 khi
xóa; create mới flag=true; payload không được tự sửa flag/firstUsedAt/isActive/version;
trigger writer cũ cũng chặn assign inactive và giữ marker sau xóa link; stale form sau
first assign báo conflict, không xóa marker. Contact JSON object và giới hạn chiều dài.

## Evidence 2026-10-13

- Phase-4 selection: **71 passed, 1 skipped** across DirectoryPartnerControllerTest,
  DirectoryPartnerServiceTest, DirectoryPartnerPostgresTest, PartnerLifecycleMigrationTest
  và CampaignCollaborator*Test. Skip là opt-in smoke trên dữ liệu application cũ;
  không bật để tránh ghi database đang dùng.
- Regression cùng ContentRequest*Test: **166 passed, 13 skipped**, 0 failures/errors.
  Các test Mongo cô lập cần container/URI riêng (đã kiểm chứng ở giai đoạn 3),
  read-only Atlas inventory và smoke application DB không tự bật trong lần chạy này.
- PostgreSQL 17 container `brandhub-partner-phase4-test`, database `partner_test`,
  port 55438, tmpfs; không lấy mật khẩu/config application. Full init SQL chạy thành
  công, Hibernate validate entity và query thật, enum filter null/non-null, scope,
  active picker, version increment, trigger inactive 23514, marker sau xóa link.
- Migration test tạo schema fixture riêng: schema legacy → migration hai lần,
  backfill chỉ linked rows, legacy flags=false; JDBC concurrent writers kiểm tra
  deactivate thắng thì insert bị chặn, assign thắng thì conditional delete không xóa.
  Đây là kiểm thử JDBC/trigger + service unit, không giả nhận là full API concurrent test.
- MockMvc verifies HTTP 201/204/400/403/409 envelopes; addFilters=false nên **không
  thay thế JWT/Gateway smoke**. Owner/cross-Agency guard kiểm chứng riêng bằng service unit.
- Web type-check pass; lint 0 errors/81 warnings hiện có, lint targeted feature sạch;
  production build pass (Vite cần quyền spawn ngoài sandbox).
- Playwright CLI browser fixture: Owner directory/create/edit/detail, bảo toàn contact
  keys cũ, khóa delete legacy, delete mới chưa dùng, deactivate legacy, filter empty;
  375/768/1440 không horizontal overflow, light/dark screenshots đã inspect,
  form auto-focus/Escape, browser console 0 errors. API fixture chỉ trong browser,
  không ghi DB; chưa full accessibility/contrast audit hay real API UI smoke.

## Chạy lại PostgreSQL tests

Tạo PostgreSQL 17 **cô lập** ở 127.0.0.1:55438, DB/user `partner_test`, password
`partner_test_only` (fixture, không dùng credential thật), chạy full init mới vào DB đó.
Tại repo business-service:

```powershell
$env:BRANDHUB_PARTNER_ISOLATED_TEST='true'
$env:BRANDHUB_POSTGRES_TEST_URL='jdbc:postgresql://127.0.0.1:55438/partner_test'
mvn.cmd '-Dtest=DirectoryPartner*Test,PartnerLifecycleMigrationTest,CampaignCollaborator*Test' test
Remove-Item Env:\BRANDHUB_PARTNER_ISOLATED_TEST
Remove-Item Env:\BRANDHUB_POSTGRES_TEST_URL
```

Tests từ chối URL khác fixture URL. Migration test chỉ drop schema có prefix ngẫu
nhiên do chính test tạo; Hibernate test rollback dữ liệu fixture. Container test
được cleanup sau kiểm thử. Chưa apply migration local shared/PostgreSQL production.

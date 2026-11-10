# Test — timezone consistency

| ID | Input | Mong đợi | Trạng thái |
|---|---|---|---|
| TZ01 | GET Workspace timezone_config hợp lệ, settings.timezone=null | API trả cột chuẩn, không repo.save | Pass (service unit) |
| TZ02 | JSON timezone khác cột chuẩn | API trả cột chuẩn, giữ platforms/industryFields; JSON không bị sửa bởi GET | Pass (service unit) |
| TZ03 | JSON thiếu/malformed/literal null | Không NPE; API vẫn trả cột chuẩn | Pass (service unit) |
| TZ04 | Settings đổi sang UTC/Asia/Tokyo hợp lệ | Cột + JSON + response cùng giá trị; giữ fields khác | Pass (service unit) |
| TZ05 | Partial settings update không timezone | Không đổi cột chuẩn sang timezone JSON cũ | Pass (service unit) |
| TZ06 | Blank/sai/whitespace timezone và name mới | 400 fields.timezone, không save hoặc đổi name | Pass (service unit) |
| TZ07 | Tạo Workspace default/list | Response settings.timezone đúng cột/default, không đổi roles | Pass (service unit) |
| TZ08 | Duplicate copy true/false, JSON nguồn khác cột | True copy cột chuẩn, false default; source/other copy policy giữ nguyên | Pass (service unit) |
| TZ09 | API timezone khác UTC, deadline sát đầu/cuối ngày Campaign | UI/API dùng cùng ngày Workspace, đúng biên bao gồm | Pass (unit API projection + rules, Node bounds) |
| TZ10 | Node request deadline regression | Date boundaries/day rollover/DST nguyên vẹn | Pass (9 Node unit tests) |
| TZ11 | Client mở Requests Workspace đã báo lỗi sau restart | Tải timezone đúng, có date min/max; không còn deadlineUnavailable | Chưa test (manual) |

Tests dùng mocks/owned local fixtures, không tạo Request/Account trong data shared.

## Verification — 2026-10-14

Business branch merge/review2: clean build và selected tests pass, tổng 71 tests, không fail/error/skip:
WorkspaceServiceTest 42, WorkspaceDuplicationServiceImplTest 8, WorkspaceTimezoneConsistencyTest 18,
ContentRequestDeadlineTest 3. Không chạy toàn suite hoặc live API/seeders.

```cmd
mvn.cmd clean -Dtest=WorkspaceTimezoneConsistencyTest,WorkspaceServiceTest,WorkspaceDuplicationServiceImplTest,ContentRequestDeadlineTest test
```

Web không sửa source, 9 tests pass:

```powershell
node --experimental-strip-types --test --test-isolation=none tests/unit/request-deadline.test.mjs
```

git diff --check đạt. Không migration, seed, backfill hoặc update DB thật. Stash Task phase1 giữ nguyên.

## Test lại trên máy người dùng

Dừng Business Service cũ rồi chạy lại từ đúng repo (CMD chuyển ổ bằng cd /d):

```cmd
cd /d D:\FPT\FA26\SEP490\brandhub-business-service
mvn.cmd spring-boot:run
```

Mở lại `/workspaces/864f1df2-d0c9-4b74-8c3a-29ab63cccb97/requests` và mở form mới để tải lại query.
GET Workspace phải trả data.settings.timezone=Asia/Ho_Chi_Minh từ cột chuẩn, dù JSON DB cũ vẫn null.
Tại ngày test 2026-10-14, Campaign 2026-10-14..2026-11-07 có khoảng chọn hợp lệ nếu trạng thái/deployment
và quyền không đổi. Nếu form vẫn đang mở từ phiên cũ, đóng/mở lại hoặc bấm Thử lại.
UI account thật/HTTP smoke chưa được tự chạy; không dùng session/token của người dùng.

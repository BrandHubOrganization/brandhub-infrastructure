# Test Specification — FR 3.10.4: Content Moderation Queue

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.4` |
| **Function Name** | Content Moderation Queue |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `ContentModerationService.decide()` (49 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/ContentModerationServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Allow Admin to approve (note >= 10 chars) or block (recording strike + returning post to DRAFT) a pending moderation item |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `Decision.APPROVE, note='Verified safe content'` | 200 OK - Decision.APPROVE sets review status='APPROVED', increments row_version, notifies author | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `Decision.BLOCK, strikeLevel=YELLOW, category='CONTENT_POLICY', note='Profanity'` | 200 OK - Decision.BLOCK sets status='BLOCKED', records strike via AdminAccountService.record | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (FLAGGED_AUTHOR)`, `request` = `Decision.APPROVE, note='Verified safe content'` | 200 OK - Decision.BLOCK returns PENDING_APPROVAL post in Mongo back to DRAFT for editing | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (FLAGGED_AUTHOR)`, `request` = `Decision.BLOCK, strikeLevel=YELLOW, category='CONTENT_POLICY', note='Profanity'` | 200 OK - list() returns AdminModerationItem.Page with pending and today reviewed counts | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Immutable snapshot of reviewed version is stored in Mongo post_versions collection | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `list(status='PENDING', source='COMPLIANCE', page=1, size=20)` | 200 OK - detail() returns AdminModerationItem with immutable Mongo post_versions snapshot | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Immutable snapshot of reviewed version is stored in Mongo post_versions collection | `id` = `PENDING review UUID (FLAGGED_AUTHOR)`, `request` = `list(status='PENDING', source='COMPLIANCE', page=1, size=20)` | 200 OK - eligibility() returns ALLOWED/APPROVED or holds FLAGGED author's unreviewed post | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `Decision.APPROVE, note='Verified safe content'` | 200 OK - AdminAudit records CONTENT_MODERATION UPDATE and AdminEmailOutbox queues author email | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `Decision.BLOCK, strikeLevel=YELLOW, category='CONTENT_POLICY', note='Profanity'` | 200 OK - flag() reuses existing review item idempotently on duplicate (postId, contentVersion) | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Decision note is at exact minimum length boundary (10 chars for APPROVE, 3 chars for BLOCK) | `id` = `PENDING review UUID (boundary note)`, `request` = `APPROVE with exact 10-char note / BLOCK with 3-char note` | 200 OK - APPROVE with exact 10-character note accepted at minimum boundary | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Decision note is at exact minimum length boundary (10 chars for APPROVE, 3 chars for BLOCK) | `id` = `PENDING review UUID (boundary note)`, `request` = `APPROVE with exact 10-char note / BLOCK with 3-char note` | 200 OK - BLOCK with exact 3-character note and default category='CONTENT_POLICY' accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `list(status='PENDING', source='COMPLIANCE', page=1, size=20)` | 200 OK - Operation ID = review ID prevents duplicate strike on retried BLOCK | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Review item is not found, already decided, rowVersion mismatches, or post version changed | `id` = `non-existent review UUID`, `request` = `Decision.APPROVE, note='Verified safe content'` | MODERATION_NOT_FOUND - 404 Moderation review ID or flagged post not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Review item is not found, already decided, rowVersion mismatches, or post version changed | `id` = `already decided or stale-version UUID`, `request` = `Decision.APPROVE, note='Verified safe content'` | ADMIN_STATE_CONFLICT - 409 Review is no longer PENDING, rowVersion stale, or post version changed | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller does not have ADMIN system role | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `Decision.APPROVE, note='Verified safe content'` | FORBIDDEN - 403 Caller does not have ADMIN system role | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `non-existent review UUID`, `request` = `APPROVE with <10-char note` | MODERATION_NOTE_TOO_SHORT - 400 APPROVE decision note must be at least 10 characters | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `already decided or stale-version UUID`, `request` = `BLOCK without strikeLevel or <3-char note` | VALIDATION_ERROR - 400 BLOCK decision requires strikeLevel and note >= 3 characters | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.4`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — 3-10-4-content-moderation-queue

Các kỳ vọng chi tiết: [spec](spec.md), [Report3 spec](report3_spec.md) và mục 3 của [plan kỹ thuật](../plan.md).

- [x] BR-64 phiên bản bất biến: snapshot Mongo `post_versions` khóa theo `postId:version`, PostgreSQL lưu SHA-256 trùng khớp; sửa bài tăng `content_version`.
- [x] FLAGGED gửi duyệt → vào hàng đợi đúng một lần; tác giả ACTIVE không vào.
- [x] Bài đã lên lịch của tác giả bị FLAGGED: `/eligibility` giữ lại (PENDING_REVIEW) và tạo mục chờ.
- [x] APPROVE ghi chú < 10 ký tự → MSG80; APPROVE không tự đăng, chỉ cho phép phiên bản đó.
- [x] BLOCK: ghi đúng 1 thẻ (operationId = id mục), bài về DRAFT, email tác giả, `/eligibility` trả BLOCKED; sửa → phiên bản mới vào hàng đợi riêng.
- [x] Quyết định trên phiên bản đã đổi, mục đã xử lý hoặc rowVersion cũ → 409; cờ nội bộ cho phiên bản cũ → 409.
- [x] DEACTIVATED → AUTHOR_RESTRICTED; sai phiên bản → VERSION_MISMATCH; bài không tồn tại → POST_NOT_FOUND.
- [x] Chưa đăng nhập 401; USER 403; endpoint nội bộ không có/sai khóa → 401.
- [x] VI/EN và light/dark; 390px không tràn ngang.

## Kết quả

- `ContentModerationDatabaseTest` 5/5 (PostgreSQL 17 test DB + Mongo local DB `brandhub_moderation_test`); `AdminSecurityTest` 13/13; `PostServiceImplTest` pass sau khi thêm mock và test phiên bản.
- Full Business suite: 381 test, 0 failure, 11 error baseline (WorkspaceController/WorkspaceTemplate thiếu mock `RequireRoleAspect`, có từ upstream).
- Playwright `tests/e2e/admin/*` 33/33 pass (gồm `moderation.spec.ts` 4/4). 6 test `tests/e2e/auth/{login,register,google-oauth}` lỗi giống hệt trên `develop` gốc (UI đã đổi sau khi viết test), không do thay đổi này.
- Smoke thật: 18 bài demo Mongo local; giả lập publisher gọi `/eligibility` → 12 bài của tác giả FLAGGED bị giữ; giả lập kiểm tra tự động gọi `/flags` → 3 mục; duyệt 1, chặn 1 (thẻ Cam) qua UI; 2 email, audit đủ.

## Hợp đồng tích hợp

```
POST /api/v1/internal/moderation/flags            (Tuấn — FR 3.6.33/3.6.34)
Header X-Internal-Service-Key: ${INTERNAL_SERVICE_KEY}
{ "postId": "...", "contentVersion": 3, "source": "COMPLIANCE|COPYRIGHT", "reason": "..." }
→ 200 { "data": { "moderationId": "..." } }   409 nếu contentVersion không còn là bản hiện tại

POST /api/v1/internal/moderation/eligibility?postId=...&contentVersion=3   (Phước — trước dispatch)
→ 200 { "data": { "allowed": false, "code": "PENDING_REVIEW|BLOCKED|VERSION_MISMATCH|AUTHOR_RESTRICTED|POST_NOT_FOUND|APPROVED|ALLOWED", "reviewId": "..." } }
Chỉ đăng khi allowed=true; lỗi mạng/không xác minh được → không đăng (fail closed).
```

Giới hạn: hàng đợi chỉ có dữ liệu thật khi Tuấn/Phước nối hai endpoint; `PublishJobMessage` hiện chưa mang `contentVersion` nên Phước cần bổ sung.

## Local schema recovery — 2026-10-14

Kịch bản trước khi thực hiện:

- Backup đọc được trước khi áp dụng SQL; đúng DB `brandhub`, schema `public`.
- Migration lần đầu và chạy lại thành công, không xóa/sửa dữ liệu cũ.
- Đủ bảng, khóa chính, unique post/version, foreign keys, CHECK và hai index queue/author.
- Query danh sách PENDING/APPROVED/BLOCKED và bộ đếm thực thi thành công, trả rỗng/0 trên bảng mới.
- Định nghĩa bảng trong init khớp migration hiện có, không cần bổ sung lần nữa.
- AdminSecurityTest giữ nguyên kiểm tra 401/403/quyền Admin. Không coi test controller mock là live authenticated smoke.

Kết quả thực tế:

- Backup full PostgreSQL custom-format, kiểm tra `pg_restore --list` thành công. File ngoài Git: `D:/FPT/FA26/SEP490/.local-backups/admin-moderation-20261014/brandhub-before-moderation.dump` (552852 bytes).
- Chạy migration hiện có trên `brandhub/public` thành công, chạy lại thành công. Có 11 constraints và 4 indexes tổng cộng (2 index tường minh cùng index PK/unique).
- Trích đúng SQL SELECT của ContentModerationService và thực thi read-only với cả PENDING/APPROVED/BLOCKED: thành công, mỗi trạng thái 0 dòng; tổng/pending/today đều 0. Không seed hoặc tạo quyết định giả.
- Định nghĩa bảng/index/comment trong init khớp chính xác migration sau chuẩn hóa CRLF, không sửa init hoặc migration cũ.
- `mvn.cmd -q -Dtest=AdminSecurityTest test`: 15 tests, 0 failures/errors/skips. Controller/security dùng mocks; không coi đây là smoke API có phiên Admin thật.
- Chỉ cần tải lại `/admin?view=moderation` hoặc bấm tải lại danh sách. Không cần restart vì chỉ bổ sung schema vào PostgreSQL hiện đang dùng.
- Không thay đổi code Web/Business/Gateway, Mongo, Dashboard hoặc logout trong lần sửa riêng này. Giữ nguyên các thay đổi local từ công việc trước; không commit/push. Chưa xác minh thao tác duyệt/chặn trên dữ liệu thật hoặc Mongo Atlas.

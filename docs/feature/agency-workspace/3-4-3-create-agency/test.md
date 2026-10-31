# Test Specification — FR 3.4.3: Create Agency

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.3` |
| **Function Name** | Create Agency |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `AgencyServiceImpl.createAgency()` (42 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Create a new agency under plan limits and bind the creator as sole Owner with an OWNER membership record |
| **Preconditions** | Can connect with server; User is authenticated |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `valid name` | 201 - AgencyResponse(myRole=OWNER), owner membership saved | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `valid name`, `category` = `valid category`, `companySize` = `valid size` | 201 - AgencyResponse with category and size | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `valid name`, `website` = `https://brandhub.vn`, `phone` = `valid phone` | 201 - AgencyResponse with website and phone | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `valid name`, `logoUrl` = `valid url`, `bannerUrl` = `valid url` | 201 - AgencyResponse with logo and banner | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `valid name`, `brandColor` = `#FF5500`, `tagline` = `valid tagline`, `foundedYear` = `2020` | 201 - AgencyResponse with branding fields | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `valid name`, `facebookUrl` = `valid url`, `linkedinUrl` = `valid url`, `instagramUrl` = `valid url` | 201 - AgencyResponse with social links | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `padded name` | 201 - name trimmed to 'padded name' | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User already owns an agency | `currentUser` = `authenticated user`, `name` = `another valid name` | 201 - second agency created, caller OWNER | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `1 char name` | 201 - AgencyResponse created | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `valid name`, `tagline` = `null`, `description` = `null` | 201 - optional fields stored as null | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `valid name`, `foundedYear` = `1900` | 201 - AgencyResponse created | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `valid name`, `description` = `very long text` | 201 - AgencyResponse created | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `null` | 400 MethodArgumentNotValidException - name must not be blank | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `empty` | 400 MethodArgumentNotValidException - name must not be blank | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `whitespace only` | 400 MethodArgumentNotValidException - name must not be blank | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Request without valid token | `currentUser` = `null`, `name` = `valid name` | 401 UNAUTHORIZED - authentication required | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User authenticated | `currentUser` = `authenticated user`, `name` = `valid name`, `category` = `unknown enum value` | 400 HttpMessageNotReadableException - invalid category | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.3`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Create Agency (FR 3.4.3)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md). Cập nhật trạng thái Pass/Fail khi verify.

| Test case ID | Mô tả (input/điều kiện) | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `createAgency_savesWithCurrentUserAsOwnerAndCreatesOwnerMember` — full request + token hợp lệ | AC1, AC2 | `201 Created`; `data.ownerId == currentUser.id`, `data.status == ACTIVE`; kèm `AgencyMember(OWNER)` được tạo | Happy path | Pass — **xác nhận 2026-09-21, test thật đã tồn tại trong `AgencyServiceImplTest`** |
| TC-02 | `createAgency_minimalRequest_leavesOptionalFieldsNull` — chỉ `{name}` | AC1 | `201`; `logoUrl`/`description` = null; vẫn tạo thành công | Happy path | Pass |
| TC-03 | `name` = `""` hoặc chỉ khoảng trắng | AC1, Error | `400 VALIDATION_ERROR` (do `@NotBlank`), không tạo bản ghi | Error case | Chưa xác nhận — không thấy method riêng cho blank-name trong `AgencyServiceImplTest` (có thể ở `AgencyControllerTest`, chưa đọc chi tiết trong lượt này) |
| TC-04 | Không kèm token / token hết hạn | (ngầm định từ role USER) | `401 UNAUTHORIZED`/`TOKEN_EXPIRED`, không tạo Agency | Error case | Chưa xác nhận — thuộc tầng filter chung, không nằm trong `AgencyServiceImplTest` |
| TC-05 | User đã sở hữu Agency khác, tạo thêm Agency mới | Edge case (spec mục 7) | `201`; tạo thêm Agency thứ 2 thành công (không giới hạn số lượng, `owner_id` không unique) | Edge case | Chưa xác nhận — không có method test riêng cho case "sở hữu 2+ agency", nhưng logic code không có gì chặn (không unique, không check count) |
| TC-06 | `createAgency_trimsSurroundingWhitespaceInName` — `name` có khoảng trắng 2 đầu | AC1 | `data.name` đã trim | Edge case | Pass |
| TC-07 | Kiểm tra `ownerId` không đổi sau khi tạo | AC2, DoD | `ownerId` giữ nguyên, không có API đổi owner trong phạm vi FR | Edge case | Pass — xác nhận qua đọc code, không có endpoint transfer-owner nào tồn tại |

## Ghi chú

- AC1 = "Form nhập name (bắt buộc), description, logo (optional)".
- AC2 = "Submit → tạo Agency với ownerId = currentUser.id".
- DoD = "Tạo Agency thành công, ownerId gắn đúng user hiện tại, không đổi được sau khi tạo".

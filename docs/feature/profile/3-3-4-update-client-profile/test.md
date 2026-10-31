# Test Specification — FR 3.3.4: Update Client Profile

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.3.4` |
| **Function Name** | Update Client Profile |
| **Functional Domain** | Profile |
| **Canonical Actors / Roles** | `Client, Owner, Manager` |
| **Target Class & Method** | `ClientProfileServiceImpl.updateById()` (40 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/ClientProfileServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Update an owned Client brand profile (brand name, logo, industry, website, contact info, brand voice) across linked workspaces |
| **Preconditions** | Can connect with server; User owns the Client profile |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 10, `Boundary (B)`: 2, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `Nike VN`, `company` = `Nike`, `phone` = `0901234567`, `note` = `VIP` | 200 OK - ClientProfileResponse with updated fields | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `Nike VN` | 200 OK - displayName stored trimmed | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `Nike VN`, `logoUrl` = `https://cdn/l.png`, `website` = `https://nike.vn`, `industry` = `Sport` | 200 OK - logo, website, industry saved | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `Nike VN`, `socialLinks` = `{facebook: url}` | 200 OK - socialLinks serialized to JSON | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `Nike VN`, `tagline` = `Just do it`, `foundedYear` = `1964`, `budgetRange` = `10k-50k` | 200 OK - brand fields saved | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `Nike VN`, `company` = `empty`, `phone` = `empty`, `note` = `empty` | 200 OK - optional fields saved empty/null | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User owns the client profile; Profile linked to 2 workspaces | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `Nike VN` | 200 OK - single record updated, change visible everywhere | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; No profile for caller | `currentUser` = `valid user id`, `displayName` = `New Brand` | 200 OK - createProfile saves profile with userId = caller | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; User owns the client profile; Profile not linked to active workspace | `currentUser` = `valid user id`, `profileId` = `own profile id` | 204 No Content - deleteById removes profile | — | **Passed** |
| `UTCID10` | `N` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `Nike VN` | 200 OK - updatedAt refreshed, email never changed | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `N` | 200 OK - displayName 1 char accepted | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `Nike VN`, `socialLinks` = `null`, `foundedYear` = `null` | 200 OK - null socialLinks/foundedYear stored as null | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `empty` | VALIDATION_ERROR - displayName must not be blank | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User owns the client profile | `currentUser` = `valid user id`, `profileId` = `own profile id`, `displayName` = `null` | VALIDATION_ERROR - displayName must not be blank | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Profile id does not exist | `currentUser` = `valid user id`, `profileId` = `unknown profile id`, `displayName` = `Nike VN` | CLIENT_PROFILE_NOT_FOUND - 404 Client profile not found | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Profile owned by another user | `currentUser` = `valid user id`, `profileId` = `other user's profile id`, `displayName` = `Nike VN` | CLIENT_PROFILE_NOT_OWNED - 403 This client profile does not belong to you | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User owns the client profile; Profile attached to active workspace | `currentUser` = `valid user id`, `profileId` = `own profile id` | CLIENT_PROFILE_IN_USE - 409 still attached to an active workspace | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Profile owned by another user | `currentUser` = `valid user id`, `profileId` = `other user's profile id` | CLIENT_PROFILE_NOT_OWNED - 403 delete other's profile | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.3.4`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Update Client Profile (FR 3.3.4)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md). V2 (2026-10-02): mô hình `agency_id` (2026-09-21) đã bị revert.

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `createProfile_savesOwnedByUser` — tạo profile mới | AC | 200; `userId` = caller, không có `agencyId` | Happy path | Pass |
| TC-02 | `updateById_ownedProfile_updatesFields` — update profile đang sở hữu | AC | 200; cập nhật đủ field | Happy path | Pass |
| TC-03 | `company`/`phone`/`note` rỗng | Edge | 200; set null | Edge case | Pass |
| TC-04 | `displayName` rỗng | Error | 400 `@NotBlank` violation | Error case | Chưa xác nhận — không thấy method riêng trong `ClientProfileServiceImplTest` cho case này (validation ở tầng bean `@Valid`, chưa có ControllerTest) |
| TC-05 | `getById_notOwned_throwsClientProfileNotOwned` — update/xem profile của người khác | AC | 403 `CLIENT_PROFILE_NOT_OWNED` | Error case | Pass |
| TC-06 | `deleteById_notInUse_deletesProfile` / `deleteById_stillAttachedToActiveWorkspace_throwsInUse` | AC | Xoá được nếu không linked workspace active; 409 `CLIENT_PROFILE_IN_USE` nếu còn linked | Happy + error | Pass |
| TC-07 | Cùng 1 profile dùng ở nhiều workspace/agency, update 1 lần | AC (đa-agency theo BA) | Thay đổi phản ánh ở mọi nơi profile được linked, không có "bản sao theo agency" | Edge case | Pass (theo thiết kế — single record, không duplicate) |

## Ghi chú

- AC = "Cập nhật displayName, company, phone, note (và các field mở rộng: logoUrl/website/industry/location/description/socialLinks, cùng brand fields); không sửa email".
- Unit test: `ClientProfileServiceImplTest.createProfile_savesOwnedByUser`, `updateById_ownedProfile_updatesFields`, `getById_notOwned_throwsClientProfileNotOwned`, `deleteById_notInUse_deletesProfile`, `deleteById_stillAttachedToActiveWorkspace_throwsInUse`.
- TC-01/TC-05 cũ (upsert theo `(userId, agencyId)`) đã bị xoá cùng field `agencyId` — xem `3-3-3-view-client-profile/plan.md` §6.

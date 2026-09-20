# Test — Update Client Profile (FR 3.3.4)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Upsert khi chưa có hồ sơ | AC | 200; tạo mới với userId hiện tại | Happy path | Pass |
| TC-02 | Upsert khi đã có hồ sơ | AC | 200; cập nhật displayName/company/phone/note | Happy path | Pass |
| TC-03 | `company`/`phone`/`note` rỗng | Edge | 200; set null | Edge case | Pass |
| TC-04 | `displayName` rỗng | Error | 400 `@NotBlank` violation | Error case | Pass |

## Ghi chú

- AC = "Cập nhật displayName, company, phone, note; không sửa email".
- Unit test: `ClientProfileServiceImplTest.upsertMyProfile_createsWhenMissing`, `upsertMyProfile_updatesExisting`.

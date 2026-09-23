# Test — Deactivate Account

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Deactivate password đúng | AC "set status=DEACTIVATED" | 200, soft-delete (không xóa cứng) | Chưa test |
| TC-02 | Password sai | Error "INVALID_PASSWORD" | 400 `WRONG_CURRENT_PASSWORD` | Chưa test |
| TC-03 | Owner Agency active | Edge "Owner duy nhất Agency" | 409 `AGENCY_OWNERSHIP_ACTIVE`, không deactivate | Chưa test |
| TC-04 | Login sau deactivate | AC "không login được" | 403 `ACCOUNT_DEACTIVATED` | Chưa test |
| TC-05 | Dữ liệu liên quan còn trong DB | AC "giữ dữ liệu" | User/Agency/Workspace record vẫn tồn tại | Chưa test |
| TC-06 | Agency chỉ còn SOFT_DELETED/INACTIVE | Edge "không còn agency active" | 200, cho deactivate | Chưa test |
| TC-07 | Deactivate lại user đã deactivated | Edge "idempotent" | 400 `WRONG_CURRENT_PASSWORD` (re-match password) | Chưa test |

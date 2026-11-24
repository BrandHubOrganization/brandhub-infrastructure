# Sequence Flow — Disconnect Account

> Supplements `spec.md` (FR 3.8.2). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Client** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `SocialAccountsPage (UI)`.
- **System** — `SocialAccountController` / `SocialAccountServiceImpl`.

---

## Flow A — Luồng thực thi chính: Disconnect Account

1. client -> socialaccountspageui: `Click "Disconnect" on Social Account card`
2. socialaccountspageui -> socialaccountspageui: `Update account status to DISCONNECTED in UI state`
3. socialaccountspageui -> socialaccountspageui: `Open Disconnect Confirmation Dialog`
4. client -> socialaccountspageui: `3: Confirm disconnect`
5. socialaccountspageui -> socialaccountcontrol: `DELETE /api/v1/social-accounts/{id}?workspaceId={wsId}`
6. socialaccountcontrol -> socialaccountservice: `disconnectAccount(accountId, workspaceId)`
7. socialaccountservice -> socialaccountmongore: `findById(accountId)`
8. socialaccountmongore --> socialaccountservice: `return Optional.empty()`
9. socialaccountspageui --> client: `Show toast warning or refresh list`
10. socialaccountservice --> socialaccountcontrol: `return void`
11. socialaccountcontrol --> socialaccountspageui: `9: return 200 OK (ApiResponse with null data)`
12. socialaccountmongore --> socialaccountservice: `return existingDoc`
13. socialaccountservice -> socialoauthcontrolle: `POST /api/v1/social/tokens/revoke (platform, encryptedAccessToken)`
14. socialoauthcontrolle -> metaoauthserviceimpl: `revokeToken(encryptedAccessToken)`
15. metaoauthserviceimpl -> socialplatformapi: `DELETE /me/permissions (revoke app access)`
16. socialplatformapi --> metaoauthserviceimpl: `return 200 OK (Revoked)`
17. metaoauthserviceimpl --> socialoauthcontrolle: `return success`
18. socialoauthcontrolle --> socialaccountservice: `return 200 OK`
19. socialaccountservice -> socialaccountdocumen: `setStatus('DISCONNECTED'), setIsActive(false), setEncryptedToken(null)`
20. socialaccountdocumen --> socialaccountservice: `return updatedDoc`
21. socialaccountservice -> socialaccountmongore: `save(updatedDoc)`
22. socialaccountmongore --> socialaccountservice: `return savedDoc`
23. socialaccountservice --> socialaccountcontrol: `return void`
24. socialaccountspageui --> client: `21: Show success toast notification`
25. socialaccountcontrol --> socialaccountspageui: `19: return 200 OK (ApiResponse { success: true })`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

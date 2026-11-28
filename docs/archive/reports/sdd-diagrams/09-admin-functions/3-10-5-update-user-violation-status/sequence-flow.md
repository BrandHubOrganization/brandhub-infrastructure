# Sequence Flow — User Management (Verify/Deactive)

> Supplements `spec.md` (FR 3.10.5). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `AdminStrikeDialog (UI)`.
- **System** — `AdminController` / `AdminAccountService`.

---

## Flow A — Luồng thực thi chính: User Management (Verify/Deactive)

1. systemadministrator -> adminstrikedialogui: `Add/remove a strike or unflag an account`
2. adminstrikedialogui -> admincontroller: `POST /api/v1/admin/users/{id}/violations OR PATCH /users/{id}/status`
3. admincontroller -> adminaccountservice: `record(actor, target, request) / unflag(actor, target, reason)`
4. adminaccountservice -> usersystemrolereposi: `findByUserId(actor)`
5. usersystemrolereposi --> adminaccountservice: `Optional<UserSystemRole>`
6. adminaccountservice --> admincontroller: `BusinessException(FORBIDDEN)`
7. admincontroller --> adminstrikedialogui: `403 Forbidden`
8. adminstrikedialogui --> systemadministrator: `Show access denied`
9. adminaccountservice -> userrepository: `lockById(target)`
10. userrepository --> adminaccountservice: `Optional<User>`
11. adminaccountservice -> usersystemrolereposi: `findByUserId(target)`
12. usersystemrolereposi --> adminaccountservice: `Target system role`
13. adminaccountservice -> userstrikerepository: `findByUserIdAndRemovedAtIsNullAndExpiresAtAfter (target, now)`
14. userstrikerepository --> adminaccountservice: `Live strikes`
15. adminaccountservice -> adminaccountservice: `Validate protected account, reason, action and strike eligibility`
16. adminaccountservice --> admincontroller: `BusinessException(errorCode)`
17. admincontroller --> adminstrikedialogui: `400 / 403 / 404 / 409 — request rejected`
18. adminstrikedialogui --> systemadministrator: `Show the reason; keep the form`
19. adminaccountservice -> useruserstrike: `Read account status and existing strike fields, if any`
20. useruserstrike --> adminaccountservice: `Account/strike data`
21. adminaccountservice -> adminaccountservice: `Apply ADD/REMOVE/UNFLAG policy; skip already-applied action`
22. adminaccountservice -> userstrikerepository: `saveAll(live) / save(strike)`
23. userstrikerepository --> adminaccountservice: `Saved strikes`
24. adminaccountservice -> userrepository: `save(user)`
25. userrepository --> adminaccountservice: `Saved User`
26. adminaccountservice -> sanctionreviewreposi: `findByUserIdAndStatus(target, "PENDING"); save(review) if threshold changes`
27. sanctionreviewreposi --> adminaccountservice: `Current/saved sanction review`
28. adminaccountservice --> admincontroller: `Operation completed (void)`
29. admincontroller --> adminstrikedialogui: `200 OK — changes saved`
30. adminstrikedialogui --> systemadministrator: `Refresh account status, counters and history`
31. admincontroller -> apiresponsevoid: `ok(null, requestId)`
32. apiresponsevoid --> admincontroller: `ApiResponse<Void>`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

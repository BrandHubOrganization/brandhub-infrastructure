# Sequence Flow — Generate Ambassador

> Supplements `spec.md` (FR 3.7.3). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **OWNER / MANAGER / CREATOR** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Generate Ambassador Page`.
- **System** — `AiAssetController` / `AiAssetService`.

---

## Flow A — Luồng thực thi chính: Generate Ambassador

1. ownermanagercreator -> webdashboard: `Generate ambassador from description/style`
2. aiassetservice -> aiassetservice: `Validate input, AI rights and available credits`
3. webdashboard -> aiassetcontroller: `POST /api/v1/ai/generate-ambassador`
4. aiassetcontroller -> aiassetservice: `generateAmbassador(user, command)`
5. aiassetservice -> workspacerepository: `Load workspace access`
6. workspacerepository --> aiassetservice: `Workspace`
7. aiassetservice -> aicreditaccountrepos: `Load credit account and limit`
8. aicreditaccountrepos --> aiassetservice: `AiCreditAccount`
9. aiassetservice --> aiassetcontroller: `400 Bad Request / 402 Payment Required / 403 Forbidden`
10. aiassetcontroller --> webdashboard: `400 Bad Request / 402 Payment Required / 403 Forbidden`
11. webdashboard --> ownermanagercreator: `Display validation or credit error`
12. aiassetservice -> aicreditaccountrepos: `Reserve generation credits`
13. aicreditaccountrepos --> aiassetservice: `reservationOutcome`
14. aiassetservice -> aiservices3: `Generate and store image in S3`
15. aiservices3 --> aiassetservice: `generationOutcome`
16. aiassetservice -> aicreditaccountrepos: `Release reserved credits`
17. aicreditaccountrepos --> aiassetservice: `releaseOutcome`
18. aiassetservice --> aiassetcontroller: `500 Internal Server Error`
19. aiassetcontroller --> webdashboard: `500 Internal Server Error`
20. webdashboard --> ownermanagercreator: `Display generation failed; Retry`
21. aiassetservice -> generatedassetreposi: `Save READY ambassador asset`
22. generatedassetreposi --> aiassetservice: `assetOutcome`
23. aiassetservice -> aicreditaccountrepos: `Settle generation credits`
24. aicreditaccountrepos --> aiassetservice: `settlementOutcome`
25. aiassetcontroller --> webdashboard: `201 Created`
26. aiassetservice --> aiassetcontroller: `201 Created`
27. webdashboard --> ownermanagercreator: `Display ambassador preview and credit usage`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

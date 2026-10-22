# Sequence Flow — Connect Social Account

> Supplements `spec.md` (FR 3.8.1). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `SocialAccountsPage (UI)`.
- **System** — `SocialOAuthController` / `MetaOAuthService`.

---

## Flow A — Luồng thực thi chính: Connect Social Account

1. user -> socialaccountspageui: `clicks "Connect Facebook / Instagram"`
2. socialaccountspageui -> socialoauthcontrolle: `GET /api/v1/oauth/social/connect?platform=META`
3. socialoauthcontrolle -> metaoauthservice: `buildAuthorizationUrl(platform)`
4. metaoauthservice --> socialoauthcontrolle: `authUrl`
5. socialoauthcontrolle --> socialaccountspageui: `302 Redirect to authUrl`
6. socialaccountspageui --> user: `Meta OAuth Consent Screen`
7. user -> metagraphapi: `authorizes permissions`
8. metagraphapi --> socialaccountspageui: `callback with authCode & state`
9. socialaccountspageui -> socialoauthcontrolle: `GET /api/v1/oauth/social/callback?code=authCode&state=...`
10. socialoauthcontrolle -> metaoauthservice: `exchangeToken(authCode)`
11. metaoauthservice -> metagraphapi: `exchange short-lived token`
12. metagraphapi --> metaoauthservice: `long-lived token (60 days)`
13. metaoauthservice -> metagraphapi: `fetch linked Pages & Instagram accounts`
14. metagraphapi --> metaoauthservice: `accountInfo`
15. metaoauthservice --> socialoauthcontrolle: `302 Redirect with error status`
16. socialoauthcontrolle --> socialaccountspageui: `error redirect`
17. socialaccountspageui --> user: `Show error "Connection cancelled or failed"`
18. metaoauthservice -> socialaccountservice: `syncSocialAccount(userId, accountInfo, encryptedToken)`
19. socialaccountservice --> metaoauthservice: `savedAccount`
20. metaoauthservice --> socialoauthcontrolle: `302 Redirect with success status`
21. socialoauthcontrolle --> socialaccountspageui: `redirect to SocialAccountsPage`
22. socialaccountspageui --> user: `Show Facebook/Instagram channel card as connected`
23. user -> socialaccountspageui: `clicks "Connect TikTok"`
24. socialaccountspageui -> socialoauthcontrolle: `GET /api/v1/oauth/social/connect?platform=TIKTOK`
25. socialoauthcontrolle -> tiktokoauthservice: `buildAuthorizationUrl()`
26. tiktokoauthservice --> socialoauthcontrolle: `authUrl (with PKCE code_challenge)`
27. socialoauthcontrolle --> socialaccountspageui: `302 Redirect to authUrl`
28. socialaccountspageui --> user: `TikTok Authorization Screen`
29. user -> tiktokopenapi: `authorizes permissions`
30. tiktokopenapi --> socialaccountspageui: `callback with authCode & state`
31. socialaccountspageui -> socialoauthcontrolle: `GET /api/v1/oauth/social/callback?code=authCode&state=...`
32. socialoauthcontrolle -> tiktokoauthservice: `exchangeToken(authCode, codeVerifier)`
33. tiktokoauthservice -> tiktokopenapi: `exchange token with code verifier`
34. tiktokopenapi --> tiktokoauthservice: `accessToken + refreshToken`
35. tiktokoauthservice -> tiktokopenapi: `fetch TikTok profile info`
36. tiktokopenapi --> tiktokoauthservice: `userInfo(displayName, avatarUrl)`
37. tiktokoauthservice --> socialoauthcontrolle: `302 Redirect with error status`
38. socialoauthcontrolle --> socialaccountspageui: `error redirect`
39. socialaccountspageui --> user: `Show error "TikTok connection cancelled or failed"`
40. tiktokoauthservice -> socialaccountservice: `syncSocialAccount(userId, userInfo, encryptedToken)`
41. socialaccountservice --> tiktokoauthservice: `savedAccount`
42. tiktokoauthservice --> socialoauthcontrolle: `302 Redirect with success status`
43. socialoauthcontrolle --> socialaccountspageui: `redirect to SocialAccountsPage`
44. socialaccountspageui --> user: `Show TikTok channel card as connected`
45. user -> socialaccountspageui: `clicks "Connect Threads"`
46. socialaccountspageui -> socialoauthcontrolle: `GET /api/v1/oauth/social/connect?platform=THREADS`
47. socialoauthcontrolle -> threadsoauthservice: `buildAuthorizationUrl()`
48. threadsoauthservice --> socialoauthcontrolle: `authUrl`
49. socialoauthcontrolle --> socialaccountspageui: `302 Redirect to authUrl`
50. socialaccountspageui --> user: `Threads Authorization Screen`
51. user -> threadsapi: `authorizes permissions (threads_basic, threads_content_publish)`
52. threadsapi --> socialaccountspageui: `callback with code & state`
53. socialaccountspageui -> socialoauthcontrolle: `GET /api/v1/oauth/social/callback?code=...&state=...`
54. socialoauthcontrolle -> threadsoauthservice: `exchangeToken(authCode)`
55. threadsoauthservice -> threadsapi: `exchange short-lived token`
56. threadsapi --> threadsoauthservice: `short-lived token`
57. threadsoauthservice -> threadsapi: `exchange long-lived token (60 days)`
58. threadsapi --> threadsoauthservice: `long-lived token`
59. threadsoauthservice -> threadsapi: `fetch Threads user profile`
60. threadsapi --> threadsoauthservice: `userInfo(username, profilePictureUrl)`
61. threadsoauthservice --> socialoauthcontrolle: `302 Redirect with error status`
62. socialoauthcontrolle --> socialaccountspageui: `error redirect`
63. socialaccountspageui --> user: `Show error "Threads connection cancelled or failed"`
64. threadsoauthservice -> socialaccountservice: `syncSocialAccount(userId, userInfo, encryptedToken)`
65. socialaccountservice --> threadsoauthservice: `savedAccount`
66. threadsoauthservice --> socialoauthcontrolle: `302 Redirect with success status`
67. socialoauthcontrolle --> socialaccountspageui: `redirect to SocialAccountsPage`
68. socialaccountspageui --> user: `Show Threads channel card as connected`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

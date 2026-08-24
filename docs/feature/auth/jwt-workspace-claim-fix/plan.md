# Plan — Fix JWT thiếu claim workspaceId

## 1. AuthServiceImpl.java
Inject `WorkspaceMemberRepository` (đã có sẵn `findFirstByUserIdAndIsActiveTrue`,
không cần query mới). Thêm helper private:
```java
private String resolveActiveWorkspaceId(UUID userId) {
    return workspaceMemberRepository.findFirstByUserIdAndIsActiveTrue(userId)
            .map(m -> m.getWorkspaceId().toString())
            .orElse(null);
}
```
Sửa 2 chỗ gọi `generateAccessToken(..., null)`:
- `login()` dòng 177: `String workspaceId = resolveActiveWorkspaceId(user.getId());`
  → `jwtUtil.generateAccessToken(user.getId().toString(), role, workspaceId)`.
- `refresh()` dòng 215: tương tự, dùng `user.getId()` đã resolve ở trên.

## 2. OAuthService.java
Inject `WorkspaceMemberRepository` vào constructor abstract class (thêm field
+ param constructor — 4 concrete class Google/GitHub/LinkedIn/Microsoft đều
gọi `super(...)`, cần update cả 4 call site).
Cùng helper `resolveActiveWorkspaceId`, áp dụng dòng 150.

## 3. Test
`AuthServiceLoginTest`/`AuthServiceRefreshTest` (đã có sẵn file, xem nội dung
trước khi thêm) — thêm case:
- `login_userHasWorkspace_tokenIncludesWorkspaceId`
- `login_userHasNoWorkspace_tokenWorkspaceIdIsNull`
- tương tự cho refresh.

Verify bằng decode JWT claim trong test (dùng `jwtUtil.parseToken` lại chính
access token vừa sinh, assert `claims.get("workspaceId")`).

## File Touch List
- `AuthServiceImpl.java`
- `OAuthService.java`
- `GoogleOAuthService.java`, `GitHubOAuthService.java`, `LinkedInOAuthService.java`, `MicrosoftOAuthService.java` (constructor param thêm)
- Test files tương ứng

## Rủi ro
- 4 constructor OAuth concrete phải sửa đồng bộ, dễ sót — grep `extends OAuthService` trước khi sửa xác nhận đủ 4 file.
- Không đổi hành vi hiện có nào khác ngoài claim workspaceId — giữ nguyên toàn bộ logic login/refresh/OAuth khác.

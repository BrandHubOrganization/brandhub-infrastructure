# Task — Fix JWT thiếu claim workspaceId

- [ ] 1. Grep `extends OAuthService` xác nhận đủ 4 concrete class.
- [ ] 2. `AuthServiceImpl.java`: inject `WorkspaceMemberRepository`, thêm
      helper `resolveActiveWorkspaceId`, sửa `login()` + `refresh()`.
- [ ] 3. `OAuthService.java`: inject `WorkspaceMemberRepository` vào
      constructor, thêm helper, sửa `handleCallback()` dòng 150.
- [ ] 4. Sửa 4 constructor call site (Google/GitHub/LinkedIn/Microsoft
      OAuthService) truyền thêm `WorkspaceMemberRepository`.
- [ ] 5. Đọc `AuthServiceLoginTest`/`AuthServiceRefreshTest` hiện có, thêm
      test case theo plan.md mục 3.
- [ ] 6. `mvn -o compile` xanh.
- [ ] 7. `mvn -o test` toàn bộ pass (không chỉ file vừa sửa).
- [ ] 8. Verify qua Chrome DevTools: login → decode JWT → PATCH settings
      không còn 403.

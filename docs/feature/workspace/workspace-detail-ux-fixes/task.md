# Task — Workspace Detail UX Fixes

## Backend
- [ ] 1. `ErrorCode.java`: thêm `INVITATION_ALREADY_PENDING`.
- [ ] 2. `WorkspaceInvitationRepository`: thêm
      `findByWorkspaceIdAndInvitedEmailAndStatusAndExpiresAtAfter`,
      `findByInvitedEmailAndStatus`.
- [ ] 3. Tạo `dto/response/InvitationResponse.java`.
- [ ] 4. Tạo `dto/request/DeclineInvitationRequest.java`.
- [ ] 5. `WorkspaceService.java`: thêm `listMyPendingInvitations`,
      `declineInvitation`.
- [ ] 6. `WorkspaceServiceImpl.java`:
    - [ ] 6a. `inviteMember`: thêm check PENDING trước khi tạo invitation
          mới, throw `INVITATION_ALREADY_PENDING` nếu có.
    - [ ] 6b. Implement `listMyPendingInvitations` (batch load, tránh N+1).
    - [ ] 6c. Implement `declineInvitation`.
- [ ] 7. `WorkspaceController.java`: thêm
      `GET /invitations/my-pending`, `POST /invitations/decline`.
- [ ] 8. Unit test 6 case theo plan.md mục 7.
- [ ] 9. `mvn -o compile` xanh, `mvn -o test` pass toàn bộ.

## Frontend
- [ ] 10. Đọc `Layout.tsx` xác nhận cách `workspaces`/`activeWorkspace`
       quản lý trước khi đổi props Navbar (tránh phá workspace switcher).
- [ ] 11. `WorkspaceSettingsPage.tsx`: xóa Input + state timezone, gửi tự
       động `Intl.DateTimeFormat().resolvedOptions().timeZone` lúc submit.
- [ ] 12. `types/workspace.ts`: thêm `WorkspaceInvitation` type.
- [ ] 13. `workspaceService.ts`: thêm `listMyPendingInvitations`,
       `declineInvitation`.
- [ ] 14. `Navbar.tsx`:
    - [ ] 14a. Thêm prop `workspaces: Workspace[]`.
    - [ ] 14b. `getBreadcrumbs()`: nhận diện segment UUID bằng regex, tra
          tên trong `workspaces` theo `useParams().id`, ẩn segment nếu
          chưa tra được tên (không hiện UUID thô).
    - [ ] 14c. Thêm `DropdownMenuItem` "Lời mời" trong Profile dropdown →
          `/invitations`.
- [ ] 15. `Layout.tsx`: truyền `workspaces` xuống `Navbar`.
- [ ] 16. Tạo `InvitationsPage.tsx`: list pending invitation, nút
       Accept/Decline.
- [ ] 17. `App.tsx`: thêm route `/invitations`.
- [ ] 18. i18n: thêm `invitations.*` (10 key), `nav.invitations` vào
       `vi.json` + `en.json`, key-parallel.
- [ ] 19. `npx tsc --noEmit` sạch.
- [ ] 20. `npx eslint` trên file đã sửa sạch.

## Verify
- [ ] 21. Restart business-service load endpoint mới.
- [ ] 22. Test theo `test.md` case 1-8 qua Chrome DevTools — cần 2 tài
       khoản test khác nhau (người mời + người được mời) để test Accept/
       Decline thật.

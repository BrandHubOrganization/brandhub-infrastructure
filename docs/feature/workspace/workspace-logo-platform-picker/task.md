# Task — Workspace Logo Upload + Platform Icon Picker

## Backend
- [ ] 1. `ErrorCode.java`: thêm `WORKSPACE_LOGO_INVALID_TYPE`, `WORKSPACE_LOGO_TOO_LARGE`.
- [ ] 2. Grep toàn repo chỗ gọi `deleteAvatar`/`uploadAvatar` trước khi đổi tên,
      liệt kê đủ caller.
- [ ] 3. `FileStorageService` (interface): thêm `uploadWorkspaceLogo`, rename
      `deleteAvatar` → `deleteFile` (update interface + impl + mọi caller từ
      task 2).
- [ ] 4. `S3FileStorageServiceImpl`: implement `uploadWorkspaceLogo` (copy
      logic `uploadAvatar`, đổi key prefix `image/workspace-logos/`).
- [ ] 5. `WorkspaceService` (interface): thêm `updateLogo(UUID, MultipartFile)`.
- [ ] 6. `WorkspaceServiceImpl`: implement `updateLogo` — validate type/size,
      xóa logo cũ nếu có, upload mới, save, map response.
- [ ] 7. `WorkspaceController`: thêm `POST /{workspaceId}/logo`
      `@RequireRole({OWNER, ACCOUNT})`.
- [ ] 8. Unit test `WorkspaceServiceImplTest`: `updateLogo_validFile_returnsUpdatedLogoUrl`,
      `updateLogo_invalidType_throwsBusinessException`,
      `updateLogo_tooLarge_throwsBusinessException`.
- [ ] 9. `mvn -o compile` xanh, `mvn -o test` pass (module business-service).

## Frontend
- [ ] 10. Đọc `Layout.tsx` xác nhận nguồn `role` hiện tại truyền cho trang con
       thế nào (route context / outlet / hook) — không đoán.
- [ ] 11. `workspaceService.ts`: thêm `uploadLogo(workspaceId, file)`.
- [ ] 12. `WorkspaceSettingsPage.tsx`:
    - [ ] 12a. Thêm state `logoUrl`, `uploadingLogo`, `fileInputRef`, đổi
          `defaultPlatforms` sang `string[]`.
    - [ ] 12b. Load `logoUrl` từ `data.data.logoUrl` trong `getById`.
    - [ ] 12c. Thêm avatar/logo block (ảnh tròn + placeholder + input file ẩn
          + nút upload), handler `handleLogoChange` validate type/size client
          trước khi gọi API.
    - [ ] 12d. Xóa `Input` text platform, thay bằng 4 icon toggle
          (Facebook/Instagram/TikTok-equivalent/LinkedIn) từ `lucide-react`,
          click toggle in/out mảng `defaultPlatforms`.
    - [ ] 12e. Ẩn nút upload logo nếu role hiện tại không phải OWNER/ACCOUNT.
    - [ ] 12f. `handleSubmit` gửi `defaultPlatforms` (mảng) thẳng, bỏ
          `.split(",")`.
- [ ] 13. `vi.json` + `en.json`: thêm 5 key `workspace.settings.logo*` (xem
       spec.md mục i18n), key-parallel.
- [ ] 14. `npx tsc --noEmit` sạch.
- [ ] 15. `npx eslint src/pages/workspaces/WorkspaceSettingsPage.tsx
       src/services/workspaceService.ts` sạch.

## Verify
- [ ] 16. Chạy business-service + web-dashboard local, mở
       `/workspace/:id/settings`, test theo `test.md`.
- [ ] 17. Nếu S3 local thiếu credentials (đã biết từ trước) → xác nhận lỗi
       500 đúng như dự đoán, KHÔNG cố sửa AWS config, ghi rõ giới hạn trong
       báo cáo cuối cho user.
- [ ] 18. Test đổi theme dark/light, đổi ngôn ngữ vi/en trên trang này.

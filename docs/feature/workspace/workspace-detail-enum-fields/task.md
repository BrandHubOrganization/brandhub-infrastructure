# Task — Workspace Detail Fields → Enum Toggle

## Backend
- [ ] 1. Đọc `GlobalExceptionHandler.java` xác nhận đã bắt
      `HttpMessageNotReadableException` chưa (câu trả lời quyết định task 8
      có cần làm không).
- [ ] 2. Tạo `model/enums/WorkspaceIndustry.java` (10 giá trị).
- [ ] 3. Tạo `model/enums/ReportFrequency.java` (2 giá trị: WEEKLY, MONTHLY).
- [ ] 4. `WorkspaceSettings.java`: thêm field `industry`, đổi
      `reportFrequency` sang enum type.
- [ ] 5. `CreateWorkspaceRequest.java`: đổi `industry` sang
      `WorkspaceIndustry`.
- [ ] 6. `UpdateWorkspaceSettingsRequest.java`: đổi `reportFrequency` sang
      `ReportFrequency`.
- [ ] 7. `WorkspaceServiceImpl.createWorkspace`: sửa để lưu
      `request.industry()` vào settings lúc build Workspace (fix bug hiện
      tại đang bỏ qua field này hoàn toàn).
- [ ] 8. Nếu task 1 xác nhận thiếu handler: thêm
      `@ExceptionHandler(HttpMessageNotReadableException.class)` trả 400 rõ
      ràng trong `GlobalExceptionHandler`.
- [ ] 9. Unit test: `createWorkspace_withIndustry_savesIndustryInSettings`,
      `createWorkspace_withoutIndustry_settingsIndustryIsNull`.
- [ ] 10. `mvn -o compile` xanh, `mvn -o test` pass.

## Frontend
- [ ] 11. `types/workspace.ts`: thêm `WorkspaceIndustry`, `ReportFrequency`
       type, cập nhật `WorkspaceSettings` interface.
- [ ] 12. `workspaceService.ts`: cập nhật `CreateWorkspaceRequest`,
       `UpdateWorkspaceSettingsRequest` type theo enum mới.
- [ ] 13. `CreateWorkspacePage.tsx`: đổi state `industry` sang
       `WorkspaceIndustry | null`, thay `Input` bằng toggle 10 nút
       (single-select, click-lại-để-bỏ), cập nhật `handleSubmit`.
- [ ] 14. `WorkspaceSettingsPage.tsx`: đổi state `reportFrequency` sang
       `ReportFrequency | null`, thay `Input` bằng toggle 2 nút
       (WEEKLY/MONTHLY), cập nhật `handleSubmit`, cập nhật load từ
       `getById` (bỏ `?? ""`, dùng `?? null`).
- [ ] 15. `vi.json` + `en.json`: thêm `workspace.industry.*` (10 key),
       `workspace.reportFrequency.*` (2 key), key-parallel.
- [ ] 16. `npx tsc --noEmit` sạch.
- [ ] 17. `npx eslint` trên các file đã sửa sạch.

## Verify
- [ ] 18. Restart business-service để load DTO/enum mới.
- [ ] 19. Chạy theo `test.md`, đặc biệt case 1 (fix bug industry) và case 3
       (400 khi gửi giá trị enum sai).
- [ ] 20. Test dark/light + vi/en trên CreateWorkspacePage và
       WorkspaceSettingsPage.

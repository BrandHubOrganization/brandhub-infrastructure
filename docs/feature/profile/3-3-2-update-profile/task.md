# Task — Update Profile (FR 3.3.2)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] `UpdateProfileRequest`: `phone`/`timezone`/`notificationPreferences` nullable (bỏ `@NotBlank`/`@NotNull` thừa)
- [x] `UserServiceImpl.updateUserProfile()` merge `preferences` (giữ notificationPreferences khi chỉ đổi timezone)
- [x] `toResponse` dùng chung với `getUserProfile`

## Frontend — `brandhub-web-dashboard`

- [x] `userService.updateProfile()` gọi `PUT /users/me` với `fullName` + `phone`
- [x] Trang `/profile`: `handleSave` gọi API + `setUser(...)` cập nhật store

## Verify

- [x] `mvn test` pass (`UserServiceImplTest.updateUserProfile_*`)
- [x] `tsc --noEmit` pass

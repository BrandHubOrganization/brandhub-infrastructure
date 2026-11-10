# Task — View User Profile (FR 3.3.1)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] `UserProfileResponse` thêm `phone`, `timezone`, `notificationPreferences`
- [x] `UserServiceImpl.getUserProfile()` trả đủ field mới (extract từ `preferences`)
- [x] `GET /api/v1/users/me` đã có ở `UserController`

## Frontend — `brandhub-web-dashboard`

- [x] `userService.getProfile()` fetch profile thật khi vào trang `/profile`
- [x] Bỏ mock data (`Trung Le`, `0912 345 678`, `trung@brandhub.dev`)

## Verify

- [x] `mvn test` pass (`UserServiceImplTest.getUserProfile_*`)
- [x] `tsc --noEmit` pass

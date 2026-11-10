# Task — List Agency (FR 3.4.1)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.listMyAgencies(AuthenticatedUser)` — gộp owned + member, loại soft-delete
- [x] Map entity → `AgencyResponse` (helper `toResponse`)
- [x] `GET /api/v1/agencies` đã có ở `AgencyController` — trỏ vào service

## Verify

- [x] `mvn test` pass (21 test service + controller)
- [x] User mới chưa có Agency → trả list rỗng (không lỗi)
- [x] Agency của user (owned) + Agency user làm member đều xuất hiện, không lẫn Agency đã soft-delete

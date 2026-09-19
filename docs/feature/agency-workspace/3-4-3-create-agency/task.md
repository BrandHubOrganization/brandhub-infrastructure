# Task — Create Agency (FR 3.4.3)

> Checklist triển khai theo [plan.md](plan.md). Thứ tự thực hiện đúng trình tự dưới đây.

## Backend — `brandhub-business-service`

- [ ] Implement `AgencyServiceImpl.createAgency(AuthenticatedUser, AgencyRequest)`
      — build `Agency.builder()`: `name(request.name().trim())`, `logoUrl`, `description`, `ownerId(currentUser.getId())`
- [ ] Thêm private helper `toResponse(Agency)` map entity → `AgencyResponse` (copy pattern `ClientProfileServiceImpl.toResponse`)
- [ ] Bổ sung `@ResponseStatus(HttpStatus.CREATED)` cho `AgencyController.createAgency` (khớp contract 201)
- [ ] `AgencyServiceImpl` inject `AgencyRepository` qua `@RequiredArgsConstructor`
- [ ] Viết unit test `AgencyServiceImplTest` (happy path + unhappy path) — xem [test.md](test.md)

## Verify trước khi mở PR

- [ ] `mvn compile` xanh, `mvn test` pass
- [ ] Service method ≤ 30 dòng, `@Transactional` cho write operation
- [ ] Không thêm unique constraint trên `owner_id` (user được sở hữu nhiều Agency)
- [ ] Không để `console.log`/sout thừa, không log PII

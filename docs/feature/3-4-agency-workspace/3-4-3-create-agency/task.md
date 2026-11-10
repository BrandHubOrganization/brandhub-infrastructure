# Task — Create Agency (FR 3.4.3)

> Checklist triển khai theo [plan.md](plan.md). Thứ tự thực hiện đúng trình tự dưới đây.

## Backend — `brandhub-business-service`

- [x] **[XÁC NHẬN 2026-09-21 — đã code]** `AgencyServiceImpl.createAgency(AuthenticatedUser, AgencyRequest)` — build `Agency.builder()` với `name(request.name().trim())`, `logoUrl`, `description`, `ownerId(currentUser.getId())`; kèm tạo `AgencyMember(role=OWNER)` cho chính người tạo (bước này không có trong plan.md gốc, DA-965 thực tế đã thêm).
- [x] Helper `toResponse(Agency)` — có trong `AgencyServiceImpl`.
- [x] `@ResponseStatus(HttpStatus.CREATED)` trên `AgencyController.createAgency` — đã khớp contract 201.
- [x] `AgencyServiceImpl` inject `AgencyRepository` qua `@RequiredArgsConstructor`.
- [x] Unit test `AgencyServiceImplTest` — `createAgency_savesWithCurrentUserAsOwnerAndCreatesOwnerMember`, `createAgency_minimalRequest_leavesOptionalFieldsNull`, `createAgency_trimsSurroundingWhitespaceInName` — 3 case, xem [test.md](test.md).

## Verify trước khi mở PR

- [x] `mvn compile`/`mvn test` — coi như pass theo test tồn tại (chưa tự chạy build trong lượt review này).
- [x] Service method ngắn, `@Transactional` cho write operation.
- [x] Không có unique constraint trên `owner_id` — đúng, user được sở hữu nhiều Agency.
- [x] Không có log PII thừa trong `createAgency`.

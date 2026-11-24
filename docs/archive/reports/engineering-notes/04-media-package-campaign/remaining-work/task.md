# Checklist — phần 3.5 còn lại

## Giai đoạn 1 — chỉ tài liệu

- [x] Kiểm tra code hiện có, mock Request, schema init và phần chưa triển khai DA-949.
- [x] Chốt receipt trigger, fields sửa, successful deployment gate và bỏ reminder.
- [x] Chốt Owner-only directory, lifecycle inactive và Request cũ sau Campaign completion.
- [x] Đồng bộ spec FR 3.5.7–3.5.10, directory, BA và master-plan.
- [x] Viết plan kỹ thuật/cutover, checklist và test cases trước code.
- [ ] Người dùng/lead review và thông báo thay đổi BA chung cho team.

## Giai đoạn 2 — DA-951 create/read/edit/cancel

- [x] Fetch/review develop backend/web; tạo `feature/DA-951-content-requests`, bảo toàn dirty changes. Chưa merge các thay đổi mail-template ngoài scope.
- [x] Đọc rules backend/web và kiểm tra Gateway wildcard `/api/v1/**`; không cần đổi Gateway.
- [x] Read-only inventory Atlas/legacy consumers: 0 records, ba legacy indexes; không mapping hoặc ghi shared data.
- [x] Viết migration mới, preflight/dry-run + init parity + hướng dẫn chạy; không init Atlas.
- [x] Implement document/repository/DTO/API, Workspace membership and Campaign gate.
- [x] Implement conditional versioned update/cancel, list/detail/audit.
- [x] Thay mock chỉ ở Workspace Requests; giữ UI module khác. QueryClientProvider đặt riêng trang này.
- [x] Cập nhật song song vi/en requests.json; kiểm tra light/dark/mobile, labels/focus cơ bản (chưa full accessibility audit).
- [x] Unit/MockMvc/Query tests + lint/type-check/build; evidence và giới hạn tại test.md. Live DB integration chưa chạy.

### Handoff giai đoạn 2

- Migration `2026-10-13-content-requests-v2.js` **chưa apply lên Atlas**; phải review backup/freeze/dry-run theo `docs/database/mongo-atlas-migrations.md`.
- Trước migration API trả `503 REQUEST_SCHEMA_NOT_READY`, không tự init/cutover.
- Backend/web ở `feature/DA-951-content-requests`; infrastructure tiếp tục nhánh docs hiện có. Chưa commit/push.
- API contract ghi tại `brandhub-business-service/docs/openapi.yaml` với hậu tố `V2`, không thay legacy endpoints của consumer khác.
- Receive/accept/deny/Task generation chưa triển khai: giai đoạn 3, không đánh dấu toàn bộ DA-951 Done.

## Giai đoạn 3 — DA-951 review/acceptance

- [x] Receive/deny có status/version guard, reviewer/decision metadata/audit và đúng effective MANAGER role.
- [x] Atlas hello read-only: replica-set + sessions; transaction thật kiểm chứng trên Mongo local cô lập.
- [x] Task source unique index/schema guard và stable ID; accept cùng transaction, retry không overwrite.
- [x] Request Task summary scoped + editor link POST/Manager; không sửa Yjs hoặc editor của thành viên khác.
- [x] Unit/MockMvc, real Mongo rollback/race/retry và browser fixture receive/accept/deny/409/double-submit.
- [ ] Operator review/apply hai migration Request trên Atlas, smoke API thật qua Gateway. Chưa commit/push hoặc đóng Jira.

## Giai đoạn 4 — DA-949/950

- [x] Thực hiện partner-directory/task.md; CRUD/deactivate chỉ Owner.
- [x] Update Campaign picker/legacy assign guard và retain inactive links.
- [x] PostgreSQL cô lập migration/init/query/trigger/race + unit cross-Agency + browser fixture.
- [ ] Operator review/apply migration PostgreSQL và JWT smoke qua Gateway; xem partner-directory/test.md.

## Giai đoạn 5 — hoàn thiện và nghiệm thu

- [x] DA-945 negotiation history append-only + legacy baseline, giữ proposal limit.
- [x] Automated Package/Campaign/Request regressions, browser fixture history/version/conflict; live end-to-end chưa nghiệm thu.
- [x] Không seed account hoặc mutate shared data; fixture riêng và hướng dẫn dùng account test hiện có.
- [x] Viết [setup guide](../test-setup.md) PostgreSQL/Atlas/restart và smoke test thủ công.
- [ ] Operator migrate + live Gateway/account Package→Campaign→Task và Request→Task smoke.
- [ ] Commit nhỏ theo Jira, evidence test.md, cập nhật roadmap và trạng thái FR đúng thực tế.
- [ ] Không tự đóng Jira hoặc đưa cả feature về Done chỉ từ mock tests.

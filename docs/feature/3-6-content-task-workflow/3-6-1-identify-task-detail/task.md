# Task — FR 3.6.1 / DA-978

## Bảng chi tiết bên phải — 2026-10-15

- [x] Tách workflow content, giữ provider riêng và contract/capabilities/form cũ.
- [x] URL chọn Task + aside desktop/Sheet mobile; nút đóng/Escape/focus return.
- [x] Cập nhật list nền sau mutation, giữ bộ lọc/view/page; link cũ tương thích.
- [x] Cập nhật vi/en và kiểm tra light/dark, responsive, keyboard.
- [x] Regression provider, route và browser mock; ghi rõ giới hạn không test Atlas.

Theo [plan](plan.md). Checklist thể hiện tiến độ thực tế, không thay trạng thái Jira.

- [x] Cập nhật Q13 thay phân biệt nội bộ/thường, giữ tách ngày đăng và hạn hoàn thành.
- [x] Chuẩn bị plan/task/test trước code ứng dụng.
- [x] Inventory read-only dữ liệu legacy; ghi rõ phần chưa xác minh ở môi trường thật.
- [x] Viết migration foundation additive và đồng bộ fresh init/checker/tests.
- [ ] Review contract list với chủ E51-05 và start/CAS với chủ E51-03.
- [x] Thêm optional fields DTO/model cho Task mới; legacy cần review trước mutation; đọc không bị chặn bởi thiếu marker.
- [x] TaskWorkflowAccess + scoped GET/member-options; ClientProfile → User ID reuse WorkspaceAccessService; reuse list DA-979.
- [x] PATCH detail targeted update, CAS và Campaign closure lock.
- [x] Validate timezone, dueDate/plannedPublishAt/type/references và trả field errors.
- [x] Áp Q13 cho đọc: Client active đọc mọi Task cùng WS; không có bộ chọn nội bộ/thường. Comments chưa triển khai.
- [x] Tạo Task Detail/read-only/form; nối Campaign/Request, không phá editor route.
- [x] Cập nhật tasks namespace vi + en song song.
- [x] Kiểm tra light/dark, keyboard/mobile, conflict giữ input bằng browser harness mock.
- [ ] Unit/API/race/regression theo test.md; migration chỉ chạy DB cô lập hoặc operator xác nhận.

- [x] Slice 2026-10-15: mở từ list thật, shared dates/metadata, readonly legacy/schema states; không tạo backlog list thứ hai.

Unit/MockMvc/Mongo cô lập đã chạy; mục regression đầy đủ còn mở vì chưa test tài khoản thật trên Atlas, removal race xuyên PostgreSQL/Mongo, hoặc chứng nhận coverage toàn service. Không tự coi Jira Done. Xem [evidence/setup](../task-workflow-phase-2-3.md).

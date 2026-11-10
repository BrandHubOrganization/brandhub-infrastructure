# T9 — Cutover System Health sang MongoDB

Trạng thái: chuẩn bị, **chưa thực hiện cutover**. Database production vẫn phải giữ 5 bảng SQL trong rollback window.

## Bằng chứng trước cutover

- Atlas thật, database riêng `brandhub_monitoring_acceptance`: 5/5 integration test pass, 0 skipped.
- Rehearsal trên PostgreSQL database riêng cùng tên và Atlas acceptance: backfill/verify pass; thêm 2 hosts, thêm collector, consume enrollment, reassign target và ghi sample microsecond; reverse-sync và verify pass, 0 discrepancies.
- Manifest local: `tuan-research/system-health-mongodb-refactor/rehearsal-result.json`. PostgreSQL test và Atlas test giữ fixture sau rehearsal để kiểm tra, không reset tự động.
- Các revision HEAD hiện tại chưa chứa phần refactor chưa commit: Business `0fa2ba2`, infrastructure `b5f99dd`, worker `a8f145d`. Phải build/deploy đúng working changes đã nghiệm thu, không chỉ redeploy image cũ.

## Cấu hình release

Compose Business đã có `MONITORING_STORAGE: ${MONITORING_STORAGE:-postgres}`. Thêm biến vào file .env không tự đổi container đang chạy; cần recreate/deploy cả fleet từ image refactor. Default vẫn postgres để không chuyển traffic trước backfill.

Database Mongo production lấy từ cấu hình Business `MONGODB_DATABASE`. Không dùng database acceptance cho cutover. Provision worker dùng cùng database production và Mongo catalog mode. Không cấp quyền catalog-write cho runtime HTTP collector.

## Trình tự thực hiện trong cửa sổ bảo trì

1. Khóa release image/commit refactor cho tất cả Business replica và provisioning tool. Xác nhận backup PostgreSQL và Atlas phục hồi được; ghi danh sách replica/writers.
2. Freeze tất cả monitoring writers: host heartbeat, collector heartbeat, health-results, invite/register và operator provisioning. Drain requests. API write bị gate phải trả lỗi bảo trì, không nhận rồi bỏ dữ liệu.
3. Chạy schema APPLY vào database Mongo production xác nhận rõ tên. Không chạy suite Atlas vì suite xóa dữ liệu test. Nếu collection production đã có dữ liệu khác, dừng và đối chiếu nguồn, không blind overwrite.
4. Chạy backfill với PostgreSQL production chỉ đọc và Mongo production ghi, sau đó verify 0 discrepancies. Ghi manifest/count/thời gian. Chỉ thao tác khi writers đã freeze.
5. Deploy toàn bộ Business refactor với `MONITORING_STORAGE=mongo`, giữ các cấu hình PostgreSQL để auth ADMIN vẫn hoạt động. Chuyển operator provisioning cùng đợt. Xác nhận không replica SQL-mode còn nhận request.
6. Smoke ADMIN list, host/collector heartbeat, result duplicate/order và enrollment trên đối tượng smoke có danh tính riêng. Mở writers, quan sát ít nhất một chu kỳ host/collector/probe; kiểm UI dữ liệu mới không chỉ snapshot cũ.
7. Ghi cutover time, replica/image/config, verify và smoke result. T9 chỉ tick khi có bằng chứng thực thi đủ các bước trên.

## Rollback

Trước khi Mongo có write mới: chuyển toàn fleet về postgres theo gate.

Sau khi Mongo có write mới: freeze/drain, reverse-export Mongo production sang PostgreSQL trong transaction, verify 0 discrepancies, kiểm host mới/enrollment consumed/owner/result timestamp, rồi chuyển fleet và provisioning về postgres. Không chỉ flip flag vì SQL snapshot đã cũ. Không reverse-sync từ acceptance vào production.

## Sau cutover

Theo dõi ít nhất 24 giờ và giữ rollback window đề xuất 7 ngày. Ghi lỗi/p95/throughput và SQL monitoring writes so baseline; không suy giảm tải từ số bảng.

T11 chỉ thực hiện khi có T9/T10 và hết rollback window: backup cuối, xác nhận không consumer SQL/JPA recreate, gỡ adapter rồi retirement migration có guard, không CASCADE. **Không có lệnh DROP production trong phiên rehearsal này.**

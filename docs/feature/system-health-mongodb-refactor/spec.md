# System Health: chuyển persistence từ PostgreSQL sang MongoDB

Ngày: 2026-10-22. Trạng thái: đang triển khai.

## Mục tiêu và phản biện

Chuyển toàn bộ persistence thuộc FR 3.10.3 sang MongoDB để tách nhịp ghi monitoring khỏi PostgreSQL. Giữ nguyên giao diện, API và hành vi nghiệp vụ hiện có.

Số bảng không phải thước đo tải. File init PostgreSQL hiện có **95 câu CREATE TABLE**, không chứng minh database đang chạy có 95 bảng hoặc đang quá tải. System Health chiếm 5 bảng, chỉ giữ mẫu mới nhất; chuyển xong chỉ giảm 5 bảng sau bước dọn dẹp. Cần đo trước/sau để xác nhận lợi ích, không hứa tăng hiệu năng khi chưa benchmark.

Worker Node gửi heartbeat host và collector mỗi 15 giây, probe mặc định 30 giây sau lần hoàn tất. Ước lượng nhịp ghi đầu vào: `servers/15 + collectors/15 + tổng(1/chu kỳ probe thực tế)` mỗi giây, chưa tính enrollment/provisioning. PostgreSQL vẫn phục vụ xác thực ADMIN và các nghiệp vụ khác.

## Phạm vi

| PostgreSQL hiện tại | Đích MongoDB |
|---|---|
| monitoring_servers | monitoring_servers |
| monitoring_collectors | monitoring_collectors |
| monitoring_health_targets | monitoring_health_targets |
| monitoring_health_results | latestResult trong monitoring_health_targets |
| monitoring_enrollments | monitoring_enrollments |

Không chuyển user/role, subscription, billing, audit khác; không chuyển toàn bộ 80+ bảng; không thêm lịch sử metrics, time-series, Prometheus hay service mới. PostgreSQL probe vẫn được giữ: database được kiểm tra khác với nơi lưu monitoring.

## User stories

1. ADMIN xem host, service và dependency với cùng dữ liệu, bộ lọc, phân trang và trạng thái như trước.
2. Agent/collector tiếp tục gửi request với UUID và token đang dùng, không phải cài lại.
3. Operator provision catalog bằng công cụ hiện có đã đổi persistence, giữ mẫu và metadata đúng quyền sở hữu.
4. ADMIN tạo lời mời cài host dùng đúng một lần, hết hạn sau 900 giây.
5. Operator có thể chuyển đổi, đối soát và quay lại PostgreSQL bằng runbook có kiểm chứng.

## Acceptance criteria

- Các đường dẫn `/api/monitoring/servers`, `/heartbeat`, `/collectors/heartbeat`, `/health-targets`, `/health-results`, `/enrollments`, `/register`, `/install.sh`, `/agent.py` giữ request/response contract, envelope, lỗi nghiệp vụ, UUID và nullability.
- Current ADMIN vẫn được kiểm tra lại qua UserSystemRoleRepository; thu hồi quyền có hiệu lực ở lần đọc tiếp theo. Không sao chép role sang Mongo để né truy vấn này.
- Host chưa có mẫu là NO_DATA; đúng 60 giây vẫn ONLINE, sau đó OFFLINE. Collector quá 60 giây không làm mọi service thành DOWN: kết quả hiển thị UNKNOWN/COLLECTOR_OFFLINE.
- Probe quá staleAfterSeconds là UNKNOWN/STALE; vẫn giữ lastKnownStatus. Không TTL xóa host, collector, target hoặc latestResult.
- Lặp current checkId là duplicate, không đổi receivedAt. Check khác có checkedAt cũ hoặc bằng bị 409. Giữ thứ tự kiểm tra quyền → duplicate/order → validation như hiện tại.
- Receipt time do backend gán. Cho phép future skew tối đa 10 giây; không nhận mẫu quá cũ. Giữ validation reason/outcome/HTTP/runtime, metrics null và khoảng giá trị.
- Không tự tạo target/host từ heartbeat hoặc probe. Target phải thuộc collector; reassign phải xóa kết quả cũ cùng lần cập nhật.
- Enrollment hết hạn không thể dùng dù document chưa được TTL dọn; hai request đồng thời chỉ tạo một host. Insert host thất bại không làm mất lời mời.
- Provisioning giữ tính nguyên tử cả batch như công cụ SQL hiện tại; không ghi đè mẫu bằng dữ liệu config cũ. Không cho orphan reference hoặc xóa đối tượng đang được tham chiếu.
- Sau cutover, ghi monitoring và provisioning không dùng 5 bảng SQL. Đọc ADMIN có thể vẫn dùng PostgreSQL theo thiết kế.
- Khi Mongo lỗi, trả lỗi nguồn dữ liệu, không giả lập trạng thái healthy/down và không fallback từng request sang SQL.
- Không thay UX/i18n/theme. Kiểm tra lại hai ngôn ngữ và hai theme trên màn hiện có; nếu phát sinh text UI mới phải bổ sung key vi/en trước triển khai.

## Quyết định và giả định

Chọn một cửa sổ bảo trì ngắn, tạm dừng writers để chuyển nhất quán; không dual-write. Dữ liệu latest nhỏ nên đây là phương án ít rủi ro vận hành hơn, nhưng phải đo thời gian rehearsal. Ngân sách tạm dừng đề xuất ≤10 phút; nếu không đạt, thiết kế lại cutover trước thực hiện.

Mongo production/test phải hỗ trợ multi-document transaction. Cấu hình hỗ trợ storage mode `monitoring.storage=postgres|mongo` (mặc định postgres, bật mongo khi cutover).

## Nguồn nghiên cứu gốc

- [Tuan Research: system-health-mongodb-refactor](../../../../tuan-research/system-health-mongodb-refactor/spec.md)

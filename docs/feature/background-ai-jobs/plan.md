# Kế hoạch triển khai phạm vi đã chốt

Đọc spec.md trước. Thay thế kế hoạch rộng ban đầu bằng vertical slice caption/image/video.

## Thiết kế

Dùng PostgreSQL durable queue với FOR UPDATE SKIP LOCKED, worker executor riêng của Business, lease/heartbeat + fencing và queue scan phục hồi. Không có khoảng hở DB→broker vì job chính là queue; không cần thêm RabbitMQ/outbox cho phạm vi hiện tại. Tái sử dụng credit execution receipt và video reconciliation hiện có; AI service giữ API và logic generation hiện tại.

Admission: validate DTO/ACL → freeze context caption/video → transaction reserve credit + insert job → 202. Worker thực thi frozen Generation qua AiCreditGenerationService, lưu history caption/video bằng formatter hiện có. Không giữ transaction khi gọi AI. Worker crash khi paid outcome chưa rõ → đối soát receipt hiện có; không tự dispatch lại RUNNING/UNKNOWN.

Kết quả + notification được ghi nguyên tử; notification ID theo job nên không lặp. List/get chỉ của actor và ACL workspace; list không trả input/base64/result. Job result chỉ lấy khi đọc detail, không lưu vào localStorage.

Frontend có một polling manager global single-flight; hydrate sau refresh/login, xóa cache khi đổi account. Khay dùng server job state, toast nhận việc “Đã nhận yêu cầu”, toast hoàn thành bấm mở preview. Inbox actionUrl mang aiJob ID; Navbar xử lý mở preview ngay trên trang đang xem. Deep link trực tiếp vẫn hoạt động qua app shell.

Đưa ChatMediaLightbox lên Layout để tái sử dụng toàn ứng dụng, giữ chức năng chat. Caption preview dùng Dialog chỉ đọc/copy. Kết quả không gọi editor mutation. HTTP caller đang mở vẫn có thể nhận kết quả để preview tại panel hiện hữu, nhưng không có auto-apply.

## File dự kiến

Business: service/ai/background/*, controller/AiBackgroundJobController; refactor tách prepare/finish trong AiCaptionService và AiVideoService, không thay sync contract. Migration tại infrastructure/docs/database/migrations/2026-11-17-ai-background-jobs.sql; cập nhật init schema cho fresh installs.
Web: services/aiBackgroundJobService, store/aiJobStore, components/ai/AiJobManager + AiJobPreview; backgroundTaskStore/Dock; generation/caption/video service adapters; Navbar/Layout/chat viewer mount; locales/{vi,en}/common.json.

## Rollout và rủi ro

Apply additive migration trước khi bật caller. Không tự apply lên production. Không rewrite coordinator video chuyên biệt. Worker heartbeat giúp không claim trùng; generation receipt là lớp chống paid duplicate cuối cùng. Provider không receipt/idempotency không thể phục hồi output đã mất; hiển thị cần đối soát thay vì chạy lại.

Worker có hai slot cố định trong đợt này; không thay scheduler hiện hữu. Queue admission có giới hạn theo user và global để tránh payload/credit tồn vô hạn. Kiểm tra shutdown/restart và schema missing không ảnh hưởng endpoint cũ.

## Nghiên cứu tham chiếu

Google AIP-151 https://google.aip.dev/151 — operation identity + status/result.
Microsoft async request/reply https://learn.microsoft.com/en-us/azure/architecture/patterns/asynchronous-request-reply — 202 và status resource.
AWS outbox https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html — tránh dual write; trong slice này queue nằm cùng DB transaction.
Stripe https://docs.stripe.com/api/idempotent_requests — retry cùng key theo logical request.

## Chi tiết sau triển khai

- Giới hạn năm job chưa terminal cho mỗi actor, được tuần tự hóa bằng advisory transaction lock trước credit account lock.
- Cache kiểm tra quyền chỉ trong mỗi request list theo workspace, không cache quyền giữa các request.
- Job terminal xóa input/command JSON lớn; giữ hash để chống trùng và giữ result + reservation reference.
- Media có material_id sẽ lấy preview URL mới qua Material API và kiểm tra quyền kho trước khi mở viewer. Video domain adapter giữ metadata draft/material từ credit receipt.
- Click preview sẽ dọn toast tác vụ đang nổi để không che nút viewer. Không bắn toast mới lên trên viewer đang mở; inbox vẫn lưu thông báo.
- Workspace của yêu cầu ảnh được truyền rõ từ panel, tránh lấy nhầm workspace mới nếu người dùng đổi trang trong lúc đọc ảnh tham chiếu.

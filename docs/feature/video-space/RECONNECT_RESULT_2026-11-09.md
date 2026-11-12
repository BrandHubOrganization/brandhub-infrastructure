# Video Space + Claude: kết quả nối vào BrandHub

Ngày kiểm tra: 09/11/2026. Thay đổi đang ở local, chưa commit/push.

## Phần đã nối

- Business API lưu/mở dự án riêng theo user và workspace, revision/CAS, media upload-session/confirm/abort, khôi phục và tính quota; đọc video AI đã hoàn thành để mở trong editor.
- Nút **Trợ lý AI** trong editor: nhập yêu cầu → lưu bản hiện tại → Claude lập kế hoạch → xem trước → áp dụng bằng command native; Undo một bước.
- Claude dùng API/key/model cấu hình sẵn trong AI service. Hướng dẫn biên tập được đóng gói tại `brandhub-ai-service/app/resources/video-edit/editorial-guide.md`, có nguồn DemoVideo và giới hạn sử dụng rõ ràng. Không chạy shell/code do model sinh ra.
- Tám thao tác: đổi tên, đổi tỷ lệ, thêm/sửa chữ, âm lượng, cắt clip, tốc độ và chuyển cảnh đã có trong engine. Thay đổi vẫn chỉnh thủ công và xuất bằng editor được.
- Cầu nối iframe giữ token ở host; chỉ cho phép endpoint edit-plan của dự án đang mở, có idempotency và kiểm tra revision/nội dung hiện tại trước khi áp dụng.
- Video AI có đường dẫn theo workspace và nút quay về giữ đúng workspace.

Mở: `http://localhost:3000/workspaces/d3210000-0000-4000-8000-000000000003/video-space`

Video AI: `http://localhost:3000/workspaces/d3210000-0000-4000-8000-000000000003/ai-studio/video`

## Bằng chứng

| Kiểm tra | Kết quả |
|---|---|
| Business kiểm thử feature | 67 test qua |
| Business toàn bộ báo cáo Surefire trong worktree sạch | 1741 test, 0 lỗi/0 thất bại, 91 bỏ qua |
| AI regression offline | 120 test qua trước sửa parser native; bộ planner cuối 51 test qua |
| FFmpeg renderer thật với nguồn tổng hợp | 7 test qua, có kiểm tra pixel/chữ/logo/âm thanh |
| Host bridge/credit unit | 14 test qua |
| Native command/concurrency unit | 14 test qua, gồm Undo/Redo và dữ liệu cũ |
| Web lint/type-check/build | Qua; còn cảnh báo lint/chunk có sẵn, không có lỗi chặn build |
| API thật qua Gateway | Login/list/save/read200; stale save409; khác workspace404; thiếu idempotency400 |
| Claude API thật | 200, khoảng2,7giây; đổi tên + thêm chữ; gửi lại cùng key trả đúng kết quả đã lưu |
| Browser riêng, fixture | Kế hoạch AI → áp dụng chữ/âm lượng → Undo qua; không gọi model/video trả phí trong browser test |
| Mở video AI, sửa, lưu, phiên mới, xuất MP4 | Qua; MP4 giải mã640×360, pixel giữa[65,65,65], góc[0,0,0] đúng mask/filter |

Bằng chứng local: `.tmp/video-connect-20261109/` và `.tmp/video-space-e2e/` tại workspace gốc. Bài browser cũ hỏng do selector/menu cũ và mất workspace ở global route; đã sửa đường dẫn theo workspace, dùng selector href và chạy lại qua.

## Database và dữ liệu

- Có backup PostgreSQL `postgres-before-connect.dump` trước thay đổi.
- Đã thử migration trên bản sao `brandhub_video_connect_verify_20261109`, sau đó áp dụng schema quota/runtime, Product Video và manager-sharing cần cho code hiện tại vào local.
- Checksum toàn bộ `billing_plan_versions` không thay đổi; không seed giá/credit, không xóa bảng legacy, không tắt trigger immutable.
- Thêm đúng4index của3collection `video_projects`, `video_project_assets`, `video_project_upload_sessions`; không sửa document tasks/posts/mail cũ.

## Giới hạn còn lại

**Đã xử lý lệch cấu hình AWS ngày09/11:** Business dùng cặp key khác AI. Key AI xác thực STS và đọc đúng bucket/CORS thành công; key Business cũ trả `InvalidClientTokenId`/`InvalidAccessKeyId`. Đã sao lưu `.env` vào file bị Git bỏ qua, đồng bộ riêng `AWS_ACCESS_KEY_ID` và `AWS_SECRET_ACCESS_KEY` từ AI sang Business, giữ nguyên bucket/region và restart Business thành công. Kiểm tra lại cả hai cặp đều xác thực STS/head bucket/CORS thành công; không cần chuyển MinIO hay tạo key mới. Chưa chạy PUT media hoặc tạo video thật trong bước kiểm tra key này. Lưu snapshot và Claude text-plan đã chạy thật, media/end-to-end trong browser dùng fixture.

Claude hiện xử lý metadata, chữ, thời lượng và cấu trúc timeline. Chưa tự xem/nghe toàn bộ footage, tìm nhạc/SFX hay thực thi toàn bộ tác vụ DemoVideo tùy ý. Kế hoạch cần người dùng bấm Áp dụng. Không triển khai VM và không chạy lượt tạo video Veo trả phí trong lần nối này. Product Video renderer/coordinator đã khôi phục source, nhưng tạo cảnh thật vẫn cần provider/journal/cloud readiness riêng.

## Quyết định triển khai

- Khôi phục source đã lưu trong stash, chỉ ghép các phần Video Space/Product Video vào code mới; giữ các thay đổi caption/trend/I2V khác. Sai khác nếu có sẽ cần sửa cục bộ, không bị mất baseline vì đã lưu patch/hash.
- Tái dùng `CONTENT_GENERATE` và cơ chế credit/idempotency hiện có cho lập kế hoạch text; không thêm bảng giá hay đường bỏ qua thanh toán. Nếu muốn tính giá riêng sau này cần operation/pricing được duyệt riêng.
- Chỉ dùng hướng dẫn biên tập có nguồn và action whitelist; không đưa recipe/code SeeCut-VN Noncommercial vào runtime thương mại.
- Giữ worktree/manifest kiểm tra vì chưa commit; không xóa bản làm việc chưa được ghi vào Git.
- Reviewer subagent cuối không chạy được do giới hạn tài khoản của công cụ; controller đã rà soát tích hợp, sửa parser native/empty caption/font/route và chạy các kiểm tra nêu trên. Chưa có chứng cứ review độc lập cuối cùng.

# Kết quả tiếp quản thread Claude — 2026-11-10

Đã đọc đúng thread **Thread Codex trước đó**, session `84196747-2e11-4de6-80a8-44555d54e163`. Điểm dừng là sau khi anh chọn cách1: chuyển skill/tài liệu thành thư viện đọc theo nhu cầu, với hai tool `list_guides`/`read_guide`. Lệnh kiểm kê nguồn của Claude đã hoàn thành; phần tích hợp chưa được làm khi hết hạn mức.

## Đã hoàn thành

- Agent server đang có đã nhận hai tool thật. Danh mục chỉ trả metadata gọn; nội dung gốc được đọc qua tool result theo đoạn/heading hoặc phân trang. Không đưa cả kho vào system prompt và không thay bằng bản tóm tắt tự viết.
- **851 tài liệu có license**: Opus video prompts MIT và HyperFrames creative/animation/audio Apache-2.0. Giữ license/credits, origin và SHA256. Không copy plugin10GB, node_modules, browser, video/ảnh hay credential files.
- **33 tài liệu private**: skill riêng đã chọn, hướng dẫn DemoVideo, playbook19 thể loại, sổ lỗi và handoff/notes Nyambe r06. Nguồn không có giấy phép phân phối rõ ràng nằm ngoài image công khai, mount read-only khi cần; không suy diễn quyền phân phối thương mại.
- Reader giới hạn12000 ký tự/lần và48000 ký tự/job. Từ chối path traversal, symlink, file không phải Markdown, manifest sai, nội dung lệch hash và đầu vào vượt giới hạn. Guide lỗi trả tool error có kiểm soát; không biến thành một lần gọi provider không rõ kết quả.
- Hướng dẫn agent đã yêu cầu tra cứu phần liên quan sau khi xem nguồn, không đọc toàn bộ thư viện hay sao chép ví dụ không phù hợp. Tài liệu không được phép vượt qua schema, preview/QC, ownership hay giới hạn job. Các script trong skill không tự được thực thi.
- Có log `event=video_edit_guide_read` ghi job/guide id và số ký tự; không ghi nguyên nội dung. Có thể dùng để xác minh job nào thật sự đọc guide thay vì chỉ nói đã áp dụng.

## Kiểm chứng

- Toàn bộ test worker tại thời điểm tích hợp: **69 passed /48.67s**.
- Sau sửa bổ sung xử lý catalogue hỏng và log metadata: **9 test guide focused passed /5.18s**; lint theo cấu hình CI passed. Không rerun toàn bộ suite sau hai thay đổi hẹp này.
- Test fake Claude thực hiện list→read→submit; nội dung đoạn được đọc xuất hiện trong tool result, không xuất hiện trong system prompt ban đầu. Test phân tách private/public, license, hash, Unicode, phân trang và lỗi an toàn đều qua.
- Kiểm tra hash đủ884 tài liệu và Compose private override bằng `config --quiet` đều qua.
- Worker được xác nhận0 job QUEUED/RUNNING trước khi reload. Readiness: health200, capabilities200, guide_library.ready=true/count884; không có internal key trả401.
- Giữ nguyên cấu hình **claude-opus-5-5 /high** mà Claude đã thiết lập. Không đổi sang model khác, không commit/push, không deploy VM.
- **Không gửi thêm job/provider call trả phí**. Chưa có video matcha mới chứng minh chất lượng chủ quan sau thay đổi này; không lấy kết quả unit test làm bằng chứng thành phẩm đã đẹp hơn.

## Vị trí

- Tool reader: `brandhub-ai-service/app/services/server_video_edit/guides.py`.
- Tool dispatch và agent rules: `tools.py`, `agent.py` cùng thư mục.
- Gói có license: `brandhub-ai-service/app/resources/video-edit/guides/manifest.json`.
- Gói private local: `F:/LEARN/DA/.tmp/video-edit-guides-20261110/deployment/private-guides-full`.
- Build script: `brandhub-ai-service/tools/video-edit/package_guides.py`.
- Hướng dẫn VM/mount/rebuild: `brandhub-ai-service/docs/server-video-edit/guides.md`; override `compose.video-edit-guides.private.yml`.
- Audit: `.tmp/video-edit-guides-20261110/{sources.json,readiness-before.json,runtime.json,tests.log}`. Source map giữ riêng vì chứa đường dẫn máy anh.

Kho guide giúp agent tiếp cận kiến thức gốc theo nhu cầu. Đây chưa phải kiến trúc Claude Code chạy tùy ý trong container, cũng không tự mở thêm mọi hiệu ứng ngoài khả năng renderer hiện tại. Lượt so sánh matcha có tính phí cần được đo và báo riêng.

# Spec: worker edit video chạy Claude CLI trong container

## Bối cảnh
Owner là người duy nhất dùng web, làm cho nhiều khách. Edit video hiện chạy `claude -p` trong workspace `F:/self/DemoVideo` trên máy owner (`server_video_edit/claude_code.py`), nên chỉ hoạt động khi máy owner bật. Mục tiêu: đóng gói worker vào một container riêng. Tuấn sẽ dựng EC2 riêng để chạy container này sau.

## Phạm vi
- Image `Dockerfile.video-edit` chứa: Claude CLI 2.1.287, Node 22 (HyperFrames ≥ 22), ffmpeg, Chrome headless của HyperFrames, workspace DemoVideo (phần mã/tài liệu và bản mẫu chất lượng `projects/TalkingHead/edits/revision-02`), cùng các skill `fk-*` và bộ skill HyperFrames. MCP EditAtlas khai báo ở user scope.
- Đăng nhập bằng `CLAUDE_CODE_OAUTH_TOKEN` của owner, cùng token với ai-service.
- Không đổi API: worker vẫn là HTTP service ở cổng 8094, business gọi qua `VIDEO_EDIT_RUNTIME_URL`.
- Không làm: dựng EC2 hay CI/CD (Tuấn làm), sửa luồng edit hoặc prompt.

## Yêu cầu
- R1: Không đưa secret vào image. DemoVideo `.env`, `.runtime/flow/chrome_profile`, `~/.claude/.credentials.json` và token đều không được copy. Script staging chỉ copy danh sách cho phép và dừng nếu phát hiện mẫu secret.
- R2: `video-env.cmd` trong container là bản bash tương đương bản Windows, để lệnh trong docs và allowlist (`./video-env.cmd ...`) chạy được.
- R3: Session Claude (`--resume`) và scratch giữ qua restart (named volume). Root filesystem giữ read-only.
- R4: Bỏ package chỉ chạy trên Windows (`comtypes`, `uiautomation`) khi cài lock Python của DemoVideo.
- R5: Tắt auto-update của CLI trong container; muốn nâng phiên bản thì build lại image.
- R6: Chạy local trên Docker Desktop: business là `host.docker.internal:8081`, Mongo Atlas giữ nguyên.

## Rủi ro
- Workspace dựng sẵn không chứa `projects/` của các khách (5 GB). Chỉ có bản mẫu chất lượng. Các dự án khác mount vào nếu cần.
- RAM: Chrome + ffmpeg + Claude + whisper. Mặc định `mem_limit` 6g.

## Bổ sung sau khi test (17-18/11)
- R7: Container dùng database Mongo riêng (`VIDEO_EDIT_MONGO_DATABASE=brandhub_owner_edit`). Journal chỉ có một lease executor toàn cục, nên các worker dùng chung một DB sẽ giành job của nhau. Đã thấy job bị một worker lạ trên DB `brandhub` nhận rồi báo lỗi sau 0.3 giây.
- R8: Theo quyết định của owner, Claude được chạy mọi lệnh Bash trong container (managed settings `/etc/claude-code/managed-settings.json`). Container là sandbox: user thường, root filesystem chỉ đọc, chỉ ghi được scratch và cache. Allowlist trong `claude_code.py` vẫn áp dụng khi chạy trên máy owner.
- R9: Nếu `TIMELINE.json` không hợp lệ, worker vẫn giao MP4 (không chỉnh được từng lớp) và ghi log lý do. Chuyển cảnh dissolve/slide dài hơn đoạn chồng clip được rút lại bằng đoạn chồng, không có đoạn chồng thì đổi thành cut.
- R10: Docker Desktop: `VIDEO_EDIT_UPLOAD_REWRITE` đổi URL upload `localhost:8080` của business sang `host.docker.internal:8080`. Trên EC2 không cần.
- R11: Worker ghi log loại lỗi và vị trí trong code khi job thất bại, không ghi message vì có thể lộ token.

# Bàn giao cho EC2 (Tuấn)

## Build
```
python scripts/stage_video_edit_context.py --demovideo <đường dẫn DemoVideo>   # chạy trên máy có DemoVideo + Claude Code đã cài plugin hyperframes
docker compose -f compose.video-edit.yml build
```
Thư mục `.video-edit-context/` (khoảng 30 MB, không chứa secret) phải có mặt khi build. Có thể build ở máy owner rồi push image lên ECR, EC2 chỉ cần pull.

## Biến môi trường (`.env.video-edit-container`, xem `.env.video-edit-container.example`)
- `INTERNAL_SERVICE_KEY`, `VIDEO_EDIT_MONGO_URI`, `VIDEO_EDIT_MONGO_DATABASE`
- `CLAUDE_CODE_OAUTH_TOKEN`: cùng token với ai-service, nằm ở SSM `/brandhub/ai-service/CLAUDE_CODE_OAUTH_TOKEN`
- `VIDEO_EDIT_BUSINESS_URL`: URL nội bộ của business-service tính từ EC2 mới
- ai-service phải trỏ `VIDEO_EDIT_RUNTIME_URL` tới worker này (mặc định http://127.0.0.1:8094)

## Tài nguyên
- `mem_limit` mặc định 6g (`VIDEO_EDIT_MEM_LIMIT`), 4 CPU (`VIDEO_EDIT_CPUS`). Chrome + ffmpeg + Claude chạy cùng lúc.
- Volume: `video-edit-scratch` (clip/thành phẩm), `video-edit-claude` (session Claude để chat nối tiếp), `video-edit-cache`.
- Model ASR mount vào `/models/asr` (`VIDEO_EDIT_HOST_MODEL_DIR`).
- Nâng phiên bản Claude CLI: sửa phiên bản trong Dockerfile rồi build lại (auto-update đã tắt).

## Lưu ý khi dựng EC2
- Đặt `VIDEO_EDIT_MONGO_DATABASE` riêng cho worker này, không dùng chung DB với worker khác.
- Không cần `VIDEO_EDIT_UPLOAD_REWRITE` khi business trả URL upload công khai hoặc S3.
- Nếu tải clip từ S3 về business chậm hơn 30 giây, đặt `spring.mvc.async.request-timeout` (ví dụ 10m) cho business.

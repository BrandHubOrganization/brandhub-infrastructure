# Test
| ID | Case | Kết quả |
|---|---|---|
| C1 | Staging: 1885 file, chỉ gồm workspace allowlist và 26 skill, không có .env/.runtime/projects khách | pass |
| C2 | `docker compose -f compose.video-edit.yml build` | pass, image 4.34 GB |
| C3 | Container lên, `/health` trả `journal_configured: true` (Mongo Atlas) | pass |
| C4 | `claude --version` 2.1.287; `claude mcp list` EditAtlas đã kết nối; 26 skill | pass |
| C5 | Node v22, ffmpeg 7.1, HyperFrames 0.8.170 qua `./video-env.cmd` | pass |
| C6 | `./video-env.cmd python tools/edit/edit.py selftest` | pass |
| C7 | `claude -p` trong container bằng CLAUDE_CODE_OAUTH_TOKEN, thấy skill hyperframes | pass |
| C8 | `claude_code.ready(config)` = True; business_url = host.docker.internal:8081 | pass |
| C9 | Job edit end-to-end từ web | pass (18/11): plan và render COMPLETED |
| C10 | Lỗi khi test: worker lạ trên DB chung, timeout stream S3 30 giây, URL upload localhost | đã sửa: DB riêng, `SPRING_MVC_ASYNC_REQUEST_TIMEOUT=10m` (máy owner), `VIDEO_EDIT_UPLOAD_REWRITE` |
| C11 | Trước khi bật Bash: 10 lệnh trở lên bị từ chối, bản dựng đơn giản | sau khi bật: 0 lệnh bị từ chối, có HyperFrames, 5,5 phút |
| C12 | TIMELINE.json thật bị lỗi slide/dissolve | fit_transitions: 21/24 → 15 frame, validate_plan pass; 78 test worker pass |

# Test
- Gateway: request `/api/v1/edit-video/v1/edits/x` có JWT tới upstream `/edit-video/v1/edits/x` kèm `X-API-Key`; thiếu JWT → 401.
- Web: POST auto-edits upload đủ clip và `instruction`; follow-up gửi `parent_id`, không gửi lại clip cũ.
- Web: `NEEDS_INPUT` → lượt COMPLETED có `questions`, không `output`; `COMPLETED` có video → `output` + `plan` (width/height/fps/duration_frames).
- Web: health 503 rồi 200 → chờ rồi mới upload.
- Thủ công: web local, project có 1 clip, nhắn "làm thành video 10s" → thấy tiến độ, câu hỏi hoặc video; đưa vào timeline được.
- Light/dark: chat không đổi giao diện.

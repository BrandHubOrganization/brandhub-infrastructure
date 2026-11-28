# Plan
- `brandhub-web/vendor/video-space/src/brandhub/auto-edit-chat.tsx`: thay `Progress` bằng `EditProgress` (stepper + timer + ghi chú); thêm tự nhập lớp cho lượt vừa xong (ref `watching` các id đã thấy chưa xong trong phiên).
- `.../brandhub/studio-messages.ts`: thêm key vi/en (steps, elapsed, autoApplied).
- `.../app/globals.css`: class `bh-progress*` dùng biến theme + reduced-motion.
- Không đổi API/BE.

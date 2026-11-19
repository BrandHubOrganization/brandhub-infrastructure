# Plan

## brandhub-api-gateway
- `application.yml`: route `edit-video` trước `business-protected`; `uri ${EDIT_VIDEO_URL}`, `RewritePath` thêm `${EDIT_VIDEO_PATH_PREFIX}`, `SetRequestHeader X-API-Key ${EDIT_VIDEO_API_KEY}`, `JwtAuthFilter`, `RateLimit`.
- Local `.env`: `EDIT_VIDEO_URL=https://api.brandhub.id.vn`, `EDIT_VIDEO_PATH_PREFIX=/edit-video` (đi qua nginx prod để có waker). Prod: `EDIT_VIDEO_URL=http://<nginx>` cùng prefix.
- Test route: path rewrite, header key, 401 khi thiếu JWT.

## brandhub-web
- `src/pages/video-space/services/editVideoService.ts`: dịch `GET/POST .../auto-edits`, `GET .../auto-edits/{id}/content` sang Edit_Video; lưu danh sách lượt theo project ở localStorage (Edit_Video không có API liệt kê).
- `videoSpaceService.ts`: chuyển các path `auto-edits` sang adapter.
- Không đổi editor iframe, protocol, i18n (`vi.json`, `en.json` không đổi).

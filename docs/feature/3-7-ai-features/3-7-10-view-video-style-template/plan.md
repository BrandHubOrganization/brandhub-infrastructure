# Plan — 3.7.6 View Video Style Template

1. AI service: `video_styles.py` (dataclass catalog, `list_styles`, `styled_prompt`), `GET /api/v1/ai/video/styles`; `VideoGenerateRequest.template_key` được kiểm tra thuộc catalog (sai → 422).
2. Business: `AiVideoService.styles()`, `AiVideoController GET /workspaces/{id}/ai/video-styles`.
3. Web: gallery trong `pages/ai-studio/video.tsx` (radiogroup, swatch hoặc clip preview).
4. Không có DB (catalog cố định). Muốn admin quản lý template: chuyển catalog sang bảng sau.

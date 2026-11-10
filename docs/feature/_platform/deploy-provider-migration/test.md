# Verification
HTTP fixtures assert exact Deploy endpoint/model/auth payload, image data URI, final-only content, no incomplete output, bounded transient retries and no retry on 401/405. Contextual ranking/log/error-code tests remain. Caption/trend-fit/pipeline and generic provider tests use Deploy. Live test uses existing env key with synthetic caption; do not log caption or key. No DB mutation.

Confirm warning translations both identify Deploy, no Gemini claims remain in replay UI; semantic/visual classes unchanged. Run TypeScript and targeted ESLint.

2026-10-27: 89 provider/context/endpoint/trend-fit/Veo tests and 22 caption/extractor/pipeline tests passed, total 111. Live Deploy smoke using existing DEPLOY_MODEL=zai-org/glm-5.3-flash returned HTTP 200 and five ranked hashtags in about 4.2 seconds. Env validation passed: Deploy key/model/base URL loaded, dedicated Veo key retained, no GEMINI_* names. Only Veo retains Google Gemini API transport, as video generation is separate. Adapter tested JSON fences, images, final-only content, transient-only bounded retry and rejection of partial responses. No stored credit reservations changed.

Frontend verification completed: TypeScript build and targeted ESLint pass; vi/en replay warning keys parse and identify Deploy. Layout and interaction classes unchanged. git diff --check passed in both repos.

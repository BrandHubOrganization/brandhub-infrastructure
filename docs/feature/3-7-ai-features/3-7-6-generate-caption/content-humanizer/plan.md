# Implementation plan

1. Pin Humanizer 3.1.0 at upstream commit `0ef9fe5bc3572734fd3ae6c448fe00a30cd5dcf0`; install with Codex's skill installer. Copy unmodified `SKILL.md` and `LICENSE` to `brandhub-ai-service/third_party/humanizer/` and document the adaptation.
2. Define shared compact embedded-mode guidance in `app/utils/humanizer.py`. Python imports keep it available in normal and Docker deployments without a network fetch or a user's home directory.
3. Include it in the existing caption generation/refine/adapt prompts in `app/services/caption_service.py`, the topic system prompt in `app/utils/prompt_builder.py`, and raw prompt mode in `app/api/v1/endpoints/content.py`. Do not change `llm_service.generate_text` globally: trend, moderation, and image/video tasks have different contracts.
4. Extend focused tests in `tests/unit/services/test_caption_service.py` and `tests/integration/api/test_content_endpoint.py` to capture the provider request and verify guidance, one-call behavior, context, and output contracts. Add direct prompt-builder coverage if useful.
5. Document source, behavior, and limitations in `third_party/humanizer/README.md`; record results in `test.md`.

No database, dependency, frontend, locale, theme, provider-routing, or credit changes. Existing local changes from other tasks remain outside this patch. The compact adaptation adds input tokens to the current call; it does not add a second rewrite request. Rollback consists of removing the new prompt imports/references and adaptation files.

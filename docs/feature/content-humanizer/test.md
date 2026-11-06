# Verification

| Case | Expected |
| --- | --- |
| Three captions, VI and EN | Shared editorial instructions, requested language, topic, and existing schema reach exactly one provider call. |
| Brand/trend context | Voice samples stay available as style references; verified brand/trend context and existing provider selection remain intact. |
| Refine and adapt | Final JSON only; CTA/hashtags and existing output parsing remain; one call per operation. |
| Topic content endpoint | Tone, keywords, platforms, Humanizer guidance, and existing response fields survive. |
| Raw prompt endpoint | Original prompt plus shared editorial guidance reach one call with the selected provider. |
| Fabricated number in mock output | Existing unverified-claim signal still flags it. |
| Malformed output and provider failure | Existing errors still propagate; no synthetic fallback text. |
| Source packaging | Pinned source and MIT notice are present; runtime imports work without an installed global skill. |

VI/EN and light/dark UI: not applicable, no UI files or visible labels change.

## Results

Verified on 2026-11-03:

- Red check: the new caption test failed because Humanizer guidance was absent before implementation.
- Final focused suite: **134 passed in 17.36s**:

  ```powershell
  .\.venv\Scripts\python.exe -m pytest tests/unit/services/test_caption_service.py tests/integration/api/test_content_endpoint.py tests/integration/api/test_llm_fallback.py tests/unit/services/test_text_moderation.py -q --disable-warnings --maxfail=3
  ```

- The suite uses mocked generation and moderation providers. No paid generation call was made.
- The Windows sandbox stalled in Python's local socketpair setup for TestClient; the final suite passed outside that sandbox without changing production code for the environment limitation.
- `compileall` passed for all four touched runtime Python modules; `git diff --check` passed for the tracked changes.
- Vendored `SKILL.md` and `LICENSE` hashes match the pinned installation. Runtime imports only the local adaptation, not the global skill directory.

These checks prove request wiring and existing validation, not the subjective quality of live model output. A live before/after content review has not been run.

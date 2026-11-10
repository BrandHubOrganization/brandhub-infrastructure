# Implementation plan

1. Extend existing LLM config with a separate fallback model; Gemini uses configured timeout and immediately hands failures to a single bounded Haiku call. Validate structured caption output inside provider quality checks.
2. Extend CaptionContextService using existing workspace/client columns. Keep workspace as source of truth and enrich only from one unambiguous client. Always pass brand profile to captions.
3. Extend existing trend-fit request with description/platform. Judge natural brand connection; apply score/risk floors independent of model verdict, mark incomplete/rule-only results provisional. Include inputs/source-card fingerprint in the existing Redis cache key.
4. Before generation apply deterministic brand/taboo/industry checks and a selected-trend suitability check. Caption prompt requires brand angle and trend evidence; retain separate checks rather than claiming use from selection alone.
5. Extend existing Business trend-fit DTO/controller and Web service/dialog. Debounce description input and clear stale selections. Update src/i18n/locales/vi/aiStudio.json and src/i18n/locales/en/aiStudio.json in parallel. Preserve existing styles.
6. Test focused Python/Java/TypeScript behavior, then use the isolated preview stack for API-only proof. Do not disturb other worktrees or migrate data.

No dependencies or schema changes. Main risks: extra judge latency, stale cached selections, incomplete brand facts, provider truncation. Reuse cache for selection; fail clearly rather than invent suitable data.

Integration follow-up: retain default Web → Gateway → Business → AI addresses and the normal runner repo paths. Update only ignored AI `.env` Redis/RabbitMQ credentials from the configured Compose `.env`; keep provider API keys in their existing file. Set explicit cheap fallback/timeout values and test normal settings against Redis. Do not copy changes into other active feature worktrees.

User-reported Web3000 bug: amend the above isolation boundary only for the confirmed active Web worktree. Reuse its existing `postAiWithCredit` for the three caption POST calls; copy the focused service-contract test outside src. HMR applies the fix without restarting/replacing other services. Use one saved request/key for the real API test; inspect any subsequent failure separately.

Confirmed AI8082 also predates the bounded fallback patch: apply the current main unstaged llm_service diff with `git apply --check`, add only its two fallback settings, and reuse provider regression tests. Synchronize ignored Redis/RabbitMQ config from the existing Compose file. Restart the same AI API on8082 with its configured role and log output; no other feature files or backend replacement. Preserve the failed request receipt; do not reuse a terminal/unknown key as a new generation.

Endpoint fix: use main's existing `base_url="https://api.anthropic.com"` in worktree `core/clients.py`; do not inherit the shell's ANTHROPIC_BASE_URL. Test this with a fake DeepSeek environment URL and no external calls, then verify one gateway caption request using a distinct saved key after the previous definitive failure.

Approved local price: authenticate through the normal seeded Admin login, PUT `/api/v1/admin/credit/prices/CONTENT_GENERATE` with unitCredits0, enabledtrue, expectedRevision0. Preserve the before/after non-secret API receipt and verify exactly one price is present. Exercise `/api/v1/ai/content/generate` through Gateway8080 with the editor's payload/credit headers and a saved idempotency key; confirm nonempty content and unchanged5000 balance. No code bypass of pricing or SQL financial mutation.

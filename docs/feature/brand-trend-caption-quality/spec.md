# Brand-specific trend captions

## Objective and user story
As a creator, I want suitable trends for my workspace brand and captions that apply my selected trend in the target platform's style. Gemini remains primary; an economical Claude fallback handles unavailable, empty, invalid or timed-out responses.

## Acceptance criteria
- Use a separate Claude fallback model (Haiku 5.5), bounded timeouts and no automatic fallback retry loop. Preserve explicit primary Claude configuration.
- Scope brand facts to the workspace and its linked client profile. Do not combine several clients into one invented brand.
- Filter unsuitable/risky trends and remove fabricated fallback trends. Cache by workspace, profile, user description, platform and candidate content.
- User decision 2026-11-05: when industry/product/audience are incomplete, use the user's description and clearly label recommendations provisional. Never invent missing facts.
- Revalidate a selected trend against brand constraints before caption generation. Do not silently ignore an unsuitable selection.
- Every selected-trend variant includes a concrete connection between trend and brand; platform-specific hook, structure, length, CTA and relevant hashtags. No guarantee of viral reach, invented endorsement or engagement bait.
- Humanizer, existing credit/idempotency and tenant checks remain in force.

## API and UI states
Trend-fit accepts optional description and platform; returns provisional status. Existing callers remain valid. UI sends the current description after a debounce and shows a preliminary notice. Loading/error states must not leave an old workspace's trend selected.

New text uses aiStudio.trendFit.provisional in both src/i18n/locales/vi/aiStudio.json and src/i18n/locales/en/aiStudio.json. Reuse existing semantic colors and light/dark variants; keyboard controls and layout remain unchanged.

## Error handling and edge cases
Provider failure yields the existing unavailable error, never synthetic captions/trends. Invalid selection yields a validation error before LLM caption work. Unknown profile remains provisional, other-brand campaigns permit format study only. Cache changes when source cards change.

## Definition of done / tests
Focused provider, brand isolation, matching/cache, selected-trend, platform and API tests pass. API-only smoke results are saved without credentials. No UI automation, commit or push.

Integration follow-up (2026-11-05): changes live directly in the three main repositories, without hardcoded preview addresses. Align ignored local AI Redis/RabbitMQ credentials with existing local Compose configuration, never print credentials. Verify Redis connectivity through the normal AI settings, without replacing other worktrees' running services.

Runtime bug follow-up: user confirmed Web3000 uses `_wt/web-trend-boards`, whose caption generate/refine/adapt calls still bypass the shared credit-request helper. Missing mandatory idempotency/workspace headers reproduces HTTP400 before provider work. Apply the narrow shared-helper fix to that active worktree, preserving its existing features; verify through Gateway8080 → Business8081 → AI8082. No UI automation, commit or push.

Second runtime failure: after correct headers, AI8082 returns a failed/unknown outcome after 86 seconds. Its active source still uses the older Gemini retry/Opus fallback and stale Redis settings despite using the same provider keys as the working preview. Apply only the already-tested provider fallback patch/configuration to this AI worktree and synchronize its ignored local dependency settings; restart this API with its existing role, leaving unrelated source untouched.

Confirmed provider mechanism: the active worktree's Anthropic client inherits a DeepSeek endpoint from the launching shell. The identical key returns OK on api.anthropic.com and 401 on the inherited endpoint. Bring over main's existing explicit Anthropic URL and add a regression test against shell endpoint leakage. No key replacement is required.

Local pricing follow-up (2026-11-06): user confirmed the editor's generic Generate with AI text button uses CONTENT_GENERATE, a distinct billable operation from free CAPTION_VARIANTS. Local price table is empty. User explicitly selected enabled CONTENT_GENERATE at0 credits per call for local testing. Apply through existing Admin price API with expectedRevision0, leaving all other prices/wallet data unchanged; then test this exact generic content route.

## Out of scope
New brand profile forms, new database schema, paid video generation, publishing and guarantees of virality.

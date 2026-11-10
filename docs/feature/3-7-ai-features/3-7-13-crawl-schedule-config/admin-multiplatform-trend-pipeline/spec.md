# Native multi-platform Trend Pipeline
## Platform order and start prerequisites
Place Facebook before Threads/TikTok in the platform settings; label it Facebook (pages and groups). Preserve its independent save and avoid nested forms. Explain a disabled manual start with missing Threads session and a clear remedy: configure server session or deselect Threads and save; do not bypass preflight or silently omit a selected platform.
## Daily time picker
Replace raw cron editing with a daily hour/minute picker, using the server timezone already displayed. Convert HH:mm to the existing five-field cron contract; no API/DB change. Parse zero-padded existing daily values correctly. Preserve non-daily cron unchanged with a read-only summary and explicit action to switch to daily. Empty time blocks saving. Add parallel time/custom/switch/daily validation labels under admin.trendSettings; existing light/dark tokens and keyboard-accessible shared Input/Button.
## Objective / user story
Admin controls the existing Facebook, Threads and TikTok native pipeline from `?view=trendPipeline`. Keep `?view=crawl` and its legacy settings/API unchanged.
## Acceptance criteria
- Select at least one platform, enable/pause automatic scheduling, edit a five-field cron using the server timezone displayed by status.
- Keep existing deployment defaults: schedule.json; Facebook source settings; Threads 10 topics, 10 posts/topic, 100 posts total, 600 seconds, 200 comments/post; TikTok manual hashtags plus Creative Center, period 7 days, 1 page/hashtag, top 3 enriched posts, 30 comments/post, media enabled.
- Facebook pages/groups retain their own source editor and revision. Threads sources remain Trending Now topics; TikTok supports manual hashtags plus optional Creative Center. Do not pretend Threads supports page URLs or TikTok pages is a strict post cap.
- Technical input bounds: Threads topics 1–50, posts/topic 1–100, total posts 1–1000, seconds 30–3600, comments 0–500. TikTok period 7/30/120, pages 1–5, enriched top posts 1–30, comments 0–100, at most 100 unique hashtags. A manual hashtag line may include its existing topic label. Require manual hashtags when Creative Center is disabled.
- Persist native configuration with optimistic revision, atomic writes and immutable per-run snapshots. Saved settings apply to the next run; an active run keeps its settings. Saving does not start crawler/scheduler.
- Manual runs may run while the automatic schedule is paused. Preflight checks selected platforms rather than requiring Facebook cookies for TikTok-only runs. Configuration checks are not proof of remote login validity.
- Show selected platforms and per-platform collection progress/counts. Overall completion still requires worker processing, DB publication and resolution. Preserve partial output and report nonzero collector exit truthfully.
## UI/UX and states
Compact schedule/platform configuration, separate platform sections; inline validation, pending/saved/error/stale states and explicit reload on revision conflict. No native browser dialogs.
All new UI strings use parallel `admin.trendSettings.*` keys in vi/en admin.json. Existing source/pipeline keys are reused. Use existing semantic tokens and shared controls; verify light/dark and keyboard/mobile/tablet/desktop.
## API
Admin-only GET/PATCH `/api/v1/admin/ai/trend-pipeline/config`; internal GET/POST `/api/v1/ai/trends/pipeline/config`. Body: revision, enabled, cron, platforms, threads limits, tiktok options/hashtags. Reject unknown fields, invalid values and stale updates with structured 400/409; storage failures 503. Never expose sessions, API keys or local paths.
## Edge cases / definition of done
No enabled platform, invalid cron, duplicate hashtags, corrupt persisted settings, simultaneous saves, interruption and recovery remain safe. Legacy settings are independent. Code, docs, isolated verification and Web CI pass.
## Out of scope
No credential editor, new providers, downstream trend algorithm/DB schema changes, live crawling, production config updates, automatic scheduler startup or legacy-page consolidation.

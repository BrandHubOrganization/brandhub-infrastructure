# Plan
## Platform layout and readiness feedback
Split the settings UI into two forms sharing draft state/save handler, with the independent Facebook editor between common controls and Threads/TikTok. Reuse existing readiness guard; add contextual remedy for missing Threads session. Keep credentials outside Web; no runtime configuration writes during QA.
## Daily time picker implementation
Add AdminTrendScheduleField using the shared Input type=time (minute precision). Strictly recognize numeric minute/hour plus three wildcards; leave special cron untouched until explicit switch. Replace only the cron field in AdminTrendSettingsForm; retain API field cron. Update vi/en admin.json. Verify conversion, empty input, preserved special schedules, formatting and Web CI.
1. Add stdlib native pipeline settings store alongside Facebook SourceConfigStore. Defaults read deployment files; runtime JSON and immutable snapshots stay ignored. Validate schema and cron, serialize saves with OS file lock.
2. Wire snapshots into manual runner and run.py, schedule polling into the same settings store. Preserve explicit CLI source/platform overrides and recovery. Pass validated values as argv, never shell strings.
3. Extend readiness for selected platforms and safe run collection metadata. Preserve per-source batches, closure receipts, T0/T1/T2/T5 and T4/T7 unchanged. Nonzero extra collector exits are partial/failed, never successful/empty.
4. Add internal config endpoints and Business Admin proxy/audit. Forward the configuration JSON intact to the strict shared validator, including unknown fields so they cannot be silently discarded. Keep source-config and legacy crawl endpoints unchanged.
5. Web: feature types/service/hook and compact form components under src/pages/admin. Keep Facebook source editor independent; add schedule/platform/Threads/TikTok fields and collection progress. Parallel src/i18n/locales/vi/admin.json and en/admin.json.
6. No Mongo/PostgreSQL migrations or seeder changes: deployment configuration only. Document single shared filesystem between native runner, API and scheduler.
7. Verify using temporary isolated configuration, mocked subprocess/providers and mocked browser APIs. Do not start crawler/scheduler, save live config or access paid AI. Keep QA artifacts ignored.

## Deployment / operation
- Deploy Web, Business and AI together; restart Business/AI to load new routes. Restart an already-running native scheduler once to load the updated scheduler code. Saving settings never starts a scheduler process.
- API, run.py and native scheduler must use the same social_crawler directory and persistent writable runtime volume. Admin configuration is stored in ignored keep-local-only/crawl-control/pipeline-settings.json; persist this deployment state across container recreation. No new database collection/table, migration or seeder is required.
- Before the first Admin save, use existing schedule.json, data/tiktok_hashtags.txt and Facebook source settings. After saving, pipeline-settings.json takes precedence for schedule/platform/Threads/TikTok configuration. Facebook sources retain their independent source-config.json revision.
- Credentials remain server environment configuration: FB_STORAGE_STATE, separate THREADS_STORAGE_STATE, TIKTOK_API_KEY and TIKTOK_API_URL. UI/API never returns their values. Preflight checks local configuration/dependencies, not remote authentication/network availability; collectors report actual runtime failures.
- Immutable pipeline and Facebook source snapshots are generated at dispatch. Recovery continues using saved raw files/receipts without reading new limits or recrawling. Explicit CLI platform/source overrides are preserved.
- Per-run .collection metadata is local progress only. RabbitMQ batch receipts, worker processing and DB publication remain authoritative for complete/partial results. A collector that returns partial data preserves the data and marks the run partial.
- Existing legacy ?view=crawl, Redis crawl settings, API crawler, database schemas and downstream T0/T1/T2/T5/T4/T7 algorithms are unchanged.

# Plan

1. Add a stdlib source-config store to crawlfb: canonical Facebook page/group
   validation, atomic JSON, OS file lock, optimistic revision and fixed run snapshots.
   Store runtime settings under ignored keep-local-only. Default from existing
   data/fb_pages.json + fb_groups.json and FB_MAX_POSTS; fail closed on corrupt data.
2. Snapshot normal manual launches before subprocess start. Let run.py snapshot
   scheduled/direct default runs too. Pass a fixed snapshot argument through the
   existing wrapper into CLI, load once, record revision/limit in the manifest.
   Preserve explicit CLI source/limit overrides and recovery argv/semantics.
3. Add internal source-config read/save routes, separate from legacy crawl-config.
   Add validated Business request record, Admin proxy methods, audit, safe 400/409/503.
4. Add Web source-config service/types/hook and compact expandable form using
   shared controls. Retain dirty form across polling, save with revision, explicitly
   reload after conflict. Update src/i18n/locales/vi/admin.json and en/admin.json.
5. Verify isolated snapshot/concurrency/validation/native regressions, Business
   compile/guard smoke, Web lint/build and mocked browser light/dark/mobile/i18n.
   Keep executable QA and screenshots ignored under keep-local-only.

Deployment: API, scheduler and crawler share one filesystem/runtime settings path.
Restart Business/AI/scheduler for new code. Persistent runtime directory must survive
deployment; separate hosts require shared storage (not implemented here). No database
or schedule migration, seed, cleanup, real configuration save or provider call in QA.

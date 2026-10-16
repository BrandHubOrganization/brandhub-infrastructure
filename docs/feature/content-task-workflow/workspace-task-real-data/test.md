# Cases before implementation

## Demo isolation correction cases (2026-10-16)

- Empty Workspace: Owner/Manager/Creator/Client GET returns empty, only count/find reads; no sample creation or assignee mutation.
- Existing `Untitled post`: GET returns original Task ID and metadata unchanged, no extra Tasks or writes.
- Seed compatibility: TaskSampleSeeder and explicit MongoDataSeeder remain available; never execute full seed on shared Atlas.
- Migration rehearsal: all five scripts pass on a temporary Mongo clone before Atlas writes; final validator accepts legacy states and TODO/IN_REVIEW/FINISHED; Task document hashes unchanged.
- Regression: Task details, assignment/start, Campaign deployment/closure, Request acceptance and content-writing/publishing tests remain green. No real Facebook posting or Campaign retry during verification.

### Verification results (2026-10-16)

- Business `fix/task-demo-isolation`: clean build/package passed; 156 focused unit tests, zero failures/errors/skips. Covers reader (15), workflow service (37), dates (14), content-writing (22), Post service (3), seed guard (5), Campaign deployment/closure and Request services. No real Facebook calls or publishing consumer test in this suite.
- Initial incremental test discovery failed with stale compiled classes (`NoClassDefFoundError: TaskListQuery`); clean Maven build resolved it without dependency changes.
- Rehearsed all five existing Request/Task migrations on ephemeral Mongo with a bounded clone of affected data/metadata; schema guards passed and all five canonical Task states were inserted successfully on the local clone only.
- After user-confirmed Business stop, Atlas APPLY passed against the identical source/script fingerprints. All 5 Task documents and approval history hashes unchanged; 1 Request normalized to V2 without changing its CANCELLED status/business data; legacy Task status enum retained. Post/Chat/Mail and other collection metadata unchanged.
- Private before/after audit artifacts retained outside repositories under `.local-backups`; no init, bulk seed, Task backfill, deployment retry or external publication. Existing local inventory-script edits in Infrastructure left untouched.
- Restart Business on the fixed branch, reload Web, then explicitly retry the approved Campaign. This real authenticated retry was NOT performed by the agent; schema readiness is verified, end-to-end deployment remains a user smoke test. Legacy Tasks without first-start evidence may remain mutation-locked by design.

| Case | Expected |
| --- | --- |
| API path and filters | Versioned endpoint; page/sort/status/type/search/campaignId forwarded |
| Mixed origins | Campaign and Request-generated Task IDs unchanged; manual Tasks retained; no duplicates |
| Scope/access | Every query constrained by workspaceId; nonmember rejected before Mongo/User reads; Client can list all |
| Filter/count | AND predicates before pagination; literal regex-special search; matching total; stable sort |
| Invalid filters | Unknown status/type, oversized search, malformed campaign ID rejected |
| Empty/error | Empty stays empty; 401/403/500/malformed body propagates to UI, no mock fallback |
| Display metadata | Names resolved in one bulk read; missing fields stay missing; no User secrets exposed |
| Four views | Same API rows/page/filter; five types + CANCELLED/DETAIL_IDENTIFIED not lost |
| Dates | Actual deadlines only; absent/invalid deadline unscheduled; no synthetic 2h/2day duration or venue |
| Read-only | No draggable status/date or fake priority; Task click actual summary and source links |
| Race | Older response cannot overwrite newly selected Workspace/filter; loading failure has retry |
| UI | vi/en, light/dark, responsive, keyboard dialog and controls; all views have pagination |

## Results (2026-10-15)

- Web: 109 tests across 11 Vitest files passed. New coverage verifies the versioned URL, filter forwarding, Spring Page.number normalization, 401/403/500 propagation, malformed/cross-Workspace responses, Task/source identity and real/missing deadlines.
- Web type-check and production `npm.cmd run build` passed. Initial sandbox attempts failed on Vite child-process/native dependency restrictions; the normal build succeeded outside sandbox, without changing dependencies/config. Existing mockContentLibraryService static/dynamic import bundler warning remains outside scope.
- Business: 69 focused tests passed (0 failures/errors/skips): WorkspaceTaskReaderTest 11, TaskServiceListTasksTest 3, CampaignTaskStoreTest 2, CampaignDeploymentProcessorTest 2, ContentRequestReviewServiceTest 13, ContentRequestServiceTest 23, AdminSecurityTest 15. These use mocks/test slices, not shared Mongo Atlas. The deploy-failure warning is an intentional failure-path fixture.
- Scoped ESLint: no errors; two advisory warnings remain in useTasks for effect-driven fetch and sequence-ref cleanup. No lint rules were disabled. The stale-response browser case passed.
- Playwright CLI: actual TaskListPage rendered in an isolated browser with fake session and mocked HTTP transport using Spring Page.number. Verified error/retry, original IDs/source link, all four views, cancelled/detail-identified rows, pagination, status/search forwarding, no-match state, delayed stale-response suppression, vi/en switching, keyboard Escape, and 375px light/dark screenshots. No real accounts/tokens were used and no shared backend was called by this harness.
- No DB init/migration/seed/backfill, stash restore, commit or push. Gateway unchanged.

## Limits / next local check

Browser mocks do not prove Mongo Atlas data or real authenticated end-to-end access. Restart Business and refresh Web, then use an existing Workspace with successful Campaign deployment: compare Task IDs with Campaign tasks and accepted Content Request additions; test Owner/Manager/Creator/Client and another Workspace. If the API fails, the page now reports that error instead of inventing mock rows. Calendar/timeline visualize actual deadlines, not durations or publishing schedules; all views show the current paginated result only. Read-only status/date interactions remain intentional.

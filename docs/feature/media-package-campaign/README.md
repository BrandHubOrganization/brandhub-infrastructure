# Media Package & Campaign - V2 implementation baseline

## Purpose

**Checkpoint mới — 2026-10-13:** phần 3.5 còn lại bắt đầu bằng giai đoạn 1 tài liệu,
khác với phase-1-design của đợt Campaign cũ. Xem [spec đã chốt](remaining-work/spec.md),
[kế hoạch 5 giai đoạn](remaining-work/plan.md), [checklist](remaining-work/task.md)
và [test matrix](remaining-work/test.md). Thứ tự mới: DA-951 → DA-949/950 → history/regression.
Chỉ tạo Request khi Campaign IN_PROGRESS và deployment SUCCEEDED; Request cũ tiếp tục
xử lý sau hoàn thành. Owner-only danh bạ, inactive giữ liên kết cũ; không scheduled reminder.

Class diagram cho FR 3.5.1–3.5.10: [Mô hình lớp Package, Campaign và Content Request](class-diagram.md).

**Điểm bắt đầu khi tiếp tục công việc:** [Lộ trình 6 giai đoạn](implementation-roadmap.md)
ghi trạng thái, thứ tự triển khai, Jira, tiêu chí bàn giao và các quyết định còn mở.

Giai đoạn 1 đã hoàn thành thiết kế: [spec/plan/task/test](phase-1-design/spec.md).
Đã chốt tổng sản lượng cả gói, Task EVENT_PLAN/PRESS_RECOMMENDATION và Manager
complete với lý do khi còn Task dang dở. Giai đoạn 2–5 đã có code; điểm tiếp theo
là xác minh migration Atlas và smoke test API/browser theo roadmap.

**Latest BA, 2026-10-08:** one Workspace has one Campaign, created from its approved
package. A new campaign uses a new Workspace; Owner can duplicate selected information
and resources from an existing Workspace. This supersedes multiple cooperation rounds
in one Workspace. See [Campaign delivery plan](campaign-delivery-plan.md) for rollout,
copy scope and remaining verification. Campaign draft, review/deployment and selective
Workspace duplication are implemented in code; this does not imply Jira Done.

October 2026 structured offering extension: see [offering-models/spec.md](offering-models/spec.md)
and its plan/task/test. This slice adds packaging, deliverables, immutable negotiation snapshots
and draft Campaign allocation only; E50-08/09 and detailed E51 service implementations remain separate.

This folder is the technical working baseline for FR 3.5.1--3.5.10. It is intended to make the first implementation slice unambiguous; it is not a replacement for BA documents.

## Source of truth and conflicts

1. Business flow: `docs/ba/04-media-package-campaign.md`, `05-content-task-workflow.md`, and `12-state-machines.md`.
2. V2 data-model decision: `docs/database/database-strategy.md`, section 4.3.
3. Delivery decomposition: `docs/plan/brandhub-master-plan.md`, E50 and E51.

`11-data-entities-glossary.md` still describes a two-table, `packageRefType` model. It is superseded for implementation by the V2 decision: one PostgreSQL `media_packages` table distinguished by `is_template`. A workspace package references it through the single `workspace_media_packages.package_id` foreign key.

## Confirmed V2 baseline

- An Admin template has `is_template = true` and `agency_id IS NULL`; every Agency may view this global catalogue.
- Until the separate Admin implementation is delivered, global templates are supplied by seed data. Admin template authoring is not part of this feature slice.
- An Agency package has `is_template = false` and a required `agency_id`. Only the Agency Owner manages this catalogue. A package can be authored independently or cloned from a global template; `source_template_id` records optional provenance without coupling later edits.
- The Owner controls Agency-wide Workspace visibility with `is_available_to_workspaces`. Hiding a package removes it from future selection but does not invalidate a package already selected by a Workspace.
- Workspace creation already adds the Client. The Client selects only an available package from that Workspace's Agency; global Admin templates are reference material for the Owner and cannot be selected directly. `workspace_media_packages` records the selected, negotiable package. It is replaceable before negotiation starts and fixed to the same package once negotiation begins.
- Until Package approval, the Workspace dashboard redirects to selection/negotiation. Client retains Package/Chat, Manager also retains Workspace settings; creative features remain gated. No scheduled reminder is required.
- Selection snapshots package terms into `workspace_media_packages.final_terms`; later edits to a global template must not retroactively change a Workspace's selected terms.
- A change to terms creates a new terms version. Both approval records for the prior version are invalid and Agency and Client must approve the new version again.
- A Client can cancel a pending content request using terminal status `CANCELLED`, rather than hard deletion, so its audit history remains available.
- A campaign can be created only from an approved workspace package. It starts as `DRAFT`; deployment creates generic Mongo `tasks` in `backlog`.
- `content_requests` are independent of campaign work items; NEW requests require the Workspace Campaign IN_PROGRESS and deployment SUCCEEDED. Existing requests continue after completion. When accepted, one generic task is created with `campaignId: null`.
- A Content Request includes Client-selected `type` (`POST`, `LIVESTREAM`, or `SURVEY`) and `dueDate`; acceptance maps those values to the generated task.
- Campaign `work_items` are stored as JSONB. Each item has stable `id`, `name`, `type`, and `dueDate`. Tasks created from work items must be idempotent; query tasks by `campaignId` rather than duplicating task IDs in PostgreSQL.
- Generated tasks record provenance: Content Request tasks use `sourceType=CONTENT_REQUEST` plus `sourceRefId`; campaign tasks use `campaignId` plus `campaignWorkItemId`. Each pair is unique for its generation source.

## Current delivery order

1. E50-01: global template and Agency catalogue persistence/APIs.
2. E50-02 and E50-03: workspace package selection/read model.
3. E50-04 and E50-05: negotiation history and two-party approval.
4. E50-06 and E50-07: campaign work items, approval, and idempotent deploy.
5. E50-10 with E51-01: content request lifecycle and generated task.

E50-09 / DA-950 now has manual per-Campaign partner tracking APIs and a dedicated
Workspace page for Owner/Manager/Creator/Client. See the
[spec, plan, task and test evidence](campaign-collaborators/spec.md).
E50-08 / DA-949 now adds Owner-only Agency directory CRUD/deactivation at
`/agency/:id/collaborators`; DA-950 selection is active-only and retains inactive
existing links. See [directory evidence](partner-directory/test.md).
PostgreSQL migration `2026-10-13-partner-directory-lifecycle.sql` and matching init
are prepared and tested on an isolated PostgreSQL, **not applied to the shared DB**.
Legacy unverified history blocks deletion; no reactivate/verification API.
Real JWT/Gateway smoke remains to be verified; code completion is not Jira Done.

## Decisions required before affected code

| Topic | Why it matters |
|---|---|
| Scheduled reminder | Removed by confirmed BA 2026-10-13; preserve current gate, no scheduler. |
| Campaign addendum | Confirmed business concept after deployment, but no E50 task owns it yet. |

Do not silently choose behaviour for an open decision.

## Remaining-work phase 5 — 2026-10-13

DA-945 immutable negotiation history + honest legacy baseline and read-only UI diff
are implemented. DA-946 now requires displayed `expectedTermsVersion` for proposal
and approval; old clients must update. DRAFT switches advance version; repeat
same-side approval preserves the original timestamp. History actor uses the
effective Workspace membership, including an Owner acting as Manager.

New SQL: `2026-10-13-package-negotiation-history.sql` (after phase-4 partner lifecycle).
Neither new SQL nor Request Atlas migrations were applied to the shared databases.
Automated checks do not replace live Gateway/account acceptance. Follow
[test setup](test-setup.md) before running the complete flow. No auto commit/push.

## Non-goals

- Do not initialise MongoDB; shared Atlas is already provisioned.
- Use an idempotent Mongo migration to normalise the existing legacy `content_requests` collection; do not rerun `init-mongo.js` against Atlas.
- Admin UI for global-template authoring and billing/KPI accounting are outside this initial slice.

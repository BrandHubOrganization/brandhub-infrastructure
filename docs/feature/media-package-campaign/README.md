# Media Package & Campaign - V2 implementation baseline

## Purpose

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
- When no package has been selected, the Workspace dashboard shows the missing-package state and gives the Client a selection action; Agency roles receive an informational state.
- Selection snapshots package terms into `workspace_media_packages.final_terms`; later edits to a global template must not retroactively change a Workspace's selected terms.
- A change to terms creates a new terms version. Both approval records for the prior version are invalid and Agency and Client must approve the new version again.
- A Client can cancel a pending content request using terminal status `CANCELLED`, rather than hard deletion, so its audit history remains available.
- A campaign can be created only from an approved workspace package. It starts as `DRAFT`; deployment creates generic Mongo `tasks` in `backlog`.
- `content_requests` are independent of campaigns. When accepted, one generic task is created with `campaignId: null`.
- A Content Request includes Client-selected `type` (`POST`, `LIVESTREAM`, or `SURVEY`) and `dueDate`; acceptance maps those values to the generated task.
- Campaign `work_items` are stored as JSONB. Each item has stable `id`, `name`, `type`, and `dueDate`. Tasks created from work items must be idempotent; query tasks by `campaignId` rather than duplicating task IDs in PostgreSQL.
- Generated tasks record provenance: Content Request tasks use `sourceType=CONTENT_REQUEST` plus `sourceRefId`; campaign tasks use `campaignId` plus `campaignWorkItemId`. Each pair is unique for its generation source.

## Current delivery order

1. E50-01: global template and Agency catalogue persistence/APIs.
2. E50-02 and E50-03: workspace package selection/read model.
3. E50-04 and E50-05: negotiation history and two-party approval.
4. E50-06 and E50-07: campaign work items, approval, and idempotent deploy.
5. E50-10 with E51-01: content request lifecycle and generated task.

E50-08 and E50-09 (campaign collaborators) can proceed independently after a campaign exists.

## Decisions required before affected code

| Topic | Why it matters |
|---|---|
| Reminder delay, cadence, and channel | Requirement says `X` days but gives no value or notification owner. |
| Campaign addendum | Confirmed business concept after deployment, but no E50 task owns it yet. |

Do not silently choose behaviour for an open decision.

## Non-goals

- Do not initialise MongoDB; shared Atlas is already provisioned.
- Use an idempotent Mongo migration to normalise the existing legacy `content_requests` collection; do not rerun `init-mongo.js` against Atlas.
- Admin UI for global-template authoring and billing/KPI accounting are outside this initial slice.

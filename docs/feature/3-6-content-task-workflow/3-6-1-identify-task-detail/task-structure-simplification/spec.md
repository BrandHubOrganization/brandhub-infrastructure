# Task structure simplification — FR 3.6.1 / 3.6.2

User approved implementation 2026-10-17. Supersedes QC/planned-publication clauses of the earlier Task detail/five-state specs for this slice.

## Acceptance criteria

- Keep dueDate, workflowRevision, description, references, Creator assignment and optional Client approval.
- Remove plannedPublishAt from Task entity, workflow payloads, autosave and UI. Publishing remains a separate module.
- No new QC assignment/cross-review. Reject non-null QC assignment from old clients instead of silently ignoring it.
- States remain TODO, IN_PROGRESS, IN_REVIEW, FINISHED, CANCELLED. Keep reviewStep distinct; new approval contract is Manager then Client if required. No approval implementation in this slice.
- Preserve CAS, membership rules, deadline bounds, explicit Creator start, Manager lock after first start, Campaign completion lock and Client access to all Workspace Tasks.
- Keep historical QC/read-compatible legacy enum values and fields in existing documents until separately reviewed. Never reinterpret an ongoing QC round or delete task_approvals.
- Do not change comments, POST/content entities or snapshot implementation.
- Use existing UI controls/theme; no new locale keys required when removing controls; preserve historical translations. Light/dark and keyboard patterns unchanged.

## Migration policy

Forward-only metadata migration, default DRY_RUN, explicit APPLY flag. Remove obsolete plannedPublishAt validation dependency; preserve unrelated validator rules and all documents. Physical cleanup/backfill of old fields or states requires a separate allowlist decision. No automatic Atlas APPLY or init.

# Creator assignment — FR 3.6.2 / DA-978

User request 2026-10-17: assign/change Creator from Task Detail and the task-list assignee column.

Manager only, TODO and never started; valid description/deadline and active Creator in the same Workspace required. Server allowedActions and assign API remain authoritative. No unassign action, QC, arbitrary status change, or post-start reassignment. Owner acting as Workspace Manager uses that membership role. Client/Creator cannot assign.

Reuse existing revision-guarded assignment/outbox; task remains TODO until assigned Creator explicitly starts. Save automatically on selecting a Creator; pending state disables duplicate selection; successful write refreshes list and shared detail cache. Failed selection retained with retry/discard; stale revision does not silently retry. Empty/failed member list has explicit feedback/retry.

UI: existing themed SelectMenu/Button; keyboard-accessible trigger, assignment cell stops row-detail click. SelectMenu has an optional defaultOpen passthrough only; existing consumers retain their default behavior. No other module changes. Parallel vi/en tasks.inline.noCreators label; reuse existing loading/error/retry labels. Preserve light/dark and mobile table scrolling.

No DB migration, live reassignment or new approval behavior required.

Follow-up: one click on the list assignee opens Creator options automatically after lazy loading; no second click on an intermediate selector. Existing detail selectors keep their normal click behavior. Escape/outside click closes the dropdown without assigning.

Correction: use a persistent dropdown trigger directly in both list and detail, not a button that mounts another select. Open the menu immediately with loading/error/prerequisite feedback inside it; never bypass server canAssign. Missing description/deadline should explain why assignment is unavailable rather than appear as unexplained static text.

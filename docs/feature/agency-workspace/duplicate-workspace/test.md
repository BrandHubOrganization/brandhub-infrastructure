# DA-1255 — Test cases

1. Owner duplicates same-Agency Workspace with name, timezone and selected
   Manager/Creator/Client; destination contains only those fields/members.
2. Owner leaves timezone unchecked: destination uses `Asia/Ho_Chi_Minh`.
3. Owner selects no members: they become sole Manager; source is unchanged.
4. Selected second Manager replaces Owner as Manager; Owner becomes Creator.
5. Reject multiple selected Managers, stale/inactive membership, member ID from
   another Workspace, non-Agency internal member, or invalid ClientProfile.
6. Reject non-owner and deleted/cross-Agency source without writing a destination.
7. Retry identical request ID: same destination ID and member count; mismatch
   request ID/name is rejected as a conflict.
8. On membership validation/write failure, transaction leaves no destination.
9. Destination has no Package/Campaign/Task/approval/chat/invitation/history;
   source values and statuses remain unchanged.
10. UI allows individual member choices, confirms them, and does not expose a
    working resource-copy option; check light/dark and narrow viewport.

Review 2026-10-10: seven WorkspaceDuplicationServiceImpl unit tests passed;
the full Business Service suite and frontend lint/type-check/production build
passed. Live duplicate API and dedicated browser/visual cases remain pending.

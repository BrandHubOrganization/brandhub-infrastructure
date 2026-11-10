# DA-1255 / DA-E16-13 — Duplicate Workspace

Agency Owner creates a new Workspace from one in the same Agency for a new Campaign.
The Owner supplies a new name and independently selects whether to copy the source
timezone and which active Manager, Creator and Client memberships to copy.

- The current Owner is always a Manager in the new Workspace unless another selected
  Manager replaces them; at most one Manager may be active.
- The Owner reviews member identities and roles before submitting. Only selected,
  currently valid members are copied. A Client retains a link to the same ClientProfile,
  not a copy of the profile; no invitation is recreated.
- `copyTimezone=false` uses the Workspace default `Asia/Ho_Chi_Minh`; true copies only
  the effective timezone from canonical `timezone_config`, which Workspace API exposes as
  `settings.timezone` (consistency fix 2026-10-14, superseding JSON-first precedence).
  The other `settings` keys, profile/branding fields,
  logo/banner and files are not copied.
- Workspace resources are not copied in this release because the resource management
  module is not implemented. The UI must not offer a functional resource-copy switch.
- The new Workspace has its own ID and lifecycle. It never inherits selected/approved
  Package, Campaign, Task, approval, chat, invitation, social token or execution history.
  Existing Package selection/approval is required before its Campaign can be created.
- Only the Owner of the source Agency may duplicate it; deleted sources are rejected.
  The source never changes. Retrying with the same request ID returns the same new
  Workspace, without creating another one. Failures roll back the entire copy.

API: `POST /api/v1/workspaces/{workspaceId}/duplicate`, request
`{requestId, name, copyTimezone, memberIds}`; response 201 with Workspace data.

This feature is distinct from DA-E16-12 Save Workspace Template, which stores a
reusable configuration and does not create a Workspace with selected members.

# Workspace Campaign summary

User request 2026-10-17: replace Recent Campaigns in Workspace Dashboard with its single Campaign. One Workspace has one Campaign.

Show one name, translated status, version and planned-work count; no recent list/count badge/view-all wording. Existing routes all target /workspaces/{id}/campaigns, not non-existent create/id subroutes. Empty state guides Manager to the existing plan workflow, without bypassing package approval. Failure is not empty; provide retry. Multiple legacy records show an inconsistency notice instead of silently selecting one.

Scope: only Dashboard Campaign summary/associated Campaign metric and fetch lifecycle; no changes to Tasks, Analytics, auth, content writing or global layout. Existing semantic theme, shared controls and keyboard access; parallel vi/en workspace.dashboard.workspaceCampaign.* labels. No backend/DB changes.

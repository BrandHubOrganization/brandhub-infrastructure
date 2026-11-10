# Plan

Extract WorkspaceCampaignSummary in workspace/components. Reuse campaignService.list and parent state; clear on Workspace change, ignore stale completion, separate failure and retry from empty. Replace only Campaign card JSX. Campaign metric uses real 0/1 or unknown, never dashboard fallback count. Add parallel vi/en workspace locale keys. Verify lint, scoped diff, component rendering states and whole-Web baseline errors.

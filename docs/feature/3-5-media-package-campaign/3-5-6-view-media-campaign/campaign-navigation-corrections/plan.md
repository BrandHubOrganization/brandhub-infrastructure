# Plan

Remove only package chat query parameters. Report task availability from CampaignDelivery to CampaignPanel keyed by campaign ID; pass boolean to NextStep and hide task link until confirmed. Add optional=true deployment read, retaining default 404 contract, membership checks and scoped campaign validation. Handle explicit successful null and old-server domain-specific 404 safely; never treat arbitrary 404/401 as empty. Keep existing polling and task-creation pipeline. Update vi/en campaign.json. Use isolated mocks, compile and Web CI; no production mutations.

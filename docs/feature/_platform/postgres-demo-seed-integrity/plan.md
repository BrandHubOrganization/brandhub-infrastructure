# Implementation plan

1. Repair CampaignSeeder terms serialization and approved-only campaign creation. Persist package snapshot/version, deliverables and allocations; leave approval lifecycle to the application.
2. Let DataSeeder own a TransactionTemplate boundary inside its error handler so commit failures reach marker failure handling. Apply the same commit boundary fix to the PostgreSQL admin demo runner.
3. Resolve compact-demo identities by reserved email across agency/client/workspace fixtures, removing obsolete positional numbers.
4. Classify billing periods against one captured timestamp per seed invocation.
5. Check behavior through the existing seeder entrypoints. Use PostgreSQL JDBC transactions and a deferred constraint to reproduce a commit failure; use an ephemeral PostgreSQL container for full init/seed/rerun verification.

Preserve existing workflow edits. No automatic commit or push, per repository policy.

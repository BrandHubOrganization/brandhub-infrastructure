# Shared seeder verification

- Missing required schema/index fails before MongoDataSeeder inserts.
- Empty Workspace samples are TODO, unassigned and revision-initialized with null
  first-start evidence; no fake IN_PROGRESS or approval rounds are introduced.
- Existing Workspace Tasks are never replaced.
- Content Request samples are omitted instead of inventing Client, Campaign,
  accepted Task or history evidence.
- Seed failures propagate. Seeders do not apply init, validators or index DDL.
- Shared DB, publishing workers and payment/funding data are not changed by tests.

## Verification record

Business compilation/test-compilation passed. Schema baseline and negative
guards were checked with isolated Mongo; verification artifacts stay ignored.
No executable test files are added by this seeder change.

Dataset-specific data repair and its operation history are local records, not
team setup steps or part of this shared feature.

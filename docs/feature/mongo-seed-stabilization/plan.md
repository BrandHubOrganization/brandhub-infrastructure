# Technical plan

1. MongoSeedSchemaGuard checks the shared Task/Request/Post schema and required
   unique indexes before MongoDataSeeder writes.
2. TaskSampleSeeder only fills empty Workspaces with unassigned TODO samples.
   Preserve existing Tasks; propagate failures instead of hiding them.
3. MongoContentSeeder omits fabricated Content Request samples until the actual
   Client/Campaign workflow supports creating them.
4. Verify Business compilation and schema/seed behavior in isolated environments.
   Do not start application workers against shared data for verification.

No machine-specific repair or data migration is required by these code changes.
Team members use the shared Mongo init for fresh databases or applicable schema
migrations for existing databases; never replay a local repair on another DB.

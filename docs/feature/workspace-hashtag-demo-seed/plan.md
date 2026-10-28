# Plan
Standalone transactional SQL data migration under docs/database/migrations. Validate exact workspace and active demo Creator/Manager users. Use deterministic UUIDs, normalized lowercase tags and actual member display names. INSERT ON CONFLICT DO NOTHING, never update existing rows. Run twice and inspect counts, scope, ownership and constraints.

Generate a separate SQL migration from the JSON with source SHA256 recorded. NFC normalization, one leading # removed, lowercase duplicate key, letters/marks/numbers/underscore and max 100 characters. Deterministic source/workspace/tag UUIDs, transactional preconditions, conflict-ignore. Keep source timestamps out of added-at audit fields.

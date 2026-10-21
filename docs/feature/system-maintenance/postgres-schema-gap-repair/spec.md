# Local PostgreSQL schema gap repair

Apply the three gaps accepted by the user after the local migration audit: create the seed_runs metadata table; widen users.working_language to 50 characters and align its JPA mapping; add and validate the two negotiation history CHECKs from the current baseline.

Acceptance: all three schema effects exist and are valid; existing row counts and user/history content remain unchanged; no seed, cleanup, marker adoption or archive replay. Back up the confirmed local brandhub database before DDL. Preserve unrelated working-tree changes.

BEGIN;

ALTER TABLE client_profiles
    ADD COLUMN IF NOT EXISTS brand_dna JSONB NOT NULL DEFAULT '{}'::jsonb;

INSERT INTO brandhub_schema_migrations (version, description)
VALUES ('20261123_client_profile_brand_dna_v1', 'Add brand_dna JSONB to client_profiles for AI trend-fit and caption generation')
ON CONFLICT (version) DO NOTHING;

COMMIT;

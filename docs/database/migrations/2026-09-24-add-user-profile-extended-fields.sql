-- 2026-09-24 — Add BA-confirmed User Profile fields (FR 3.3.1/3.3.2)
--
-- BA doc `docs/ba/02-authentication-profile.md` §3.3.1 confirms 10 profile
-- fields for the signed-in user; 4 were missing from both the `users` table
-- and the codebase: professionalTitle, bio, portfolioUrl(s), workingLanguage.
--
-- Run this against an existing database that already has the `users` table
-- (created before this date). A brand-new database created from
-- `init-postgres-v2.sql` already includes these columns — do not re-run
-- this file against a freshly initialized DB.
--
-- Apply:
--   psql "$DATABASE_URL" ^
--     < brandhub-infrastructure\docs\database\migrations\2026-09-24-add-user-profile-extended-fields.sql

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS professional_title VARCHAR(255),
    ADD COLUMN IF NOT EXISTS bio TEXT,
    ADD COLUMN IF NOT EXISTS portfolio_urls JSONB NOT NULL DEFAULT '[]',
    ADD COLUMN IF NOT EXISTS working_language VARCHAR(10);

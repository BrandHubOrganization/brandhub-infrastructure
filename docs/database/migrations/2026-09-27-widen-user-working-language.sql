-- Widen users.working_language from VARCHAR(10) to VARCHAR(50) — field is
-- becoming a multi-select (comma-joined language codes, e.g. "vi,en,fr")
-- instead of a single free-text code, so 10 chars is too small.
ALTER TABLE users
    ALTER COLUMN working_language TYPE VARCHAR(50);

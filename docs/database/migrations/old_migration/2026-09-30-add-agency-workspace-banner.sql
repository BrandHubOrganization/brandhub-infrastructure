-- Apply once: psql -X -v ON_ERROR_STOP=1 -f 2026-09-30-add-agency-workspace-banner.sql
-- Thêm banner_url cho agencies/workspaces — mirror cột banner_url đã có ở
-- users (2026-09-27-add-user-profile-skills-social-location.sql), ảnh bìa
-- ghi qua POST /agencies/{id}/banner và POST /workspaces/{id}/banner.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SET LOCAL search_path = public;

ALTER TABLE agencies ADD COLUMN IF NOT EXISTS banner_url VARCHAR;
ALTER TABLE workspaces ADD COLUMN IF NOT EXISTS banner_url VARCHAR;

COMMIT;

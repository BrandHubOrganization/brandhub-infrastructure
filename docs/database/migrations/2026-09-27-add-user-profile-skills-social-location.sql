-- 2026-09-27 — Add User Profile fields: skills, location, experience, social links
--
-- Bổ sung các trường hồ sơ theo mô hình profile của LinkedIn/Upwork/Contra:
--   skills              — danh sách chuyên môn (chip multi-select), JSON array
--   location            — vị trí địa lý
--   years_of_experience — số năm kinh nghiệm (INTEGER, không enum)
--   linkedin_url / facebook_url / instagram_url / tiktok_url / website
--                       — social links có cấu trúc (5 cột riêng, mirror bảng agencies)
--   banner_url          — ảnh bìa hồ sơ; 1 cột cho cả 2 cách nhập (upload qua
--                         POST /users/me/banner ghi URL S3, hoặc user dán URL tay)
--
-- `skills` dùng cùng pattern với `portfolio_urls` (JSONB array of string, entity giữ
-- raw JSON String + @JdbcTypeCode(SqlTypes.JSON), service serialize bằng ObjectMapper).
--
-- Run this against an existing database that already has the `users` table
-- (created before this date). A brand-new database created from
-- `init-postgres-v2.sql` already includes these columns — do not re-run
-- this file against a freshly initialized DB.
--
-- Apply:
--   psql "$DATABASE_URL" ^
--     < brandhub-infrastructure\docs\database\migrations\2026-09-27-add-user-profile-skills-social-location.sql

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS skills JSONB NOT NULL DEFAULT '[]',
    ADD COLUMN IF NOT EXISTS location VARCHAR(255),
    ADD COLUMN IF NOT EXISTS years_of_experience INTEGER,
    ADD COLUMN IF NOT EXISTS linkedin_url VARCHAR,
    ADD COLUMN IF NOT EXISTS facebook_url VARCHAR,
    ADD COLUMN IF NOT EXISTS instagram_url VARCHAR,
    ADD COLUMN IF NOT EXISTS tiktok_url VARCHAR,
    ADD COLUMN IF NOT EXISTS website VARCHAR,
    ADD COLUMN IF NOT EXISTS banner_url VARCHAR;

-- 2026-09-27 — Add Client Profile brand fields (contact, company size, tax, tagline…)
--
-- Bổ sung các trường hồ sơ thương hiệu còn thiếu ở form "Tạo hồ sơ mới", mirror
-- bộ field đã có trên bảng `agencies` để client brand khai báo đủ thông tin:
--   contact_name / contact_email — người liên hệ đại diện thương hiệu
--   company_size                 — quy mô công ty (enum SIZE_1_10…SIZE_500_PLUS, giữ dạng
--                                  VARCHAR như agencies.company_size, không tạo DB enum)
--   instagram_url                — kênh Instagram của thương hiệu
--   tax_code                     — mã số thuế
--   address                      — địa chỉ trụ sở (khác `location` — vị trí/thành phố)
--   tagline                      — câu định vị ngắn
--   founded_year                 — năm thành lập (INTEGER, không enum)
--   budget_range                 — khoảng ngân sách marketing dự kiến (VARCHAR, giá trị
--                                  hợp lệ do FE quản lý trong BUDGET_RANGES)
--
-- `logo_url` đã có sẵn và phục vụ cả 2 cách nhập: upload qua
-- POST /api/v1/client-profile/{profileId}/logo (ghi URL S3), hoặc user dán URL tay.
--
-- Run this against an existing database that already has the `client_profiles` table
-- (created before this date). A brand-new database created from
-- `init-postgres-v2.sql` already includes these columns — do not re-run
-- this file against a freshly initialized DB.
--
-- Apply:
--   psql "$DATABASE_URL" ^
--     < brandhub-infrastructure\docs\database\migrations\2026-09-27-client-profile-brand-fields.sql

ALTER TABLE client_profiles
    ADD COLUMN IF NOT EXISTS contact_name  VARCHAR(255),
    ADD COLUMN IF NOT EXISTS contact_email VARCHAR(255),
    ADD COLUMN IF NOT EXISTS company_size  VARCHAR(50),
    ADD COLUMN IF NOT EXISTS instagram_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS tax_code      VARCHAR(50),
    ADD COLUMN IF NOT EXISTS address       VARCHAR(500),
    ADD COLUMN IF NOT EXISTS tagline       VARCHAR(255),
    ADD COLUMN IF NOT EXISTS founded_year  INTEGER,
    ADD COLUMN IF NOT EXISTS budget_range  VARCHAR(50);

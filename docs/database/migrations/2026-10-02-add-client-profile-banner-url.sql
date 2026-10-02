-- 2026-10-02 — Add banner_url to client_profiles table
--
-- Cho phép hồ sơ thương hiệu (ClientProfile) chọn/upload ảnh bìa (banner) giống với Agency.

ALTER TABLE client_profiles
    ADD COLUMN IF NOT EXISTS banner_url VARCHAR(500);

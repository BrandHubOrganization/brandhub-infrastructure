-- Loại công ty: AGENCY (phục vụ khách hàng) hoặc PERSONAL (studio cá nhân, nhiều không gian cá nhân).
ALTER TABLE agencies ADD COLUMN IF NOT EXISTS company_type VARCHAR(20) NOT NULL DEFAULT 'AGENCY';
ALTER TABLE agencies DROP CONSTRAINT IF EXISTS chk_agencies_company_type;
ALTER TABLE agencies ADD CONSTRAINT chk_agencies_company_type CHECK (company_type IN ('AGENCY', 'PERSONAL'));
-- Studio cá nhân tạo trước khi có cột được đánh dấu bằng logo_icon.
UPDATE agencies SET company_type = 'PERSONAL' WHERE logo_icon = 'personal-studio' AND company_type <> 'PERSONAL';

-- Personal companies created by the 1-click bootstrap were named "Personal Studio — <name>" in English while their
-- workspace was "Không gian Cá nhân — <name>". New ones are "Studio — <name>"; this renames the untouched old ones.
-- Only rows still carrying the generated name/description/tagline change. Idempotent. psql -X -v ON_ERROR_STOP=1
BEGIN;
UPDATE agencies
   SET name = 'Studio — ' || substring(name FROM char_length('Personal Studio — ') + 1)
 WHERE company_type = 'PERSONAL' AND name LIKE 'Personal Studio — %';
UPDATE agencies
   SET description = 'Studio cá nhân'
 WHERE company_type = 'PERSONAL' AND description = 'Personal Studio Hub';
UPDATE agencies
   SET tagline = 'Studio nội dung cá nhân'
 WHERE company_type = 'PERSONAL' AND tagline = 'Personal Content Studio';
COMMIT;

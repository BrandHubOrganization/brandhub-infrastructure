-- Addendum B (3.6.28-32): danh sách chặn mail riêng theo Agency.
-- Người bấm huỷ đăng ký ở mail AGENCY_INTERNAL/AGENCY_CLIENT chỉ bị chặn mail của đúng Agency đó,
-- không bị chặn luôn mail broadcast hệ thống (workspace_id IS NULL AND agency_id IS NULL).
-- Prerequisites: 2026-10-28-mail-template-scope-postgres.sql đã chạy.
\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='120s';
SET LOCAL search_path=public;
SELECT pg_advisory_xact_lock(392026,1029);
DO $$
BEGIN
 IF to_regclass('mail_suppressions') IS NULL OR to_regclass('agencies') IS NULL
    OR to_regclass('brandhub_schema_migrations') IS NULL THEN
  RAISE EXCEPTION 'mail_suppressions/agencies must exist';
 END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'uq_mail_suppressions_system_email') THEN
  RAISE EXCEPTION 'Apply 2026-10-28-mail-template-scope-postgres.sql first';
 END IF;
END $$;

ALTER TABLE mail_suppressions ADD COLUMN IF NOT EXISTS agency_id UUID REFERENCES agencies(id);

-- Một dòng thuộc đúng một phạm vi: Workspace, Agency hoặc hệ thống (cả hai cột null).
ALTER TABLE mail_suppressions DROP CONSTRAINT IF EXISTS ck_mail_suppressions_one_scope;
ALTER TABLE mail_suppressions ADD CONSTRAINT ck_mail_suppressions_one_scope
 CHECK (workspace_id IS NULL OR agency_id IS NULL);

-- Danh sách hệ thống nay phải loại các dòng Agency.
DROP INDEX IF EXISTS uq_mail_suppressions_system_email;
CREATE UNIQUE INDEX uq_mail_suppressions_system_email
 ON mail_suppressions (email_lower) WHERE workspace_id IS NULL AND agency_id IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_mail_suppressions_agency_email
 ON mail_suppressions (agency_id, email_lower) WHERE agency_id IS NOT NULL;

INSERT INTO brandhub_schema_migrations(version,description) VALUES
 ('20261029_mail_suppressions_agency','Addendum B: mail_suppressions.agency_id, per-Agency unsubscribe list')
ON CONFLICT DO NOTHING;
COMMIT;

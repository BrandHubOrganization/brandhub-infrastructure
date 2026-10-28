-- Addendum B (3.6.28-32, chưa chốt): mở rộng mail_send_quota.scope CHECK thêm 'AGENCY',
-- và cho phép mail_suppressions.workspace_id NULL (khoá đặc biệt cho ADMIN_SYSTEM_BROADCAST).
-- Prerequisites: mail-template-builder (mail_send_quota, mail_suppressions phải tồn tại sẵn).
\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='120s';
SET LOCAL search_path=public;
SELECT pg_advisory_xact_lock(392026,1028);
DO $$
BEGIN
 IF to_regclass('mail_send_quota') IS NULL OR to_regclass('mail_suppressions') IS NULL
    OR to_regclass('brandhub_schema_migrations') IS NULL THEN
  RAISE EXCEPTION 'Apply mail-template-builder migrations first; mail_send_quota/mail_suppressions must exist';
 END IF;
END $$;

-- mail_send_quota.scope CHECK hiện chỉ cho ('SYSTEM','WORKSPACE') — thêm 'AGENCY' cho AGENCY_INTERNAL/AGENCY_CLIENT.
ALTER TABLE mail_send_quota DROP CONSTRAINT IF EXISTS mail_send_quota_scope_check;
ALTER TABLE mail_send_quota ADD CONSTRAINT mail_send_quota_scope_check
 CHECK (scope IN ('SYSTEM', 'WORKSPACE', 'AGENCY'));

-- mail_suppressions.workspace_id hiện NOT NULL — nới để dùng workspace_id IS NULL làm khoá suppression
-- phạm vi hệ thống (ADMIN_SYSTEM_BROADCAST), tách biệt suppression theo từng Workspace.
ALTER TABLE mail_suppressions ALTER COLUMN workspace_id DROP NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_mail_suppressions_system_email
 ON mail_suppressions (email_lower) WHERE workspace_id IS NULL;

-- Phát hiện khi code MailDeliveryService (bản đầu B.1/B.5 bỏ sót): mail_batches.workspace_id hiện
-- NOT NULL REFERENCES workspaces(id) — chặn cứng batch của ADMIN_SYSTEM_BROADCAST/TRANSACTIONAL_AUTO/
-- AGENCY_INTERNAL/AGENCY_CLIENT (không gắn Workspace). Nới nullable + thêm scope/agency_id để worker
-- (MailDeliveryService.process()) biết áp quota theo đường nào khi workspace_id null.
ALTER TABLE mail_batches ALTER COLUMN workspace_id DROP NOT NULL;
ALTER TABLE mail_batches ADD COLUMN IF NOT EXISTS scope VARCHAR(32);
ALTER TABLE mail_batches ADD COLUMN IF NOT EXISTS agency_id UUID REFERENCES agencies(id);
ALTER TABLE mail_batches DROP CONSTRAINT IF EXISTS ck_mail_batches_scope_consistency;
ALTER TABLE mail_batches ADD CONSTRAINT ck_mail_batches_scope_consistency
 CHECK (
   (workspace_id IS NOT NULL AND agency_id IS NULL)
   OR (workspace_id IS NULL AND scope IN ('ADMIN_SYSTEM_BROADCAST','TRANSACTIONAL_AUTO'))
   OR (workspace_id IS NULL AND agency_id IS NOT NULL AND scope IN ('AGENCY_INTERNAL','AGENCY_CLIENT'))
 );
-- mail_deliveries không cần workspace_id trực tiếp (join qua batch_id) — không đổi.

INSERT INTO brandhub_schema_migrations(version,description) VALUES
 ('20261028_mail_template_scope_postgres','Addendum B: mail_send_quota AGENCY scope, mail_suppressions nullable workspace_id, mail_batches nullable workspace_id + scope/agency_id for non-Workspace scopes')
ON CONFLICT DO NOTHING;
COMMIT;

-- Admin Plan Editor (docs/feature/admin-plan-editor): audit log of admin plan changes.
-- Plan versions stay immutable: an edit inserts a new version, a sale toggle flips is_sellable.
-- Idempotent; safe to run multiple times. psql -X -v ON_ERROR_STOP=1
BEGIN;
CREATE TABLE IF NOT EXISTS billing_plan_change_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_code text NOT NULL,
  plan_version_id uuid NOT NULL REFERENCES billing_plan_versions(id) ON DELETE RESTRICT,
  action text NOT NULL CHECK (action IN ('NEW_VERSION', 'ENABLE_SALE', 'DISABLE_SALE')),
  actor_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  reason text NOT NULL CHECK (char_length(btrim(reason)) BETWEEN 3 AND 500),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_billing_plan_change_log_code ON billing_plan_change_log (plan_code, created_at DESC);

INSERT INTO brandhub_schema_migrations (version, description)
VALUES ('20261122_admin_plan_editor_v1', 'Admin plan editor change log')
ON CONFLICT (version) DO NOTHING;
COMMIT;

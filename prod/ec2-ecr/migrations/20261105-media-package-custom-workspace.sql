BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
ALTER TABLE public.media_packages ADD COLUMN IF NOT EXISTS custom_workspace_id uuid;
COMMIT;

-- Personal companies are one user (the owner). Removes everyone else that slipped in before the 1-user cap:
--   * agency_members rows for non-owners are copied to personal_extra_members_backup_20261122, then deleted
--     (agency_members has no soft-delete column; restore from the backup table if needed).
--   * workspace_members rows for non-owners in personal-company workspaces are deactivated (is_active = false).
--   * pending agency/workspace invitations of personal companies are revoked.
-- Run after 2026-11-22-agency-company-type.sql. Idempotent. psql -X -v ON_ERROR_STOP=1
BEGIN;
CREATE TABLE IF NOT EXISTS personal_extra_members_backup_20261122 (LIKE agency_members INCLUDING DEFAULTS);

INSERT INTO personal_extra_members_backup_20261122
SELECT am.* FROM agency_members am
JOIN agencies a ON a.id = am.agency_id
WHERE a.company_type = 'PERSONAL' AND am.user_id <> a.owner_id
  AND NOT EXISTS (SELECT 1 FROM personal_extra_members_backup_20261122 b WHERE b.id = am.id);

DELETE FROM agency_members am
USING agencies a
WHERE a.id = am.agency_id AND a.company_type = 'PERSONAL' AND am.user_id <> a.owner_id;

UPDATE workspace_members wm SET is_active = false, updated_at = now()
FROM workspaces w JOIN agencies a ON a.id = w.agency_id
WHERE w.id = wm.workspace_id AND a.company_type = 'PERSONAL' AND wm.is_active
  AND wm.user_id IS DISTINCT FROM a.owner_id;

UPDATE agency_invitations ai SET status = 'REVOKED'
FROM agencies a
WHERE a.id = ai.agency_id AND a.company_type = 'PERSONAL' AND ai.status = 'PENDING';

UPDATE workspace_invitations wi SET status = 'REVOKED'
FROM workspaces w JOIN agencies a ON a.id = w.agency_id
WHERE w.id = wi.workspace_id AND a.company_type = 'PERSONAL' AND wi.status = 'PENDING';

INSERT INTO brandhub_schema_migrations (version, description)
VALUES ('20261122_personal_remove_extra_members_v1', 'Personal company = owner only: drop extra members, revoke invites')
ON CONFLICT (version) DO NOTHING;
COMMIT;

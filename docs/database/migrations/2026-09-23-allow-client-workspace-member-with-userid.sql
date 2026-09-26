-- ============================================================
-- BrandHub — Migration: allow CLIENT workspace_members row to carry both
--                        user_id and client_profile_id
-- Date: 2026-09-23
-- Reason: Real client login flow — user accepts a CLIENT agency invite,
--         gets a WorkspaceMember with role=CLIENT that is now linked to
--         BOTH their user_id (real login) and their agency-scoped
--         client_profile_id (brand profile shown in UI). Old constraint
--         forced user_id IS NULL whenever role=CLIENT, which only fit
--         the old "manager manually adds client, no login" model.
--         AgencyServiceImpl.acceptClientInvitation() now inserts rows
--         with both columns set — DB rejected them with
--         ConstraintViolationException until this migration runs.
--
-- Idempotent: safe to run repeatedly on any existing V2 database.
--
-- Usage (against the running postgres container):
--   docker exec -i brandhub-postgres psql -U brandhub -d brandhub < 2026-09-23-allow-client-workspace-member-with-userid.sql
-- ============================================================

ALTER TABLE workspace_members DROP CONSTRAINT IF EXISTS chk_workspace_members_identity;

ALTER TABLE workspace_members ADD CONSTRAINT chk_workspace_members_identity CHECK (
    (role = 'CLIENT' AND client_profile_id IS NOT NULL)
    OR (role != 'CLIENT' AND user_id IS NOT NULL AND client_profile_id IS NULL)
);

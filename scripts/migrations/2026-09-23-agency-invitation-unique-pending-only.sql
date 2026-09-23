-- ============================================================
-- BrandHub — Migration: agency_invitations unique constraint scoped to
--                        PENDING only (was: unique across ALL statuses)
-- Date: 2026-09-23
-- Reason: Root cause of "500 Internal Server Error" on invite. Old
--         UNIQUE (agency_id, invited_email) blocked re-inviting ANY
--         email that ever had an invitation row for that agency —
--         even REVOKED/EXPIRED/ACCEPTED ones. AgencyServiceImpl
--         .inviteMember() only checks for an existing PENDING,
--         non-expired invitation (pendingInvitationExists) before
--         inserting, so a legitimate re-invite after revoke/expiry
--         passed that check but then hit the DB constraint and threw
--         DataIntegrityViolationException, caught by the generic
--         500 handler in GlobalExceptionHandler.
--
-- Idempotent: safe to run repeatedly on any existing V2 database.
--
-- Usage (against the running postgres container):
--   docker exec -i brandhub-postgres psql -U brandhub -d brandhub < 2026-09-23-agency-invitation-unique-pending-only.sql
-- ============================================================

ALTER TABLE agency_invitations
    DROP CONSTRAINT IF EXISTS agency_invitations_agency_id_invited_email_key;

CREATE UNIQUE INDEX IF NOT EXISTS idx_agency_inv_unique_pending
    ON agency_invitations(agency_id, invited_email) WHERE status = 'PENDING';

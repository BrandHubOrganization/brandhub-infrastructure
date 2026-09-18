-- ============================================================
-- BrandHub — Migration: add ip_address + user_agent to user_refresh_tokens
-- Date: 2026-09-18
-- Reason: DA-1235 (logout / OAuth refresh-token hardening). Entity
--         com.brandhub.business.model.UserRefreshToken gained:
--           ipAddress  -> ip_address VARCHAR(45)  (nullable)
--           userAgent  -> user_agent  VARCHAR(255) (nullable)
--         Hibernate runs ddl-auto=validate, so the app refuses to
--         boot (SchemaManagementException: missing column) until the
--         DB matches.
--
-- Idempotent: safe to run repeatedly on any existing V2 database.
--
-- Usage (against the running postgres container):
--   docker exec -i brandhub-postgres psql -U brandhub -d brandhub < 2026-09-18-add-refresh-token-ip-user-agent.sql
-- ============================================================

ALTER TABLE user_refresh_tokens
    ADD COLUMN IF NOT EXISTS ip_address VARCHAR(45),
    ADD COLUMN IF NOT EXISTS user_agent  VARCHAR(255);

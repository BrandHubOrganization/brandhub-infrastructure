-- ============================================================
-- BrandHub — Migration: add two_factor_enabled + totp_secret to users
-- Date: 2026-09-18
-- Reason: DA-1235 (2FA / TOTP auth hardening). Entity
--         com.brandhub.business.model.User gained:
--           twoFactorEnabled -> two_factor_enabled BOOLEAN NOT NULL DEFAULT FALSE
--           totpSecret       -> totp_secret        VARCHAR(64)   (nullable)
--         Hibernate runs ddl-auto=validate, so the app refuses to
--         boot (SchemaManagementException: missing column) until the
--         DB matches.
--
-- Idempotent: safe to run repeatedly on any existing V2 database.
--
-- Usage (against the running postgres container):
--   docker exec -i brandhub-postgres psql -U brandhub -d brandhub < 2026-09-18-add-user-totp-two-factor.sql
-- ============================================================

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS two_factor_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS totp_secret        VARCHAR(64);

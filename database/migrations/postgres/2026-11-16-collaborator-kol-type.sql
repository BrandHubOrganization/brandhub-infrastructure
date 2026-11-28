-- FR 3.7.19 — Recommend Collaborator & Collaborator Directory: add KOL to collaborator_type enum.
-- Additive only; safe to run multiple times.
ALTER TYPE collaborator_type ADD VALUE IF NOT EXISTS 'KOL';

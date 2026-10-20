-- Migration / Cleanup script: Reduce excess seed users in PostgreSQL from ~500 to ~30 users.
-- Date: 18/10/2026
-- Backup reference: backup_before_seed_reduction_20261018.sql
--
-- Preserved accounts:
--  1. admin@brandhub.dev (System administrator)
--  2. winhtuan@gmail.com (Real user account)
--  3. user1@gmail.com, user59@gmail.com, user177@hotmail.com (Dev Quick Login fixtures)
--  4. user2 through user25 (Core demo users)
--  5. user91@gmail.com (Owner of preserved workspace with active hashtag)
-- Total preserved: 30 users.

BEGIN;

-- 1. Identify preserved users
CREATE TEMP TABLE preserved_users ON COMMIT DROP AS
SELECT id, email FROM users
WHERE email IN (
  'admin@brandhub.dev',
  'winhtuan@gmail.com',
  'user1@gmail.com',
  'user59@gmail.com',
  'user177@hotmail.com',
  'user91@gmail.com'
) OR email ~ '^user([1-9]|1[0-9]|2[0-5])@';

-- 2. Identify target excess users
CREATE TEMP TABLE target_users ON COMMIT DROP AS
SELECT id, email FROM users
WHERE id NOT IN (SELECT id FROM preserved_users);

-- 3. Identify target agencies and workspaces to remove
CREATE TEMP TABLE target_agencies ON COMMIT DROP AS
SELECT id FROM agencies 
WHERE owner_id IN (SELECT id FROM target_users);

CREATE TEMP TABLE target_workspaces ON COMMIT DROP AS
SELECT id FROM workspaces 
WHERE agency_id IN (SELECT id FROM target_agencies)
   OR (created_by IN (SELECT id FROM target_users) AND id NOT IN (SELECT workspace_id FROM workspace_hashtags));

DO $$
DECLARE
  v_users_to_delete INT;
  v_users_to_keep INT;
  v_agencies_to_delete INT;
  v_workspaces_to_delete INT;
BEGIN
  SELECT count(*) INTO v_users_to_delete FROM target_users;
  SELECT count(*) INTO v_users_to_keep FROM preserved_users;
  SELECT count(*) INTO v_agencies_to_delete FROM target_agencies;
  SELECT count(*) INTO v_workspaces_to_delete FROM target_workspaces;
  
  RAISE NOTICE 'Preserved users: %, Excess users to delete: %', v_users_to_keep, v_users_to_delete;
  RAISE NOTICE 'Target agencies: %, Target workspaces: %', v_agencies_to_delete, v_workspaces_to_delete;
END $$;

-- Clean child records of target workspaces
DELETE FROM workspace_media_packages WHERE workspace_id IN (SELECT id FROM target_workspaces);
DELETE FROM workspace_invitations WHERE workspace_id IN (SELECT id FROM target_workspaces);
DELETE FROM workspace_members WHERE workspace_id IN (SELECT id FROM target_workspaces) OR user_id IN (SELECT id FROM target_users) OR client_profile_id IN (SELECT id FROM client_profiles WHERE user_id IN (SELECT id FROM target_users));
DELETE FROM workspace_templates WHERE source_workspace_id IN (SELECT id FROM target_workspaces) OR agency_id IN (SELECT id FROM target_agencies) OR created_by IN (SELECT id FROM target_users);
DELETE FROM workspaces WHERE id IN (SELECT id FROM target_workspaces);

-- Clean child records of target agencies
DELETE FROM agency_invitations WHERE agency_id IN (SELECT id FROM target_agencies) OR invited_by IN (SELECT id FROM target_users);
DELETE FROM agency_members WHERE agency_id IN (SELECT id FROM target_agencies) OR user_id IN (SELECT id FROM target_users);
DELETE FROM third_party_collaborators WHERE agency_id IN (SELECT id FROM target_agencies) OR created_by IN (SELECT id FROM target_users);
DELETE FROM agencies WHERE id IN (SELECT id FROM target_agencies);

-- Clean client profiles belonging to target users
DELETE FROM client_profiles WHERE user_id IN (SELECT id FROM target_users);

-- Clean user personal child records
DELETE FROM user_oauth_providers WHERE user_id IN (SELECT id FROM target_users);
DELETE FROM user_refresh_tokens WHERE user_id IN (SELECT id FROM target_users);
DELETE FROM user_system_roles WHERE user_id IN (SELECT id FROM target_users);
DELETE FROM transactions WHERE user_id IN (SELECT id FROM target_users);
DELETE FROM user_subscriptions WHERE user_id IN (SELECT id FROM target_users);
DELETE FROM ai_credit_creator_limits WHERE creator_id IN (SELECT id FROM target_users) OR set_by IN (SELECT id FROM target_users);
DELETE FROM user_notifications WHERE user_id IN (SELECT id FROM target_users);
DELETE FROM account_activation_tokens WHERE user_id IN (SELECT id FROM target_users) OR created_by IN (SELECT id FROM target_users);
DELETE FROM subscription_plan_changes WHERE user_id IN (SELECT id FROM target_users) OR requested_by IN (SELECT id FROM target_users);
DELETE FROM user_strikes WHERE user_id IN (SELECT id FROM target_users) OR created_by IN (SELECT id FROM target_users);
DELETE FROM sanction_reviews WHERE user_id IN (SELECT id FROM target_users) OR resolved_by IN (SELECT id FROM target_users);

-- Delete target users
DELETE FROM users WHERE id IN (SELECT id FROM target_users);

DO $$
DECLARE
  v_remaining_users INT;
BEGIN
  SELECT count(*) INTO v_remaining_users FROM users;
  RAISE NOTICE 'SUCCESS: Remaining users in database after cleanup: %', v_remaining_users;
END $$;

COMMIT;

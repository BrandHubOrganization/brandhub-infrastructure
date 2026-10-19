-- Migration: 2026-10-18-link-real-user-to-3-agencies.sql
-- Goal: Link real user (winhtuan@gmail.com) to 3 agencies as CLIENT

-- 1. Ensure enum agency_member_role includes 'CLIENT'
ALTER TYPE agency_member_role ADD VALUE IF NOT EXISTS 'CLIENT';

-- 2. Link real user winhtuan@gmail.com to 3 agencies with role 'CLIENT'
DO $$
DECLARE
    v_user_id UUID;
    v_agency_id UUID;
    v_count INT := 0;
BEGIN
    -- Find real user ID
    SELECT id INTO v_user_id FROM users WHERE LOWER(email) = 'winhtuan@gmail.com';
    IF v_user_id IS NULL THEN
        RAISE NOTICE 'Real user winhtuan@gmail.com not found in users table.';
        RETURN;
    END IF;

    -- Link up to 3 agencies (prioritize Demo Agency, Saatchi & Saatchi, AIM Academy)
    FOR v_agency_id IN 
        SELECT id FROM agencies 
        WHERE status != 'SOFT_DELETED'
        ORDER BY 
            CASE 
                WHEN name LIKE 'Demo Agency%' THEN 1
                WHEN name LIKE 'Saatchi & Saatchi%' THEN 2
                WHEN name LIKE 'AIM Academy%' THEN 3
                ELSE 4
            END,
            created_at ASC
        LIMIT 3
    LOOP
        INSERT INTO agency_members (agency_id, user_id, role, joined_at)
        VALUES (v_agency_id, v_user_id, 'CLIENT'::agency_member_role, now())
        ON CONFLICT (agency_id, user_id) 
        DO UPDATE SET role = 'CLIENT'::agency_member_role;

        v_count := v_count + 1;
    END LOOP;

    RAISE NOTICE 'Linked real user % to % agencies as CLIENT.', v_user_id, v_count;
END $$;

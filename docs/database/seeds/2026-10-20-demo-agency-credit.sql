-- LOCAL DEVELOPMENT ONLY. Explicitly authorized by the product owner on 2026-10-20.
-- Run after Credit configuration/accounting/AI execution/DEV_SEED-source migrations.
-- Never include this script in production init or a recursive migration runner.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';
DO $$
DECLARE
    target_agency UUID := '23dc3d67-4c4b-4a0a-8b91-da5968dbbbb9';
    target_owner UUID := '34b1e1b9-dc72-44c2-b2bd-e7dcc9186bc6';
    seed_key TEXT := 'DEV_SEED:demo-agency:2026-10-20:100';
BEGIN
    PERFORM 1 FROM agencies a JOIN users u ON u.id=a.owner_id
        WHERE a.id=target_agency AND a.owner_id=target_owner AND a.name='Demo Agency'
            AND u.email='user177@hotmail.com' AND a.status='ACTIVE' AND a.deleted_at IS NULL
        FOR UPDATE OF a;
    IF NOT FOUND THEN RAISE EXCEPTION 'Expected local development Agency/Owner not found; no writes'; END IF;
    INSERT INTO ai_credit_grants(agency_id,source_key,kind,amount)
        VALUES(target_agency,seed_key,'DEV_SEED',100) ON CONFLICT(source_key) DO NOTHING;
    PERFORM 1 FROM ai_credit_grants WHERE source_key=seed_key AND agency_id=target_agency
        AND kind='DEV_SEED' AND amount=100 AND subscription_id IS NULL AND transaction_id IS NULL;
    IF NOT FOUND THEN RAISE EXCEPTION 'Seed source conflicts with existing data; rollback'; END IF;
    UPDATE agencies SET credit_cycle_anchor=COALESCE(credit_cycle_anchor,now()) WHERE id=target_agency;
END;
$$;
COMMIT;
SELECT a.name,g.source_key,g.kind,g.amount,g.used,g.held,g.amount-g.used-g.held AS available
FROM ai_credit_grants g JOIN agencies a ON a.id=g.agency_id
WHERE g.source_key='DEV_SEED:demo-agency:2026-10-20:100';

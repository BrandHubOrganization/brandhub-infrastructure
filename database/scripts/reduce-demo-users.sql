-- Reduce demo data to 30 users while keeping 5 key accounts and everything linked to them.
-- Kept: the 5 accounts, every owner/member of their agencies and workspaces,
-- then users without any agency filled up to 30 (oldest first).
-- Other agencies/workspaces and all rows that depended on removed rows are deleted;
-- nullable SET NULL references are cleared instead.
-- Requires a superuser (session_replication_role bypasses FK/immutability triggers).
\set ON_ERROR_STOP on
BEGIN;

CREATE TEMP TABLE k5 AS
SELECT id FROM users WHERE email IN (
  'admin@demo.brandhub.test',
  'user177@demo.brandhub.test',
  'user1@demo.brandhub.test',
  'user13@demo.brandhub.test',
  'user59@demo.brandhub.test');

DO $$ BEGIN
  IF (SELECT count(*) FROM k5) <> 5 THEN RAISE EXCEPTION 'expected 5 key accounts, found %', (SELECT count(*) FROM k5); END IF;
END $$;

CREATE TEMP TABLE keep_agencies AS
SELECT id FROM agencies WHERE owner_id IN (SELECT id FROM k5)
UNION SELECT agency_id FROM agency_members WHERE user_id IN (SELECT id FROM k5);

CREATE TEMP TABLE keep_users AS
SELECT id FROM k5
UNION SELECT owner_id FROM agencies WHERE id IN (SELECT id FROM keep_agencies)
UNION SELECT user_id FROM agency_members WHERE agency_id IN (SELECT id FROM keep_agencies)
UNION SELECT user_id FROM workspace_members
      WHERE workspace_id IN (SELECT id FROM workspaces WHERE agency_id IN (SELECT id FROM keep_agencies));

INSERT INTO keep_users
SELECT u.id FROM users u
WHERE u.id NOT IN (SELECT id FROM keep_users)
  AND NOT EXISTS (SELECT 1 FROM agency_members m WHERE m.user_id = u.id)
  AND NOT EXISTS (SELECT 1 FROM agencies g WHERE g.owner_id = u.id)
  AND NOT EXISTS (SELECT 1 FROM workspace_members w WHERE w.user_id = u.id)
ORDER BY u.created_at, u.email
LIMIT GREATEST(0, 30 - (SELECT count(*) FROM keep_users));

SET LOCAL session_replication_role = replica;

DELETE FROM users WHERE id NOT IN (SELECT id FROM keep_users);
DELETE FROM agencies WHERE id NOT IN (SELECT id FROM keep_agencies);

-- Cascade by hand: repeat until no FK points at a missing row.
DO $$
DECLARE
  fk record; cond text; total bigint; n bigint; pass int := 0;
BEGIN
  LOOP
    pass := pass + 1; total := 0;
    FOR fk IN
      SELECT c.conrelid::regclass AS child, c.confrelid::regclass AS parent, c.confdeltype AS act,
             array_agg(quote_ident(ca.attname) ORDER BY k.ord) AS ccols,
             array_agg(quote_ident(pa.attname) ORDER BY k.ord) AS pcols,
             bool_and(NOT ca.attnotnull) AS nullable
      FROM pg_constraint c
      CROSS JOIN LATERAL unnest(c.conkey, c.confkey) WITH ORDINALITY AS k(ck, pk, ord)
      JOIN pg_attribute ca ON ca.attrelid = c.conrelid AND ca.attnum = k.ck
      JOIN pg_attribute pa ON pa.attrelid = c.confrelid AND pa.attnum = k.pk
      WHERE c.contype = 'f' AND c.connamespace = 'public'::regnamespace
      GROUP BY c.oid, c.conrelid, c.confrelid, c.confdeltype
    LOOP
      SELECT string_agg(format('p.%s = t.%s', fk.pcols[i], fk.ccols[i]), ' AND ')
             || ' ) AND ' || string_agg(format('t.%s IS NOT NULL', fk.ccols[i]), ' AND ')
        INTO cond FROM generate_subscripts(fk.ccols, 1) i;
      cond := format('NOT EXISTS (SELECT 1 FROM %s p WHERE ', fk.parent) || cond;
      IF fk.act = 'n' AND fk.nullable THEN
        EXECUTE format('UPDATE %s t SET %s WHERE %s', fk.child,
          (SELECT string_agg(format('%s = NULL', c), ', ') FROM unnest(fk.ccols) c), cond);
      ELSE
        EXECUTE format('DELETE FROM %s t WHERE %s', fk.child, cond);
      END IF;
      GET DIAGNOSTICS n = ROW_COUNT; total := total + n;
    END LOOP;
    RAISE NOTICE 'pass %: % rows removed or cleared', pass, total;
    EXIT WHEN total = 0 OR pass > 20;
  END LOOP;
  IF total <> 0 THEN RAISE EXCEPTION 'orphan cleanup did not converge'; END IF;
END $$;

SET LOCAL session_replication_role = origin;

SELECT 'users=' || count(*) FROM users;
SELECT 'agencies=' || count(*) FROM agencies;
SELECT 'workspaces=' || count(*) FROM workspaces;
SELECT 'key accounts kept=' || count(*) FROM users WHERE id IN (SELECT id FROM k5);

COMMIT;

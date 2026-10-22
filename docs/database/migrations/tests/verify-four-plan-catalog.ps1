# Runs only against a disposable PostgreSQL 17 container; no host ports or runtime DB credentials.
$ErrorActionPreference = 'Stop'
$migrationRoot = Split-Path $PSScriptRoot -Parent
$containerName = 'brandhub-catalog-test-' + [guid]::NewGuid().ToString('N').Substring(0, 10)

function Invoke-CatalogSql {
    param([string]$Sql, [string]$Database = 'catalog_test', [switch]$ExpectFailure)
    $result = $Sql | docker exec -i $containerName psql -X -q -A -t -v ON_ERROR_STOP=1 -U postgres -d $Database 2>&1
    $succeeded = $LASTEXITCODE -eq 0
    if ($ExpectFailure) {
        if ($succeeded) { throw 'Expected SQL failure, but execution succeeded' }
    } elseif (-not $succeeded) {
        throw ($result -join "`n")
    }
    return ($result -join "`n").Trim()
}

try {
    docker run --rm -d --network none --name $containerName -e POSTGRES_HOST_AUTH_METHOD=trust postgres:17-alpine | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Cannot start disposable PostgreSQL 17' }
    $ready = $false
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        docker exec $containerName pg_isready -U postgres 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $ready = $true; break }
        Start-Sleep -Milliseconds 500
    }
    if (-not $ready) { throw 'PostgreSQL startup timed out' }
    docker exec $containerName createdb -U postgres catalog_test
    if ($LASTEXITCODE -ne 0) { throw 'Cannot create isolated database' }
    docker exec $containerName createdb -U postgres catalog_missing
    if ($LASTEXITCODE -ne 0) { throw 'Cannot create prerequisite test database' }

    # Retain all real schema objects and constraints, but never import exported user rows.
    $export = Get-Content (Join-Path $migrationRoot 'brandhub-export.sql') -Raw
    $schemaOnly = [regex]::Replace($export, '(?ms)^COPY [^\r\n]+ FROM stdin;\r?\n.*?^\\\.\r?$', '')
    $schemaOnly = [regex]::Replace($schemaOnly, '(?m)^\\(?:un)?restrict[^\r\n]*\r?$', '')
    $schemaOnly = [regex]::Replace($schemaOnly, '(?m)^SELECT pg_catalog\.setval\([^\r\n]*\r?$', '')
    if ($schemaOnly -match '(?m)^COPY |^INSERT INTO ') { throw 'Unsafe fixture: exported row statements remain' }
    Invoke-CatalogSql $schemaOnly | Out-Null
    Invoke-CatalogSql (Get-Content (Join-Path $migrationRoot '2026-10-20-agency-subscription-expand.sql') -Raw) | Out-Null

    # Represent a configured, sellable paid version to prove history is preserved.
    Invoke-CatalogSql @'
INSERT INTO billing_plan_versions (
 code,version,display_name,price_monthly,max_active_workspaces,max_internal_members,max_clients,
 storage_limit_bytes,monthly_ai_credits,max_concurrent_ai_jobs,version_retention_days,trash_retention_days,activity_retention_days,is_sellable
) SELECT code,2,display_name,99000,max_active_workspaces,max_internal_members,max_clients,
 storage_limit_bytes,monthly_ai_credits,max_concurrent_ai_jobs,version_retention_days,trash_retention_days,activity_retention_days,true
FROM billing_plan_versions WHERE code='PLUS' AND version=1;
INSERT INTO users(id,email,full_name) VALUES ('00000000-0000-0000-0000-000000000001','catalog-test@example.invalid','Catalog Test');
INSERT INTO agencies(id,name,owner_id) VALUES ('00000000-0000-0000-0000-000000000002','Synthetic Agency','00000000-0000-0000-0000-000000000001');
INSERT INTO agency_subscriptions(id,agency_id,plan_version_id)
 SELECT '00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000002',id FROM billing_plan_versions WHERE code='BASIC' AND version=1;
INSERT INTO billing_orders(id,agency_id,payer_user_id,kind,idempotency_key,payload_hash,amount,product_snapshot,plan_version_id,expires_at)
 SELECT '00000000-0000-0000-0000-000000000004','00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000001',
 'SUBSCRIPTION','synthetic-order',repeat('a',64),1,'{}',id,now()+interval '1 hour'
 FROM billing_plan_versions WHERE code='BASIC' AND version=1;
INSERT INTO agency_subscription_periods(agency_id,subscription_id,plan_version_id,order_id,starts_at,ends_at,status)
 SELECT '00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003',id,
 '00000000-0000-0000-0000-000000000004',now(),now()+interval '1 month','CURRENT'
 FROM billing_plan_versions WHERE code='BASIC' AND version=1;
'@ | Out-Null
    $snapshotSql = "SELECT jsonb_agg(to_jsonb(p)-'billing_scope' ORDER BY code,version)::text FROM billing_plan_versions p WHERE code<>'PERSONAL';"
    $before = Invoke-CatalogSql $snapshotSql
    $migration = Get-Content (Join-Path $migrationRoot '2026-10-20-four-plan-catalog.sql') -Raw
    docker exec $containerName createdb -U postgres -T catalog_test catalog_rollback
    if ($LASTEXITCODE -ne 0) { throw 'Cannot create atomic rollback test database' }
    $registryInsert = 'INSERT INTO brandhub_schema_migrations (version, description) VALUES ('
    $brokenMigration = $migration.Replace($registryInsert,
        'DO $$ BEGIN RAISE EXCEPTION ''Injected migration failure''; END $$;' + "`n" + $registryInsert)
    $rollbackError = Invoke-CatalogSql -Sql $brokenMigration -Database 'catalog_rollback' -ExpectFailure
    if ($rollbackError -notmatch 'Injected migration failure') { throw 'Wrong injected-failure error' }
    $rollbackCheck = @'
SELECT NOT EXISTS (SELECT 1 FROM billing_plan_versions WHERE code='PERSONAL')
 AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='billing_plan_versions' AND column_name='billing_scope')
 AND NOT EXISTS (SELECT 1 FROM brandhub_schema_migrations WHERE version='20261020_four_plan_catalog_v1');
'@
    if ((Invoke-CatalogSql -Sql $rollbackCheck -Database 'catalog_rollback') -ne 't') { throw 'Migration failure left partial DDL or data' }
    if ($before -cne (Invoke-CatalogSql -Sql $snapshotSql -Database 'catalog_rollback')) { throw 'Rollback changed existing plan versions' }
    Invoke-CatalogSql $migration | Out-Null
    if ($before -cne (Invoke-CatalogSql $snapshotSql)) { throw 'Existing plan rows were changed' }
    $replayBefore = Invoke-CatalogSql 'SELECT jsonb_agg(to_jsonb(p) ORDER BY code,version)::text FROM billing_plan_versions p;'
    Invoke-CatalogSql $migration | Out-Null
    if ($replayBefore -cne (Invoke-CatalogSql 'SELECT jsonb_agg(to_jsonb(p) ORDER BY code,version)::text FROM billing_plan_versions p;')) { throw 'Replay changed the catalog' }

    Invoke-CatalogSql @'
DO $$
DECLARE personal uuid; agency_plan uuid; target text;
BEGIN
 IF (SELECT count(*) FROM billing_plan_versions WHERE version=1) <> 4 THEN RAISE EXCEPTION 'Expected four v1 plans'; END IF;
 IF (SELECT count(*) FROM billing_plan_versions WHERE version=1 AND billing_scope='AGENCY') <> 3 THEN RAISE EXCEPTION 'Expected three Agency plans'; END IF;
 SELECT id INTO personal FROM billing_plan_versions WHERE code='PERSONAL' AND version=1 AND billing_scope='USER'
   AND price_monthly IS NULL AND NOT is_sellable AND max_active_workspaces=0 AND max_clients=0
   AND storage_limit_bytes=20000000000 AND monthly_ai_credits=1000
   AND features->>'max_personal_spaces'='1';
 IF personal IS NULL THEN RAISE EXCEPTION 'Personal catalog mismatch'; END IF;
 SELECT id INTO agency_plan FROM billing_plan_versions WHERE code='PLUS' AND version=1;
 FOREACH target IN ARRAY ARRAY['agency_subscriptions','billing_orders','agency_subscription_periods'] LOOP
   BEGIN
     EXECUTE format('UPDATE %I SET plan_version_id=$1',target) USING personal;
     RAISE EXCEPTION 'Personal accepted by %',target;
   EXCEPTION WHEN foreign_key_violation THEN NULL;
   END;
   EXECUTE format('UPDATE %I SET plan_version_id=$1',target) USING agency_plan;
   BEGIN
     EXECUTE format('UPDATE %I SET plan_billing_scope=''USER''',target);
     RAISE EXCEPTION 'Agency scope bypass accepted by %',target;
   EXCEPTION WHEN check_violation THEN NULL;
   END;
 END LOOP;
 BEGIN
   UPDATE billing_plan_versions SET monthly_ai_credits=monthly_ai_credits+1 WHERE id=personal;
   RAISE EXCEPTION 'Immutable plan mutation succeeded';
 EXCEPTION WHEN check_violation THEN NULL;
 END;
 UPDATE billing_plan_versions SET is_sellable=false WHERE code='BASIC';
 UPDATE billing_plan_versions SET is_sellable=true WHERE code='BASIC';
 IF (SELECT count(*) FROM brandhub_schema_migrations WHERE version='20261020_four_plan_catalog_v1') <> 1 THEN RAISE EXCEPTION 'Migration registry mismatch'; END IF;
END $$;
'@ | Out-Null
    $missing = Invoke-CatalogSql -Sql $migration -Database 'catalog_missing' -ExpectFailure
    if ($missing -notmatch 'Apply 2026-10-20-agency-subscription-expand.sql first') { throw 'Wrong missing-prerequisite error' }
    if ((Invoke-CatalogSql -Sql "SELECT to_regclass('public.billing_plan_versions') IS NULL AND to_regclass('public.brandhub_schema_migrations') IS NULL;" -Database 'catalog_missing') -ne 't') { throw 'Prerequisite failure left schema changes' }
    Write-Output 'PASS: full schema migration, four products, replay, preserved terms, USER/AGENCY FKs, immutable versions, missing prerequisites, atomic DDL/data rollback.'
} finally {
    docker rm -f $containerName 2>&1 | Out-Null
}

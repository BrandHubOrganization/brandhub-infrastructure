param([switch]$Apply)
$ErrorActionPreference = 'Stop'
$migration = Join-Path $PSScriptRoot '../docs/database/migrations/2026-10-24-repository-foundation.sql'
if (-not (Test-Path -LiteralPath $migration)) { throw 'Repository migration file is missing' }
if (-not $Apply) {
    Write-Output 'DRY_RUN: adds repository usage/reservations/ledger/pool tables; BASIC total becomes 20 GiB.'
    Write-Output 'Existing agencies remain inventory-unverified. No database connection or write performed.'
    return
}
if ($env:REPOSITORY_MIGRATION_APPROVED -ne 'true' -or $env:REPOSITORY_WRITERS_PAUSED -ne 'true') {
    throw 'APPLY requires reviewed backup, approval and paused writers flags'
}
if (-not $env:PGDATABASE -or -not $env:PGHOST -or -not $env:PGUSER) {
    throw 'Set PGDATABASE, PGHOST and PGUSER explicitly; credentials use standard psql environment'
}
& psql -X -v ON_ERROR_STOP=1 -f $migration
if ($LASTEXITCODE -ne 0) { throw 'Repository migration failed; inspect psql diagnostics' }

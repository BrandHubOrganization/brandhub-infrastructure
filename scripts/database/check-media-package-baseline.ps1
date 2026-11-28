param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'
$packageInitPath = Join-Path $RepoRoot 'database/init/init-postgres-v2.sql'
if (-not (Test-Path -LiteralPath $packageInitPath)) {
    throw "Canonical PostgreSQL init baseline not found: $packageInitPath"
}

$packageInitSql = Get-Content -Raw -Encoding UTF8 -LiteralPath $packageInitPath
$packageTable = [regex]::Match($packageInitSql,
    '(?s)CREATE TABLE IF NOT EXISTS media_packages\s*\((.*?)\n\);')
if (-not $packageTable.Success) {
    throw 'Canonical media_packages table definition not found.'
}
if ($packageTable.Groups[1].Value -match '(?m)^\s*(package_type|offering_model)\s+' -or
    $packageInitSql -match '(?i)CREATE\s+TYPE\s+package_type\b') {
    throw 'Retired Media Package classification found in fresh baseline.'
}
if ($packageTable.Groups[1].Value -notmatch '(?m)^\s*offering_details\s+JSONB\b') {
    throw 'Current service details missing from Media Package baseline.'
}

foreach ($packageRetiredPath in @(
    'docs/database/init-postgres-v2.sql',
    'scripts/init-postgres-v2.sql',
    'docs/database/seeds/2026-10-07-refresh-admin-media-templates.sql',
    'docs/database/migrations/2026-10-06-media-package-offering-model.sql'
)) {
    if (Test-Path -LiteralPath (Join-Path $RepoRoot $packageRetiredPath)) {
        throw "Retired active entry point restored: $packageRetiredPath"
    }
}

Write-Output 'PASS: canonical Media Package baseline; retired fields/enum/active seed absent.'

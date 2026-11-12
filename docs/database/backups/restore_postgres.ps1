<#
.SYNOPSIS
    Thay thế toàn bộ PostgreSQL database cũ bằng bản backup mới nhất (Schema + Data).

.DESCRIPTION
    Script tự động:
    1. Tìm file backup mới nhất (brandhub_postgres_full_*.sql hoặc *.dump) trong thư mục backups.
    2. Đảm bảo database đích tồn tại, ngắt các kết nối đang mở tới database (tránh lỗi lock).
    3. Xóa sạch schema `public` cũ (DROP SCHEMA public CASCADE) và tạo lại schema mới.
    4. Nạp toàn bộ Schema + Data từ bản backup vào container Docker `brandhub-postgres` (hoặc PostgreSQL local).
    5. Kiểm tra số lượng bảng và phiên bản migration sau khi khôi phục.

.EXAMPLE
    .\restore_postgres.ps1
    .\restore_postgres.ps1 -Force
    .\restore_postgres.ps1 -BackupFile "brandhub_postgres_full_20261112.sql"
#>

param(
    [string]$ContainerName = $(if ($env:POSTGRES_CONTAINER) { $env:POSTGRES_CONTAINER } else { "brandhub-postgres" }),
    [string]$DbUser        = $(if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "brandhub" }),
    [string]$DbPassword    = $(if ($env:POSTGRES_PASSWORD) { $env:POSTGRES_PASSWORD } else { "root" }),
    [string]$DbName        = $(if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "brandhub" }),
    [string]$DbHost        = $(if ($env:POSTGRES_HOST) { $env:POSTGRES_HOST } else { "localhost" }),
    [int]$DbPort           = $(if ($env:POSTGRES_PORT) { [int]$env:POSTGRES_PORT } else { 5432 }),
    [string]$BackupFile    = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Assert-LastExitCode([string]$StepName) {
    if ($LASTEXITCODE -ne 0) {
        throw "Bước '$StepName' thất bại với mã lỗi $LASTEXITCODE."
    }
}

# 1. Xác định file backup
if ([string]::IsNullOrWhiteSpace($BackupFile)) {
    $LatestSql = Get-ChildItem -Path $ScriptDir -Filter "brandhub_postgres_full_*.sql" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    $LatestDump = Get-ChildItem -Path $ScriptDir -Filter "brandhub_postgres_full_*.dump" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($LatestSql) {
        $BackupPath = $LatestSql.FullName
    } elseif ($LatestDump) {
        $BackupPath = $LatestDump.FullName
    } else {
        Write-Error "Không tìm thấy file backup (brandhub_postgres_full_*.sql hoặc *.dump) trong $ScriptDir"
        exit 1
    }
} else {
    $BackupPath = if ([System.IO.Path]::IsPathRooted($BackupFile)) {
        $BackupFile
    } else {
        Join-Path $ScriptDir $BackupFile
    }
    if (-not (Test-Path $BackupPath)) {
        Write-Error "File backup không tồn tại: $BackupPath"
        exit 1
    }
}

$FileName = Split-Path -Leaf $BackupPath
$IsCustomDump = $BackupPath.EndsWith(".dump", [System.StringComparison]::OrdinalIgnoreCase)

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " BrandHub PostgreSQL Full Restore (Replace Existing DB)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Backup file : $FileName"
Write-Host " Target DB   : $DbName (User: $DbUser)"
Write-Host " Container   : $ContainerName"
Write-Host "============================================================" -ForegroundColor Cyan

if (-not $Force) {
    $Confirm = Read-Host "CẢNH BÁO: Toàn bộ dữ liệu PostgreSQL cũ trong '$DbName' sẽ bị XÓA và thay thế. Tiếp tục? (y/N)"
    if ($Confirm -notmatch "^[yY](es)?$") {
        Write-Host "Đã hủy thao tác khôi phục." -ForegroundColor Yellow
        exit 0
    }
}

# 2. Kiểm tra Docker container có đang chạy không
$UseDocker = $false
if (Get-Command docker -ErrorAction SilentlyContinue) {
    $RunningContainer = docker ps --filter "name=^/${ContainerName}$" --format "{{.Names}}" 2>$null
    if ($RunningContainer -eq $ContainerName) {
        $UseDocker = $true
    }
}

$ResetSql = @"
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = '$DbName'
  AND pid <> pg_backend_pid();

DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO "$DbUser";
GRANT ALL ON SCHEMA public TO public;
"@

if ($UseDocker) {
    Write-Host "[1/4] Đang ngắt các kết nối cũ và làm sạch schema 'public' trên container '$ContainerName'..." -ForegroundColor Yellow
    $DbExists = (docker exec -e PGPASSWORD=$DbPassword $ContainerName psql -U $DbUser -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DbName';") -join ""
    if ($DbExists.Trim() -ne "1") {
        docker exec -e PGPASSWORD=$DbPassword $ContainerName psql -U $DbUser -d postgres -c "CREATE DATABASE `"$DbName`" OWNER `"$DbUser`";" | Out-Null
        Assert-LastExitCode "Create Database"
    }

    $ResetSql | docker exec -i -e PGPASSWORD=$DbPassword $ContainerName psql -v ON_ERROR_STOP=1 -U $DbUser -d $DbName | Out-Null
    Assert-LastExitCode "Reset Schema"

    $ContainerTmpPath = "/tmp/$FileName"
    Write-Host "[2/4] Đang copy bản backup vào container..." -ForegroundColor Yellow
    docker cp $BackupPath "${ContainerName}:${ContainerTmpPath}"
    Assert-LastExitCode "Docker Copy"

    try {
        Write-Host "[3/4] Đang nạp Schema + Data từ '$FileName'..." -ForegroundColor Yellow
        if ($IsCustomDump) {
            docker exec -e PGPASSWORD=$DbPassword $ContainerName pg_restore -U $DbUser -d $DbName --no-owner --no-privileges --exit-on-error $ContainerTmpPath
            Assert-LastExitCode "pg_restore"
        } else {
            docker exec -e PGPASSWORD=$DbPassword $ContainerName psql -v ON_ERROR_STOP=1 -U $DbUser -d $DbName -f $ContainerTmpPath | Out-Null
            Assert-LastExitCode "psql restore"
        }
    } finally {
        docker exec $ContainerName rm -f $ContainerTmpPath 2>$null | Out-Null
    }

    Write-Host "[4/4] Đang kiểm tra kết quả sau khi khôi phục..." -ForegroundColor Yellow
    docker exec -e PGPASSWORD=$DbPassword $ContainerName psql -U $DbUser -d $DbName -c "SELECT count(*) AS total_tables FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';"
    Assert-LastExitCode "Verify Tables"
    docker exec -e PGPASSWORD=$DbPassword $ContainerName psql -U $DbUser -d $DbName -c "SELECT version, applied_at FROM brandhub_schema_migrations ORDER BY applied_at DESC LIMIT 5;"
    Assert-LastExitCode "Verify Migrations"
} else {
    if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
        Write-Error "Container '$ContainerName' không chạy và máy không cài sẵn 'psql'. Hãy bật Docker container '$ContainerName' trước."
        exit 1
    }

    $env:PGPASSWORD = $DbPassword
    Write-Host "[1/3] Đang ngắt các kết nối cũ và làm sạch schema 'public' trên $DbHost`:$DbPort..." -ForegroundColor Yellow
    $DbExists = (psql -h $DbHost -p $DbPort -U $DbUser -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DbName';") -join ""
    if ($DbExists.Trim() -ne "1") {
        psql -h $DbHost -p $DbPort -U $DbUser -d postgres -c "CREATE DATABASE `"$DbName`" OWNER `"$DbUser`";" | Out-Null
        Assert-LastExitCode "Create Database"
    }

    $ResetSql | psql -v ON_ERROR_STOP=1 -h $DbHost -p $DbPort -U $DbUser -d $DbName | Out-Null
    Assert-LastExitCode "Reset Schema"

    Write-Host "[2/3] Đang nạp Schema + Data từ '$FileName'..." -ForegroundColor Yellow
    if ($IsCustomDump) {
        pg_restore -h $DbHost -p $DbPort -U $DbUser -d $DbName --no-owner --no-privileges --exit-on-error $BackupPath
        Assert-LastExitCode "pg_restore"
    } else {
        psql -v ON_ERROR_STOP=1 -h $DbHost -p $DbPort -U $DbUser -d $DbName -f $BackupPath | Out-Null
        Assert-LastExitCode "psql restore"
    }

    Write-Host "[3/3] Đang kiểm tra kết quả sau khi khôi phục..." -ForegroundColor Yellow
    psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -c "SELECT count(*) AS total_tables FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';"
    Assert-LastExitCode "Verify Tables"
    psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -c "SELECT version, applied_at FROM brandhub_schema_migrations ORDER BY applied_at DESC LIMIT 5;"
    Assert-LastExitCode "Verify Migrations"
}

Write-Host "============================================================" -ForegroundColor Green
Write-Host " [OK] Đã thay thế thành công database '$DbName' bằng bản backup '$FileName'!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green

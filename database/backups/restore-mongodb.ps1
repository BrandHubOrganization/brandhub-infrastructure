<#
.SYNOPSIS
    Thêm/khởi động container MongoDB (brandhub-mongodb) trong project brandhub và nạp file backup .ejson.

.DESCRIPTION
    Script tự động:
    1. Xác định file backup .ejson (mặc định brandhub_mongodb_full_20261123.ejson hoặc bản mới nhất).
    2. Kiểm tra Docker và đảm bảo container `brandhub-mongodb` đang chạy trong Docker Compose `brandhub`.
       Nếu chưa có/chưa chạy, tự động chạy `docker compose -p brandhub ... up -d mongodb` (hoặc tạo container trên `brandhub-network`).
    3. Đợi MongoDB sẵn sàng nhận kết nối.
    4. Nạp toàn bộ collections, $jsonSchema validators, indexes và documents từ file .ejson vào database đích bằng mongosh trong container (không cần cài Python/pymongo trên máy).

.EXAMPLE
    .\restore-mongodb.ps1
    .\restore-mongodb.ps1 -Force
    .\restore-mongodb.ps1 -BackupFile "brandhub_mongodb_full_20261123.ejson" -Force
#>

param(
    [string]$ContainerName = $(if ($env:MONGODB_CONTAINER) { $env:MONGODB_CONTAINER } else { "brandhub-mongodb" }),
    [string]$DbName        = $(if ($env:MONGODB_DATABASE) { $env:MONGODB_DATABASE } else { "brandhub" }),
    [int]$HostPort         = $(if ($env:MONGODB_HOST_PORT) { [int]$env:MONGODB_HOST_PORT } else { 27017 }),
    [string]$BackupFile    = "brandhub_mongodb_full_20261123.ejson",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Assert-LastExitCode([string]$StepName) {
    if ($LASTEXITCODE -ne 0) {
        throw "Bước '$StepName' thất bại với mã lỗi $LASTEXITCODE."
    }
}

# 1. Xác định file backup .ejson
$BackupPath = $null
if (-not [string]::IsNullOrWhiteSpace($BackupFile)) {
    $Candidate = if ([System.IO.Path]::IsPathRooted($BackupFile)) {
        $BackupFile
    } else {
        Join-Path $ScriptDir $BackupFile
    }
    if (Test-Path $Candidate) {
        $BackupPath = (Resolve-Path $Candidate).Path
    } elseif ($BackupFile -ne "brandhub_mongodb_full_20261123.ejson") {
        Write-Error "File backup không tồn tại: $Candidate"
        exit 1
    }
}

if (-not $BackupPath) {
    $LatestEjson = Get-ChildItem -Path $ScriptDir -Filter "brandhub_mongodb_full_*.ejson" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($LatestEjson) {
        $BackupPath = $LatestEjson.FullName
    } else {
        Write-Error "Không tìm thấy file backup brandhub_mongodb_full_*.ejson trong $ScriptDir"
        exit 1
    }
}

$FileName = Split-Path -Leaf $BackupPath

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " BrandHub MongoDB Setup & Full Restore (.ejson)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Backup file : $FileName"
Write-Host " Target DB   : $DbName"
Write-Host " Container   : $ContainerName (Port: $HostPort)"
Write-Host "============================================================" -ForegroundColor Cyan

if (-not $Force) {
    $Confirm = Read-Host "CẢNH BÁO: Các collection trùng tên trong MongoDB '$DbName' sẽ bị XÓA và nạp lại từ '$FileName'. Tiếp tục? (y/N)"
    if ($Confirm -notmatch "^[yY](es)?$") {
        Write-Host "Đã hủy thao tác khôi phục." -ForegroundColor Yellow
        exit 0
    }
}

# 2. Kiểm tra Docker CLI và Docker Daemon
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Không tìm thấy Docker CLI. Hãy cài đặt và bật Docker Desktop trước."
    exit 1
}

docker info >$null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker Desktop chưa chạy. Hãy mở Docker Desktop rồi chạy lại script."
    exit 1
}

# 3. Đảm bảo container brandhub-mongodb được thêm vào project brandhub và đang chạy
$RunningContainer = (docker ps --filter "name=^/${ContainerName}$" --format "{{.Names}}" 2>$null) -join ""
if ($RunningContainer.Trim() -ne $ContainerName) {
    Write-Host "[1/4] Container '$ContainerName' chưa chạy. Đang thêm/khởi động MongoDB vào stack 'brandhub'..." -ForegroundColor Yellow

    $InfraRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
    $ComposeDir = Join-Path $InfraRoot "docker\compose"
    $ComposeFile = Join-Path $ComposeDir "dev\compose.yaml"
    $EnvFile = Join-Path $ComposeDir ".env"
    $EnvExample = Join-Path $ComposeDir ".env.example"

    if ((Test-Path $ComposeFile)) {
        if (-not (Test-Path $EnvFile) -and (Test-Path $EnvExample)) {
            Copy-Item -Path $EnvExample -Destination $EnvFile
            Write-Host "  Đã tạo $EnvFile từ .env.example." -ForegroundColor DarkGray
        }
        if (Test-Path $EnvFile) {
            docker compose -p brandhub --env-file $EnvFile -f $ComposeFile up -d mongodb
        }
    }

    $RunningContainer = (docker ps --filter "name=^/${ContainerName}$" --format "{{.Names}}" 2>$null) -join ""
    if ($RunningContainer.Trim() -ne $ContainerName) {
        $ExistingContainer = (docker ps -a --filter "name=^/${ContainerName}$" --format "{{.Names}}" 2>$null) -join ""
        if ($ExistingContainer.Trim() -eq $ContainerName) {
            docker start $ContainerName | Out-Null
            Assert-LastExitCode "docker start $ContainerName"
        } else {
            docker network inspect brandhub-network >$null 2>&1
            if ($LASTEXITCODE -ne 0) {
                docker network create brandhub-network | Out-Null
                Assert-LastExitCode "docker network create brandhub-network"
            }

            $InitMongoPath = Join-Path $InfraRoot "database\init\init-mongo.js"
            $RunArgs = @(
                "run", "-d",
                "--name", $ContainerName,
                "--restart", "unless-stopped",
                "--network", "brandhub-network",
                "-p", "${HostPort}:27017",
                "-e", "MONGO_INITDB_DATABASE=${DbName}",
                "-v", "brandhub-mongodb-data:/data/db"
            )
            if (Test-Path $InitMongoPath) {
                $RunArgs += @("-v", "${InitMongoPath}:/docker-entrypoint-initdb.d/init-mongo.js:ro")
            }
            $RunArgs += "mongo:7.0"

            & docker @RunArgs | Out-Null
            Assert-LastExitCode "docker run $ContainerName"
        }
    }
} else {
    Write-Host "[1/4] Container '$ContainerName' đã sẵn sàng." -ForegroundColor Green
}

# 4. Đợi MongoDB sẵn sàng
Write-Host "[2/4] Đang kiểm tra kết nối MongoDB trong '$ContainerName'..." -ForegroundColor Yellow
$Ready = $false
for ($i = 1; $i -le 30; $i++) {
    $PingResult = (docker exec $ContainerName mongosh --quiet --eval "db.adminCommand('ping').ok" 2>$null) -join ""
    if ($PingResult.Trim() -eq "1") {
        $Ready = $true
        break
    }
    Start-Sleep -Seconds 1
}
if (-not $Ready) {
    Write-Error "MongoDB trong container '$ContainerName' không phản hồi sau 30 giây."
    exit 1
}

# 5. Copy file .ejson và script restore vào container để thực thi bằng mongosh
$ContainerEjsonPath = "/tmp/$FileName"
$ContainerJsPath = "/tmp/restore_ejson.js"
$LocalTempJs = Join-Path ([System.IO.Path]::GetTempPath()) ("brandhub_restore_" + [System.Guid]::NewGuid().ToString("N") + ".js")

$JsScript = @"
const fs = require("fs");
const bundlePath = "$ContainerEjsonPath";
const targetDbName = "$DbName";

const raw = fs.readFileSync(bundlePath, "utf8");
const bundle = EJSON.parse(raw, { relaxed: false });
const targetDb = db.getSiblingDB(targetDbName);
const existingNames = new Set(targetDb.getCollectionNames());

const collections = bundle.collections || {};
const colNames = Object.keys(collections);
let totalDocs = 0;

for (const cname of colNames) {
    const cdata = collections[cname] || {};
    if (existingNames.has(cname)) {
        targetDb.getCollection(cname).drop();
    }

    const options = cdata.options || {};
    const createOpts = {};
    if (options.validator !== undefined) {
        createOpts.validator = options.validator;
    }
    if (options.validationLevel !== undefined) {
        createOpts.validationLevel = options.validationLevel;
    }
    if (options.validationAction !== undefined) {
        createOpts.validationAction = options.validationAction;
    }

    targetDb.createCollection(cname, createOpts);
    const col = targetDb.getCollection(cname);

    const docs = cdata.documents || [];
    const batchSize = 500;
    for (let i = 0; i < docs.length; i += batchSize) {
        col.insertMany(docs.slice(i, i + batchSize));
    }
    totalDocs += docs.length;

    const indexes = cdata.indexes || [];
    for (const idx of indexes) {
        if (idx.name === "_id_") {
            continue;
        }
        const idxOpts = { name: idx.name };
        for (const opt of ["unique", "sparse", "expireAfterSeconds", "partialFilterExpression"]) {
            if (idx[opt] !== undefined) {
                idxOpts[opt] = idx[opt];
            }
        }
        col.createIndex(idx.key, idxOpts);
    }

    print("[OK] Restored " + cname + ": " + docs.length + " documents, " + indexes.length + " indexes");
}

print("SUMMARY: " + colNames.length + " collections, " + totalDocs + " documents restored into '" + targetDbName + "'.");
"@

try {
    [System.IO.File]::WriteAllText($LocalTempJs, $JsScript, (New-Object System.Text.UTF8Encoding($false)))

    Write-Host "[3/4] Đang copy '$FileName' vào container '$ContainerName'..." -ForegroundColor Yellow
    docker cp $BackupPath "${ContainerName}:${ContainerEjsonPath}"
    Assert-LastExitCode "Docker Copy Backup"

    docker cp $LocalTempJs "${ContainerName}:${ContainerJsPath}"
    Assert-LastExitCode "Docker Copy Script"

    Write-Host "[4/4] Đang nạp collections, validators, indexes và documents vào '$DbName'..." -ForegroundColor Yellow
    docker exec $ContainerName mongosh --quiet $ContainerJsPath
    Assert-LastExitCode "mongosh restore"
} finally {
    if (Test-Path $LocalTempJs) {
        Remove-Item -Path $LocalTempJs -Force -ErrorAction SilentlyContinue
    }
    docker exec $ContainerName rm -f $ContainerEjsonPath $ContainerJsPath 2>$null | Out-Null
}

Write-Host "============================================================" -ForegroundColor Green
Write-Host " [OK] Đã thêm/bật '$ContainerName' và khôi phục '$FileName' vào '$DbName'!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green

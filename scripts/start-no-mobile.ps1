# start-no-mobile.ps1 — start full stack for web dev (mobile runs via Expo natively)
# Usage: .\scripts\start-no-mobile.ps1 [-Build] [-NoDetach]
param(
    [switch]$Build,
    [switch]$NoDetach
)

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ComposeFile = "$ScriptDir\..\docker\docker-compose.yml"
$EnvFile     = "$ScriptDir\..\docker\.env"

if (-not (Test-Path $EnvFile)) {
    Write-Error "[ERROR] .env not found. Copy docker\.env.example to docker\.env and fill in secrets."
    exit 1
}

$services = @(
    "mongo", "postgres", "redis", "rabbitmq", "chromadb", "pgadmin",
    "business-service", "ai-service", "publisher-service", "api-gateway", "web-dashboard"
)

$composeArgs = @("-f", $ComposeFile, "--env-file", $EnvFile, "up")
if ($Build)         { $composeArgs += "--build" }
if (-not $NoDetach) { $composeArgs += "-d" }
$composeArgs += $services

Write-Host "==> Starting BrandHub stack (web + backend, no mobile container)..." -ForegroundColor Cyan
& docker compose @composeArgs

if (-not $NoDetach) {
    Write-Host ""
    Write-Host "==> Services running:" -ForegroundColor Green
    Write-Host "    Web Dashboard    http://localhost:3000"
    Write-Host "    API Gateway      http://localhost:8080"
    Write-Host "    Business Service http://localhost:8081"
    Write-Host "    AI Service       http://localhost:8082"
    Write-Host "    Publisher        http://localhost:8083"
    Write-Host "    pgAdmin          http://localhost:5050  (admin@brandhub.local / admin)"
    Write-Host "    RabbitMQ UI      http://localhost:15672"
    Write-Host "    MongoDB          localhost:27017"
    Write-Host "    PostgreSQL       localhost:5432"
    Write-Host "    Redis            localhost:6379"
    Write-Host "    ChromaDB         http://localhost:8000"
    Write-Host ""
    Write-Host "==> Mobile (Expo): cd brandhub-mobile-app; npx expo start" -ForegroundColor Yellow
    Write-Host "    Set EXPO_PUBLIC_API_BASE_URL=http://<your-local-ip>:8080 in mobile .env"
}

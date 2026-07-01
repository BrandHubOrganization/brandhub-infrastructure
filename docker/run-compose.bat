@echo off
setlocal

cd /d "%~dp0"

set MODE=%~1
set PROJECT_NAME=brandhub

echo [BrandHub] Docker Compose runner
echo [INFO] Compose project: %PROJECT_NAME%

where docker >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Docker CLI not found. Please install/start Docker Desktop.
  exit /b 1
)

docker compose version >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Docker Compose plugin is not available.
  exit /b 1
)

if not exist ".env" (
  if not exist ".env.example" (
    echo [ERROR] .env.example not found.
    exit /b 1
  )
  echo [INFO] .env not found. Copying .env.example to .env...
  copy ".env.example" ".env" >nul
  echo [WARN] Please review .env and update passwords/secrets before shared usage.
)

echo [1/3] Checking infra config...
docker compose -p %PROJECT_NAME% -f docker-compose.infra.yml config >nul
if errorlevel 1 (
  echo [ERROR] Infra compose config is invalid.
  exit /b 1
)

echo [2/3] Checking infra + dev config...
docker compose -p %PROJECT_NAME% -f docker-compose.infra.yml -f docker-compose.dev.yml config >nul
if errorlevel 1 (
  echo [ERROR] Infra + dev compose config is invalid.
  exit /b 1
)

echo [3/3] Starting infra + dev services...
docker compose -p %PROJECT_NAME% -f docker-compose.infra.yml -f docker-compose.dev.yml up -d
if errorlevel 1 (
  echo [ERROR] Failed to start infra + dev services.
  exit /b 1
)

if /I "%MODE%"=="full" (
  echo [FULL] Checking full stack config...
  docker compose -p %PROJECT_NAME% -f docker-compose.infra.yml -f docker-compose.apps.yml -f docker-compose.dev.yml config >nul
  if errorlevel 1 (
    echo [ERROR] Full stack config is invalid.
    echo [HINT] Enable rabbitmq/chromadb in docker-compose.infra.yml if app services depend on them.
    exit /b 1
  )

  echo [FULL] Starting full stack...
  docker compose -p %PROJECT_NAME% -f docker-compose.infra.yml -f docker-compose.apps.yml -f docker-compose.dev.yml up -d
  if errorlevel 1 (
    echo [ERROR] Failed to start full stack.
    exit /b 1
  )
)

echo [DONE] Containers:
docker compose -p %PROJECT_NAME% -f docker-compose.infra.yml -f docker-compose.dev.yml ps

endlocal

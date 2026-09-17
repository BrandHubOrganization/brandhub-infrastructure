@echo off
setlocal

set SCRIPT_DIR=%~dp0
set DOCKER_DIR=%SCRIPT_DIR%..

cd /d "%DOCKER_DIR%"

set PROJECT_NAME=brandhub
set COMPOSE_FILES=
set MODE=%~1

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

if not "%MODE%"=="" goto resolve

echo.
echo Select a mode:
echo   [1] infra    - Databases + Cache/Broker + Dev ^(PostgreSQL, Redis, RabbitMQ, pgAdmin, RedisInsight^)
echo   [2] infra_ai - AI Data + Databases + Cache/Broker + Dev ^(Neo4j, ChromaDB, PostgreSQL, Redis, RabbitMQ, pgAdmin, RedisInsight^)
echo   [3] full     - all infra + dev tools + app services
echo.
echo   Shortcut: run.bat infra ^| run.bat infra_ai ^| run.bat full
echo.
choice /C 123 /N /M "  Choose mode [1/2/3]? "
if errorlevel 3 (
  set "MODE=full"
) else if errorlevel 2 (
  set "MODE=infra_ai"
) else (
  set "MODE=infra"
)

:resolve
if /i "%MODE%"=="infra" (
  set "COMPOSE_FILES= -f docker-compose.infra.databases.yml -f docker-compose.infra.cache-broker.yml -f docker-compose.dev.yml"
) else if /i "%MODE%"=="infra_ai" (
  set "COMPOSE_FILES= -f docker-compose.infra.databases.yml -f docker-compose.infra.ai-data.yml -f docker-compose.infra.cache-broker.yml -f docker-compose.dev.yml"
) else if /i "%MODE%"=="full" (
  set "COMPOSE_FILES= -f docker-compose.infra.databases.yml -f docker-compose.infra.ai-data.yml -f docker-compose.infra.cache-broker.yml -f docker-compose.dev.yml -f docker-compose.apps.yml"
) else (
  echo [ERROR] Unknown mode "%MODE%". Use: infra, infra_ai, or full.
  exit /b 1
)

echo.
echo [RUN] docker compose -p %PROJECT_NAME%%COMPOSE_FILES% up -d
echo.

docker compose -p %PROJECT_NAME%%COMPOSE_FILES% config >nul
if errorlevel 1 (
  echo [ERROR] Compose config is invalid for mode "%MODE%".
  exit /b 1
)

docker compose -p %PROJECT_NAME%%COMPOSE_FILES% up -d
if errorlevel 1 (
  echo [ERROR] Failed to start mode "%MODE%".
  exit /b 1
)

echo.
echo [DONE] Mode "%MODE%" containers:
docker compose -p %PROJECT_NAME%%COMPOSE_FILES% ps

endlocal

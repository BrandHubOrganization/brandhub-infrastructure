@echo off
setlocal

set PROJECT_NAME=brandhub
set INFRA_FILES=-f docker-compose.infra.databases.yml -f docker-compose.infra.ai-data.yml -f docker-compose.infra.cache-broker.yml
set SCRIPT_DIR=%~dp0
set DOCKER_DIR=%SCRIPT_DIR%..
set CACHE_MODE=%~1

echo [BrandHub] Docker Compose shutdown
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

pushd "%DOCKER_DIR%" >nul
if errorlevel 1 (
  echo [ERROR] Cannot enter docker directory: %DOCKER_DIR%
  exit /b 1
)

echo [1/2] Stopping and removing infra + dev containers...
docker compose -p %PROJECT_NAME% %INFRA_FILES% -f docker-compose.dev.yml down --remove-orphans
if errorlevel 1 (
  popd >nul
  echo [ERROR] Failed to stop infra + dev containers.
  exit /b 1
)

if /I "%CACHE_MODE%"=="cache" (
  echo [2/2] Removing Docker build cache...
  docker builder prune -a -f
  if errorlevel 1 (
    popd >nul
    echo [ERROR] Failed to remove Docker build cache.
    exit /b 1
  )
) else (
  echo [2/2] Skipping cache cleanup. Pass "cache" to also run docker builder prune -a -f.
)

echo [DONE] Containers are stopped. Named volumes are kept.

popd >nul
endlocal

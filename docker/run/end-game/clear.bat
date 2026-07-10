@echo off
setlocal

set CONFIRM=%~1
set SCRIPT_DIR=%~dp0
set DOCKER_DIR=%SCRIPT_DIR%..\..
set PROJECT_NAME=brandhub

echo [BrandHub] Docker cleanup for BrandHub resources only
echo [WARN] This removes BrandHub containers, BrandHub named volumes, BrandHub network,
echo [WARN] BrandHub-tagged images, and Docker build cache.
echo [WARN] It does not remove unrelated Docker containers/images/volumes.
echo.

if /I not "%CONFIRM%"=="YES" (
  echo [ABORTED] To run this cleanup, execute:
  echo   run\end-game\clear.bat YES
  exit /b 1
)

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

echo [1/6] Stopping BrandHub compose stacks and removing BrandHub compose volumes...
docker compose -p %PROJECT_NAME% -f docker-compose.infra.yml -f docker-compose.dev.yml down -v --remove-orphans
docker compose -p %PROJECT_NAME% -f docker-compose.infra.yml -f docker-compose.apps.yml -f docker-compose.dev.yml down -v --remove-orphans

echo [2/6] Removing leftover BrandHub containers...
for /f "tokens=*" %%i in ('docker ps -aq --filter "label=com.docker.compose.project=%PROJECT_NAME%"') do docker rm -f %%i
for /f "tokens=*" %%i in ('docker ps -aq --filter "name=brandhub-"') do docker rm -f %%i

echo [3/6] Removing BrandHub volumes...
for /f "tokens=*" %%i in ('docker volume ls -q --filter "name=brandhub"') do docker volume rm -f %%i

echo [4/6] Removing BrandHub networks...
for /f "tokens=*" %%i in ('docker network ls -q --filter "label=com.docker.compose.project=%PROJECT_NAME%"') do docker network rm %%i
for /f "tokens=*" %%i in ('docker network ls -q --filter "name=brandhub"') do docker network rm %%i

echo [5/6] Removing BrandHub-tagged images...
for /f "tokens=*" %%i in ('docker images "brandhub*" -q') do docker rmi -f %%i
for /f "tokens=*" %%i in ('docker images "brandhub/*" -q') do docker rmi -f %%i

echo [6/6] Removing Docker build cache...
docker builder prune -a -f

popd >nul

echo [DONE] BrandHub Docker cleanup completed.
endlocal

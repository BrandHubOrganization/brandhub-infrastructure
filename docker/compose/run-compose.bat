@echo off
setlocal
set "MODE=%~1"
set "ACTION=%~2"
if "%MODE%"=="" set "MODE=dev"
if "%ACTION%"=="" set "ACTION=up"
if /I "%MODE%"=="dev" goto mode_ok
if /I "%MODE%"=="dev-ai" goto mode_ok
if /I "%MODE%"=="production" goto mode_ok
echo [ERROR] Use dev, dev-ai, or production.
exit /b 1
:mode_ok
if /I "%ACTION%"=="up" goto action_ok
if /I "%ACTION%"=="down" goto action_ok
if /I "%ACTION%"=="config" goto action_ok
echo [ERROR] Use up, down, or config.
exit /b 1
:action_ok
where docker >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Docker CLI not found.
  exit /b 1
)
docker compose version >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Docker Compose is unavailable.
  exit /b 1
)
if not exist "%~dp0.env" (
  if exist "%~dp0.env.example" copy "%~dp0.env.example" "%~dp0.env" >nul
  echo [ERROR] Configure compose/.env before running this script.
  exit /b 1
)
pushd "%~dp0%MODE%"
if errorlevel 1 exit /b 1
set COMPOSE=docker compose -p brandhub --env-file "%~dp0.env" -f compose.yaml
%COMPOSE% config --quiet
if errorlevel 1 goto failed
if /I "%ACTION%"=="config" goto done
if /I "%ACTION%"=="down" goto down
if /I "%MODE%"=="production" (
  if not exist "nginx\certs\fullchain.pem" (
    echo [ERROR] Missing production/nginx/certs/fullchain.pem.
    goto failed
  )
  if not exist "nginx\certs\privkey.pem" (
    echo [ERROR] Missing production/nginx/certs/privkey.pem.
    goto failed
  )
)
%COMPOSE% up -d --remove-orphans
if errorlevel 1 goto failed
%COMPOSE% ps
if errorlevel 1 goto failed
goto done
:down
%COMPOSE% down --remove-orphans
if errorlevel 1 goto failed
:done
popd
exit /b 0
:failed
popd
exit /b 1

@echo off
setlocal

rem Clone or pull the seven BrandHub repositories beside brandhub-infrastructure.
set "ORG_NAME=BrandHubOrganization"
set "BASE_URL=https://github.com/%ORG_NAME%"
set "FAILED=0"

where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Git is not installed or is not available in PATH.
    exit /b 1
)

pushd "%~dp0..\.."
if errorlevel 1 (
    echo [ERROR] Cannot access the workspace directory.
    exit /b 1
)

echo Synchronizing repositories from %ORG_NAME%...
for %%R in (
    brandhub-ai-service
    brandhub-api-gateway
    brandhub-business-service
    brandhub-infrastructure
    brandhub-mobile-app
    brandhub-publisher-service
    brandhub-web
) do call :sync_repo "%%R"

popd
if "%FAILED%"=="1" (
    echo [ERROR] Some repositories could not be synchronized. Check the output above.
    exit /b 1
)
echo [OK] All repositories synchronized successfully.
exit /b 0

:sync_repo
echo ------------------------------------------------------------
if exist "%~1\" (
    if not exist "%~1\.git" (
        echo [ERROR] %~1 exists but is not a Git repository. Skipping.
        set "FAILED=1"
        exit /b 0
    )
    echo [PULL] Updating %~1...
    git -C "%~1" pull
) else (
    echo [CLONE] Cloning %~1...
    git clone "%BASE_URL%/%~1.git" "%~1"
)
if errorlevel 1 (
    echo [ERROR] Failed to synchronize %~1.
    set "FAILED=1"
)
exit /b 0

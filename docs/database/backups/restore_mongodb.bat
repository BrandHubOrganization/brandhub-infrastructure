@echo off
chcp 65001 >nul
setlocal

REM ============================================================================
REM Add/start brandhub-mongodb container in brandhub and restore .ejson backup
REM Usage:
REM   restore_mongodb.bat
REM   restore_mongodb.bat -BackupFile "brandhub_mongodb_full_20261123.ejson"
REM   restore_mongodb.bat -DbName "brandhub"
REM ============================================================================

set "EXTRA_ARGS="
echo.%* | findstr /I /C:"-Force" >nul
if errorlevel 1 set "EXTRA_ARGS=-Force"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore_mongodb.ps1" %EXTRA_ARGS% %*
set EXIT_CODE=%ERRORLEVEL%

if not "%EXIT_CODE%"=="0" (
    echo.
    echo [ERROR] Restore failed with exit code %EXIT_CODE%.
    exit /b %EXIT_CODE%
)

exit /b 0

@echo off
chcp 65001 >nul
setlocal

REM ============================================================================
REM Add/start brandhub-mongodb container in brandhub and restore .ejson backup
REM Usage:
REM   restore-mongodb.bat
REM   restore-mongodb.bat -Force
REM   restore-mongodb.bat -BackupFile "brandhub_mongodb_full_20261123.ejson" -Force
REM   restore-mongodb.bat -DbName "brandhub"
REM ============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore-mongodb.ps1" %*
set EXIT_CODE=%ERRORLEVEL%

if not "%EXIT_CODE%"=="0" (
    echo.
    echo [ERROR] Restore failed with exit code %EXIT_CODE%.
    exit /b %EXIT_CODE%
)

exit /b 0

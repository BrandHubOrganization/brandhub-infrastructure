@echo off
chcp 65001 >nul
setlocal

REM ============================================================================
REM Replace existing PostgreSQL database with the latest full backup (Schema + Data)
REM Usage:
REM   restore-postgres.bat
REM   restore-postgres.bat -Force
REM   restore-postgres.bat -BackupFile "brandhub_postgres_full_20261123.dump"
REM ============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore-postgres.ps1" %*
set EXIT_CODE=%ERRORLEVEL%

if not "%EXIT_CODE%"=="0" (
    echo.
    echo [ERROR] Restore failed with exit code %EXIT_CODE%.
    exit /b %EXIT_CODE%
)

exit /b 0

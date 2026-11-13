@echo off
chcp 65001 >nul
setlocal

REM ============================================================================
REM Replace existing PostgreSQL database with the latest full backup (Schema + Data)
REM Usage:
REM   restore_postgres.bat
REM   restore_postgres.bat -Force
REM   restore_postgres.bat -BackupFile "brandhub_postgres_full_20261112.sql"
REM ============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore_postgres.ps1" %*
set EXIT_CODE=%ERRORLEVEL%

if not "%EXIT_CODE%"=="0" (
    echo.
    echo [ERROR] Restore failed with exit code %EXIT_CODE%.
    exit /b %EXIT_CODE%
)

exit /b 0

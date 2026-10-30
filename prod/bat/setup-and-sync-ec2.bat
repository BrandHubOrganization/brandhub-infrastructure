@echo off
setlocal
title BrandHub - Setup & Sync EC2 Infrastructure & DB
chcp 65001 >nul
set PYTHONUTF8=1

echo ========================================================
echo   BRANDHUB - AUTO SETUP ^& SYNC EC2 (DB, REDIS, QUEUE)
echo ========================================================
echo.

python "%~dp0setup-and-sync-ec2.py"
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Qua trinh cap nhat gap loi!
) else (
    echo.
    echo [OK] Hoan tat khoi tao va dong bo EC2 thanh cong!
)
echo.
pause

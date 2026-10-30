@echo off
setlocal

title Send File to EC2

echo ================================
echo        SEND FILE TO EC2
echo ================================
echo.

set /p "KEY_FILE=Nhap duong dan file .pem: "
set /p "FILE_TO_SEND=Nhap duong dan file can gui: "
set /p "EC2_DNS=Nhap EC2 Public DNS: "

rem Xoa dau ngoac kep neu copy path co ngoac kep
set "KEY_FILE=%KEY_FILE:"=%"
set "FILE_TO_SEND=%FILE_TO_SEND:"=%"
set "EC2_DNS=%EC2_DNS:"=%"

echo.
echo Dang gui file...
echo.

scp -i "%KEY_FILE%" "%FILE_TO_SEND%" ec2-user@%EC2_DNS%:/home/ec2-user/

echo.
if %errorlevel% equ 0 (
    echo [OK] Gui file thanh cong.
) else (
    echo [ERROR] Gui file that bai.
)

echo.
pause

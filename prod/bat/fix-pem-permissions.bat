@echo off
set /p "PEM=Nhap duong dan file .pem: "
set "PEM=%PEM:"=%"

for /f "delims=" %%U in ('whoami') do set "USER=%%U"

icacls "%PEM%" /inheritance:r
icacls "%PEM%" /grant:r "%USER%:(R)"
icacls "%PEM%" /remove "*S-1-5-32"
icacls "%PEM%"

pause
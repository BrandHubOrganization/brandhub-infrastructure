@echo off
call "%~dp0compose\run-compose.bat" dev %*
exit /b %errorlevel%

@echo off
call "%~dp0compose\run-compose.bat" dev-ai %*
exit /b %errorlevel%

@echo off
REM ============================================================
REM Fix DA-574 to DA-583: summary prefix + epic link
REM ============================================================

set TOKEN=ATATT3xFfGF0hOu_QP0K9NHqnGgsrxko4pKSzqkTXX2nm1YWWBm-g9KGqEEe0h1h90vbBdEskz9EoWDc3s2sB3WMnqNedf2RzztO0R0FwLqNs4vIotf4_r9kajvHL4p9G7W9PF_Z3qCkZP_21vJPbmbiul8PkiEdjpwr0AY3Cbt6O0nft6dvDtQ=080C74FD
set EMAIL=letritrung2605@gmail.com
set JIRA=https://letritrung2605.atlassian.net/rest/api/3/issue
set EPIC_E35=DA-117
set EPIC_E36=DA-119

echo ==========================================
echo FIXING 10 TASKS (DA-574 to DA-583)
echo ==========================================

echo [1/10] DA-574 - Register page
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E35-05] Build Register page (account creation form, validation, redirect to dashboard)\",\"parent\":{\"key\":\"%EPIC_E35%\"}}}" "%JIRA%/DA-574" -o nul -w "  HTTP %%{http_code}\n"

echo [2/10] DA-575 - Google OAuth
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E35-06] Build Google OAuth button + callback page (OAuth flow, handle new vs existing user)\",\"parent\":{\"key\":\"%EPIC_E35%\"}}}" "%JIRA%/DA-575" -o nul -w "  HTTP %%{http_code}\n"

echo [3/10] DA-576 - Workspace Settings
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E35-07] Build Workspace Settings page (timezone selector, default platforms, report frequency)\",\"parent\":{\"key\":\"%EPIC_E35%\"}}}" "%JIRA%/DA-576" -o nul -w "  HTTP %%{http_code}\n"

echo [4/10] DA-577 - Workspace Members
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E35-08] Build Workspace Members page (member table, invite button, remove action with confirm)\",\"parent\":{\"key\":\"%EPIC_E35%\"}}}" "%JIRA%/DA-577" -o nul -w "  HTTP %%{http_code}\n"

echo [5/10] DA-578 - Create Client
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E35-09] Build Create Client page (form: name, industry, brand color picker, logo upload)\",\"parent\":{\"key\":\"%EPIC_E35%\"}}}" "%JIRA%/DA-578" -o nul -w "  HTTP %%{http_code}\n"

echo [6/10] DA-579 - Edit Client
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E35-10] Build Edit Client page (pre-filled form: name, industry, brand color, logo)\",\"parent\":{\"key\":\"%EPIC_E35%\"}}}" "%JIRA%/DA-579" -o nul -w "  HTTP %%{http_code}\n"

echo [7/10] DA-580 - Client Service Package
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E35-11] Build Client Service Package page (posts/month input, platform checkboxes, AI credits slider)\",\"parent\":{\"key\":\"%EPIC_E35%\"}}}" "%JIRA%/DA-580" -o nul -w "  HTTP %%{http_code}\n"

echo [8/10] DA-581 - AI Generate Panel
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E36-06] Build AI Generate Panel (call ai-service, display caption + hashtag + image, regenerate with feedback)\",\"parent\":{\"key\":\"%EPIC_E36%\"}}}" "%JIRA%/DA-581" -o nul -w "  HTTP %%{http_code}\n"

echo [9/10] DA-582 - Template Browser
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E36-07] Build Template Browser page (saved drafts list, search, preview, use template)\",\"parent\":{\"key\":\"%EPIC_E36%\"}}}" "%JIRA%/DA-582" -o nul -w "  HTTP %%{http_code}\n"

echo [10/10] DA-583 - Hashtag Groups
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E36-08] Build Hashtag Groups page (CRUD hashtag groups, assign to posts)\",\"parent\":{\"key\":\"%EPIC_E36%\"}}}" "%JIRA%/DA-583" -o nul -w "  HTTP %%{http_code}\n"

echo.
echo ALL DONE. 10 tasks updated: summary prefix + epic link.
pause

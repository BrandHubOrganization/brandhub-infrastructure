@echo off
REM Fix Sprint 6 Jira issues: 3 assignees + 5 summaries
set TOKEN=ATATT3xFfGF0hOu_QP0K9NHqnGgsrxko4pKSzqkTXX2nm1YWWBm-g9KGqEEe0h1h90vbBdEskz9EoWDc3s2sB3WMnqNedf2RzztO0R0FwLqNs4vIotf4_r9kajvHL4p9G7W9PF_Z3qCkZP_21vJPbmbiul8PkiEdjpwr0AY3Cbt6O0nft6dvDtQ=080C74FD
set EMAIL=letritrung2605@gmail.com
set PHUOC_ID=712020:d2f784a1-44cf-468f-bb96-cd8930b1c135
set JIRA=https://letritrung2605.atlassian.net/rest/api/3/issue

echo ========================================
echo FIX 1/3: Reassign DA-135, DA-305, DA-339 to Phuoc
echo ========================================
for %%k in (DA-135 DA-305 DA-339) do (
  curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"accountId\":\"%PHUOC_ID%\"}" "%JIRA%/%%k/assignee" -o nul -w "%%k: HTTP %%{http_code}\n"
)

echo.
echo ========================================
echo FIX 2/5: Update DA-366 summary
echo ========================================
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E35-01] Build Login page (email/password form, error states)\"}}" "%JIRA%/DA-366" -o nul -w "DA-366: HTTP %%{http_code}\n"

echo ========================================
echo FIX 3/5: Update DA-323 summary
echo ========================================
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E35-03] Build Create Workspace page (form: name, industry)\"}}" "%JIRA%/DA-323" -o nul -w "DA-323: HTTP %%{http_code}\n"

echo ========================================
echo FIX 4/5: Update DA-339 summary
echo ========================================
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E35-04] Build Client List page (table, search, role filter)\"}}" "%JIRA%/DA-339" -o nul -w "DA-339: HTTP %%{http_code}\n"

echo ========================================
echo FIX 5/5: Update DA-346 summary
echo ========================================
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E36-05] Build Media Browser page (S3 file browser, upload, folders)\"}}" "%JIRA%/DA-346" -o nul -w "DA-346: HTTP %%{http_code}\n"

echo ========================================
echo FIX 6/5: Update DA-368 summary
echo ========================================
curl -s -u "%EMAIL%:%TOKEN%" -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"summary\":\"[DA-E36-02] Build Content Editor page (caption, hashtag, platform, image, schedule)\"}}" "%JIRA%/DA-368" -o nul -w "DA-368: HTTP %%{http_code}\n"

echo.
echo DONE. All 8 fixes applied.
pause

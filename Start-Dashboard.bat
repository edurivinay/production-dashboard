@echo off
title MISO Ribbon Dashboard — Live Host
cd /d "%~dp0"

:: Prefer Python server (full features: 0.0.0.0 bind, POST data.json)
where python >nul 2>&1
if %ERRORLEVEL%==0 (
  python server.py
  goto :eof
)
where py >nul 2>&1
if %ERRORLEVEL%==0 (
  py -3 server.py
  goto :eof
)

:: Fallback: PowerShell
where powershell >nul 2>&1
if %ERRORLEVEL%==0 (
  echo Starting PowerShell host...
  echo If other PCs cannot connect, run this window As Administrator once.
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-Dashboard.ps1"
  goto :eof
)

echo Need Python 3 or PowerShell.
pause

@echo off
title MISO Dashboard Installer — Live Shared Host
setlocal EnableExtensions
echo.
echo  ================================================
echo   MISO Ribbon Dashboard - LIVE SHARED INSTALL
echo  ================================================
echo.
echo  Admin uploads a report once.
echo  All other PCs open the link and turn Auto Sync ON.
echo  Everyone sees the same live numbers.
echo.

set "INSTALL_DIR=%LOCALAPPDATA%\MISO-Dashboard"
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs\MISO Dashboard"
set "DESKTOP=%USERPROFILE%\Desktop"

echo Installing to: %INSTALL_DIR%
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
copy /Y "%~dp0index.html" "%INSTALL_DIR%\index.html" >nul
copy /Y "%~dp0server.py" "%INSTALL_DIR%\server.py" >nul
copy /Y "%~dp0Start-Dashboard.bat" "%INSTALL_DIR%\Start-Dashboard.bat" >nul
copy /Y "%~dp0Start-Dashboard.ps1" "%INSTALL_DIR%\Start-Dashboard.ps1" >nul
copy /Y "%~dp0Start-Hidden.vbs" "%INSTALL_DIR%\Start-Hidden.vbs" >nul
copy /Y "%~dp0Uninstall.bat" "%INSTALL_DIR%\Uninstall.bat" >nul
copy /Y "%~dp0README.txt" "%INSTALL_DIR%\README.txt" >nul
if exist "%~dp0data.json" copy /Y "%~dp0data.json" "%INSTALL_DIR%\data.json" >nul

if not exist "%START_MENU%" mkdir "%START_MENU%"

powershell -NoProfile -Command ^
  "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%DESKTOP%\MISO Dashboard.lnk'); $s.TargetPath = '%INSTALL_DIR%\Start-Dashboard.bat'; $s.WorkingDirectory = '%INSTALL_DIR%'; $s.IconLocation = 'shell32.dll,165'; $s.Description = 'MISO Live Dashboard'; $s.Save()"

powershell -NoProfile -Command ^
  "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%START_MENU%\MISO Dashboard.lnk'); $s.TargetPath = '%INSTALL_DIR%\Start-Dashboard.bat'; $s.WorkingDirectory = '%INSTALL_DIR%'; $s.IconLocation = 'shell32.dll,165'; $s.Save()"

powershell -NoProfile -Command ^
  "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%STARTUP%\MISO Dashboard.lnk'); $s.TargetPath = '%INSTALL_DIR%\Start-Hidden.vbs'; $s.WorkingDirectory = '%INSTALL_DIR%'; $s.WindowStyle = 7; $s.Description = 'MISO auto-start'; $s.Save()"

echo.
echo  Installed.
echo  - Desktop: MISO Dashboard
echo  - Auto-start on Windows restart: ON
echo  - Shared data file: %INSTALL_DIR%\data.json
echo.
echo  HOW TO USE
echo  1. This PC (ADMIN): open dashboard, click Upload Report
echo  2. Other PCs: open http://THIS-PC-IP:8765/
echo  3. Other PCs: click Auto Sync ON
echo  4. When admin uploads again, all screens update
echo.
echo  Starting host now...
start "" "%INSTALL_DIR%\Start-Dashboard.bat"
echo.
pause

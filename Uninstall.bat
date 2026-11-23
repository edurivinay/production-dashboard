@echo off
title MISO Dashboard Uninstall
set "INSTALL_DIR=%LOCALAPPDATA%\MISO-Dashboard"
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs\MISO Dashboard"
set "DESKTOP=%USERPROFILE%\Desktop"
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM pythonw.exe >nul 2>&1
del /F /Q "%DESKTOP%\MISO Dashboard.lnk" >nul 2>&1
del /F /Q "%STARTUP%\MISO Dashboard.lnk" >nul 2>&1
if exist "%START_MENU%" rmdir /S /Q "%START_MENU%" >nul 2>&1
if exist "%INSTALL_DIR%" rmdir /S /Q "%INSTALL_DIR%" >nul 2>&1
echo Uninstalled.
pause

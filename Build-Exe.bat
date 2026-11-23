@echo off
title Build MISO-Dashboard.exe
echo This builds a Windows .exe on a PC that has Python.
echo.
python -m pip install --upgrade pyinstaller
python -m PyInstaller --noconfirm --onefile --windowed --name "MISO-Dashboard" ^
  --add-data "index.html;." ^
  server.py
echo.
echo If build succeeded, see folder: dist\MISO-Dashboard.exe
echo Copy index.html next to the exe if needed, or re-run with --add-data.
pause

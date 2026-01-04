@echo off
echo Running PowerShell script with temporary execution policy bypass...

REM Run the PowerShell script without permanently changing the system policy
powershell -NoProfile -ExecutionPolicy Bypass -File "filer.ps1"

echo.
echo Script finished.
pause

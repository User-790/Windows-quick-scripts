@echo off
:: Request administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo ================================================
echo Windows Update Disabler
echo ================================================
echo.
echo WARNING: Disabling Windows Updates may leave your
echo system vulnerable to security threats.
echo.
pause

echo.
echo Stopping Windows Update services...
net stop wuauserv
net stop UsoSvc
net stop WaaSMedicSvc

echo.
echo Disabling Windows Update services...
sc config wuauserv start=disabled
sc config UsoSvc start=disabled
sc config WaaSMedicSvc start=disabled

echo.
echo Disabling Windows Update via Registry...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f

echo.
echo Disabling Update Orchestrator Service...
takeown /f "%windir%\System32\Tasks\Microsoft\Windows\UpdateOrchestrator" /a /r
icacls "%windir%\System32\Tasks\Microsoft\Windows\UpdateOrchestrator" /grant Administrators:F /t
del /f /q "%windir%\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" 2>nul
del /f /q "%windir%\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\UpdateAssistant" 2>nul

echo.
echo ================================================
echo Windows Updates have been disabled.
echo ================================================
echo.
echo To re-enable updates later, you can:
echo 1. Set services back to Automatic in services.msc
echo 2. Delete the registry keys created
echo 3. Or run Windows Update Troubleshooter
echo.
pause

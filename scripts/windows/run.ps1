# Exit immediately if an error occurs
$ErrorActionPreference = "Stop"

Write-Host "INFO: Running application"

# Set default configuration if not provided
if (-not $env:CONFIG) {
    $env:CONFIG = "Release"
}

Write-Host "INFO: CONFIG=$env:CONFIG"

# Specify the path to the executable
$execPath = "C:\app\build\$env:CONFIG\CrossPlatformApp.exe"

# Check if the executable exists
if (-not (Test-Path $execPath)) {
    Write-Error "ERROR: Executable not found at $execPath."
    exit 1
}

Write-Host "INFO: Executing: $execPath"

# Run the executable
& $execPath

Write-Host "INFO: Application executed successfully."

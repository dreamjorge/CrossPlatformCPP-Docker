# Run the built application
param(
    [string]$env:VS_YEAR,
    [string]$env:VS_VERSION
)

Write-Host "Running application with Visual Studio $($env:VS_YEAR), Version $($env:VS_VERSION)"

# Example run logic
$appPath = "C:\app\bin\Release\CrossPlatformApp.exe"

if (Test-Path $appPath) {
    Write-Host "Executing application..."
    Start-Process $appPath -NoNewWindow -Wait
} else {
    Write-Host "Application not found at $appPath"
    exit 1
}
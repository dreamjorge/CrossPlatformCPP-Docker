# Run the compiled application
param(
    [string]$env:VS_YEAR,
    [string]$env:VS_VERSION
)

Write-Host "Running application with Visual Studio $($env:VS_YEAR), Version $($env:VS_VERSION)"

# Path to the compiled binary
$appPath = "C:\build\Release\CrossPlatformApp.exe"

if (Test-Path $appPath) {
    Write-Host "Executing application at $appPath"
    Start-Process $appPath -NoNewWindow -Wait
} else {
    Write-Host "Application binary not found at $appPath"
    exit 1
}
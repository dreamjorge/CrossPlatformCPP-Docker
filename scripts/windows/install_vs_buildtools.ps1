param (
    [string]$VS_VERSION = $env:VS_VERSION
)

if (-not $VS_VERSION) {
    Write-Error "VS_VERSION is not specified."
    exit 1
}

$vsInstaller = "C:\TEMP\vs_buildtools.exe"
$vsBootstrapperUrl = if ($VS_VERSION -eq "16") {
    "https://aka.ms/vs/16/release/vs_buildtools.exe"
} elseif ($VS_VERSION -eq "17") {
    "https://aka.ms/vs/17/release/vs_buildtools.exe"
} else {
    Write-Error "Unsupported VS_VERSION: $VS_VERSION."
    exit 1
}

Write-Host "Downloading Visual Studio Build Tools..."
Invoke-WebRequest -Uri $vsBootstrapperUrl -OutFile $vsInstaller -UseBasicParsing

if (-not (Test-Path $vsInstaller)) {
    Write-Error "Installer download failed. File not found: $vsInstaller"
    exit 1
}

Write-Host "Installing Visual Studio Build Tools..."
$logPath = "C:\TEMP\vs_install_log.txt"

try {
    Start-Process -FilePath $vsInstaller -ArgumentList "--quiet", "--wait", "--norestart", "--nocache", "--add", "Microsoft.VisualStudio.Workload.AzureBuildTools", "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64", "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041", "--log", $logPath -NoNewWindow -Wait
    Write-Host "Installation initiated. Logs at: $logPath"
} catch {
    Write-Error "Installation failed to start. Check logs at: $logPath"
    exit 1
}

# Wait until all installer processes are complete
Write-Host "Waiting for installer processes to complete..."
while (Get-Process -Name "vs_setup" -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 10
}

Write-Host "Validating installation..."
$installPath = "C:\Program Files (x86)\Microsoft Visual Studio\$VS_VERSION\BuildTools"
if (Test-Path $installPath) {
    Write-Host "Validation successful: Build Tools installed at $installPath"
} else {
    Write-Error "Validation failed: Installation directory not found."
    exit 1
}

Write-Host "Cleaning up..."
Remove-Item -Path $vsInstaller -Force -ErrorAction SilentlyContinue
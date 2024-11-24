param(
    [string]$VS_YEAR,
    [string]$VS_VERSION
)

# Resolve environment variables if arguments are not provided
if (-not $VS_YEAR) {
    $VS_YEAR = $env:VS_YEAR
}
if (-not $VS_VERSION) {
    $VS_VERSION = $env:VS_VERSION
}

Write-Host "Installing Visual Studio Build Tools for Year: $VS_YEAR, Version: $VS_VERSION"

# Define URLs and paths
$CHANNEL_URL = "https://aka.ms/vs/$VS_YEAR/release/channel"
$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/$VS_YEAR/release/vs_buildtools.exe"
$vsInstallerPath = "C:\temp\vs_buildtools.exe"

Write-Host "Channel URL: $CHANNEL_URL"
Write-Host "Build Tools URL: $VS_BUILD_TOOLS_URL"

# Create temp directory if it doesn't exist
if (-not (Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

# Download the installer with retries
$retryCount = 3
for ($i = 1; $i -le $retryCount; $i++) {
    try {
        Write-Host "Downloading Visual Studio Build Tools... Attempt $i"
        Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile $vsInstallerPath -UseBasicParsing
        if ((Test-Path $vsInstallerPath) -and ((Get-Item $vsInstallerPath).Length -gt 0)) {
            Write-Host "Download successful!"
            break
        } else {
            throw "File appears to be empty or invalid."
        }
    } catch {
        Write-Host "Download failed. Retrying..."
        if ($i -eq $retryCount) {
            throw "Failed to download Visual Studio Build Tools after $retryCount attempts."
        }
    }
}

# Verify installer path
if (-not (Test-Path $vsInstallerPath)) {
    throw "Installer file not found at $vsInstallerPath."
}

# Start installation
Write-Host "Starting Visual Studio Build Tools installation..."
try {
    $startTime = Get-Date
    Start-Process -FilePath $vsInstallerPath -ArgumentList `
        "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended" `
        -NoNewWindow -Wait

    $endTime = Get-Date
    $duration = $endTime - $startTime
    Write-Host "Installation completed in $($duration.TotalMinutes) minutes."
} catch {
    throw "Visual Studio Build Tools installation failed: $_"
}
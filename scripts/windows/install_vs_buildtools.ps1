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

Write-Host "Starting Visual Studio Build Tools installation for Year: $VS_YEAR, Version: $VS_VERSION"

# Define URLs and paths
$CHANNEL_URL = "https://aka.ms/vs/$VS_YEAR/release/channel"
$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/$VS_YEAR/release/vs_buildtools.exe"
$vsInstallerPath = "C:\temp\vs_buildtools.exe"

Write-Host "Channel URL: $CHANNEL_URL"
Write-Host "Build Tools URL: $VS_BUILD_TOOLS_URL"

# Create temp directory if it doesn't exist
if (-not (Test-Path -Path "C:\temp")) {
    Write-Host "Creating temp directory..."
    New-Item -ItemType Directory -Path "C:\temp"
}

# Download the installer with retries and progress tracking
$retryCount = 3
for ($i = 1; $i -le $retryCount; $i++) {
    try {
        Write-Host "[$(Get-Date -Format "HH:mm:ss")] Downloading Visual Studio Build Tools... Attempt $i"
        Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile $vsInstallerPath -UseBasicParsing
        if ((Test-Path $vsInstallerPath) -and ((Get-Item $vsInstallerPath).Length -gt 0)) {
            Write-Host "[$(Get-Date -Format "HH:mm:ss")] Download successful! File size: $((Get-Item $vsInstallerPath).Length / 1MB) MB"
            break
        } else {
            throw "File appears to be empty or invalid."
        }
    } catch {
        Write-Host "[$(Get-Date -Format "HH:mm:ss")] Download failed. Retrying..."
        if ($i -eq $retryCount) {
            throw "[$(Get-Date -Format "HH:mm:ss")] Failed to download Visual Studio Build Tools after $retryCount attempts."
        }
    }
}

# Verify installer path
if (-not (Test-Path $vsInstallerPath)) {
    throw "[$(Get-Date -Format "HH:mm:ss")] Installer file not found at $vsInstallerPath."
}

# Start installation with progress tracking
Write-Host "[$(Get-Date -Format "HH:mm:ss")] Starting Visual Studio Build Tools installation..."
try {
    $startTime = Get-Date
    Write-Host "[$(Get-Date -Format "HH:mm:ss")] Installation in progress. This may take some time..."
    
    # Run the installer with detailed logging
    Start-Process -FilePath $vsInstallerPath -ArgumentList `
        "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended" `
        -NoNewWindow -Wait

    $endTime = Get-Date
    $duration = $endTime - $startTime
    Write-Host "[$(Get-Date -Format "HH:mm:ss")] Installation completed in $($duration.TotalMinutes) minutes."
} catch {
    throw "[$(Get-Date -Format "HH:mm:ss")] Visual Studio Build Tools installation failed: $_"
}

Write-Host "[$(Get-Date -Format "HH:mm:ss")] Visual Studio Build Tools installation completed successfully."
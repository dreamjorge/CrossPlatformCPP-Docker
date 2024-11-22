param (
    [Parameter(Mandatory = $true)]
    [string]$ChannelUrl,
    [Parameter(Mandatory = $true)]
    [string]$BuildToolsUrl
)

# Exit immediately if an error occurs
$ErrorActionPreference = "Stop"

Write-Host "INFO: Starting Visual Studio Build Tools installation..."
Write-Host "DEBUG: Received ChannelUrl=$ChannelUrl"
Write-Host "DEBUG: Received BuildToolsUrl=$BuildToolsUrl"

# Validate URLs
if (-not $BuildToolsUrl -or -not $ChannelUrl) {
    Write-Error "ERROR: BuildToolsUrl or ChannelUrl is empty. Ensure the values are passed correctly."
    exit 1
}

if (-not ($BuildToolsUrl -match "^https?:\/\/")) {
    Write-Error "ERROR: Invalid BuildToolsUrl format: $BuildToolsUrl"
    exit 1
}

if (-not ($ChannelUrl -match "^https?:\/\/")) {
    Write-Error "ERROR: Invalid ChannelUrl format: $ChannelUrl"
    exit 1
}

# Temporary paths
$tempDir = "C:\temp"
$installerPath = "$tempDir\vs_buildtools.exe"
$logPath = "$tempDir\vs_installation.log"

# Create temporary directory
if (!(Test-Path -Path $tempDir)) {
    Write-Host "INFO: Creating temporary directory at $tempDir"
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# Download the Visual Studio Build Tools installer
Write-Host "INFO: Downloading Visual Studio Build Tools from $BuildToolsUrl"
Invoke-WebRequest -Uri $BuildToolsUrl -OutFile $installerPath

param (
    [Parameter(Mandatory = $true)]
    [string]$ChannelUrl,  # URL to the Visual Studio Channel
    [Parameter(Mandatory = $true)]
    [string]$BuildToolsUrl  # URL to the Visual Studio Build Tools installer
)

# Exit immediately if an error occurs
$ErrorActionPreference = "Stop"

Write-Host "INFO: Starting Visual Studio Build Tools installation..."

# Debugging: Output the received parameters
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
Invoke-WebRequest -Uri $BuildToolsUrl -OutFile $installerPath -UseBasicParsing

# Verify installer download
if (!(Test-Path -Path $installerPath)) {
    Write-Error "ERROR: Failed to download Visual Studio Build Tools installer."
    exit 1
}

Write-Host "INFO: Installer downloaded successfully to $installerPath"

# Execute the installer
Write-Host "INFO: Installing Visual Studio Build Tools..."
Start-Process -FilePath $installerPath `
    -ArgumentList `
    "--quiet", `
    "--norestart", `
    "--wait", `
    "--add Microsoft.VisualStudio.Workload.VCTools;includeRecommended" `
    "--channelUri $ChannelUrl" `
    "--installPath C:\BuildTools" `
    "--log $logPath" `
    -NoNewWindow -Wait

# Verify installation
if ($LASTEXITCODE -ne 0) {
    Write-Error "ERROR: Visual Studio Build Tools installation failed. Check logs at $logPath"
    exit $LASTEXITCODE
}

Write-Host "INFO: Visual Studio Build Tools installed successfully!"

# Cleanup temporary files
Write-Host "INFO: Cleaning up temporary files..."
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "INFO: Visual Studio Build Tools installation completed successfully."
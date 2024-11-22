param (
    [Parameter(Mandatory = $true)]
    [string]$ChannelUrl,  # URL to the Visual Studio Channel

    [Parameter(Mandatory = $true)]
    [string]$BuildToolsUrl  # URL to the Visual Studio Build Tools installer
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

# Download the Visual Studio Build Tools installer with retry logic
$maxRetries = 3
$retryCount = 0
$downloadSuccess = $false

while (-not $downloadSuccess -and $retryCount -lt $maxRetries) {
    try {
        Write-Host "INFO: Downloading Visual Studio Build Tools from $BuildToolsUrl (Attempt $($retryCount + 1))"
        Invoke-WebRequest -Uri $BuildToolsUrl -OutFile $installerPath -UseBasicParsing
        $downloadSuccess = $true
    }
    catch {
        $retryCount++
        Write-Host "WARNING: Download failed. Retry attempt $retryCount of $maxRetries."
        Start-Sleep -Seconds 5
    }
}

if (-not $downloadSuccess) {
    Write-Error "ERROR: Failed to download Visual Studio Build Tools after $maxRetries attempts."
    exit 1
}

# Verify installer download
if (!(Test-Path -Path $installerPath)) {
    Write-Error "ERROR: Failed to download Visual Studio Build Tools installer."
    exit 1
}

Write-Host "INFO: Installer downloaded successfully to $installerPath"

# Prepare argument list as an array
$arguments = @(
    "--quiet",
    "--norestart",
    "--wait",
    "--add", "Microsoft.VisualStudio.Workload.VCTools;includeRecommended",
    "--channelUri", $ChannelUrl,
    "--installPath", "C:\BuildTools",
    "--log", $logPath
)

# Execute the installer
Write-Host "INFO: Installing Visual Studio Build Tools with arguments: $arguments"
Start-Process -FilePath $installerPath `
    -ArgumentList $arguments `
    -NoNewWindow -Wait

# Always output the log
if (Test-Path $logPath) {
    Write-Host "----- BEGIN vs_installation.log -----"
    Get-Content $logPath | Write-Host
    Write-Host "----- END vs_installation.log -----"
}
else {
    Write-Host "WARNING: Log file not found at $logPath"
}

# Additional Diagnostic: List contents of C:\BuildTools
Write-Host "INFO: Listing contents of C:\BuildTools to verify installation..."
Get-ChildItem -Path "C:\BuildTools" -Recurse | Select-Object FullName | Write-Host

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

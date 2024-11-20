# Exit on error
$ErrorActionPreference = "Stop"

# Validate required variables
if (-not $env:CHANNEL_URL) {
    Write-Error "CHANNEL_URL environment variable is not set."
    exit 1
}
if (-not $env:VS_BUILD_TOOLS_URL) {
    Write-Error "VS_BUILD_TOOLS_URL environment variable is not set."
    exit 1
}

# Download Visual Studio Channel
Write-Host "Downloading Visual Studio Channel from $env:CHANNEL_URL"
Invoke-WebRequest -Uri $env:CHANNEL_URL -OutFile "$env:TEMP_DIR\VisualStudioChannel.json"

# Download Visual Studio Build Tools
Write-Host "Downloading Visual Studio Build Tools from $env:VS_BUILD_TOOLS_URL"
Invoke-WebRequest -Uri $env:VS_BUILD_TOOLS_URL -OutFile "$env:TEMP_DIR\vs_buildtools.exe"

# Install Visual Studio Build Tools
Write-Host "Installing Visual Studio Build Tools..."
Start-Process -FilePath "$env:TEMP_DIR\vs_buildtools.exe" -ArgumentList `
    '--quiet', '--wait', '--norestart', '--nocache', `
    '--channelUri', "$env:TEMP_DIR\VisualStudioChannel.json", `
    '--installPath', "$env:BUILD_TOOLS_PATH", `
    '--add', 'Microsoft.VisualStudio.Workload.VCTools', `
    '--includeRecommended' -Wait
Write-Host "Visual Studio Build Tools installation completed successfully."
